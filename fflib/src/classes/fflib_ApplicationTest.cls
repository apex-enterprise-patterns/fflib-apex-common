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


@IsTest
private class fflib_ApplicationTest 
{
	@IsTest
	private static void callingDomainFactoryShouldGiveRegisteredImplsAndMocks()
	{
		// Registered Accounts domain class by SObject List
		Id testAccountId = fflib_IDGenerator.generate(Account.SObjectType);
		fflib_ISObjectDomain domainObjectAcct = 
			Domain.newInstance(
				new List<Account> 
					{ new Account( 
						Id = testAccountId,
						Name = 'Test Account') });
		System.assert(domainObjectAcct instanceof AccountsDomain);
		System.assertEquals(testAccountId, domainObjectAcct.getRecords()[0].Id);

		// Registered Accounts domain class by SObject List
		testAccountId = fflib_IDGenerator.generate(Account.SObjectType);
		domainObjectAcct = 
			Domain.newInstance(
				new List<SObject> 
					{ new Account( 
						Id = testAccountId,
						Name = 'Test Account') }
				, Account.SObjectType);
		System.assert(domainObjectAcct instanceof AccountsDomain);
		System.assertEquals(testAccountId, domainObjectAcct.getRecords()[0].Id);		

		// Registered Opportunities domain class by SObject List
		Id testOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
		fflib_ISObjectDomain domainObjectOpp = 
			Domain.newInstance(
				new List<Opportunity> 
					{ new Opportunity( 
						Id = testOpportunityId,
						Name = 'Test Opportunity') });
		System.assertEquals(testOpportunityId, domainObjectOpp.getRecords()[0].Id);		
		System.assert(domainObjectOpp instanceof OpportuntiesDomain);

		// Test failure for creating new instance using IConstructable2
		// for domain class that does not support it
		testOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
		domainObjectOpp = 
			Domain.newInstance(
				new List<SObject> 
					{ new Opportunity( 
						Id = testOpportunityId,
						Name = 'Test Opportunity') }
				, Opportunity.SObjectType);
		System.assertEquals(testOpportunityId, domainObjectOpp.getRecords()[0].Id);		
		System.assert(domainObjectOpp instanceof OpportuntiesDomain);

		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		mocks.startStubbing();		
		fflib_ISObjectDomain domainMock = new fflib_SObjectMocks.SObjectDomain(mocks);
		mocks.when(domainMock.sObjectType()).thenReturn(Account.SObjectType);
		mocks.stopStubbing();		
		Domain.setMock(domainMock);

		// When
		domainObjectAcct = 
			Domain.newInstance(
				new List<Account> 
					{ new Account( 
						Id = testAccountId,
						Name = 'Test Account') });

		// Then
		System.assert(domainObjectAcct instanceof fflib_SObjectMocks.SObjectDomain);

		// When
		domainObjectAcct = 
			Domain.newInstance(
				new List<SObject> 
					{ new Account( 
						Id = testAccountId,
						Name = 'Test Account') }
				, Account.SObjectType);

		// Then
		System.assert(domainObjectAcct instanceof fflib_SObjectMocks.SObjectDomain);		
	}

	@IsTest
	private static void callingDomainFactoryWithIdsShouldGiveRegisteredImpls()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		mocks.startStubbing();
		fflib_ISObjectSelector selectorMock = new fflib_SObjectMocks.SObjectSelector(mocks);
		Id testAccountId = fflib_IDGenerator.generate(Account.SObjectType);
		List<Account> accounts = 
			new List<Account> 
				{ new Account( 
					Id = testAccountId,
					Name = 'Test Account') };
		Set<Id> accountIds = new Map<Id, Account>(accounts).keySet();
		mocks.when(selectorMock.selectSObjectsById(accountIds)).thenReturn(accounts);
		mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
		mocks.stopStubbing();

		// When
		Selector.setMock(selectorMock);
		fflib_ISObjectDomain domainObjectAcc = Domain.newInstance(new Set<Id> { testAccountId });

		// Then
		List<Account> assertAccounts = (List<Account>) domainObjectAcc.getRecords();
		System.assert(domainObjectAcc instanceof AccountsDomain);
		System.assertEquals(testAccountId, domainObjectAcc.getRecords()[0].Id);		
		System.assertEquals(1, assertAccounts.size());
		System.assertEquals(testAccountId, assertAccounts[0].Id);
		System.assertEquals('Test Account', assertAccounts[0].Name);
	}

	@IsTest
	private static void callingDomainFactoryWithGenericListShouldGiveException()
	{
		try {
			Domain.newInstance(new List<SObject>());
			System.assert(false, 'Expected exception');
		} catch (fflib_Application.DeveloperException e) {
			System.assertEquals('Unable to determine SObjectType', e.getMessage());
		}
	}

	@IsTest
	private static void callingDomainFactoryWithNoSObjectTypeShouldGiveException()
	{
		try {
			Domain.newInstance(new List<SObject>(), null);
			System.assert(false, 'Expected exception');
		} catch (fflib_Application.DeveloperException e) {
			System.assertEquals('Must specify sObjectType', e.getMessage());
		}
	}	

	@IsTest
	private static void callingDomainFactoryWithInAccessableConstructorShouldGiveException()
	{
		try {
			Domain.newInstance(new List<Product2>{ new Product2(Name = 'Test Product') });
			System.assert(false, 'Expected exception');
		} catch (fflib_Application.DeveloperException e) {
			System.assertEquals('Domain constructor class not found for SObjectType Product2', e.getMessage());
		}

		try {
			Domain.newInstance(new List<SObject>{ new Product2(Name = 'Test Product') }, Product2.SObjectType);
			System.assert(false, 'Expected exception');
		} catch (fflib_Application.DeveloperException e) {
			System.assertEquals('Domain constructor class not found for SObjectType Product2', e.getMessage());
		}		
	}

	@IsTest
	private static void callingDomainFactoryWithContructorClassThatDoesNotSupportIConstructableShouldGiveException()
	{
		try {
			Domain.newInstance(new List<Contact>{ new Contact(LastName = 'TestContactLName') });
			System.assert(false, 'Expected exception');
		} catch (System.TypeException e) {
			System.assertEquals('Invalid conversion from runtime type fflib_ApplicationTest.ContactsConstructor to fflib_SObjectDomain.IConstructable', e.getMessage());
		}	

		try {
			Domain.newInstance(new List<SObject>{ new Contact(LastName = 'TestContactLName') }, Contact.SObjectType);
			System.assert(false, 'Expected exception');
		} catch (System.TypeException e) {
			System.assertEquals('Invalid conversion from runtime type fflib_ApplicationTest.ContactsConstructor to fflib_SObjectDomain.IConstructable2', e.getMessage());
		}		
	}	

	@IsTest
	private static void callingUnitOfWorkFactoryShouldGivenStandardImplsAndMockImpls()
	{
		// Standard behaviour
		System.assert(UnitOfWork.newInstance() instanceof fflib_SObjectUnitOfWork);
 		
		// Mocking behaviour
		UnitOfWork.setMock(new fflib_SObjectMocks.SObjectUnitOfWork(new fflib_ApexMocks()));
		System.assert(UnitOfWork.newInstance() instanceof fflib_SObjectMocks.SObjectUnitOfWork);
	}

	@IsTest
	private static void callingServiceFactoryShouldGiveRegisteredImplsAndMockImpls()
	{
		// Standard behaviour
		System.assert(Service.newInstance(IAccountService.class) instanceof AccountsServiceImpl);
		System.assert(Service.newInstance(IOpportunitiesService.class) instanceof OpportunitiesServiceImpl);
		try {
			Service.newInstance(IContactService.class);
			System.assert(false, 'Expected exception');
		} catch (fflib_Application.DeveloperException e) {
			System.assertEquals('No implementation registered for service interface ' + IContactService.class.getName(), e.getMessage());
		}

		// Mocking behaviour		
		Service.setMock(IAccountService.class, new AccountsServiceMock());
		System.assert(Service.newInstance(IOpportunitiesService.class) instanceof OpportunitiesServiceImpl);
		System.assert(Service.newInstance(IAccountService.class) instanceof AccountsServiceMock);
	}

	@IsTest
	private static void callingSelectorFactoryShouldGiveRegisteredImpls()
	{
		// Standard behaviour
		System.assert(Selector.newInstance(Account.SObjectType) instanceof AccountsSelector);
		System.assert(Selector.newInstance(Opportunity.SObjectType) instanceof OpportuntiesSelector);
		try {
			Selector.newInstance(User.SObjectType);
			System.assert(false, 'Expected exception');
		} catch (fflib_Application.DeveloperException e) {
			System.assertEquals('Selector class not found for SObjectType User', e.getMessage());
		}
	}

	@IsTest
	private static void callingSelectorFactorySelectByIdWithEmptyListShouldGiveException()
	{
		try {
			Selector.selectById(null);
			System.assert(false, 'Expected exception');
		} catch (fflib_Application.DeveloperException e) {
			System.assertEquals('Invalid record Id\'s set', e.getMessage());
		}
		try {
			Selector.selectById(new Set<Id>());
			System.assert(false, 'Expected exception');
		} catch (fflib_Application.DeveloperException e) {
			System.assertEquals('Invalid record Id\'s set', e.getMessage());
		}
	}

	@IsTest
	private static void callingSelectorFactorySelectByIdWithMixedIdTypeListShouldGiveException()
	{
		try {
			Selector.selectById(
				new Set<Id> { 
					fflib_IDGenerator.generate(Opportunity.SObjectType), 
					fflib_IDGenerator.generate(Account.SObjectType) });
			System.assert(true, 'Expected exception');
		} catch (fflib_Application.DeveloperException e) {
			System.assertEquals('Unable to determine SObjectType, Set contains Id\'s from different SObject types', e.getMessage());
		}		
	}

	@IsTest
	private static void callingSelectoryFactorySelectByIdShouldReturnResults()
	{	
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		mocks.startStubbing();
		fflib_ISObjectSelector selectorMock = new fflib_SObjectMocks.SObjectSelector(mocks);
		Id testAccountId = fflib_IDGenerator.generate(Account.SObjectType);
		List<Account> accounts = 
			new List<Account> 
				{ new Account( 
					Id = testAccountId,
					Name = 'Test Account') };
		Set<Id> accountIds = new Map<Id, Account>(accounts).keySet();
		mocks.when(selectorMock.selectSObjectsById(accountIds)).thenReturn(accounts);
		mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
		mocks.stopStubbing();

		// When
		Selector.setMock(selectorMock);
		List<Account> assertAccounts = Selector.selectById(accountIds);

		// Then
		System.assert(Selector.newInstance(Account.SObjectType) instanceof fflib_SObjectMocks.SObjectSelector);
		System.assertEquals(1, assertAccounts.size());
		System.assertEquals(testAccountId, assertAccounts[0].Id);
		System.assertEquals('Test Account', assertAccounts[0].Name);
		System.assert(Selector.newInstance(Opportunity.SObjectType) instanceof OpportuntiesSelector);
	}


	@IsTest
	private static void callingSelectoryFactorySselectByRelationshipPassRelatedIds()
	{	
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		mocks.startStubbing();
		fflib_ISObjectSelector selectorMock = new fflib_SObjectMocks.SObjectSelector(mocks);
		Id testAccountId = fflib_IDGenerator.generate(Account.SObjectType);
		Id testOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
		List<Account> accounts = 
			new List<Account> 
				{ new Account( 
					Id = testAccountId,
					Name = 'Test Account') };
		Set<Id> accountIds = new Map<Id, Account>(accounts).keySet();
		mocks.when(selectorMock.selectSObjectsById(accountIds)).thenReturn(accounts);
		mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
		mocks.stopStubbing();
		Selector.setMock(selectorMock);

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
		List<Account> assertAccounts = Selector.selectByRelationship(opportunties, Opportunity.AccountId);

		// Then
		System.assert(Selector.newInstance(Account.SObjectType) instanceof fflib_SObjectMocks.SObjectSelector);
		System.assertEquals(1, assertAccounts.size());
		System.assertEquals(testAccountId, assertAccounts[0].Id);
		System.assertEquals('Test Account', assertAccounts[0].Name);
		System.assert(Selector.newInstance(Opportunity.SObjectType) instanceof OpportuntiesSelector);
	}


	// Configure and create the ServiceFactory for this Application
	public static final fflib_Application.ServiceFactory Service = 
		new fflib_Application.ServiceFactory( 
			new Map<Type, Type> {
					IOpportunitiesService.class => OpportunitiesServiceImpl.class,
					IAccountService.class => AccountsServiceImpl.class });

	// Configure and create the UnitOfWorkFactory for this Application
	public static final fflib_Application.UnitOfWorkFactory UnitOfWork = 
		new fflib_Application.UnitOfWorkFactory(
				new List<SObjectType> { 
					Account.SObjectType,
					Opportunity.SObjectType,
					OpportunityLineItem.SObjectType });	

	// Configure and create the SelectorFactory for this Application
	public static final fflib_Application.SelectorFactory Selector = 
		new fflib_Application.SelectorFactory(
			new Map<SObjectType, Type> {
					Account.SObjectType => AccountsSelector.class,
					Opportunity.SObjectType => OpportuntiesSelector.class });

	// Configure and create the DomainFactory for this Application
	public static final fflib_Application.DomainFactory Domain = 
		new fflib_Application.DomainFactory(
			fflib_ApplicationTest.Selector,
			new Map<SObjectType, Type> {
					Account.SObjectType => AccountsConstructor.class,
					Opportunity.SObjectType => OpportuntiesConstructor.class,
					Contact.SObjectType => ContactsConstructor.class });

	public class AccountsDomain extends fflib_SObjectDomain
	{
		public AccountsDomain(List<Account> sObjectList)
		{
			super(sObjectList);
		}

		public AccountsDomain(List<SObject> sObjectList, SObjectType sObjectType)
		{
			super(sObjectList, sObjectType);
		}
	}			

	public class AccountsConstructor implements fflib_SObjectDomain.IConstructable2
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new AccountsDomain(sObjectList);
		}

		public fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sObjectType)
		{
			return new AccountsDomain(sObjectList, sObjectType);
		}		
	}	

	public class OpportuntiesDomain extends fflib_SObjectDomain
	{
		public OpportuntiesDomain(List<Opportunity> sObjectList)
		{
			super(sObjectList);
		}

		public OpportuntiesDomain(List<SObject> sObjectList, SObjectType sObjectType)
		{
			super(sObjectList, sObjectType);
		}		
	}	

	public class OpportuntiesConstructor implements fflib_SObjectDomain.IConstructable2
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new OpportuntiesDomain(sObjectList);
		}

		public fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sObjectType)
		{
			return new OpportuntiesDomain(sObjectList, sObjectType);
		}		
	}

	public class ContactsDomain extends fflib_SObjectDomain
	{
		public ContactsDomain(List<Opportunity> sObjectList)
		{
			super(sObjectList);
		}

		public ContactsDomain(List<SObject> sObjectList, SObjectType sObjectType)
		{
			super(sObjectList, sObjectType);
		}
	}			

	// Intentionally does not support IConstructable or IConstructable2 interfaces in order to support testing
	public class ContactsConstructor
	{

	}		

	class OpportuntiesSelector extends fflib_SObjectSelector
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
	
	class AccountsSelector extends fflib_SObjectSelector
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

	public interface IContactService { }

	public interface IOpportunitiesService { }

	public interface IAccountService { }

	public class OpportunitiesServiceImpl implements IOpportunitiesService { }

	public class AccountsServiceImpl implements IAccountService { }

	public class AccountsServiceMock implements IAccountService { }
}