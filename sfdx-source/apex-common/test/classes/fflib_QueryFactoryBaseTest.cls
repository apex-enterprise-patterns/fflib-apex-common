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
private class fflib_QueryFactoryBaseTest {

	@IsTest
	static void fieldSelections(){
		fflib_IQueryFactoryBase qf = fflib_QueryFactoryBase.newInstance('Contact');
		qf.selectField('firstName');
		qf.selectField('lastName');
		qf.selectFields( new Set<String>{'acCounTId', 'account.name'} );
		qf.selectFields( new List<String>{'homePhonE','fAX'} );
		qf.selectFields( new List<String>{ 'Email', 'Title' } );
		System.assertEquals(new Set<String>{
			'firstName',
			'lastName',
			'acCounTId',
			'account.name',
			'homePhonE',
			'fAX',
			'Email',
			'Title'},
			new Set<String>(qf.getSelectedFields()));
	}

	@IsTest
	static void simpleFieldSelection() {
		fflib_IQueryFactoryBase qf = fflib_QueryFactoryBase.newInstance('Contact');
		qf.selectField('NAMe').selectFields( new Set<String>{'naMe', 'email'});
		String query = qf.toSOQL();
		System.assert( Pattern.matches('(?i)SELECT.*Name.*FROM.*',query), 'Expected Name field in query, got '+query);
		System.assert( Pattern.matches('(?i)SELECT.*Email.*FROM.*',query), 'Expected Name field in query, got '+query);
		qf.setLimit(100);
		System.assertEquals(100,qf.getLimit());
		System.assert( qf.toSOQL().endsWithIgnoreCase('LIMIT '+qf.getLimit()), 'Failed to respect limit clause:'+qf.toSOQL() );
	}

	@IsTest
	static void simpleFieldCondition(){
		String whereClause = 'name = \'test\'';
		fflib_IQueryFactoryBase qf = fflib_QueryFactoryBase.newInstance('Contact');
		qf.selectField('name');
		qf.selectField('email');
		qf.setCondition( whereClause );
		System.assertEquals(whereClause,qf.getCondition());
		String query = qf.toSOQL();
		System.assert(query.endsWith('WHERE name = \'test\''),'Query should have ended with a filter on name, got: '+query);
	}

	@IsTest
	static void duplicateFieldSelection() {
		fflib_IQueryFactoryBase qf = fflib_QueryFactoryBase.newInstance('Contact');
		qf.selectField('NAMe').selectFields( new Set<String>{'naMe', 'email'});
		String query = qf.toSOQL();
		System.assertEquals(1, query.toLowerCase().countMatches('name'), 'Expected one name field in query: '+query );
	}

	@IsTest
	static void equalityCheck(){
		fflib_IQueryFactoryBase qf1 = fflib_QueryFactoryBase.newInstance('Contact');
		fflib_IQueryFactoryBase qf2 = fflib_QueryFactoryBase.newInstance('Contact');
		System.assertEquals(JSON.serialize(qf1),JSON.serialize(qf2));
	}

	@IsTest
	static void ordering(){
		fflib_IQueryFactoryBase qf = fflib_QueryFactoryBase.newInstance('Contact');
		qf.selectField('name');
		qf.selectField('email');
		qf.setCondition( 'name = \'test\'' );
		qf.addOrdering(new fflib_QueryFactoryBase.Ordering('name',fflib_QueryFactoryBase.SortOrder.ASCENDING) ).addOrdering(new fflib_QueryFactoryBase.Ordering('CreatedDATE',fflib_QueryFactoryBase.SortOrder.DESCENDING) );
		String query = qf.toSOQL();

		System.assertEquals(2,qf.getOrderings().size());
		System.assertEquals('name',qf.getOrderings()[0].getField().toLowerCase() );
		System.assertEquals(fflib_QueryFactoryBase.SortOrder.DESCENDING,qf.getOrderings()[1].getDirection() );

		
		System.assert( Pattern.matches('(?i)SELECT.*Name.*FROM.*',query), 'Expected Name field in query, got '+query);
		System.assert( Pattern.matches('(?i)SELECT.*Email.*FROM.*',query), 'Expected Name field in query, got '+query);
	}

	@IsTest
	static void setOrdering_ReplacesPreviousOrderingsWithExpectedOrdering(){
		fflib_IQueryFactoryBase qf = fflib_QueryFactoryBase.newInstance('Contact');
		qf.selectField('name');
		qf.selectField('email');
		qf.setCondition( 'name = \'test\'' );

		//test base method with ordeting by OwnerId Descending
		qf.setOrdering(new fflib_QueryFactoryBase.Ordering('OwnerId',fflib_QueryFactoryBase.SortOrder.DESCENDING) );

		System.assertEquals(1, qf.getOrderings().size(), 'Unexpected order size - setOrder should replace default Orderings');
		System.assertEquals(Contact.OwnerId.getDescribe().getName(), qf.getOrderings()[0].getField(), 'Unexpected order field - should have been resolved from the field OwnerId');
		System.assertEquals(fflib_QueryFactoryBase.SortOrder.DESCENDING, qf.getOrderings()[0].getDirection(), 'Unexpected order direction.');

		//test method overload with ordering by LastModifiedDate Ascending
		qf.setOrdering('LastModifiedDate', fflib_QueryFactoryBase.SortOrder.ASCENDING, true);

		System.assertEquals(1, qf.getOrderings().size(), 'Unexpected order size - setOrder should replace previous Orderings');
		System.assertEquals(Contact.LastModifiedDate.getDescribe().getName(), qf.getOrderings()[0].getField(), 'Unexpected order field - should have been resolved from the field LastModifiedDate');
		System.assertEquals(fflib_QueryFactoryBase.SortOrder.ASCENDING, qf.getOrderings()[0].getDirection(), 'Unexpected order direction.');

		//test method overload with ordering by CreatedDate Descending
		qf.setOrdering('CreatedDate', fflib_QueryFactoryBase.SortOrder.DESCENDING, true);

		System.assertEquals(1, qf.getOrderings().size(), 'Unexpected order size - setOrder should replace previous Orderings');
		System.assertEquals(Contact.CreatedDate.getDescribe().getName(), qf.getOrderings()[0].getField(), 'Unexpected order field - should have been resolved from the field CreatedDate');
		System.assertEquals(fflib_QueryFactoryBase.SortOrder.DESCENDING, qf.getOrderings()[0].getDirection(), 'Unexpected order direction.');

		//test method overload with ordering by CreatedBy.Name Descending
		qf.setOrdering('CreatedBy.Name', fflib_QueryFactoryBase.SortOrder.DESCENDING);

		System.assertEquals(1, qf.getOrderings().size(), 'Unexpected order size - setOrder should replace previous Orderings');
		System.assertEquals(fflib_QueryFactoryBase.SortOrder.DESCENDING, qf.getOrderings()[0].getDirection(), 'Unexpected order direction.');

		//test method overload with ordering by Birthdate Ascending
		qf.setOrdering('Birthdate', fflib_QueryFactoryBase.SortOrder.ASCENDING);

		System.assertEquals(1, qf.getOrderings().size(), 'Unexpected order size - setOrder should replace previous Orderings');
		System.assertEquals(Contact.Birthdate.getDescribe().getName(), qf.getOrderings()[0].getField(), 'Unexpected order field - should have been resolved from the field Birthdate');
		System.assertEquals(fflib_QueryFactoryBase.SortOrder.ASCENDING, qf.getOrderings()[0].getDirection(), 'Unexpected order direction.');
	}

	@IsTest
	static void addChildQueriesWithChildRelationship_success(){
		fflib_IQueryFactoryBase qf = fflib_QueryFactoryBase.newInstance('Contact');
		qf.selectField('name').selectField('Id').setCondition('name=\'test\'').addOrdering('CreatedDate', fflib_QueryFactoryBase.SortOrder.DESCENDING, true);
		//explicitly assert object accessibility when creating the subselect
		qf.subselectQuery('Tasks').selectField('Id').selectField('Subject').setCondition(' IsDeleted = false ');
		List<fflib_IQueryFactoryBase> queries = qf.getSubselectQueries();
		System.assert(queries != null);
		System.assert(
				Pattern.matches('(?i)SELECT.*(SELECT.*FROM Tasks WHERE.*).*FROM Contact WHERE.*', qf.toSOQL()),
				'Incorrect returned query'
		);
	}

	@IsTest
	static void addChildQueriesWithChildRelationshipNoAccessibleCheck_success(){
		fflib_IQueryFactoryBase qf = fflib_QueryFactoryBase.newInstance('Contact');
		qf.selectField('name').selectField('Id').setCondition('name=\'test\'').addOrdering('CreatedDate', fflib_QueryFactoryBase.SortOrder.DESCENDING, true);
		//explicitly assert object accessibility when creating the subselect
		qf.subselectQuery('Tasks').selectField('Id').selectField('Subject').setCondition(' IsDeleted = false ');
		List<fflib_IQueryFactoryBase> queries = qf.getSubselectQueries();
		System.assert(queries != null);
		System.assert(
				Pattern.matches('(?i)SELECT.*(SELECT.*FROM Tasks WHERE.*).*FROM Contact WHERE.*', qf.toSOQL()),
				'Incorrect returned query'
		);
	}

	@IsTest
	static void addChildQueriesWithChildRelationshipObjCheckIsAccessible_success(){
		fflib_IQueryFactoryBase qf = fflib_QueryFactoryBase.newInstance('Contact');
		qf.selectField('name').selectField('Id').setCondition('name=\'test\'').addOrdering('CreatedDate', fflib_QueryFactoryBase.SortOrder.DESCENDING, true);
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
		qf.subselectQuery(relationship.getRelationshipName()).selectField('Id').selectField('Subject').setCondition(' IsDeleted = false ');
		List<fflib_IQueryFactoryBase> queries = qf.getSubselectQueries();
		System.assert(queries != null);
		System.assert(
				Pattern.matches('(?i)SELECT.*(SELECT.*FROM Tasks WHERE.*).*FROM Contact WHERE.*', qf.toSOQL()),
				'Incorrect returned query'
		);
	}

	@IsTest
	static void addChildQueriesWithChildRelationshipObj_success(){
		fflib_IQueryFactoryBase qf = fflib_QueryFactoryBase.newInstance('Contact');
		qf.selectField('name').selectField('Id').setCondition( 'name=\'%test%\'' ).addOrdering('CreatedDate',fflib_QueryFactoryBase.SortOrder.DESCENDING, true);
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
		qf.subselectQuery(relationship.getRelationshipName()).selectField('Id').selectField('Subject').setCondition(' IsDeleted = false ');
		List<fflib_IQueryFactoryBase> queries = qf.getSubselectQueries();
		System.assert(queries != null);
		System.assert(
				Pattern.matches('(?i)SELECT.*(SELECT.*FROM Tasks WHERE.*).*FROM Contact WHERE.*', qf.toSOQL()),
				'Incorrect returned query'
		);
	}

	@IsTest
	static void addChildQueries_success(){
		fflib_IQueryFactoryBase qf = fflib_QueryFactoryBase.newInstance('Contact');
		qf.selectField('name').selectField('Id').setCondition( 'name like \'%test%\'' ).addOrdering('CreatedDate',fflib_QueryFactoryBase.SortOrder.DESCENDING, true);
		//explicitly assert object accessibility when creating the subselect
		qf.subselectQuery('Tasks').selectField('Id').selectField('Subject').setCondition('IsDeleted = false');
		List<fflib_IQueryFactoryBase> queries = qf.getSubselectQueries();
		System.assert(queries != null);
		System.assert(
				Pattern.matches('(?i)SELECT.*(SELECT.*FROM Tasks WHERE.*).*FROM Contact WHERE.*', qf.toSOQL()),
				'Incorrect returned query.  Actual: ' + qf.toSOQL()
		);
	}

	@IsTest
	static void addChildQuerySameRelationshipAgain_success(){
		fflib_IQueryFactoryBase qf = fflib_QueryFactoryBase.newInstance('Contact');
		qf.selectField('name');
		qf.selectField('Id');
		qf.setCondition( 'name like \'%test%\'' );
		qf.addOrdering(new fflib_QueryFactoryBase.Ordering('name',fflib_QueryFactoryBase.SortOrder.ASCENDING) ).addOrdering('CreatedBy.Name',fflib_QueryFactoryBase.SortOrder.DESCENDING);
		Schema.DescribeSObjectResult descResult = Contact.SObjectType.getDescribe();
       	Schema.ChildRelationship relationship;
        for (Schema.ChildRelationship childRow : descResult.getChildRelationships()) {
            if (childRow.getRelationshipName() == 'Tasks') {
                relationship = childRow;
            }
        }
        System.assert(qf.getSubselectQueries().isEmpty());
		fflib_IQueryFactoryBase childQf = qf.subselectQuery(Task.SObjectType.getDescribe().getName());
		childQf.selectField('Id');
		qf.subselectQuery(Task.SObjectType.getDescribe().getName());
		List<fflib_IQueryFactoryBase> queries = qf.getSubselectQueries();
		System.assert(queries != null);
		System.assert(queries.size() == 1);
	}

	@IsTest
	static void checkFieldObjectReadSort_success(){
		fflib_IQueryFactoryBase qf = fflib_QueryFactoryBase.newInstance('Contact');
		qf.selectField('createdby.name')
		  .selectField('LastModifiedById')
		  .selectFields(new List<String>{'LastModifiedDate'})
		  .selectField('LastName')
		  .selectFields(new List<String>{'Id'})
		  .setCondition( 'name like \'%test%\'' )
		  .selectFields(new Set<String>{'FirstName'})
		  .addOrdering(new fflib_QueryFactoryBase.Ordering('name',fflib_QueryFactoryBase.SortOrder.ASCENDING) )
		  .addOrdering('LastModifiedDate',fflib_QueryFactoryBase.SortOrder.DESCENDING)
		  .addOrdering('CreatedDate',fflib_QueryFactoryBase.SortOrder.DESCENDING, true);
		Set<String> fields = new Set<String>(qf.getSelectedFields());
		fflib_QueryFactoryBase.Ordering ordering = new fflib_QueryFactoryBase.Ordering('name',fflib_QueryFactoryBase.SortOrder.ASCENDING);
		System.assertEquals('name',ordering.getField());

		System.assertEquals(new Set<String>{
			'createdby.name',
			'LastModifiedById',
			'LastModifiedDate',
			'LastName',
			'Id',
			'FirstName'},
			fields);

		System.assert(qf.toSOQL().containsIgnoreCase('NULLS LAST'));
	}

	@IsTest
	static void queryWith_noFields(){
		fflib_IQueryFactoryBase qf = fflib_QueryFactoryBase.newInstance('Contact');
		qf.setCondition( 'name like \'%test%\'' ).addOrdering('CreatedDate',fflib_QueryFactoryBase.SortOrder.DESCENDING);
		String query = qf.toSOQL();
		System.assert(query.containsIgnoreCase('SELECT Id FROM Contact'),'Expected \'SELECT Id FROM Contact\' in the SOQL, found: ' + query);
	}  

	@IsTest
	static void deterministic_toSOQL(){
		fflib_IQueryFactoryBase qf1 = fflib_QueryFactoryBase.newInstance(User.SObjectType.getDescribe().getName());
		fflib_IQueryFactoryBase qf2 = fflib_QueryFactoryBase.newInstance(User.SObjectType.getDescribe().getName());
		for(fflib_IQueryFactoryBase qf:new Set<fflib_IQueryFactoryBase>{qf1, qf2}){
			qf.selectFields(new List<String>{
				'Id',
				'FirstName',
				'LastName',
				'CreatedBy.Name',
				'CreatedBy.Manager',
				'LastModifiedBy.Email'
			});
		}

		// This should be 'CreatedBy.ManagerId' but this Query Factory
		// only works with the provided field name strings.
		String expectedQuery = 
			'SELECT CreatedBy.Manager, CreatedBy.Name, '
			+'FirstName, Id, LastModifiedBy.Email, LastName '
			+'FROM User';
		System.assertEquals(qf1.toSOQL(), qf2.toSOQL());
		System.assertEquals(expectedQuery, qf1.toSOQL());
		System.assertEquals(expectedQuery, qf2.toSOQL());
	}

	@IsTest
	static void deepCloneBasicNoChanges() {
		fflib_IQueryFactoryBase qf = fflib_QueryFactoryBase.newInstance('Contact')	
		.setLimit(10)
		.setCondition('id=12345')
		.selectField('Description')
		.addOrdering(new fflib_QueryFactoryBase.Ordering('name',fflib_QueryFactoryBase.SortOrder.ASCENDING) )
		.addOrdering(new fflib_QueryFactoryBase.Ordering('CreatedDATE',fflib_QueryFactoryBase.SortOrder.DESCENDING));

		fflib_IQueryFactoryBase qf2 = qf.deepClone();

		System.assertEquals(JSON.serialize(qf2), JSON.serialize(qf));

		System.assertEquals(qf.getLimit(), qf2.getLimit());
		System.assertEquals(qf.getCondition(), qf2.getCondition());
		System.assertEquals(qf.toSOQL(), qf2.toSOQL());
		System.assertEquals(JSON.serialize(qf.getOrderings()), JSON.serialize(qf2.getOrderings()));
	}

	@IsTest
	static void deepCloneSubqueryNoChanges() {
		fflib_IQueryFactoryBase qf = fflib_QueryFactoryBase.newInstance(Account.SObjectType.getDescribe().getName())
		.setLimit(10)
		.setCondition('id=12345')
		.selectField('Description')
		.addOrdering(new fflib_QueryFactoryBase.Ordering('Name',fflib_QueryFactoryBase.SortOrder.ASCENDING) )
		.addOrdering(new fflib_QueryFactoryBase.Ordering('Description',fflib_QueryFactoryBase.SortOrder.DESCENDING));

		qf.subselectQuery('Contacts');

		fflib_IQueryFactoryBase qf2 = qf.deepClone();

		System.assertEquals(JSON.serialize(qf), JSON.serialize(qf2));

		System.assertEquals(qf.getLimit(), qf2.getLimit());
		System.assertEquals(qf.getCondition(), qf2.getCondition());
		System.assertEquals(qf.toSOQL(), qf2.toSOQL());
		System.assertEquals(JSON.serialize(qf.getOrderings()), JSON.serialize(qf2.getOrderings()));
		System.assertEquals(JSON.serialize(qf.getSubselectQueries()), JSON.serialize(qf2.getSubselectQueries()));
	}

	@IsTest
	static void deepCloneBasic() {
		fflib_IQueryFactoryBase qf = fflib_QueryFactoryBase.newInstance('Contact')	
		.setLimit(10)
		.setCondition('id=12345')
		.selectField('Description')
		.addOrdering(new fflib_QueryFactoryBase.Ordering('name',fflib_QueryFactoryBase.SortOrder.ASCENDING) )
		.addOrdering(new fflib_QueryFactoryBase.Ordering('CreatedDATE',fflib_QueryFactoryBase.SortOrder.DESCENDING));


		fflib_IQueryFactoryBase qf2 = qf.deepClone()
			.setLimit(200)
			.setCondition('id=54321')
			.selectField('Fax')
			.addOrdering(new fflib_QueryFactoryBase.Ordering('Fax',fflib_QueryFactoryBase.SortOrder.ASCENDING));

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
		System.assertEquals('name', qf.getOrderings()[0].getField() );
		System.assertEquals(fflib_QueryFactoryBase.SortOrder.DESCENDING, qf.getOrderings()[1].getDirection());

		System.assertEquals(2, qf2.getOrderings().size());
		System.assertEquals('Fax', qf2.getOrderings()[1].getField());
		System.assertEquals(fflib_QueryFactoryBase.SortOrder.ASCENDING, qf2.getOrderings()[1].getDirection());

	}

	@IsTest
	static void deepCloneSubquery() {
		fflib_QueryFactory qf = new fflib_QueryFactory(Account.SObjectType);
		qf.subselectQuery('Contacts');

		fflib_QueryFactory qf2 = qf.deepClone();
		qf2.subselectQuery('Opportunities');

		List<fflib_QueryFactory> subqueries = qf.getSubselectQueries();
		List<fflib_QueryFactory> subqueries2 = qf2.getSubselectQueries();

		fflib_QueryFactory subquery2_0 = subqueries2.get(0);

		subquery2_0.addOrdering(new fflib_QueryFactory.Ordering('Name',fflib_QueryFactory.SortOrder.ASCENDING));

		System.assert(subqueries.size() == 1);
		System.assert(subqueries2.size() == 2);

		System.assert(qf.getSubselectQueries().get(0).getOrderings().size() == 0);
		System.assert(qf2.getSubselectQueries().get(0).getOrderings().size() == 1);
	}
	
	@IsTest
	static void testSoql_unsortedSelectFields(){
		//Given
		fflib_IQueryFactoryBase qf = fflib_QueryFactoryBase.newInstance(User.SObjectType.getDescribe().getName());
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

	@IsTest
	static void setMock_When_MockIsProvided_Expect_MockFunctionality()
	{
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_IQueryFactoryBase mockQueryFactory = (fflib_IQueryFactoryBase) mocks.mock(fflib_IQueryFactoryBase.class);

		mocks.startStubbing();
		mocks.when(mockQueryFactory.toSOQL()).thenReturn('hello world');
		mocks.stopStubbing();

		fflib_QueryFactoryBase.setMock('Contact', mockQueryFactory);

		System.assertEquals('hello world', fflib_QueryFactoryBase.newInstance('Contact').toSOQL());
	}
}
