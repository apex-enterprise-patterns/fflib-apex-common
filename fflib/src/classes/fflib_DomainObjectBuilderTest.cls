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
private class fflib_DomainObjectBuilderTest
{
	/**
     * @description Flag passed to helper methods to determine which test to run
     **/
	private enum MethodMode { Build, BuildNew, Persist }

	/**
     * @description UnitOfWork SObjectTypes used for persist methods
     **/	
	private static List<Schema.SObjectType> UOW_SOBJECTTYPES = 
		new Schema.SObjectType[] { 
			Account.SObjectType, 
			Contact.SObjectType, 
			Product2.SObjectType,
			PriceBook2.SObjectType,
			PriceBookEntry.SObjectType,
			Opportunity.SObjectType,
			OpportunityLineItem.SObjectType };

	private static void runBuild(Boolean buildNew)
	{
		// Given
		TestAccountBuilder acctBuilder = anAccount();
		Account beforeBuildRecord = acctBuilder.Record; // SObject available on builder instantiation

		// When
		Account acct = buildNew ? acctBuilder.buildNew() : acctBuilder.build();

		// Then
		System.assertEquals(true, acctBuilder.IsBuilt);
		System.assertEquals(false, acctBuilder.IsRegistered);
		System.assertNotEquals(null, acct);
		System.assertNotEquals(null, acctBuilder.Record);
		System.assertEquals(beforeBuildRecord, acctBuilder.Record); // should be same SObject
		System.assertEquals(acct, acctBuilder.Record); // should be same SObject
		if (buildNew) {
			System.assertEquals(null, acctBuilder.Record.Id);
			System.assertEquals(null, acct.Id);
		} else {
			System.assertNotEquals(null, acctBuilder.Record.Id);
			System.assertNotEquals(null, acct.Id);
		}
		System.assertEquals(2, acctBuilder.getDomainObjectBuilderEventsFired().size());
		System.assertEquals(buildNew, acctBuilder.getDomainObjectBuilderEventsFired().get('beforeBuild'));
		System.assertEquals(acct, acctBuilder.getDomainObjectBuilderEventsFired().get('afterBuild'));
	}

	private static void runBuildTwice(Boolean buildNewFirstCall, Boolean buildNewSecondCall)
	{
		// Given
		TestAccountBuilder acctBuilder = anAccount();
		Account acct = buildNewFirstCall ? acctBuilder.buildNew() : acctBuilder.build();

		// When
		fflib_DomainObjectBuilder.DomainObjectBuilderException caughtEx;
		try {
			Account acct2 = buildNewSecondCall ? acctBuilder.buildNew() : acctBuilder.build();
		} catch (fflib_DomainObjectBuilder.DomainObjectBuilderException ex) {
			caughtEx = ex;
		}

		// Then
		System.assertNotEquals(null, caughtEx, 'Expected exception');			
		System.assertEquals('Builder has already been built', caughtEx.getMessage());
	}

	private static void runBuildWithValues(Boolean buildNew)
	{
		// Given
		TestAccountBuilder acctBuilder = anAccount().withName('My Account');
		TestContactBuilder contactBuilder = aContact().withLastName('My Contact').withAccount(acctBuilder);

		// When
		Contact contact = buildNew ? contactBuilder.buildNew() : contactBuilder.build();

		// Then		
		System.assertNotEquals(null, acctBuilder.Record.Id);
		if (buildNew) {
			System.assertEquals(null, contactBuilder.Record.Id);
		} else {
			System.assertNotEquals(null, contactBuilder.Record.Id);
		}
		System.assertEquals(contact.LastName, 'My Contact');
		System.assertEquals(contactBuilder.Record.LastName, 'My Contact');
		System.assertEquals(acctBuilder.Record.Name, 'My Account');
		System.assertEquals(contact.AccountId, acctBuilder.Record.Id);

	}

	private static void runBuildAfterRegistering(Boolean buildNew)
	{
		// Given
		TestAccountBuilder acctBuilder = anAccount();
		acctBuilder.register();

		// When
		fflib_DomainObjectBuilder.DomainObjectBuilderException caughtEx;
		try {
			Account acct = buildNew ? acctBuilder.buildNew() : acctBuilder.build();
		} catch (fflib_DomainObjectBuilder.DomainObjectBuilderException ex) {
			caughtEx = ex;
		}

		// Then
		System.assertNotEquals(null, caughtEx, 'Expected exception');			
		System.assertEquals('Builder has already been registered', caughtEx.getMessage());		
	}

	private static void runBuildWithRelationshipThatWasBuiltNew(Boolean buildNew)
	{
		// Given
		TestAccountBuilder accountBuilder = anAccount();
		Account account = accountBuilder.buildNew();
		TestContactBuilder testContactBuilder = aContact().withAccount(accountBuilder);

		// When
		fflib_DomainObjectBuilder.DomainObjectBuilderException caughtEx;
		try {
			Contact contact = buildNew ? testContactBuilder.buildNew() : testContactBuilder.build();
		} catch (fflib_DomainObjectBuilder.DomainObjectBuilderException ex) {
			caughtEx = ex;
		}

		// Then
		System.assertNotEquals(null, caughtEx, 'Expected exception');			
		System.assertEquals(String.format('Field {0} contains value for a builder that was built as new', new List<String> { Contact.AccountId.getDescribe().getName() }), caughtEx.getMessage());			
	}

	private static void runRegisterAfterBuilding(Boolean buildNew)
	{
		// Given
		TestAccountBuilder acctBuilder = anAccount();
		Account acct = buildNew ? acctBuilder.buildNew() : acctBuilder.build();

		// When
		fflib_DomainObjectBuilder.DomainObjectBuilderException caughtEx;
		try {
			acctBuilder.register();
		} catch (fflib_DomainObjectBuilder.DomainObjectBuilderException ex) {
			caughtEx = ex;
		}

		// Then
		System.assertNotEquals(null, caughtEx, 'Expected exception');			
		System.assertEquals('Builder has already been built', caughtEx.getMessage());			
	}

	private static void runBuildWithRegisteredRelationship(Boolean buildNew)
	{
		// Given
		TestAccountBuilder acctBuilder = anAccount().register();
		TestContactBuilder contactBuilder = aContact().withAccount(acctBuilder);

		// When
		fflib_DomainObjectBuilder.DomainObjectBuilderException caughtEx;
		try {
			Contact contact = buildNew ? contactBuilder.buildNew() : contactBuilder.build();
		} catch (fflib_DomainObjectBuilder.DomainObjectBuilderException ex) {
			caughtEx = ex;
		}

		// Then
		System.assertNotEquals(null, caughtEx, 'Expected exception');			
		System.assertEquals(String.format('Field {0} contains value for a builder that is marked for registration', new List<String> { Contact.AccountId.getDescribe().getName() }), caughtEx.getMessage());
	}

	private static void verifySetThrowsException(TestContactBuilder contactBuilder, Boolean useRelationshipField)
	{
		// When
		fflib_DomainObjectBuilder.DomainObjectBuilderException caughtEx;		
		try {
			TestContactBuilder builder = useRelationshipField ? contactBuilder.withAccount(anAccount()) : contactBuilder.withLastName('TestLastName');
		} catch (fflib_DomainObjectBuilder.DomainObjectBuilderException ex) {
			caughtEx = ex;
		}

		// Then
		System.assertNotEquals(null, caughtEx, 'Expected exception');
		System.assertEquals('Builder has already been built', caughtEx.getMessage());
	}	

	private static void runPersistWithRelationshipThatWasBuilt(MethodMode mode)
	{
		// Given
		TestAccountBuilder accountBuilder = anAccount().withName('Test Account');
		if (MethodMode.Persist == mode) {
			accountBuilder.register();
			fflib_DomainObjectBuilder.persistRegistered(new fflib_SObjectUnitOfWork(UOW_SOBJECTTYPES));
		} else {
			Account account = (MethodMode.BuildNew == mode) ? accountBuilder.buildNew() : accountBuilder.build();
		}
		TestContactBuilder testContactBuilder = aContact().withLastName('Test Contact').withAccount(accountBuilder).register();		

		// When
		fflib_DomainObjectBuilder.DomainObjectBuilderException caughtEx;
		try {
			fflib_DomainObjectBuilder.persistRegistered(new fflib_SObjectUnitOfWork(UOW_SOBJECTTYPES));
		} catch (fflib_DomainObjectBuilder.DomainObjectBuilderException ex) {
			caughtEx = ex;
		}

		// Then
		System.assertNotEquals(null, caughtEx, 'Expected exception');			
		System.assertEquals(String.format('Field {0} contains value for a builder that has already been built', new List<String> { Contact.AccountId.getDescribe().getName() }), caughtEx.getMessage());
	}

	private static void runBuildRelationshipTree(Boolean buildNew)
	{
		// Given
		TestAccountBuilder accountBuilder1 = anAccount().withName('Test Account1');
		TestAccountBuilder accountBuilder2 = anAccount().withName('Test Account2');
		TestOpportunityBuilder opportunityBuilder1 = aClosedWonOpportunity().withAccount(accountBuilder2);
		TestOpportunityBuilder opportunityBuilder2 = opportunityBuilder1.but().withName('Built with but').withAccount(accountBuilder1);
		TestContactBuilder contactBuilder1 = aContact().withLastName('Jones').withAccount(accountBuilder1);
		TestContactBuilder contactBuilder2 = contactBuilder1.but().withLastName('Smith');

		// When
		Opportunity opportunity1 = buildNew ? opportunityBuilder1.buildNew() : opportunityBuilder1.build();
		Opportunity opportunity2 = buildNew ? opportunityBuilder2.buildNew() : opportunityBuilder2.build();	
		Contact contact1 = buildNew ? contactBuilder1.buildNew() : contactBuilder1.build();
		Contact contact2 = buildNew ? contactBuilder2.buildNew() : contactBuilder2.build();

		// Then
		Account account1 = accountBuilder1.Record;
		Account account2 = accountBuilder2.Record;					
		verifyRelationshipTree(account1, account2, contact1, contact2, opportunity1, opportunity2, buildNew);
	}

	private static SObject assertAndGet(Map<Id, SObject> records, Id searchForId)
	{
		System.assertNotEquals(null, searchForId);
		System.assertEquals(true, records.containsKey(searchForId));
		return records.get(searchForId);
	}

	private static void verifyRelationshipTree(Account account1, Account account2, Contact contact1, Contact contact2, Opportunity opportunity1, Opportunity opportunity2, Boolean buildNew)
	{
		System.assertNotEquals(null, account1.Id);
		System.assertNotEquals(null, account2.Id);
		System.assert(buildNew ? (null == opportunity1.Id) : (null != opportunity1.Id), 'Value for Opportunity1 Id was not expected');
		System.assert(buildNew ? (null == opportunity2.Id) : (null != opportunity2.Id), 'Value for Opportunity2 Id was not expected');
		System.assert(buildNew ? (opportunity1.Id == opportunity2.Id) : (opportunity1.Id != opportunity2.Id), 'Opportunity1 Id and Opportunity2 Id mismatch');
		System.assertEquals('Closed Won', opportunity1.StageName);
		System.assertEquals('Built with but', opportunity2.Name);
		System.assertNotEquals(opportunity1.Name, opportunity2.Name);
		System.assertNotEquals(null, opportunity1.AccountId);
		System.assertNotEquals(null, opportunity2.AccountId);
		System.assertNotEquals(opportunity1.AccountId, opportunity2.AccountId);
		System.assert(buildNew ? (null == contact1.Id) : (null != contact1.Id), 'Value for Contact1 Id was not expected');
		System.assert(buildNew ? (null == contact2.Id) : (null != contact2.Id), 'Value for Contact2 Id was not expected');
		System.assert(buildNew ? (contact1.Id == contact2.Id) : (contact1.Id != contact2.Id), 'Contact1 Id and Contact2 Id mismatch');
		System.assertEquals('Jones', contact1.LastName);			
	}

	private static void runDeepRelationshipTree(MethodMode mode)
	{
		// Given		
		TestProductBuilder prdBuilder = aProduct()
										.withName('My Test Product');

		TestPriceBookEntryBuilder pbeBuilder = aPriceBookEntryWithStandardPriceBook()
											.withUnitPrice(200)
											.withIsActive(true)
											.withProduct(prdBuilder);

		TestOpportunityLineItemBuilder oliBuilder = anOpportunityLineItem()
												.withQuantity(5)
												.withTotalPrice(500)
												.withPriceBookEntry(
													aPriceBookEntry()
														.withUnitPrice(100)
														.withIsActive(true)
														.withUseStandardPrice(false)
														.withProduct(prdBuilder)
														.withPriceBook(
															aPriceBook()
																.withName('My PriceBook')
																.withIsActive(true)))
												.withOpportunity(
													anOpportunity()
														.withName('My Test Opportunity')
														.withStageName('Prospecting')
														.withCloseDate(System.today())
														.withAccount(
															anAccount()
																.withName('My Test Account')));

		if (MethodMode.Persist == mode) {
			// When
			pbeBuilder.register();
			oliBuilder.register();
			fflib_DomainObjectBuilder.persistRegistered(new fflib_SObjectUnitOfWork(UOW_SOBJECTTYPES));

			// Then
			System.assertEquals(1, [SELECT COUNT() FROM Opportunity]);
			System.assertEquals(1, [SELECT COUNT() FROM OpportunityLineItem]);
			System.assertEquals(1, [SELECT COUNT() FROM PriceBook2]);
			System.assertEquals(2, [SELECT COUNT() FROM PriceBookEntry]);
			System.assertEquals(1, [SELECT COUNT() FROM Product2]);
			System.assertEquals(1, [SELECT COUNT() FROM Account]);

		} else {
			// When
			PriceBookEntry pbe = MethodMode.BuildNew == mode ? pbeBuilder.buildNew() : pbeBuilder.build();
			OpportunityLineItem oli = MethodMode.BuildNew == mode ? oliBuilder.buildNew() : oliBuilder.build();

			// Then
			System.assertNotEquals(null, prdBuilder.Record.Id);
			System.assert(MethodMode.BuildNew == mode ? pbe.Id == null : pbe.Id != null, 'Value for PriceBookEntry Id was not expected');
			System.assertEquals(prdBuilder.Record.Id, pbe.Product2Id);
			System.assert(MethodMode.BuildNew == mode ? oli.Id == null : null != oli.Id, 'Value for OpportunityLineItem Id was not expected');
			System.assertNotEquals(null, oli.OpportunityId);
			System.assertNotEquals(null, oli.PriceBookEntryId);
		}
	}

    /**
     * @description Confirms that creating a builder has the correct initial state
     **/
	@IsTest
	private static void testCreateBuilderInstance()
	{
		// Given
		TestAccountBuilder acctBuilder = anAccount();

		// When

		// Then
		System.assertNotEquals(null, acctBuilder.Record); // does not require build to have SObject instance created		
		System.assertEquals(false, acctBuilder.IsBuilt);
		System.assertEquals(false, acctBuilder.IsRegistered);
		System.assertEquals(null, acctBuilder.Record.Id);
		System.assertEquals(Account.SObjectType, acctBuilder.getSObjectType());
	}

    /**
     * @description Confirms that calling build results with a valid SObject that has an Id
     **/
	@IsTest
	private static void testBuild()
	{
		runBuild(false);
	}

    /**
     * @description Confirms that calling buildNew results with a valid SObject that does NOT have an Id
     **/
	@IsTest
	private static void testBuildNew()
	{
		runBuild(true);		
	}

    /**
     * @description Confirms that calling register results in the builder having the correct state
     **/
	@IsTest
	private static void testRegister()
	{
		// Given
		TestAccountBuilder acctBuilder = anAccount();
		Account beforeBuildRecord = acctBuilder.Record;

		// When
		acctBuilder.register();

		// Then
		System.assertEquals(false, acctBuilder.IsBuilt);		
		System.assertEquals(true, acctBuilder.IsRegistered);
		System.assertNotEquals(null, acctBuilder.Record);
		System.assertEquals(null, acctBuilder.Record.Id);
	}

    /**
     * @description Confirms that a builder cannot be built twice
     **/
	@IsTest
	private static void testBuildingTwiceThrowsException()
	{
		// build and build
		runBuildTwice(false, false);
		// build and buildNew
		runBuildTwice(false, true);
		// buildNew and buildNew
		runBuildTwice(true, true);
		// buildNew and build
		runBuildTwice(true, false);
	}

    /**
     * @description Confirms that a builder cannot be built if it is registered
     **/
	@IsTest
	private static void testBuildAfterRegisteringThrowsException()
	{
		runBuildAfterRegistering(false);
	}

    /**
     * @description Confirms that a builder cannot be builtnew if it is registered
     **/
	@IsTest
	private static void testBuildNewAfterRegisteringThrowsException()
	{
		runBuildAfterRegistering(true);
		runBuildAfterRegistering(false);
	}

    /**
     * @description Confirms that a builder cannot be registered if it has been built
     **/
	@IsTest
	private static void testRegisteringAfterBuildThrowsException()
	{
		runRegisterAfterBuilding(false);
		runRegisterAfterBuilding(true);
	}

    /**
     * @description Confirms that a builder cannot be registered twice
     **/
	@IsTest
	private static void testRegisteringTwiceThrowsException()
	{
		// Given
		TestAccountBuilder acctBuilder = anAccount();

		// When
		acctBuilder.register();

		// Then
		System.assertEquals(true, acctBuilder.IsRegistered);
		System.assertEquals(false, acctBuilder.IsBuilt);		
		System.assertEquals(null, acctBuilder.Record.Id);

		// When
		fflib_DomainObjectBuilder.DomainObjectBuilderException caughtEx;
		try {
			acctBuilder.register();
		} catch (fflib_DomainObjectBuilder.DomainObjectBuilderException ex) {
			caughtEx = ex;
		}

		// Then
		System.assertNotEquals(null, caughtEx, 'Expected exception');			
		System.assertEquals('Builder has already been registered', caughtEx.getMessage());			
	}

    /**
     * @description Confirms that a builder field data cannot be changed after it has been built
     **/
	@IsTest
	private static void testChangingDataAfterBuildThrowsException()
	{
		// Given
		TestContactBuilder contactBuilder = aContact();
		Contact contact = contactBuilder.build();

		// When and Then - Non relationship field
		verifySetThrowsException(contactBuilder, false);
		// When and Then - relationship field
		verifySetThrowsException(contactBuilder, true);
	}

    /**
     * @description Confirms that a builder field data cannot be changed after it has been builtnew
     **/
	@IsTest
	private static void testChangingDataAfterBuildNewThrowsException()
	{
		// Given
		TestContactBuilder contactBuilder = aContact();
		Contact contact = contactBuilder.buildNew();

		// When and Then - Non relationship field
		verifySetThrowsException(contactBuilder, false);
		// When and Then - relationship field
		verifySetThrowsException(contactBuilder, true);
	}

    /**
     * @description Confirms that a builder field data cannot be changed after it has been persisted
     **/
	@IsTest
	private static void testChangingDataAfterPersistThrowsException()
	{
		// Given
		TestContactBuilder contactBuilder = aContact().withLastName('Test Contact').register();
		fflib_DomainObjectBuilder.persistRegistered(new fflib_SObjectUnitOfWork(UOW_SOBJECTTYPES));

		// When and Then - Non relationship field
		verifySetThrowsException(contactBuilder, false);
		// When and Then - relationship field
		verifySetThrowsException(contactBuilder, true);
	}

    /**
     * @description Confirms that a builder that contains a relationship field that references a builder
     *              that has been registered cannot be built
     **/
	@IsTest
	private static void testBuildWhenRelationshipIsRegisteredThrowsException()
	{
		// build
		runBuildWithRegisteredRelationship(false);
		// buildNew
		runBuildWithRegisteredRelationship(true);
	}

    /**
     * @description Confirms that calling persistRegistered results with a valid SObject in the database
     **/
	@IsTest
	private static void testPersistRegistered()
	{
		// Given
		Integer numAccounts = 5;		
		List<TestAccountBuilder> builders = new List<TestAccountBuilder>();
		for (Integer i = 0; i < numAccounts; i++) {
			builders.add(anAccount().withName('Account' + i).register());
		}

		// When
		fflib_DomainObjectBuilder.persistRegistered(new fflib_SObjectUnitOfWork(UOW_SOBJECTTYPES));

		// Then
		Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
		System.assertEquals(builders.size(), accounts.size());		
		for (Integer i = 0; i < numAccounts; i++) {
			TestAccountBuilder builder = builders[i];
			System.assertEquals(true, builder.IsBuilt);
			System.assertEquals(false, builder.IsRegistered);
			System.assertNotEquals(null, builder.Record.Id);
			System.assert(accounts.containsKey(builder.Record.Id), 'Builder Id ' + builder.Record.Id + ' not found in database');
			System.assertEquals(builder.Record, accounts.get(builder.Record.Id));			
			System.assertEquals('Account' + i, accounts.get(builder.Record.Id).Name);
			System.assertEquals(2, builder.getDomainObjectBuilderEventsFired().size());
			System.assertEquals(builder.Record, builder.getDomainObjectBuilderEventsFired().get('beforeInsert'));
			System.assertEquals(builder.Record, builder.getDomainObjectBuilderEventsFired().get('afterInsert'));
		}
	}

    /**
     * @description Confirms that building results in all fields containing correct values
     **/
	@IsTest
	private static void testBuildingWithValuesHasCorrectValues()
	{
		runBuildWithValues(false);
		runBuildWithValues(true);
	}	

    /**
     * @description Confirms that persisting results in all fields containing correct values
     **/
	@IsTest
	private static void testPersistingWithValuesHasCorrectValues()
	{
		// Given
		Integer numAccounts = 5;
		List<TestAccountBuilder> accountBuilders = new List<TestAccountBuilder>();
		List<TestContactBuilder> contactBuilders = new List<TestContactBuilder>();
		for (Integer i = 0; i < numAccounts; i++) {
			TestAccountBuilder accountBuilder = anAccount().withName('My Account' + i).register();
			TestContactBuilder contactBuilder = aContact().withLastName('My Contact' + i).withAccount(accountBuilder).register();
			accountBuilders.add(accountBuilder);
			contactBuilders.add(contactBuilder);
		}

		// When
		fflib_DomainObjectBuilder.persistRegistered(new fflib_SObjectUnitOfWork(UOW_SOBJECTTYPES));

		// Then
		Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
		Map<Id, Contact> contacts = new Map<Id, Contact>([SELECT Id, LastName, AccountId FROM Contact]);
		System.assertEquals(numAccounts, accounts.size());
		System.assertEquals(numAccounts, contacts.size());
		for (Integer i = 0; i < numAccounts; i++) {
			TestAccountBuilder accountBuilder = accountBuilders[i];
			TestContactBuilder contactBuilder = contactBuilders[i];
			Account account = accountBuilder.Record;
			Contact contact = contactBuilder.Record;

			System.assertEquals(true, accounts.containsKey(account.Id));
			System.assertEquals(account, accounts.get(account.Id));
			System.assertEquals('My Account' + i, accounts.get(account.Id).Name);
			System.assertEquals(true, contacts.containsKey(contact.Id));
			System.assertEquals(contact, contacts.get(contact.Id));
			System.assertEquals('My Contact' + i, contacts.get(contact.Id).LastName);
			System.assertEquals(account.Id, contact.AccountId);
		}
	}

    /**
     * @description Confirms that copy constructor (clone) results in a builder instance
     *              with the same exact field values as the source instance
     **/
	@IsTest
	private static void testClone()
	{
		// Given
		TestAccountBuilder accountBuilder = anAccount().withName('Test Account');

		// When
		TestAccountBuilder clonedAccountBuilder = accountBuilder.but();

		// Then
		clonedAccountBuilder.assertEquals(accountBuilder);

		// When
		Account account = accountBuilder.build();
		Account clonedAccount = clonedAccountBuilder.withName('Test Account2').build();

		// Then
		System.assertEquals('Test Account', account.Name);
		System.assertEquals('Test Account2', clonedAccount.Name);
	}

    /**
     * @description Confirms that builder that contains a field value to another builder
     *              that has been built can be built
     **/
	@IsTest
	private static void testBuildWithRelationshipThatIsAlreadyBuilt()
	{
		// Build Account after estaliblishing relationship
		// Given
		TestAccountBuilder accountBuilder = anAccount();
		TestContactBuilder contactBuilder = aContact().withAccount(accountBuilder);
		Account account = accountBuilder.build();

		// When
		Contact contact = contactBuilder.build();

		// Then
		System.assertNotEquals(null, contact.AccountId);		
		System.assertEquals(contact.AccountId, account.Id);

		// Before Account before establishing relationship
		// Given
		TestAccountBuilder accountBuilder2 = anAccount();
		Account account2 = accountBuilder2.build();
		TestContactBuilder contactBuilder2 = aContact().withAccount(accountBuilder2);

		// When
		Contact contact2 = contactBuilder2.build();

		// Then
		System.assertNotEquals(null, contact2.AccountId);
		System.assertEquals(contact2.AccountId, account2.Id);
	}

    /**
     * @description Confirms that builder that contains a field value to another builder
     *              that has been builtnew cannot be built
     **/
	@IsTest
	private static void testBuildWithRelationshipThatWasBuiltNewThrowsException()
	{
		runBuildWithRelationshipThatWasBuiltNew(false);
		runBuildWithRelationshipThatWasBuiltNew(true);
	}

    /**
     * @description Confirms that builder that contains a field value to another builder
     *              that has been built cannot be persisted
     **/
	@IsTest
	private static void testPersistWithRelationshipThatWasBuiltThrowsException()
	{
		runPersistWithRelationshipThatWasBuilt(MethodMode.Build);		
	}

    /**
     * @description Confirms that builder that contains a field value to another builder
     *              that has been builtnew cannot be persisted
     **/
	@IsTest
	private static void testPersistWithRelationshipThatWasBuiltNewThrowsException()
	{
		runPersistWithRelationshipThatWasBuilt(MethodMode.BuildNew);
	}

    /**
     * @description Confirms that builder that contains a field value to another builder
     *              that has been persisted cannot be persisted
     **/
	@IsTest
	private static void testPeristWithRelationshipThatWasPersistedThrowsException()
	{
		runPersistWithRelationshipThatWasBuilt(MethodMode.Persist);
	}

    /**
     * @description Confirms that builder can be persisted when one of its fields
     *              references another builder that has not been registered
     **/
	@IsTest
	private static void testPersistWithRelationshipThatIsNotRegistered()
	{
		// Given
		TestAccountBuilder accountBuilder = anAccount().withName('Test Account');
		TestContactBuilder contactBuilder = aContact().withLastName('Test Contact').withAccount(accountBuilder).register();

		// When
		fflib_DomainObjectBuilder.persistRegistered(new fflib_SObjectUnitOfWork(UOW_SOBJECTTYPES));

		// Then
		List<Account> accounts = [SELECT Id, Name FROM Account];
		List<Contact> contacts = [SELECT Id, LastName, AccountId FROM Contact];
		System.assertEquals(1, accounts.size());
		System.assertEquals(1, contacts.size());
		System.assertEquals(accounts[0].Id, contacts[0].AccountId);
		System.assertEquals(2, accountBuilder.getDomainObjectBuilderEventsFired().size());
		System.assertEquals(accountBuilder.Record, accountBuilder.getDomainObjectBuilderEventsFired().get('beforeInsert'));
		System.assertEquals(accountBuilder.Record, accountBuilder.getDomainObjectBuilderEventsFired().get('afterInsert'));	
		System.assertEquals(2, contactBuilder.getDomainObjectBuilderEventsFired().size());
		System.assertEquals(contactBuilder.Record, contactBuilder.getDomainObjectBuilderEventsFired().get('beforeInsert'));
		System.assertEquals(contactBuilder.Record, contactBuilder.getDomainObjectBuilderEventsFired().get('afterInsert'));	
	}

    /**
     * @description Confirms that multiple builders with several relationships can be persisted
     **/
	@IsTest
	private static void testPersistRegisteredRelationshipTree()
	{
		// Given
		TestAccountBuilder accountBuilder1 = anAccount().withName('Test Account1');
		TestAccountBuilder accountBuilder2 = anAccount().withName('Test Account2');		
		TestOpportunityBuilder opportunityBuilder1 = aClosedWonOpportunity().withAccount(accountBuilder2).register();
		TestOpportunityBuilder opportunityBuilder2 = opportunityBuilder1.but().withName('Built with but').withAccount(accountBuilder1).register();
		TestContactBuilder contactBuilder1 = aContact().withLastName('Jones').withAccount(accountBuilder1).register();
		TestContactBuilder contactBuilder2 = contactBuilder1.but().withLastName('Smith').register();

		// When
		fflib_DomainObjectBuilder.persistRegistered(new fflib_SObjectUnitOfWork(UOW_SOBJECTTYPES));

		// Then
		Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
		System.assertEquals(2, accounts.size());
		Map<Id, Contact> contacts = new Map<Id, Contact>([SELECT Id, LastName, AccountId FROM Contact]);
		System.assertEquals(2, contacts.size());
		Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>([SELECT Id, Name, StageName, AccountId FROM Opportunity]);
		System.assertEquals(2, opportunities.size());
		Account account1 = (Account)assertAndGet(accounts, accountBuilder1.Record.Id);
		Account account2 = (Account)assertAndGet(accounts, opportunityBuilder1.Record.AccountId);
		Contact contact1 = (Contact)assertAndGet(contacts, contactBuilder1.Record.Id);
		Contact contact2 = (Contact)assertAndGet(contacts, contactBuilder2.Record.Id);
		Opportunity opportunity1 = (Opportunity)assertAndGet(opportunities, opportunityBuilder1.Record.Id);
		Opportunity opportunity2 = (Opportunity)assertAndGet(opportunities, opportunityBuilder2.Record.Id);
		verifyRelationshipTree(account1, account2, contact1, contact2, opportunity1, opportunity2, false);
	}

    /**
     * @description Confirms that multiple builders with several relationships can be built
     **/
	@IsTest
	private static void testBuildRelationshipTree()
	{
		runBuildRelationshipTree(false);
		runBuildRelationshipTree(true);
	}

    /**
     * @description Confirms that multiple builders with several layers of relationships can be built
     **/
	@IsTest
	private static void testBuildDeepRelationshipTree()
	{
		runDeepRelationshipTree(MethodMode.Build);
		runDeepRelationshipTree(MethodMode.BuildNew);
	}

    /**
     * @description Confirms that multiple builders with several layers of relationships can be persisted
     **/
	@IsTest
	private static void testPersistDeepRelationshipTree()
	{
		runDeepRelationshipTree(MethodMode.Persist);		
	}

    /**
     * @description Confirms that a builder instance can be persisted without being registered
     **/
	@IsTest
	private static void testPersistBuilder()
	{
		// Given
		TestAccountBuilder accountBuilder = anAccount().withName('Test Account');

		// When
		Account account = accountBuilder.persist(new fflib_SObjectUnitOfWork(UOW_SOBJECTTYPES));

		// Then
		Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
		System.assertEquals(true, accountBuilder.IsBuilt);
		System.assertEquals(false, accountBuilder.IsRegistered);
		System.assertNotEquals(null, accountBuilder.Record.Id);
		System.assertEquals(account.Id, accountBuilder.Record.Id);
		System.assertEquals(account, accountBuilder.Record);			
		System.assertEquals('Test Account', account.Name);
		System.assertEquals(2, accountBuilder.getDomainObjectBuilderEventsFired().size());
		System.assertEquals(accountBuilder.Record, accountBuilder.getDomainObjectBuilderEventsFired().get('beforeInsert'));
		System.assertEquals(accountBuilder.Record, accountBuilder.getDomainObjectBuilderEventsFired().get('afterInsert'));
	}

    /**
     * @description Confirms that a builder instance with several layers of relationships can be persisted without being registered
     **/
	@IsTest
	private static void testPersistRelationshipTree()
	{
		TestOpportunityLineItemBuilder oliBuilder = anOpportunityLineItem()
												.withQuantity(5)
												.withTotalPrice(500)
												.withPriceBookEntry(
													aPriceBookEntryWithStandardPriceBook()
														.withUnitPrice(200)
														.withIsActive(true)
														.withProduct(
															aProduct()
																.withName('My Test Product')))
												.withOpportunity(
													anOpportunity()
														.withName('My Test Opportunity')
														.withStageName('Prospecting')
														.withCloseDate(System.today())
														.withAccount(
															anAccount()
																.withName('My Test Account')));

		// When
		OpportunityLineItem oli = oliBuilder.persist(new fflib_SObjectUnitOfWork(UOW_SOBJECTTYPES));

		// Then
		System.assertEquals(1, [SELECT COUNT() FROM Opportunity]);
		System.assertEquals(1, [SELECT COUNT() FROM OpportunityLineItem]);
		System.assertEquals(1, [SELECT COUNT() FROM PriceBookEntry]);
		System.assertEquals(1, [SELECT COUNT() FROM Product2]);
		System.assertEquals(1, [SELECT COUNT() FROM Account]);
		System.assertNotEquals(null, oli.Id);
	}	
	
    /**
     * @description Object Mother method for an empty account
     *
     * @remarks This would normally go within the TestAccountBuilder itself
	 *          but static methods are not allowed on inner classes.
	 **/
	private static TestAccountBuilder anAccount() {
		return new TestAccountBuilder();
	}

    /**
     * @description Object Mother method for an Prospect account
     *
     * @remarks This would normally go within the TestAccountBuilder itself
	 *          but static methods are not allowed on inner classes.
	 **/
	private static TestAccountBuilder aProspect() {
		return anAccount().withName('Potential Customer').withType('Prospect');
	}

    /**
     * @description Object Mother method for an Empty contact
     *
     * @remarks This would normally go within the TestContactBuilder itself
	 *          but static methods are not allowed on inner classes.
	 **/
	private static TestContactBuilder aContact() {
		return new TestContactBuilder();
	}

    /**
     * @description Object Mother method for a Contact with an Account
     *
     * @remarks This would normally go within the TestContactBuilder itself
	 *          but static methods are not allowed on inner classes.
	 **/
	private static TestContactBuilder aContactWithAccount() {
		return aContact().withLastName('Test Contact').withAccount(anAccount().withName('Test Account'));
	}

    /**
     * @description Object Mother method for an Empty Opportunity
     *
     * @remarks This would normally go within the TestOpportunityBuilder itself
	 *          but static methods are not allowed on inner classes.
	 **/
	private static TestOpportunityBuilder anOpportunity() {
		return new TestOpportunityBuilder();
	}

    /**
     * @description Object Mother method for a Closed Won Opportunity
     *
     * @remarks This would normally go within the TestOpportunityBuilder itself
	 *          but static methods are not allowed on inner classes.
	 **/
	private static TestOpportunityBuilder aClosedWonOpportunity() {
		return anOpportunity()
					.withName('Large Purchase')
					.withAccount(aProspect())
					.withAmount(1000000.00)
					.withStageName('Closed Won')
					.withType('New Customer')
					.withCloseDate(System.today());
	}

    /**
     * @description Object Mother method for an Empty Opportunity Line Item
     *
     * @remarks This would normally go within the TestOpportunityLineItemBuilder itself
	 *          but static methods are not allowed on inner classes.
	 **/
	private static TestOpportunityLineItemBuilder anOpportunityLineItem() {
		return new TestOpportunityLineItemBuilder();
	}	

    /**
     * @description Object Mother method for an Empty Price Book
     *
     * @remarks This would normally go within the TestPriceBookBuilder itself
	 *          but static methods are not allowed on inner classes.
	 **/
	private static TestPriceBookBuilder aPriceBook() {
		return new TestPriceBookBuilder();
	}

    /**
     * @description Object Mother method for an Empty Price Book Entry
     *
     * @remarks This would normally go within the TestPriceBookEntryBuilder itself
	 *          but static methods are not allowed on inner classes.
	 **/
	private static TestPriceBookEntryBuilder aPriceBookEntry() {
		return new TestPriceBookEntryBuilder();
	}

    /**
     * @description Object Mother method for Price Book Entry that uses the Standard Price Book
     *
     * @remarks This would normally go within the TestPriceBookEntryBuilder itself
	 *          but static methods are not allowed on inner classes.
	 **/
	private static TestPriceBookEntryBuilder aPriceBookEntryWithStandardPriceBook() {
		return aPriceBookEntry().withStandardPriceBook();
	}

    /**
     * @description Object Mother method for an Empty Product
     *
     * @remarks This would normally go within the TestProductBuilder itself
	 *          but static methods are not allowed on inner classes.
	 **/
	private static TestProductBuilder aProduct() {
		return new TestProductBuilder();
	}

	private abstract class TestBuilderBase extends fflib_DomainObjectBuilder
	{
	    /**
	     * @description Tracks events fired on this instance to aid in test verifications
		 **/		
		private Map<String, Object> m_domainObjectBuilderEvents = new Map<String, Object>();

	    protected TestBuilderBase(SObjectType type) {
	    	super(type);
	    }

		protected TestBuilderBase(TestBuilderBase copyFrom) {
			super(copyFrom);
		}	    

		public Map<String, Object> getDomainObjectBuilderEventsFired() {
			return m_domainObjectBuilderEvents.clone();
		}

		protected virtual override void beforeBuild(Boolean isNew) {
			super.beforeBuild(isNew);
			addEvent('beforeBuild', isNew);
		}

		protected virtual override void afterBuild(SObject record) {
			super.afterBuild(record);
			addEvent('afterBuild', record);
		}

		protected virtual override void beforeInsert(SObject record) {
			super.beforeInsert(record);
			addEvent('beforeInsert', record);
		}	

		protected virtual override void afterInsert(SObject record) {
			super.afterInsert(record);
			addEvent('afterInsert', record);
		}

		protected void addEvent(String eventName, Object value) {
			if (m_domainObjectBuilderEvents.containsKey(eventName)) {
				throw new TestDomainBuilderException(String.format('Event {0} has already been fired.', new List<String> { eventName }));	
			}

			m_domainObjectBuilderEvents.put(eventName, value);
		}

	    /**
	     * @description Helper to provide test support to gain access to protected members
		 **/
		protected void assertEquals(TestAccountBuilder compareTo) {
			System.assertEquals(this.m_fieldValueMap, compareTo.m_fieldValueMap);
			System.assertEquals(this.m_parentByRelationship, compareTo.m_parentByRelationship);
			System.assertEquals(this.m_sObjType, compareTo.m_sObjType);
		}
	}

	private class TestAccountBuilder extends TestBuilderBase
	{
		/**
		 * Methods/Properties below would be included in a basic template for any derived builder class
		 * 
		 * BEGIN STANDARD BUILDER TEMPLATE
		 * -------------------------------
		 **/

	    /**
	     * @description Constructor should be included in every derived builder
		 **/
		private TestAccountBuilder() {
			super(Account.SObjectType);
		}

	    /**
	     * @description Constructor should be included in every derived builder
		 **/
		private TestAccountBuilder(TestAccountBuilder copyFrom) {
			super(copyFrom);
		}

	    /**
	     * @description Creates an existing SObject without issuing DML
	     *              
	     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
		 **/
	    public Account build() {
	    	return (Account)build(false);
	    }

	    /**
	     * @description Creates an New SObject (No Id) without issuing DML
	     *              
	     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
		 **/
	    public Account buildNew() {
	    	return (Account)build(true);
	    }

	    /**
	     * @description Persists builder and its related data through Unit Of Work
	     *              
	     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
		 **/
	    public Account persist(fflib_ISObjectUnitOfWork uow) {
	    	return (Account)persistBuilder(uow);
	    }

	    /**
	     * @description Registers instance for persistance via persistBuilders
	     *              
	     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
		 **/
	    public TestAccountBuilder register() {
	    	return (TestAccountBuilder)registerBuilder();
	    }		

	    /**
	     * @description Returns Contact SObject associated to this builder
	     *              
	     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
		 **/
	    public Account Record {
	    	get { return (Account)getRecord(); }
	    	private set;
	    }	    

	    /**
	     * @description Returns a Clone of this instance
		 **/
		public TestAccountBuilder but() {
			return new TestAccountBuilder(this);
		}

		/**
		 * Methods/Properties above would be included in a basic template for any derived builder class
		 * 
		 * END STANDARD BUILDER TEMPLATE
		 * -------------------------------
		 **/

	    /**
	     * @description Remaining methods are SObject specific and support fluent configuration of field values
	     **/
		public TestAccountBuilder withName(String value) {
			set(Account.Name, value);
			return this;
		}

		public TestAccountBuilder withType(String value) {
			set(Account.Type, value);
			return this;
		}
	}

	private class TestContactBuilder extends TestBuilderBase 
	{
		/**
		 * Methods/Properties below would be included in a basic template for any derived builder class
		 * 
		 * BEGIN STANDARD BUILDER TEMPLATE
		 * -------------------------------
		 **/

	    /**
	     * @description Constructor should be included in every derived builder
		 **/		
		private TestContactBuilder() {
			super(Contact.SObjectType);
		}

	    /**
	     * @description Constructor should be included in every derived builder
		 **/		
		private TestContactBuilder(TestContactBuilder copyFrom) {
			super(copyFrom);
		}		

	    /**
	     * @description Creates an existing SObject without issuing DML
	     *              
	     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
		 **/
	    public Contact build() {
	    	return (Contact)build(false);
	    }

	    /**
	     * @description Creates an New SObject (No Id) without issuing DML
	     *              
	     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
		 **/	    
	    public Contact buildNew() {
	    	return (Contact)build(true);
	    }

	    /**
	     * @description Persists builder and its related data through Unit Of Work
	     *              
	     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
		 **/
	    public Contact persist(fflib_ISObjectUnitOfWork uow) {
	    	return (Contact)persistBuilder(uow);
	    }	    

	    /**
	     * @description Registers instance for persistance via persistBuilders
	     *              
	     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
		 **/
	    public TestContactBuilder register() {
	    	return (TestContactBuilder)registerBuilder();
	    }

	    /**
	     * @description Returns Contact SObject associated to this builder
	     *              
	     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
		 **/
	    public Contact Record {
	    	get { return (Contact)getRecord(); }
	    	private set;
	    }

	    /**
	     * @description Returns a Clone of this instance
		 **/
		public TestContactBuilder but() {
			return new TestContactBuilder(this);
		}

		/**
		 * Methods/Properties above would be included in a basic template for any derived builder class
		 * 
		 * END STANDARD BUILDER TEMPLATE
		 * -------------------------------
		 **/

	    /**
	     * @description Remaining methods are SObject specific and support fluent configuration of field values
	     **/
		public TestContactBuilder withLastName(String value) {
			set(Contact.LastName, value);
			return this;
		}

		public TestContactBuilder withFirstName(String value) {
			set(Contact.FirstName, value);
			return this;
		}		

		public TestContactBuilder withAccount(TestAccountBuilder value) {
			setParent(Contact.AccountId, value);
			return this;
		}
	}	

	private class TestOpportunityBuilder extends TestBuilderBase 
	{
		/**
		 * Methods/Properties below would be included in a basic template for any derived builder class
		 * 
		 * BEGIN STANDARD BUILDER TEMPLATE
		 * -------------------------------
		 **/

	    /**
	     * @description Constructor should be included in every derived builder
		 **/		
		private TestOpportunityBuilder() {
			super(Opportunity.SObjectType);
		}

	    /**
	     * @description Constructor should be included in every derived builder
		 **/
		private TestOpportunityBuilder(TestOpportunityBuilder copyFrom) {
			super(copyFrom);
		}			

	    /**
	     * @description Creates an existing SObject without issuing DML
	     *              
	     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
		 **/
	    public Opportunity build() {
	    	return (Opportunity)build(false);
	    }

	    /**
	     * @description Creates an New SObject (No Id) without issuing DML
	     *              
	     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
		 **/	
	    public Opportunity buildNew() {
	    	return (Opportunity)build(true);
	    }

	    /**
	     * @description Persists builder and its related data through Unit Of Work
	     *              
	     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
		 **/
	    public Opportunity persist(fflib_ISObjectUnitOfWork uow) {
	    	return (Opportunity)persistBuilder(uow);
	    }	    

	    /**
	     * @description Registers instance for persistance via persistBuilders
	     *              
	     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
		 **/
	    public TestOpportunityBuilder register() {
	    	return (TestOpportunityBuilder)registerBuilder();
	    }

	    /**
	     * @description Returns Contact SObject associated to this builder
	     *              
	     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
		 **/
	    public Opportunity Record {
	    	get { return (Opportunity)getRecord(); }
	    	private set;
	    }

	    /**
	     * @description Returns a Clone of this instance
		 **/
		public TestOpportunityBuilder but() {
			return new TestOpportunityBuilder(this);
		}

		/**
		 * Methods/Properties above would be included in a basic template for any derived builder class
		 * 
		 * END STANDARD BUILDER TEMPLATE
		 * -------------------------------
		 **/

	    /**
	     * @description Remaining methods are SObject specific and support fluent configuration of field values
	     **/
	    public TestOpportunityBuilder withAccount(TestAccountBuilder value) {
	    	setParent(Opportunity.AccountId, value);
	    	return this;
	    }

		public TestOpportunityBuilder withName(String value) {
			set(Opportunity.Name, value);
			return this;
		}

		public TestOpportunityBuilder withAmount(Decimal value) {
			set(Opportunity.Amount, value);
			return this;
		}

		public TestOpportunityBuilder withStageName(String value) {
			set(Opportunity.StageName, value);
			return this;
		}

		public TestOpportunityBuilder withCloseDate(Date value) {
			set(Opportunity.CloseDate, value);
			return this;
		}

		public TestOpportunityBuilder withType(String value) {
			set(Opportunity.Type, value);
			return this;
		}	
	}

	private class TestOpportunityLineItemBuilder extends TestBuilderBase 
	{
		/**
		 * Methods/Properties below would be included in a basic template for any derived builder class
		 * 
		 * BEGIN STANDARD BUILDER TEMPLATE
		 * -------------------------------
		 **/

	    /**
	     * @description Constructor should be included in every derived builder
		 **/		
		private TestOpportunityLineItemBuilder() {
			super(OpportunityLineItem.SObjectType);
		}

	    /**
	     * @description Constructor should be included in every derived builder
		 **/
		private TestOpportunityLineItemBuilder(TestOpportunityLineItemBuilder copyFrom) {
			super(copyFrom);
		}			

	    /**
	     * @description Creates an existing SObject without issuing DML
	     *              
	     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
		 **/
	    public OpportunityLineItem build() {
	    	return (OpportunityLineItem)build(false);
	    }

	    /**
	     * @description Creates an New SObject (No Id) without issuing DML
	     *              
	     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
		 **/
	    public OpportunityLineItem buildNew() {
	    	return (OpportunityLineItem)build(true);
	    }

	    /**
	     * @description Persists builder and its related data through Unit Of Work
	     *              
	     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
		 **/
	    public OpportunityLineItem persist(fflib_ISObjectUnitOfWork uow) {
	    	return (OpportunityLineItem)persistBuilder(uow);
	    }	 	    

	    /**
	     * @description Registers instance for persistance via persistBuilders
	     *              
	     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
		 **/
	    public TestOpportunityLineItemBuilder register() {
	    	return (TestOpportunityLineItemBuilder)registerBuilder();
	    }

	    /**
	     * @description Returns Contact SObject associated to this builder
	     *              
	     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
		 **/
	    public OpportunityLineItem Record {
	    	get { return (OpportunityLineItem)getRecord(); }
	    	private set;
	    }

	    /**
	     * @description Returns a Clone of this instance
		 **/
		public TestOpportunityLineItemBuilder but() {
			return new TestOpportunityLineItemBuilder(this);
		}

		/**
		 * Methods/Properties above would be included in a basic template for any derived builder class
		 * 
		 * END STANDARD BUILDER TEMPLATE
		 * -------------------------------
		 **/

	    /**
	     * @description Remaining methods are SObject specific and support fluent configuration of field values
	     **/
	    public TestOpportunityLineItemBuilder withQuantity(Decimal value) {
	    	set(OpportunityLineItem.Quantity, value);
	    	return this;
	    }

		public TestOpportunityLineItemBuilder withTotalPrice(Decimal value) {
			set(OpportunityLineItem.TotalPrice, value);
			return this;
		}

		public TestOpportunityLineItemBuilder withPriceBookEntry(TestPriceBookEntryBuilder value) {
			setParent(OpportunityLineItem.PriceBookEntryId, value);
			return this;
		}

		public TestOpportunityLineItemBuilder withOpportunity(TestOpportunityBuilder value) {
			setParent(OpportunityLineItem.OpportunityId, value);
			return this;
		}
	}	

	private class TestProductBuilder extends TestBuilderBase 
	{
		/**
		 * Methods/Properties below would be included in a basic template for any derived builder class
		 * 
		 * BEGIN STANDARD BUILDER TEMPLATE
		 * -------------------------------
		 **/

	    /**
	     * @description Constructor should be included in every derived builder
		 **/		
		private TestProductBuilder() {
			super(Product2.SObjectType);
		}

	    /**
	     * @description Constructor should be included in every derived builder
		 **/
		private TestProductBuilder(TestProductBuilder copyFrom) {
			super(copyFrom);
		}			

	    /**
	     * @description Creates an existing SObject without issuing DML
	     *              
	     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
		 **/
	    public Product2 build() {
	    	return (Product2)build(false);
	    }

	    /**
	     * @description Creates an New SObject (No Id) without issuing DML
	     *              
	     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
		 **/
	    public Product2 buildNew() {
	    	return (Product2)build(true);
	    }

	    /**
	     * @description Persists builder and its related data through Unit Of Work
	     *              
	     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
		 **/
	    public Product2 persist(fflib_ISObjectUnitOfWork uow) {
	    	return (Product2)persistBuilder(uow);
	    }		    

	    /**
	     * @description Registers instance for persistance via persistBuilders
	     *              
	     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
		 **/
	    public TestProductBuilder register() {
	    	return (TestProductBuilder)registerBuilder();
	    }

	    /**
	     * @description Returns Contact SObject associated to this builder
	     *              
	     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
		 **/
	    public Product2 Record {
	    	get { return (Product2)getRecord(); }
	    	private set;
	    }

	    /**
	     * @description Returns a Clone of this instance
		 **/
		public TestProductBuilder but() {
			return new TestProductBuilder(this);
		}

		/**
		 * Methods/Properties above would be included in a basic template for any derived builder class
		 * 
		 * END STANDARD BUILDER TEMPLATE
		 * -------------------------------
		 **/

	    /**
	     * @description Remaining methods are SObject specific and support fluent configuration of field values
	     **/		
	    public TestProductBuilder withName(String value) {
	    	set(Product2.Name, value);
	    	return this;
	    }    
	}

	private class TestPriceBookBuilder extends TestBuilderBase 
	{
		/**
		 * Methods/Properties below would be included in a basic template for any derived builder class
		 * 
		 * BEGIN STANDARD BUILDER TEMPLATE
		 * -------------------------------
		 **/

	    /**
	     * @description Constructor should be included in every derived builder
		 **/		
		private TestPriceBookBuilder() {
			super(Pricebook2.SObjectType);
		}

	    /**
	     * @description Constructor should be included in every derived builder
		 **/	
		private TestPriceBookBuilder(TestPriceBookBuilder copyFrom) {
			super(copyFrom);
		}			

	    /**
	     * @description Creates an existing SObject without issuing DML
	     *              
	     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
		 **/
	    public Pricebook2 build() {
	    	return (Pricebook2)build(false);
	    }

	    /**
	     * @description Creates an New SObject (No Id) without issuing DML
	     *              
	     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
		 **/
	    public Pricebook2 buildNew() {
	    	return (Pricebook2)build(true);
	    }

	    /**
	     * @description Persists builder and its related data through Unit Of Work
	     *              
	     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
		 **/
	    public Pricebook2 persist(fflib_ISObjectUnitOfWork uow) {
	    	return (Pricebook2)persistBuilder(uow);
	    }	    

	    /**
	     * @description Registers instance for persistance via persistBuilders
	     *              
	     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
		 **/
	    public TestPriceBookBuilder register() {
	    	return (TestPriceBookBuilder)registerBuilder();
	    }

	    /**
	     * @description Returns Contact SObject associated to this builder
	     *              
	     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
		 **/
	    public Pricebook2 Record {
	    	get { return (Pricebook2)getRecord(); }
	    	private set;
	    }

	    /**
	     * @description Returns a Clone of this instance
		 **/
		public TestPriceBookBuilder but() {
			return new TestPriceBookBuilder(this);
		}	    

		/**
		 * Methods/Properties above would be included in a basic template for any derived builder class
		 * 
		 * END STANDARD BUILDER TEMPLATE
		 * -------------------------------
		 **/

	    /**
	     * @description Remaining methods are SObject specific and support fluent configuration of field values
	     **/
	    public TestPriceBookBuilder withName(String value) {
	    	set(Pricebook2.Name, value);
	    	return this;
	    }

	    public TestPriceBookBuilder withIsActive(Boolean value) {
	    	set(Pricebook2.IsActive, value);
	    	return this;
	    }
	}

	private class TestPriceBookEntryBuilder extends TestBuilderBase 
	{
		/**
		 * Methods/Properties below would be included in a basic template for any derived builder class
		 * 
		 * BEGIN STANDARD BUILDER TEMPLATE
		 * -------------------------------
		 **/

	    /**
	     * @description Constructor should be included in every derived builder
		 **/		
		private TestPriceBookEntryBuilder() {
			super(PricebookEntry.SObjectType);
		}

	    /**
	     * @description Constructor should be included in every derived builder
		 **/
		private TestPriceBookEntryBuilder(TestPriceBookEntryBuilder copyFrom) {
			super(copyFrom);
		}			

	    /**
	     * @description Creates an existing SObject without issuing DML
	     *              
	     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
		 **/
	    public PricebookEntry build() {
	    	return (PricebookEntry)build(false);
	    }

	    /**
	     * @description Creates an New SObject (No Id) without issuing DML
	     *              
	     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
		 **/
	    public PricebookEntry buildNew() {
	    	return (PricebookEntry)build(true);
	    }

	    /**
	     * @description Persists builder and its related data through Unit Of Work
	     *              
	     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
		 **/
	    public PricebookEntry persist(fflib_ISObjectUnitOfWork uow) {
	    	return (PricebookEntry)persistBuilder(uow);
	    }		    

	    /**
	     * @description Registers instance for persistance via persistBuilders
	     *              
	     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
		 **/
	    public TestPriceBookEntryBuilder register() {
	    	return (TestPriceBookEntryBuilder)registerBuilder();
	    }

	    /**
	     * @description Returns Contact SObject associated to this builder
	     *              
	     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
		 **/
	    public PricebookEntry Record {
	    	get { return (PricebookEntry)getRecord(); }
	    	private set;
	    }

	    /**
	     * @description Returns a Clone of this instance
		 **/
		public TestPriceBookEntryBuilder but() {
			return new TestPriceBookEntryBuilder(this);
		}

		/**
		 * Methods/Properties above would be included in a basic template for any derived builder class
		 * 
		 * END STANDARD BUILDER TEMPLATE
		 * -------------------------------
		 **/

	    /**
	     * @description Remaining methods are SObject specific and support fluent configuration of field values
	     **/
	    public TestPriceBookEntryBuilder withUnitPrice(Decimal value) {
	    	set(PricebookEntry.UnitPrice, value);
	    	return this;
	    }

	    public TestPriceBookEntryBuilder withIsActive(Boolean value) {
	    	set(PricebookEntry.IsActive, value);
	    	return this;
	    }

	    public TestPriceBookEntryBuilder withUseStandardPrice(Boolean value) {
	    	set(PriceBookEntry.UseStandardPrice, value);
	    	return this;
	    }    

	    public TestPriceBookEntryBuilder withStandardPriceBook() {
	    	set(PriceBookEntry.PriceBook2Id, Test.getStandardPricebookId());
	    	return this;
	    }

	    public TestPriceBookEntryBuilder withPriceBook(TestPriceBookBuilder value) {
	    	setParent(PriceBookEntry.PriceBook2Id, value);
	    	return this;
	    }

	    public TestPriceBookEntryBuilder withProduct(TestProductBuilder value) {
	    	setParent(PriceBookEntry.Product2Id, value);
	    	return this;
	    }
	}		

	/**
	 * General exception class for test class
	 **/
	public class TestDomainBuilderException extends Exception {}
}