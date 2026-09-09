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
@IsTest(isParallel=true)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs, PMD.ApexDoc, PMD.ClassNamingConventions')
public with sharing class fflib_SObjectsTest
{
	private static Integer testFakeIdSequence = 0;
	private static final String TEST_FAKE_ID_PADDING = '000000000000';
    private static Map<SObjectType, String> prefixCacheMap = new Map<SObjectType, String>();

	/**
	 * Returns a syntactically valid fake Id for the given SObject type. For unit tests only
	 * (same scheme historically provided by fflib_IDGenerator in ApexMocks).
	 *
	 * @param sObjectType The type whose key prefix the fake Id should use
	 */
	@TestVisible
	private static Id generateTestRecordId(Schema.SObjectType sObjectType) {
        // Avoid describing sObject multiple times
        String keyPrefix = prefixCacheMap.get(sObjectType);
        if(keyPrefix == null){
            keyPrefix = sObjectType.getDescribe().getKeyPrefix();
            prefixCacheMap.put(sObjectType, keyPrefix);
        }

        testFakeIdSequence++;
        String fakeIdPrefix = TEST_FAKE_ID_PADDING.substring(
			0,
			TEST_FAKE_ID_PADDING.length() - String.valueOf(testFakeIdSequence).length()
		);
        return Id.valueOf(keyPrefix + fakeIdPrefix + testFakeIdSequence);
	}

	@IsTest
	private static void itShouldClearTheField()
	{
		Account record = new Account(ShippingCountry = 'Holland');
		DomainAccounts domain = new DomainAccounts(new List<Account>{ record });
		System.assert(!domain.selectByShippingCountry('Holland').isEmpty(), 'Incorrect test data');

		domain.clearField(Schema.Account.ShippingCountry);

		System.assert(domain.selectByShippingCountry('Holland').isEmpty(), 'Field should have been nullified');
	}

	@IsTest
	private static void itShouldReturnTheDomainsType()
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
	private static void itShouldReturnRecordsIds()
	{
		SObjectType accountSObjectType = Schema.Account.SObjectType;
		Id idA = generateTestRecordId(accountSObjectType);
		Id idB = generateTestRecordId(accountSObjectType);
		Id idC = generateTestRecordId(accountSObjectType);

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
	private static void itShouldReturnRecordIdsFromField()
	{
		Id idA = generateTestRecordId(Schema.Account.SObjectType);
		Id idB = generateTestRecordId(Schema.Account.SObjectType);
		List<Account> accounts = new List<Account>
		{
				new Account(Name = 'A', ParentId = idA),
				new Account(Name = 'B', ParentId = idB),
				new Account(Name = 'C', ParentId = null)
		};
		DomainAccounts domain = new DomainAccounts(accounts);

		Set<Id> idsExcludingNulls = domain.getRecordIds(Schema.Account.ParentId);
		System.assertEquals(2, idsExcludingNulls.size(), 'Should exclude null ParentId values by default');
		System.assert(idsExcludingNulls.contains(idA));
		System.assert(idsExcludingNulls.contains(idB));

		Set<Id> idsIncludingNulls = domain.getRecordIds(Schema.Account.ParentId, true);
		System.assertEquals(3, idsIncludingNulls.size(), 'Should include the null ParentId value when requested');
		System.assert(idsIncludingNulls.contains(null));
	}

	@IsTest
	private static void itShouldReturnRecordIdsFromRelationship()
	{
		Id ownerIdA = generateTestRecordId(Schema.User.SObjectType);
		Id ownerIdB = generateTestRecordId(Schema.User.SObjectType);
		List<Account> accounts = new List<Account>
		{
				new Account(Name = 'A', Parent = new Account(OwnerId = ownerIdA)),
				new Account(Name = 'B', Parent = new Account(OwnerId = ownerIdB)),
				new Account(Name = 'C')
		};
		DomainAccounts domain = new DomainAccounts(accounts);

		Set<Id> relationshipIds = domain.getRecordIdsFromRelationship('Parent.OwnerId');
		System.assertEquals(2, relationshipIds.size(), 'Should only include Ids resolvable via the relationship path');
		System.assert(relationshipIds.contains(ownerIdA));
		System.assert(relationshipIds.contains(ownerIdB));
	}

	@IsTest
	private static void itShouldReturnRecordsWithFieldValues()
	{
		DomainAccounts domain = generateDomain();

		System.assert(domain.selectByShippingCountry('USA').size() == 1);
	}

	@IsTest
	private static void itShouldReturnRecordsWithoutFieldValues()
	{
		DomainAccounts domain = generateDomain();

		System.assertEquals(3, domain.selectWithoutShippingCountry().size());
	}
	@IsTest
	private static void itShouldReturnRecordsWithoutFieldValuesForNonStringFields()
	{
		DomainAccounts domain = generateDomain();

		System.assertEquals(4, domain.selectWithoutNumberOfEmployees().size());
	}

	@IsTest
	private static void itShouldReturnRecordsWithoutAllFieldValues()
	{
		DomainAccounts domain = generateDomain();

		System.assert(domain.selectWithEmptyRecord().size() == 1);
	}

	@IsTest
	private static void itShouldReturnRecordsWithShippingCountry()
	{
		DomainAccounts domain = generateDomain();

		System.assert(domain.selectWithShippingCountry().size() == 4);
	}
	@IsTest
	private static void itShouldReturnRecordsWithNumberOfEmployees()
	{
		DomainAccounts domain = generateDomain();

		System.assert(domain.selectWithNumberOfEmployees().size() == 3);
	}

	@IsTest
	private static void itShouldReturnRecordsWithAllFieldValues()
	{
		DomainAccounts domain = generateDomain();

		System.assert(domain.selectPopulatedRecords().size() == 2);
	}

	@IsTest
	private static void itShouldReturnFieldValues()
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
	private static void itShouldReturnStringFieldValuesExcludingBlanks()
	{
		DomainAccounts domain = generateDomain();

		final Set<String> expectedExcludingBlanks = new Set<String>
		{
				'Canada',
				'Ireland',
				'UK',
				'USA'
		};

		System.assert(
				domain.getStringFieldValues(Schema.Account.ShippingCountry, false).equals(expectedExcludingBlanks)
		);
	}

	@IsTest
	private static void itShouldReturnFieldValuesForNonStringFields()
	{
		DomainAccounts domain = generateDomain();

		final Set<Integer> expectedOriginalType = new Set<Integer>
		{
				null,
				10,
				20,
				30
		};

		System.assert(
				domain.getFieldValues(Schema.Account.NumberOfEmployees)
						.equals(expectedOriginalType)
		);
	}

	@IsTest
	private static void getStringFieldValuesShouldThrowClassCastExceptionForNonStringFields()
	{
		DomainAccounts domain = generateDomain();

		try
		{
			domain.getStringFieldValues(Schema.Account.NumberOfEmployees);
			Assert.fail('Expected ClassCastException because NumberOfEmployees is not a Text field');
		}
		catch (System.TypeException expected)
		{
			System.assert(expected.getMessage().contains('Invalid conversion from runtime type'),
					'Unexpected exception message: ' + expected.getMessage());
		}
	}

	@IsTest
	private static void itShouldSetFieldValue()
	{
		DomainAccounts domain = generateDomain();
		String country = 'Holland';
		domain.setShippingCountry(country);

		System.assert(domain.selectByShippingCountry(country).size() == 7);
	}


	@IsTest
	private static void itShouldSetFieldValueByCondition()
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
	private static void itShouldAllowBulkMutatorsFromOutsideDomainHierarchy()
	{
		Account recordA = new Account(Name = 'A', ShippingCountry = 'USA');
		Account recordB = new Account(Name = 'B', ShippingCountry = 'Canada');
		DomainAccounts domain = new DomainAccounts(new List<Account>{ recordA, recordB });

		domain.addError('Bulk record error');
		domain.addError(Schema.Account.Name, 'Bulk field error');
		domain.clearFields(new Set<Schema.SObjectField>{ Schema.Account.ShippingCountry });

		System.assertEquals(2, domain.getRecords().size());
		System.assertEquals(null, recordA.ShippingCountry);
		System.assertEquals(null, recordB.ShippingCountry);
	}

	@IsTest
	private static void testDomainErrorLogging()
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
	private static void testErrorLogging()
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

	@IsTest
	private static void groupRecordsByFieldValue_success()
	{
		DomainAccounts domain = new DomainAccounts(
				new List<Account>
				{
						new Account(Name = 'Acme Inc'),
						new Account(Name = 'ACME INC'),
						new Account(Name = 'Globex')
				}
		);

		Map<String, List<SObject>> grouped = domain.groupRecordsByFieldValue(Schema.Account.Name);

		System.assertEquals(3, grouped.keySet().size(), 'Case-sensitive grouping should keep differently-cased names apart');
		System.assertEquals(1, grouped.get('Globex').size());
	}

	@IsTest
	private static void groupRecordsByFieldValue_lowerCase()
	{
		DomainAccounts domain = new DomainAccounts(
				new List<Account>
				{
						new Account(Name = 'Acme Inc'),
						new Account(Name = 'ACME INC'),
						new Account(Name = 'Globex')
				}
		);

		Map<String, List<SObject>> grouped = domain.groupRecordsByFieldValue(Schema.Account.Name, true);

		System.assertEquals(2, grouped.keySet().size(), 'Lower-cased grouping should merge differently-cased duplicates');
		System.assertEquals(2, grouped.get('acme inc').size());
	}

	@IsTest
	private static void groupRecordsByFieldValue_blankValue()
	{
		DomainAccounts domain = new DomainAccounts(new List<Account>{ new Account() });

		try
		{
			domain.groupRecordsByFieldValue(Schema.Account.ShippingCountry);
			System.assert(false, 'Expected an InvalidValueException to be thrown for a blank identifier value');
		}
		catch (fflib_Objects.InvalidValueException expected)
		{
			System.assert(expected.getMessage().contains('ShippingCountry'),
					'Expected the field name to be present in the exception message: ' + expected.getMessage());
		}
	}

	@IsTest
	private static void groupRecordsByFieldValue_wrongSObject()
	{
		DomainAccounts domain = new DomainAccounts(new List<Account>{ new Account() });

		try
		{
			domain.groupRecordsByFieldValue(Contact.LastName);
			System.assert(false, 'Expected a System.SObjectException for a field belonging to another SObjectType');
		}
		catch (System.SObjectException expected)
		{
			System.assert(true);
		}
	}

	@IsTest
	private static void getPicklistValues_validReturn()
	{
		List<Schema.PicklistEntry> expected = Schema.Account.Rating.getDescribe().getPicklistValues();

		DomainAccounts domain = generateDomain();
		List<Schema.PicklistEntry> actual = domain.getPicklistValues('Account', 'Rating');

		System.assertEquals(expected.size(), actual.size());
	}

	@IsTest
	private static void getPicklistValues_invalidField()
	{
		DomainAccounts domain = generateDomain();

		try
		{
			domain.getPicklistValues('Account', 'NonExistingField123');
			System.assert(false, 'Expected an InvalidValueException for an unknown field');
		}
		catch (fflib_Objects.InvalidValueException expected)
		{
			System.assert(expected.getMessage().contains('NonExistingField123'));
		}
	}

	@IsTest
	private static void getPicklistValues_invalidObject()
	{
		DomainAccounts domain = generateDomain();

		try
		{
			domain.getPicklistValues('NonExistingObject123', 'Rating');
			System.assert(false, 'Expected an InvalidValueException for an unknown SObjectType');
		}
		catch (fflib_Objects.InvalidValueException expected)
		{
			System.assert(expected.getMessage().contains('NonExistingObject123'));
		}
	}

	@IsTest
	private static void getPicklistValuesToStrings_returnsUpperCasedLabels()
	{
		DomainAccounts domain = generateDomain();
		List<String> values = domain.getPicklistValuesToStrings('Account', 'Rating');

		System.assert(values.contains('HOT'), 'Expected the Hot picklist label, upper-cased, to be present');
	}

	@IsTest
	private static void isValidPicklistValue_success()
	{
		DomainAccounts domain = generateDomain();

		System.assert(domain.isValidPicklistValue(Schema.Account.Rating, Schema.Account.SObjectType, 'Hot'));
	}

	@IsTest
	private static void isValidPicklistValue_blankValue()
	{
		DomainAccounts domain = generateDomain();

		System.assertEquals(false, domain.isValidPicklistValue(Schema.Account.Rating, Schema.Account.SObjectType, null));
	}

	@IsTest
	private static void isValidPicklistValue_invalidValue()
	{
		DomainAccounts domain = generateDomain();

		System.assertEquals(false, domain.isValidPicklistValue(Schema.Account.Rating, Schema.Account.SObjectType, 'NotARealValue'));
	}

	@IsTest
	private static void isValidPicklistValue_wrongSObjectType()
	{
		DomainAccounts domain = generateDomain();

		try
		{
			domain.isValidPicklistValue(Schema.Account.Rating, Schema.Contact.SObjectType, 'Hot');
			System.assert(false, 'Expected an InvalidValueException since Rating does not exist on Contact');
		}
		catch (fflib_Objects.InvalidValueException expected)
		{
			System.assert(expected.getMessage().contains('Rating'));
		}
	}

	private static DomainAccounts generateDomain()
	{
		DomainAccounts domain = new DomainAccounts(
				new List<Account>
				{
						new Account(Name = 'A', ShippingCountry = 'USA'),
						new Account(Name = 'B', ShippingCountry = 'Ireland'),
						new Account(Name = 'C', ShippingCountry = 'UK', NumberOfEmployees = 10),
						new Account(Name = 'D', ShippingCountry = ''),
						new Account(Name = 'E', NumberOfEmployees = 20),
						new Account(),
						new Account(Name = 'G', ShippingCountry = 'Canada', NumberOfEmployees = 30)
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

		public List<Account> selectWithoutNumberOfEmployees()
		{
			return (List<Account>) getRecordsWithBlankFieldValues(
							Schema.Account.NumberOfEmployees
			);
		}

		public List<Account> selectWithNumberOfEmployees()
		{
			return (List<Account>) getRecordsWithNotBlankFieldValues(
							Schema.Account.NumberOfEmployees
			);
		}

		public List<Account> selectWithEmptyRecord()
		{
			return (List<Account>) getRecordsWithAllBlankFieldValues(
					new Set<Schema.SObjectField>
					{
							Schema.Account.Name,
							Schema.Account.ShippingCountry,
							Schema.Account.NumberOfEmployees
					}
			);
		}

		public List<Account> selectPopulatedRecords()
		{
			return (List<Account>) getRecordsWithAllNotBlankFieldValues(
					new Set<Schema.SObjectField>
					{
							Schema.Account.Name,
							Schema.Account.ShippingCountry,
							Schema.Account.NumberOfEmployees
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