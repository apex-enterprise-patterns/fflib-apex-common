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

@isTest
private class fflib_QueryFactoryTest {

	@isTest
	static void fieldSelections(){
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType);
		qf.selectField('firstName');
		qf.selectField(Schema.Contact.SObjectType.fields.lastName);
		qf.selectFields( new Set<String>{'acCounTId', 'account.name'} );
		qf.selectFields( new List<String>{'homePhonE','fAX'} );
		qf.selectFields( new List<Schema.SObjectField>{ Contact.Email, Contact.Title } );
		System.assertEquals(new Set<String>{
			'FirstName',
			'LastName',
			'AccountId',
			'Account.Name',
			'HomePhone',
			'Fax',
			'Email',
			'Title'},
			qf.getSelectedFields());
	}

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
		List<fflib_QueryFactory.InvalidFieldException> exceptions = new List<fflib_QueryFactory.InvalidFieldException>();
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
		System.assertEquals('Name',qf.getOrderings()[0].getField() );
		System.assertEquals(fflib_QueryFactory.SortOrder.DESCENDING,qf.getOrderings()[1].getDirection() );

		
		System.assert( Pattern.matches('SELECT.*Name.*FROM.*',query), 'Expected Name field in query, got '+query);
		System.assert( Pattern.matches('SELECT.*Email.*FROM.*',query), 'Expected Name field in query, got '+query);
	}

	@isTest
	static void setOrdering_ReplacesPreviousOrderingsWithExpectedOrdering(){
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType);
		qf.selectField('name');
		qf.selectField('email');
		qf.setCondition( 'name = \'test\'' );

		//test base method with ordeting by OwnerId Descending
		qf.setOrdering( new fflib_QueryFactory.Ordering('Contact','OwnerId',fflib_QueryFactory.SortOrder.DESCENDING) );

		System.assertEquals(1, qf.getOrderings().size(), 'Unexpected order size - setOrder should replace default Orderings');
		System.assertEquals(Contact.OwnerId.getDescribe().getName(), qf.getOrderings()[0].getField(), 'Unexpected order field - should have been resolved from the field OwnerId');
		System.assertEquals(fflib_QueryFactory.SortOrder.DESCENDING, qf.getOrderings()[0].getDirection(), 'Unexpected order direction.');

		//test method overload with ordering by LastModifiedDate Ascending
		qf.setOrdering('LastModifiedDate', fflib_QueryFactory.SortOrder.ASCENDING, true);

		System.assertEquals(1, qf.getOrderings().size(), 'Unexpected order size - setOrder should replace previous Orderings');
		System.assertEquals(Contact.LastModifiedDate.getDescribe().getName(), qf.getOrderings()[0].getField(), 'Unexpected order field - should have been resolved from the field LastModifiedDate');
		System.assertEquals(fflib_QueryFactory.SortOrder.ASCENDING, qf.getOrderings()[0].getDirection(), 'Unexpected order direction.');

		//test method overload with ordering by CreatedDate Descending
		qf.setOrdering(Contact.CreatedDate, fflib_QueryFactory.SortOrder.DESCENDING, true);

		System.assertEquals(1, qf.getOrderings().size(), 'Unexpected order size - setOrder should replace previous Orderings');
		System.assertEquals(Contact.CreatedDate.getDescribe().getName(), qf.getOrderings()[0].getField(), 'Unexpected order field - should have been resolved from the field CreatedDate');
		System.assertEquals(fflib_QueryFactory.SortOrder.DESCENDING, qf.getOrderings()[0].getDirection(), 'Unexpected order direction.');

		//test method overload with ordering by CreatedBy.Name Descending
		qf.setOrdering('CreatedBy.Name', fflib_QueryFactory.SortOrder.DESCENDING);

		System.assertEquals(1, qf.getOrderings().size(), 'Unexpected order size - setOrder should replace previous Orderings');
		System.assertEquals(fflib_QueryFactory.SortOrder.DESCENDING, qf.getOrderings()[0].getDirection(), 'Unexpected order direction.');

		//test method overload with ordering by Birthdate Ascending
		qf.setOrdering(Contact.Birthdate, fflib_QueryFactory.SortOrder.ASCENDING);

		System.assertEquals(1, qf.getOrderings().size(), 'Unexpected order size - setOrder should replace previous Orderings');
		System.assertEquals(Contact.Birthdate.getDescribe().getName(), qf.getOrderings()[0].getField(), 'Unexpected order field - should have been resolved from the field Birthdate');
		System.assertEquals(fflib_QueryFactory.SortOrder.ASCENDING, qf.getOrderings()[0].getDirection(), 'Unexpected order direction.');

		String query = qf.toSOQL();
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
	static void invalidFields_noQueryField(){
		try {
			String path = fflib_QueryFactory.getFieldTokenPath(null);
			System.assert(false,'Expected InvalidFieldException; none was thrown');
		} 
		catch (fflib_QueryFactory.InvalidFieldException ife) {
			//Expected
		}
		catch (Exception e){
			System.assert(false,'Expected InvalidFieldException; ' + e.getTypeName() + ' was thrown instead: ' + e);
		}
	}

	@isTest
	static void queryFieldsNotEquals(){
		String qfld = fflib_QueryFactory.getFieldTokenPath(Contact.Name);
		String qfld2 = fflib_QueryFactory.getFieldTokenPath(Contact.LastName);
		System.assert(!qfld.equals(qfld2));	
	}

	@isTest
	static void addChildQueriesWithChildRelationship_success(){
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType);
		qf.selectField('name').selectField('Id').setCondition('name=\'test\'').addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING, true);
		Schema.DescribeSObjectResult descResult = Contact.SObjectType.getDescribe();
		//explicitly assert object accessibility when creating the subselect
		qf.subselectQuery('Tasks', true).selectField('Id').selectField('Subject').setCondition(' IsDeleted = false ');
		List<fflib_QueryFactory> queries = qf.getSubselectQueries();
		System.assert(queries != null);
		System.assert(
				Pattern.matches('SELECT.*(SELECT.*FROM Tasks WHERE.*).*FROM Contact WHERE.*', qf.toSOQL()),
				'Incorrect returned query'
		);
	}

	@isTest
	static void addChildQueriesWithChildRelationshipNoAccessibleCheck_success(){
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType);
		qf.selectField('name').selectField('Id').setCondition('name=\'test\'').addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING, true);
		//explicitly assert object accessibility when creating the subselect
		qf.subselectQuery('Tasks').selectField('Id').selectField('Subject').setCondition(' IsDeleted = false ');
		List<fflib_QueryFactory> queries = qf.getSubselectQueries();
		System.assert(queries != null);
		System.assert(
				Pattern.matches('SELECT.*(SELECT.*FROM Tasks WHERE.*).*FROM Contact WHERE.*', qf.toSOQL()),
				'Incorrect returned query'
		);
	}

	@isTest
	static void addChildQueriesWithChildRelationshipObjCheckIsAccessible_success(){
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType);
		qf.selectField('name').selectField('Id').setCondition('name=\'test\'').addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING, true);
		Schema.DescribeSObjectResult descResult = Contact.SObjectType.getDescribe();
		Schema.ChildRelationship relationship;
		for (Schema.ChildRelationship childRow : descResult.getChildRelationships()){
        	//occasionally on some standard objects (Like Contact child of Contact) do not have a relationship name.  
        	//if there is no relationship name, we cannot query on it, so throw an exception.
            if (childRow.getRelationshipName() == 'Tasks'){ 
                relationship = childRow;
            }   
        }
       	//explicitly assert object accessibility when creating the subselect
		qf.subselectQuery(relationship, true).selectField('Id').selectField('Subject').setCondition(' IsDeleted = false ');
		List<fflib_QueryFactory> queries = qf.getSubselectQueries();
		System.assert(queries != null);
		System.assert(
				Pattern.matches('SELECT.*(SELECT.*FROM Tasks WHERE.*).*FROM Contact WHERE.*', qf.toSOQL()),
				'Incorrect returned query'
		);
	}

	@isTest
	static void addChildQueriesWithChildRelationshipObj_success(){
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType);
		qf.selectField('name').selectField('Id').setCondition( 'name=\'%test%\'' ).addOrdering('CreatedDate',fflib_QueryFactory.SortOrder.DESCENDING, true);
		Schema.DescribeSObjectResult descResult = Contact.SObjectType.getDescribe();
		Schema.ChildRelationship relationship;
		for (Schema.ChildRelationship childRow : descResult.getChildRelationships()){
        	//occasionally on some standard objects (Like Contact child of Contact) do not have a relationship name.  
        	//if there is no relationship name, we cannot query on it, so throw an exception.
            if (childRow.getRelationshipName() == 'Tasks'){ 
                relationship = childRow;
            }   
        }
       	//explicitly assert object accessibility when creating the subselect
		qf.subselectQuery(relationship).selectField('Id').selectField('Subject').setCondition(' IsDeleted = false ');
		List<fflib_QueryFactory> queries = qf.getSubselectQueries();
		System.assert(queries != null);
		System.assert(
				Pattern.matches('SELECT.*(SELECT.*FROM Tasks WHERE.*).*FROM Contact WHERE.*', qf.toSOQL()),
				'Incorrect returned query'
		);
	}

	@isTest
	static void addChildQueriesWithChildRelationshipNoAccessibleCheck_fail(){
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType);
		qf.selectField('name').selectField('Id').setCondition( 'name=\'test\'' ).addOrdering('CreatedDate',fflib_QueryFactory.SortOrder.DESCENDING, true);
		Schema.DescribeSObjectResult descResult = Contact.SObjectType.getDescribe();
		//explicitly assert object accessibility when creating the subselect
		//
		Exception e;
		try {
			qf.subselectQuery('Tas').selectField('Id').selectField('Subject').setCondition(' IsDeleted = false ');
		} catch (fflib_QueryFactory.InvalidSubqueryRelationshipException ex) {
			e = ex;   
		}	
		System.assertNotEquals(e, null);
	}

	@isTest
	static void addChildQueries_success(){
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType);
		qf.selectField('name').selectField('Id').setCondition( 'name like \'%test%\'' ).addOrdering('CreatedDate',fflib_QueryFactory.SortOrder.DESCENDING, true);
		Schema.DescribeSObjectResult descResult = Contact.SObjectType.getDescribe();
		//explicitly assert object accessibility when creating the subselect
		qf.subselectQuery(Task.SObjectType, true).selectField('Id').selectField('Subject').setCondition(' IsDeleted = false ');
		List<fflib_QueryFactory> queries = qf.getSubselectQueries();
		System.assert(queries != null);
		System.assert(
				Pattern.matches('SELECT.*(SELECT.*FROM Tasks WHERE.*).*FROM Contact WHERE.*', qf.toSOQL()),
				'Incorrect returned query'
		);
	}

	@isTest
	static void addChildQuerySameRelationshipAgain_success(){
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType);
		qf.selectField('name');
		qf.selectField('Id');
		qf.setCondition( 'name like \'%test%\'' );
		qf.addOrdering( new fflib_QueryFactory.Ordering('Contact','name',fflib_QueryFactory.SortOrder.ASCENDING) ).addOrdering('CreatedBy.Name',fflib_QueryFactory.SortOrder.DESCENDING);
		Schema.DescribeSObjectResult descResult = Contact.SObjectType.getDescribe();
       	Schema.ChildRelationship relationship;
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
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType);
		qf.selectField('name');
		qf.selectField('email');
		qf.setCondition( 'name like \'%test%\'' );
		qf.addOrdering( new fflib_QueryFactory.Ordering('Contact','name',fflib_QueryFactory.SortOrder.ASCENDING) ).addOrdering( 'CreatedDATE',fflib_QueryFactory.SortOrder.DESCENDING);
		Schema.DescribeSObjectResult descResult = Account.SObjectType.getDescribe();
        Exception e;
		try {
			SObjectType invalidType = null;
			fflib_QueryFactory childQf = qf.subselectQuery(invalidType);
			childQf.selectField('Id');
		} catch (fflib_QueryFactory.InvalidSubqueryRelationshipException ex) {
			e = ex;
		}	
		System.assertNotEquals(e, null);
	}

	@isTest
	static void addChildQueries_invalidChildRelationshipTooDeep(){
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
		Set<String> fields = qf.getSelectedFields();
		fflib_QueryFactory.Ordering ordering = new fflib_QueryFactory.Ordering('Contact','name',fflib_QueryFactory.SortOrder.ASCENDING);
		System.assertEquals('Name',ordering.getField());

		System.assertEquals(new Set<String>{
			'CreatedBy.Name',
			'LastModifiedById',
			'LastModifiedDate',
			'LastName',
			'Id',
			'FirstName'},
			fields);

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
		System.assert(query.containsIgnoreCase('SELECT Id FROM Contact'),'Expected \'SELECT Id FROM Contact\' in the SOQL, found: ' + query);
	}  

	@isTest
	static void deterministic_toSOQL(){
		fflib_QueryFactory qf1 = new fflib_QueryFactory(User.SObjectType);
		fflib_QueryFactory qf2 = new fflib_QueryFactory(User.SObjectType);
		for(fflib_QueryFactory qf:new Set<fflib_QueryFactory>{qf1,qf2}){
			qf.selectFields(new List<String>{
				'Id',
				'FirstName',
				'LastName',
				'CreatedBy.Name',
				'CreatedBy.Manager',
				'LastModifiedBy.Email'
			});
		}
		String expectedQuery = 
			'SELECT CreatedBy.ManagerId, CreatedBy.Name, '
			+'FirstName, Id, LastModifiedBy.Email, LastName '
			+'FROM User';
		System.assertEquals(qf1.toSOQL(), qf2.toSOQL());
		System.assertEquals(expectedQuery, qf1.toSOQL());
		System.assertEquals(expectedQuery, qf2.toSOQL());
	}

	@isTest
	static void deepCloneBasicNoChanges() {
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType)	
		.setLimit(10)
		.setCondition('id=12345')
		.selectField('Description')
		.addOrdering(new fflib_QueryFactory.Ordering('Contact','name',fflib_QueryFactory.SortOrder.ASCENDING) )
		.addOrdering( new fflib_QueryFactory.Ordering('Contact','CreatedDATE',fflib_QueryFactory.SortOrder.DESCENDING))
		.setEnforceFLS(true);

		fflib_QueryFactory qf2 = qf.deepClone();

		System.assertEquals(qf2, qf);

		System.assertEquals(qf.getLimit(), qf2.getLimit());
		System.assertEquals(qf.getCondition(), qf2.getCondition());
		System.assertEquals(qf.toSOQL(), qf2.toSOQL());
		System.assertEquals(qf.getOrderings(), qf2.getOrderings());
	}

	@isTest
	static void deepCloneSubqueryNoChanges() {
		fflib_QueryFactory qf = new fflib_QueryFactory(Account.SObjectType)	
		.setLimit(10)
		.setCondition('id=12345')
		.selectField('Description')
		.addOrdering(new fflib_QueryFactory.Ordering('Account','Name',fflib_QueryFactory.SortOrder.ASCENDING) )
		.addOrdering( new fflib_QueryFactory.Ordering('Account','Description',fflib_QueryFactory.SortOrder.DESCENDING))
		.setEnforceFLS(true);

		qf.subselectQuery('Contacts', true);	

		fflib_QueryFactory qf2 = qf.deepClone();

		System.assertEquals(qf, qf2);

		System.assertEquals(qf.getLimit(), qf2.getLimit());
		System.assertEquals(qf.getCondition(), qf2.getCondition());
		System.assertEquals(qf.toSOQL(), qf2.toSOQL());
		System.assertEquals(qf.getOrderings(), qf2.getOrderings());
		System.assertEquals(qf.getSubselectQueries(), qf2.getSubselectQueries());
	}

	@isTest
	static void deepCloneBasic() {
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType)	
		.setLimit(10)
		.setCondition('id=12345')
		.selectField('Description')
		.addOrdering(new fflib_QueryFactory.Ordering('Contact','name',fflib_QueryFactory.SortOrder.ASCENDING) )
		.addOrdering( new fflib_QueryFactory.Ordering('Contact','CreatedDATE',fflib_QueryFactory.SortOrder.DESCENDING))
		.setEnforceFLS(true);


		fflib_QueryFactory qf2 = qf.deepClone()
			.setLimit(200)
			.setCondition('id=54321')
			.selectField('Fax')
			.addOrdering( new fflib_QueryFactory.Ordering('Contact','Fax',fflib_QueryFactory.SortOrder.ASCENDING))
			.setEnforceFLS(false);

		qf2.getOrderings().remove(0);

		System.assertEquals(10, qf.getLimit());
		System.assertEquals(200, qf2.getLimit());

		System.assertEquals('id=12345', qf.getCondition());
		System.assertEquals('id=54321', qf2.getCondition());

		String query = qf.toSOQL();
		String query2 = qf2.toSOQL();

		System.assert(query.containsIgnoreCase('Fax') == false);
		System.assert(query.containsIgnoreCase('Description'));
		System.assert(query2.containsIgnoreCase('Description'));
		System.assert(query2.containsIgnoreCase('Fax'));

		System.assertEquals(2, qf.getOrderings().size());
		System.assertEquals('Name', qf.getOrderings()[0].getField() );
		System.assertEquals(fflib_QueryFactory.SortOrder.DESCENDING, qf.getOrderings()[1].getDirection());

		System.assertEquals(2, qf2.getOrderings().size());
		System.assertEquals('Fax', qf2.getOrderings()[1].getField());
		System.assertEquals(fflib_QueryFactory.SortOrder.ASCENDING, qf2.getOrderings()[1].getDirection());

	}

	@isTest
	static void deepCloneSubquery() {
		fflib_QueryFactory qf = new fflib_QueryFactory(Account.SObjectType);
		qf.subselectQuery('Contacts', true);

		fflib_QueryFactory qf2 = qf.deepClone();
		qf2.subselectQuery('Opportunities', true);

		List<fflib_QueryFactory> subqueries = qf.getSubselectQueries();
		List<fflib_QueryFactory> subqueries2 = qf2.getSubselectQueries();

		fflib_QueryFactory subquery2_0 = subqueries2.get(0);

		subquery2_0.addOrdering(new fflib_QueryFactory.Ordering('Contact','Name',fflib_QueryFactory.SortOrder.ASCENDING));

		System.assert(subqueries.size() == 1);
		System.assert(subqueries2.size() == 2);

		System.assert(qf.getSubselectQueries().get(0).getOrderings().size() == 0);
		System.assert(qf2.getSubselectQueries().get(0).getOrderings().size() == 1);
	}
	
	@isTest
	static void testSoql_unsortedSelectFields(){
		//Given
		fflib_QueryFactory qf = new fflib_QueryFactory(User.SObjectType);
		qf.selectFields(new List<String>{
			'Id',
			'FirstName',
			'LastName',
			'CreatedBy.Name',
			'CreatedBy.Manager',
			'LastModifiedBy.Email'
		});

		qf.setSortSelectFields(false);

		String orderedQuery =
			'SELECT '
			+'FirstName, Id, LastName, ' //less joins come first, alphabetically
			+'CreatedBy.ManagerId, CreatedBy.Name, LastModifiedBy.Email ' //alphabetical on the same number of joins'
			+'FROM User';

		//When
		String actualSoql = qf.toSOQL();

		//Then		
		System.assertNotEquals(orderedQuery, actualSoql);
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
