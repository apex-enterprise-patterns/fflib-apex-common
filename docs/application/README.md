# Application 

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

    // Configure and create the ServiceFactory for this Application
    public static final fflib_BindingResolver Service = 
            new fflib_ForceDiResolver();

    // Configure and create the SelectorFactory for this Application
    public static final fflib_SelectorBindingResolver Selector = 
            new fflib_ForceDiSelectorResolver(APP_NAME);

    // Configure and create the DomainFactory for this Application
    public static final fflib_DomainBindingResolver Domain = 
            new fflib_ForceDiDomainResolver(APP_NAME, Application.Selector);

}
```
The plugin required an `APP_NAME`, which is either the Namespace
or another unique application identifier with a similar format as the Namespace.

No changes were made to the UnitOfWork factory, so will stay the same.

Instead of defining a list with all the dependencies we just create three new factory instances,
one for Service, Selector and Domain.
Only the Selector and Domain need to know the Namespace or App_Name.
These factories will connect with Force-Di to retrieve the dependencies.

The methods on the application factories are the same as the current fflib implementation,
which makes implementing this plugin very easy.

All the bindings are stored not in the standard force-di binding object but in
the custom meta-data object 'Enterprise Pattern Binding' (`fflib_Binding__mdt`).
This object is very similar to the one in force-di with the exception of the specific Type
(Selector, Domain, Service).
This object only supports Apex files. Any other dependency injection for e.g. Lightning Components
still need to be registered in the force-di binding object.


## Class & Method reference

- di_Bindings,
  <br/> domain class for Di Bindings
- [di_Configurator](docs/di-Configurator.md), creates Di Bindings at runtime
- fflib_Bindings, Domain class for fflib_Binding_mdt
- fflib_BindingsSelector, Selector for the Custom Metadata object fflib_Binding__mdt
- fflib_CustomMetaDataModule, Dependency Injection module to register the bindings for the SoC layers
- fflib_DeveloperException, Generic exception class
- [fflib_DomainFactory](docs/fflib_DomainFactory.md), Interface for the Domain factory to be able to dynamically instantiate domains
- [fflib_SelectorFactory](),

### Domain Factory

#### newInstance(Set<Id> recordIds)
```apex
public  fflib_ISObjectDomain newInstance(Set<Id> recordIds);
```
Queries the records and constructs a new domain instance for the query result

###### Example
    public with sharing class MyAccountService
    {
        public void myMethod(Set<Id> idSet)
        {
            Accounts domain = (Accounts) Application.Domain.newInstance(idSet);
            ...
        }
    }

#### newInstance(List<SObject> records)
```apex
public fflib_ISObjectDomain newInstance(List<SObject> records);
```
Gets the SObjectType from the list of records and constructs a new instance of the domain with the records

###### Example
    public with sharing class MyAccountService
    {
        public void myMethod(List<Accounts> records)
        {
            Accounts domain = (Accounts) Application.Domain.newInstance(records);
            ...
        }
    }

#### newInstance(List<SObject> records, SObjectType domainSObjectType);
```apex
public fflib_ISObjectDomain newInstance(List<SObject> records, SObjectType domainSObjectType);
```
Gets the instance for the domain constructor from force-di and constructs a new domain

###### Example
    public with sharing class MyAccountService
    {
        public void myMethod(List<SObject> records)
        {
            Accounts domain = (Accounts) Application.Domain.newInstance(records, Account.SObjectType);
            ...
        }
    }

#### replaceWith(SObjectType sObjectType, Object domainImpl)
```apex
public void replaceWith(SObjectType sObjectType, Object domainImpl);
```
Dynamically replace a domain implementation at runtime.
As this is a domain class and domain classes are constructed via the sub-class Constructor
we need to replace the binding with the Constructor implementation and not the actual domain implementation.

###### Example
```apex
    public with sharing class MyAccountService
    {
        public void myMethod(List<Account> records)
        {
            if (isUserInTestGroup())
            {
                Application.Domain.replaceWith(Schema.Account.SObjectType, new TestGroep_AccountsImp.Constructor());
            }

            // This domain will be different for the users in the TestGroup
            Accounts domain = (Accounts) Application.Domain.newInstance(records);
        }
    }
```

```apex
@IsTest
static void itShouldRunMyTest()
{
    // GIVEN
    fflib_ApexMocks mocks = new fflib_ApexMocks();
    AccountsConstructor domainConstructorMock = (Accounts) mocks.mock(AccountsImp.class);
    Application.Service.replaceWith(Schema.Account.SObjectType, domainMock)
    
    
}
```

#### setMock(SObjectType sObjectType, Object mockImp)
```apex
void setMock(Schema.SObjectType sObjectType, Object domainImp);
```


### Selector Factory

#### newInstance(Schema.SObjectType sObjectType)
```apex
public fflib_ISObjectSelector newInstance(Schema.SObjectType sObjectType);
```

###### Example
    public with sharing class MyAccountService
    {
        public void myMethod(Set<Id> idSet)
        {
            List<Account> records = 
                    ((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
                            .selectById(idSet);
            ...
        }
    }

#### replaceWith(Schema.SObjectType sObjectType, Object selectorImpl);
```apex
public void replaceWith(Schema.SObjectType sObjectType, Object selectorImpl);
```
Used to replace the implementation for another, e.g. a mock


#### selectById(Set<Id> recordIds);
```apex
List<SObject> selectById(Set<Id> recordIds);
```
Method to query the given SObject records and internally creates
an instance of the registered Selector and calls its selectSObjectById method.

###### Example
    public with sharing class MyAccountService
    {
        public void myMethod(Set<Id> idSet)
        {
            List<Account> records = (List<Account>) Application.Selector.selectById(idSet);
            ...
        }
    }

#### selectByRelationship(List<SObject> relatedRecords, Schema.SObjectField relationshipField);
```apex
public 
List<SObject> selectByRelationship(List<SObject> relatedRecords, Schema.SObjectField relationshipField);

```
Method to query related records to those provided,
for example if passed a list of Opportunity records and the AccountId field will
construct internally a list of Account Ids and call the registered
Account selector to query the related Account records, e.g.

###### Example
     public with sharing class Opportunities
     {
        public List<Account> getRelatedAccountRecords()
        {
            return (List<Account>) Application.Selector.selectByRelationship(Records, Opportunity.AccountId);
        }
    }

### Service Factory

#### newInstance(Type serviceInterfaceType);
```apex
public Object newInstance(Type serviceInterfaceType);
```
Creates a new instance of a service class by referencing its binding type

###### Example
     public with sharing class MyController
     {
        public void myMethod()
        {
            ((MyService) Application.Service.newInstance(MyService.class))
                    .myServiceMethod();
        }
    }
    
    public interface MyService
    {
        myServiceMethod();
    }
    
    public with sharing MyServiceImp implements MyService
    {
        public void myServiceMethod()
        {
            ...
        }
    }

#### replaceWith(Type serviceInterfaceType, Object serviceImpl);
```apex
public void replaceWith(Type serviceInterfaceType, Object serviceImpl);
```
Used to replace the implementation for another, e.g. a mock


## Project Folders
|Folder|Description|
|:---|:---|
|sfdx-source/force-app/main/default|Core of the application|
|sfdx-source/force-app/examples|Examples|


Have fflib use the force-di package to enable dependency injection 