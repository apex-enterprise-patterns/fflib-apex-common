/*
* FinancialForce.com, inc. claims copyright in this software, its screen
* display designs and supporting documentation. FinancialForce and
* FinancialForce.com are trademarks of FinancialForce.com, inc. Any
* unauthorized use, copying or sale of the above may constitute an
* infringement of copyright and may result in criminal or other legal
* proceedings.
*
* Copyright (c) 2013-2014 FinancialForce.com, inc. All rights reserved.
*/

/**
 * @see fflib_SObjectUnitOfWork
 **/
public interface fflib_ISObjectUnitOfWork
{
    /**
     * Register a newly created SObject instance to be inserted when commitWork is called
     *
     * @param record A newly created SObject instance to be inserted during commitWork
     **/
    void registerNew(SObject record);
    /**
     * Register a list of newly created SObject instances to be inserted when commitWork is called
     *
     * @param records A list of newly created SObject instances to be inserted during commitWork
     **/
    void registerNew(List<SObject> records);
    /**
     * Register a newly created SObject instance to be inserted when commitWork is called,
     *   you may also provide a reference to the parent record instance (should also be registered as new separatly)
     *
     * @param record A newly created SObject instance to be inserted during commitWork
     * @param relatedToParentField A SObjectField reference to the child field that associates the child record with its parent
     * @param relatedToParentRecord A SObject instance of the parent record (should also be registered as new separatly)
     **/
    void registerNew(SObject record, Schema.sObjectField relatedToParentField, SObject relatedToParentRecord);
    /**
     * Register a relationship between two records that have yet to be inserted to the database. This information will be
     *  used during the commitWork phase to make the references only when related records have been inserted to the database.
     *
     * @param record An existing or newly created record
     * @param relatedToField A SObjectField referene to the lookup field that relates the two records together
     * @param relatedTo A SOBject instance (yet to be commited to the database)
     */
    void registerRelationship(SObject record, Schema.sObjectField relatedToField, SObject relatedTo);
    /**
     * Registers a relationship between a record and a Messaging.Email where the record has yet to be inserted
     *  to the database.  This information will be
     *  used during the commitWork phase to make the references only when related records have been inserted to the database.
     *
     * @param a single email message instance
     * @param relatedTo A SOBject instance (yet to be commited to the database)
     */
    void registerRelationship(Messaging.SingleEmailMessage email, SObject relatedTo);
    /**
     * Registers a relationship between a record and a lookup value using an external ID field and a provided value. This
     * information will be used during the commitWork phase to make the lookup reference requested when inserted to the database.
     *
     * @param record An existing or newly created record
     * @param relatedToField A SObjectField reference to the lookup field that relates the two records together
     * @param externalIdField A SObjectField reference to a field on the target SObject that is marked as isExternalId
     * @param externalId A Object representing the targetted value of the externalIdField in said lookup
     *
     * Usage Example: uow.registerRelationship(recordSObject, record_sobject__c.relationship_field__c, lookup_sobject__c.external_id__c, 'abc123');
     *
     * Wraps putSObject, creating a new instance of the lookup sobject using the external id field and value.
     */
     void registerRelationship(SObject record, Schema.sObjectField relatedToField, Schema.sObjectField externalIdField, Object externalId);
    /**
     * Register an existing record to be updated during the commitWork method
     *
     * @param record An existing record
     **/
    void registerDirty(SObject record);
    /**
     * Register specific fields on record to be updated when work is commited
     *
     * If the record has previously been registered as dirty, the dirty fields on the record in this call will overwrite
     * the values of the previously registered dirty record
     *
     * @param record An existing record
     * @param dirtyFields The fields to update if record is already registered
     **/
    void registerDirty(SObject record, List<SObjectField> dirtyFields);
    /**
     * Register an existing record to be updated when commitWork is called,
     *   you may also provide a reference to the parent record instance (should also be registered as new separatly)
     *
     * @param record A newly created SObject instance to be inserted during commitWork
     * @param relatedToParentField A SObjectField reference to the child field that associates the child record with its parent
     * @param relatedToParentRecord A SObject instance of the parent record (should also be registered as new separatly)
     **/
    void registerDirty(SObject record, Schema.sObjectField relatedToParentField, SObject relatedToParentRecord);
    /**
     * Register a list of existing records to be updated during the commitWork method
     *
     * @param records A list of existing records
     **/
    void registerDirty(List<SObject> records);
    /**
     * Register a new or existing record to be inserted or updated during the commitWork method
     *
     * @param record An new or existing record
     **/
    void registerUpsert(SObject record);
    /**
     * Register a list of mix of new and existing records to be upserted during the commitWork method
     *
     * @param records A list of mix of existing and new records
     **/
    void registerUpsert(List<SObject> records);
    /**
     * Register an existing record to be deleted during the commitWork method
     *
     * @param record An existing record
     **/
    void registerDeleted(SObject record);
    /**
     * Register a list of existing records to be deleted during the commitWork method
     *
     * @param records A list of existing records
     **/
    void registerDeleted(List<SObject> records);
    /**
     * Register a newly created SObject (Platform Event) instance to be published when commitWork is called
     *
     * @param record A newly created SObject (Platform Event) instance to be inserted during commitWork
     **/
    void registerPublishBeforeTransaction(SObject record);
    /**
     * Register a list of newly created SObject (Platform Event) instance to be published when commitWork is called
     *
     * @param records A list of existing records
     **/
    void registerPublishBeforeTransaction(List<SObject> records);
    /**
     * Register a newly created SObject (Platform Event) instance to be published when commitWork has successfully
     * completed
     *
     * @param record A newly created SObject (Platform Event) instance to be inserted during commitWork
     **/
    void registerPublishAfterSuccessTransaction(SObject record);
    /**
     * Register a list of newly created SObject (Platform Event) instance to be published when commitWork has successfully
     * completed
     *
     * @param records A list of existing records
     **/
    void registerPublishAfterSuccessTransaction(List<SObject> records);
    /**
     * Register a newly created SObject (Platform Event) instance to be published when commitWork has caused an error
     *
     * @param record A newly created SObject (Platform Event) instance to be inserted during commitWork
     **/
    void registerPublishAfterFailureTransaction(SObject record);
    /**
     * Register a list of newly created SObject (Platform Event) instance to be published when commitWork has caused an
     * error
     *
     * @param records A list of existing records
     **/
    void registerPublishAfterFailureTransaction(List<SObject> records);
    /**
     * Takes all the work that has been registered with the UnitOfWork and commits it to the database
     **/
    void commitWork();
    /**
     * Register a generic peace of work to be invoked during the commitWork phase
     *
     * @param work Work to be registered
     **/
    void registerWork(fflib_SObjectUnitOfWork.IDoWork work);
    /**
     * Registers the given email to be sent during the commitWork
     *
     * @param email Email to be sent
     **/
    void registerEmail(Messaging.Email email);
}