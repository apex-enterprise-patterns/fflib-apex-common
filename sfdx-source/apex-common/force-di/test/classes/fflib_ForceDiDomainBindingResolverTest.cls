/**
 * File Name: fflib_DomainFactoryImpTest
 * Description: Unit test class for the Domain Factory Implementation class
 *
 * @author : architect ir. Wilhelmus G.J. Velzeboer
 */
@IsTest(IsParallel=true)
private class fflib_ForceDiDomainBindingResolverTest
{
	private static final String ACCOUNT_BINDING = 'TEST.domain.Account';

	@IsTest
	static void itShouldAddTheTestBinding()
	{
		// GIVEN a mock binding
		configureInjectorWithBindingForAccount();

		// WHEN we try to get the mock binding from the di_Injector
		Object obj = di_Injector.Org.getInstance(ACCOUNT_BINDING);

		// THEN it should be returned
		System.assert(obj instanceof fflib_TestAccounts.Constructor, 'Incorrect instance returned');
	}

	@IsTest
	static void itShouldReplaceTheDomainBindingForAMock()
	{
		// GIVEN an injector with a binding for Accounts
		configureInjectorWithBindingForAccount();
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_ForceDiDomainBindingResolver domainFactory = new fflib_ForceDiDomainBindingResolver('TEST', getSelectorFactoryMock(mocks));
		domainFactory.replaceWith(Schema.Account.SObjectType, new fflib_TestAccountsMock.Constructor());

		// WHEN we replace that binding in the injector
		System.Test.startTest();
		fflib_IDomain domain = domainFactory.newInstance(new List<Account> {new Account()});
		System.Test.stopTest();

		// THEN the injector should return the replacement
		System.assert(domain instanceof fflib_TestAccountsMock, 'Replacement of the domain class did not work');
	}

	@IsTest
	static void itShouldSetAMock()
	{
		// GIVEN an injector with a binding for Accounts
		configureInjectorWithBindingForAccount();
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_ForceDiDomainBindingResolver domainFactory = new fflib_ForceDiDomainBindingResolver('TEST', getSelectorFactoryMock(mocks));
		fflib_TestAccounts domainMock = (fflib_TestAccounts) mocks.mock(fflib_TestAccounts.class);
		mocks.startStubbing();
		mocks.when(domainMock.getType()).thenReturn(Schema.Account.SObjectType);
		mocks.stopStubbing();

		// WHEN we replace the binding for a mocked class
		System.Test.startTest();
		domainFactory.setMock(domainMock);
		fflib_IDomain domain = domainFactory.newInstance(new List<Account> {new Account()});
		Object result = domain.getType();
		System.Test.stopTest();

		// THEN it should use the mocked class
		System.assert(domain == domainMock, 'Incorrect returned mock version of the domain');
		System.assertEquals(Schema.Account.SObjectType, result, 'Incorrect returned SObjectType');
	}

	@IsTest
	static void itShouldThrowAnExceptionOnBindingWithNoConstructor()
	{
		// GIVEN an Injector with an incorrect binding for Accounts Constructor
		di_Injector.Org.Bindings.set(
				new di_Module()
						.bind(ACCOUNT_BINDING).to(fflib_TestAccounts.InvalidConstructor.class)
		);
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_ForceDiDomainBindingResolver domainFactory = new fflib_ForceDiDomainBindingResolver('TEST', getSelectorFactoryMock(mocks));

		// WHEN we try to get the binding for Accounts
		System.Test.startTest();
		Boolean exceptionThrown = false;
		try
		{
			domainFactory.newInstance(new List<Account> {new Account()});
		}
		catch (fflib_ForceDiDomainBindingResolver.DeveloperException e)
		{
			exceptionThrown = true;
		}
		System.Test.stopTest();

		// THEN it should throw an fflib_DeveloperException
		System.assert(exceptionThrown, 'It should have thrown an fflib_DeveloperException due to a missing binding');
	}

	@IsTest
	static void itShouldThrowExceptionWhenItCanNotGetTheSObjectType()
	{
		// GIVEN a domain factory
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_ForceDiDomainBindingResolver domainFactory = new fflib_ForceDiDomainBindingResolver('TEST', getSelectorFactoryMock(mocks));

		// WHEN we try to get the domain class for an SObject List
		System.Test.startTest();
		Boolean exceptionThrown = false;
		try
		{
			domainFactory.newInstance(new List<SObject>());
		}
		catch (fflib_ForceDiDomainBindingResolver.DeveloperException e)
		{
			exceptionThrown = true;
		}
		System.Test.stopTest();

		// THEN Is should throw an exception
		System.assert(exceptionThrown, 'It should have thrown an fflib_DeveloperException due to a unknown SObjectType');
	}

	@IsTest
	static void itShouldStillBeAbleToConstructTheDomainWithLegacyConstructor()
	{
		// GIVEN an Injector with a legacy binding for Accounts constructor
		di_Injector.Org.Bindings.set(
				new di_Module()
						.bind(ACCOUNT_BINDING).to(fflib_TestAccounts.LegacyConstructor.class)
		);
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_ForceDiDomainBindingResolver domainFactory = new fflib_ForceDiDomainBindingResolver('TEST', getSelectorFactoryMock(mocks));

		// WHEN we try to get the binding for Accounts
		System.Test.startTest();

		fflib_IDomain result = domainFactory.newInstance(new List<Account> {new Account()});
		System.Test.stopTest();

		// THEN
		System.assert(result instanceof fflib_TestAccounts, 'Unable to use legacy constructor to construct domain');
	}

	@IsTest
	static void itShouldConstructDomainViaSelectorFactory()
	{
		// GIVEN a domain factory
		configureInjectorWithBindingForAccount();
		Set<Id> recordIds = new Set<Id>
		{
				fflib_IDGenerator.generate(Schema.Account.SObjectType),
				fflib_IDGenerator.generate(Schema.Account.SObjectType)
		};
		List<Account> records = new List<Account>
		{
				new Account(Id = fflib_IDGenerator.generate(Schema.Account.SObjectType)),
				new Account(Id = fflib_IDGenerator.generate(Schema.Account.SObjectType))
		};
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_ForceDiSelectorBindingResolver selectorFactoryMock = getSelectorFactoryMock(mocks);
		fflib_ForceDiDomainBindingResolver domainFactory = new fflib_ForceDiDomainBindingResolver('TEST', selectorFactoryMock);
		fflib_TestAccounts domainMock = (fflib_TestAccounts) mocks.mock(fflib_TestAccounts.class);
		mocks.startStubbing();
		mocks.when(selectorFactoryMock.selectById(recordIds)).thenReturn(records);
		mocks.stopStubbing();

		// WHEN we construct the domain with just the Ids
		fflib_IDomain domain = domainFactory.newInstance(recordIds);

		// THEN The constructed domain should contain the records
		System.assert(domain instanceof fflib_TestAccounts, 'Incorrect instance of domain returned');
		System.assert(records.equals(domain.getObjects()), 'Domain does not contain the correct records');
		((fflib_ForceDiSelectorBindingResolver) mocks.verify(selectorFactoryMock)).selectById(recordIds);
	}

	private static void configureInjectorWithBindingForAccount()
	{
		di_Injector.Org.Bindings.set(
				new di_Module()
						.bind(ACCOUNT_BINDING).to(fflib_TestAccounts.Constructor.class)
		);
	}


	private static fflib_ForceDiSelectorBindingResolver getSelectorFactoryMock(fflib_ApexMocks mocks)
	{
		return  (fflib_ForceDiSelectorBindingResolver) mocks.mock(fflib_ForceDiSelectorBindingResolver.class);
	}
}