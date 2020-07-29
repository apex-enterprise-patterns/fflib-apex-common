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
private with sharing class fflib_SObjectDomainTest 
{
	private static final String COLD = 'Cold';
	private static final String HOLLAND = 'Holland';
	private static final String HOT = 'Hot';
	private static final String IRELAND = 'Ireland';
	private static final String ITALY = 'Italy';
	private static final String USA = 'United States of America';
	private static final String WARM = 'Warm';

	@IsTest
	private static void testValidationWithoutDML()
	{
		fflib_SObjectDomain.TestSObjectDomain opps = new fflib_SObjectDomain.TestSObjectDomain(new Opportunity[] { new Opportunity ( Name = 'Test', Type = 'Existing Account' ) } );
		opps.onValidate();
		System.assertEquals(1, fflib_SObjectDomain.Errors.getAll().size());		
		System.assertEquals('You must provide an Account for Opportunities for existing Customers.', fflib_SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(Opportunity.AccountId, ((fflib_SObjectDomain.FieldError)fflib_SObjectDomain.Errors.getAll()[0]).field); 		

		opps = new fflib_SObjectDomain.TestSObjectDomain(new SObject[] { new Opportunity ( Name = 'Test', Type = 'Existing Account' ) }, Opportunity.SObjectType );
		System.assertEquals(1, fflib_SObjectDomain.Errors.getAll().size());		
		System.assertEquals('You must provide an Account for Opportunities for existing Customers.', fflib_SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(Opportunity.AccountId, ((fflib_SObjectDomain.FieldError)fflib_SObjectDomain.Errors.getAll()[0]).field);		
	}
	
	@IsTest
	private static void testInsertValidationFailedWithoutDML()
	{
		Opportunity opp = new Opportunity ( Name = 'Test', Type = 'Existing Account' );
		System.assertEquals(false, fflib_SObjectDomain.Test.Database.hasRecords());
		fflib_SObjectDomain.Test.Database.onInsert(new Opportunity[] { opp } );		
		System.assertEquals(true, fflib_SObjectDomain.Test.Database.hasRecords());
		fflib_SObjectDomain.triggerHandler(fflib_SObjectDomain.TestSObjectDomainConstructor.class);		
		System.assertEquals(1, fflib_SObjectDomain.Errors.getAll().size());		
		System.assertEquals('You must provide an Account for Opportunities for existing Customers.', fflib_SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(Opportunity.AccountId, ((fflib_SObjectDomain.FieldError)fflib_SObjectDomain.Errors.getAll()[0]).field); 		
	}

	@IsTest
	private static void testUpdateValidationFailedWithoutDML()
	{
		Opportunity oldOpp = (Opportunity) Opportunity.sObjectType.newSObject('006E0000006mkRQ');
		oldOpp.Name = 'Test';
		oldOpp.Type = 'Existing Account'; 
		Opportunity newOpp = (Opportunity) Opportunity.sObjectType.newSObject('006E0000006mkRQ'); 
		newOpp.Name = 'Test';
		newOpp.Type = 'New Account'; 
		System.assertEquals(false, fflib_SObjectDomain.Test.Database.hasRecords());		
		fflib_SObjectDomain.Test.Database.onUpdate(new Opportunity[] { newOpp }, new Map<Id, SObject> { newOpp.Id => oldOpp } );
		System.assertEquals(true, fflib_SObjectDomain.Test.Database.hasRecords());				
		fflib_SObjectDomain.triggerHandler(fflib_SObjectDomain.TestSObjectDomainConstructor.class);		
		System.assertEquals(1, fflib_SObjectDomain.Errors.getAll().size());		
		System.assertEquals('You cannot change the Opportunity type once it has been created.', fflib_SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(Opportunity.Type, ((fflib_SObjectDomain.FieldError)fflib_SObjectDomain.Errors.getAll()[0]).field); 		
	}
	
	@IsTest
	private static void testOnBeforeDeleteWithoutDML()
	{
		Opportunity opp = (Opportunity) Opportunity.sObjectType.newSObject('006E0000006mkRQ'); 
		opp.Name = 'Test';
		opp.Type = 'Existing Account';
		System.assertEquals(false, fflib_SObjectDomain.Test.Database.hasRecords());		
		fflib_SObjectDomain.Test.Database.onDelete(new Map<ID, Opportunity> { opp.Id => opp } );		
		System.assertEquals(true, fflib_SObjectDomain.Test.Database.hasRecords());				
		fflib_SObjectDomain.triggerHandler(fflib_SObjectDomain.TestSObjectDomainConstructor.class);		
		System.assertEquals(1, fflib_SObjectDomain.Errors.getAll().size());		
		System.assertEquals('You cannot delete this Opportunity.', fflib_SObjectDomain.Errors.getAll()[0].message);
	}
	
	@IsTest
	private static void testOnAfterUndeleteWithoutDML()
	{
		Opportunity opp = (Opportunity) Opportunity.sObjectType.newSObject('006E0000006mkRQ'); 
		opp.Name = 'Test';
		opp.Type = 'Existing Account';
		System.assertEquals(false, fflib_SObjectDomain.Test.Database.hasRecords());		
		fflib_SObjectDomain.Test.Database.onUndelete(new list<Opportunity> { opp } );		
		System.assertEquals(true, fflib_SObjectDomain.Test.Database.hasRecords());				
		fflib_SObjectDomain.triggerHandler(fflib_SObjectDomain.TestSObjectDomainConstructor.class);		
	}
	
	@IsTest
	private static void testObjectSecurity()
	{
		// Create a user which will not have access to the test object type
		User testUser = createChatterExternalUser();
		if(testUser==null)
			return; // Abort the test if unable to create a user with low enough acess
		System.runAs(testUser)
		{					
			// Test Create object security
			Opportunity opp = new Opportunity ( Name = 'Test', Type = 'Existing Account' );
			fflib_SObjectDomain.Test.Database.onInsert(new Opportunity[] { opp } );
			try {
				fflib_SObjectDomain.triggerHandler(fflib_SObjectDomain.TestSObjectDomainConstructor.class);
				System.assert(false, 'Expected access denied exception');						
			} catch (Exception e) {
				System.assertEquals('Permission to create an Opportunity denied.', e.getMessage());
			}		
			
			// Test Update object security
			Opportunity existingOpp = (Opportunity) Opportunity.sObjectType.newSObject('006E0000006mkRQ');
			existingOpp.Name = 'Test';
			existingOpp.Type = 'Existing Account'; 			
			fflib_SObjectDomain.Test.Database.onUpdate(new List<Opportunity> { opp }, new Map<Id, Opportunity> { opp.Id => opp } );
			try {
				fflib_SObjectDomain.triggerHandler(fflib_SObjectDomain.TestSObjectDomainConstructor.class);
				System.assert(false, 'Expected access denied exception');						
			} catch (Exception e) {
				System.assertEquals('Permission to update an Opportunity denied.', e.getMessage());
			}		
			
			// Test Delete object security
			fflib_SObjectDomain.Test.Database.onDelete(new Map<Id, Opportunity> { opp.Id => opp });
			try {
				fflib_SObjectDomain.triggerHandler(fflib_SObjectDomain.TestSObjectDomainConstructor.class);
				System.assert(false, 'Expected access denied exception');						
			} catch (Exception e) {
				System.assertEquals('Permission to delete an Opportunity denied.', e.getMessage());
			}		
		}			
	}
	
	@IsTest
	private static void testErrorLogging()
	{	
		// Test static helpers for raise none domain object instance errors
		Opportunity opp = new Opportunity ( Name = 'Test', Type = 'Existing Account' );		
		fflib_SObjectDomain.Errors.error('Error', opp);
		fflib_SObjectDomain.Errors.error('Error', opp, Opportunity.Type);
		System.assertEquals(2, fflib_SObjectDomain.Errors.getAll().size());		
		System.assertEquals('Error', fflib_SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals('Error', fflib_SObjectDomain.Errors.getAll()[1].message);
		System.assertEquals(Opportunity.Type, ((fflib_SObjectDomain.FieldError)fflib_SObjectDomain.Errors.getAll()[1]).field);
		fflib_SObjectDomain.Errors.clearAll();		
		System.assertEquals(0, fflib_SObjectDomain.Errors.getAll().size());		
	}
	
	@IsTest
	private static void testTriggerState()
	{
		Opportunity opp = new Opportunity ( Name = 'Test', Type = 'Existing Account' );
		fflib_SObjectDomain.Test.Database.onInsert(new Opportunity[] { opp } );		
		fflib_SObjectDomain.triggerHandler(fflib_SObjectDomain.TestSObjectStatefulDomainConstructor.class);		
		System.assertEquals(1, fflib_SObjectDomain.Errors.getAll().size());		
		System.assertEquals('Error on Record Test', fflib_SObjectDomain.Errors.getAll()[0].message);
	}	

	@IsTest
	private static void testRecursiveTriggerState()
	{
		Opportunity opp = new Opportunity ( Name = 'Test Recursive 1', Type = 'Existing Account' );
		fflib_SObjectDomain.Test.Database.onInsert(new Opportunity[] { opp } );		
		fflib_SObjectDomain.triggerHandler(fflib_SObjectDomain.TestSObjectStatefulDomainConstructor.class);		
		System.assertEquals(2, fflib_SObjectDomain.Errors.getAll().size());		
		System.assertEquals('Error on Record Test Recursive 2', fflib_SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals('Error on Record Test Recursive 1', fflib_SObjectDomain.Errors.getAll()[1].message);
	}	

	@IsTest
	private static void testOnValidateBehaviorDefault()
	{
		Opportunity oldOpp = (Opportunity) Opportunity.sObjectType.newSObject('006E0000006mkRQ');
		oldOpp.Name = 'Test Default Behaviour';
		oldOpp.Type = 'Existing Account'; 
		Opportunity newOpp = (Opportunity) Opportunity.sObjectType.newSObject('006E0000006mkRQ'); 
		newOpp.Name = 'Test Default Behaviour';
		newOpp.Type = 'New Account'; 		
		fflib_SObjectDomain.Test.Database.onUpdate(new Opportunity[] { newOpp }, new Map<Id, SObject> { newOpp.Id => oldOpp } );		
		fflib_SObjectDomain.triggerHandler(fflib_SObjectDomain.TestSObjectOnValidateBehaviourConstructor.class);		
	}	

	@IsTest
	private static void testOnValidateBehaviorOld()
	{
		Opportunity oldOpp = (Opportunity) Opportunity.sObjectType.newSObject('006E0000006mkRQ');
		oldOpp.Name = 'Test Enable Old Behaviour';
		oldOpp.Type = 'Existing Account'; 
		Opportunity newOpp = (Opportunity) Opportunity.sObjectType.newSObject('006E0000006mkRQ'); 
		newOpp.Name = 'Test Enable Old Behaviour';
		newOpp.Type = 'New Account'; 		
		fflib_SObjectDomain.Test.Database.onUpdate(new Opportunity[] { newOpp }, new Map<Id, SObject> { newOpp.Id => oldOpp } );
		try {		
			fflib_SObjectDomain.triggerHandler(fflib_SObjectDomain.TestSObjectOnValidateBehaviourConstructor.class);
			System.assert(false, 'Expected exception');
		} catch (Exception e) {
			System.assertEquals('onValidate called', e.getMessage());
		}
	}

	@IsTest
	private static void testGetChangedFieldsAsStrings()
	{
		Account acct1 = new Account ( Id = '001E0000006mkRP', Name = 'Test1', AccountNumber = '12345', Site = 'Here'),
		        acct2 = new Account ( Id = '001E0000006mkRQ', Name = 'Test2', AccountNumber = '54321', Site = 'There');
		System.assertEquals(false, fflib_SObjectDomain.Test.Database.hasRecords());
		fflib_SObjectDomain.Test.Database.onInsert(new Account[] { acct1, acct2 } );
		System.assertEquals(true, fflib_SObjectDomain.Test.Database.hasRecords());
		fflib_SObjectDomain.triggerHandler(fflib_SObjectDomain.TestSObjectChangedRecordsConstructor.class);
		Account acct1changed = acct1.clone(),
		        acct2changed = acct2.clone();
		acct1changed.Name = 'Test1changed';
		fflib_SObjectDomain.Test.Database.onUpdate(
			new Account[]{ acct1, acct2},
			new Map<Id, Account>{
				acct1changed.Id => acct1,
				acct2changed.Id => acct2
			}
		);
	}


	@IsTest
	private static void itShouldReturnTheChangedRecordsBySObjectFields()
	{
		// GIVEN a domain with old and changed records

		Id idLuke = fflib_IDGenerator.generate(Account.SObjectType);
		Id idHan = fflib_IDGenerator.generate(Account.SObjectType);
		Id idLeia = fflib_IDGenerator.generate(Account.SObjectType);
		List<Account> oldRecords = new List<Account>
		{
				new Account(Id = idLuke, Name = 'Luke', Description = 'Jedi'),
				new Account(Id = idHan, Name = 'Han', Description = 'Pilot'),
				new Account(Id = idLeia, Name = 'Leia')
		};

		List<Account> newRecords = oldRecords.deepClone(true, true, true);
		newRecords.get(0).Name = 'Luke SkyWalker';
		newRecords.get(0).Description = 'Jedi Master';
		newRecords.get(1).Name = 'Han Solo';
		Accounts accounts = new Accounts(newRecords);
		accounts.ExistingRecords = new Map<Id, SObject>(oldRecords);

		// WHEN we create a domain with ExistingRecords and request the changed records
		List<SObject> result = accounts.getChangedRecords(
				new Set<Schema.SObjectField>
				{
						Account.Name,
						Account.Description
				}
		);

		// THEN it should only return the changed records
		Map<Id, SObject> resultMap = new Map<Id, SObject>(result);
		System.assertEquals(2, result.size());
		System.assert(resultMap.containsKey(idLuke));
		System.assert(resultMap.containsKey(idHan));
	}

	@IsTest
	private static void itShouldReturnTheChangedRecordsByStringFields()
	{
		// GIVEN a domain with old and changed records

		Id idLuke = fflib_IDGenerator.generate(Account.SObjectType);
		Id idHan = fflib_IDGenerator.generate(Account.SObjectType);
		Id idLeia = fflib_IDGenerator.generate(Account.SObjectType);
		List<Account> oldRecords = new List<Account>
		{
				new Account(Id = idLuke, Name = 'Luke', Description = 'Jedi'),
				new Account(Id = idHan, Name = 'Han', Description = 'Pilot'),
				new Account(Id = idLeia, Name = 'Leia')
		};

		List<Account> newRecords = oldRecords.deepClone(true, true, true);
		newRecords.get(0).Name = 'Luke SkyWalker';
		newRecords.get(0).Description = 'Jedi Master';
		newRecords.get(1).Name = 'Han Solo';
		Accounts accounts = new Accounts(newRecords);
		fflib_SObjectDomain.Test.Database.onUpdate(newRecords, new Map<Id, SObject>(oldRecords));

		// WHEN we create a domain with ExistingRecords and request the changed records
		List<SObject> result = accounts.getChangedRecords(
				new Set<String>
				{
						'Name',
						'Description'
				}
		);

		// THEN it should only return the changed records
		Map<Id, SObject> resultMap = new Map<Id, SObject>(result);
		System.assertEquals(2, result.size());
		System.assert(resultMap.containsKey(idLuke));
		System.assert(resultMap.containsKey(idHan));
	}


	/**
	 * Create test user
	 **/
	private static User createChatterExternalUser()
	{
		// Can only proceed with test if we have a suitable profile - Chatter External license has no access to Opportunity
		List<Profile> testProfiles = [Select Id From Profile where UserLicense.Name='Chatter External' limit 1];
		if(testProfiles.size()!=1)
			return null; 		

		// Can only proceed with test if we can successfully insert a test user 
		String testUsername = System.now().format('yyyyMMddhhmmss') + '@testorg.com';
		User testUser = new User(Alias = 'test1', Email='testuser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = testProfiles[0].Id, TimeZoneSidKey='America/Los_Angeles', UserName=testUsername);
		try {
			insert testUser;
		} catch (Exception e) {
			return null;
		}		
		return testUser;
	}

	/**
	 *	The following tests that the ability to enable/disable all trigger events works as required
	 **/
	@IsTest
	private static void testDisableTriggerEventsBehaviour()
	{
		boolean bError = false;

		String  sErrorMessage = '';

		Opportunity oldOpp = (Opportunity) Opportunity.sObjectType.newSObject('006E0000006mkRQ');
		oldOpp.Name = 'Test';
		oldOpp.Type = 'Existing'; 
		Opportunity newOpp = (Opportunity) Opportunity.sObjectType.newSObject('006E0000006mkRQ'); 
		newOpp.Name = 'Test';
		newOpp.Type = 'New'; 



		// these will be called multiple times making sure the correct error message comes back out
		// so... there are alot of tests to do here sadly and remember everything is reversed and you need to run backwards!
		// 1 - all disabled 
		try
		{
			fflib_SObjectDomain.getTriggerEvent(fflib_SObjectDomain.TestSObjectDisableBehaviourConstructor.class).disableAll();
			fflib_SObjectDomain.Test.Database.onInsert(new Opportunity[] { newOpp } );
			fflib_SObjectDomain.triggerHandler(fflib_SObjectDomain.TestSObjectDisableBehaviourConstructor.class);
		}
		catch (Exception e)
		{
			bError = true;
		}

		System.AssertEquals(false, bError, 'Error - Trigger events have been fired when they are disabled');

		////////////////////////////
		// Insert!
		try
		{
			// now lets go after insert and then before
			fflib_SObjectDomain.getTriggerEvent(fflib_SObjectDomain.TestSObjectDisableBehaviourConstructor.class).enableAfterInsert();
			fflib_SObjectDomain.Test.Database.onInsert(new Opportunity[] { newOpp } );
			fflib_SObjectDomain.triggerHandler(fflib_SObjectDomain.TestSObjectDisableBehaviourConstructor.class);
		}
		catch (Exception e)
		{
			sErrorMessage = e.getMessage();
			System.Debug('Exception Fired :' + e.getMEssage());
		}

		System.AssertEquals('onAfterInsert called', sErrorMessage, 'Error - After Insert Event is enabled but did not run');

		try
		{
			// now lets go after insert and then before
			fflib_SObjectDomain.getTriggerEvent(fflib_SObjectDomain.TestSObjectDisableBehaviourConstructor.class).enableBeforeInsert();
			fflib_SObjectDomain.Test.Database.onInsert(new Opportunity[] { newOpp } );
			fflib_SObjectDomain.triggerHandler(fflib_SObjectDomain.TestSObjectDisableBehaviourConstructor.class);
		}
		catch (Exception e)
		{
			sErrorMessage = e.getMessage();
		}

		System.AssertEquals('onBeforeInsert called', sErrorMessage, 'Error - Before Insert Event is enabled but did not run');

		////////////////////////////
		// Update!
		try
		{
			// now lets go after insert and then before
			fflib_SObjectDomain.getTriggerEvent(fflib_SObjectDomain.TestSObjectDisableBehaviourConstructor.class).enableAfterUpdate();
			fflib_SObjectDomain.Test.Database.onUpdate(new Opportunity[] { newOpp }, new Map<Id, SObject> { newOpp.Id => oldOpp } );
			fflib_SObjectDomain.triggerHandler(fflib_SObjectDomain.TestSObjectDisableBehaviourConstructor.class);
		}
		catch (Exception e)
		{
			sErrorMessage = e.getMessage();
		}

		System.AssertEquals('onAfterUpdate called', sErrorMessage, 'Error - After Update Event is enabled but did not run');

		try
		{
			// now lets go after insert and then before
			fflib_SObjectDomain.getTriggerEvent(fflib_SObjectDomain.TestSObjectDisableBehaviourConstructor.class).enableBeforeUpdate();
			fflib_SObjectDomain.Test.Database.onUpdate(new Opportunity[] { newOpp }, new Map<Id, SObject> { newOpp.Id => oldOpp } );
			fflib_SObjectDomain.triggerHandler(fflib_SObjectDomain.TestSObjectDisableBehaviourConstructor.class);
		}
		catch (Exception e)
		{
			sErrorMessage = e.getMessage();	
		}

		System.AssertEquals('onBeforeUpdate called', sErrorMessage, 'Error - Before Update Event is enabled but did not run');

		////////////////////////////
		// Delete!
		try
		{
			// now lets go after insert and then before
			fflib_SObjectDomain.getTriggerEvent(fflib_SObjectDomain.TestSObjectDisableBehaviourConstructor.class).enableAfterDelete();
			fflib_SObjectDomain.Test.Database.onDelete(new Map<Id, Opportunity> { newOpp.Id => newOpp } );
			fflib_SObjectDomain.triggerHandler(fflib_SObjectDomain.TestSObjectDisableBehaviourConstructor.class);
		}
		catch (Exception e)
		{
			sErrorMessage = e.getMessage();
		}

		System.AssertEquals('onAfterDelete called', sErrorMessage, 'Error - After Delete Event is enabled but did not run');

		try
		{
			// now lets go after insert and then before
			fflib_SObjectDomain.getTriggerEvent(fflib_SObjectDomain.TestSObjectDisableBehaviourConstructor.class).enableBeforeDelete();
			fflib_SObjectDomain.Test.Database.onDelete(new Map<Id, Opportunity> { newOpp.Id => newOpp } );
			fflib_SObjectDomain.triggerHandler(fflib_SObjectDomain.TestSObjectDisableBehaviourConstructor.class);
		}
		catch (Exception e)
		{
			sErrorMessage = e.getMessage();	
		}

		System.AssertEquals('onBeforeDelete called', sErrorMessage, 'Error - Before Delete Event is enabled but did not run');

		////////////////////////////
		// Undelete!
		try
		{
			// now lets go after insert and then before
			fflib_SObjectDomain.getTriggerEvent(fflib_SObjectDomain.TestSObjectDisableBehaviourConstructor.class).enableAfterUndelete();
			fflib_SObjectDomain.Test.Database.onUndelete(new Opportunity[] { newOpp });
			fflib_SObjectDomain.triggerHandler(fflib_SObjectDomain.TestSObjectDisableBehaviourConstructor.class);
		}
		catch (Exception e)
		{
			sErrorMessage = e.getMessage();
		}

		System.AssertEquals('onAfterUndelete called', sErrorMessage, 'Error - After Undelete Event is enabled but did not run');

		/*

		fflib_SObjectDomain.Test.Database.onInsert(new Opportunity[] { opp } );



		fflib_SObjectDomain.Test.Database.onUpdate(new Opportunity[] { newOpp }, new Map<Id, SObject> { newOpp.Id => oldOpp } );

		fflib_SObjectDomain.Test.Database.onDelete(new Map<ID, Opportunity> { opp.Id => opp } );		

		fflib_SObjectDomain.Test.Database.onUndelete(new list<Opportunity> { opp } );		


		try {		
			fflib_SObjectDomain.triggerHandler(fflib_SObjectDomain.TestSObjectOnValidateBehaviourConstructor.class);
			System.assert(false, 'Expected exception');
		} catch (Exception e) {
			System.assertEquals('onValidate called', e.getMessage());
		}
		*/
	}

	@IsTest
	private static void itShouldGetTheSObjectType()
	{
		// GIVEN a domain with Accounts;
		Accounts domain = new Accounts(generateAccounts());

		// WHEN we get the SObjectType of the domain
		Schema.SObjectType sObjectType = domain.sObjectType();

		// THEN it should return the SObjectType for Accounts
		System.assert(sObjectType == Account.SObjectType);
	}


	@IsTest
	private static void itShouldReturnTheRecords()
	{
		List<Account> records = generateAccounts();

		Accounts accounts = new Accounts(records.clone());

		System.assertEquals(records, accounts.getRecords());
	}

	@IsTest
	private static void itShouldGetAllTheRecordIds()
	{
		// GIVEN a list of records inside a domain
		List<Account> accounts = generateAccounts();
		Accounts domain = new Accounts(accounts);

		// WHEN we request a set of all record Ids
		Set<Id> result = domain.getRecordIds();

		// THEN all record Ids should be present
		System.assertEquals(
				new Map<Id, SObject>(accounts).keySet(),
				result,
				'Incorrect recordIds returned'
		);
	}

	@IsTest
	private static void itShouldCheckForAnEmptyDomain()
	{
		// GIVEN an empty domain
		Accounts domain = new Accounts(new List<Account>());

		// WHEN we check if the domain is empty
		Boolean result = domain.isEmpty();

		// THEN it should be empty
		System.assert(result, 'The domain was not empty');
	}

	@IsTest
	private static void itShouldCheckForAnEmptyDomain_failure()
	{
		// GIVEN an empty domain
		Accounts domain = new Accounts(generateAccounts());

		// WHEN we check if the domain is empty
		Boolean result = domain.isEmpty();

		// THEN it should be empty
		System.assert(!result, 'Oops the domain was not empty but validated as empty');
	}

	@IsTest
	private static void itShouldCheckForANotEmptyDomain()
	{
		// GIVEN an empty domain
		Accounts domain = new Accounts(generateAccounts());

		// WHEN we check if the domain is empty
		Boolean result = domain.isNotEmpty();

		// THEN it should be empty
		System.assert(result, 'The domain was not empty, but validated as empty');
	}

	@IsTest
	private static void itShouldCheckForANotEmptyDomain_failure()
	{
		// GIVEN an empty domain
		Accounts domain = new Accounts(new List<Account>());

		// WHEN we check if the domain is empty
		Boolean result = domain.isNotEmpty();

		// THEN it should be empty
		System.assert(!result, 'Oops the domain was empty but validated as not empty');
	}

	@IsTest
	private static void itShouldGetTheIdValues()
	{
		// GIVEN a domain with Contacts related to Accounts
		List<Account> accounts = generateAccounts();
		Set<Id> accountIds = new Map<Id, SObject>(accounts).keySet();
		List<Contact> contacts = generateContacts(accounts);
		Contacts domain = new Contacts(contacts);

		// WHEN we get the Id's of the related AccountId field
		Set<Id> result = domain.getIdFieldValues(Contact.AccountId);

		// THEN It should return the Ids of the Accounts
		System.assertEquals(result.size(), accountIds.size(), 'Incorrect number or returned records');
		System.assert(result.containsAll(accountIds), 'All account Ids should be returned');
	}

	@IsTest
	private static void itShouldThrowExceptionOnIncorrectFieldTypeForGetIdFieldValues()
	{
		// GIVEN a domain with Contacts related to Accounts
		List<Account> accounts = generateAccounts();
		Set<Id> accountIds = new Map<Id, SObject>(accounts).keySet();
		List<Contact> contacts = generateContacts(accounts);
		Contacts domain = new Contacts(contacts);

		// WHEN we get the values for the incorrect field type
		Boolean exceptionThrown = false;
		try
		{
			domain.getIdFieldValues(Contact.LastName);
		}
		catch (fflib_SObjectDomain.InvalidParameterTypeException e)
		{
			System.assertEquals('You can only use a field of the type Id', e.getMessage());
			exceptionThrown = true;
		}

		// THEN it should throw an exception
		System.assert(exceptionThrown, 'It should have thrown an exception for an incorrect field type');
	}

	@IsTest
	private static void itShouldGetAlShippingCountries()
	{
		// GIVEN a domain of Accounts with ShippingCountry values
		List<Account> accounts = generateAccounts();
		Accounts domain = new Accounts(accounts);
		Set<String> shippingCountries = new Set<String>();
		for (Account account : accounts)
		{
			shippingCountries.add(account.ShippingCountry);
		}
		System.assert(!shippingCountries.isEmpty(), 'Incorrect data to initiate test');

		// WHEN we get the Id's of the related AccountId field
		Set<String> result = domain.getStringFieldValues(Account.ShippingCountry);

		// THEN It should return the Ids of the Accounts
		System.assertEquals(result.size(), shippingCountries.size(), 'Incorrect number or returned values');
		System.assert(result.containsAll(shippingCountries), 'Not all shippingCountry values were returned');
	}

	@IsTest
	private static void itShouldThrowExceptionOnIncorrectFieldTypeForGetStringFieldValues()
	{
		// GIVEN a domain of Accounts with ShippingCountry values
		Accounts domain = new Accounts(generateAccounts());

		// WHEN we get the values for the incorrect field type
		Boolean exceptionThrown = false;
		try
		{
			Set<String> result = domain.getStringFieldValues(Account.OwnerId);
		}
		catch (fflib_SObjectDomain.InvalidParameterTypeException e)
		{
			System.assertEquals('You can only use a field of the type String', e.getMessage());
			exceptionThrown = true;
		}

		// THEN it should throw an exception
		System.assert(exceptionThrown, 'It should have thrown an exception for an incorrect field type');
	}

	@IsTest
	private static void itShouldGetAStringByStringMap()
	{
		Accounts domain = new Accounts(
				new List<Account>
				{
						new Account(Name = 'Account A', ShippingCountry = USA, Rating = COLD),
						new Account(Name = 'Account B', ShippingCountry = IRELAND, Rating = WARM),
						new Account(Name = 'Account C', ShippingCountry = HOLLAND, Rating = HOT)
				}
		);
		Map<String, String> result = domain.getRatingByShippingCountry();
		System.assertEquals(3, result.size());
		System.debug(result);
		System.assertEquals(HOT, result.get(HOLLAND));
		System.assertEquals(WARM, result.get(IRELAND));
		System.assertEquals(COLD, result.get(USA));
	}

	@IsTest
	private static void itShouldSetAFieldValue()
	{
		Accounts domain = new Accounts(
				new List<Account>
				{
						new Account(Name = 'Account A', ShippingCountry = USA),
						new Account(Name = 'Account B', ShippingCountry = IRELAND),
						new Account(Name = 'Account C', ShippingCountry = ITALY)
				}
		);

		domain.setShippingCountry(HOLLAND);
		List<Account> results = (List<Account>) domain.getRecords();
		System.assertEquals(3, results.size());
		for (Account result : results)
		{
			System.assertEquals(HOLLAND, result.ShippingCountry);
		}
	}

	@IsTest
	private static void itShouldGetTheAccountNameById()
	{
		Id usaId = fflib_IDGenerator.generate(Account.SObjectType);
		Id irelandId = fflib_IDGenerator.generate(Account.SObjectType);
		Accounts domain = new Accounts(
				new List<Account>
				{
						new Account(Id = usaId, Name = USA),
						new Account(Id = irelandId, Name = IRELAND)
				}
		);

		Map<Id, String> result = domain.getNameById();
		System.assertEquals(2, result.size());
		System.assertEquals(USA, result.get(usaId));
		System.assertEquals(IRELAND, result.get(irelandId));
	}

	@IsTest
	private static void itShouldGetContactsByAccountId()
	{
		Id usaId = fflib_IDGenerator.generate(Account.SObjectType);
		Id irelandId = fflib_IDGenerator.generate(Account.SObjectType);

		Contacts domain = new Contacts(
				new List<Contact>
				{
						new Contact(AccountId = usaId),
						new Contact(AccountId = usaId),
						new Contact(AccountId = irelandId)
				}
		);

		Map<Id, List<SObject>> result = domain.getSObjectsByAccountId();
		System.assertEquals(2, result.size());
		System.assertEquals(2, result.get(usaId).size());
		System.assertEquals(1, result.get(irelandId).size());
	}

	@IsTest
	private static void itShouldGetContactsByCountry()
	{
		Contacts domain = new Contacts(
				new List<Contact>
				{
						new Contact(MailingCountry = USA),
						new Contact(MailingCountry = IRELAND),
						new Contact(MailingCountry = IRELAND),
						new Contact(MailingCountry = ITALY)
				}
		);

		Map<String, List<SObject>> result = domain.getSObjectsByMailingCountry();
		System.assertEquals(3, result.size());
		System.assertEquals(1, result.get(USA).size());
		System.assertEquals(1, result.get(ITALY).size());
		System.assertEquals(2, result.get(IRELAND).size());
	}

	@IsTest
	private static void itShouldGetAccountByName()
	{
		Id usaId = fflib_IDGenerator.generate(Account.SObjectType);
		Id irelandId = fflib_IDGenerator.generate(Account.SObjectType);

		Accounts domain = new Accounts(
				new List<Account>
				{
						new Account(Id = usaId, Name = USA),
						new Account(Id = irelandId, Name = IRELAND)
				}
		);

		Map<String, SObject> result = domain.getSObjectByAccountName();
		System.assertEquals(2, result.size());
		System.assertEquals(usaId, result.get(USA).Id);
		System.assertEquals(irelandId, result.get(IRELAND).Id);
	}

	private static List<Account> generateAccounts()
	{
		return new List<Account>
		{
				new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Account A', ShippingCountry = 'USA'),
				new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Account B', ShippingCountry = IRELAND),
				new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Account C', ShippingCountry = HOLLAND)
		};
	}

	private static List<Contact> generateContacts(List<Account> accounts)
	{
		List<Contact> result = new List<Contact>();
		for (Account account : accounts)
		{
			result.add(
					new Contact(
							Id = fflib_IDGenerator.generate(Contact.SObjectType),
							AccountId = account.Id
					)
			);
		}
		return result;
	}

	private class Accounts extends fflib_SObjectDomain
	{
		public Accounts(List<SObject> records)
		{
			super(records);
		}

		public Map<String, String> getRatingByShippingCountry()
		{
			return getStringFieldByStringField(Account.Rating, Account.ShippingCountry);
		}

		public Map<Id, String> getNameById()
		{
			return getStringFieldByIdField(Account.Name, Account.Id);
		}

		public Map<String, SObject> getSObjectByAccountName()
		{
			return getSObjectByStringField(Account.Name);
		}

		public void setShippingCountry(String shippingCountry)
		{
			setFieldValue(Schema.Account.ShippingCountry, shippingCountry);
		}
	}

	private class Contacts extends fflib_SObjectDomain
	{
		public Contacts(List<SObject> records)
		{
			super(records);
		}

		public Map<Id, List<SObject>> getSObjectsByAccountId()
		{
			return getSObjectsByIdField(Contact.AccountId);
		}

		public Map<String, List<SObject>> getSObjectsByMailingCountry()
		{
			return getSObjectsByStringField(Contact.MailingCountry);
		}
	}
}