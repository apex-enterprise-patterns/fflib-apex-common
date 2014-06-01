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
	@IsTest
	private static void testValidationWithoutDML()
	{
		fflib_SObjectDomain.TestSObjectDomain opps = new fflib_SObjectDomain.TestSObjectDomain(new Opportunity[] { new Opportunity ( Name = 'Test', Type = 'Existing Account' ) } );
		opps.onValidate();
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
				System.assertEquals('Permission to udpate an Opportunity denied.', e.getMessage());
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
}