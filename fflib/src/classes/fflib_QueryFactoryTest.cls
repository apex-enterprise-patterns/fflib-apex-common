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
			fflib_QueryFactory.QueryField qfld = new fflib_QueryFactory.QueryField(Contact.SObjectType, sObjectFields);
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
			fflib_QueryFactory.QueryField qfld = new fflib_QueryFactory.QueryField(Contact.SObjectType, sObjectField);
		} catch (Exception ex) {
			e = ex;
		}	  
		System.assertNotEquals(null,e);
	}

	@isTest
	static void invalidFields_queryFieldsNotEquals(){
		Exception e;
		Schema.SObjectField sObjectField;
		fflib_QueryFactory.QueryField qfld = new fflib_QueryFactory.QueryField(Contact.SObjectType, Contact.Name);
		fflib_QueryFactory.QueryField qfld2 = new fflib_QueryFactory.QueryField(Contact.SObjectType, Contact.LastName);
		System.assert(!qfld.equals(qfld2));	
	}

	@isTest
	static void queryIdFieldNotEquals(){
		//this is the equivalent of calling setField('account.name'), where table = Contact
		fflib_QueryFactory.QueryField qfld = new fflib_QueryFactory.QueryField(Contact.SObjectType, new List<Schema.SObjectField>{
			Schema.Contact.SObjectType.fields.AccountId,
			Schema.Account.SObjectType.fields.name
		});
		String fldString = qfld.toString();
	}

	@isTest
	static void queryIdFieldNotEqualsWrongObjType(){
		fflib_QueryFactory.QueryField qfld = new fflib_QueryFactory.QueryField(Contact.SObjectType, new List<Schema.SObjectField>{
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
		qf.selectField('name');
		qf.selectField('Id');
		qf.setCondition( 'name like \'%test%\'' );
		qf.addOrdering( new fflib_QueryFactory.Ordering('Contact','name',fflib_QueryFactory.SortOrder.ASCENDING) ).addOrdering( new fflib_QueryFactory.Ordering('Contact','CreatedDate',fflib_QueryFactory.SortOrder.DESCENDING) );
		Schema.DescribeSObjectResult descResult = Contact.SObjectType.getDescribe();
       	ChildRelationship relationship;
        for (Schema.ChildRelationship childRow : descResult.getChildRelationships()) {
            if (childRow.getRelationshipName() == 'Tasks') {
                relationship = childRow;
            }
        }
		fflib_QueryFactory childQf = qf.subselectQuery(relationship);
		childQf.selectField('Id');
		childQf.selectField('Subject');
		List<fflib_QueryFactory> queries = qf.getSubselectQueries();
		System.assert(queries != null);
		String query = qf.toSOQL();
		List<Contact> contacts = Database.query(query);
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
		qf.addOrdering( new fflib_QueryFactory.Ordering('Contact','name',fflib_QueryFactory.SortOrder.ASCENDING) ).addOrdering( new fflib_QueryFactory.Ordering('Contact','CreatedDate',fflib_QueryFactory.SortOrder.DESCENDING) );
		Schema.DescribeSObjectResult descResult = Contact.SObjectType.getDescribe();
       	ChildRelationship relationship;
        for (Schema.ChildRelationship childRow : descResult.getChildRelationships()) {
            if (childRow.getRelationshipName() == 'Tasks') {
                relationship = childRow;
            }
        }
        System.assert(qf.getSubselectQueries() == null);
		fflib_QueryFactory childQf = qf.subselectQuery(relationship);
		fflib_QueryFactory childQf2 = qf.subselectQuery(relationship);
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
		qf.addOrdering( new fflib_QueryFactory.Ordering('Contact','name',fflib_QueryFactory.SortOrder.ASCENDING) ).addOrdering( new fflib_QueryFactory.Ordering('Contact','CreatedDATE',fflib_QueryFactory.SortOrder.DESCENDING) );
		Schema.DescribeSObjectResult descResult = Account.SObjectType.getDescribe();
       	ChildRelationship relationship;
        for (Schema.ChildRelationship childRow : descResult.getChildRelationships()) {
            if (childRow.getRelationshipName() == 'Contacts') {
                relationship = childRow;
            }
        }
        Exception e;
		try {
			fflib_QueryFactory childQf = qf.subselectQuery(relationship);
			childQf.selectField('Id');
		} catch (Exception ex) {
			e = ex;
		}	
		System.assertNotEquals(e, null);
		System.assert(e.getMessage().containsIgnoreCase('Invalid relationship'));
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
		qf.addOrdering( new fflib_QueryFactory.Ordering('Contact','name',fflib_QueryFactory.SortOrder.ASCENDING) ).addOrdering( new fflib_QueryFactory.Ordering('Contact','CreatedDATE',fflib_QueryFactory.SortOrder.DESCENDING) );
		Schema.DescribeSObjectResult descResult = Contact.SObjectType.getDescribe();
       	ChildRelationship relationship;
        for (Schema.ChildRelationship childRow : descResult.getChildRelationships()) {
            if (childRow.getRelationshipName() == 'Tasks') {
                relationship = childRow;
            }
        }
		fflib_QueryFactory childQf = qf.subselectQuery(relationship);
		childQf.selectField('Id');
		childQf.selectField('Subject');
		Exception e;
		try {
			fflib_QueryFactory subChildQf = childQf.subselectQuery(relationship);
		} catch (Exception ex) {
			e = ex;
		}	
		System.assertNotEquals(e, null);
		System.assert(e.getMessage().containsIgnoreCase('invalid'));
		System.assert(e.getMessage().containsIgnoreCase('subselect query'));
	}
}