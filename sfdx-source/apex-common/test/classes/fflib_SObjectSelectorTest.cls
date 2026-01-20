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
	@TestSetup
	static void testSetup(){
		fflib_SecurityUtilsTest.testSetup();
	}
	
	static testMethod void testGetSObjectName()
	{
		AccountSelector selector = new AccountSelector();
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
		AccountSelector selector = new AccountSelector();
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
		AccountSelector selector = new AccountSelector();
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
			AccountSelector selector = new AccountSelector();
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
			AccountSelector selector = new AccountSelector(false, false, false, true);
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
		AccountSelector selector = new AccountSelector();
		String soql = selector.newQueryFactory().toSOQL();
		Pattern p = Pattern.compile('SELECT (.*) FROM Account ORDER BY AccountNumber DESC NULLS FIRST , AnnualRevenue ASC NULLS LAST ');
		Matcher m = p.matcher(soql);
		System.assert(m.matches(), 'Generated SOQL does not match expected pattern. Here is the generated SOQL: ' + soql);
		System.assertEquals(1, m.groupCount(), 'Unexpected number of groups captured.');
		String fieldListString = m.group(1);
		assertFieldListString(fieldListString, null);
	}
	
	static testMethod void testSOQL_defaultSorting()
	{
		DefaultSortingAccountSelector selector = new DefaultSortingAccountSelector(false);
		String soql = selector.newQueryFactory().toSOQL();
		Pattern p = Pattern.compile(String.format('SELECT (.*) FROM Account ORDER BY {0} ASC NULLS FIRST ',
			new List<String>{selector.getOrderBy()}));
		Matcher m = p.matcher(soql);
		System.assert(m.matches(), 'Generated SOQL does not match expected pattern. Here is the generated SOQL: ' + soql);
		System.assertEquals(1, m.groupCount(), 'Unexpected number of groups captured.');
		String fieldListString = m.group(1);
		assertFieldListString(fieldListString, null);
	}

	static testMethod void testDefaultConfig()
	{
		AccountSelector selector = new AccountSelector();
		System.assertEquals(false, selector.isEnforcingFLS());
		System.assertEquals(true, selector.isEnforcingCRUD());
		System.assertEquals(false, selector.isIncludeFieldSetFields());
		System.assertEquals(fflib_SObjectSelector.DataAccess.LEGACY, selector.getDataAccess());
		
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
	

	@IsTest
	static void testWithoutSorting()
	{
		//Given
		AccountSelector selector = new AccountSelector(false, false, false, false);
		fflib_QueryFactory qf = selector.newQueryFactory();
		
		Set<String> expectedSelectFields = new Set<String>{ 'Name', 'Id', 'AccountNumber', 'AnnualRevenue' };
		if (UserInfo.isMultiCurrencyOrganization())
		{
			expectedSelectFields.add('CurrencyIsoCode');
		}

		//When
		String soql = qf.toSOQL();

		//Then
		Pattern soqlPattern = Pattern.compile('SELECT (.*) FROM Account ORDER BY AccountNumber DESC NULLS FIRST , AnnualRevenue ASC NULLS LAST ');
		Matcher soqlMatcher = soqlPattern.matcher(soql);
		soqlMatcher.matches();

		List<String> actualSelectFields = soqlMatcher.group(1).deleteWhiteSpace().split(',');
		System.assertEquals(expectedSelectFields, new Set<String>(actualSelectFields));
	}

	// Test case of ordering with NULLS LAST option passed into the ordering method
	@IsTest
	static void testWithOrderingNullsLast()
	{
		// Build the selector to test with
		AccountSelector selector = new AccountSelector(false, false, false, false);
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
		Pattern soqlPattern = Pattern.compile('SELECT (.*) FROM Account ORDER BY AccountNumber DESC NULLS FIRST , AnnualRevenue ASC NULLS LAST ');
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
		Pattern soqlPattern = Pattern.compile(String.format('SELECT Id, \\(SELECT (.*) FROM Users ORDER BY {0} ASC NULLS FIRST \\) +FROM Account',new List<String>{selector.getOrderBy()}));
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
		Pattern soqlPattern = Pattern.compile(String.format('SELECT Id, \\(SELECT (.*) FROM Users ORDER BY {0} ASC NULLS FIRST \\) +FROM Account',
			new List<String>{selector.getOrderBy()}));
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

	@IsTest
	static void toSOQL_When_UserModeAndUserCannnotReadObject_Expect_QueryException(){
		AccessLevelOpportunitySelector sel = new AccessLevelOpportunitySelector();

		User u = getMinimumAccessUser();
		System.runAs(u){
			try{
				System.debug(sel.newQueryFactory().toSOQL());
				sel.selectSObjectsById(new Set<Id>{fflib_IDGenerator.generate(Opportunity.SObjectType)});
				Assert.fail('Expected a QueryException due to read only user not having access to Opportunity');
			}
			catch(QueryException qe){
				//If you don't have Read access to the Lead object, the Name field is inaccessible -- so that's what we're verifying
				Assert.isNotNull(qe.getInaccessibleFields(),'Expected a Map of inaccessible objects; got null');
				Set<String> inaccessibleFields = qe.getInaccessibleFields().get('Opportunity');
				Assert.isNotNull(inaccessibleFields,'Expected a Set of inaccessible fields on the Opportunity object; got null');
				Assert.isTrue(inaccessibleFields.contains('Name'),'Expected Name to be an inaccessible field on Opportunity');
			}
		}
	}

	@IsTest
	static void toSOQL_When_SystemModeAndUserCannnotReadObject_Expect_Success(){
		AccessLevelOpportunitySelector sel = new AccessLevelOpportunitySelector(fflib_SObjectSelector.DataAccess.SYSTEM_MODE);

		User u = getMinimumAccessUser();
		System.runAs(u){
			sel.selectSObjectsById(new Set<Id>{fflib_IDGenerator.generate(Opportunity.SObjectType)});
		}
	}

	@IsTest
	static void toSOQL_When_UserModeAndUserCannnotReadField_Expect_QueryException(){
		AccessLevelAccountSelector sel = new AccessLevelAccountSelector();

		//Account has Read access by the limited read only user but no FLS access
		User u = getMinimumAccessUser();
		System.runAs(u){
			try{
				System.debug(sel.newQueryFactory().toSOQL());
				sel.selectSObjectsById(new Set<Id>{fflib_IDGenerator.generate(Account.SObjectType)});
				Assert.fail('Expected a QueryException due to read only user not having access to AnnualRevenue');
			}
			catch(QueryException qe){
				//If you don't have Read access to the Lead object, the Name field is inaccessible -- so that's what we're verifying
				Assert.isNotNull(qe.getInaccessibleFields(),'Expected a Map of inaccessible objects; got null');
				Set<String> inaccessibleFields = qe.getInaccessibleFields().get('Account');
				Assert.isNotNull(inaccessibleFields,'Expected a Set of inaccessible fields on the Account object; got null');
				Assert.isFalse(inaccessibleFields.contains('Name'),'Expected Name to be an accessible field on Account');
				Assert.isTrue(inaccessibleFields.contains('AnnualRevenue'),'Expected AnnualRevenue to be an inaccessible field on Account');
			}
		}
	}

	@IsTest
	static void toSOQL_When_SystemModeAndUserCannnotReadField_Expect_Success(){
		AccessLevelAccountSelector sel = new AccessLevelAccountSelector(fflib_SObjectSelector.DataAccess.SYSTEM_MODE);

		//Account has Read access by the limited read only user but no FLS access
		User u = getMinimumAccessUser();
		System.runAs(u){
			sel.selectSObjectsById(new Set<Id>{fflib_IDGenerator.generate(Account.SObjectType)});
		}
	}

	@IsTest
	static void toSOQL_When_SystemModeAndParentRelationshipAndDuplicateFields_Expect_WellFormedSOQL(){
		AccessLevelOpportunitySelector sel = new AccessLevelOpportunitySelector(fflib_SObjectSelector.DataAccess.SYSTEM_MODE);

		String soql = sel.createSelectAllWithAccountSOQL();

		String expected = String.format('SELECT name, id, amount, closedate, (currencyisocode, )?account\\.name, account\\.billingpostalcode(, currencyisocode)? FROM Opportunity WITH SYSTEM_MODE ORDER BY {0} ASC NULLS FIRST ',
			new List<String>{sel.getOrderBy()});
		Pattern soqlPattern = Pattern.compile(expected);
		Matcher soqlMatcher = soqlPattern.matcher(soql);
		System.assert(soqlMatcher.matches(),'Expected: ' + expected + ' Actual:' + soql);
	}

	@IsTest
	static void toSOQL_When_SystemModeAndChildRelationship_Expect_WellFormedSOQL(){
		AccessLevelAccountSelector sel = new AccessLevelAccountSelector(fflib_SObjectSelector.DataAccess.SYSTEM_MODE);

	AccessLevelOpportunitySelector innerSelector = new AccessLevelOpportunitySelector();

	String soql = sel.createSelectAccountWithOpportunitiesSOQL();

	String expected = String.format(
	  'SELECT name, id, annualrevenue, accountnumber, (currencyisocode, )?\\(SELECT name, id, amount, closedate(, currencyisocode)? FROM Opportunities ORDER BY {0} ASC NULLS FIRST \\)  FROM Account WITH SYSTEM_MODE ORDER BY {1} ASC NULLS FIRST ',
	  new List<String>{ innerSelector.getOrderBy(), sel.getOrderBy() }
	);
		Pattern soqlPattern = Pattern.compile(expected);
		Matcher soqlMatcher = soqlPattern.matcher(soql);
		System.assert(soqlMatcher.matches(),'Expected: ' + expected + ' Actual:' + soql);
	}


	private class AccountSelector extends fflib_SObjectSelector
	{
		public AccountSelector()
		{
			super();
		}

		public AccountSelector(Boolean includeFieldSetFields, Boolean enforceCRUD, Boolean enforceFLS, Boolean sortSelectFields)
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
			return 'AccountNumber DESC, AnnualRevenue ASC NULLS LAST';
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

	private class DefaultSortingAccountSelector extends fflib_SObjectSelector
	{
		public DefaultSortingAccountSelector(Boolean includeFieldSetFields)
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

	private class AccessLevelOpportunitySelector extends fflib_SObjectSelector{
		public AccessLevelOpportunitySelector(){
			this(DataAccess.USER_MODE);
		}

		public AccessLevelOpportunitySelector(DataAccess access){
			super(false, access);
		}

		public Schema.SObjectType getSObjectType(){
			return Opportunity.sObjectType;
		}

		public List<Schema.SObjectField> getSObjectFieldList(){
			return new List<Schema.SObjectField> {
					Opportunity.Name,
					Opportunity.Id,
					Opportunity.Amount,
					Opportunity.CloseDate
			};
		}

		@TestVisible
		private String createSelectAllWithAccountSOQL(){
			fflib_QueryFactory qf = newQueryFactory();

			qf.selectField('AMOUNT'); //Duplicate (as String)
			qf.selectField('amount'); //Duplicate (as String)
			qf.selectField(Opportunity.Amount); //Duplicate (as SObjectField)

			//Parent Relationship
			qf.selectFields(new Set<String>{
					'Account.Name',
					'Account.BillingPostalCode'
			});
			qf.selectField('Account.BILLINGPOSTALCODE'); //Duplicate field (as String)

			return qf.toSOQL();
		}

		public List<Opportunity> selectAllWithAccount(){
			return Database.query(createSelectAllWithAccountSOQL());
		}
	}

	private class AccessLevelAccountSelector extends fflib_SObjectSelector{
		public AccessLevelAccountSelector(){
			this(DataAccess.USER_MODE);
		}

		public AccessLevelAccountSelector(DataAccess access){
			super(false, access);
		}

		public Schema.SObjectType getSObjectType(){
			return Account.sObjectType;
		}

		public List<Schema.SObjectField> getSObjectFieldList(){
			return new List<Schema.SObjectField> {
					Account.Name,
					Account.Id,
					Account.AnnualRevenue,
					Account.AccountNumber
			};
		}

		@TestVisible
		private String createSelectAccountWithOpportunitiesSOQL(){
			AccessLevelOpportunitySelector oSel = new AccessLevelOpportunitySelector(getDataAccess());

			fflib_QueryFactory qf = newQueryFactory();

			oSel.addQueryFactorySubselect(qf,'Opportunities');

			return qf.toSOQL();
		}

		public List<Account> selectAccountWithOpportunities(){
			return Database.query(createSelectAccountWithOpportunitiesSOQL());
		}
	}

	private class ContractSelector extends fflib_SObjectSelector{
		public ContractSelector(){
			super(false,DataAccess.SYSTEM_MODE);
		}

		public Schema.SObjectType getSObjectType(){
			return Contract.SObjectType;
		}

		public List<Schema.SObjectField> getSObjectFieldList(){
			return new List<Schema.SObjectField> {
					Contract.Id,
					Contract.ContractNumber
			};
		}
	}

	private class ListEmailSelector extends fflib_SObjectSelector{
		public ListEmailSelector(){
			super(false,DataAccess.SYSTEM_MODE);
		}

		public Schema.SObjectType getSObjectType(){
			return ListEmail.SObjectType;
		}

		public List<Schema.SObjectField> getSObjectFieldList(){
			return new List<Schema.SObjectField> {
					ListEmail.Id,
					ListEmail.Name
			};
		}
	}

	private class TaskSelector extends fflib_SObjectSelector{
		public TaskSelector(){
			super(false,DataAccess.SYSTEM_MODE);
		}

		public Schema.SObjectType getSObjectType(){
			return Task.SObjectType;
		}

		public List<Schema.SObjectField> getSObjectFieldList(){
			return new List<Schema.SObjectField> {
					Task.Id,
					Task.Subject
			};
		}
	}

	/**
	 * Create test user
	 **/
	private static User createChatterExternalUser()
	{
		// Can only proceed with test if we have a suitable profile - Chatter External license has no access to Opportunity
		List<Profile> testProfiles = [SELECT Id FROM Profile WHERE UserLicense.Name='Chatter External' LIMIT 1];
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

	private static User getMinimumAccessUser(){
		return fflib_SecurityUtilsTest.setupTestUser(true);
	}

	@IsTest
	static void toSOQL_When_PolymorphicSelect_Expect_RelatedType() {
		//Given		

		CaseCommentSelector ccSelector = new CaseCommentSelector(fflib_SObjectSelector.DataAccess.LEGACY);
		CaseSelector caseSelector = new CaseSelector();
		UserSelector userSelector = new UserSelector();
		fflib_QueryFactory qf = ccSelector.newQueryFactory();
		caseSelector.configureQueryFactoryFields(qf, 'Parent');
		userSelector.configureQueryFactoryFields(qf, 'Parent.Owner');


		Set<String> expectedSelectFields = new Set<String>{
				'Id', 'CommentBody', 'Parent.Id', 'Parent.OwnerId', 'Parent.Owner.Id', 'Parent.Owner.UserRoleId'
		};
		if (ccSelector.isCurrencyIsoCodeAvailable()) {
			expectedSelectFields.add('CurrencyIsoCode');
		}
		if (caseSelector.isCurrencyIsoCodeAvailable()) {
			expectedSelectFields.add('Parent.CurrencyIsoCode');
		}
		if (userSelector.isCurrencyIsoCodeAvailable()) {
			expectedSelectFields.add('Parent.Owner.CurrencyIsoCode');
		}

		//When
		String soql = qf.toSOQL();

		//Then
		Pattern soqlPattern = Pattern.compile(String.format('SELECT (.*) FROM CaseComment ORDER BY {0} ASC NULLS FIRST ',
		new List<String>{ccSelector.getOrderBy()}));
		Matcher soqlMatcher = soqlPattern.matcher(soql);
		soqlMatcher.matches();

		List<String> actualSelectFields = soqlMatcher.group(1).deleteWhiteSpace().split(',');
		System.assertEquals(expectedSelectFields, new Set<String>(actualSelectFields));
	}

	@IsTest
	static void toSOQL_When_PolymorphicSelectInMulticurrency_Expect_RelatedType() {
		//Given

		CaseCommentSelector ccSelector = new CaseCommentSelector(fflib_SObjectSelector.DataAccess.LEGACY);
		CaseSelector caseSelector = new CaseSelector();
		GroupSelector groupSelector = new GroupSelector();
		fflib_QueryFactory qf = ccSelector.newQueryFactory();
		caseSelector.configureQueryFactoryFields(qf, 'Parent');
		groupSelector.configureQueryFactoryFields(qf, 'Parent.Owner');


		Set<String> expectedSelectFields = new Set<String>{
			'Id', 'CommentBody', 'Parent.Id', 'Parent.OwnerId', 'Parent.Owner.Id'
		};
		Set<String> unexpectedSelectFields = new Set<String>();
		if (ccSelector.isCurrencyIsoCodeAvailable()) {
			expectedSelectFields.add('CurrencyIsoCode');
		}
		if (caseSelector.isCurrencyIsoCodeAvailable()) {
			expectedSelectFields.add('Parent.CurrencyIsoCode');
		}
		// Group does NOT have CurrencyIsoCode field
		unexpectedSelectFields.add('Parent.Owner.CurrencyIsoCode');

		//When
		String soql = qf.toSOQL();
		System.debug(soql);

		//Then
		Pattern soqlPattern = Pattern.compile('SELECT (.*) FROM CaseComment ORDER BY CreatedDate ASC NULLS FIRST ');
		Matcher soqlMatcher = soqlPattern.matcher(soql);
		soqlMatcher.matches();

		List<String> actualSelectFields = soqlMatcher.group(1).deleteWhiteSpace().split(',');
		Set<String> actualSelectFieldsSet = new Set<String>(actualSelectFields);
		Assert.areEqual(expectedSelectFields, actualSelectFieldsSet);
		if (unexpectedSelectFields.size() > 0) {
			Assert.isFalse(
				actualSelectFieldsSet.containsAll(unexpectedSelectFields),
				String.format('The fields {0} were not expected on actualSelectFieldsSet {1}', new List<Set<String>>{unexpectedSelectFields, actualSelectFieldsSet})
			);
		}
	}

	@IsTest
	static void toSOQL_When_SystemModePolymorphicSelect_Expect_RelatedType() {
		CaseCommentSelector ccSelector = new CaseCommentSelector(fflib_SObjectSelector.DataAccess.SYSTEM_MODE);
		CaseSelector caseSelector = new CaseSelector();
		UserSelector userSelector = new UserSelector();
		fflib_QueryFactory qf = ccSelector.newQueryFactory();
		caseSelector.configureQueryFactoryFields(qf, 'Parent');
		userSelector.configureQueryFactoryFields(qf, 'Parent.Owner');

		List<String> expectedSelectFields = new List<String>();
		expectedSelectFields.add('id');
		expectedSelectFields.add('commentbody');
		if (ccSelector.isCurrencyIsoCodeAvailable()) {
			expectedSelectFields.add('currencyisocode');
		}
		expectedSelectFields.add('parent.ownerid');
		expectedSelectFields.add('parent.id');
		if (caseSelector.isCurrencyIsoCodeAvailable()) {
			expectedSelectFields.add('parent.currencyisocode');
		}
		expectedSelectFields.add('parent.owner.userroleid');
		expectedSelectFields.add('parent.owner.id');
		if (userSelector.isCurrencyIsoCodeAvailable()) {
			expectedSelectFields.add('parent.owner.currencyisocode');
		}

		String expectedSOQL = String.format('SELECT ' + String.join(expectedSelectFields,', ') + ' FROM CaseComment WITH SYSTEM_MODE ORDER BY {0} ASC NULLS FIRST ',
			new List<String>{ccSelector.getOrderBy()});

		//When
		String actualSOQL = qf.toSOQL();

		//Then
		System.assertEquals(expectedSOQL, actualSOQL);
	}

	@IsTest
	static void toSOQL_When_GreatGreatGrandchildRelationships_Expect_WelformedSOQL(){
		AccessLevelAccountSelector aSel = new AccessLevelAccountSelector();
		fflib_QueryFactory aQF = aSel.newQueryFactory();

		ContractSelector cSel = new ContractSelector();
		fflib_QueryFactory cQF = cSel.addQueryFactorySubselect(aQF);

		AccessLevelOpportunitySelector oppSel = new AccessLevelOpportunitySelector();
		fflib_QueryFactory oppQF = oppSel.addQueryFactorySubselect(cQF);

		ListEmailSelector listEmailSel = new ListEmailSelector();
		fflib_QueryFactory listEmailQF = listEmailSel.addQueryFactorySubselect(oppQF);

		TaskSelector tSel = new TaskSelector();
		fflib_QueryFactory tQF = tSel.addQueryFactorySubselect(listEmailQF);

	String expected = String.format(
		'SELECT name, id, annualrevenue, accountnumber{0}, ' +
			'(SELECT id, contractnumber{1}, ' +
				'(SELECT name, id, amount, closedate{2}, ' +
					'(SELECT id, name{3}, ' +
						'(SELECT id, subject{4} FROM Tasks ORDER BY {5} ASC NULLS FIRST )  ' +
					'FROM ListEmails ORDER BY {6} ASC NULLS FIRST )  ' +
				'FROM Opportunities ORDER BY {7} ASC NULLS FIRST )  ' +
			'FROM Contracts ORDER BY {8} ASC NULLS FIRST )  ' +
		'FROM Account WITH USER_MODE ORDER BY {9} ASC NULLS FIRST ',
		new List<String>{
			aSel.isCurrencyIsoCodeAvailable() ? ', currencyisocode' : '',
			cSel.isCurrencyIsoCodeAvailable() ? ', currencyisocode' : '',
			oppSel.isCurrencyIsoCodeAvailable() ? ', currencyisocode' : '',
			listEmailSel.isCurrencyIsoCodeAvailable() ? ', currencyisocode' : '',
			tSel.isCurrencyIsoCodeAvailable() ? ', currencyisocode' : '',
			tSel.getOrderBy(), listEmailSel.getOrderBy(), oppSel.getOrderBy(), cSel.getOrderBy(), aSel.getOrderBy()
		}
	);

		Assert.areEqual(expected,aQF.toSOQL());
	}

	private class CaseCommentSelector extends fflib_SObjectSelector {
		public CaseCommentSelector(DataAccess access) {
			super(false, access);
		}

		public List<Schema.SObjectField> getSObjectFieldList() {
			return new List<Schema.SObjectField>{
					CaseComment.Id,
					CaseComment.CommentBody
			};
		}

		public Schema.SObjectType getSObjectType() {
			return CaseComment.sObjectType;
		}
	}

	private class CaseSelector extends fflib_SObjectSelector {
		public CaseSelector() {
			super();
		}

		public List<Schema.SObjectField> getSObjectFieldList() {
			return new List<Schema.SObjectField>{
					Case.OwnerId,
					Case.Id
			};
		}

		public Schema.SObjectType getSObjectType() {
			return Case.sObjectType;
		}
	}

	private class UserSelector extends fflib_SObjectSelector {
		public UserSelector() {
			super();
		}

		public List<Schema.SObjectField> getSObjectFieldList() {
			return new List<Schema.SObjectField>{
					User.UserRoleId,
					User.Id
			};
		}

		public Schema.SObjectType getSObjectType() {
			return User.sObjectType;
		}
	}

	private class GroupSelector extends fflib_SObjectSelector {
		public GroupSelector() {
			super();
		}

		public List<Schema.SObjectField> getSObjectFieldList() {
			return new List<Schema.SObjectField>{
				Group.Id
			};
		}

		public Schema.SObjectType getSObjectType() {
			return Group.sObjectType;
		}
	}	
}
