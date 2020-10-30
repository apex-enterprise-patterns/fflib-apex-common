# Criteria

The criteria class can be used to have one common filter for both selector and domain classes. Where the selector is
querying its data for a source and the domain queries the data in memory from its own objects.

## Design pattern
Often the same filters are repeated in the domain and the selector classes. 
The Criteria feature provides a solution for that by extracting the filter conditions
into a single reusable criteria class. 
The filter conditions are made dynamic so that they can be evaluated in run-time,
or be converted to a SOQL statement condition.
```
                + - - - - - - - - +
        + - - - | Filter Criteria | - - - +  
        |       + - - - - - - - - +       |
        |                                 | 
        |                                 |
+ - - - - - - - +                 + - - - - - - - +
|    Domain     |                 |    Selector   |
+ - - - - - - - +                 + - - - - - - - +
```

## Examples

### Criteria Class
The criteria class is the place where all the filter conditions are stored for a single domain.
```apex
public with sharing class AccountCriteria extends fflib_Criteria
{
    public AccountCriteria ShippingCountryEquals(String countryName)
    { 
        equalTo(Schema.Account.ShippingCountry, countryName);
        return this;                
    }
    
    public AccountCriteria NumberOfEmployeesGreaterThan(Integer numberOfEmployees)
    {
        greaterThan(Schema.Account.NumberOfEmployees, numberOfEmployees);
        return this;
    }
}
```

### SObject Domain 

```apex
public with sharing class AccountsImp
        extends SObjects
        implements Accounts
{
    private static final Integer LARGE_ACCOUNT_EMPLOYEE_NUMBERS = 500;

    public Accounts getByCountry(String countryName)
    {
        return new AccountsImp(
                getRecords(
                        new AccountCriteria().ShippingCountryEquals(countryName)
                )
        );
    }
    
    public Accounts getByNumberOfEmployeesGreaterThan(Integer numberOfEmployees)
    {
        return new AccountsImp(
                getRecords(
                       new AccountCriteria().NumberOfEmployeesGreaterThan(numberOfEmployees)
                )
        );
    }
    
    public Accounts getByLargeAccountsInCountry(String countryName)
    {
        return getByCountry(countryName)
                .getByNumberOfEmployeesGreaterThan(LARGE_ACCOUNT_EMPLOYEE_NUMBERS);
    }
}
```
In this example we see three filters; one for country, another for checking minimal number of employees and a third that combines the first two.
It is important not to have a filter with too many conditions. 
One filter criteria condition per method is ideal to have maximum flexibility and a high chance on code-reuse.

### SObject Selector 
```apex
public with sharing class AccountsSelectorImp
        extends fflib_SObjectSelector
{
    ...
    public List<Account> selectByCountryWithMinimalNumberOfEmployees(String country, Integer minimalNumberOfEmployees)
    {
        return (List<Account>)  Database.query(
                newQueryFactory()
                        .setCondition(
                                new AccountCriteria()
                                        .ShippingCountryEquals(country)
                                        .NumberOfEmployeesGreaterThan(minimalNumberOfEmployees)
        );
    }
    ...
}
```

### Usage
```apex
public with sharing class AccountsServiceImp
        implements AccountsService
{
    private AccountsSelector Selector 
    {
        get
        {
            if (Selector == null) 
            {
                Selector = Application.Selector.newInstance(Account.SObjectType);
            }
            return Selector;
        }
        private set;
    }
    
    public void setLargeIrelandAccountsToRatingHot()
    {
        Accounts largeIrelandAccounts = 
                ((Accounts) Application.Domain.newInstance(
                        Selector.selectByCountryWithMinimalNumberOfEmployees('Ireland', 500)
                ));
        
        if (largeIrelandAccounts.isEmpty()) return;
        
        largeIrelandAccounts.setRating('Hot');
        
        update largeIrelandAccounts.getRecords(); // UnitOfWork is omitted here to keep things clear
    }
    
    public void setLargeIrelandAccountsToRatingHot(List<Account> records)
    {
        Accounts largeIrelandAccounts = 
                ((Accounts) Application.Domain.newInstance(records))
                        .getByLargeAccountsInCountry('Ireland');

        if (largeIrelandAccounts.isEmpty()) return;

        largeIrelandAccounts.setRating('Hot');

        update largeIrelandAccounts.getRecords(); // UnitOfWork is omitted here to keep things clear
    }
}
```


### Object Domain
todo

