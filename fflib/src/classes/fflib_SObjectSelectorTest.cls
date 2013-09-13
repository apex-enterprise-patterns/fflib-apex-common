/**
 * Copyright (c) 2012, FinancialForce.com, inc
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
private with sharing class fflib_SObjectSelectorTest 
{
	
	static testMethod void testGetFieldListString()
	{
		Testfflib_SObjectSelector selector = new Testfflib_SObjectSelector();
		List<String> fieldList = selector.getFieldListString().split(',');
		Set<String> fieldSet = new Set<String>(fieldList);
		system.assertEquals(4, fieldSet.size());
		system.assert(fieldSet.contains('Name'));
		system.assert(fieldSet.contains('Id'));
		system.assert(fieldSet.contains('AccountNumber'));
		system.assert(fieldSet.contains('AnnualRevenue'));
		if(UserInfo.isMultiCurrencyOrganization())
			system.assert(fieldSet.contains('CurrencyIsoCode'));
	}
	
	static testMethod void testGetSObjectName()
	{
		Testfflib_SObjectSelector selector = new Testfflib_SObjectSelector();
		system.assertEquals('Account',selector.getSObjectName());
	}
	
	static testMethod void testSelectSObjectsById()
	{
		// Inserting in reverse order so that we can test the order by of select 
		List<Account> accountList = new List<Account> {
			new Account(Name='TestAccount2',AccountNumber='A2',AnnualRevenue=12345.67),
			new Account(Name='TestAccount1',AccountNumber='A1',AnnualRevenue=76543.21) };		
		insert accountList;		
		Set<Id> idSet = new Set<Id>();
		for(Account item : accountList)
			idSet.add(item.Id);
			
		Test.startTest();		
		Testfflib_SObjectSelector selector = new Testfflib_SObjectSelector();
		List<Account> result = (List<Account>) selector.selectSObjectsById(idSet);		
		Test.stopTest();
		
		system.assertEquals(2,result.size());
		system.assertEquals('TestAccount1',result[0].Name);
		system.assertEquals('A1',result[0].AccountNumber);
		system.assertEquals(76543.21,result[0].AnnualRevenue);
		system.assertEquals('TestAccount2',result[1].Name);
		system.assertEquals('A2',result[1].AccountNumber);
		system.assertEquals(12345.67,result[1].AnnualRevenue);
	}
	
	static testMethod void testAssertIsAccessible()
	{
		List<Account> accountList = new List<Account> {
			new Account(Name='TestAccount2',AccountNumber='A2',AnnualRevenue=12345.67),
			new Account(Name='TestAccount1',AccountNumber='A1',AnnualRevenue=76543.21) };		
		insert accountList;		
		Set<Id> idSet = new Set<Id>();
		for(Account item : accountList)
			idSet.add(item.Id);
		
		// Create a user which will not have access to the test object type
		User testUser = createChatterExternalUser();
		if(testUser==null)
			return; // Abort the test if unable to create a user with low enough acess
		System.runAs(testUser)
		{					
			Testfflib_SObjectSelector selector = new Testfflib_SObjectSelector();
			try
			{
				List<Account> result = (List<Account>) selector.selectSObjectsById(idSet);
				System.assert(false,'Expected exception was not thrown');
			}
			catch(fflib_SObjectDomain.DomainException e)
			{
				System.assertEquals('Permission to access an Account dennied.',e.getMessage());
			}
		}
	}
	
	private class Testfflib_SObjectSelector extends fflib_SObjectSelector
	{
		public List<Schema.SObjectField> getSObjectFieldList()
		{
			return new List<Schema.SObjectField> {
				Account.Name,
				Account.Id,
				Account.AccountNumber,
				Account.AnnualRevenue
			};
		}
		
		public Schema.SObjectType getSObjectType()
		{
			return Account.sObjectType;
		}
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