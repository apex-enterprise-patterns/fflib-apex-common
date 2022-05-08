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
 */
@IsTest
private class fflib_ApplicationTest 
{
	@IsTest
	private static void callingDomainFactoryShouldGiveRegisteredImplsAndMocks()
	{
		// Registered Accounts domain class by SObject List
		Id testAccountId = fflib_IDGenerator.generate(Account.SObjectType);
		fflib_IDomain domainObjectAcct =
			TestDomainFactory.newInstance(
				new List<Account> 
					{ new Account( 
						Id = testAccountId,
						Name = 'Test Account') });
		System.assert(domainObjectAcct instanceof Accounts);
		System.assertEquals(testAccountId, getFirstSObject(domainObjectAcct).Id);

		// Registered Accounts domain class by SObject List
		testAccountId = fflib_IDGenerator.generate(Account.SObjectType);
		domainObjectAcct = 
			TestDomainFactory.newInstance(
				new List<SObject> 
					{ new Account( 
						Id = testAccountId,
						Name = 'Test Account') }
				, Account.SObjectType);
		System.assert(domainObjectAcct instanceof Accounts);
		System.assertEquals(testAccountId, getFirstSObject(domainObjectAcct).Id);

		// Registered Opportunities domain class by SObject List
		Id testOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
		fflib_IDomain domainObjectOpp =
			TestDomainFactory.newInstance(
				new List<Opportunity> 
					{ new Opportunity( 
						Id = testOpportunityId,
						Name = 'Test Opportunity') });
		System.assertEquals(testOpportunityId, getFirstSObject(domainObjectOpp).Id);
		System.assert(domainObjectOpp instanceof Opportunties);

		// Test failure for creating new instance using IConstructable2
		// for domain class that does not support it
		testOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
		domainObjectOpp = 
			TestDomainFactory.newInstance(
				new List<SObject> 
					{ new Opportunity( 
						Id = testOpportunityId,
						Name = 'Test Opportunity') }
				, Opportunity.SObjectType);
		System.assertEquals(testOpportunityId, getFirstSObject(domainObjectOpp).Id);
		System.assert(domainObjectOpp instanceof Opportunties);

		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		mocks.startStubbing();		
		// fflib_ISObjectDomain domainMock = new fflib_SObjectMocks.SObjectDomain(mocks);
		fflib_ApplicationTest.IAccounts accountsDomainMock = (fflib_ApplicationTest.IAccounts)mocks.mock(fflib_ApplicationTest.IAccounts.class);
		mocks.when(accountsDomainMock.sObjectType()).thenReturn(Account.SObjectType);
		mocks.stopStubbing();		
		TestDomainFactory.setMock(accountsDomainMock);

		// When
		domainObjectAcct = 
			TestDomainFactory.newInstance(
				new List<Account> 
					{ new Account( 
						Id = testAccountId,
						Name = 'Test Account') });

		// Then
		System.assert(domainObjectAcct instanceof IAccounts);

		// When
		domainObjectAcct = 
			TestDomainFactory.newInstance(
				new List<SObject> 
					{ new Account( 
						Id = testAccountId,
						Name = 'Test Account') }
				, Account.SObjectType);

		// Then
		System.assert(domainObjectAcct instanceof IAccounts);		
	}

	private static SObject getFirstSObject(fflib_IDomain domainObjectAcct)
	{
		return ((List<SObject>) domainObjectAcct.getObjects())[0];
	}

	@IsTest
	private static void callingDomainFactoryWithIdsShouldGiveRegisteredImpls()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		IAccountsSelector mockAccountsSelector = (IAccountsSelector)mocks.mock(IAccountsSelector.class);

		Id testAccountId = fflib_IDGenerator.generate(Account.SObjectType);
		List<Account> accounts = 
			new List<Account> 
				{ new Account( 
					Id = testAccountId,
					Name = 'Test Account') };
		Set<Id> accountIds = new Map<Id, Account>(accounts).keySet();
		mocks.startStubbing();
		mocks.when(mockAccountsSelector.selectSObjectsById(accountIds)).thenReturn(accounts);
		mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
		mocks.stopStubbing();

		// When
		TestSelectorFactory.setMock(mockAccountsSelector);
		fflib_IDomain domainObjectAcc = TestDomainFactory.newInstance(new Set<Id> { testAccountId });

		// Then
		List<Account> assertAccounts = (List<Account>) domainObjectAcc.getObjects();
		System.assert(domainObjectAcc instanceof Accounts);
		System.assertEquals(testAccountId, getFirstSObject(domainObjectAcc).Id);
		System.assertEquals(1, assertAccounts.size());
		System.assertEquals(testAccountId, assertAccounts[0].Id);
		System.assertEquals('Test Account', assertAccounts[0].Name);
	}

	@IsTest
	private static void callingDomainFactoryWithGenericListShouldGiveException()
	{
		try {
			TestDomainFactory.newInstance(new List<SObject>());
			System.assert(false, 'Expected exception');
		} catch (fflib_Application.DeveloperException e) {
			System.assertEquals('Unable to determine SObjectType', e.getMessage());
		}
	}

	@IsTest
	private static void callingDomainFactoryWithNoSObjectTypeShouldGiveException()
	{
		try {
			TestDomainFactory.newInstance(new List<SObject>(), null);
			System.assert(false, 'Expected exception');
		} catch (fflib_Application.DeveloperException e) {
			System.assertEquals('Must specify sObjectType', e.getMessage());
		}
	}	

	@IsTest
	private static void callingDomainFactoryWithInAccessableConstructorShouldGiveException()
	{
		try {
			TestDomainFactory.newInstance(new List<Product2>{ new Product2(Name = 'Test Product') });
			System.assert(false, 'Expected exception');
		} catch (fflib_Application.DeveloperException e) {
			System.assertEquals('Domain constructor class not found for SObjectType Product2', e.getMessage());
		}

		try {
			TestDomainFactory.newInstance(new List<SObject>{ new Product2(Name = 'Test Product') }, Product2.SObjectType);
			System.assert(false, 'Expected exception');
		} catch (fflib_Application.DeveloperException e) {
			System.assertEquals('Domain constructor class not found for SObjectType Product2', e.getMessage());
		}		
	}

	@IsTest
	private static void callingDomainFactoryWithContructorClassThatDoesNotSupportIConstructableShouldGiveException()
	{
		try {
			TestDomainFactory.newInstance(new List<Contact>{ new Contact(LastName = 'TestContactLName') });
			System.assert(false, 'Expected exception');
		} catch (System.TypeException e) {

			System.assert(Pattern.Matches('Invalid conversion from runtime type \\w*\\.?fflib_ApplicationTest\\.ContactsConstructor to \\w*\\.?fflib_IDomainConstructor',
				e.getMessage()), 'Exception message did not match the expected pattern: ' + e.getMessage());
		}	

		try {
			TestDomainFactory.newInstance(new List<SObject>{ new Contact(LastName = 'TestContactLName') }, Contact.SObjectType);
			System.assert(false, 'Expected exception');
		} catch (System.TypeException e) {
			System.assert(Pattern.Matches('Invalid conversion from runtime type \\w*\\.?fflib_ApplicationTest\\.ContactsConstructor to \\w*\\.?fflib_IDomainConstructor',
				e.getMessage()), 'Exception message did not match the expected pattern: ' + e.getMessage());
		}		
	}	

	@IsTest
	private static void callingUnitOfWorkFactoryShouldGivenStandardImplsAndMockImpls()
	{
		// Standard behaviour
		System.assert(TestUnitOfWorkFactory.newInstance() instanceof fflib_SObjectUnitOfWork);
 		
		// Mocking behaviour
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_ISObjectUnitOfWork mockUow = (fflib_ISObjectUnitOfWork)mocks.mock(fflib_ISObjectUnitOfWork.class);
		TestUnitOfWorkFactory.setMock(mockUow);
	}

	@IsTest
	private static void callingUnitOfWorkFactoryWithCustomTypesShouldGivenStandardImplsAndMockImpls()
	{
		// Standard behaviour
		System.assert(
				TestUnitOfWorkFactory.newInstance(
						new List<SObjectType>{ Account.SObjectType}
				) instanceof fflib_SObjectUnitOfWork);

	}

	@IsTest
	private static void callingServiceFactoryShouldGiveRegisteredImplsImpl()
	{
		// Standard behaviour
		System.assert(TestServiceFactory.newInstance(IAccountsService.class) instanceof AccountsServiceImpl);
		System.assert(TestServiceFactory.newInstance(IOpportunitiesService.class) instanceof OpportunitiesServiceImpl);
		try {
			TestServiceFactory.newInstance(IContactService.class);
			System.assert(false, 'Expected exception');
		} catch (fflib_Application.DeveloperException e) {
			System.assertEquals('No implementation registered for service interface ' + IContactService.class.getName(), e.getMessage());
		}
	}

	@IsTest 
	private static void callingServiceFactoryWhenMockInstanceSetShouldGiveRegisteredMockImpl()
	{
		// Mocking behaviour
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		IAccountsService mockAccountsService = (IAccountsService)mocks.mock(IAccountsService.class);
		TestServiceFactory.setMock(IAccountsService.class, mockAccountsService);
		System.assert(TestServiceFactory.newInstance(IAccountsService.class) instanceof IAccountsService );
	}

	@IsTest
	private static void callingSelectorFactoryShouldGiveRegisteredImpls()
	{
		// Standard behaviour
		System.assert(TestSelectorFactory.newInstance(Account.SObjectType) instanceof AccountsSelector);
		System.assert(TestSelectorFactory.newInstance(Opportunity.SObjectType) instanceof OpportuntiesSelector);
		try {
			TestSelectorFactory.newInstance(User.SObjectType);
			System.assert(false, 'Expected exception');
		} catch (fflib_Application.DeveloperException e) {
			System.assertEquals('TestSelectorFactory class not found for SObjectType User', e.getMessage());
		}

		// Mock behaviour
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		IAccountsSelector mockAccountsSelector = (IAccountsSelector)mocks.mock(IAccountsSelector.class);

		mocks.startStubbing();
		mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
		mocks.stopStubbing();

		TestSelectorFactory.setMock( mockAccountsSelector );

		System.assert(TestSelectorFactory.newInstance(Account.SObjectType) instanceof IAccountsSelector);
	}

	@IsTest
	private static void callingSelectorFactorySelectByIdWithEmptyListShouldGiveException()
	{
		try {
			TestSelectorFactory.selectById(null);
			System.assert(false, 'Expected exception');
		} catch (fflib_Application.DeveloperException e) {
			System.assertEquals('Invalid record Id\'s set', e.getMessage());
		}
		try {
			TestSelectorFactory.selectById(new Set<Id>());
			System.assert(false, 'Expected exception');
		} catch (fflib_Application.DeveloperException e) {
			System.assertEquals('Invalid record Id\'s set', e.getMessage());
		}
	}

	@IsTest
	private static void callingSelectorFactorySelectByIdWithMixedIdTypeListShouldGiveException()
	{
		try {
			TestSelectorFactory.selectById(
				new Set<Id> { 
					fflib_IDGenerator.generate(Opportunity.SObjectType), 
					fflib_IDGenerator.generate(Account.SObjectType) });
			System.assert(true, 'Expected exception');
		} catch (fflib_Application.DeveloperException e) {
			System.assertEquals('Unable to determine SObjectType, Set contains Id\'s from different SObject types', e.getMessage());
		}		
	}

	@IsTest
	private static void callingSelectorFactorySelectByIdWithIdSetShouldSucceedWithNoRecords()
	{
		// Standard behaviour
		try {
			List<Account> testRecords = (List<Account>) TestSelectorFactory.selectById(
				new Set<Id> { 
					fflib_IDGenerator.generate(Account.SObjectType), 
					fflib_IDGenerator.generate(Account.SObjectType) });
			System.assert(true, 'Expected exception');
		} catch (fflib_Application.DeveloperException e) {
			System.assert(false, 'Should not throw a fflib_Application.DeveloperException');
		} catch (Exception e) {
			System.assert(false, 'Should not throw a Exception');
		}

		// Mock behaviour
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		IAccountsSelector mockAccountsSelector = (IAccountsSelector)mocks.mock(IAccountsSelector.class);
		Set<Id> testAccountIdSet = new Set<Id>();
		testAccountIdSet.add( fflib_IDGenerator.generate(Account.SObjectType) );
		testAccountIdSet.add( fflib_IDGenerator.generate(Account.SObjectType) );
		mocks.startStubbing();
		mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
		mocks.stopStubbing();

		TestSelectorFactory.setMock( mockAccountsSelector );

		TestSelectorFactory.newInstance(Account.SObjectType);
		
	}
	@IsTest
	private static void callingSelectoryFactorySelectByIdShouldReturnResults()
	{	
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		IAccountsSelector mockAccountsSelector = (IAccountsSelector)mocks.mock(IAccountsSelector.class);

		Id testAccountId = fflib_IDGenerator.generate(Account.SObjectType);
		List<Account> accounts = 
			new List<Account> 
				{ new Account( 
					Id = testAccountId,
					Name = 'Test Account') };
		Set<Id> accountIds = new Map<Id, Account>(accounts).keySet();

		mocks.startStubbing();
		mocks.when(mockAccountsSelector.selectSObjectsById(accountIds)).thenReturn(accounts);
		mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
		mocks.stopStubbing();

		TestSelectorFactory.setMock(mockAccountsSelector);

		// When
		List<Account> assertAccounts = TestSelectorFactory.selectById(accountIds);

		// Then
		System.assert(TestSelectorFactory.newInstance(Account.SObjectType) instanceof IAccountsSelector);
		System.assertEquals(1, assertAccounts.size());
		System.assertEquals(testAccountId, assertAccounts[0].Id);
		System.assertEquals('Test Account', assertAccounts[0].Name);
		System.assert(TestSelectorFactory.newInstance(Opportunity.SObjectType) instanceof OpportuntiesSelector);
	}

	@IsTest
	private static void callingSelectoryFactorySelectByRelationshipPassRelatedIds()
	{	
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		IAccountsSelector mockAccountsSelector = (IAccountsSelector)mocks.mock(IAccountsSelector.class);

		Id testAccountId = fflib_IDGenerator.generate(Account.SObjectType);
		Id testOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
		List<Account> accounts = 
			new List<Account> 
				{ new Account( 
					Id = testAccountId,
					Name = 'Test Account') };
		Set<Id> accountIds = new Map<Id, Account>(accounts).keySet();

		mocks.startStubbing();
		mocks.when(mockAccountsSelector.selectSObjectsById(accountIds)).thenReturn(accounts);
		mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
		mocks.stopStubbing();

		TestSelectorFactory.setMock(mockAccountsSelector);

		// When
		List<Opportunity> opportunties = 
			new List<Opportunity>
				{ new Opportunity(
						Id = testOpportunityId,
						Account = accounts[0],
						AccountId = testAccountId,
						Name = 'Test Opportunity 1'),
				  new Opportunity(
						Id = testOpportunityId,
						Name = 'Test Opportunity 2') };
		List<Account> assertAccounts = TestSelectorFactory.selectByRelationship(opportunties, Opportunity.AccountId);

		// Then
		System.assert(TestSelectorFactory.newInstance(Account.SObjectType) instanceof IAccountsSelector);
		System.assertEquals(1, assertAccounts.size());
		System.assertEquals(testAccountId, assertAccounts[0].Id);
		System.assertEquals('Test Account', assertAccounts[0].Name);
		System.assert(TestSelectorFactory.newInstance(Opportunity.SObjectType) instanceof OpportuntiesSelector);
	}

	@IsTest
	private static void callingUnitOfWorkWithCustomDML()
	{
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_ISObjectUnitOfWork mockUow = (fflib_ISObjectUnitOfWork)mocks.mock(fflib_ISObjectUnitOfWork.class);
		TestUnitOfWorkFactory.setMock(mockUow);

		// Given a custom DML class and a new record
		CustomDML customDML = new CustomDML();
		Account myAccount = new Account(Name = 'Test Account');

		// When the unit of work is instantiated from the Application Class and the record is registered and commited
		fflib_ISObjectUnitOfWork unitOfWork = TestUnitOfWorkFactory.newInstance(customDML);
		unitOfWork.registerNew(myAccount);
		unitOfWork.commitWork();

		// Then the Custom DML is used by the unit of Work
		System.assert(customDML.isInsertCalled, 'Oops, custom DML was not called');
	}

	@IsTest
	private static void callingMockedUnitOfWorkWithCustomDML()
	{
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_ISObjectUnitOfWork mockUow = (fflib_ISObjectUnitOfWork)mocks.mock(fflib_ISObjectUnitOfWork.class);
		TestUnitOfWorkFactory.setMock(mockUow);

		// Given a custom DML class and a new record
		CustomDML customDML = new CustomDML();
		Account myAccount = new Account(Name = 'Test Account');

		// When the unit of work is instantiated from the Application Class and the record is registered and commited
		fflib_ISObjectUnitOfWork uow = TestUnitOfWorkFactory.newInstance(customDML);

		uow.registerNew(myAccount);
		uow.commitWork();

		// Then the Custom DML should not be used by the unit of Work
		System.assert(!customDML.isInsertCalled, 'Oops, custom DML was called');
	}

	@IsTest
	private static void callingUnitOfWorkWithCustomObjectTypesAndDML()
	{
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_ISObjectUnitOfWork mockUow = (fflib_ISObjectUnitOfWork)mocks.mock(fflib_ISObjectUnitOfWork.class);
		TestUnitOfWorkFactory.setMock(mockUow);

		// Given a custom DML class and a new record
		CustomDML customDML = new CustomDML();
		Account myAccount = new Account(Name = 'Test Account');

		// When the unit of work is instantiated from the Application Class and the record is registered and commited
		fflib_ISObjectUnitOfWork unitOfWork = TestUnitOfWorkFactory.newInstance(
				new List<SObjectType>{ Account.SObjectType },
				customDML
		);
		unitOfWork.registerNew(myAccount);
		unitOfWork.commitWork();

		// Then the Custom DML is used by the unit of Work
		System.assert(customDML.isInsertCalled, 'Oops, custom DML was not called');
	}

	@IsTest
	private static void callingMockedUnitOfWorkWithCustomObjectTypesAndDML()
	{
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_ISObjectUnitOfWork mockUow = (fflib_ISObjectUnitOfWork)mocks.mock(fflib_ISObjectUnitOfWork.class);
		TestUnitOfWorkFactory.setMock(mockUow);
		
		// Given a custom DML class and a new record
		CustomDML customDML = new CustomDML();
		Account myAccount = new Account(Name = 'Test Account');

		// When the unit of work is instantiated from the Application Class and the record is registered and commited
		fflib_ISObjectUnitOfWork uow = TestUnitOfWorkFactory.newInstance(
				new List<SObjectType>{ Account.SObjectType },
				customDML
		);
		uow.registerNew(myAccount);
		uow.commitWork();

		// Then the Custom DML should not be used by the unit of Work
		System.assert(!customDML.isInsertCalled, 'Oops, custom DML was called');
	}

	public class CustomDML implements fflib_SObjectUnitOfWork.IDML
	{
		public boolean isInsertCalled = false;
		public boolean isUpdateCalled = false;
		public boolean isDeleteCalled = false;
		public boolean isPublishCalled = false;
		public Boolean isEmptyRecycleBinCalled = false;

		public void dmlInsert(List<SObject> objList){
			this.isInsertCalled = true;
		}
		public void dmlUpdate(List<SObject> objList){
			this.isUpdateCalled = true;
		}
		public void dmlDelete(List<SObject> objList){
			this.isDeleteCalled = true;
		}
		public void eventPublish(List<SObject> objList)
		{
			this.isPublishCalled = true;
		}
		public void emptyRecycleBin(List<SObject> objList)
		{
			this.isEmptyRecycleBinCalled = true;
		}
	}

	// Configure and create the ServiceFactory for this Application
	public static final fflib_Application.ServiceFactory TestServiceFactory = 
		new fflib_Application.ServiceFactory( 
			new Map<Type, Type> {
					IOpportunitiesService.class => OpportunitiesServiceImpl.class,
					IAccountsService.class => AccountsServiceImpl.class });

	// Configure and create the UnitOfWorkFactory for this Application
	public static final fflib_Application.UnitOfWorkFactory TestUnitOfWorkFactory = 
		new fflib_Application.UnitOfWorkFactory(
				new List<SObjectType> { 
					Account.SObjectType,
					Opportunity.SObjectType,
					OpportunityLineItem.SObjectType });	

	// Configure and create the SelectorFactory for this Application
	public static final fflib_Application.SelectorFactory TestSelectorFactory = 
		new fflib_Application.SelectorFactory(
			new Map<SObjectType, Type> {
					Account.SObjectType => AccountsSelector.class,
					Opportunity.SObjectType => OpportuntiesSelector.class });

	// Configure and create the DomainFactory for this Application
	public static final fflib_Application.DomainFactory TestDomainFactory = 
		new fflib_Application.DomainFactory(
			fflib_ApplicationTest.TestSelectorFactory,
			new Map<SObjectType, Type> {
					Account.SObjectType => AccountsConstructor.class,
					Opportunity.SObjectType => OpportuntiesConstructor.class,
					Contact.SObjectType => ContactsConstructor.class });

	public class Accounts 
		extends fflib_SObjectDomain
		implements IAccounts 
	{
		public Accounts(List<Account> sObjectList)
		{
			super(sObjectList);
		}

		public Accounts(List<SObject> sObjectList, SObjectType sObjectType)
		{
			super(sObjectList, sObjectType);
		}
	}			

	public class AccountsConstructor implements fflib_SObjectDomain.IConstructable2
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new Accounts(sObjectList);
		}

		public fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sObjectType)
		{
			return new Accounts(sObjectList, sObjectType);
		}		
	}	

	public class Opportunties 
		extends fflib_SObjectDomain
		implements IOpportunties
	{
		public Opportunties(List<Opportunity> sObjectList)
		{
			super(sObjectList);
		}

		public Opportunties(List<SObject> sObjectList, SObjectType sObjectType)
		{
			super(sObjectList, sObjectType);
		}		
	}	

	public class OpportuntiesConstructor implements fflib_SObjectDomain.IConstructable2
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new Opportunties(sObjectList);
		}

		public fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sObjectType)
		{
			return new Opportunties(sObjectList, sObjectType);
		}		
	}

	public class Contacts 
		extends fflib_SObjectDomain
		implements IContacts
	{
		public Contacts(List<Opportunity> sObjectList)
		{
			super(sObjectList);
		}

		public Contacts(List<SObject> sObjectList, SObjectType sObjectType)
		{
			super(sObjectList, sObjectType);
		}
	}			

	// Intentionally does not support IConstructable or IConstructable2 interfaces in order to support testing
	public class ContactsConstructor
	{

	}		

	public class OpportuntiesSelector 
		extends fflib_SObjectSelector
		implements IOpportuntiesSelector
	{
		public List<Schema.SObjectField> getSObjectFieldList()
		{
			return new List<Schema.SObjectField> {
				Opportunity.Name,
				Opportunity.Id
			};
		}
		
		public Schema.SObjectType getSObjectType()
		{
			return Opportunity.sObjectType;
		}
	}
	
	public class AccountsSelector 
		extends fflib_SObjectSelector
		implements IAccountsSelector
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

	public interface IOpportunties extends fflib_ISObjectDomain { }

	public interface IAccounts extends fflib_ISObjectDomain { }

	public interface IContacts extends fflib_ISObjectDomain { }

	public interface IOpportuntiesSelector extends fflib_ISObjectSelector { }

	public interface IAccountsSelector extends fflib_ISObjectSelector { }

	public interface IContactService { }

	public interface IOpportunitiesService { }

	public interface IAccountsService { }

	public class OpportunitiesServiceImpl implements IOpportunitiesService { }

	public class AccountsServiceImpl implements IAccountsService { }
}
