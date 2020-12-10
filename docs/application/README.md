# Application 

The Application class is redesigned compared to the original version. 
It is 100% backwards compatible, but will send warning messages to the Debug log.

Main intend to redesign the Application is to align the architecture more with the Liskov's Substitution principle 
of the SOLID design principle. 
The new interface structure allows multiple implementations of the Factories, which are renamed to BindingResolvers.

There are two default implementations provided
- [Classic based on maps](#classic-factories) <br/> 
  Similar than the Factories in the original AEP
- [Force-Di](#force-di-bindings) <br/>
  A new dependency has been added to allow fflib to connect with all the features of force-di
  If this dependency is not desired, simply remove the folder `sfdx-source/apex-common/force-di`.
  

## Classic Factories
Binding based on static maps in Apex

```apex
public with sharing class Application
{
    public static final fflib_BindingResolver Service =
            new fflib_ClassicBindingResolver(
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

## Force-DI Bindings

The Application Force-DI bindings are designed to integrate force-di with the Apex Enterprise Patterns v2.0.


### Example:
```apex
public with sharing class Application
{
    public static final String APP_NAME = 'MyForceApp';

    // Configure and create the UnitOfWorkFactory for this Application
    public static final fflib_Application.UnitOfWorkFactory UnitOfWork =
            new fflib_Application.UnitOfWorkFactory(
                    new List<SObjectType>
                    {
                            Account.SObjectType,
                            Contact.SObjectType
                    });

    // Configure and create the Binding Resolver Factory for this Application
    public static final fflib_BindingResolver Service = 
            new fflib_ForceDiBindingResolver();

    // Configure and create the SelectorFactory for this Application
    public static final fflib_SelectorBindingResolver Selector = 
            new fflib_ForceDiSelectorBindingResolver(APP_NAME);

    // Configure and create the DomainFactory for this Application
    public static final fflib_DomainBindingResolver Domain = 
            new fflib_ForceDiDomainBindingResolver(APP_NAME, Application.Selector);
}
```
The plugin requires an `APP_NAME`, which is used in the binding name to identify the bindings belonging to the application.
The AEP 2.0 binding resolvers construct a force-di binding name based on
  - AppName, 
  - Type of binding (Domain, Selector, Service)
  - Object type 

The bindings are stored in `fflib_Bindings__mdt` and imported into Force-Di via the module `fflib_CustomMetadataModule`.
