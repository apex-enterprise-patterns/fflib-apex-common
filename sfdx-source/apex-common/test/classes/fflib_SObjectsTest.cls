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
public with sharing class fflib_SObjectsTest{
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
	private static Id generateTestRecordId(Schema.SObjectType sObjectType){
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
	private static void itShouldConstructWithoutSObjectType(){
		Account record = new Account(Name = 'A');
		fflib_SObjects domain = new fflib_SObjects(new List<SObject>{ record });

		System.Assert.areEqual(1, domain.getRecords().size(), 'The single-arg constructor should still expose the provided records');
	}

	@IsTest
	private static void itShouldClearTheField(){
		Account record = new Account(ShippingCountry = 'Holland');
		DomainAccounts domain = new DomainAccounts(new List<Account>{ record });
		System.Assert.isTrue(!domain.selectByShippingCountry('Holland').isEmpty(), 'Incorrect test data');

		domain.clearField(Schema.Account.ShippingCountry);

		System.Assert.isTrue(domain.selectByShippingCountry('Holland').isEmpty(), 'Field should have been nullified');
	}

	@IsTest
	private static void itShouldReturnTheDomainsType(){
		System.Assert.areEqual(
				(Object) Schema.Account.SObjectType,
				new DomainAccounts(new List<Account>())
						.getType(),
				'Unexpected Domain Type'
		);
		System.Assert.areEqual(
				Schema.Account.SObjectType,
				new DomainAccounts(new List<Account>())
						.getSObjectType(),
				'Unexpected Domain SObjectType'
		);
	}


	@IsTest
	private static void itShouldReturnRecordsIds(){
		SObjectType accountSObjectType = Schema.Account.SObjectType;
		Id idA = generateTestRecordId(accountSObjectType);
		Id idB = generateTestRecordId(accountSObjectType);
		Id idC = generateTestRecordId(accountSObjectType);

		DomainAccounts domain = new DomainAccounts(
				new List<SObject>{
						new Account(Id = idA),
						new Account(Id = idB),
						new Account(Id = idC)
				}
		);

		Set<Id> recordIds = new Set<Id>{idA, idB, idC};
		System.Assert.isTrue(
				domain.getRecordIds().equals(recordIds),
				'The domain should return all the record Ids'
		);

		System.Assert.isTrue(
				domain.getIdFieldValues(Schema.Account.Id).equals(recordIds),
				'The domain should return all the record Ids'
		);
	}

	@IsTest
	private static void itShouldReturnRecordIdsFromField(){
		Id idA = generateTestRecordId(Schema.Account.SObjectType);
		Id idB = generateTestRecordId(Schema.Account.SObjectType);
		List<Account> accounts = new List<Account>{
				new Account(Name = 'A', ParentId = idA),
				new Account(Name = 'B', ParentId = idB),
				new Account(Name = 'C', ParentId = null)
		};
		DomainAccounts domain = new DomainAccounts(accounts);

		Set<Id> idsExcludingNulls = domain.getRecordIds(Schema.Account.ParentId);
		System.Assert.areEqual(2, idsExcludingNulls.size(), 'Should exclude null ParentId values by default');
		System.Assert.isTrue(idsExcludingNulls.contains(idA), 'Expected idsExcludingNulls to contain idA');
		System.Assert.isTrue(idsExcludingNulls.contains(idB), 'Expected idsExcludingNulls to contain idB');

		Set<Id> idsIncludingNulls = domain.getRecordIds(Schema.Account.ParentId, true);
		System.Assert.areEqual(3, idsIncludingNulls.size(), 'Should include the null ParentId value when requested');
		System.Assert.isTrue(idsIncludingNulls.contains(null), 'Expected idsIncludingNulls to contain null');
	}

	@IsTest
	private static void itShouldReturnRecordIdsFromRelationship(){
		Id ownerIdA = generateTestRecordId(Schema.User.SObjectType);
		Id ownerIdB = generateTestRecordId(Schema.User.SObjectType);
		List<Account> accounts = new List<Account>{
				new Account(Name = 'A', Parent = new Account(OwnerId = ownerIdA)),
				new Account(Name = 'B', Parent = new Account(OwnerId = ownerIdB)),
				new Account(Name = 'C')
		};
		DomainAccounts domain = new DomainAccounts(accounts);

		Set<Id> relationshipIds = domain.getRecordIdsFromRelationship('Parent.OwnerId');
		System.Assert.areEqual(2, relationshipIds.size(), 'Should only include Ids resolvable via the relationship path');
		System.Assert.isTrue(relationshipIds.contains(ownerIdA), 'Expected relationshipIds to contain ownerIdA');
		System.Assert.isTrue(relationshipIds.contains(ownerIdB), 'Expected relationshipIds to contain ownerIdB');
	}

	@IsTest
	private static void itShouldReturnRecordIdsFromDeepRelationship(){
		Id ownerIdA = generateTestRecordId(Schema.User.SObjectType);
		List<Account> accounts = new List<Account>{
				new Account(Name = 'A', Parent = new Account(Parent = new Account(OwnerId = ownerIdA))),
				new Account(Name = 'B', Parent = new Account())
		};
		DomainAccounts domain = new DomainAccounts(accounts);

		Set<Id> relationshipIds = domain.getRecordIdsFromRelationship('Parent.Parent.OwnerId');
		System.Assert.areEqual(1, relationshipIds.size(), 'Should resolve arbitrary-depth relationship paths');
		System.Assert.isTrue(relationshipIds.contains(ownerIdA), 'Expected relationshipIds to contain ownerIdA');
	}

	@IsTest
	private static void itShouldReturnRecordsWithFieldValues(){
		DomainAccounts domain = generateDomain();
		System.Assert.areEqual(1, domain.selectByShippingCountry('USA').size(), 'Expected exactly one Account with ShippingCountry USA');
	}

	@IsTest
	private static void itShouldReturnRecordsWithoutFieldValues(){
		DomainAccounts domain = generateDomain();

		System.Assert.areEqual(3, domain.selectWithoutShippingCountry().size(), 'Expected 3 Accounts without ShippingCountry');
	}
	@IsTest
	private static void itShouldReturnRecordsWithoutFieldValuesForNonStringFields(){
		DomainAccounts domain = generateDomain();

		System.Assert.areEqual(4, domain.selectWithoutNumberOfEmployees().size(), 'Expected 4 Accounts without NumberOfEmployees');
	}

	@IsTest
	private static void itShouldReturnRecordsWithoutAllFieldValues(){
		DomainAccounts domain = generateDomain();

		System.Assert.areEqual(1, domain.selectWithEmptyRecord().size(), 'Expected exactly one fully empty Account record');
	}

	@IsTest
	private static void itShouldReturnRecordsWithShippingCountry(){
		DomainAccounts domain = generateDomain();

		System.Assert.areEqual(4, domain.selectWithShippingCountry().size(), 'Expected 4 Accounts with ShippingCountry populated');
	}
	@IsTest
	private static void itShouldReturnRecordsWithNumberOfEmployees(){
		DomainAccounts domain = generateDomain();

		System.Assert.areEqual(3, domain.selectWithNumberOfEmployees().size(), 'Expected 3 Accounts with NumberOfEmployees populated');
	}

	@IsTest
	private static void itShouldReturnRecordsWithAllFieldValues(){
		DomainAccounts domain = generateDomain();

		System.Assert.areEqual(2, domain.selectPopulatedRecords().size(), 'Expected 2 Accounts with Name, ShippingCountry and NumberOfEmployees all populated');
	}

	@IsTest
	private static void itShouldReturnFieldValues(){
		DomainAccounts domain = generateDomain();

		final Set<String> expected = new Set<String>{
				null,
				'',
				'Canada',
				'Ireland',
				'UK',
				'USA'
		};
		System.Assert.isTrue(
				domain.getStringFieldValues(Schema.Account.ShippingCountry).equals(expected),
				'Expected string field values for ShippingCountry to match'
		);

		System.Assert.isTrue(
				domain.getFieldValues(Schema.Account.ShippingCountry)
						.equals(expected),
				'Expected generic field values for ShippingCountry to match'
		);
	}

	@IsTest
	private static void itShouldReturnStringFieldValuesExcludingBlanks(){
		DomainAccounts domain = generateDomain();

		final Set<String> expectedExcludingBlanks = new Set<String>{
				'Canada',
				'Ireland',
				'UK',
				'USA'
		};

		System.Assert.isTrue(
				domain.getStringFieldValues(Schema.Account.ShippingCountry, false).equals(expectedExcludingBlanks),
				'Expected string field values excluding blanks to match'
		);
	}

	@IsTest
	private static void itShouldReturnFieldValuesForNonStringFields(){
		DomainAccounts domain = generateDomain();

		final Set<Integer> expectedOriginalType = new Set<Integer>{
				null,
				10,
				20,
				30
		};

		System.Assert.isTrue(
				domain.getFieldValues(Schema.Account.NumberOfEmployees)
						.equals(expectedOriginalType),
				'Expected field values for NumberOfEmployees to retain their original Integer type'
		);
	}

	@IsTest
	private static void getStringFieldValuesShouldThrowClassCastExceptionForNonStringFields(){
		DomainAccounts domain = generateDomain();

		try {
			domain.getStringFieldValues(Schema.Account.NumberOfEmployees);
			System.Assert.fail('Expected a System.TypeException because NumberOfEmployees is an Integer field and cannot be cast to String');
		} catch (Exception ex){
			System.Assert.isInstanceOfType(ex, System.TypeException.class, 'Expected System.TypeException but got ' + ex);
			System.Assert.isTrue(
				ex.getMessage().contains('Invalid conversion from runtime type'),
				'Unexpected exception message: ' + ex.getMessage()
			);
		}
	}

	@IsTest
	private static void itShouldSetFieldValue(){
		DomainAccounts domain = generateDomain();
		String country = 'Holland';
		domain.setShippingCountry(country);

		System.Assert.areEqual(7, domain.selectByShippingCountry(country).size(), 'Expected all 7 Accounts to have ShippingCountry set to Holland');
	}


	@IsTest
	private static void itShouldSetFieldValueByCondition(){
		DomainAccounts domain = generateDomain();
		domain.setRatingByShippingCountry(
				new Map<Object,Object>{
						'USA' => 'Hot'
				}
		);

		System.Assert.areEqual(1, domain.selectByRating('Hot').size(), 'Expected exactly one Account with Rating Hot');
	}

	@IsTest
	private static void itShouldAllowBulkMutatorsFromOutsideDomainHierarchy(){
		Account recordA = new Account(Name = 'A', ShippingCountry = 'USA');
		Account recordB = new Account(Name = 'B', ShippingCountry = 'Canada');
		DomainAccounts domain = new DomainAccounts(new List<Account>{ recordA, recordB });

		domain.addError('Bulk record error');
		domain.addError(Schema.Account.Name, 'Bulk field error');
		domain.clearFields(new Set<Schema.SObjectField>{ Schema.Account.ShippingCountry });

		System.Assert.areEqual(2, domain.getRecords().size(), 'Expected domain to still contain 2 records');
		System.Assert.areEqual(null, recordA.ShippingCountry, 'Expected ShippingCountry to be cleared on recordA');
		System.Assert.areEqual(null, recordB.ShippingCountry, 'Expected ShippingCountry to be cleared on recordB');
	}

	@IsTest
	private static void testDomainErrorLogging(){
		// Test static helpers for raise none domain object instance errors
		final String errorMessage = 'Test Error';
		Account record = new Account();
		DomainAccounts domain = new DomainAccounts(new List<Account>{ record });
		domain.addNameError(errorMessage);

		System.Assert.areEqual(1, fflib_SObjects.Errors.getAll().size(), 'Expected one error to be logged');
		System.Assert.areEqual(errorMessage, fflib_SObjects.Errors.getAll()[0].message, 'Expected logged error message to match');
		System.Assert.areEqual(Account.Name, ((fflib_SObjects.FieldError) fflib_SObjects.Errors.getAll()[0]).field, 'Expected logged error field to be Account.Name');
	}

	@IsTest
	private static void testErrorLogging(){
		// Test static helpers for raise none domain object instance errors
		Opportunity opp = new Opportunity ( Name = 'Test', Type = 'Existing Account' );
		fflib_SObjects.Errors.error('Error', opp);
		fflib_SObjects.Errors.error('Error', opp, Opportunity.Type);
		System.Assert.areEqual(2, fflib_SObjects.Errors.getAll().size(), 'Expected two errors to be logged');
		System.Assert.areEqual('Error', fflib_SObjects.Errors.getAll()[0].message, 'Expected first logged error message to match');
		System.Assert.areEqual('Error', fflib_SObjects.Errors.getAll()[1].message, 'Expected second logged error message to match');
		System.Assert.areEqual(Opportunity.Type, ((fflib_SObjects.FieldError) fflib_SObjects.Errors.getAll()[1]).field, 'Expected second logged error field to be Opportunity.Type');
		fflib_SObjects.Errors.clearAll();
		System.Assert.areEqual(0, fflib_SObjects.Errors.getAll().size(), 'Expected errors to be cleared');
	}

	@IsTest
	private static void groupRecordsByFieldValue_success(){
		DomainAccounts domain = new DomainAccounts(
				new List<Account>{
						new Account(Name = 'Acme Inc'),
						new Account(Name = 'ACME INC'),
						new Account(Name = 'Globex')
				}
		);

		Map<Object, List<SObject>> grouped = domain.groupRecordsByFieldValue(Schema.Account.Name);

		System.Assert.areEqual(3, grouped.keySet().size(), 'Case-sensitive grouping should keep differently-cased names apart');
		System.Assert.areEqual(1, grouped.get('Globex').size(), 'Expected exactly one Globex record');
	}

	@IsTest
	private static void groupRecordsByFieldValue_blankValue(){
		DomainAccounts domain = new DomainAccounts(new List<Account>{ new Account() });

		try {
			domain.groupRecordsByFieldValue(Schema.Account.ShippingCountry);
			System.Assert.fail('Expected a fflib_Objects.InvalidValueException because the Account record has a null ShippingCountry and groupRecordsByFieldValue requires a non-null identifier value');
		} catch (Exception ex){
			System.Assert.isInstanceOfType(ex, fflib_Objects.InvalidValueException.class, 'Expected fflib_Objects.InvalidValueException but got ' + ex);
			System.Assert.isTrue(
				ex.getMessage().contains('ShippingCountry'),
				'Expected the field name to be present in the exception message: ' + ex.getMessage()
			);
		}
	}

	@IsTest
	private static void groupRecordsByFieldValue_wrongSObject(){
		DomainAccounts domain = new DomainAccounts(new List<Account>{ new Account() });

		try {
			domain.groupRecordsByFieldValue(Contact.LastName);
			System.Assert.fail('Expected a System.SObjectException because Contact.LastName does not exist on the Account records held by this domain');
		} catch (Exception ex){
			System.Assert.isInstanceOfType(ex, System.SObjectException.class, 'Expected System.SObjectException but got ' + ex);
		}
	}

	private static DomainAccounts generateDomain(){
		DomainAccounts domain = new DomainAccounts(
				new List<Account>{
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


	private class DomainAccounts extends fflib_SObjects {
		public DomainAccounts(List<SObject> records){
			super(records, Schema.Account.SObjectType);
		}

		public List<Account> selectByShippingCountry(String country){
			return (List<Account>) getRecordsByFieldValues(
				Schema.Account.ShippingCountry,
				new Set<Object>{ country }
			);
		}

		public List<Account> selectByRating(String rating){
			return (List<Account>) getRecordsByFieldValue(
				Schema.Account.Rating,
					rating
			);
		}

		public List<Account> selectWithoutShippingCountry(){
			return (List<Account>) getRecordsWithBlankFieldValues(
							Schema.Account.ShippingCountry
			);
		}

		public List<Account> selectWithShippingCountry(){
			return (List<Account>) getRecordsWithNotBlankFieldValues(
							Schema.Account.ShippingCountry
			);
		}

		public List<Account> selectWithoutNumberOfEmployees(){
			return (List<Account>) getRecordsWithBlankFieldValues(
							Schema.Account.NumberOfEmployees
			);
		}

		public List<Account> selectWithNumberOfEmployees(){
			return (List<Account>) getRecordsWithNotBlankFieldValues(
							Schema.Account.NumberOfEmployees
			);
		}

		public List<Account> selectWithEmptyRecord(){
			return (List<Account>) getRecordsWithAllBlankFieldValues(
					new Set<Schema.SObjectField>{
							Schema.Account.Name,
							Schema.Account.ShippingCountry,
							Schema.Account.NumberOfEmployees
					}
			);
		}

		public List<Account> selectPopulatedRecords(){
			return (List<Account>) getRecordsWithAllNotBlankFieldValues(
					new Set<Schema.SObjectField>{
							Schema.Account.Name,
							Schema.Account.ShippingCountry,
							Schema.Account.NumberOfEmployees
					}
			);
		}

		public void setShippingCountry(String country){
			setFieldValue(Schema.Account.ShippingCountry, country);
		}

		public void setRatingByShippingCountry(Map<Object, Object> ratingByCountry){
			setFieldValueByMap(
					Schema.Account.ShippingCountry,
					Schema.Account.Rating,
					ratingByCountry);
		}

		public void addNameError(String message){
			addError(Schema.Account.Name, message);
		}

		public void clearShippingCountry(){
			clearField(Schema.Account.ShippingCountry);
		}
	}
}