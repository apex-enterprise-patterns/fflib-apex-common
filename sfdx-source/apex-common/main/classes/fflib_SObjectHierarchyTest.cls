@IsTest
private class fflib_SObjectHierarchyTest {
	

	@IsTest
	static void getUntilTopOfHierarchy_ChildHasOneParent_ReturnHierarchyWithOneParent() {

		Account parentAccount = new Account(Name = 'Parent Account');
		insert parentAccount;

		Account childAccount = new Account(Name = 'Child Account', ParentId = parentAccount.Id);
		insert childAccount;

		SObjectField field = Account.ParentId.getDescribe().getSobjectField();

		fflib_SObjectHierarchy testObject = new fflib_SObjectHierarchy(
				Account.getSObjectType(), field
		);

		Test.startTest();
		Map<Id, List<SObject>> hierarchies = testObject.getUntilTopOfHierarchy(new Set<Id> {childAccount.Id});
		Test.stopTest();

		System.assertEquals(1, hierarchies.size());

		System.assertEquals(parentAccount.Id, hierarchies.get(childAccount.Id).get(1).Id);
	}

	@IsTest
	static void getUntilTopOfHierarchy_IncludeNameInQueryField_ReturnHierarchyWithNameIncluded() {

		Account parentAccount = new Account(Name = 'Parent Account');
		insert parentAccount;

		Account childAccount = new Account(Name = 'Child Account', ParentId = parentAccount.Id);
		insert childAccount;

		SObjectField field = Account.ParentId.getDescribe().getSobjectField();

		fflib_SObjectHierarchy testObject = new fflib_SObjectHierarchy(
				Account.getSObjectType(), field, new Set<SObjectField> {Account.Name.getDescribe().getSObjectField()}
		);

		Test.startTest();
		Map<Id, List<SObject>> hierarchies = testObject.getUntilTopOfHierarchy(new Set<Id> {childAccount.Id});
		Test.stopTest();

		System.assertEquals(1, hierarchies.size());

		System.assertEquals(parentAccount.Id, hierarchies.get(childAccount.Id).get(1).Id);
		System.assertEquals(parentAccount.Name, hierarchies.get(childAccount.Id).get(1).get('Name'));
		System.assertEquals(childAccount.Name, hierarchies.get(childAccount.Id).get(0).get('Name'));
	}

	@IsTest
	static void getUntilTopOfHierarchy_LookupAlreadyInListOfFields_ReturnHierarchyWithJustLookupQueried() {

		Account parentAccount = new Account(Name = 'Parent Account');
		insert parentAccount;

		Account childAccount = new Account(Name = 'Child Account', ParentId = parentAccount.Id);
		insert childAccount;

		SObjectField field = Account.ParentId.getDescribe().getSobjectField();

		fflib_SObjectHierarchy testObject = new fflib_SObjectHierarchy(
				Account.getSObjectType(), field, new Set<SObjectField> {Account.ParentId.getDescribe().getSObjectField()}
		);

		Test.startTest();
		Map<Id, List<SObject>> hierarchies = testObject.getUntilTopOfHierarchy(new Set<Id> {childAccount.Id});
		Test.stopTest();

		System.assertEquals(1, hierarchies.size());

		System.assertEquals(parentAccount.Id, hierarchies.get(childAccount.Id).get(1).Id);
	}


	@IsTest
	static void getUntilTopOfHierarchy_OnlyOneElementInHierarchy_ReturnOneHierarchyWithOneLevel() {

		Account childAccount = new Account(Name = 'Child Account');
		insert childAccount;

		SObjectField field = Account.ParentId.getDescribe().getSobjectField();

		fflib_SObjectHierarchy testObject = new fflib_SObjectHierarchy(
				Account.getSObjectType(), field, new Set<SObjectField> {Account.Name.getDescribe().getSObjectField()}
		);

		Test.startTest();
		Map<Id, List<SObject>> hierarchies = testObject.getUntilTopOfHierarchy(new Set<Id> {childAccount.Id});
		Test.stopTest();

		System.assertEquals(1, hierarchies.size());
		System.assertEquals(childAccount.Id, hierarchies.get(childAccount.Id).get(0).Id);
	}

	@IsTest
	static void getUntilTopOfHierarchy_CaseChildHasOneParent_ReturnHierarchiesWithTwoLevels() {

		Case parentCase = new Case();
		insert parentCase;

		Case childCase = new Case(ParentId = parentCase.Id);
		insert childCase;

		SObjectField field = Case.ParentId.getDescribe().getSobjectField();

		fflib_SObjectHierarchy testObject = new fflib_SObjectHierarchy(
				Case.getSObjectType(), field
		);

		Test.startTest();
		Map<Id, List<SObject>> hierarchies = testObject.getUntilTopOfHierarchy(new Set<Id> {childCase.Id});
		Test.stopTest();

		System.assertEquals(1, hierarchies.size());

		System.assertEquals(parentCase.Id, hierarchies.get(childCase.Id).get(1).Id);
	}

	@IsTest
	static void getUntilTopOfHierarchy_ChildHasTwoLevelsAbove_ReturnHierarchiesWithThreeLevels() {

		Account grandParent = new Account(Name = 'GrandParent Account');
		insert grandParent;

		Account parentAccount = new Account(Name = 'Parent Account', ParentId = grandParent.Id);
		insert parentAccount;

		Account childAccount = new Account(Name = 'Child Account', ParentId = parentAccount.Id);
		insert childAccount;

		SObjectField field = Account.ParentId.getDescribe().getSobjectField();

		fflib_SObjectHierarchy testObject = new fflib_SObjectHierarchy(
				Account.getSObjectType(), field
		);

		Test.startTest();
		Map<Id, List<SObject>> hierarchies = testObject.getUntilTopOfHierarchy(new Set<Id> {childAccount.Id});
		Test.stopTest();

		System.assertEquals(1, hierarchies.size());
		System.assertEquals(grandParent.Id, hierarchies.get(childAccount.Id).get(2).Id);
	}

	@IsTest
	static void getUntilTopOfHierarchy_10Levels_ReturnHierarchiesWithTenLevels() {
		Integer numAccounts = 10;
		AccountHierarchyTestUtil testUtil = AccountHierarchyTestUtil.createAccountHierarchy(numAccounts);

		SObjectField field = Account.ParentId.getDescribe().getSobjectField();

		fflib_SObjectHierarchy testObject = new fflib_SObjectHierarchy(
				Account.getSObjectType(), field
		);

		Test.startTest();
		Map<Id, List<SObject>> hierarchies = testObject.getUntilTopOfHierarchy(new Set<Id> {testUtil.getLowestLevel().Id});
		Test.stopTest();

		System.assertEquals(1, hierarchies.size());

		List<SObject> parsed = hierarchies.get(testUtil.getLowestLevel().Id);
		System.assertEquals(numAccounts, parsed.size());
		System.assertEquals(testUtil.getHighestLevel().Id, hierarchies.get(testUtil.getLowestLevel().Id).get(numAccounts - 1).Id);
	}

	@IsTest
	static void getUntilTopOfHierarchy_50Levels_ReturnHierarchiesWith50Levels() {
		Integer numAccounts = 50;
		AccountHierarchyTestUtil testUtil = AccountHierarchyTestUtil.createAccountHierarchy(numAccounts);

		SObjectField field = Account.ParentId.getDescribe().getSobjectField();

		fflib_SObjectHierarchy testObject = new fflib_SObjectHierarchy(
				Account.getSObjectType(), field
		);

		Test.startTest();
		Map<Id, List<SObject>> hierarchies = testObject.getUntilTopOfHierarchy(new Set<Id> {testUtil.getLowestLevel().Id});
		System.assertEquals(9, Limits.getQueries());
		Test.stopTest();

		System.assertEquals(1, hierarchies.size());

		List<SObject> parsed = hierarchies.get(testUtil.getLowestLevel().Id);
		System.assertEquals(numAccounts, parsed.size());
		System.assertEquals(testUtil.getHighestLevel().Id, hierarchies.get(testUtil.getLowestLevel().Id).get(numAccounts - 1).Id);

	}

	@IsTest
	static void getUntilTopOfHierarchy_53Levels_ReturnHierarchiesWith53Levels() {

		AccountHierarchyTestUtil testUtil = AccountHierarchyTestUtil.createAccountHierarchy(53);

		SObjectField field = Account.ParentId.getDescribe().getSobjectField();

		fflib_SObjectHierarchy testObject = new fflib_SObjectHierarchy(
				Account.getSObjectType(), field, new Set<SObjectField> {Account.Name.getDescribe().getSObjectField()}
		);

		Test.startTest();
		Map<Id, List<SObject>> hierarchies = testObject.getUntilTopOfHierarchy(new Set<Id> {testUtil.getLowestLevel().Id});
		System.assertEquals(9, Limits.getQueries());
		Test.stopTest();

		System.assertEquals(1, hierarchies.size());

		List<SObject> parsed = hierarchies.get(testUtil.getLowestLevel().Id);
		System.assertEquals(53, parsed.size());

		System.assertEquals('Name 52', parsed.get(0).get('Name'));
	}

	@IsTest
	static void getUntilTopOfHierarchy_55Levels_ReturnHierarchiesWith55Levels() {

		AccountHierarchyTestUtil testUtil = AccountHierarchyTestUtil.createAccountHierarchy(55);

		for (Account account : testUtil.getLowestToHighest()) {
			System.debug(account);
		}

		SObjectField field = Account.ParentId.getDescribe().getSobjectField();

		fflib_SObjectHierarchy testObject = new fflib_SObjectHierarchy(
				Account.getSObjectType(), field, new Set<SObjectField> {Account.Name.getDescribe().getSObjectField()}
		);

		Test.startTest();
		Map<Id, List<SObject>> hierarchies = testObject.getUntilTopOfHierarchy(new Set<Id> {testUtil.getLowestLevel().Id});
		System.assertEquals(10, Limits.getQueries());
		Test.stopTest();

		System.assertEquals(1, hierarchies.size());

		List<SObject> parsed = hierarchies.get(testUtil.getLowestLevel().Id);
		System.assertEquals(55, parsed.size());

		System.assertEquals('Name 54', parsed.get(0).get('Name'));
	}

	@IsTest
	static void getUntilTopOfHierarchy_DatabaseHasAccountsNotIncludedInQuery_HierarchyCreatedForIncludedAccountsOnly() {
		// Arrange
		Account p1 = new Account(Name = 'Parent 1');
		Account p2 = new Account(Name = 'Parent 2');
		insert new List<Account> {p1, p2};

		Account c1 = new Account(Name = 'Child 1', ParentId = p1.Id);
		Account c2 = new Account(Name = 'Child 2', ParentId = p2.Id);
		insert new List<Account> {c1, c2};

		fflib_SObjectHierarchy hierarchy = new fflib_SObjectHierarchy(Account.getSObjectType(), Account.ParentId);

		// Act
		Test.startTest();
		Map<Id, List<SObject>> hierarchies = hierarchy.getUntilTopOfHierarchy(new Set<Id> {c1.Id});
		Test.stopTest();

		// Assert
		System.assertEquals(1, hierarchies.size());
		System.assert(hierarchies.containsKey(c1.Id));
		System.assert(!hierarchies.containsKey(c2.Id));
	}

	@IsTest
	static void getUntilTopOfHierarchy_MultipleHierarchies_HierarchiesCreated() {
		// Arrange
		Account p1 = new Account(Name = 'Parent 1');
		Account p2 = new Account(Name = 'Parent 2');
		insert new List<Account> {p1, p2};

		Account c1 = new Account(Name = 'Child 1', ParentId = p1.Id);
		Account c2 = new Account(Name = 'Child 2', ParentId = p2.Id);
		insert new List<Account> {c1, c2};

		fflib_SObjectHierarchy hierarchy = new fflib_SObjectHierarchy(Account.getSObjectType(), Account.ParentId);

		// Act
		Test.startTest();
		Map<Id, List<SObject>> hierarchies = hierarchy.getUntilTopOfHierarchy(new Set<Id> {c1.Id, c2.Id});
		Test.stopTest();

		// Assert
		System.assertEquals(2, hierarchies.size());
		System.assert(hierarchies.containsKey(c1.Id));
		System.assert(hierarchies.containsKey(c2.Id));

		List<SObject> hier1 = hierarchies.get(c1.Id);
		List<SObject> hier2 = hierarchies.get(c2.Id);
		System.assertEquals(p1.Id, hier1.get(hier1.size() - 1).Id);
		System.assertEquals(p2.Id, hier2.get(hier2.size() - 1).Id);
	}

	@IsTest
	static void getUntilTopOfHierarchy_NullSetOfIds_ThrowIllegalArgumentException() {

		fflib_SObjectHierarchy testObject = new fflib_SObjectHierarchy(Account.getSObjectType(), Account.ParentId);
		
		Test.startTest();

		Exception caughtException = null;
		try {
			testObject.getUntilTopOfHierarchy(null);	
		} catch (IllegalArgumentException e) {
			caughtException = e;
		}
		Test.stopTest();
		
		System.assertEquals('Cannot parse hierarchy with a null set of ids', caughtException.getMessage());
	}

	@IsTest
	static void getUntilTopOfHierarchy_MultipleAccountsInSameHierarchyGiven_ReturnHierarchiesWithSharedElements() {
		// Arrange
		AccountHierarchyTestUtil testUtil = createAccountHierarchy(12);

		List<Account> accounts = testUtil.getLowestToHighest();
		Account firstAccount = accounts[0];
		Account secondAccount = accounts[1];

		Account middleAccount = accounts.get(accounts.size() / 2);

		Account topForBoth = accounts.get(accounts.size() - 1);

		fflib_SObjectHierarchy testObject = new fflib_SObjectHierarchy(Account.getSObjectType(), Account.ParentId);

		// Act
		Test.startTest();
		Map<Id, List<SObject>> hierarchies = testObject.getUntilTopOfHierarchy(new Set<Id> {firstAccount.Id, secondAccount.Id, middleAccount.Id});
		Test.stopTest();

		// Assert
		System.assertEquals(3, hierarchies.size());

		List<Account> firstAccountHierarchy = hierarchies.get(firstAccount.Id);
		List<Account> secondAccountHierarchy = hierarchies.get(secondAccount.Id);
		List<Account> middleAccountHierarchy = hierarchies.get(middleAccount.Id);

		System.assertEquals(12, firstAccountHierarchy.size());
		System.assertEquals(11, secondAccountHierarchy.size());
		System.assertEquals(6, middleAccountHierarchy.size());

		System.assertEquals(topForBoth.Id, firstAccountHierarchy.get(firstAccountHierarchy.size() - 1).Id);
		System.assertEquals(topForBoth.Id, secondAccountHierarchy.get(secondAccountHierarchy.size() - 1).Id);
		System.assertEquals(topForBoth.Id, middleAccountHierarchy.get(middleAccountHierarchy.size() - 1).Id);
	}

	@IsTest
	static void getUntilTopOfHierarchy_TwoHierarchiesConverge_ReturnHierarchiesWithSharedElements(){
		// Arrange
		Account p1 = new Account(Name = 'Parent 1');
		insert new List<Account> {p1};

		Account c1 = new Account(Name = 'Child 1', ParentId = p1.Id);
		Account c2 = new Account(Name = 'Child 2', ParentId = p1.Id);
		insert new List<Account> {c1, c2};

		fflib_SObjectHierarchy hierarchy = new fflib_SObjectHierarchy(Account.getSObjectType(), Account.ParentId);

		// Act
		Test.startTest();
		Map<Id, List<SObject>> hierarchies = hierarchy.getUntilTopOfHierarchy(new Set<Id> {c1.Id, c2.Id});
		Test.stopTest();

		// Assert
		System.assertEquals(2, hierarchies.size());
		System.assert(hierarchies.containsKey(c1.Id));
		System.assert(hierarchies.containsKey(c2.Id));

		List<SObject> hier1 = hierarchies.get(c1.Id);
		List<SObject> hier2 = hierarchies.get(c2.Id);
		System.assertEquals(p1.Id, hier1.get(hier1.size() - 1).Id);
		System.assertEquals(p1.Id, hier2.get(hier2.size() - 1).Id);
	}

	@IsTest
	static void onConstruction_NullSObjectType_ThrowIllegalArgumentException() {
		SObjectField field = Account.ParentId.getDescribe().getSobjectField();
		Exception caughtException;

		Test.startTest();
		try {
			new fflib_SObjectHierarchy(null, field);
		} catch (IllegalArgumentException e) {
			caughtException = e;

		}
		Test.stopTest();

		System.assertEquals('sobjType cannot be null.', caughtException.getMessage());
	}

	@IsTest
	static void onConstruction_NullLookupField_ThrowIllegalArgumentException() {
		Exception caughtException;

		Test.startTest();
		try {
			new fflib_SObjectHierarchy(Account.getSObjectType(), null);
		} catch (IllegalArgumentException e) {
			caughtException = e;
		}
		Test.stopTest();

		System.assertEquals('lookupField cannot be null.', caughtException.getMessage());
	}

	@IsTest
	static void onConstruction_NullSObjectFieldsGiven_ThrowIllegalArgumentException() {

		Exception caughtException = null;

		Test.startTest();
		try {
			new fflib_SObjectHierarchy(Account.getSObjectType(), Account.ParentId.getDescribe().getSobjectField(), null);
		} catch (IllegalArgumentException e) {
			caughtException = e;
		}
		Test.stopTest();
		
		System.assertEquals('queryFields cannot be null', caughtException.getMessage());	
	}

	@IsTest
	static void onConstruction_GiveNonLookup_ThrowIllegalArgumentException() {

		Account parentAccount = new Account(Name = 'Parent Account');
		insert parentAccount;

		Account childAccount = new Account(Name = 'Child Account', ParentId = parentAccount.Id);
		insert childAccount;

		SObjectField field = Account.Id.getDescribe().getSobjectField();

		Test.startTest();
		Exception caughtException = null;
		try {
			new fflib_SObjectHierarchy(
					Account.getSObjectType(), field
			);
		} catch (IllegalArgumentException e) {
			caughtException = e;
		}
		Test.stopTest();

		System.assertEquals('Cannot construct a hierarchy with a non-lookup field [Id]', caughtException.getMessage());
	}

	@IsTest
	static void onConstruction_LookupToOtherObject_ThrowIllegalArgumentException() {

		Account parentAccount = new Account(Name = 'Parent Account');
		insert parentAccount;

		Case childCase = new Case(AccountId = parentAccount.Id);
		insert childCase;

		SObjectField field = Case.AccountId.getDescribe().getSobjectField();

		Test.startTest();
		Exception caughtException = null;
		try {
			new fflib_SObjectHierarchy(Case.getSObjectType(), field);
		} catch (IllegalArgumentException e) {
			caughtException = e;
		}
		Test.stopTest();

		System.assertEquals('Lookup field must point to same type as SObject type [was (Account), must be Case]',
				caughtException.getMessage());
	}

	private static AccountHierarchyTestUtil createAccountHierarchy(Integer numLevels) {
		AccountHierarchyTestUtil hierarchy = new AccountHierarchyTestUtil();

		List<Account> accounts = new List<Account>();
		for (Integer i = 0; i < numLevels; i++) {
			String distinctName = 'Name ' + i;
			accounts.add(new Account(Name = distinctName));
		}
		insert accounts;

		Account parentAccount = accounts.get(0);
		List<Account> reversed = new List<Account>();
		reversed.add(parentAccount);

		for (Integer i = 1; i <= numLevels - 1; i++) {

			Account currentLevel = accounts.get(i);
			currentLevel.Parent = parentAccount;
			currentLevel.ParentId = parentAccount.Id;
			reversed.add(currentLevel);

			parentAccount = currentLevel;
		}
		update accounts;

		hierarchy.hierarchy = reverse(reversed);

		return hierarchy;
	}

	private static List<Account> reverse(List<Account> reversed) {
		List<Account> correct = new List<Account>();
		for (Integer i = reversed.size() - 1; i >= 0; i--) {
			correct.add(reversed.get(i));
		}
		return correct;
	}

	private class AccountHierarchyTestUtil implements Iterable<Account> {

		private List<Account> hierarchy;
	
		public AccountHierarchyTestUtil() {
			hierarchy = new List<Account>();
		}
	
		public Account getLowestLevel() {
			return hierarchy.get(0);
		}
	
		public Account getHighestLevel() {
			return this.hierarchy.get(this.hierarchy.size() - 1);
		}

		public List<Account> getLowestToHighest() {
			return new List<Account>(hierarchy);
		}
	
		public Iterator<Account> iterator() {
			return hierarchy.iterator();
		}
	}
}