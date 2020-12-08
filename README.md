FFLib Apex Common 2.0
=================

[![Build Status](https://travis-ci.org/apex-enterprise-patterns/fflib-apex-common.svg)](https://travis-ci.org/apex-enterprise-patterns/fflib-apex-common) 

**Dependencies:** Must deploy [ApexMocks](https://github.com/apex-enterprise-patterns/fflib-apex-mocks) 
and [Force-DI](https://github.com/apex-enterprise-patterns/force-di) before deploying this library

<a href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>

## What's new in v2.0
This fork of fflib-apex-commons has some major changes to its architecture, while maintaining backwards compatible.

- [Event driven architecture](docs/events/README.md) <br/>
  Ability to publish custom events in Apex. 
  Listeners will be invoked in realtime or can run as Queueable Apex.
  This feature will also replace the existing trigger handler (fflib_SObjectDomain).
- [Domain architecture](docs/domains/README.md) <br/>
  Domain can now be constructed with generic Objects and not limited to SObjects.
  This allows the creation of compound domains, DTO's and more.
  Major improvement is the introduction of primitive domains.
- [Application factories redesigned and can use Force-DI](docs/application/README.md) <br/>
  Redesign of interface structure of the Application class factories, in order to easily replace their implementation.
  Now force-di is fully integrated into the application 
  while also maintaining backwards compatibility with the classic way of working with Maps.
  The force-di integration is just another implementation of the factories.
  
  
## Road Map for fflib-apex-common v2.0

- **Criteria class** <br/> 
  The criteria class can be used to have one common selector method for both selector and domain classes. 
  Where the selector is querying its data for a source and the domain queries the data in memory from its own objects.
  
- **Selector Architecture** <br/>
  The selector will be redesigned to that its not coupled to a database. 
  In this new architecture the selector will retrieve data from wherever it is stored.
  It should not be the concern of a service class calling the selector to know where the data is coming from.  
  This new architecture should allow for getting the data from; 
    - In memory
      from previous queries (Identity Map Design Pattern)  
    - A Platform Cache
    - The Database
    - External WebService
    
  The queries should also be able to roll-over. 
  Like when the requested record is not in memory, 
  then the next selector in line should be called as the record might be in the Platform cache. 
  If it is still not found the record can be queried from a database.
  
- **Queued Actions** <br/>
  A replacement for the scheduled actions of process builder flows,
  as it is difficult to update flows with scheduled actions.
  This feature contains a queue object with actions and scheduled jobs 
  to execute the actions when they are scheduled. 
  Events are used to tell the application that the given action should be performed.

  

Updates
=======

- **December 2020**, **IMPORTANT CHANGE**, the repository had become dependent on force-di. If that is not desired, just exclude the folder `sfdx-source/apex-common/classes/force-di`. 
- **April 2020**, **IMPORTANT CHANGE**, the directory format of this project repo was converted to [Salesforce DX Source Format](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_source_file_format.htm).  While the GIT commit history was maintained, it is not visible on GitHub.  If you need to see the history, either clone the repo and execute `git log --follow` from the command line or refer to this [tag](https://github.com/apex-enterprise-patterns/fflib-apex-common/tree/metadata-format-prior-to-dx-source-format-conversion) of the codebase prior to conversion.
- **September 2014**, **IMPORTANT CHANGE**, changes applied to support Dreamforce 2014 advanced presentation, library now provides Application factories for major layers and support for ApexMocks. More details to follow! As a result [ApexMocks](https://github.com/apex-enterprise-patterns/fflib-apex-mocks) must be deployed to the org before deploying this library. The sample application [here](https://github.com/apex-enterprise-patterns/fflib-apex-common-samplecode) has also been updated to demonstrate the new features!
- **July 2014**, **IMPORTANT CHANGE**, prior **23rd July 2014**, both the ``fflib_SObjectDomain.onValidate()`` and ``fflib_SObjectDomain.onValidate(Map<Id, SObject> existingRecords)`` methods where called during an on **after update** trigger event. From this point on the ``onValidate()`` method will only be called during on **after insert**. If you still require the orignal behaviour add the line ``Configuration.enableOldOnUpdateValidateBehaviour();`` into your constructor.
- **June 2014**, New classes providing utilities to support security and dynamic queries, in addition to improvements to existing Apex Enterprise Pattern base classes. Read more [here](http://andyinthecloud.com/2014/06/28/financialforce-apex-common-updates/).
- **June 2014**, Experimental [branch](https://github.com/apex-enterprise-patterns/fflib-apex-common/tree/fls-support-experiment) supporting automated FLS checking, see [README](https://github.com/apex-enterprise-patterns/fflib-apex-common/tree/fls-support-experiment#expirimental-crud-and-fls-support) for more details.

This Library
============

Is derived from the **Dreamforce 2012** presentation on [Apex Enterprise Patterns](https://github.com/financialforcedev/df12-apex-enterprise-patterns) and progresses the patterns further with a more general ongoing home for them. It also adds some form of namespace qualification from the previous version. So that classes are grouped together more easily in the IDE's and packages. Below you can find comprehensive articles and videos on the use of these patterns. There is also a **working sample application** illustrating the patterns [here](https://github.com/apex-enterprise-patterns/fflib-apex-common-samplecode).

![Alt text](/images/patternsturning.png "Optional title")

Application Enterprise Patterns on Force.com
============================================

Design patterns are an invaluable tool for developers and architects looking to build enterprise solutions. Here are presented some tried and tested enterprise application engineering patterns that have been used in other platforms and languages. We will discuss and illustrate how patterns such as Data Mapper, Service Layer, Unit of Work and of course Model View Controller can be applied to Force.com. Applying these patterns can help manage governed resources (such as DML) better, encourage better separation-of-concerns in your logic and enforce Force.com coding best practices.

Dreamforce Session and Slides
-----------------------------

- View slides for the **Dreamforce 2013** session [here](https://docs.google.com/file/d/0B6brfGow3cD8RVVYc1dCX2s0S1E/edit) 
- Video recording of the **Dreamforce 2013** session [here](http://www.youtube.com/watch?v=qlq46AEAlLI).
- Video recording of the **Advanced Apex Enterprise Dreamforce 2014** session [here](http://dreamforce.vidyard.com/watch/7QtP2628KmtXfmiwI-7B1w%20).
- View slides for the **Dreamforce 2015** session [here](http://www.slideshare.net/andyinthecloud/building-strong-foundations-apex-enterprise-patterns)

Documentation
-------------

- [Apex Sharing and applying to Apex Enterprise Patterns](http://andyinthecloud.com/2016/01/10/apex-sharing-and-applying-to-apex-enterprise-patterns/)
- [Tips for Migrating to Apex Enterprise Patterns](http://andyinthecloud.com/2015/09/30/tips-for-migrating-to-apex-enterprise-patterns/)
- [Great Contributions to Apex Enterprise Patterns](http://andyinthecloud.com/2015/07/25/great-contributions-to-apex-enterprise-patterns/)
- [Unit Testing, Apex Enterprise Patterns and ApexMocks – Part 1](http://andyinthecloud.com/2015/03/22/unit-testing-with-apex-enterprise-patterns-and-apexmocks-part-1/)
- [Unit Testing, Apex Enterprise Patterns and ApexMocks – Part 2](http://andyinthecloud.com/2015/03/29/unit-testing-apex-enterprise-patterns-and-apexmocks-part-2/)
- [Apex Enterprise Patterns - Separation of Concerns](http://wiki.developerforce.com/page/Apex_Enterprise_Patterns_-_Separation_of_Concerns)
- [Apex Enterprise Patterns - Service Layer](http://wiki.developerforce.com/page/Apex_Enterprise_Patterns_-_Service_Layer)
- [Apex Enterprise Patterns - Domain Layer](http://wiki.developerforce.com/page/Apex_Enterprise_Patterns_-_Domain_Layer)
- [Apex Enterprise Patterns - Selector Layer](https://github.com/financialforcedev/df12-apex-enterprise-patterns#data-mapper-selector)

**Other Related Blogs**

- [Preview of Advanced Apex Patterns Session (Application Factory and ApexMocks Features)](http://andyinthecloud.com/2014/08/26/preview-of-advanced-apex-enterprise-patterns-session/)
- [Unit Testing with the Domain Layer](http://andyinthecloud.com/2014/03/23/unit-testing-with-the-domain-layer/)
- [MavensMate Templates](http://andyinthecloud.com/2014/05/23/mavensmate-templates-and-apex-enterprise-patterns/)
- [FinancialForce Apex Common Updates](http://andyinthecloud.com/2014/06/28/financialforce-apex-common-updates/)

