FFLib Apex Common
=================

# Application class

### Example - Binding based on static maps in Apex

```apex
public with sharing class Application
{
    public static final fflib_ServiceBindingResolver Service =
            new fflib_ClassicServiceBindingResolver(
                    new Map<Type, Type>
                    {
                            AccountsService.class => AccountsServiceImp.class
                    }
            );

    public static final fflib_SelectorBindingResolver Selector =
            new fflib_ClassicSelectorBindingResolver(
                    new Map<SObjectType, Type>
                    {
                            Account.SObjectType => AccountsSelector.class
                    }
            );

    public static final fflib_DomainBindingResolver Domain =
            new fflib_ClassicDomainBindingResolver(
                    Application.Selector,
                    new Map<SObjectType, Type>
                    {
		                    Schema.Account.SObjectType => Accounts.Constructor.class
                    }
            );

    public static final fflib_Application.UnitOfWorkFactory UnitOfWork =
            new fflib_Application.UnitOfWorkFactory(
                    new List<SObjectType>
                    {
                            Account.SObjectType,
                            Contact.SObjectType
                    }
           );
}
```