/**
 * Copyright (c) 2014, FinancialForce.com, inc
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

@isTest
private class fflib_QueryFactoryTest {
	@isTest
	static void simpleFieldSelection() {
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType);
		qf.selectField('NAMe').selectFields( new Set<String>{'naMe', 'email'});
		String query = qf.toSOQL();
		System.assert( Pattern.matches('SELECT.*Name.*FROM.*',query), 'Expected Name field in query, got '+query);
		System.assert( Pattern.matches('SELECT.*Email.*FROM.*',query), 'Expected Name field in query, got '+query);
		qf.setLimit(100);
		System.assertEquals(100,qf.getLimit());
		System.assert( qf.toSOQL().endsWithIgnoreCase('LIMIT '+qf.getLimit()), 'Failed to respect limit clause:'+qf.toSOQL() );
	}

	@isTest
	static void fieldSelections(){
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType);
		qf.selectField('firstName');
		qf.selectField(Schema.Contact.SObjectType.fields.lastName);
		qf.selectFields( new Set<String>{'acCounTId', 'account.name'} );
		qf.selectFields( new List<String>{'homePhonE','fAX'} );
		qf.selectFields( new List<Schema.SObjectField>{ Contact.Email, Contact.Title } );
	}

	@isTest
	static void simpleFieldCondition(){
		String whereClause = 'name = \'test\'';
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType);
		qf.selectField('name');
		qf.selectField('email');
		qf.setCondition( whereClause );
		System.assertEquals(whereClause,qf.getCondition()); 
		String query = qf.toSOQL();
		System.assert(query.endsWith('WHERE name = \'test\''),'Query should have ended with a filter on name, got: '+query);
	}

	@isTest
	static void duplicateFieldSelection() {
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType);
		qf.selectField('NAMe').selectFields( new Set<String>{'naMe', 'email'});
		String query = qf.toSOQL();
		System.assertEquals(1, query.countMatches('Name'), 'Expected one name field in query: '+query );
	}

	@isTest
	static void equalityCheck(){
		fflib_QueryFactory qf1 = new fflib_QueryFactory(Contact.SObjectType);
		fflib_QueryFactory qf2 = new fflib_QueryFactory(Contact.SObjectType);
		System.assertEquals(qf1,qf2);
		qf1.selectField('name');
		System.assertNotEquals(qf1,qf2);
		qf2.selectField('NAmE');
		System.assertEquals(qf1,qf2);
		qf1.selectField('name').selectFields( new Set<String>{ 'NAME', 'name' }).selectFields( new Set<Schema.SObjectField>{ Contact.Name, Contact.Name} );
		System.assertEquals(qf1,qf2);
	}

	@isTest
	static void nonReferenceField(){
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType);
		fflib_QueryFactory.NonReferenceFieldException e;
		try{
			qf.selectField('name.title');
		}catch(fflib_QueryFactory.NonReferenceFieldException ex){
			e = ex;
		}
		System.assertNotEquals(null,e,'Cross-object notation on a non-reference field should throw NonReferenceFieldException.');
	}

	@isTest
	static void invalidCrossObjectField(){
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType);
		fflib_QueryFactory.InvalidFieldException e;
		try{
			qf.selectField('account.NOT_A_REAL_FIELD');
		}catch(fflib_QueryFactory.InvalidFieldException ex){
			e = ex;
		}
		System.assertNotEquals(null,e,'Cross-object notation on a non-reference field should throw NonReferenceFieldException.');
	}

	@isTest
	static void invalidFieldTests(){
		List<Exception> exceptions = new List<Exception>();
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType);
		try{
			qf.selectField('Not_a_field');
		}catch(fflib_QueryFactory.InvalidFieldException e){
			exceptions.add(e);
		}
		try{
			qf.selectFields( new Set<String>{ 'Not_a_field','alsoNotreal'});
		}catch(fflib_QueryFactory.InvalidFieldException e){
			exceptions.add(e);
		}
		try{
			qf.selectFields( new Set<Schema.SObjectField>{ null });
		}catch(fflib_QueryFactory.InvalidFieldException e){
			exceptions.add(e);
		}
		try{
			qf.selectFields( new List<Schema.SObjectField>{ null, Contact.title });
		}catch(fflib_QueryFactory.InvalidFieldException e){
			exceptions.add(e);
		}
		System.assertEquals(4,exceptions.size());
	}

	@isTest
	static void ordering(){
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType);
		qf.selectField('name');
		qf.selectField('email');
		qf.setCondition( 'name = \'test\'' );
		qf.addOrdering( new fflib_QueryFactory.Ordering('Contact','name',fflib_QueryFactory.SortOrder.ASCENDING) ).addOrdering( new fflib_QueryFactory.Ordering('Contact','CreatedDATE',fflib_QueryFactory.SortOrder.DESCENDING) );
		String query = qf.toSOQL();

		System.assertEquals(2,qf.getOrderings().size());
		System.assertEquals(Contact.name,qf.getOrderings()[0].getField() );
		System.assertEquals(fflib_QueryFactory.SortOrder.DESCENDING,qf.getOrderings()[1].getDirection() );

		
		System.assert( Pattern.matches('SELECT.*Name.*FROM.*',query), 'Expected Name field in query, got '+query);
		System.assert( Pattern.matches('SELECT.*Email.*FROM.*',query), 'Expected Name field in query, got '+query);
	}

	@isTest
	static void invalidField_string(){
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType);
		qf.selectField('name');
		Exception e;
		try{
			qf.selectField('not_a__field');
		}catch(fflib_QueryFactory.InvalidFieldException ex){
			e = ex;
		}
		System.assertNotEquals(null,e);
	}

	@isTest
	static void invalidFields_string(){
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType);
		qf.selectField('name');
		Exception e; 
		try{
			qf.selectFields( new List<String>{'not_a__field'} );
		}catch(fflib_QueryFactory.InvalidFieldException ex){
			e = ex;
		}
		System.assertNotEquals(null,e);
	}

	@isTest
	static void invalidField_nullToken(){
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType);
		qf.selectField('name');
		Exception e;
		Schema.SObjectField token = null;
		try{
			qf.selectField( token );
		}catch(fflib_QueryFactory.InvalidFieldException ex){
			e = ex;
		}
		System.assertNotEquals(null,e);
	}

	@isTest
	static void invalidFields_nullToken(){
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType);
		qf.selectField('name');
		Exception e;
		List<Schema.SObjectField> token = new List<Schema.SObjectField>{
			null
		};
		try{
			qf.selectFields( token );
		}catch(fflib_QueryFactory.InvalidFieldException ex){
			e = ex;
		}
		System.assertNotEquals(null,e);
	}

	@isTest
	static void invalidFields_noQueryFields(){
		Exception e;
		List<Schema.SObjectField> sObjectFields = new List<Schema.SObjectField>();
		try {
			fflib_QueryFactory.QueryField qfld = new fflib_QueryFactory.QueryField(sObjectFields);
		} catch (Exception ex) {
			e = ex;
		}	  
		System.assertNotEquals(null,e);
	}
  
	@isTest
	static void invalidFields_noQueryField(){
		Exception e;
		Schema.SObjectField sObjectField;
		try {
			fflib_QueryFactory.QueryField qfld = new fflib_QueryFactory.QueryField(sObjectField);
		} catch (Exception ex) {
			e = ex;
		}	  
		System.assertNotEquals(null,e);
	}

	@isTest
	static void invalidFields_queryFieldsNotEquals(){
		Exception e;
		Schema.SObjectField sObjectField;
		fflib_QueryFactory.QueryField qfld = new fflib_QueryFactory.QueryField(Contact.Name);
		fflib_QueryFactory.QueryField qfld2 = new fflib_QueryFactory.QueryField(Contact.LastName);
		System.assert(!qfld.equals(qfld2));	
	}

	@isTest
	static void queryIdFieldNotEquals(){
		//this is the equivalent of calling setField('account.name'), where table = Contact
		fflib_QueryFactory.QueryField qfld = new fflib_QueryFactory.QueryField(new List<Schema.SObjectField>{
			Schema.Contact.SObjectType.fields.AccountId,
			Schema.Account.SObjectType.fields.name
		});
		String fldString = qfld.toString();
	}

	@isTest
	static void queryIdFieldNotEqualsWrongObjType(){
		fflib_QueryFactory.QueryField qfld = new fflib_QueryFactory.QueryField(new List<Schema.SObjectField>{
			Schema.Contact.SObjectType.fields.AccountId});
		System.assert(!qfld.equals(new Contact()));	
	}

	@isTest
	static void addChildQueries_success(){
		Account acct = new Account();
		acct.Name = 'testchildqueriesacct';
		insert acct;
		Contact cont = new Contact();
		cont.FirstName = 'test';
		cont.LastName = 'test';
		cont.AccountId = acct.Id;
		insert cont;
        Task tsk = new Task();
        tsk.WhoId = cont.Id;
        tsk.Subject = 'test';
        tsk.ActivityDate = System.today();
        insert tsk;

		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType);
		qf.selectField('name').selectField('Id').setCondition( 'name like \'%test%\'' ).addOrdering('CreatedDate',fflib_QueryFactory.SortOrder.DESCENDING, true);
		Schema.DescribeSObjectResult descResult = Contact.SObjectType.getDescribe();
		//explicitly assert object accessibility when creating the subselect
		qf.subselectQuery(Task.SObjectType, true).selectField('Id').selectField('Subject').setCondition(' IsDeleted = false ');
		List<fflib_QueryFactory> queries = qf.getSubselectQueries();
		System.assert(queries != null);
		List<Contact> contacts = Database.query(qf.toSOQL());
		System.assert(contacts != null && contacts.size() == 1);
		System.assert(contacts[0].Tasks.size() == 1);
		System.assert(contacts[0].Tasks[0].Subject == 'test');
	}

	@isTest
	static void addChildQuerySameRelationshipAgain_success(){
		Account acct = new Account();
		acct.Name = 'testchildqueriesacct';
		insert acct;
		Contact cont = new Contact();
		cont.FirstName = 'test';
		cont.LastName = 'test';
		cont.AccountId = acct.Id;
		insert cont;
        Task tsk = new Task();
        tsk.WhoId = cont.Id;
        tsk.Subject = 'test';
        tsk.ActivityDate = System.today();
        insert tsk;
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType);
		qf.selectField('name');
		qf.selectField('Id');
		qf.setCondition( 'name like \'%test%\'' );
		qf.addOrdering( new fflib_QueryFactory.Ordering('Contact','name',fflib_QueryFactory.SortOrder.ASCENDING) ).addOrdering('CreatedBy.Name',fflib_QueryFactory.SortOrder.DESCENDING);
		Schema.DescribeSObjectResult descResult = Contact.SObjectType.getDescribe();
       	ChildRelationship relationship;
        for (Schema.ChildRelationship childRow : descResult.getChildRelationships()) {
            if (childRow.getRelationshipName() == 'Tasks') {
                relationship = childRow;
            }
        }
        System.assert(qf.getSubselectQueries() == null);
		fflib_QueryFactory childQf = qf.subselectQuery(Task.SObjectType);
		childQf.assertIsAccessible();
		childQf.setEnforceFLS(true);
		childQf.selectField('Id');
		fflib_QueryFactory childQf2 = qf.subselectQuery(Task.SObjectType);
		List<fflib_QueryFactory> queries = qf.getSubselectQueries();
		System.assert(queries != null);
		System.assert(queries.size() == 1);
	}

	@isTest
	static void addChildQueries_invalidChildRelationship(){
		Account acct = new Account();
		acct.Name = 'testchildqueriesacct';
		insert acct;
		Contact cont = new Contact();
		cont.FirstName = 'test';
		cont.LastName = 'test';
		cont.AccountId = acct.Id;
		insert cont;
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType);
		qf.selectField('name');
		qf.selectField('email');
		qf.setCondition( 'name like \'%test%\'' );
		qf.addOrdering( new fflib_QueryFactory.Ordering('Contact','name',fflib_QueryFactory.SortOrder.ASCENDING) ).addOrdering( 'CreatedDATE',fflib_QueryFactory.SortOrder.DESCENDING);
		Schema.DescribeSObjectResult descResult = Account.SObjectType.getDescribe();
        Exception e;
		try {
			fflib_QueryFactory childQf = qf.subselectQuery(Contact.SObjectType);
			childQf.selectField('Id');
		} catch (fflib_QueryFactory.InvalidSubqueryRelationshipException ex) {
			e = ex;
		}	
		System.assertNotEquals(e, null);
	}

	@isTest
	static void addChildQueries_invalidChildRelationshipTooDeep(){
		Account acct = new Account();
		acct.Name = 'testchildqueriesacct';
		insert acct;
		Contact cont = new Contact();
		cont.FirstName = 'test';
		cont.LastName = 'test';
		cont.AccountId = acct.Id;
		insert cont;
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType);
		qf.selectField('name');
		qf.selectField('email');
		qf.setCondition( 'name like \'%test%\'' );
		qf.addOrdering( new fflib_QueryFactory.Ordering('Contact','name',fflib_QueryFactory.SortOrder.ASCENDING) ).addOrdering('CreatedDATE',fflib_QueryFactory.SortOrder.DESCENDING);
		Schema.DescribeSObjectResult descResult = Contact.SObjectType.getDescribe();
  
		fflib_QueryFactory childQf = qf.subselectQuery(Task.SObjectType);
		childQf.selectField('Id');
		childQf.selectField('Subject');
		Exception e;
		try {
			fflib_QueryFactory subChildQf = childQf.subselectQuery(Task.SObjectType);
		} catch (fflib_QueryFactory.InvalidSubqueryRelationshipException ex) {
			e = ex;   
		}	
		System.assertNotEquals(e, null);
	}

	@isTest
	static void checkFieldObjectReadSort_success(){
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType);
		qf.assertIsAccessible()
		  .setEnforceFLS(true) 
		  .selectField('createdby.name')
		  .selectField(Contact.LastModifiedById)
		  .selectFields(new List<SObjectField>{Contact.LastModifiedDate})
		  .setEnforceFLS(false)
		  .selectField(Contact.LastName)
		  .selectFields(new List<SObjectField>{Contact.Id})
		  .setCondition( 'name like \'%test%\'' )
		  .setEnforceFLS(true)
		  .selectFields(new Set<SObjectField>{Contact.FirstName})
		  .addOrdering(new fflib_QueryFactory.Ordering('Contact','name',fflib_QueryFactory.SortOrder.ASCENDING) )
		  .addOrdering(Contact.LastModifiedDate,fflib_QueryFactory.SortOrder.DESCENDING)
		  .addOrdering(Contact.CreatedDate,fflib_QueryFactory.SortOrder.DESCENDING, true);
		Set<fflib_QueryFactory.QueryField> fields = qf.getSelectedFields();  
		fflib_QueryFactory.Ordering ordering = new fflib_QueryFactory.Ordering('Contact','name',fflib_QueryFactory.SortOrder.ASCENDING);
		ordering.getFields();
		for (fflib_QueryFactory.QueryField qfRow : fields) {
			SObjectField fld = qfRow.getBaseField();
			List<SObjectfield> flds = qfRow.getFieldPath(); 
			break;
		}
		System.assert(qf.toSOQL().containsIgnoreCase('NULLS LAST'));
	}

	@isTest
	static void checkObjectRead_fail(){
		User usr = createTestUser_noAccess();
		if (usr != null){
			System.runAs(usr){
				//create a query factory object for Account.  
				fflib_QueryFactory qf = new fflib_QueryFactory(Account.SObjectType);
				Boolean excThrown = false;
				try {
					//check to see if this record is accessible, it isn't.
					qf.assertIsAccessible();
				} catch (fflib_SecurityUtils.CrudException e) {
					excThrown = true;
				}	
				System.assert(excThrown);
			}	
		}	
	}  

	@isTest
	static void checkFieldRead_fail(){		
		User usr = createTestUser_noAccess();
		if (usr != null){
			System.runAs(usr){
				//create a query factory object for Account. 
				fflib_QueryFactory qf = new fflib_QueryFactory(Account.SObjectType);
				Boolean excThrown = false;
				try {
					//set field to enforce FLS, then try to add a field.  
					qf.setEnforceFLS(true);
					qf.selectField('Name');
				} catch (fflib_SecurityUtils.FlsException e) {
					excThrown = true;
				}	
				System.assert(excThrown);
			}	
		}	
	}

	@isTest
	static void queryWith_noFields(){
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType);
		qf.assertIsAccessible().setEnforceFLS(true).setCondition( 'name like \'%test%\'' ).addOrdering('CreatedDate',fflib_QueryFactory.SortOrder.DESCENDING);
		String query = qf.toSOQL();
		System.assert(query.containsIgnoreCase('Id FROM'));
	}  

	public static User createTestUser_noAccess(){
		User usr;
		try {
			//look for a profile that does not have access to the Account object
			PermissionSet ps = 
			[SELECT Profile.Id, profile.name
				FROM PermissionSet
				WHERE IsOwnedByProfile = true
				AND Profile.UserType = 'Standard'
				AND Id NOT IN (SELECT ParentId
				               FROM ObjectPermissions
				               WHERE SObjectType = 'Account'
				               AND PermissionsRead = true)
				LIMIT 1];
			
			if (ps != null){
				//create a user with the profile found that doesn't have access to the Account object
				usr = new User(
				    firstName = 'testUsrF',
				    LastName = 'testUsrL',
				    Alias = 'tstUsr',
				    Email = 'testy.test@test.com',
				    UserName='test'+ Math.random().format()+'user99@test.com',
				    EmailEncodingKey = 'ISO-8859-1',
				    LanguageLocaleKey = 'en_US',
				    TimeZoneSidKey = 'America/Los_Angeles',
				    LocaleSidKey = 'en_US',
				    ProfileId = ps.Profile.Id,
				    IsActive=true
				    );
				insert usr;
			}
		} catch (Exception e) {
			//do nothing, just return null User because this test case won't work in this org.
			return null;
		}	
		return usr;	
	}
}