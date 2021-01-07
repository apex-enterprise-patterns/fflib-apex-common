# Selector

## Ordering

Previously there were two ways to add ordering to SOQL queries in selector classes
- Overriding the method `getOrderBy()`
- Via the QueryFactory method; `addOrdering` or `setOrdering`

These two ways are fully controlled by the selector class. 
If another class, e.g. a Service class want to change the behaviour of the ordering, 
then that could only be done via method arguments, which makes the method calls on the selector very cumbersome.

Therefore a third ways is introduced in fflib 2.0, 
where the class that is invoking the selector method can request a different sorting order.
This method is named `setOrdering` and can be called on the selector instance.

Here is an example on how that would look like:

**AccountsSelector.cls**
```
public with sharing class AccountsSelector implements fflib_SObjectSelector
{
    ...
    public static fflib_QueryFactory.Ordering largeAccountsFirst =
            new fflib_QueryFactory.Ordering(Account.NumberOfEmployees, fflib_QueryFactory.SortOrder.DESCENDING);

    public List<Account> selectById(Set<Id> idSet)
    {
        return (List<Account>) selectSObjectsById(idSet);
    }
    ....
}
```

**AccountsService.cls**
```
public with sharing class AccountsService
{
    public void MyServiceMethod(Set<Id> idSet)
    {
        List<Account> records = 
                ((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
                        .setOrdering(AccountsSelector.largeAccountsFirst)
                        .setLimit(10)
                        .selectById(idSet);
        ....
    }
}
```

