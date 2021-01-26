/**
 * File Name: fflib_ClassicDomainBindingResolverTest
 * Description: Unit test class for the Domain class binding resolver based on the classic AEP 1.0 definition with static maps
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
private class fflib_ClassicDomainBindingResolverTest
{
	@IsTest
	static void itShouldReturnTheDomainInstance()
	{
		// GIVEN a configured domain binding resolver with an implementation linked to a SObjectType
		fflib_ClassicDomainBindingResolver domain = generateConfiguredBindingResolver();
		List<Account> records = generateAccounts();

		// WHEN we request an instance for the SObjectType
		fflib_IDomain result = domain.newInstance(records);

		// THEN the result should be an instance of the Accounts domain class containing the records
		System.assert(
				result instanceof Accounts,
				'Incorrect implementation returned'
		);
		System.assert(
				((List<Account>) result.getObjects()).equals(records),
				'Returned instance does not contain the right records'
		);
	}

	@IsTest
	static void itShouldReturnTheDomainInstance_DeveloperException_UnknownSObjectType()
	{
		// GIVEN a configured domain binding resolver with an implementation linked to a SObjectType
		//   and an list of an unknown SObjectType
		fflib_ClassicDomainBindingResolver bindingResolver = generateConfiguredBindingResolver();
		List<SObject> records = new List<SObject>();

		// WHEN a domain is requested with a list of an unregistered SObjectType
		Boolean exceptionThrown = false;
		try
		{
			fflib_IDomain domain = bindingResolver.newInstance(records);
		}
		catch (fflib_ClassicDomainBindingResolver.DeveloperException e)
		{
			exceptionThrown = true;
			System.assertEquals(
					'Unable to determine SObjectType',
					e.getMessage(),
					'Incorrect returned exception message'
			);
		}

		// THEN an developer exception should have been thrown
		System.assert(exceptionThrown, 'Expected a fflib_ClassicDomainBindingResolver.DeveloperException');
	}

	@IsTest
	static void itShouldReturnTheDomainInstance_DeveloperException_BindingNotFound()
	{
		// GIVEN a configured domain binding resolver with an implementation linked to a SObjectType
		//   and an list of an unregistered SObjectType
		fflib_ClassicDomainBindingResolver bindingResolver = generateConfiguredBindingResolver();
		List<Contact> contacts = new List<Contact>();

		// WHEN a domain is requested with a list of an unregistered SObjectType
		Boolean exceptionThrown = false;
		try
		{
			fflib_IDomain domain = bindingResolver.newInstance(contacts);
		}
		catch (fflib_ClassicDomainBindingResolver.DeveloperException e)
		{
			exceptionThrown = true;
			System.assertEquals(
					'Domain constructor class not found for SObjectType Contact',
					e.getMessage(),
					'Incorrect returned exception message'
			);
		}

		// THEN an developer exception should have been thrown
		System.assert(exceptionThrown, 'Expected a fflib_ClassicDomainBindingResolver.DeveloperException');
	}

	@IsTest
	static void itShouldReturnTheMockDomainInstance()
	{
		// GIVEN a configured domain binding resolver with an implementation linked to a SObjectType
		//   and the implementation is mocked
		fflib_ClassicDomainBindingResolver bindingResolver = generateConfiguredBindingResolver();
		bindingResolver.setMock(new AccountsMock(generateAccounts()));

		// WHEN a domain is requested
		fflib_IDomain result = bindingResolver.newInstance(generateAccounts());

		// THEN the mocked instance should be returned
		System.assert(result instanceof AccountsMock, 'Expected mock instance');
	}


	private static fflib_ClassicDomainBindingResolver generateConfiguredBindingResolver()
	{
		fflib_ClassicSelectorBindingResolver selectorBindingResolver =
				fflib_ClassicSelectorBindingResolverTest.generateConfiguredSelectorBindingResolver();
		fflib_ClassicSelectorBindingResolverTest.AccountsSelectorMock selectorMock = new fflib_ClassicSelectorBindingResolverTest.AccountsSelectorMock();
		selectorBindingResolver.setMock(selectorMock);
		selectorMock.records = generateAccounts();
		return generateConfiguredBindingResolver(selectorBindingResolver);
	}

	private static fflib_ClassicDomainBindingResolver generateConfiguredBindingResolver(
			fflib_ClassicSelectorBindingResolver selectorBindingResolver
	)
	{
		return new fflib_ClassicDomainBindingResolver(
				selectorBindingResolver,
				new Map<SObjectType, Type>
				{
						Schema.Account.SObjectType => AccountsConstructor.class
				}
		);
	}

	private static List<Account> generateAccounts()
	{
		return new List<Account>
		{
				new Account(Id = fflib_IDGenerator.generate(Schema.Account.SObjectType), Name = 'Test A'),
				new Account(Id = fflib_IDGenerator.generate(Schema.Account.SObjectType), Name = 'Test B'),
				new Account(Id = fflib_IDGenerator.generate(Schema.Account.SObjectType), Name = 'Test C')
		};
	}

	private with sharing class Accounts extends fflib_SObjectDomain
	{
		public Accounts(List<SObject> records)
		{
			super(records, Schema.Account.SObjectType);
		}
	}

	private with sharing class AccountsMock extends SObjects
	{
		public AccountsMock(List<SObject> records)
		{
			super(records, Schema.Account.SObjectType);
		}
	}

	private class AccountsConstructor implements fflib_SObjectDomain.IConstructable2
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sObjectType)
		{
			return new Accounts(sObjectList);
		}

		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new Accounts(sObjectList);
		}
	}
}