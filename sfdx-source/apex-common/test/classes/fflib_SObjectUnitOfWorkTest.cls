/**
 * Copyright (c), FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

@IsTest(IsParallel=true)
private with sharing class fflib_SObjectUnitOfWorkTest
{
    // SObjects (in order of dependency) used by UnitOfWork in tests bellow
    private static List<Schema.SObjectType> MY_SOBJECTS =
        new Schema.SObjectType[] {
            Product2.SObjectType,
            PricebookEntry.SObjectType,
            Opportunity.SObjectType,
            OpportunityLineItem.SObjectType };

    @IsTest
    private static void testUnitOfWorkEmail()
    {
        String testRecordName = 'UoW Test Name 1';

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{ 'foobar@test.com' });
        email.setPlainTextBody('See Spot run.');

        MockDML mockDML = new MockDML();
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(MY_SOBJECTS, mockDML);

        uow.m_emailWork = new Mock_SendEmailWork();

        Opportunity opp = new Opportunity();
        opp.Name = testRecordName;
        opp.StageName = 'Open';
        opp.CloseDate = System.today();
        uow.registerNew( opp );

        uow.registerEmail( email );

        uow.registerRelationship( email, opp );

        uow.commitWork();

        // assert that mock email functionality was called
        System.assert(((Mock_SendEmailWork) uow.m_emailWork).doWorkWasCalled);

        System.assertEquals(1, mockDML.recordsForInsert.size());
    }

    @IsTest
    private static void testRegisterNew_ThrowExceptionOnDirtyRecord()
    {
        // GIVEN an existing record
        Opportunity opportunity = new Opportunity(Id = fflib_IDGenerator.generate(Schema.Opportunity.SObjectType));
        fflib_SObjectUnitOfWork unitOfWork = new fflib_SObjectUnitOfWork(MY_SOBJECTS);

        // WHEN we register the existing record as new
        Boolean exceptionThrown = false;
        try
        {
            unitOfWork.registerNew(opportunity);
        }
        catch (Exception e)
        {
            exceptionThrown = true;
            System.assertEquals(
                    'Only new records can be registered as new',
                    e.getMessage(),
                    'Incorrect exception message thrown'
            );
        }

        // THEN it should have thrown an exception
        System.assert(exceptionThrown);
    }

    @IsTest
    private static void testRegisterDirty_ThrowExceptionOnNewRecord()
    {
        // GIVEN an new record
        Opportunity opportunity = new Opportunity();
        fflib_SObjectUnitOfWork unitOfWork = new fflib_SObjectUnitOfWork(MY_SOBJECTS);

        // WHEN we register the existing record as new
        Boolean exceptionThrown = false;
        try
        {
            unitOfWork.registerDirty(opportunity);
        }
        catch (Exception e)
        {
            exceptionThrown = true;
            System.assertEquals(
                    'New records cannot be registered as dirty',
                    e.getMessage(),
                    'Incorrect exception message thrown'
            );
        }

        // THEN it should have thrown an exception
        System.assert(exceptionThrown);
    }

    @IsTest
    private static void testRegisterDeleted()
    {
        // GIVEN - two existing records
        Opportunity opportunity = new Opportunity(Id = fflib_IDGenerator.generate(Schema.Opportunity.SObjectType));
        Product2 product = new Product2(Id = fflib_IDGenerator.generate(Schema.Product2.SObjectType));
        MockDML mockDML = new MockDML();
        fflib_SObjectUnitOfWork unitOfWork = new fflib_SObjectUnitOfWork(MY_SOBJECTS, mockDML);

        // WHEN - we mark the records as deleted
        unitOfWork.registerDeleted(new List<SObject> { opportunity, product });
        unitOfWork.commitWork();

        // THEN - the dmlDelete action should be invoked
        System.assertEquals(new List<SObject> { opportunity, product }, mockDML.recordsForDelete);
    }

    @IsTest
    private static void testRegisterPermanentlyDeleted()
    {
        // GIVEN - two existing records
        Opportunity opportunity = new Opportunity(Id = fflib_IDGenerator.generate(Schema.Opportunity.SObjectType));
        Product2 product = new Product2(Id = fflib_IDGenerator.generate(Schema.Product2.SObjectType));
        MockDML mockDML = new MockDML();
        fflib_SObjectUnitOfWork unitOfWork = new fflib_SObjectUnitOfWork(MY_SOBJECTS, mockDML);

        // WHEN - we mark the records as deleted
        unitOfWork.registerPermanentlyDeleted(new List<SObject> { opportunity, product });
        unitOfWork.commitWork();

        // THEN - the dmlDelete and emptyRecycleBin actions should be invoked
        System.assertEquals(new List<SObject> { opportunity, product }, mockDML.recordsForDelete);
        System.assertEquals(new List<SObject> { opportunity, product }, mockDML.recordsForRecycleBin);
    }

    @IsTest
    private static void testRegisterEmptyRecycleBin()
    {
        // GIVEN - an existing record of the recycle bin
        Opportunity opportunity = new Opportunity(Id = fflib_IDGenerator.generate(Schema.Opportunity.SObjectType));
        MockDML mockDML = new MockDML();
        fflib_SObjectUnitOfWork unitOfWork = new fflib_SObjectUnitOfWork(MY_SOBJECTS, mockDML);

        // WHEN - we empty the record from the recycle bin
        unitOfWork.registerEmptyRecycleBin(new List<Opportunity>{ opportunity });
        unitOfWork.commitWork();

        // THEN - the emptyRecycleBin action should be invoked
        System.assertEquals(1, mockDML.recordsForRecycleBin.size());
    }

    @IsTest
    private static void testAssertForNonEventSObjectType()
    {
        fflib_SObjectUnitOfWork unitOfWork = new fflib_SObjectUnitOfWork(MY_SOBJECTS);
        unitOfWork.assertForNonEventSObjectType('CustomObject__c');
    }

    @IsTest
    private static void testAssertForNonEventSObjectType_ThrowExceptionOnEventObject()
    {
        Boolean exceptionThrown = false;
        fflib_SObjectUnitOfWork unitOfWork = new fflib_SObjectUnitOfWork(MY_SOBJECTS);
        try
        {
            unitOfWork.assertForNonEventSObjectType('PlatformEventObject__e');
        }
        catch (Exception e)
        {
            exceptionThrown = true;
            System.assert(
                    e.getMessage().contains('registerPublishBeforeTransaction'),
                    'Incorrect exception message thrown'
            );
        }

        System.assert(exceptionThrown);
    }

    @IsTest
    private static void testAssertForEventSObjectType()
    {
        fflib_SObjectUnitOfWork unitOfWork = new fflib_SObjectUnitOfWork(MY_SOBJECTS);
        unitOfWork.assertForEventSObjectType('PlatformEventObject__e');
    }

    @IsTest
    private static void testAssertForEventSObjectType_ThrowExceptionOnNonEventObject()
    {
        Boolean exceptionThrown = false;
        fflib_SObjectUnitOfWork unitOfWork = new fflib_SObjectUnitOfWork(MY_SOBJECTS);
        try
        {
            unitOfWork.assertForEventSObjectType('CustomObject__c');
        }
        catch (Exception e)
        {
            exceptionThrown = true;
            System.assert(
                    e.getMessage().contains('invalid for publishing'),
                    'Incorrect exception message thrown'
            );
        }

        System.assert(exceptionThrown);
    }

    @IsTest
    private static void testAssertForSupportedSObjectType_throwExceptionOnUnsupportedType()
    {
        Boolean exceptionThrown = false;
        fflib_SObjectUnitOfWork unitOfWork = new fflib_SObjectUnitOfWork(MY_SOBJECTS);
        try
        {
            unitOfWork.registerNew(new Account());
        }
        catch (Exception e)
        {
            exceptionThrown = true;
            System.assert(
                    e.getMessage().contains('not supported by this unit of work'),
                    'Incorrect exception message thrown'
            );
        }

        System.assert(exceptionThrown);
    }

    /**
     * Create uow with new records and commit
     *
     *	Testing:
     *
     *		- Correct events are fired when commitWork completes successfully
     *
     */
    @IsTest
    private static void testDerivedUnitOfWork_CommitSuccess()
    {
        // Insert Opportunities with UnitOfWork
        MockDML mockDML = new MockDML();
        DerivedUnitOfWork uow = new DerivedUnitOfWork(MY_SOBJECTS, mockDML);
        for(Integer o=0; o<10; o++)
        {
            Opportunity opp = new Opportunity();
            opp.Name = 'UoW Test Name ' + o;
            opp.StageName = 'Open';
            opp.CloseDate = System.today();
            uow.registerNew(new List<SObject>{opp});
            for(Integer i=0; i<o+1; i++)
            {
                Product2 product = new Product2();
                product.Name = opp.Name + ' : Product : ' + i;
                uow.registerNew(new List<SObject>{product});
                PricebookEntry pbe = new PricebookEntry();
                pbe.UnitPrice = 10;
                pbe.IsActive = true;
                pbe.UseStandardPrice = false;
                uow.registerNew(pbe, PricebookEntry.Product2Id, product);
                OpportunityLineItem oppLineItem = new OpportunityLineItem();
                oppLineItem.Quantity = 1;
                oppLineItem.TotalPrice = 10;
                uow.registerRelationship(oppLineItem, OpportunityLineItem.PricebookEntryId, pbe);
                uow.registerNew(oppLineItem, OpportunityLineItem.OpportunityId, opp);
            }
        }
        uow.commitWork();

        // Assert Results
        System.assertEquals(175, mockDML.recordsForInsert.size(), 'Incorrect of new records');

        assertEvents(new List<String> {
                'onCommitWorkStarting'
                , 'onPublishBeforeEventsStarting'
                , 'onPublishBeforeEventsFinished'
                , 'onDMLStarting'
                , 'onDMLFinished'
                , 'onDoWorkStarting'
                , 'onDoWorkFinished'
                , 'onCommitWorkFinishing'
                , 'onPublishAfterSuccessEventsStarting'
                , 'onPublishAfterSuccessEventsFinished'
                , 'onCommitWorkFinished - true'
            }
            , uow.getCommitWorkEventsFired(), new Set<Schema.SObjectType>(MY_SOBJECTS), uow.getRegisteredTypes());
    }

    /**
     * Create uow with data that results in DML Exception
     *
     *	Testing:
     *
     *		- Correct events are fired when commitWork fails during DML processing
     *
     */
    @IsTest
    private static void testDerivedUnitOfWork_CommitDMLFail()
    {
        // Insert Opportunities with UnitOfWork forcing a failure on DML by not setting 'Name' field
        DerivedUnitOfWork uow = new DerivedUnitOfWork(MY_SOBJECTS);
        Opportunity opp = new Opportunity();
        uow.registerNew(new List<SObject>{opp});
        Boolean didFail = false;
        System.DmlException caughtEx = null;

        try {
            uow.commitWork();
        }
        catch (System.DmlException dmlex) {
            didFail = true;
            caughtEx = dmlex;
        }

        // Assert Results
        System.assertEquals(didFail, true, 'didFail');
        System.assert(caughtEx.getMessage().contains('REQUIRED_FIELD_MISSING'), String.format('Exception message was ', new List<String> { caughtEx.getMessage() }));

        assertEvents(new List<String> {
                'onCommitWorkStarting'
                , 'onPublishBeforeEventsStarting'
                , 'onPublishBeforeEventsFinished'
                , 'onDMLStarting'
                , 'onPublishAfterFailureEventsStarting'
                , 'onPublishAfterFailureEventsFinished'
                , 'onCommitWorkFinished - false'
            }
            , uow.getCommitWorkEventsFired(), new Set<Schema.SObjectType>(MY_SOBJECTS), uow.getRegisteredTypes());
    }

    /**
     * Create uow with work that fails
     *
     *	Testing:
     *
     *		- Correct events are fired when commitWork fails during DoWork processing
     *
     */
    @isTest
    private static void testDerivedUnitOfWork_CommitDoWorkFail()
    {
        // Insert Opportunities with UnitOfWork
        MockDML mockDML = new MockDML();
        DerivedUnitOfWork uow = new DerivedUnitOfWork(MY_SOBJECTS, mockDML);
        Opportunity opp = new Opportunity();
        opp.Name = 'UoW Test Name 1';
        opp.StageName = 'Open';
        opp.CloseDate = System.today();
        uow.registerNew(new List<SObject>{opp});

        // register work that will fail during processing
        FailDoingWork fdw = new FailDoingWork();
        uow.registerWork(fdw);

        Boolean didFail = false;
        FailDoingWorkException caughtEx = null;

        try {
            uow.commitWork();
        }
        catch (FailDoingWorkException fdwe) {
            didFail = true;
            caughtEx = fdwe;
        }

        // Assert Results
        System.assertEquals(didFail, true, 'didFail');
        System.assert(caughtEx.getMessage().contains('Work failed.'), String.format('Exception message was ', new List<String> { caughtEx.getMessage() }));

        assertEvents(new List<String> {
                'onCommitWorkStarting'
                , 'onPublishBeforeEventsStarting'
                , 'onPublishBeforeEventsFinished'
                , 'onDMLStarting'
                , 'onDMLFinished'
                , 'onDoWorkStarting'
                , 'onPublishAfterFailureEventsStarting'
                , 'onPublishAfterFailureEventsFinished'
                , 'onCommitWorkFinished - false'
            }
            , uow.getCommitWorkEventsFired(), new Set<Schema.SObjectType>(MY_SOBJECTS), uow.getRegisteredTypes());
    }

    /**
     * Try registering two instances of the same record as dirty. Second register should overwrite first.
     *
     *  Testing:
     *
     *      - Exception is thrown stopping second registration
     */
    @IsTest
    private static void testRegisterDirty_ExpectReplacement()
    {
        final Opportunity insertedOpp = new Opportunity(
                Id = fflib_IDGenerator.generate(Schema.Opportunity.SObjectType),
                Name = 'Original',
                StageName = 'Open',
                CloseDate = System.today());

        Opportunity opp = new Opportunity(Id = insertedOpp.Id, Name = 'Never');
        Opportunity opp2 = new Opportunity(Id = insertedOpp.Id, Name = 'Expected');

        MockDML mockDML = new MockDML();
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(MY_SOBJECTS, mockDML);
        uow.registerDirty(opp);
        uow.registerDirty(opp2);
        uow.commitWork();

        System.assertEquals(1, mockDML.recordsForUpdate.size());
        System.assertEquals('Expected', mockDML.recordsForUpdate.get(0).get(Schema.Opportunity.Name));
    }

    /**
     * Try registering a single field as dirty.
     *
     *  Testing:
     *
     *      - field is updated
     */
    @IsTest
    private static void testRegisterDirty_field() {
        Opportunity opp = new Opportunity(
                Id = fflib_IDGenerator.generate(Schema.Opportunity.SObjectType),
                Name = 'test name',
                StageName = 'Open',
                CloseDate = System.today());

        Opportunity nameUpdate = new Opportunity(Id = opp.Id, Name = 'UpdateName');
        Opportunity amountUpdate = new Opportunity(Id = opp.Id, Amount = 250);
        MockDML mockDML = new MockDML();
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(MY_SOBJECTS, mockDML);
        uow.registerDirty(nameUpdate);
        uow.registerDirty(amountUpdate, new List<SObjectField> { Opportunity.Amount } );
        uow.commitWork();

        System.assertEquals(1, mockDML.recordsForUpdate.size());
        System.assertEquals(nameUpdate.Name, mockDML.recordsForUpdate.get(0).get(Schema.Opportunity.Name));
        System.assertEquals(amountUpdate.Amount, mockDML.recordsForUpdate.get(0).get(Schema.Opportunity.Amount));
    }

    /**
     * Try registering a single field as dirty on multiple records.
     *
     */
    @IsTest
    private static void testRegisterDirtyRecordsWithDirtyFields()
    {
        // GIVEN a list of existing records
        Opportunity opportunityA = new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'test name A',
                StageName = 'Open',
                CloseDate = System.today());
        Opportunity opportunityB = new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'test name B',
                StageName = 'Open',
                CloseDate = System.today());

        MockDML mockDML = new MockDML();
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(MY_SOBJECTS, mockDML);
        uow.registerDirty(new List<Opportunity>{ opportunityA, opportunityB });

        // WHEN we register the records again with different fields updated
        List<Opportunity> recordsWithStageUpdate = new List<Opportunity>
        {
                new Opportunity(Id = opportunityA.Id, StageName = 'Closed'),
                new Opportunity(Id = opportunityB.Id, StageName = 'Closed')
        };
        List<Opportunity> recordsWithAmountUpdate = new List<Opportunity>
        {
                new Opportunity(Id = opportunityA.Id, Amount = 250),
                new Opportunity(Id = opportunityB.Id, Amount = 250)
        };
        uow.registerDirty(recordsWithStageUpdate, new List<SObjectField> { Opportunity.StageName });
        uow.registerDirty(recordsWithAmountUpdate, new List<SObjectField> { Opportunity.Amount });
        uow.commitWork();

        // THEN the records should be registered with both changed values for Amount and StageName
        System.assert(
                new fflib_MatcherDefinitions.SObjectsWith(
                        new List<Map<SObjectField, Object>>{
                                new Map<SObjectField, Object>
                                {
                                     Opportunity.Id => opportunityA.Id,
                                     Opportunity.Amount => 250,
                                     Opportunity.StageName => 'Closed'
                                },
                                new Map<SObjectField, Object>
                                {
                                     Opportunity.Id => opportunityB.Id,
                                     Opportunity.Amount => 250,
                                     Opportunity.StageName => 'Closed'
                                }
                        }
                )
                        .matches(mockDML.recordsForUpdate),
                'Records not registered with the correct values'
        );
    }

    /**
     * Try registering a single field as dirty on multiple records.
     *
     */
    @IsTest
    private static void testRegisterDirtyRecordsWithDirtyFields_failing()
    {
        // GIVEN a list of existing records
        Opportunity opportunityA = new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'test name A',
                StageName = 'Open',
                CloseDate = System.today());
        Opportunity opportunityB = new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'test name B',
                StageName = 'Open',
                CloseDate = System.today());

        MockDML mockDML = new MockDML();
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(MY_SOBJECTS, mockDML);
        uow.registerDirty(new List<Opportunity>{ opportunityA, opportunityB });

        // WHEN we register the records again with different fields updated
        List<Opportunity> recordsWithStageUpdate = new List<Opportunity>
        {
                new Opportunity(Id = opportunityA.Id, StageName = 'Closed'),
                new Opportunity(Id = opportunityB.Id, StageName = 'Closed')
        };
        List<Opportunity> recordsWithAmountUpdate = new List<Opportunity>
        {
                new Opportunity(Id = opportunityA.Id, Amount = 250),
                new Opportunity(Id = opportunityB.Id, Amount = 250)
        };
        uow.registerDirty(recordsWithStageUpdate, new List<SObjectField> { Opportunity.StageName });
        uow.registerDirty(recordsWithAmountUpdate, new List<SObjectField> { Opportunity.Amount });
        uow.registerDirty( // Register again the original record, should overwrite the one with the dirty fields
                new Opportunity(
                Id = opportunityB.Id,
                Name = 'test name B',
                StageName = 'Open',
                CloseDate = System.today())
        ); 
        uow.commitWork();

        // THEN only the first record should be registered with both changed values for Amount and StageName and the second should be the original
        System.assert(
                !new fflib_MatcherDefinitions.SObjectsWith(
                        new List<Map<SObjectField, Object>>{
                                new Map<SObjectField, Object>
                                {
                                     Opportunity.Id => opportunityA.Id,
                                     Opportunity.Amount => 250,
                                     Opportunity.StageName => 'Closed'
                                },
                                new Map<SObjectField, Object>
                                {
                                     Opportunity.Id => opportunityB.Id,
                                     Opportunity.Amount => 250,
                                     Opportunity.StageName => 'Closed'
                                }
                        }
                )
                        .matches(mockDML.recordsForUpdate),
                'Not all records should not be registered with the dirty values'
        );
        System.assert(
                new fflib_MatcherDefinitions.SObjectsWith(
                        new List<Map<SObjectField, Object>>{
                                new Map<SObjectField, Object>
                                {
                                     Opportunity.Id => opportunityA.Id,
                                     Opportunity.Amount => 250,
                                     Opportunity.StageName => 'Closed'
                                },
                                new Map<SObjectField, Object>
                                {
                                     Opportunity.Id => opportunityB.Id,
                                     Opportunity.StageName => 'Open'
                                }
                        }
                )
                        .matches(mockDML.recordsForUpdate),
                'The second record should be registered with the original values'
        );
    }

    @IsTest
    private static void testRegisterUpsert() {
        Opportunity existingOpp = new Opportunity(
                Id = fflib_IDGenerator.generate(Schema.Opportunity.SObjectType),
                Name = 'Existing Opportunity',
                StageName = 'Closed',
                CloseDate = System.today());

        Opportunity newOpportunity = new Opportunity(Name = 'New Opportunity', StageName = 'Closed', CloseDate = System.today());

        Test.startTest();
        MockDML mockDML = new MockDML();
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(MY_SOBJECTS, mockDML);
        uow.registerUpsert(new List<Opportunity>{existingOpp, newOpportunity});
        uow.commitWork();
        Test.stopTest();

        System.assertEquals(1, mockDML.recordsForUpdate.size());
        System.assertEquals(1, mockDML.recordsForInsert.size());
    }

    /**
     * Assert that actual events exactly match expected events (size, order and name)
     * and types match expected types
     */
    private static void assertEvents(List<String> expectedEvents, List<String> actualEvents, Set<Schema.SObjectType> expectedTypes, Set<Schema.SObjectType> actualTypes)
    {
        // assert that events match
        System.assertEquals(expectedEvents.size(), actualEvents.size(), 'events size');
        for (Integer i = 0; i < expectedEvents.size(); i++)
        {
            System.assertEquals(expectedEvents[i], actualEvents[i], String.format('Event {0} was not fired in order expected.', new List<String> { expectedEvents[i] }));
        }

        // assert that types match
        System.assertEquals(expectedTypes.size(), actualTypes.size(), 'types size');
        for (Schema.SObjectType sObjectType :expectedTypes)
        {
            System.assertEquals(true, actualTypes.contains(sObjectType), String.format('Type {0} was not registered.', new List<String> { sObjectType.getDescribe().getName() }));
        }
    }

    /**
     * DoWork implementation that throws exception during processing
     */
    private class FailDoingWork implements fflib_SObjectUnitOfWork.IDoWork
    {
        public void doWork()
        {
            throw new FailDoingWorkException('Work failed.');
        }
    }

    /**
     * Derived unit of work that tracks event notifications and handle registration of type
     */
    private class DerivedUnitOfWork extends fflib_SObjectUnitOfWork
    {
        private List<String> m_commitWorkEventsFired = new List<String>();
        private Set<Schema.SObjectType> m_registeredTypes = new Set<Schema.SObjectType>();

        public List<String> getCommitWorkEventsFired()
        {
            return m_commitWorkEventsFired.clone();
        }

        public Set<Schema.SObjectType> getRegisteredTypes()
        {
            return m_registeredTypes.clone();
        }

        public DerivedUnitOfWork(List<Schema.SObjectType> sObjectTypes)
        {
            super(sObjectTypes);
        }

        public DerivedUnitOfWork(List<Schema.SObjectType> sObjectTypes, IDML dml)
        {
            super(sObjectTypes, dml);
        }

        private void addEvent(String event)
        {
            // events should only be fired one time
            // ensure that this event has not been fired already
            for (String eventName :m_commitWorkEventsFired)
            {
                if (event == eventName)
                {
                    throw new DerivedUnitOfWorkException(String.format('Event {0} has already been fired.', new List<String> { event }));
                }
            }
            m_commitWorkEventsFired.add(event);
        }

        public override void onRegisterType(Schema.SObjectType sObjectType)
        {
            if (m_registeredTypes.contains(sObjectType))
            {
                throw new DerivedUnitOfWorkException(String.format('Type {0} has already been registered.', new List<String> { sObjectType.getDescribe().getName() }));
            }
            m_registeredTypes.add(sObjectType);
        }

        public override void onCommitWorkStarting()
        {
            addEvent('onCommitWorkStarting');
        }

        public override void onPublishBeforeEventsStarting()
        {
            addEvent('onPublishBeforeEventsStarting');
        }

        public override void onPublishBeforeEventsFinished()
        {
            addEvent('onPublishBeforeEventsFinished');
        }

        public override void onDMLStarting()
        {
            addEvent('onDMLStarting');
        }

        public override void onDMLFinished()
        {
            addEvent('onDMLFinished');
        }

        public override void onDoWorkStarting()
        {
            addEvent('onDoWorkStarting');
        }

        public override void onDoWorkFinished()
        {
            addEvent('onDoWorkFinished');
        }

        public override void onCommitWorkFinishing()
        {
            addEvent('onCommitWorkFinishing');
        }

        public override void onPublishAfterSuccessEventsStarting()
        {
            addEvent('onPublishAfterSuccessEventsStarting');
        }

        public override void onPublishAfterSuccessEventsFinished()
        {
            addEvent('onPublishAfterSuccessEventsFinished');
        }

        public override void onPublishAfterFailureEventsStarting()
        {
            addEvent('onPublishAfterFailureEventsStarting');
        }

        public override void onPublishAfterFailureEventsFinished()
        {
            addEvent('onPublishAfterFailureEventsFinished');
        }

        public override void onCommitWorkFinished(Boolean wasSuccessful)
        {
            addEvent('onCommitWorkFinished - ' + wasSuccessful);
        }
    }

    /**
     * Mock implementation of fflib_SObjectUnitOfWork.SendEmailWork
     **/
    private class Mock_SendEmailWork implements fflib_SObjectUnitOfWork.IEmailWork
    {
        public Mock_SendEmailWork()
        {
        }

        public void registerEmail(Messaging.Email email)
        {
        }

        public void doWork()
        {
            doWorkWasCalled = true;
            // The code in the fflib_SObjectUnitOfWork class
            // causes unit test failures in Orgs that do not
            // have email enabled.
        }

        private Boolean doWorkWasCalled = false;
    }

    private class MockDML implements fflib_SObjectUnitOfWork.IDML
    {
        public List<SObject> recordsForInsert = new List<SObject>();
        public List<SObject> recordsForUpdate = new List<SObject>();
        public List<SObject> recordsForDelete = new List<SObject>();
        public List<SObject> recordsForRecycleBin = new List<SObject>();
        public List<SObject> recordsForEventPublish = new List<SObject>();

        public void dmlInsert(List<SObject> objList)
        {
            this.recordsForInsert.addAll(objList);
        }

        public void dmlUpdate(List<SObject> objList)
        {
            this.recordsForUpdate.addAll(objList);
        }

        public void dmlDelete(List<SObject> objList)
        {
            this.recordsForDelete.addAll(objList);
        }

        public void eventPublish(List<SObject> objList)
        {
            this.recordsForEventPublish.addAll(objList);
        }

        public void emptyRecycleBin(List<SObject> objList)
        {
            this.recordsForRecycleBin.addAll(objList);
        }
    }

    public class DerivedUnitOfWorkException extends Exception {}
    public class FailDoingWorkException extends Exception {}
}
