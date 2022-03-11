@isTest(isParallel=true)
private class fflib_CriteriaFactoryTest {
  @isTest
  static void equalsToCriteriaForString() {
    assertEquals('Name = \'salesforce\'', cf().equalsTo(Account.Name, 'salesforce'));
  }

  @isTest
  static void equalsToCriteriaForBoolean() {
    assertEquals('HasOpportunityLineItem = true', cf().equalsTo(Opportunity.HasOpportunityLineItem, true));
  }

  @isTest
  static void equalsToCriteriaForNumeric() {
    assertEquals('TotalOpportunityQuantity = 2', cf().equalsTo(Opportunity.TotalOpportunityQuantity, 2));
  }

  @isTest
  static void equalsToCriteriaForDateField() {
    assertEquals('Birthdate = 1995-05-21', cf().equalsTo(Contact.Birthdate, Date.valueOf('1995-05-21')));
  }

  @isTest
  static void equalsToCriteriaForDateString() {
    assertEquals('Birthdate = 1995-05-21', cf().equalsTo(Contact.Birthdate, '1995-05-21'));
  }

  @isTest
  static void equalsToCriteriaForDateFunction() {
    assertEquals('CALENDAR_MONTH(Birthdate) = 12', cf().equalsTo(CALENDAR_MONTH(Contact.Birthdate), 12));
  }

  @isTest
  static void dateFieldToFailIfInvalidArgument() {
    Boolean exceptionWasThrown = false;
    try {
      cf().equalsTo(Contact.Birthdate, 12);
    } catch (IllegalArgumentException iae) {
      exceptionWasThrown = true;
    }
    System.assert(exceptionWasThrown, 'should fail when building criteria with integer value for Date field');
  }

  @isTest
  static void equalsToCriteriaForDatetime() {
    Datetime dateTimeValue = DateTime.newInstanceGMT(2022, 2, 24, 3, 12, 4);
    assertEquals('CreatedDate = 2022-02-24T03:12:04Z', cf().equalsTo(Account.CreatedDate, dateTimeValue));
  }

  @isTest
  static void equalsToCriteriaForDatetimeString() {
    assertEquals('CreatedDate = 2022-02-24T03:12:04Z', cf().equalsTo(Account.CreatedDate, '2022-02-24T03:12:04Z'));
  }

  @isTest
  static void dateTimeFieldToFailIfInvalidArgument() {
    Boolean exceptionWasThrown = false;
    try {
      cf().equalsTo(Contact.CreatedDate, 12);
    } catch (IllegalArgumentException iae) {
      exceptionWasThrown = true;
    }
    System.assert(exceptionWasThrown, 'should fail when building criteria with integer value for Datetime field');
  }

  @isTest
  static void equalsToCriteriaForDateLiteral() {
    assertEquals('CreatedDate = TODAY', cf().equalsTo(Account.CreatedDate, 'TODAY'));
    assertEquals('Birthdate = TODAY', cf().equalsTo(Contact.Birthdate, 'TODAY'));
  }

  @isTest
  static void notEqualsToCriteriaForString() {
    assertEquals('Name != \'microsoft\'', cf().notEqualsTo(Account.Name, 'microsoft'));
  }

  @isTest
  static void notEqualsToCriteriaForNumeric() {
    assertEquals('TotalOpportunityQuantity != 2', cf().notEqualsTo(Opportunity.TotalOpportunityQuantity, 2));
  }

  @isTest
  static void notEqualsToCriteriaForDateField() {
    assertEquals('Birthdate != 1995-05-21', cf().notEqualsTo(Contact.Birthdate, Date.valueOf('1995-05-21')));
  }

  @isTest
  static void notEqualsToCriteriaForDateString() {
    assertEquals('Birthdate != 1995-05-21', cf().notEqualsTo(Contact.Birthdate, '1995-05-21'));
  }

  @isTest
  static void notEqualsToCriteriaForDateFunction() {
    assertEquals('CALENDAR_MONTH(Birthdate) != 1', cf().notEqualsTo(CALENDAR_MONTH(Contact.Birthdate), 1));
  }

  @isTest
  static void greaterOrEqualCriteriaForNumeric() {
    assertEquals('TotalOpportunityQuantity >= 2', cf().greaterOrEqual(Opportunity.TotalOpportunityQuantity, 2));
  }

  @isTest
  static void greaterOrEqualCriteriaForDateField() {
    assertEquals('Birthdate >= 1995-05-21', cf().greaterOrEqual(Contact.Birthdate, Date.valueOf('1995-05-21')));
  }

  @isTest
  static void greaterOrEqualCriteriaForDateString() {
    assertEquals('Birthdate >= 1995-05-21', cf().greaterOrEqual(Contact.Birthdate, '1995-05-21'));
  }

  @isTest
  static void greaterOrEqualCriteriaForDateFunction() {
    assertEquals('CALENDAR_MONTH(Birthdate) >= 1', cf().greaterOrEqual(CALENDAR_MONTH(Contact.Birthdate), 1));
  }

  @isTest
  static void greaterThanCriteriaForNumeric() {
    assertEquals('TotalOpportunityQuantity > 2', cf().greaterThan(Opportunity.TotalOpportunityQuantity, 2));
  }

  @isTest
  static void greaterThanCriteriaForDateField() {
    assertEquals('Birthdate > 1995-05-21', cf().greaterThan(Contact.Birthdate, Date.valueOf('1995-05-21')));
  }

  @isTest
  static void greaterThanCriteriaForDateString() {
    assertEquals('Birthdate > 1995-05-21', cf().greaterThan(Contact.Birthdate, '1995-05-21'));
  }

  @isTest
  static void greaterThanCriteriaForDateFunction() {
    assertEquals('CALENDAR_MONTH(Birthdate) > 1', cf().greaterThan(CALENDAR_MONTH(Contact.Birthdate), 1));
  }

  @isTest
  static void lessThanCriteriaForNumeric() {
    assertEquals('TotalOpportunityQuantity < 2', cf().lessThan(Opportunity.TotalOpportunityQuantity, 2));
  }

  @isTest
  static void lessThanCriteriaForDateField() {
    assertEquals('Birthdate < 1995-05-21', cf().lessThan(Contact.Birthdate, Date.valueOf('1995-05-21')));
  }

  @isTest
  static void lessThanCriteriaForDateString() {
    assertEquals('Birthdate < 1995-05-21', cf().lessThan(Contact.Birthdate, '1995-05-21'));
  }

  @isTest
  static void lessThanCriteriaForDateFunction() {
    assertEquals('CALENDAR_MONTH(Birthdate) < 6', cf().lessThan(CALENDAR_MONTH(Contact.Birthdate), 6));
  }

  @isTest
  static void lessOrEqualCriteriaForNumeric() {
    assertEquals('TotalOpportunityQuantity <= 2', cf().lessOrEqual(Opportunity.TotalOpportunityQuantity, 2));
  }

  @isTest
  static void lessOrEqualCriteriaForDateField() {
    assertEquals('Birthdate <= 1995-05-21', cf().lessOrEqual(Contact.Birthdate, Date.valueOf('1995-05-21')));
  }

  @isTest
  static void lessOrEqualCriteriaForDateString() {
    assertEquals('Birthdate <= 1995-05-21', cf().lessOrEqual(Contact.Birthdate, '1995-05-21'));
  }

  @isTest
  static void lessOrEqualCriteriaForDateFunction() {
    assertEquals('CALENDAR_MONTH(Birthdate) <= 6', cf().lessOrEqual(CALENDAR_MONTH(Contact.Birthdate), 6));
  }

  @isTest
  static void inCriteriaForStrings() {
    List<String> inValues = new List<String>{ 'BMW', 'Jeep' };
    assertEquals('Name IN (\'BMW\',\'Jeep\')', cf().isIn(Account.Name, inValues));
  }

  @isTest
  static void inCriteriaForNonStrings() {
    List<Integer> inValues = new List<Integer>{ 1, 2, 3 };
    assertEquals('NumberOfEmployees IN (1,2,3)', cf().isIn(Account.NumberOfEmployees, inValues));
  }

  @isTest
  static void inCriteriaForSubSelect() {
    String subSelect = 'SELECT Id FROM Account';
    assertEquals('AccountId IN (SELECT Id FROM Account)', cf().isIn(Contact.AccountId, subSelect));
  }

  @isTest
  static void inCriteriaForDateFunction() {
    List<Integer> inValues = new List<Integer>{ 1, 2, 3 };
    assertEquals('CALENDAR_MONTH(Birthdate) IN (1,2,3)', cf().isIn(CALENDAR_MONTH(Contact.Birthdate), inValues));
  }

  @isTest
  static void notInCriteriaForSubSelect() {
    String subSelect = 'SELECT Id FROM Account';
    assertEquals('AccountId NOT IN (SELECT Id FROM Account)', cf().isNotIn(Contact.AccountId, subSelect));
  }

  @isTest
  static void notInCriteriaForStrings() {
    List<String> inValues = new List<String>{ 'BMW', 'Jeep' };
    assertEquals('Name NOT IN (\'BMW\',\'Jeep\')', cf().isNotIn(Account.Name, inValues));
  }

  @isTest
  static void notInCriteriaForNonStrings() {
    List<Integer> inValues = new List<Integer>{ 1, 2, 3 };
    assertEquals('NumberOfEmployees NOT IN (1,2,3)', cf().isNotIn(Account.NumberOfEmployees, inValues));
  }

  @isTest
  static void notInCriteriaForDateFunction() {
    List<Integer> inValues = new List<Integer>{ 1, 2, 3 };
    assertEquals('CALENDAR_MONTH(Birthdate) NOT IN (1,2,3)', cf().isNotIn(CALENDAR_MONTH(Contact.Birthdate), inValues));
  }

  @isTest
  static void likeCriteria() {
    assertEquals('Name LIKE \'%force\'', cf().isLike(Account.Name, '%force'));
  }

  @isTest
  static void wrapsNotLikeCriteriaIntoBrackets() {
    assertEquals('(NOT Name LIKE \'%force\')', cf().isNotLike(Account.Name, '%force'));
  }

  @isTest
  static void isNull() {
    assertEquals('Name = NULL', cf().isNull(Account.Name));
  }

  @isTest
  static void isNotNull() {
    assertEquals('Name != NULL', cf().isNotNull(Account.Name));
  }

  @isTest
  static void joinsCriteriaViaAndByDefault() {
    assertEquals(
      'Industry != NULL AND NumberOfEmployees >= 100',
      cf().isNotNull(Account.Industry).greaterOrEqual(Account.NumberOfEmployees, 100)
    );
  }

  @isTest
  static void canJoinViaOrIfConfigured() {
    assertEquals(
      'Industry != NULL OR NumberOfEmployees >= 100',
      cf().isNotNull(Account.Industry).withOr().greaterOrEqual(Account.NumberOfEmployees, 100)
    );
  }

  @isTest
  static void criteriaBasedOnReferenceAttributes() {
    assertEquals(
      'Account.Industry != NULL AND Account.NumberOfEmployees >= 100',
      cf()
        .configureForReferenceField(Contact.AccountId)
        .isNotNull(Account.Industry)
        .greaterOrEqual(Account.NumberOfEmployees, 100)
    );
  }

  @isTest
  static void dateFunctionCriteriaBasedOnReferenceAttributes() {
    assertEquals(
      'CALENDAR_MONTH(Opportunity.CloseDate) = 3',
      cf()
        .configureForReferenceField(OpportunityLineItem.OpportunityId)
        .equalsTo(CALENDAR_MONTH(Opportunity.CloseDate), 3)
    );
  }

  @isTest
  static void wrapsCompositeCriteriaIntoBrackets() {
    assertEquals(
      'Department LIKE \'Finance%\' AND (Email = NULL OR Title != NULL)',
      cf()
        .isLike(Contact.Department, 'Finance%')
        .composite(cf().isNull(Contact.Email).withOr().isNotNull(Contact.Title))
    );
  }

  @isTest
  static void usesBindingVariables() {
    assertEquals('Name = :companyName', cf().equalsTo(Account.Name, ':companyName'));
    assertEquals('Name != :companyName', cf().notEqualsTo(Account.Name, ':companyName'));
    assertEquals('Birthdate = :birthDate', cf().equalsTo(Contact.Birthdate, ':birthDate'));
    assertEquals('CreatedDate = :createdDate', cf().equalsTo(Contact.CreatedDate, ':createdDate'));
    assertEquals('NumberOfEmployees > :value', cf().greaterThan(Account.NumberOfEmployees, ':value'));
    assertEquals('Birthdate > :birthDate', cf().greaterThan(Contact.Birthdate, ':birthDate'));
    assertEquals('CreatedDate > :createdDate', cf().greaterThan(Contact.CreatedDate, ':createdDate'));
    assertEquals('NumberOfEmployees >= :value', cf().greaterOrEqual(Account.NumberOfEmployees, ':value'));
    assertEquals('Birthdate >= :birthDate', cf().greaterOrEqual(Contact.Birthdate, ':birthDate'));
    assertEquals('CreatedDate >= :createdDate', cf().greaterOrEqual(Contact.CreatedDate, ':createdDate'));
    assertEquals('NumberOfEmployees < :value', cf().lessThan(Account.NumberOfEmployees, ':value'));
    assertEquals('Birthdate < :birthDate', cf().lessThan(Contact.Birthdate, ':birthDate'));
    assertEquals('CreatedDate < :createdDate', cf().lessThan(Contact.CreatedDate, ':createdDate'));
    assertEquals('NumberOfEmployees <= :value', cf().lessOrEqual(Account.NumberOfEmployees, ':value'));
    assertEquals('Birthdate <= :birthDate', cf().lessOrEqual(Contact.Birthdate, ':birthDate'));
    assertEquals('CreatedDate <= :createdDate', cf().lessOrEqual(Contact.CreatedDate, ':createdDate'));
    assertEquals('Name IN (:inValues)', cf().isIn(Account.Name, ':inValues'));
    assertEquals('Birthdate IN (:inValues)', cf().isIn(Contact.Birthdate, ':inValues'));
    assertEquals('CreatedDate IN (:inValues)', cf().isIn(Contact.CreatedDate, ':inValues'));
    assertEquals('Name NOT IN (:inValues)', cf().isNotIn(Account.Name, ':inValues'));
    assertEquals('Birthdate NOT IN (:inValues)', cf().isNotIn(Contact.Birthdate, ':inValues'));
    assertEquals('CreatedDate NOT IN (:inValues)', cf().isNotIn(Contact.CreatedDate, ':inValues'));
    assertEquals('Name LIKE :likeValue', cf().isLike(Account.Name, ':likeValue'));
    assertEquals('(NOT Name LIKE :likeValue)', cf().isNotLike(Account.Name, ':likeValue'));
  }

  @isTest
  static void combinesStaticValuesAndBindingVariables() {
    assertEquals(
      'Department LIKE \'Finance%\' AND Email = :theEmail',
      cf().isLike(Contact.Department, 'Finance%').equalsTo(Contact.Email, ':theEmail')
    );
  }

  @isTest
  static void cannotExceed4000CharactersInWhereClause() {
    String criteria = 'CALENDAR_MONTH(Birthdate) = 1';
    String joinCondition = ' AND ';
    Integer theLimit = 4000;
    Integer failOnIterationNumber = (theLimit + joinCondition.length()) / (criteria.length() + joinCondition.length());
    Boolean exceptionThrown = false;
    Integer latestIndex = 0;
    fflib_CriteriaFactory cf = cf();

    try {
      do {
        cf.equalsTo(CALENDAR_MONTH(Contact.Birthdate), 1);
      } while (latestIndex++ < theLimit);
    } catch (Exception e) {
      exceptionThrown = true;
    }

    System.assert(exceptionThrown, 'should throw exception if "WHERE" clause exeeds 4000');
    System.assertEquals(failOnIterationNumber, latestIndex);
  }

  private static fflib_CriteriaFactory cf() {
    return fflib_CriteriaFactory.builder();
  }

  private static void assertEquals(String expectedCriteria, fflib_CriteriaFactory criteriaBuilder) {
    System.assertEquals(expectedCriteria, criteriaBuilder.toCriteria());
  }

  private static fflib_CriteriaFactory.SoqlDateFunction CALENDAR_MONTH(Schema.SObjectField field) {
    return fflib_CriteriaFactory.dateFunction(fflib_CriteriaFactory.DateFunction.CALENDAR_MONTH, field);
  }
}
