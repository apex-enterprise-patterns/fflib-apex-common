FinancialForce Common Apex Lib
==============================

**[Deploy to Salesforce](https://githubsfdeploy.herokuapp.com/app/githubdeploy/financialforcedev/fflib-apex-common)**

See here for [MavensMate Templates](http://andyinthecloud.com/2014/05/23/mavensmate-templates-and-apex-enterprise-patterns/)

Expirimental CRUD and FLS Support
=================================

**WARNING:** This branch is expirimental and should not be used in production without careful consideration. 

**Salesforce Security** review has recently [started requiring FLS checking to be implemented in Apex code](https://developer.salesforce.com/forums/?id=906F00000009JFXIA2) as per the documents [here](https://developer.salesforce.com/page/Enforcing_CRUD_and_FLS) and [here](https://developer.salesforce.com/page/Testing_CRUD_and_FLS_Enforcement). Distributing these kind of manual CRUD and FLS checks accross a large code base is not appealing and fragile! So this branch of the **Apex Enterprise Patterns** is exploring a more generic implementation that is handled seamlessly. 

Implementing FLS checking generically in Apex code is hard on the Force.com platform currently! This branch of the Apex Enterprise Patterns is attempting to accomplish it by combining the Unit of Work, Domain and Selector layer patterns. The responsibility of enforcing, create, update and delete security is distributed as follows. 

- The **Unit Of Work** commit code checks **create** security at object and field level prior to executing the insert DML operation. 
- The **Domain layer** checks **update** security at object and field level, since during the Apex Trigger handling, it has access to existing records and field values (via Trigger.old) it can determine dynamically which fields have been changed. This is only performed if it is able to determine that there is an outer Unit of Work commit in progress. Note that historically the Domain layer has always been checking create, update and delete object security.
- The **Selector layer** has been updated in the main branch to utilise the amazing fflib_QueryFactory, which also now supports **read** security at the object and field level. This can be enabled by passing the approprite parameter to the Selector constructor or by calling the approprite method on the QueryFactory class.

This class diagram shows how the various pattern base classes interact with the **fflib_SecurityUtils** and **fflib_QueryFactory** classes described in more detail in this [blog](http://andyinthecloud.com/2014/06/28/financialforce-apex-common-updates/).

![alt tag](https://andrewfawcett.files.wordpress.com/2014/06/flspocclassdiagram.png)

**Current Result...**

The above allows the [existing sample application](https://github.com/financialforcedev/fflib-apex-common-samplecode) to support CRUD and FLS checking without any code changes! Which is one of the aims of this experiment, should Salesforce add **platform support** for this in the future we want to minimise changes to the framework code only.

So far so good.... but both the Unit of Work and Domain layer require knowledge of which fields have been populated on the SObject passed to them. This is not as easy as you might think, see [fflib_SObjectDomain.resolvePopulatedFields](https://github.com/financialforcedev/fflib-apex-common/blob/fls-support-experiment/fflib/src/classes/fflib_SObjectDomain.cls#L258) method. I'll be going into the pros and cons of this experiment in a blog post coming soon!

This Library
============

Is derived from the **Dreamforce 2012** presentation on [Apex Enterprise Patterns](https://github.com/financialforcedev/df12-apex-enterprise-patterns) and progresses the patterns further with a more general ongoing home for them. While also leading up to an updated presentation given at **Dreamforce 2013**. It also adds some form of namespace qualification from the previous version. So that classes are grouped together more easily in the IDE's and packages. Below you can find comprehensive articles and videos on the use of these patterns. There is also a **working sample application** illustrating the patterns [here](https://github.com/financialforcedev/fflib-apex-common-samplecode).

![Alt text](/images/patternsturning.png "Optional title")

Application Enterprise Patterns on Force.com
============================================

Design patterns are an invaluable tool for developers and architects looking to build enterprise solutions. Here are presented some tried and tested enterprise application engineering patterns that have been used in other platforms and languages. We will discuss and illustrate how patterns such as Data Mapper, Service Layer, Unit of Work and of course Model View Controller can be applied to Force.com. Applying these patterns can help manage governed resources (such as DML) better, encourage better separation-of-concerns in your logic and enforce Force.com coding best practices.

Dreamforce Session and Slides
-----------------------------

View slides for the  **Dreamforce 2013** session [here](https://docs.google.com/file/d/0B6brfGow3cD8RVVYc1dCX2s0S1E/edit) and a video recording of the session [here](http://www.youtube.com/watch?v=qlq46AEAlLI).

Latest Article Series on Developer Force.com
--------------------------------------------

I'm proud to have been given the opportunity to run a more detailed look at these patterns on developer.force.com. 

- [Apex Enterprise Patterns - Separation of Concerns](http://wiki.developerforce.com/page/Apex_Enterprise_Patterns_-_Separation_of_Concerns)
- [Apex Enterprise Patterns - Service Layer](http://wiki.developerforce.com/page/Apex_Enterprise_Patterns_-_Service_Layer)
- [Apex Enterprise Patterns - Domain Layer](http://wiki.developerforce.com/page/Apex_Enterprise_Patterns_-_Domain_Layer)
- [Apex Enterprise Patterns - Selector Layer](https://github.com/financialforcedev/df12-apex-enterprise-patterns#data-mapper-selector)

**Other Related Blogs**

- [Unit Testing with the Domain Layer](http://andyinthecloud.com/2014/03/23/unit-testing-with-the-domain-layer/)
- [MavensMate Templates](http://andyinthecloud.com/2014/05/23/mavensmate-templates-and-apex-enterprise-patterns/)

