@isTest
public class fflib_CriteriaBuilderTest {
    @isTest
    static void equalsCriteriaForString(){
        fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));

        cb.equals('Name', 'salesforce');

      assertEquals('Name = \'salesforce\'', cb);
    }
  
    @isTest
    static void equalsCriteriaForBoolean() {
        fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Opportunity.getSObjectType()));
        cb.equals('HasOpportunityLineItem', true);
      assertEquals('HasOpportunityLineItem = true',cb);
    }
  
    @isTest
    static void equalsCriteriaForNumeric() {
        fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Opportunity.getSObjectType()));
        cb.equals('TotalOpportunityQuantity', 2);
        assertEquals('TotalOpportunityQuantity = 2', cb);
    }
  
    @isTest
    static void equalsCriteriaForDateField() {
        fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Contact.getSObjectType()));

        cb.equals('Birthdate', Date.valueOf('1995-05-21'));
      assertEquals('Birthdate = 1995-05-21', cb);
    }
  
    @isTest
    static void equalsCriteriaForDateString() {
        fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Contact.getSObjectType()));
        cb.equals('Birthdate', '1995-05-21');
        assertEquals('Birthdate = 1995-05-21',cb);
    }
  
    // @isTest
    // static void equalsCriteriaForDateFunction() {
    //     fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
    //     cb.equals(CALENDAR_MONTH(Contact.Birthdate), 12);
    //     assertEquals('CALENDAR_MONTH(Birthdate) = 12',cb);
    // }
  
    // @isTest
    // static void dateFieldToFailIfInvalidArgument() {
    //   Boolean exceptionWasThrown = false;
    //   try {
    //         fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Contact.getSObjectType()));
    //         cb.equals('Birthdate', 12);
    //   } catch (IllegalArgumentException iae) {
    //     exceptionWasThrown = true;
    //   }
    //   System.assert(exceptionWasThrown, 'should fail when building criteria with integer value for Date field');
    // }
  
    @isTest
    static void equalsCriteriaForDatetime() {
      Datetime dateTimeValue = DateTime.newInstance(2022, 2, 24, 3, 12, 4);
      fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
        cb.equals('CreatedDate', dateTimeValue);
      assertEquals('CreatedDate = 2022-02-24T03:12:04Z', cb);
    }
  
    @isTest
    static void equalsCriteriaForDatetimeString() {
        fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
        cb.equals('CreatedDate', '2022-02-24T03:12:04Z');
      assertEquals('CreatedDate = 2022-02-24T03:12:04Z',cb);
    }
  
//     @isTest
//     static void dateTimeFieldToFailIfInvalidArgument() {
//       Boolean exceptionWasThrown = false;
//       try {
//                 fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Contact.getSObjectType()));
// cb.equals('CreatedDate', 12);
//       } catch (IllegalArgumentException iae) {
//         exceptionWasThrown = true;
//       }
//       System.assert(exceptionWasThrown, 'should fail when building criteria with integer value for Datetime field');
//     }
  
    @isTest
    static void equalsCriteriaForDateLiteral() {
        fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
        cb.equals('CreatedDate', 'TODAY');
      assertEquals('CreatedDate = TODAY',cb);
      fflib_CriteriaBuilder cb2= new fflib_CriteriaBuilder(new fflib_QueryFactory(Contact.getSObjectType()));
      cb2.equals('Birthdate', 'TODAY');
      assertEquals('Birthdate = TODAY', cb2);
    }
  
    @isTest
    static void notequalsCriteriaForString() {
        fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
        cb.notequals('Name', 'microsoft');
      assertEquals('Name != \'microsoft\'',cb);
    }
  
    @isTest
    static void notequalsCriteriaForNumeric() {
        fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Opportunity.getSObjectType()));
cb.notequals('TotalOpportunityQuantity', 2);
      assertEquals('TotalOpportunityQuantity != 2',   cb      );
    }
  
    @isTest
    static void notequalsCriteriaForDateField() {
        fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Contact.getSObjectType()));
cb.notequals('Birthdate', Date.valueOf('1995-05-21'));
      assertEquals('Birthdate != 1995-05-21',        cb );
    }
  
    @isTest
    static void notequalsCriteriaForDateString() {
        fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Contact.getSObjectType()));
        cb.notequals('Birthdate', '1995-05-21');
      assertEquals('Birthdate != 1995-05-21', cb);
    }
  
    // @isTest
    // static void notequalsCriteriaForDateFunction() {
    //     fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
    //     cb.notequals(CALENDAR_MONTH(Contact.Birthdate), 1);
    //   assertEquals('CALENDAR_MONTH(Birthdate) != 1',cb);
    // }
  
    @isTest
    static void greatherThanOrEqualsToCriteriaForNumeric() {
        fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Opportunity.getSObjectType()));
        cb.greatherThanOrEqualsTo('TotalOpportunityQuantity', 2);
      assertEquals('TotalOpportunityQuantity >= 2',cb);
    }
  
    @isTest
    static void greatherThanOrEqualsToCriteriaForDateField() {
        fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Contact.getSObjectType()));
        cb.greatherThanOrEqualsTo('Birthdate', Date.valueOf('1995-05-21'));
      assertEquals('Birthdate >= 1995-05-21',cb);
    }
  
    @isTest
    static void greatherThanOrEqualsToCriteriaForDateString() {
        fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Contact.getSObjectType()));
        cb.greatherThanOrEqualsTo('Birthdate', '1995-05-21');
      assertEquals('Birthdate >= 1995-05-21',cb);
    }
  
    // @isTest
    // static void greatherThanOrEqualsToCriteriaForDateFunction() {
    //     fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
    //     cb.greatherThanOrEqualsTo(CALENDAR_MONTH(Contact.Birthdate), 1);
    //     assertEquals('CALENDAR_MONTH(Birthdate) >= 1',         cb);
    // }
  
    @isTest
    static void greatherThanCriteriaForNumeric() {
        fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Opportunity.getSObjectType()));
cb.greatherThan('TotalOpportunityQuantity', 2);
      assertEquals('TotalOpportunityQuantity > 2',       cb  );
    }
  
    @isTest
    static void greatherThanCriteriaForDateField() {
        fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Contact.getSObjectType()));
        cb.greatherThan('Birthdate', Date.valueOf('1995-05-21'));
      assertEquals('Birthdate > 1995-05-21',        cb);
    }
  
    @isTest
    static void greatherThanCriteriaForDateString() {
        fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Contact.getSObjectType()));
        cb.greatherThan('Birthdate', '1995-05-21');
      assertEquals('Birthdate > 1995-05-21',   cb);
    }
  
    // @isTest
    // static void greatherThanCriteriaForDateFunction() {
    //     fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
    //     cb.greatherThan(CALENDAR_MONTH(Contact.Birthdate), 1);
    //   assertEquals('CALENDAR_MONTH(Birthdate) > 1', cb);
    // }
  
    @isTest
    static void lessThanCriteriaForNumeric() {
        fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Opportunity.getSObjectType()));
        cb.lessThan('TotalOpportunityQuantity', 2);
      assertEquals('TotalOpportunityQuantity < 2',cb);
    }
  
    @isTest
    static void lessThanCriteriaForDateField() {
        fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Contact.getSObjectType()));
        cb.lessThan('Birthdate', Date.valueOf('1995-05-21'));
        assertEquals('Birthdate < 1995-05-21',         cb);
    }
  
    @isTest
    static void lessThanCriteriaForDateString() {
        fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Contact.getSObjectType()));
        cb.lessThan('Birthdate', '1995-05-21');
      assertEquals('Birthdate < 1995-05-21',cb);
    }
  
    // @isTest
    // static void lessThanCriteriaForDateFunction() {
    //     fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
    //     cb.lessThan(CALENDAR_MONTH(Contact.Birthdate), 6);
    //   assertEquals('CALENDAR_MONTH(Birthdate) < 6', cb);
    // }
  
    @isTest
    static void lessThanOrEqualsToCriteriaForNumeric() {
        fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Opportunity.getSObjectType()));
cb.lessThanOrEqualsTo('TotalOpportunityQuantity', 2);
      assertEquals('TotalOpportunityQuantity <= 2',        cb );
    }
  
    @isTest
    static void lessThanOrEqualsToCriteriaForDateField() {
        fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Contact.getSObjectType()));
        cb.lessThanOrEqualsTo('Birthdate', Date.valueOf('1995-05-21'));
      assertEquals('Birthdate <= 1995-05-21',        cb);
    }
  
    @isTest
    static void lessThanOrEqualsToCriteriaForDateString() {
        fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Contact.getSObjectType()));
        cb.lessThanOrEqualsTo('Birthdate', '1995-05-21');
      assertEquals('Birthdate <= 1995-05-21',cb);
    }
  
    // @isTest
    // static void lessThanOrEqualsToCriteriaForDateFunction() {
    //     fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
    //     cb.lessThanOrEqualsTo(CALENDAR_MONTH(Contact.Birthdate), 6);
    //   assertEquals('CALENDAR_MONTH(Birthdate) <= 6', cb);
    // }
  
    @isTest
    static void inCriteriaForStrings() {
      List<String> inValues = new List<String>{ 'BMW', 'Jeep' };
      fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
      cb.isIn('Name', inValues);
      assertEquals('Name IN (\'BMW\',\'Jeep\')', cb);
    }
  
    @isTest
    static void inCriteriaForNonStrings() {
      List<Integer> inValues = new List<Integer>{ 1, 2, 3 };
      fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
      cb.isIn('NumberOfEmployees', inValues);
      assertEquals('NumberOfEmployees IN (1,2,3)',cb);
    }
  
    @isTest
    static void inCriteriaForSubSelect() {
      String subSelect = 'SELECT Id FROM Account';
      fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Contact.getSObjectType()));
      cb.isIn('AccountId', subSelect);
      assertEquals('AccountId IN (SELECT Id FROM Account)',cb);
    }
  
    // @isTest
    // static void inCriteriaForDateFunction() {
    //   List<Integer> inValues = new List<Integer>{ 1, 2, 3 };
    //   fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
    //   cb.isIn(CALENDAR_MONTH(Contact.Birthdate), inValues);
    //   assertEquals('CALENDAR_MONTH(Birthdate) IN (1,2,3)',cb);
    // }
  
    @isTest
    static void notInCriteriaForSubSelect() {
      String subSelect = 'SELECT Id FROM Account';
      fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Contact.getSObjectType()));
      cb.notIn('AccountId', subSelect);
      assertEquals('AccountId NOT IN (SELECT Id FROM Account)',cb);
    }
  
    @isTest
    static void notInCriteriaForStrings() {
      List<String> inValues = new List<String>{ 'BMW', 'Jeep' };
      fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
      cb.notIn('Name', inValues);
      assertEquals('Name NOT IN (\'BMW\',\'Jeep\')',cb);
    }
  
    @isTest
    static void notInCriteriaForNonStrings() {
      List<Integer> inValues = new List<Integer>{ 1, 2, 3 };
      fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
      cb.notIn('NumberOfEmployees', inValues);
      assertEquals('NumberOfEmployees NOT IN (1,2,3)',    cb);
    }
  
    // @isTest
    // static void notInCriteriaForDateFunction() {
    //   List<Integer> inValues = new List<Integer>{ 1, 2, 3 };
    //   fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
    //   cb.notIn(CALENDAR_MONTH(Contact.Birthdate), inValues);
    //   assertEquals('CALENDAR_MONTH(Birthdate) NOT IN (1,2,3)',cb);
    // }
  
    @isTest
    static void likeCriteria() {
        fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
        cb.isLike('Name', '%force');
      assertEquals('(Name LIKE \'%force\')',  cb);
    }
  
    @isTest
    static void wrapsNotLikeCriteriaIntoBrackets() {
        fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
        cb.notLike('Name', '%force');
      assertEquals('(NOT Name LIKE \'%force\')',  cb);
    }
  
    @isTest
    static void isNull() {
        fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
        cb.isNull('Name');
      assertEquals('Name = NULL',cb);
    }
  
    @isTest
    static void notNull() {
        fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
        cb.notNull('Name');
      assertEquals('Name != NULL', cb);
    }
  
    @isTest
    static void joinsCriteriaViaAndByDefault() {
        fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
        cb.withAnd(cb.notNull('Industry'),cb.greatherThanOrEqualsTo('NumberOfEmployees', 100));
        assertEquals(
            'Industry != NULL AND NumberOfEmployees >= 100',
            cb
      );
    }
  
    @isTest
    static void canJoinViaOrIfConfigured() {
        fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
        cb.withOr(cb.notNull('Industry'),cb.greatherThanOrEqualsTo('NumberOfEmployees', 100));
        assertEquals(
            'Industry != NULL OR NumberOfEmployees >= 100',
            cb
        );
    }
  
    //TODO: get relations for tables
    // @isTest
    // static void criteriaBasedOnReferenceAttributes() {
    //     fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Contact.getSObjectType()));
    //     cb.withAnd(cb.notNull(Account.Industry),
    //               cb.greatherThanOrEqualsTo(Account.NumberOfEmployees, 100));
    //   assertEquals(
    //     'Account.Industry != NULL AND Account.NumberOfEmployees >= 100',
    //     cb
    //   );
    // }
  
    // @isTest
    // static void dateFunctionCriteriaBasedOnReferenceAttributes() {
    //     fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
    //     cb.equals(CALENDAR_MONTH(Opportunity.CloseDate), 3);
    //   assertEquals(
    //     'CALENDAR_MONTH(Opportunity.CloseDate) = 3',
    //             cb
    //   );
    // }
  
    @isTest
    static void wrapsCompositeCriteriaIntoBrackets() {
        fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Contact.getSObjectType()));
        cb.withAnd(cb.isLike('Department', 'Finance%'), cb.withOr(cb.isNull('Email'), cb.notNull('Title')));
      assertEquals(
        '(Department LIKE \'Finance%\') AND (Email = NULL OR Title != NULL)',
        cb
      );
    }
  
    @isTest
    static void usesBindingVariables() {
      fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
      cb.equals('Name', ':companyName');
      assertEquals('Name = :companyName',      cb   );
      cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
      cb.notEquals('Name', ':companyName');

      assertEquals('Name != :companyName',         cb);
      cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Contact.getSObjectType()));
      cb.equals('Birthdate', ':birthDate');

      assertEquals('Birthdate = :birthDate',cb);
      cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
      cb.equals('CreatedDate', ':createdDate');
      assertEquals('CreatedDate = :createdDate',        cb);
           cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
cb.greatherThan('NumberOfEmployees', ':value');
      assertEquals('NumberOfEmployees > :value',     cb);
            cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Contact.getSObjectType()));
cb.greatherThan('Birthdate', ':birthDate');
      assertEquals('Birthdate > :birthDate',    cb);
               cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
cb.greatherThan('CreatedDate', ':createdDate');
      assertEquals('CreatedDate > :createdDate', cb);
      cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
cb.greatherThanOrEqualsTo('NumberOfEmployees', ':value');
      assertEquals('NumberOfEmployees >= :value',         cb);
      cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Contact.getSObjectType()));
cb.greatherThanOrEqualsTo('Birthdate', ':birthDate');
      assertEquals('Birthdate >= :birthDate',         cb);
 cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Contact.getSObjectType()));
cb.greatherThanOrEqualsTo('CreatedDate', ':createdDate');
      assertEquals('CreatedDate >= :createdDate',        cb);
cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
cb.lessThan('NumberOfEmployees', ':value');
      assertEquals('NumberOfEmployees < :value',cb);
cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Contact.getSObjectType()));
cb.lessThan('Birthdate', ':birthDate');
      assertEquals('Birthdate < :birthDate',cb);
cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
cb.lessThan('CreatedDate', ':createdDate');
      assertEquals('CreatedDate < :createdDate',cb);
 cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
cb.lessThanOrEqualsTo('NumberOfEmployees', ':value');
      assertEquals('NumberOfEmployees <= :value',        cb);
 cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Contact.getSObjectType()));
cb.lessThanOrEqualsTo('Birthdate', ':birthDate');
      assertEquals('Birthdate <= :birthDate', cb);
     cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
cb.lessThanOrEqualsTo('CreatedDate', ':createdDate');
      assertEquals('CreatedDate <= :createdDate',        cb);
         cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
cb.isIn('Name', ':inValues');
      assertEquals('Name IN (:inValues)',cb);
         cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Contact.getSObjectType()));
cb.isIn('Birthdate', ':inValues');
      assertEquals('Birthdate IN (:inValues)',cb);
         cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
cb.isIn('CreatedDate', ':inValues');
      assertEquals('CreatedDate IN (:inValues)',cb);
         cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
cb.notIn('Name', ':inValues');
      assertEquals('Name NOT IN (:inValues)',cb);
         cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Contact.getSObjectType()));
cb.notIn('Birthdate', ':inValues');
      assertEquals('Birthdate NOT IN (:inValues)',cb);
    cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
cb.notIn('CreatedDate', ':inValues');
      assertEquals('CreatedDate NOT IN (:inValues)',cb);
         cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
cb.isLike('Name', ':likeValue');
      assertEquals('(Name LIKE :likeValue)',cb);
cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));
cb.notLike('Name', ':likeValue');
      assertEquals('(NOT Name LIKE :likeValue)',         cb);
    }
  
    @isTest
    static void combinesStaticValuesAndBindingVariables() {
        
        fflib_CriteriaBuilder cb= new fflib_CriteriaBuilder(new fflib_QueryFactory(Contact.getSObjectType()));
        cb.withAnd(cb.isLike('Department', 'Finance%'), cb.equals('Email', ':theEmail'));
      assertEquals(
        '(Department LIKE \'Finance%\') AND Email = :theEmail',cb    );
    }
  
    // @isTest
    // static void cannotExceed4000CharactersInWhereClause() {
    //   String criteria = 'CALENDAR_MONTH(Birthdate) = 1';
    //   String joinCondition = ' AND ';
    //   Integer theLimit = 4000;
    //   Integer failOnIterationNumber = (theLimit + joinCondition.length()) / (criteria.length() + joinCondition.length());
    //   Boolean exceptionThrown = false;
    //   Integer latestIndex = 0;
    //   fflib_CriteriaBuilder cf = new fflib_CriteriaBuilder(new fflib_QueryFactory(Account.getSObjectType()));  
    //   try {
    //     do {
    //       cf.equals(CALENDAR_MONTH(Contact.Birthdate), 1);
    //     } while (latestIndex++ < theLimit);
    //   } catch (Exception e) {
    //     exceptionThrown = true;
    //   }
  
    //   System.assert(exceptionThrown, 'should throw exception if "WHERE" clause exeeds 4000');
    //   System.assertEquals(failOnIterationNumber, latestIndex);
    // }

    private static void assertEquals(String expectedCriteria, fflib_CriteriaBuilder criteriaBuilder) {
      Assert.areEqual(expectedCriteria.toUpperCase(), (criteriaBuilder.toSoql()).toUpperCase());
    }
  
    // private static fflib_CriteriaFactory.SoqlDateFunction CALENDAR_MONTH(Schema.SObjectField field) {
    //   return fflib_CriteriaFactory.dateFunction(fflib_CriteriaFactory.DateFunction.CALENDAR_MONTH, field);
    // }
  
}