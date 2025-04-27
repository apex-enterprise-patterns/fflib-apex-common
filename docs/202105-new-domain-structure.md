# New domain structure
The new domain structure allows more flexibility of the object type a domain can contain. 
This allows for the creation of compound-domains and domains of data-classes. 

It also splits the functionality into a Domain Model [as described by Martin Fowler](https://www.martinfowler.com/eaaCatalog/domainModel.html) and a separate trigger handler. 
This helps to structure the code better and makes it more clear which Apex code should be in the domain and which in the trigger handler.



## Previous interface and implementation structure
| Interfaces | Implementation | Description |
|:---|:---|:---|
| fflib_ISObjectDomain | fflib_SObjectDomain | Used as Domain and trigger handler 


## New interface and implementation structure
| Interfaces | Implementation | Description |
|:---|:---|:---|
| fflib_IDomain | | Generic identifier for domains
| fflib_IObjects | fflib_Objects | Domains constructed with Objects, e.g. data-classes 
| fflib_ISObjects | fflib_SObjects | Domain containing SObjectTypes, e.g. Accounts, Contacts
| fflib_ISObjectDomain | fflib_SObjectDomain | Used for trigger handlers and for legacy domains

See [this PR](https://github.com/apex-enterprise-patterns/fflib-apex-common/pull/300) for a detailed overview 
of all the code changes which were part of this change.

The [fflib-apex-common-samplecode](https://github.com/apex-enterprise-patterns/fflib-apex-common-samplecode)
also includes examples on how to structure the change into the 
[new domain](https://github.com/apex-enterprise-patterns/fflib-apex-common-samplecode/blob/master/sfdx-source/apex-common-samplecode/main/classes/domains/Accounts.cls)
and [trigger handler](https://github.com/apex-enterprise-patterns/fflib-apex-common-samplecode/blob/master/sfdx-source/apex-common-samplecode/main/classes/triggerHandlers/OpportunitiesTriggerHandler.cls)

## Known issues and how to resolve them


### _Issue:_ Ambiguous method signature: void setMock(MyDomainClass)
This happens when you try to mock an old domain class which is extended from fflib_SObjectDomain. 
```apex
Application.Domain.setMock(mockAssetsDomain);   // <<== generates Ambiguous method signature: void setMock
```
The issue can be resolved by casting the mock implementation to fflib_ISObjectDomain:
> Application.Domain.setMock( **(fflib_ISObjectDomain)** mockAssetsDomain);  

[See this issue report for more information](https://github.com/apex-enterprise-patterns/fflib-apex-common/issues/347)


### _Issue:_ Illegal assignment from fflib_Domain to fflib_ISObjectDomain
The `newInstance` method signature of the Application Domain Factory (fflib_Application.DomainFactory) has changed into:
>public **fflib_IDomain** newInstance(***);

If you have:
```apex
fflib_ISObjectDomain domain =  Application.Domain.newInstance(sObjIds);	
```
You need to change that into:
> fflib_ISObjectDomain domain = **(fflib_ISObjectDomain)** Application.Domain.newInstance(sObjIds);	

[See this issue report for more information](https://github.com/apex-enterprise-patterns/fflib-apex-common/issues/346)