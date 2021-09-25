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
private with sharing class fflib_SObjectSelectorTest 
{
	
	static testMethod void testGetSObjectName()
	{
		Testfflib_SObjectSelector selector = new Testfflib_SObjectSelector();
		system.assertEquals(null, selector.getSObjectFieldSetList());
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
		system.assertEquals('TestAccount2',result[0].Name);
		system.assertEquals('A2',result[0].AccountNumber);
		system.assertEquals(12345.67,result[0].AnnualRevenue);
		system.assertEquals('TestAccount1',result[1].Name);
		system.assertEquals('A1',result[1].AccountNumber);
		system.assertEquals(76543.21,result[1].AnnualRevenue);
	}

	static testMethod void testQueryLocatorById()
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
		Database.QueryLocator result = selector.queryLocatorById(idSet);		
		System.Iterator<SObject> iteratorResult = result.iterator();
		Test.stopTest();		

		System.assert(true, iteratorResult.hasNext());
		Account account = (Account) iteratorResult.next();
		system.assertEquals('TestAccount2',account.Name);
		system.assertEquals('A2',account.AccountNumber);
		system.assertEquals(12345.67,account.AnnualRevenue);				
		System.assert(true, iteratorResult.hasNext());
		account = (Account) iteratorResult.next();
		system.assertEquals('TestAccount1',account.Name);
		system.assertEquals('A1',account.AccountNumber);
		system.assertEquals(76543.21,account.AnnualRevenue);				
		System.assertEquals(false, iteratorResult.hasNext());
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
				System.assertEquals('Permission to access an Account denied.',e.getMessage());
			}
		}
	}

	static testMethod void testCRUDOff()
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
			Testfflib_SObjectSelector selector = new Testfflib_SObjectSelector(false, false, false, true);
			try
			{
				List<Account> result = (List<Account>) selector.selectSObjectsById(idSet);
			}
			catch(fflib_SObjectDomain.DomainException e)
			{
				System.assert(false,'Did not expect an exception to be thrown');
			}
		}
	}
	
	static testMethod void testSOQL()
	{
		Testfflib_SObjectSelector selector = new Testfflib_SObjectSelector();
		String soql = selector.newQueryFactory().toSOQL();
		Pattern p = Pattern.compile('SELECT (.*) FROM Account ORDER BY Name DESC NULLS FIRST , AnnualRevenue ASC NULLS LAST ');
		Matcher m = p.matcher(soql);
		System.assert(m.matches(), 'Generated SOQL does not match expected pattern. Here is the generated SOQL: ' + soql);
		System.assertEquals(1, m.groupCount(), 'Unexpected number of groups captured.');
		String fieldListString = m.group(1);
		assertFieldListString(fieldListString, null);
	}
	
	static testMethod void testSOQL_defaultSorting()
	{
		Testfflib_SObjectSelectorDefaultSorting selector = new Testfflib_SObjectSelectorDefaultSorting(false);
		String soql = selector.newQueryFactory().toSOQL();
		Pattern p = Pattern.compile('SELECT (.*) FROM Account ORDER BY Name ASC NULLS FIRST ');
		Matcher m = p.matcher(soql);
		System.assert(m.matches(), 'Generated SOQL does not match expected pattern. Here is the generated SOQL: ' + soql);
		System.assertEquals(1, m.groupCount(), 'Unexpected number of groups captured.');
		String fieldListString = m.group(1);
		assertFieldListString(fieldListString, null);
	}

	static testMethod void testDefaultConfig()
	{
		Testfflib_SObjectSelector selector = new Testfflib_SObjectSelector();
		System.assertEquals(false, selector.isEnforcingFLS());
		System.assertEquals(true, selector.isEnforcingCRUD());
		System.assertEquals(false, selector.isIncludeFieldSetFields());
		
		System.assertEquals('Account', selector.getSObjectName());
		System.assertEquals(Account.SObjectType, selector.getSObjectType2());
	}
	
	private static void assertFieldListString(String fieldListString, String prefix) {
		String prefixString = (!String.isBlank(prefix)) ? prefix + '.' : '';
		List<String> fieldList = fieldListString.split(',{1}\\s?');
		System.assertEquals(UserInfo.isMultiCurrencyOrganization() ? 5 : 4, fieldList.size()); 
		Set<String> fieldSet = new Set<String>();
		fieldSet.addAll(fieldList);
		String expected = prefixString + 'AccountNumber';
		System.assert(fieldSet.contains(expected), expected + ' missing from field list string: ' + fieldListString);
		expected = prefixString + 'AnnualRevenue';
		System.assert(fieldSet.contains(expected), expected + ' missing from field list string: ' + fieldListString);
		expected = prefixString + 'Id';
		System.assert(fieldSet.contains(expected), expected + ' missing from field list string: ' + fieldListString);
		expected = prefixString + 'Name';
		System.assert(fieldSet.contains(expected), expected + ' missing from field list string: ' + fieldListString);
		if (UserInfo.isMultiCurrencyOrganization()) {
			expected = prefixString + 'CurrencyIsoCode';
			System.assert(fieldSet.contains(expected), expected + ' missing from field list string: ' + fieldListString);
		}
	}
	

	@isTest
	static void testWithoutSorting()
	{
		//Given
		Testfflib_SObjectSelector selector = new Testfflib_SObjectSelector(false, false, false, false);
		fflib_QueryFactory qf = selector.newQueryFactory();
		
		Set<String> expectedSelectFields = new Set<String>{ 'Name', 'Id', 'AccountNumber', 'AnnualRevenue' };
		if (UserInfo.isMultiCurrencyOrganization())
		{
			expectedSelectFields.add('CurrencyIsoCode');
		}

		//When
		String soql = qf.toSOQL();

		//Then
		Pattern soqlPattern = Pattern.compile('SELECT (.*) FROM Account ORDER BY Name DESC NULLS FIRST , AnnualRevenue ASC NULLS LAST ');
		Matcher soqlMatcher = soqlPattern.matcher(soql);
		soqlMatcher.matches();

		List<String> actualSelectFields = soqlMatcher.group(1).deleteWhiteSpace().split(',');
		System.assertEquals(expectedSelectFields, new Set<String>(actualSelectFields));
	}

	// Test case of ordering with NULLS LAST option passed into the ordering method
	@isTest
	static void testWithOrderingNullsLast()
	{
		// Build the selector to test with
		Testfflib_SObjectSelector selector = new Testfflib_SObjectSelector(false, false, false, false);
		fflib_QueryFactory qf = selector.newQueryFactory();
		
		// Add in the expected fields
		Set<String> expectedSelectFields = new Set<String>{ 'Name', 'Id', 'AccountNumber', 'AnnualRevenue' };
		if (UserInfo.isMultiCurrencyOrganization())
		{
			expectedSelectFields.add('CurrencyIsoCode');
		}

		// Generate the SOQL string
		String soql = qf.toSOQL();

		// Assert that the
		Pattern soqlPattern = Pattern.compile('SELECT (.*) FROM Account ORDER BY Name DESC NULLS FIRST , AnnualRevenue ASC NULLS LAST ');
		Matcher soqlMatcher = soqlPattern.matcher(soql);
		system.assert(soqlMatcher.matches(), 'The SOQL should have that expected.');
	}

	@IsTest
	static void testConfigureQueryFactoryFields() {
		//Given
		Testfflib_UserSObjectSelector selector = new Testfflib_UserSObjectSelector();
		fflib_QueryFactory qf = new fflib_QueryFactory(Account.SObjectType);

		Set<String> expectedSelectFields = new Set<String>{ 'Owner.Name', 'Owner.Id', 'Owner.Username', 'Owner.LastLoginDate' };
		if (UserInfo.isMultiCurrencyOrganization())
		{
			expectedSelectFields.add('Owner.CurrencyIsoCode');
		}

		//When
		selector.configureQueryFactoryFields(qf, 'Owner');

		//Then
		String soql = qf.toSOQL();
		Pattern soqlPattern = Pattern.compile('SELECT (.*) FROM Account');
		Matcher soqlMatcher = soqlPattern.matcher(soql);
		System.assert(soqlMatcher.matches(), 'Generated SOQL does not match expected pattern. Here is the generated SOQL: ' + soql);

		List<String> actualSelectFields = soqlMatcher.group(1).deleteWhiteSpace().split(',');
		System.assertEquals(expectedSelectFields, new Set<String>(actualSelectFields));
	}

	@IsTest
	static void testAddQueryFactorySubselect() {
		//Given
		Testfflib_UserSObjectSelector selector = new Testfflib_UserSObjectSelector();
		fflib_QueryFactory qf = new fflib_QueryFactory(Account.SObjectType);

		Set<String> expectedSelectFields = new Set<String>{ 'Name', 'Id', 'Username', 'LastLoginDate' };
		if (UserInfo.isMultiCurrencyOrganization())
		{
			expectedSelectFields.add('CurrencyIsoCode');
		}

		//When
		selector.addQueryFactorySubselect(qf);

		//Then
		String soql = qf.toSOQL();
		Pattern soqlPattern = Pattern.compile('SELECT Id, \\(SELECT (.*) FROM Users ORDER BY Name ASC NULLS FIRST \\) +FROM Account');
		Matcher soqlMatcher = soqlPattern.matcher(soql);
		System.assert(soqlMatcher.matches(), 'Generated SOQL does not match expected pattern. Here is the generated SOQL: ' + soql);

		List<String> actualSelectFields = soqlMatcher.group(1).deleteWhiteSpace().split(',');
		System.assertEquals(expectedSelectFields, new Set<String>(actualSelectFields));
	}

	@IsTest
	static void testAddQueryFactorySubselect2() {
		//Given
		Testfflib_UserSObjectSelector selector = new Testfflib_UserSObjectSelector();
		fflib_QueryFactory qf = new fflib_QueryFactory(Account.SObjectType);

		Set<String> expectedSelectFields = new Set<String>{ 'Name', 'Id', 'Username', 'LastLoginDate' };
		if (UserInfo.isMultiCurrencyOrganization())
		{
			expectedSelectFields.add('CurrencyIsoCode');
		}

		//When
		selector.addQueryFactorySubselect(qf, 'Users');

		//Then
		String soql = qf.toSOQL();
		Pattern soqlPattern = Pattern.compile('SELECT Id, \\(SELECT (.*) FROM Users ORDER BY Name ASC NULLS FIRST \\) +FROM Account');
		Matcher soqlMatcher = soqlPattern.matcher(soql);
		System.assert(soqlMatcher.matches(), 'Generated SOQL does not match expected pattern. Here is the generated SOQL: ' + soql);

		List<String> actualSelectFields = soqlMatcher.group(1).deleteWhiteSpace().split(',');
		System.assertEquals(expectedSelectFields, new Set<String>(actualSelectFields));
	}

	@IsTest
	static void testGetFieldListString() {
		//Given
		Testfflib_UserSObjectSelector selector = new Testfflib_UserSObjectSelector();
		fflib_QueryFactory qf = new fflib_QueryFactory(Account.SObjectType);

		Set<String> expectedSelectFields = new Set<String>{ 'Name', 'Id', 'Username', 'LastLoginDate' };
		if (UserInfo.isMultiCurrencyOrganization())
		{
			expectedSelectFields.add('CurrencyIsoCode');
		}

		//When
		String fieldListString = selector.getFieldListString();

		//Then
		List<String> actualSelectFields = fieldListString.deleteWhiteSpace().split(',');
		System.assertEquals(expectedSelectFields, new Set<String>(actualSelectFields));
	}

	@IsTest
	static void testGetRelatedFieldListString() {
		//Given
		Testfflib_UserSObjectSelector selector = new Testfflib_UserSObjectSelector();

		Set<String> expectedSelectFields = new Set<String>{ 'Owner.Name', 'Owner.Id', 'Owner.Username', 'Owner.LastLoginDate' };
		if (UserInfo.isMultiCurrencyOrganization())
		{
			expectedSelectFields.add('Owner.CurrencyIsoCode');
		}

		//When
		String fieldListString = selector.getRelatedFieldListString('Owner');

		//Then
		List<String> actualSelectFields = fieldListString.deleteWhiteSpace().split(',');
		System.assertEquals(expectedSelectFields, new Set<String>(actualSelectFields));

	}

	private static void assertEqualsSelectFields(String expectedSelectFields, String actualSelectFields)
	{
		Set<String> expected = new Set<String>(expectedSelectFields.deleteWhiteSpace().split(','));
		Set<String> actual = new Set<String>(actualSelectFields.deleteWhiteSpace().split(','));

		System.assertEquals(expected, actual);
	}
	
	private class Testfflib_SObjectSelector extends fflib_SObjectSelector
	{
		public Testfflib_SObjectSelector()
		{
			super();
		}

		public Testfflib_SObjectSelector(Boolean includeFieldSetFields, Boolean enforceCRUD, Boolean enforceFLS, Boolean sortSelectFields)
		{
			super(includeFieldSetFields, enforceCRUD, enforceFLS, sortSelectFields);
		}
		
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
		
		public override String getOrderBy()
		{
			return 'Name DESC, AnnualRevenue ASC NULLS LAST';
		}
	}
	
	private class Testfflib_UserSObjectSelector extends fflib_SObjectSelector
	{
		public Testfflib_UserSObjectSelector()
		{
			super();
		}

		public List<Schema.SObjectField> getSObjectFieldList()
		{
			return new List<Schema.SObjectField> {
				User.Name,
				User.Id,
				User.Username,
				User.LastLoginDate
			};
		}

		public Schema.SObjectType getSObjectType()
		{
			return User.SObjectType;
		}

	}

	private class Testfflib_SObjectSelectorDefaultSorting extends fflib_SObjectSelector
	{
		public Testfflib_SObjectSelectorDefaultSorting(Boolean includeFieldSetFields)
		{
			super(includeFieldSetFields);
		}

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
