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
		Testfflib_SObjectSelector selector = new Testfflib_SObjectSelector();
		Assert.areEqual(null, selector.getSObjectFieldSetList());
		Assert.areEqual('Account',selector.getSObjectName());
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
		
		Assert.areEqual(2,result.size());
		Assert.areEqual('TestAccount2',result[0].Name);
		Assert.areEqual('A2',result[0].AccountNumber);
		Assert.areEqual(12345.67,result[0].AnnualRevenue);
		Assert.areEqual('TestAccount1',result[1].Name);
		Assert.areEqual('A1',result[1].AccountNumber);
		Assert.areEqual(76543.21,result[1].AnnualRevenue);
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

		Assert.isTrue(true, String.valueOf(iteratorResult.hasNext()));
		Account account = (Account) iteratorResult.next();
		Assert.areEqual('TestAccount2',account.Name);
		Assert.areEqual('A2',account.AccountNumber);
		Assert.areEqual(12345.67,account.AnnualRevenue);
		Assert.isTrue(true, String.valueOf(iteratorResult.hasNext()));
		account = (Account) iteratorResult.next();
		Assert.areEqual('TestAccount1',account.Name);
		Assert.areEqual('A1',account.AccountNumber);
		Assert.areEqual(76543.21,account.AnnualRevenue);
		Assert.areEqual(false, iteratorResult.hasNext());
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
				Assert.isTrue(false,'Expected exception was not thrown');
			}
			catch(fflib_SObjectDomain.DomainException e)
			{
				Assert.areEqual('Permission to access an Account denied.',e.getMessage());
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
				Assert.isTrue(false,'Did not expect an exception to be thrown');
			}
		}
	}
	
	static testMethod void testSOQL()
	{
		Testfflib_SObjectSelector selector = new Testfflib_SObjectSelector();
		String soql = selector.newQueryFactory().toSOQL();
		Pattern p = Pattern.compile('SELECT (.*) FROM Account ORDER BY Name DESC NULLS FIRST , AnnualRevenue ASC NULLS LAST ');
		Matcher m = p.matcher(soql);
		Assert.isTrue(m.matches(), 'Generated SOQL does not match expected pattern. Here is the generated SOQL: ' + soql);
		Assert.areEqual(1, m.groupCount(), 'Unexpected number of groups captured.');
		String fieldListString = m.group(1);
		assertFieldListString(fieldListString, null);
	}
	
	static testMethod void testSOQL_defaultSorting()
	{
		Testfflib_SObjectSelectorDefaultSorting selector = new Testfflib_SObjectSelectorDefaultSorting(false);
		String soql = selector.newQueryFactory().toSOQL();
		Pattern p = Pattern.compile('SELECT (.*) FROM Account ORDER BY Name ASC NULLS FIRST ');
		Matcher m = p.matcher(soql);
		Assert.isTrue(m.matches(), 'Generated SOQL does not match expected pattern. Here is the generated SOQL: ' + soql);
		Assert.areEqual(1, m.groupCount(), 'Unexpected number of groups captured.');
		String fieldListString = m.group(1);
		assertFieldListString(fieldListString, null);
	}

	static testMethod void testDefaultConfig()
	{
		Testfflib_SObjectSelector selector = new Testfflib_SObjectSelector();
		Assert.areEqual(false, selector.isEnforcingFLS());
		Assert.areEqual(true, selector.isEnforcingCRUD());
		Assert.areEqual(false, selector.isIncludeFieldSetFields());
		Assert.areEqual(fflib_SObjectSelector.DataAccess.LEGACY, selector.getDataAccess());
		
		Assert.areEqual('Account', selector.getSObjectName());
		Assert.areEqual(Account.SObjectType, selector.getSObjectType2());
	}
	
	private static void assertFieldListString(String fieldListString, String prefix) {
		String prefixString = (!String.isBlank(prefix)) ? prefix + '.' : '';
		List<String> fieldList = fieldListString.split(',{1}\\s?');
		Assert.areEqual(UserInfo.isMultiCurrencyOrganization() ? 5 : 4, fieldList.size());
		Set<String> fieldSet = new Set<String>();
		fieldSet.addAll(fieldList);
		String expected = prefixString + 'AccountNumber';
		Assert.isTrue(fieldSet.contains(expected), expected + ' missing from field list string: ' + fieldListString);
		expected = prefixString + 'AnnualRevenue';
		Assert.isTrue(fieldSet.contains(expected), expected + ' missing from field list string: ' + fieldListString);
		expected = prefixString + 'Id';
		Assert.isTrue(fieldSet.contains(expected), expected + ' missing from field list string: ' + fieldListString);
		expected = prefixString + 'Name';
		Assert.isTrue(fieldSet.contains(expected), expected + ' missing from field list string: ' + fieldListString);
		if (UserInfo.isMultiCurrencyOrganization()) {
			expected = prefixString + 'CurrencyIsoCode';
			Assert.isTrue(fieldSet.contains(expected), expected + ' missing from field list string: ' + fieldListString);
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
		Assert.areEqual(expectedSelectFields, new Set<String>(actualSelectFields));
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
		Assert.isTrue(soqlMatcher.matches(), 'The SOQL should have that expected.');
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
		Assert.isTrue(soqlMatcher.matches(), 'Generated SOQL does not match expected pattern. Here is the generated SOQL: ' + soql);

		List<String> actualSelectFields = soqlMatcher.group(1).deleteWhiteSpace().split(',');
		Assert.areEqual(expectedSelectFields, new Set<String>(actualSelectFields));
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
		Assert.isTrue(soqlMatcher.matches(), 'Generated SOQL does not match expected pattern. Here is the generated SOQL: ' + soql);

		List<String> actualSelectFields = soqlMatcher.group(1).deleteWhiteSpace().split(',');
		Assert.areEqual(expectedSelectFields, new Set<String>(actualSelectFields));
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
		Assert.isTrue(soqlMatcher.matches(), 'Generated SOQL does not match expected pattern. Here is the generated SOQL: ' + soql);

		List<String> actualSelectFields = soqlMatcher.group(1).deleteWhiteSpace().split(',');
		Assert.areEqual(expectedSelectFields, new Set<String>(actualSelectFields));
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
		Assert.areEqual(expectedSelectFields, new Set<String>(actualSelectFields));
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
		Assert.areEqual(expectedSelectFields, new Set<String>(actualSelectFields));

	}

	@IsTest
	static void toSoql_When_UserModeAndUserCannnotReadObject_Expect_QueryException(){
		AccessLevelOpportunitySelector sel = new AccessLevelOpportunitySelector();

		User u = getLimitedReadOnlyUser();
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
	static void toSoql_When_SystemModeAndUserCannnotReadObject_Expect_Success(){
		AccessLevelOpportunitySelector sel = new AccessLevelOpportunitySelector(fflib_SObjectSelector.DataAccess.SYSTEM_MODE);

		User u = getLimitedReadOnlyUser();
		System.runAs(u){
			sel.selectSObjectsById(new Set<Id>{fflib_IDGenerator.generate(Opportunity.SObjectType)});
		}
	}

	@IsTest
	static void toSoql_When_UserModeAndUserCannnotReadField_Expect_QueryException(){
		AccessLevelAccountSelector sel = new AccessLevelAccountSelector();

		//Account has Read access by the limited read only user but no FLS access
		User u = getLimitedReadOnlyUser();
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
	static void toSoql_When_SystemModeAndUserCannnotReadField_Expect_Success(){
		AccessLevelAccountSelector sel = new AccessLevelAccountSelector(fflib_SObjectSelector.DataAccess.SYSTEM_MODE);

		//Account has Read access by the limited read only user but no FLS access
		User u = getLimitedReadOnlyUser();
		System.runAs(u){
			sel.selectSObjectsById(new Set<Id>{fflib_IDGenerator.generate(Account.SObjectType)});
		}
	}

	@IsTest
	static void toSoql_When_SystemModeAndParentRelationshipAndDuplicateFields_Expect_WellFormedSOQL(){
		AccessLevelOpportunitySelector sel = new AccessLevelOpportunitySelector(fflib_SObjectSelector.DataAccess.SYSTEM_MODE);

		String soql = sel.createSelectAllWithAccountSOQL();

		String expected = 'SELECT name, id, amount, closedate, account\\.name, account\\.billingpostalcode(.*)FROM Opportunity WITH SYSTEM_MODE ORDER BY Name ASC NULLS FIRST ';
		Pattern soqlPattern = Pattern.compile(expected);
		Matcher soqlMatcher = soqlPattern.matcher(soql);
		Assert.isTrue(soqlMatcher.matches(),'Expected: ' + expected + ' Actual:' + soql);
	}

	@IsTest
	static void toSoql_When_SystemModeAndChildRelationship_Expect_WellFormedSOQL(){
		AccessLevelAccountSelector sel = new AccessLevelAccountSelector(fflib_SObjectSelector.DataAccess.SYSTEM_MODE);

		String soql = sel.createSelectAccountWithOpportunitiesSOQL();

		String expected = 'SELECT name, id, annualrevenue, accountnumber,(.*)\\(SELECT name, id, amount, closedate FROM Opportunities ORDER BY Name ASC NULLS FIRST \\)  FROM Account WITH SYSTEM_MODE ORDER BY Name ASC NULLS FIRST ';
		Pattern soqlPattern = Pattern.compile(expected);
		Matcher soqlMatcher = soqlPattern.matcher(soql);
		Assert.isTrue(soqlMatcher.matches(),'Expected: ' + expected + ' Actual:' + soql);
	}

	@IsTest
	static void whenWithUserModeIsCalledDataAccessIsUserMode() {
		Testfflib_SObjectSelector selector = new Testfflib_SObjectSelector();

		selector.withUserMode();
		Assert.areEqual(fflib_SObjectSelector.DataAccess.USER_MODE, selector.getDataAccess());
	}

	@IsTest
	static void whenWithSystemModeIsCalledThenDataAccessIsSystemMode() {
		Testfflib_SObjectSelector selector = new Testfflib_SObjectSelector();

		selector.withSystemMode();
		Assert.areEqual(fflib_SObjectSelector.DataAccess.SYSTEM_MODE, selector.getDataAccess());
	}

	@IsTest
	static void whenDataAccessIsUserModeThenIsEnforcingFLSIsTrue() {
		Testfflib_SObjectSelector selector = new Testfflib_SObjectSelector();

		selector.withUserMode();
		Assert.isTrue(selector.isEnforcingFLS());
	}

	@IsTest
	static void whenDataAccessIsUserModeThenIsEnforcingCRUDIsTrue() {
		Testfflib_SObjectSelector selector = new Testfflib_SObjectSelector();

		selector.withUserMode();
		Assert.isTrue(selector.isEnforcingCRUD());
	}

	@IsTest
	static void whenDataAccessIsSystemModeThenIsEnforcingFLSIsFalse() {
		Testfflib_SObjectSelector selector = new Testfflib_SObjectSelector();

		selector.withSystemMode();
		Assert.isFalse(selector.isEnforcingFLS());
	}

	@IsTest
	static void whenDataAccessIsSystemModeThenIsEnforcingCRUDIsFalse() {
		Testfflib_SObjectSelector selector = new Testfflib_SObjectSelector();

		selector.withSystemMode();
		Assert.isFalse(selector.isEnforcingCRUD());
	}

	@IsTest
	static void whenDataAccessIsNotLegacyAndEnforceFLSIsCalledThenDataAccessIsSetToLegacy() {
		AccessLevelAccountSelector selector = new AccessLevelAccountSelector(fflib_SObjectSelector.DataAccess.USER_MODE);

		selector.enforceFLS();
		Assert.areEqual(fflib_SObjectSelector.DataAccess.LEGACY, selector.getDataAccess());
	}

	@IsTest
	static void whenDataAccessIsNotLegacyAndEnforceFLSIsCalledThenIsEnforcingCrudReturnsTrue() {
		AccessLevelAccountSelector selector = new AccessLevelAccountSelector(fflib_SObjectSelector.DataAccess.USER_MODE);

		selector.enforceFLS();
		Assert.isTrue(selector.isEnforcingCRUD());
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

			oSel.addQueryFactorySubselect(qf);

			return qf.toSOQL();
		}

		public List<Account> selectAccountWithOpportunities(){
			return Database.query(createSelectAccountWithOpportunitiesSOQL());
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

	private static User getLimitedReadOnlyUser(){
		return fflib_SecurityUtilsTest.setupTestUser('Read Only');
	}

	@isTest
	static void testPolymorphicSelectWithRelatedType() {
		//Given		

		Testfflib_CampaignMemberSelector cmSelector = new Testfflib_CampaignMemberSelector();
		fflib_QueryFactory qf = cmSelector.newQueryFactory();
		new Testfflib_LeadSelector().configureQueryFactoryFields(qf, 'Lead');
		new Testfflib_UserSelector().configureQueryFactoryFields(qf, 'Lead.Owner');


		Set<String> expectedSelectFields = new Set<String>{
				'Id', 'Status', 'Lead.Id', 'Lead.OwnerId', 'Lead.Owner.Id', 'Lead.Owner.UserRoleId'
		};
		if (UserInfo.isMultiCurrencyOrganization()) {
			expectedSelectFields.add('CurrencyIsoCode');
		}

		//When
		String soql = qf.toSOQL();

		//Then
		Pattern soqlPattern = Pattern.compile('SELECT (.*) FROM CampaignMember ORDER BY CreatedDate ASC NULLS FIRST ');
		Matcher soqlMatcher = soqlPattern.matcher(soql);
		soqlMatcher.matches();

		List<String> actualSelectFields = soqlMatcher.group(1).deleteWhiteSpace().split(',');
		Assert.areEqual(expectedSelectFields, new Set<String>(actualSelectFields));
	}

	private class Testfflib_CampaignMemberSelector extends fflib_SObjectSelector {
		public Testfflib_CampaignMemberSelector() {
			super();
		}

		public List<Schema.SObjectField> getSObjectFieldList() {
			return new List<Schema.SObjectField>{
					CampaignMember.Id,
					CampaignMember.Status
			};
		}

		public Schema.SObjectType getSObjectType() {
			return CampaignMember.sObjectType;
		}
	}

	private class Testfflib_UserSelector extends fflib_SObjectSelector {
		public Testfflib_UserSelector() {
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

	private class Testfflib_LeadSelector extends fflib_SObjectSelector {
		public Testfflib_LeadSelector() {
			super();
		}

		public List<Schema.SObjectField> getSObjectFieldList() {
			return new List<Schema.SObjectField>{
					Lead.OwnerId,
					Lead.Id
			};
		}

		public Schema.SObjectType getSObjectType() {
			return Lead.sObjectType;
		}
	}	
}
