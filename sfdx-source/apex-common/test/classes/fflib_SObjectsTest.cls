/**
 * Copyright (c), FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors
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
**/

@IsTest
private class fflib_SObjectsTest
{

	@IsTest
	static void itShouldClearTheField()
	{
		Account record = new Account(ShippingCountry = 'Holland');
		DomainAccounts domain = new DomainAccounts(new List<Account>{ record });
		System.assert(!domain.selectByShippingCountry('Holland').isEmpty(), 'Incorrect test data');

		domain.clearShippingCountry();

		System.assert(domain.selectByShippingCountry('Holland').isEmpty(), 'Field should have been nullified');
	}

	@IsTest
	static void itShouldReturnTheDomainsType()
	{
		System.assertEquals(
				(Object) Schema.Account.SObjectType,
				new DomainAccounts(new List<Account>())
						.getType(),
				'Unexpected Domain Type'
		);
		System.assertEquals(
				Schema.Account.SObjectType,
				new DomainAccounts(new List<Account>())
						.getSObjectType(),
				'Unexpected Domain SObjectType'
		);
	}


	@IsTest
	static void itShouldReturnRecordsIds()
	{
		SObjectType accountSObjectType = Schema.Account.SObjectType;
		Id idA = fflib_IDGenerator.generate(accountSObjectType);
		Id idB = fflib_IDGenerator.generate(accountSObjectType);
		Id idC = fflib_IDGenerator.generate(accountSObjectType);

		DomainAccounts domain = new DomainAccounts(
				new List<SObject>
				{
						new Account(Id = idA),
						new Account(Id = idB),
						new Account(Id = idC)
				}
		);

		Set<Id> recordIds = new Set<Id> {idA, idB, idC};
		System.assert(
				domain.getRecordIds().equals(recordIds),
				'The domain should return all the record Ids'
		);

		System.assert(
				domain.getIdFieldValues(Schema.Account.Id).equals(recordIds),
				'The domain should return all the record Ids'
		);
	}

	@IsTest
	static void itShouldReturnRecordsWithFieldValues()
	{
		DomainAccounts domain = generateDomain();

		System.assert(domain.selectByShippingCountry('USA').size() == 1);
	}

	@IsTest
	static void itShouldReturnRecordsWithoutFieldValues()
	{
		DomainAccounts domain = generateDomain();

		System.assertEquals(3, domain.selectWithoutShippingCountry().size());
	}

	@IsTest
	static void itShouldReturnRecordsWithoutAllFieldValues()
	{
		DomainAccounts domain = generateDomain();

		System.assert(domain.selectWithEmptyRecord().size() == 1);
	}

	@IsTest
	static void itShouldReturnRecordsWithShippingCountry()
	{
		DomainAccounts domain = generateDomain();

		System.assert(domain.selectWithShippingCountry().size() == 4);
	}

	@IsTest
	static void itShouldReturnRecordsWithAllFieldValues()
	{
		DomainAccounts domain = generateDomain();

		System.assert(domain.selectPopulatedRecords().size() == 4);
	}

	@IsTest
	static void itShouldReturnFieldValues()
	{
		DomainAccounts domain = generateDomain();

		final Set<String> expected = new Set<String>
		{
				null,
				'',
				'Canada',
				'Ireland',
				'UK',
				'USA'
		};
		System.assert(
				domain.getStringFieldValues(Schema.Account.ShippingCountry).equals(expected)
		);

		System.assert(
				domain.getFieldValues(Schema.Account.ShippingCountry)
						.equals(expected)
		);
	}

	@IsTest
	static void itShouldSetFieldValue()
	{
		DomainAccounts domain = generateDomain();
		String country = 'Holland';
		domain.setShippingCountry(country);

		System.assert(domain.selectByShippingCountry(country).size() == 7);
	}


	@IsTest
	static void itShouldSetFieldValueByCondition()
	{
		DomainAccounts domain = generateDomain();
		domain.setRatingByShippingCountry(
				new Map<Object,Object>
				{
						'USA' => 'Hot'
				}
		);

		System.assert(domain.selectByRating('Hot').size() == 1);
	}

	@IsTest
	static void testDomainErrorLogging()
	{
		// Test static helpers for raise none domain object instance errors
		final String errorMessage = 'Test Error';
		Account record = new Account();
		DomainAccounts domain = new DomainAccounts(new List<Account>{ record });
		domain.addNameError(errorMessage);

		System.assertEquals(1, fflib_SObjects.Errors.getAll().size());
		System.assertEquals(errorMessage, fflib_SObjects.Errors.getAll()[0].message);
		System.assertEquals(Account.Name, ((fflib_SObjects.FieldError) fflib_SObjects.Errors.getAll()[0]).field);
	}

	@IsTest
	static void testErrorLogging()
	{
		// Test static helpers for raise none domain object instance errors
		Opportunity opp = new Opportunity ( Name = 'Test', Type = 'Existing Account' );
		fflib_SObjects.Errors.error('Error', opp);
		fflib_SObjects.Errors.error('Error', opp, Opportunity.Type);
		System.assertEquals(2, fflib_SObjects.Errors.getAll().size());
		System.assertEquals('Error', fflib_SObjects.Errors.getAll()[0].message);
		System.assertEquals('Error', fflib_SObjects.Errors.getAll()[1].message);
		System.assertEquals(Opportunity.Type, ((fflib_SObjects.FieldError) fflib_SObjects.Errors.getAll()[1]).field);
		fflib_SObjects.Errors.clearAll();
		System.assertEquals(0, fflib_SObjects.Errors.getAll().size());
	}

	private static DomainAccounts generateDomain()
	{
		DomainAccounts domain = new DomainAccounts(
				new List<Account>
				{
						new Account(Name = 'A', ShippingCountry = 'USA'),
						new Account(Name = 'B', ShippingCountry = 'Ireland'),
						new Account(Name = 'C', ShippingCountry = 'UK'),
						new Account(Name = 'D', ShippingCountry = ''),
						new Account(Name = 'E'),
						new Account(),
						new Account(Name = 'G', ShippingCountry = 'Canada')
				}
		);
		return domain;
	}


	private class DomainAccounts extends fflib_SObjects
	{
		public DomainAccounts(List<SObject> records)
		{
			super(records, Schema.Account.SObjectType);
		}

		public List<Account> selectByShippingCountry(String country)
		{
			return (List<Account>) getRecordsByFieldValues(
				Schema.Account.ShippingCountry,
				new Set<Object>{ country }
			);
		}

		public List<Account> selectByRating(String rating)
		{
			return (List<Account>) getRecordsByFieldValue(
				Schema.Account.Rating,
					rating
			);
		}

		public List<Account> selectWithoutShippingCountry()
		{
			return (List<Account>) getRecordsWithBlankFieldValues(
							Schema.Account.ShippingCountry
			);
		}

		public List<Account> selectWithShippingCountry()
		{
			return (List<Account>) getRecordsWithNotBlankFieldValues(
							Schema.Account.ShippingCountry
			);
		}

		public List<Account> selectWithEmptyRecord()
		{
			return (List<Account>) getRecordsWithAllBlankFieldValues(
					new Set<Schema.SObjectField>
					{
							Schema.Account.Name,
							Schema.Account.ShippingCountry
					}
			);
		}

		public List<Account> selectPopulatedRecords()
		{
			return (List<Account>) getRecordsWithAllNotBlankFieldValues(
					new Set<Schema.SObjectField>
					{
							Schema.Account.Name,
							Schema.Account.ShippingCountry
					}
			);
		}

		public void setShippingCountry(String country)
		{
			setFieldValue(Schema.Account.ShippingCountry, country);
		}

		public void setRatingByShippingCountry(Map<Object, Object> ratingByCountry)
		{
			setFieldValueByMap(
					Schema.Account.ShippingCountry,
					Schema.Account.Rating,
					ratingByCountry);
		}

		public void addNameError(String message)
		{
			addError(Schema.Account.Name, message);
		}

		public void clearShippingCountry()
		{
			clearField(Schema.Account.ShippingCountry);
		}
	}
}