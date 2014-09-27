FinancialForce Apex Common
==========================

**Dependencies:** Must deploy [ApexMocks](https://github.com/financialforcedev/fflib-apex-mocks) before deploying this library

<a href="https://githubsfdeploy.herokuapp.com?owner=financialforcedev&repo=fflib-apex-common">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>

See here for [MavensMate Templates](http://andyinthecloud.com/2014/05/23/mavensmate-templates-and-apex-enterprise-patterns/)

Updates
=======

- **September 2014**, **IMPORTANT CHANGE**, changes applied to support Dreamforce 2014 advanced presentation, library now provides Application factories for major layers and support for ApexMocks. More details to follow! As a result [ApexMocks](https://github.com/financialforcedev/fflib-apex-mocks) must be deployed to the org before deploying this library. The sample application [here](https://github.com/financialforcedev/fflib-apex-common-samplecode) has also been updated to demonstrate the new features!
- **July 2014**, **IMPORTANT CHANGE**, prior **23rd July 2014**, both the ``fflib_SObjectDomain.onValidate()`` and ``fflib_SObjectDomain.onValidate(Map<Id, SObject> existingRecords)`` methods where called during an on **after update** trigger event. From this point on the ``onValidate()`` method will only be called during on **after insert**. If you still require the orignal behaviour add the line ``Configuration.enableOldOnUpdateValidateBehaviour();`` into your constructor.
- **June 2014**, New classes providing utilities to support security and dynamic queries, in addition to improvements to existing Apex Enterprise Pattern base classes. Read more [here](http://andyinthecloud.com/2014/06/28/financialforce-apex-common-updates/).
- **June 2014**, Experimental [branch](https://github.com/financialforcedev/fflib-apex-common/tree/fls-support-experiment) supporting automated FLS checking, see [README](https://github.com/financialforcedev/fflib-apex-common/tree/fls-support-experiment#expirimental-crud-and-fls-support) for more details.

This Library
============

Is derived from the **Dreamforce 2012** presentation on [Apex Enterprise Patterns](https://github.com/financialforcedev/df12-apex-enterprise-patterns) and progresses the patterns further with a more general ongoing home for them. It also adds some form of namespace qualification from the previous version. So that classes are grouped together more easily in the IDE's and packages. Below you can find comprehensive articles and videos on the use of these patterns. There is also a **working sample application** illustrating the patterns [here](https://github.com/financialforcedev/fflib-apex-common-samplecode).

![Alt text](/images/patternsturning.png "Optional title")

Application Enterprise Patterns on Force.com
============================================

Design patterns are an invaluable tool for developers and architects looking to build enterprise solutions. Here are presented some tried and tested enterprise application engineering patterns that have been used in other platforms and languages. We will discuss and illustrate how patterns such as Data Mapper, Service Layer, Unit of Work and of course Model View Controller can be applied to Force.com. Applying these patterns can help manage governed resources (such as DML) better, encourage better separation-of-concerns in your logic and enforce Force.com coding best practices.

Dreamforce Session and Slides
-----------------------------

View slides for the  **Dreamforce 2013** session [here](https://docs.google.com/file/d/0B6brfGow3cD8RVVYc1dCX2s0S1E/edit) and a video recording of the session [here](http://www.youtube.com/watch?v=qlq46AEAlLI).

Documentation
-------------

I'm proud to have been given the opportunity to run a more detailed look at these patterns on developer.force.com. 

- [Apex Enterprise Patterns - Separation of Concerns](http://wiki.developerforce.com/page/Apex_Enterprise_Patterns_-_Separation_of_Concerns)
- [Apex Enterprise Patterns - Service Layer](http://wiki.developerforce.com/page/Apex_Enterprise_Patterns_-_Service_Layer)
- [Apex Enterprise Patterns - Domain Layer](http://wiki.developerforce.com/page/Apex_Enterprise_Patterns_-_Domain_Layer)
- [Apex Enterprise Patterns - Selector Layer](https://github.com/financialforcedev/df12-apex-enterprise-patterns#data-mapper-selector)

**Other Related Blogs**

- [Preview of Advanced Apex Patterns Session (Application Factory and ApexMocks Features)](http://andyinthecloud.com/2014/08/26/preview-of-advanced-apex-enterprise-patterns-session/)
- [Unit Testing with the Domain Layer](http://andyinthecloud.com/2014/03/23/unit-testing-with-the-domain-layer/)
- [MavensMate Templates](http://andyinthecloud.com/2014/05/23/mavensmate-templates-and-apex-enterprise-patterns/)
- [FinancialForce Apex Common Updates](http://andyinthecloud.com/2014/06/28/financialforce-apex-common-updates/)

