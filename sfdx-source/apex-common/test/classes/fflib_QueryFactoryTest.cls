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

@isTest( isParallel = true )
private class fflib_QueryFactoryTest {

	@isTest
	static void fieldSelections(){
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType);
		qf.selectField('firstName');
		qf.selectField(Schema.Contact.SObjectType.fields.lastName);
		qf.selectFields( new Set<String>{'acCounTId', 'account.name'} );
		qf.selectFields( new List<String>{'homePhonE','fAX'} );
		qf.selectFields( new List<Schema.SObjectField>{ Contact.Email, Contact.Title } );
		Assert.areEqual(new Set<String>{
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
		Assert.isTrue( Pattern.matches('SELECT.*Name.*FROM.*',query), 'Expected Name field in query, got '+query);
		Assert.isTrue( Pattern.matches('SELECT.*Email.*FROM.*',query), 'Expected Name field in query, got '+query);
		qf.setLimit(100);
		Assert.areEqual(100,qf.getLimit());
		Assert.isTrue( qf.toSOQL().endsWithIgnoreCase('LIMIT '+qf.getLimit()), 'Failed to respect limit clause:'+qf.toSOQL() );
	}

	@isTest
	static void simpleFieldCondition(){
		String whereClause = 'name = \'test\'';
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType);
		qf.selectField('name');
		qf.selectField('email');
		qf.setCondition( whereClause );
		Assert.areEqual(whereClause,qf.getCondition()); 
		String query = qf.toSOQL();
		Assert.isTrue(query.endsWith('WHERE name = \'test\''),'Query should have ended with a filter on name, got: '+query);
	}

	@isTest
	static void duplicateFieldSelection() {
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType);
		qf.selectField('NAMe').selectFields( new Set<String>{'naMe', 'email'});
		String query = qf.toSOQL();
		Assert.areEqual(1, query.countMatches('Name'), 'Expected one name field in query: '+query );
	}

	@isTest
	static void equalityCheck(){
		fflib_QueryFactory qf1 = new fflib_QueryFactory(Contact.SObjectType);
		fflib_QueryFactory qf2 = new fflib_QueryFactory(Contact.SObjectType);
		Assert.areEqual(qf1,qf2);
		qf1.selectField('name');
		Assert.areNotEqual(qf1,qf2);
		qf2.selectField('NAmE');
		Assert.areEqual(qf1,qf2);
		qf1.selectField('name').selectFields( new Set<String>{ 'NAME', 'name' }).selectFields( new Set<Schema.SObjectField>{ Contact.Name, Contact.Name} );
		Assert.areEqual(qf1,qf2);
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
		Assert.areNotEqual(null,e,'Cross-object notation on a non-reference field should throw NonReferenceFieldException.');
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
		Assert.areNotEqual(null,e,'Cross-object notation on a non-reference field should throw NonReferenceFieldException.');
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
		Assert.areEqual(4, exceptions.size(), 'Expected 4 InvalidFieldExceptions to be thrown');
	}

	@isTest
	static void ordering(){
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType);
		qf.selectField('name');
		qf.selectField('email');
		qf.setCondition( 'name = \'test\'' );
		qf.addOrdering( new fflib_QueryFactory.Ordering('Contact','name',fflib_QueryFactory.SortOrder.ASCENDING) ).addOrdering( new fflib_QueryFactory.Ordering('Contact','CreatedDATE',fflib_QueryFactory.SortOrder.DESCENDING) );
		String query = qf.toSOQL();

		Assert.areEqual(2,qf.getOrderings().size());
		Assert.areEqual('Name',qf.getOrderings()[0].getField() );
		Assert.areEqual(fflib_QueryFactory.SortOrder.DESCENDING,qf.getOrderings()[1].getDirection() );

		
		Assert.isTrue(Pattern.matches('SELECT.*Name.*FROM.*',query), 'Expected Name field in query, got '+query);
		Assert.isTrue(Pattern.matches('SELECT.*Email.*FROM.*',query), 'Expected Email field in query, got '+query);
	}

	@isTest
	static void setOrdering_ReplacesPreviousOrderingsWithExpectedOrdering(){
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType);
		qf.selectField('name');
		qf.selectField('email');
		qf.setCondition( 'name = \'test\'' );

		//test base method with ordeting by OwnerId Descending
		qf.setOrdering( new fflib_QueryFactory.Ordering('Contact','OwnerId',fflib_QueryFactory.SortOrder.DESCENDING) );

		Assert.areEqual(1, qf.getOrderings().size(), 'Unexpected order size - setOrder should replace default Orderings');
		Assert.areEqual(Contact.OwnerId.getDescribe().getName(), qf.getOrderings()[0].getField(), 'Unexpected order field - should have been resolved from the field OwnerId');
		Assert.areEqual(fflib_QueryFactory.SortOrder.DESCENDING, qf.getOrderings()[0].getDirection(), 'Unexpected order direction.');

		//test method overload with ordering by LastModifiedDate Ascending
		qf.setOrdering('LastModifiedDate', fflib_QueryFactory.SortOrder.ASCENDING, true);

		Assert.areEqual(1, qf.getOrderings().size(), 'Unexpected order size - setOrder should replace previous Orderings');
		Assert.areEqual(Contact.LastModifiedDate.getDescribe().getName(), qf.getOrderings()[0].getField(), 'Unexpected order field - should have been resolved from the field LastModifiedDate');
		Assert.areEqual(fflib_QueryFactory.SortOrder.ASCENDING, qf.getOrderings()[0].getDirection(), 'Unexpected order direction.');

		//test method overload with ordering by CreatedDate Descending
		qf.setOrdering(Contact.CreatedDate, fflib_QueryFactory.SortOrder.DESCENDING, true);

		Assert.areEqual(1, qf.getOrderings().size(), 'Unexpected order size - setOrder should replace previous Orderings');
		Assert.areEqual(Contact.CreatedDate.getDescribe().getName(), qf.getOrderings()[0].getField(), 'Unexpected order field - should have been resolved from the field CreatedDate');
		Assert.areEqual(fflib_QueryFactory.SortOrder.DESCENDING, qf.getOrderings()[0].getDirection(), 'Unexpected order direction.');

		//test method overload with ordering by CreatedBy.Name Descending
		qf.setOrdering('CreatedBy.Name', fflib_QueryFactory.SortOrder.DESCENDING);

		Assert.areEqual(1, qf.getOrderings().size(), 'Unexpected order size - setOrder should replace previous Orderings');
		Assert.areEqual(fflib_QueryFactory.SortOrder.DESCENDING, qf.getOrderings()[0].getDirection(), 'Unexpected order direction.');

		//test method overload with ordering by Birthdate Ascending
		qf.setOrdering(Contact.Birthdate, fflib_QueryFactory.SortOrder.ASCENDING);

		Assert.areEqual(1, qf.getOrderings().size(), 'Unexpected order size - setOrder should replace previous Orderings');
		Assert.areEqual(Contact.Birthdate.getDescribe().getName(), qf.getOrderings()[0].getField(), 'Unexpected order field - should have been resolved from the field Birthdate');
		Assert.areEqual(fflib_QueryFactory.SortOrder.ASCENDING, qf.getOrderings()[0].getDirection(), 'Unexpected order direction.');

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
		Assert.areNotEqual(null,e);
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
		Assert.areNotEqual(null,e);
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
		Assert.areNotEqual(null,e);
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
		Assert.areNotEqual(null,e);
	}

	@isTest
	static void invalidFields_noQueryField(){
		try {
			String path = fflib_QueryFactory.getFieldTokenPath(null);
			Assert.fail('Expected InvalidFieldException; none was thrown');
		} 
		catch (fflib_QueryFactory.InvalidFieldException ife) {
			//Expected
		}
		catch (Exception e){
			Assert.fail('Expected InvalidFieldException; ' + e.getTypeName() + ' was thrown instead: ' + e);
		}
	}

	@isTest
	static void queryFieldsNotEquals(){
		String qfld = fflib_QueryFactory.getFieldTokenPath(Contact.Name);
		String qfld2 = fflib_QueryFactory.getFieldTokenPath(Contact.LastName);
		Assert.isFalse(qfld.equals(qfld2), 'Field paths should not be equal');
	}

	@isTest
	static void addChildQueriesWithChildRelationship_success(){
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType);
		qf.selectField('name').selectField('Id').setCondition('name=\'test\'').addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING, true);
		Schema.DescribeSObjectResult descResult = Contact.SObjectType.getDescribe();
		//explicitly assert object accessibility when creating the subselect
		qf.subselectQuery('Tasks', true).selectField('Id').selectField('Subject').setCondition(' IsDeleted = false ');
		List<fflib_QueryFactory> queries = qf.getSubselectQueries();
		Assert.isNotNull(queries);
		Assert.isTrue(
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
		Assert.isNotNull(queries);
		Assert.isTrue(
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
		Assert.areNotEqual(e, null);
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
        Assert.isNull(qf.getSubselectQueries(), 'Subselect queries should initially be null');
		fflib_QueryFactory childQf = qf.subselectQuery(Task.SObjectType);
		childQf.assertIsAccessible();
		childQf.setEnforceFLS(true);
		childQf.selectField('Id');
		fflib_QueryFactory childQf2 = qf.subselectQuery(Task.SObjectType);
		List<fflib_QueryFactory> queries = qf.getSubselectQueries();
		Assert.isNotNull(queries, 'Subselect queries should not be null after adding subquery');
		Assert.areEqual(1, queries.size(), 'Should have exactly one subquery');
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
		Assert.areNotEqual(e, null);
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
		Assert.areEqual('Name',ordering.getField());

		Assert.areEqual(new Set<String>{
			'CreatedBy.Name',
			'LastModifiedById',
			'LastModifiedDate',
			'LastName',
			'Id',
			'FirstName'},
			fields);

		Assert.isTrue(qf.toSOQL().containsIgnoreCase('NULLS LAST'));
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
				Assert.isTrue(excThrown);
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
				Assert.isTrue(excThrown);
			}	
		}	
	}

	@isTest
	static void queryWith_noFields(){
		fflib_QueryFactory qf = new fflib_QueryFactory(Contact.SObjectType);
		qf.assertIsAccessible().setEnforceFLS(true).setCondition( 'name like \'%test%\'' ).addOrdering('CreatedDate',fflib_QueryFactory.SortOrder.DESCENDING);
		String query = qf.toSOQL();
		Assert.isTrue(query.containsIgnoreCase('SELECT Id FROM Contact'),'Expected \'SELECT Id FROM Contact\' in the SOQL, found: ' + query);
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
		Assert.areEqual(qf1.toSOQL(), qf2.toSOQL());
		Assert.areEqual(expectedQuery, qf1.toSOQL());
		Assert.areEqual(expectedQuery, qf2.toSOQL());
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

		Assert.areEqual(qf2, qf);

		Assert.areEqual(qf.getLimit(), qf2.getLimit());
		Assert.areEqual(qf.getCondition(), qf2.getCondition());
		Assert.areEqual(qf.toSOQL(), qf2.toSOQL());
		Assert.areEqual(qf.getOrderings(), qf2.getOrderings());
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

		Assert.areEqual(qf, qf2);

		Assert.areEqual(qf.getLimit(), qf2.getLimit());
		Assert.areEqual(qf.getCondition(), qf2.getCondition());
		Assert.areEqual(qf.toSOQL(), qf2.toSOQL());
		Assert.areEqual(qf.getOrderings(), qf2.getOrderings());
		Assert.areEqual(qf.getSubselectQueries(), qf2.getSubselectQueries());
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

		Assert.areEqual(10, qf.getLimit());
		Assert.areEqual(200, qf2.getLimit());

		Assert.areEqual('id=12345', qf.getCondition());
		Assert.areEqual('id=54321', qf2.getCondition());

		String query = qf.toSOQL();
		String query2 = qf2.toSOQL();

		Assert.isFalse(query.containsIgnoreCase('Fax'));
		Assert.isTrue(query.containsIgnoreCase('Description'));
		Assert.isTrue(query2.containsIgnoreCase('Description'));
		Assert.isTrue(query2.containsIgnoreCase('Fax'));

		Assert.areEqual(2, qf.getOrderings().size());
		Assert.areEqual('Name', qf.getOrderings()[0].getField() );
		Assert.areEqual(fflib_QueryFactory.SortOrder.DESCENDING, qf.getOrderings()[1].getDirection());

		Assert.areEqual(2, qf2.getOrderings().size());
		Assert.areEqual('Fax', qf2.getOrderings()[1].getField());
		Assert.areEqual(fflib_QueryFactory.SortOrder.ASCENDING, qf2.getOrderings()[1].getDirection());

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

		Assert.areEqual(1, subqueries.size());
		Assert.areEqual(2, subqueries2.size());

		Assert.areEqual(0, qf.getSubselectQueries().get(0).getOrderings().size());
		Assert.areEqual(1, qf2.getSubselectQueries().get(0).getOrderings().size());
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
		Assert.areNotEqual(orderedQuery, actualSoql);
	}

	@isTest
	static void testSoql_allRows(){
		//Given
		fflib_QueryFactory qf = new fflib_QueryFactory(User.SObjectType);
		qf.selectField('Id');
		qf.setAllRows();

		String allRowsQuery =
			'SELECT Id '
			+'FROM User '
			+'ALL ROWS';

		//When
		String actualSoql = qf.toSOQL();

		//Then		
		Assert.areEqual(allRowsQuery, actualSoql);
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
