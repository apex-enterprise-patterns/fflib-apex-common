/**
 * File Name: fflib_ClassicSelectorBindingResolverTest 
 * Description: Unit test class for the Selector class binding resolver based on the classic AEP 1.0 definition with static maps
 *
 * @author: architect ir. Wilhelmus G.J. Velzeboer
 *
 * Redistribution and use in source and binary forms, with or without modification,
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above author notice,
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 * - Neither the name of the author nor the names of its contributors
 *      may be used to endorse or promote products derived from this software without
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
@IsTest
public class fflib_ClassicSelectorBindingResolverTest
{
	@IsTest
	static void itShouldReturnTheSelectorInstance()
	{
		// GIVEN a configured selector binding resolver with an implementation linked to a SObjectType
		fflib_ClassicSelectorBindingResolver selector = generateConfiguredSelectorBindingResolver();

		// WHEN we request an instance for the SObjectType
		fflib_ISObjectSelector result = selector.newInstance(Schema.Account.SObjectType);

		// THEN the result should be an instance of the AccountsSelector
		System.assert(
				result instanceof AccountsSelector,
				'Incorrect implementation returned'
		);
	}

	@IsTest
	static void itShouldReturnTheImplementation_NoImplementationRegisteredException()
	{
		// GIVEN an empty selector binding resolver
		fflib_ClassicSelectorBindingResolver selector =
				new fflib_ClassicSelectorBindingResolver(new Map<Schema.SObjectType, Type> {});

		// WHEN we request an instance for the SObjectType
		Boolean exceptionThrown = false;
		try
		{
			selector.newInstance(Schema.Account.SObjectType);
		} catch (fflib_ClassicSelectorBindingResolver.DeveloperException e)
		{
			exceptionThrown = true;
		}

		// THEN an exception should have been thrown
		System.assert(
				exceptionThrown,
				'An exception should have been thrown as the requested SObjectType mapping is not present'
		);
	}

	@IsTest
	static void itShouldReturnTheMockInstance()
	{
		// GIVEN a configured service binding resolver with an interface linked to an implementation
		//    where the linked implementation for the SObjectType has been replaced with a mock
		fflib_ISelectorBindingResolver selector = generateConfiguredSelectorBindingResolver();

		selector.setMock(new AccountsSelectorMock());

		// WHEN we request an instance for the SObjectType
		fflib_ISObjectSelector result = selector.newInstance(Schema.Account.SObjectType);

		// THEN the result should be the AccountsSelectorMock instance
		System.assert(
				result instanceof AccountsSelectorMock,
				'Incorrect instance returned'
		);
	}

	@IsTest
	static void itShouldReturnTheReplacedInstance()
	{
		// GIVEN a configured service binding resolver with an interface linked to an implementation
		//   where the implementation is replaced for an alternative implementation
		fflib_ISelectorBindingResolver selector = generateConfiguredSelectorBindingResolver();
		selector.replaceWith(Schema.Account.SObjectType, new AccountsSelectorMock());

		// WHEN we request the implementation for the interface
		fflib_ISObjectSelector result = selector.newInstance(Schema.Account.SObjectType);

		// THEN it should return the alternative implementation
		System.assert(
				result instanceof AccountsSelectorMock,
				'Incorrect implementation returned, expected the alternative implementation'
		);
	}

	@IsTest
	static void itShouldReturnTheReplacedImplementation()
	{
		// GIVEN a configured service binding resolver with an interface linked to an implementation
		//   where the implementation is replaced for an alternative implementation
		fflib_ISelectorBindingResolver selector = generateConfiguredSelectorBindingResolver();
		selector.replaceWith(Schema.Account.SObjectType, AccountsSelectorMock.class);

		// WHEN we request the implementation for the interface
		fflib_ISObjectSelector result = selector.newInstance(Schema.Account.SObjectType);

		// THEN it should return the alternative implementation
		System.assert(
				result instanceof AccountsSelectorMock,
				'Incorrect implementation returned, expected the alternative implementation'
		);
	}

	@IsTest
	static void itShouldQueryTheRecords()
	{
		// GIVEN a configured Selector binding resolver
		fflib_ClassicSelectorBindingResolver selector = new fflib_ClassicSelectorBindingResolver(
				new Map<SObjectType, Type>
				{
						Schema.Account.SObjectType => AccountsSelectorMock.class
				}
		);
		Id accountId = fflib_IDGenerator.generate(Schema.Account.SObjectType);
		AccountsSelectorMock selectorMock = new AccountsSelectorMock();
		selectorMock.records = new List<Account> {new Account(Id = accountId, Name = 'Test')};
		selector.setMock(selectorMock);

		// WHEN we request the records from the selector resolver
		List<SObject> result = selector.selectById(new Set<Id>{ accountId });

		// THEN the records should be returned
		System.assert(selectorMock.records.equals(result));
	}

	@TestVisible
	private static fflib_ClassicSelectorBindingResolver generateConfiguredSelectorBindingResolver()
	{
		return new fflib_ClassicSelectorBindingResolver(
				new Map<SObjectType, Type>
				{
						Schema.Account.SObjectType => AccountsSelector.class
				}
		);
	}

	public class AccountsSelector extends fflib_SObjectSelector
	{
		public List<Schema.SObjectField> getSObjectFieldList()
		{
			return new List<Schema.SObjectField>
			{
					Account.Id,
					Account.AccountNumber,
					Account.Name,
					Account.Phone
			};
		}

		public Schema.SObjectType getSObjectType()
		{
			return Schema.Account.SObjectType;
		}

		public List<Account> selectById(Set<Id> idSet)
		{
			return (List<Account>) selectSObjectsById(idSet);
		}
	}

	public class AccountsSelectorMock extends fflib_SObjectSelector
	{
		public List<Account> records;

		public List<Schema.SObjectField> getSObjectFieldList()
		{
			return new List<Schema.SObjectField> {};
		}

		public Schema.SObjectType getSObjectType()
		{
			return Schema.Account.SObjectType;
		}

		public override List<SObject> selectSObjectsById(Set<Id> idSet)
		{
			return selectById(idSet);
		}

		public List<Account> selectById(Set<Id> idSet)
		{
			return records;
		}
	}
}