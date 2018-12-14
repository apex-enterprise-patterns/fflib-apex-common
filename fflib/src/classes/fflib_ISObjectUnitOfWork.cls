/*
* FinancialForce.com, inc. claims copyright in this software, its screen
* display designs and supporting documentation. FinancialForce and
* FinancialForce.com are trademarks of FinancialForce.com, inc. Any
* unauthorized use, copying or sale of the above may constitute an
* infringement of copyright and may result in criminal or other legal
* proceedings.
*
* Copyright (c) 2013 FinancialForce.com, inc. All rights reserved.
*/

/**
 * @see fflib_SObjectUnitOfWork
 **/
public interface fflib_ISObjectUnitOfWork
{
	/**
	 * extractCleanIds
	 *
	 * @description Remove the registered clean record ids from the given set and returns them
	 *
	 * @param sObjectType A SObjectType reference for the clean registered records
	 * @param idSet The set of Ids where the clean record ids will be extracted from and returns the set without them
	 *
	 * @return A set of Ids which are stored as clean and member of the given idSet
	 */
	Set<Id> extractCleanIds(Schema.SObjectType sObjectType, Set<Id> idSet);
	/**
	 * extractCleanIds
	 *
	 * @description Remove the registered clean record ids from the given set and returns them
	 *
	 * @param sObjectType The name of the registered clean SObjectType
	 * @param idSet The set of Ids where the clean record ids will be extracted from and returns the set without them
	 *
	 * @return A set of Ids which are stored as clean and member of the given idSet
	 */
	Set<Id> extractCleanIds(String sObjectType, Set<Id> idSet);
	/**
	 * extractDeletedIds
	 *
	 * @description Remove the registered deleted record ids from the given set and returns them
	 *
	 * @param sObjectType A SObjectType reference for the deleted registered records
	 * @param idSet The set of Ids where the deleted record ids will be extracted from and returns the set without them
	 *
	 * @return A set of Ids which are stored as deleted and member of the given idSet
	 */
	Set<Id> extractDeletedIds(Schema.SObjectType sObjectType, Set<Id> idSet);
	/**
	 * extractDeletedIds
	 *
	 * @description Remove the registered deleted record ids from the given set and returns them
	 *
	 * @param sObjectType The name of the registered deleted SObjectType
	 * @param idSet The set of Ids where the deleted record ids will be extracted from and returns the set without them
	 *
	 * @return A set of Ids which are stored as deleted and member of the given idSet
	 */
	Set<Id> extractDeletedIds(String sObjectType, Set<Id> idSet);
	/**
	 * extractDirtyIds
	 *
	 * @description Remove the registered dirty record ids from the given set and returns them
	 *
	 * @param sObjectType A SObjectType reference for the dirty registered records
	 * @param idSet The set of Ids where the clean Ids will be extracted from and returns the set without them
	 *
	 * @return A set of Ids which are stored as dirty and member of the given idSet
	 */
	Set<Id> extractDirtyIds(Schema.SObjectType sObjectType, Set<Id> idSet);
	/**
	 * extractDirtyIds
	 *
	 * @description Remove the registered dirty record ids from the given set and returns them
	 *
	 * @param sObjectType The name of the registered dirty SObjectType
	 * @param idSet The set of Ids where the dirty record ids will be extracted from and returns the set without them
	 *
	 * @return A set of Ids which are stored as dirty and member of the given idSet
	 */
	Set<Id> extractDirtyIds(String sObjectType, Set<Id> idSet);
	/**
	 * getClean
	 *
	 * @description Get the clean registered records of the given id set
	 *
	 * @param sObjectType The name of the registered clean SObjectType
	 * @param idSet A set of Id's to search for
	 *
	 * @return A list of clean registered SObjects which are member of the given idSet
	 */
	List<SObject> getClean(String sObjectType, Set<Id> idSet);
	/**
	 * getClean
	 *
	 * @description Get the clean registered records of the given id set
	 *
	 * @param sObjectType A SObjectType reference registered clean SObjectType
	 * @param idSet A set of Id's to search for
	 *
	 * @return A list of clean registered SObjects which are member of the given idSet
	 */
    List<SObject> getClean(Schema.SObjectType sObjectType, Set<Id> idSet);
	/**
	 * getDeleted
	 *
	 * @description Get the deleted registered records of the given id set
	 *
	 * @param sObjectType The name of the registered deleted SObjectType
	 * @param idSet A set of Id's to search for
	 */
	List<SObject> getDeleted(String sObjectType, Set<Id> idSet);
	/**
	 * getDeleted
	 *
	 * @description Get the deleted registered records of the given id set
	 *
	 * @param sObjectType A SObjectType reference registered deleted SObjectType
	 * @param idSet A set of Id's to search for
	 */
	List<SObject> getDeleted(Schema.SObjectType sObjectType, Set<Id> idSet);
	/**
	 * getDirty
	 *
	 * @description Get the dirty registered records of the given id set
	 *
	 * @param sObjectType The name of the registered clean SObjectType
	 * @param idSet A set of Id's to search for
	 */
	List<SObject> getDirty(String sObjectType, Set<Id> idSet);
	/**
	 * getDirty
	 *
	 * @description Get the dirty registered records of the given id set
	 *
	 * @param sObjectType A SObjectType reference registered dirty SObjectType
	 * @param idSet A set of Id's to search for
	 */
	List<SObject> getDirty(Schema.SObjectType sObjectType, Set<Id> idSet);
     /**
     * Register a just queried SObject that has not been changed yet
     *
     * @param record A queried SObject instance
     **/
	void registerClean(SObject record);
	/**
     * Register a list of just queried SObject that has not been changed yet
     *
     * @param records A list of queried SObject instances
     **/
	void registerClean(List<SObject> records);
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