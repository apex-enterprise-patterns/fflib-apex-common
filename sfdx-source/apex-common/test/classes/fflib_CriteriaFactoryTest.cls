@isTest(isParallel=true)
private class fflib_CriteriaFactoryTest {
  private final static fflib_CriteriaFactory cf = new fflib_CriteriaFactory();

  @isTest
  static void equalsToCriteriaForString() {
    assertEquals('Name = \'salesforce\'', cf.equalsTo(Account.Name, 'salesforce'));
  }

  @isTest
  static void equalsToCriteriaForBoolean() {
    assertEquals('HasOpportunityLineItem = true', cf.equalsTo(Opportunity.HasOpportunityLineItem, true));
  }

  @isTest
  static void equalsToCriteriaForNumeric() {
    assertEquals('TotalOpportunityQuantity = 2', cf.equalsTo(Opportunity.TotalOpportunityQuantity, 2));
  }

  @isTest
  static void notEqualsToCriteriaForString() {
    assertEquals('Name != \'microsoft\'', cf.notEqualsTo(Account.Name, 'microsoft'));
  }

  @isTest
  static void notEqualsToCriteriaForNumeric() {
    assertEquals('TotalOpportunityQuantity != 2', cf.notEqualsTo(Opportunity.TotalOpportunityQuantity, 2));
  }

  @isTest
  static void greaterOrEqualCriteriaForNumeric() {
    assertEquals('TotalOpportunityQuantity >= 2', cf.greaterOrEqual(Opportunity.TotalOpportunityQuantity, 2));
  }

  @isTest
  static void greaterThanCriteriaForNumeric() {
    assertEquals('TotalOpportunityQuantity > 2', cf.greaterThan(Opportunity.TotalOpportunityQuantity, 2));
  }

  @isTest
  static void lessThanCriteriaForNumeric() {
    assertEquals('TotalOpportunityQuantity < 2', cf.lessThan(Opportunity.TotalOpportunityQuantity, 2));
  }

  @isTest
  static void lessOrEqualCriteriaForNumeric() {
    assertEquals('TotalOpportunityQuantity <= 2', cf.lessOrEqual(Opportunity.TotalOpportunityQuantity, 2));
  }

  @isTest
  static void inCriteriaForStrings() {
    List<String> inValues = new List<String>{ 'BMW', 'Jeep' };
    assertEquals('Name IN (\'BMW\',\'Jeep\')', cf.isIn(Account.Name, inValues));
  }

  @isTest
  static void inCriteriaForNonStrings() {
    List<Integer> inValues = new List<Integer>{ 1, 2, 3 };
    assertEquals('NumberOfEmployees IN (1,2,3)', cf.isIn(Account.NumberOfEmployees, inValues));
  }

  @isTest
  static void inCriteriaForSubSelect() {
    String subSelect = 'SELECT Id FROM Account';
    assertEquals('AccountId IN (SELECT Id FROM Account)', cf.isIn(Contact.AccountId, subSelect));
  }

  @isTest
  static void notInCriteriaForSubSelect() {
    String subSelect = 'SELECT Id FROM Account';
    assertEquals('AccountId NOT IN (SELECT Id FROM Account)', cf.isNotIn(Contact.AccountId, subSelect));
  }

  @isTest
  static void notInCriteriaForStrings() {
    List<String> inValues = new List<String>{ 'BMW', 'Jeep' };
    assertEquals('Name NOT IN (\'BMW\',\'Jeep\')', cf.isNotIn(Account.Name, inValues));
  }

  @isTest
  static void notInCriteriaForNonStrings() {
    List<Integer> inValues = new List<Integer>{ 1, 2, 3 };
    assertEquals('NumberOfEmployees NOT IN (1,2,3)', cf.isNotIn(Account.NumberOfEmployees, inValues));
  }

  @isTest
  static void likeCriteria() {
    assertEquals('Name LIKE \'%force\'', cf.isLike(Account.Name, '%force'));
  }

  @isTest
  static void wrapsNotLikeCriteriaIntoBrackets() {
    assertEquals('(NOT Name LIKE \'%force\')', cf.isNotLike(Account.Name, '%force'));
  }

  @isTest
  static void isNull() {
    assertEquals('Name = NULL', cf.isNull(Account.Name));
  }

  @isTest
  static void isNotNull() {
    assertEquals('Name != NULL', cf.isNotNull(Account.Name));
  }

  @isTest
  static void joinsCriteriaViaAndByDefault() {
    cf.isNotNull(Account.Industry).greaterOrEqual(Account.NumberOfEmployees, 100);

    System.assertEquals('Industry != NULL AND NumberOfEmployees >= 100', cf.toCriteria());
  }

  @isTest
  static void canJoinViaOrIfConfigured() {
    cf.isNotNull(Account.Industry).withOr().greaterOrEqual(Account.NumberOfEmployees, 100);

    System.assertEquals('Industry != NULL OR NumberOfEmployees >= 100', cf.toCriteria());
  }

  @isTest
  static void criteriaBasedOnReferenceAttributes() {
    cf
      .configureForReferenceField(Contact.AccountId)
      .isNotNull(Account.Industry)
      .greaterOrEqual(Account.NumberOfEmployees, 100);

    System.assertEquals('Account.Industry != NULL AND Account.NumberOfEmployees >= 100', cf.toCriteria());
  }

  @isTest
  static void wrapsCompositeCriteriaIntoBrackets() {
    fflib_CriteriaFactory compositeCriteria = new fflib_CriteriaFactory();
    compositeCriteria.isNull(Contact.Email).withOr().isNotNull(Contact.Title);
    fflib_CriteriaFactory cf = new fflib_CriteriaFactory();
    cf.isLike(Contact.Department, 'Finance%').composite(compositeCriteria);

    System.assertEquals('Department LIKE \'Finance%\' AND (Email = NULL OR Title != NULL)', cf.toCriteria());
  }

  private static void assertEquals(String expectedCriteria, fflib_CriteriaFactory criteriaBuilder) {
    System.assertEquals(expectedCriteria, criteriaBuilder.toCriteria());
  }
}
