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
     *   you may also provide a reference to the parent record instance (should also be registered as new separately)
     *
     * @param record A newly created SObject instance to be inserted during commitWork
     * @param relatedToParentField A SObjectField reference to the child field that associates the child record with its parent
     * @param relatedToParentRecord A SObject instance of the parent record (should also be registered as new separately)
     **/
    void registerNew(SObject record, Schema.SObjectField relatedToParentField, SObject relatedToParentRecord);
    /**
     * Register a relationship between two records that have yet to be inserted to the database. This information will be
     *  used during the commitWork phase to make the references only when related records have been inserted to the database.
     *
     * @param record An existing or newly created record
     * @param relatedToField A SObjectField reference to the lookup field that relates the two records together
     * @param relatedTo A SObject instance (yet to be committed to the database)
     */
    void registerRelationship(SObject record, Schema.SObjectField relatedToField, SObject relatedTo);
    /**
     * Registers a relationship between a record and a Messaging.Email where the record has yet to be inserted
     *  to the database.  This information will be
     *  used during the commitWork phase to make the references only when related records have been inserted to the database.
     *
     * @param email a single email message instance
     * @param relatedTo A SObject instance (yet to be committed to the database)
     */
    void registerRelationship(Messaging.SingleEmailMessage email, SObject relatedTo);
    /**
     * Registers a relationship between a record and a lookup value using an external ID field and a provided value. This
     * information will be used during the commitWork phase to make the lookup reference requested when inserted to the database.
     *
     * @param record An existing or newly created record
     * @param relatedToField A SObjectField reference to the lookup field that relates the two records together
     * @param externalIdField A SObjectField reference to a field on the target SObject that is marked as isExternalId
     * @param externalId A Object representing the targeted value of the externalIdField in said lookup
     *
     * Usage Example: uow.registerRelationship(recordSObject, record_sobject__c.relationship_field__c, lookup_sobject__c.external_id__c, 'abc123');
     *
     * Wraps putSObject, creating a new instance of the lookup sobject using the external id field and value.
     */
     void registerRelationship(SObject record, Schema.SObjectField relatedToField, Schema.SObjectField externalIdField, Object externalId);
    /**
     * Register an existing record to be updated during the commitWork method
     *
     * @param record An existing record
     **/
    void registerDirty(SObject record);
    /**
     * Register specific fields on records to be updated when work is committed
     *
     * If the records are previously registered as dirty, the dirty fields on the records in this call will overwrite
     * the values of the previously registered dirty records
     *
     * @param records A list of existing records
     * @param dirtyFields The fields to update if record is already registered
     **/
    void registerDirty(List<SObject> records, List<SObjectField> dirtyFields);
    /**
     * Register specific fields on record to be updated when work is committed
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
     *   you may also provide a reference to the parent record instance (should also be registered as new separately)
     *
     * @param record A newly created SObject instance to be inserted during commitWork
     * @param relatedToParentField A SObjectField reference to the child field that associates the child record with its parent
     * @param relatedToParentRecord A SObject instance of the parent record (should also be registered as new separately)
     **/
    void registerDirty(SObject record, Schema.SObjectField relatedToParentField, SObject relatedToParentRecord);
    /**
     * Register a list of existing records to be updated during the commitWork method
     *
     * @param records A list of existing records
     **/
    void registerDirty(List<SObject> records);
    /**
	 * Register an deleted record to be removed from the recycle bin during the commitWork method
	 *
	 * @param record An deleted record
	 **/
    void registerEmptyRecycleBin(SObject record);
    /**
	 * Register deleted records to be removed from the recycle bin during the commitWork method
	 *
	 * @param records Deleted records
	 **/
    void registerEmptyRecycleBin(List<SObject> records);
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
     * Register a list of existing records to be deleted and removed from the recycle bin during the commitWork method
     *
     * @param records A list of existing records
     **/
    void registerPermanentlyDeleted(List<SObject> records);
    /**
     * Register a list of existing records to be deleted and removed from the recycle bin during the commitWork method
     *
     * @param record A list of existing records
     **/
    void registerPermanentlyDeleted(SObject record);
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