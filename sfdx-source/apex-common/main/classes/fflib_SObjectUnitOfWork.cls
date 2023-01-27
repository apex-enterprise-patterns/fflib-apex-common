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
 * Provides an implementation of the Enterprise Application Architecture Unit Of Work, as defined by Martin Fowler
 *   http://martinfowler.com/eaaCatalog/unitOfWork.html
 *
 * "When you're pulling data in and out of a database, it's important to keep track of what you've changed; otherwise,
 *  that data won't be written back into the database. Similarly you have to insert new objects you create and
 *  remove any objects you delete."
 *
 * "You can change the database with each change to your object model, but this can lead to lots of very small database calls,
 *  which ends up being very slow. Furthermore it requires you to have a transaction open for the whole interaction, which is
 *  impractical if you have a business transaction that spans multiple requests. The situation is even worse if you need to
 *  keep track of the objects you've read so you can avoid inconsistent reads."
 *
 * "A Unit of Work keeps track of everything you do during a business transaction that can affect the database. When you're done,
 *  it figures out everything that needs to be done to alter the database as a result of your work."
 *
 * In an Apex context this pattern provides the following specific benefits
 *  - Applies bulkfication to DML operations, insert, update and delete
 *  - Manages a business transaction around the work and ensures a rollback occurs (even when exceptions are later handled by the caller)
 *  - Honours dependency rules between records and updates dependent relationships automatically during the commit
 *
 * Please refer to the testMethod's in this class for example usage
 *
 * TODO: Need to complete the 100% coverage by covering parameter exceptions in tests
 * TODO: Need to add some more test methods for more complex use cases and some unexpected (e.g. registerDirty and then registerDeleted)
 *
 **/
public virtual class fflib_SObjectUnitOfWork
    implements fflib_ISObjectUnitOfWork
{
    protected List<Schema.SObjectType> m_sObjectTypes = new List<Schema.SObjectType>();

    protected Map<String, List<SObject>> m_newListByType = new Map<String, List<SObject>>();

    protected Map<String, Map<Id, SObject>> m_dirtyMapByType = new Map<String, Map<Id, SObject>>();

    protected Map<String, Map<Id, SObject>> m_deletedMapByType = new Map<String, Map<Id, SObject>>();
    protected Map<String, Map<Id, SObject>> m_emptyRecycleBinMapByType = new Map<String, Map<Id, SObject>>();

    protected Map<String, Relationships> m_relationships = new Map<String, Relationships>();

    protected Map<String, List<SObject>> m_publishBeforeListByType = new Map<String, List<SObject>>();
    protected Map<String, List<SObject>> m_publishAfterSuccessListByType = new Map<String, List<SObject>>();
    protected Map<String, List<SObject>> m_publishAfterFailureListByType = new Map<String, List<SObject>>();

    protected List<IDoWork> m_workList = new List<IDoWork>();

    @TestVisible
    protected IEmailWork m_emailWork = new SendEmailWork();

    protected IDML m_dml;

    /**
     * Interface describes work to be performed during the commitWork method
     **/
    public interface IDoWork
    {
        void doWork();
    }

    public interface IDML
    {
        void dmlInsert(List<SObject> objList);
        void dmlUpdate(List<SObject> objList);
        void dmlDelete(List<SObject> objList);
        void eventPublish(List<SObject> objList);
	    void emptyRecycleBin(List<SObject> objList);
    }

    public virtual class SimpleDML implements IDML
    {
        public virtual void dmlInsert(List<SObject> objList)
        {
            insert objList;
        }
        public virtual void dmlUpdate(List<SObject> objList)
        {
            update objList;
        }
        public virtual void dmlDelete(List<SObject> objList)
        {
            delete objList;
        }
        public virtual void eventPublish(List<SObject> objList)
        {
            EventBus.publish(objList);
        }
		public virtual void emptyRecycleBin(List<SObject> objList)
		{
			if (objList.isEmpty())
			{
				return;
			}

			Database.emptyRecycleBin(objList);
		}
    }

	public virtual class UserModeDML extends SimpleDML{
		@TestVisible
		private AccessLevel m_accessLevel;

		public UserModeDML(){
			this(AccessLevel.USER_MODE);
		}

		/** Supply the AccessLevel explicitly (UserModeDML uses AccessMode.USER_MODE, by default) */
		public UserModeDML(AccessLevel access){
			m_accessLevel = access;
		}

		public virtual override void dmlInsert(List<SObject> objList){
			Database.insert(objList,m_accessLevel);
		}
		public virtual override void dmlUpdate(List<SObject> objList){
			Database.update(objList,m_accessLevel);
		}
		public virtual override void dmlDelete(List<SObject> objList){
			Database.delete(objList,m_accessLevel);
		}
	}


    /**
     * Constructs a new UnitOfWork to support work against the given object list
     *
     * @param sObjectTypes A list of objects given in dependency order (least dependent first)
     */
    public fflib_SObjectUnitOfWork(List<Schema.SObjectType> sObjectTypes)
    {
        this(sObjectTypes,new SimpleDML());
    }

    public fflib_SObjectUnitOfWork(List<Schema.SObjectType> sObjectTypes, IDML dml)
    {
        m_sObjectTypes = sObjectTypes.clone();

        for (Schema.SObjectType sObjectType : m_sObjectTypes)
        {
            // register the type
            handleRegisterType(sObjectType);
        }

		m_relationships.put(Messaging.SingleEmailMessage.class.getName(), new Relationships());

        m_dml = dml;
    }

    // default implementations for commitWork events
    public virtual void onRegisterType(Schema.SObjectType sObjectType) {}
    public virtual void onCommitWorkStarting() {}

    public virtual void onPublishBeforeEventsStarting() {}
    public virtual void onPublishBeforeEventsFinished() {}

    public virtual void onDMLStarting() {}
    public virtual void onDMLFinished() {}

    public virtual void onDoWorkStarting() {}
    public virtual void onDoWorkFinished() {}

    public virtual void onPublishAfterSuccessEventsStarting() {}
    public virtual void onPublishAfterSuccessEventsFinished() {}

    public virtual void onPublishAfterFailureEventsStarting() {}
    public virtual void onPublishAfterFailureEventsFinished() {}

    public virtual void onCommitWorkFinishing() {}
    public virtual void onCommitWorkFinished(Boolean wasSuccessful) {}

    /**
     * Registers the type to be used for DML operations
     *
     * @param sObjectType - The type to register
     *
     */
    private void handleRegisterType(Schema.SObjectType sObjectType)
    {
        String sObjectName = sObjectType.getDescribe().getName();

        // add type to dml operation tracking
        m_newListByType.put(sObjectName, new List<SObject>());
        m_dirtyMapByType.put(sObjectName, new Map<Id, SObject>());
        m_deletedMapByType.put(sObjectName, new Map<Id, SObject>());
	    m_emptyRecycleBinMapByType.put(sObjectName, new Map<Id, SObject>());
        m_relationships.put(sObjectName, new Relationships());

        m_publishBeforeListByType.put(sObjectName, new List<SObject>());
        m_publishAfterSuccessListByType.put(sObjectName, new List<SObject>());
        m_publishAfterFailureListByType.put(sObjectName, new List<SObject>());

        // give derived class opportunity to register the type
        onRegisterType(sObjectType);
    }

    /**
     * Register a generic piece of work to be invoked during the commitWork phase
     **/
    public void registerWork(IDoWork work)
    {
        m_workList.add(work);
    }

    /**
     * Registers the given email to be sent during the commitWork
     **/
    public void registerEmail(Messaging.Email email)
    {
        m_emailWork.registerEmail(email);
    }

	/**
	 * Register an deleted record to be removed from the recycle bin during the commitWork method
	 *
	 * @param record An deleted record
	 **/
	public void registerEmptyRecycleBin(SObject record)
	{
		registerEmptyRecycleBin(new List<SObject> {record});
	}

	/**
	 * Register deleted records to be removed from the recycle bin during the commitWork method
	 *
	 * @param records Deleted records
	 **/
	public void registerEmptyRecycleBin(List<SObject> records)
	{
		if (records.isEmpty()) return;

		Map<String, List<SObject>> sortedRecords =
				sortAndValidateForExistingNonEvent(m_emptyRecycleBinMapByType, records);
		for (String sObjectName : sortedRecords.keySet())
		{
			registerEmptyRecycleBin(sObjectName, sortedRecords.get(sObjectName));
		}
	}

    /**
     * Register a newly created SObject instance to be inserted when commitWork is called
     *
     * @param record A newly created SObject instance to be inserted during commitWork
     **/
    public void registerNew(SObject record)
    {
        registerNew(record, null, null);
    }

    /**
     * Register a list of newly created SObject instances to be inserted when commitWork is called
     *
     * @param records A list of newly created SObject instances to be inserted during commitWork
     **/
    public void registerNew(List<SObject> records)
    {
	    registerNew(records, null, null);
    }

    /**
     * Register a newly created SObject instance to be inserted when commitWork is called,
     *   you may also provide a reference to the parent record instance (should also be registered as new separately)
     *
     * @param record A newly created SObject instance to be inserted during commitWork
     * @param relatedToParentField A SObjectField reference to the child field that associates the child record with its parent
     * @param relatedToParentRecord A SObject instance of the parent record (should also be registered as new separately)
     **/
    public void registerNew(SObject record, Schema.SObjectField relatedToParentField, SObject relatedToParentRecord)
    {
	    registerNew(new List<SObject> {record}, relatedToParentField, relatedToParentRecord);
    }

	/**
	 * Register newly created records to be inserted when commitWork is called,
	 * it also provides a reference to the single parent record instance (should also be registered as new separately)
	 *
	 * @param records newly created records to be inserted during commitWork
	 * @param relatedToParentField A SObjectField reference to the child field that associates the child record with its parent
	 * @param relatedToParentRecord A SObject instance of the parent record (should also be registered as new separately)
	 **/
	public void registerNew(List<SObject> records, Schema.SObjectField relatedToParentField, SObject relatedToParentRecord)
	{
		if (records.isEmpty()) return;

		Map<String, List<SObject>> sortedRecords = sortAndValidateForNewNonEvent(m_newListByType, records);
		for (String sObjectName : sortedRecords.keySet())
		{
			registerNew(sObjectName, sortedRecords.get(sObjectName), relatedToParentField, relatedToParentRecord);
		}
	}

	/**
	 * Register a relationship between two records that have yet to be inserted to the database. This information will be
	 *  used during the commitWork phase to make the references only when related records have been inserted to the database.
	 *
	 * @param record An existing or newly created record
	 * @param relatedToField A SObjectField reference to the lookup field that relates the two records together
	 * @param relatedTo A SObject instance (yet to be committed to the database)
	 */
	public void registerRelationship(SObject record, Schema.SObjectField relatedToField, SObject relatedTo)
	{
		registerRelationship(new List<SObject> {record}, relatedToField, relatedTo);
	}

	/**
	 * Register a relationship between two records that have yet to be inserted to the database. This information will be
	 *  used during the commitWork phase to make the references only when related records have been inserted to the database.
	 *
	 * @param records Existing or newly created records
	 * @param relatedToField A SObjectField reference to the field that relates the given records to the relatedTo record
	 * @param relatedTo A SObject instance (yet to be committed to the database)
	 */
	public void registerRelationship(List<SObject> records, Schema.SObjectField relatedToField, SObject relatedTo)
	{
		if (records.isEmpty()) return;

		Map<String, List<SObject>> sortedRecords = sortAndValidateForNonEvent(m_newListByType, records);

		for (String sObjectName : sortedRecords.keySet())
		{
			registerRelationship(sObjectName, sortedRecords.get(sObjectName), relatedToField, relatedTo);
		}
	}

    /**
     * Registers a relationship between a record and a Messaging.Email where the record has yet to be inserted
     *  to the database.  This information will be
     *  used during the commitWork phase to make the references only when related records have been inserted to the database.
     *
     * @param email a single email message instance
     * @param relatedTo A SObject instance (yet to be committed to the database)
     */
    public void registerRelationship( Messaging.SingleEmailMessage email, SObject relatedTo )
    {
        m_relationships.get( Messaging.SingleEmailMessage.class.getName() ).add(email, relatedTo);
    }

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
    public void registerRelationship(SObject record, Schema.SObjectField relatedToField, Schema.SObjectField externalIdField, Object externalId)
    {
	    // NOTE: Due to the lack of ExternalID references on Standard Objects, this method can not be provided a standardized Unit Test. - Rick Parker
	    String sObjectType = record.getSObjectType().getDescribe().getName();

	    assertForSupportedSObjectType(m_newListByType, sObjectType);

	    m_relationships.get(sObjectType).add(record, relatedToField, externalIdField, externalId);
    }

    /**
     * Register an existing record to be updated during the commitWork method
     *
     * @param record An existing record
     **/
    public void registerDirty(SObject record)
    {
        registerDirty(record, new List<SObjectField>());
    }

	/**
	 * Registers the entire record as dirty or just only the dirty fields if the record was already registered
	 *
	 * @param record SObject to register as dirty
	 * @param dirtyFields A list of modified fields
	 */
	public void registerDirty(SObject record, List<SObjectField> dirtyFields)
	{
		registerDirty(new List<SObject> {record}, dirtyFields);
	}

	/**
	 * Registers the entire record as dirty or just only the dirty fields if the record was already registered
	 *
	 * @param records SObjects to register as dirty
	 * @param dirtyFields A list of modified fields
	 */
	public void registerDirty(List<SObject> records, List<SObjectField> dirtyFields)
	{
		if (records.isEmpty()) return;

		Map<String, List<SObject>> sortedRecords = sortAndValidateForExistingNonEvent(m_dirtyMapByType, records);
		for (String sObjectName : sortedRecords.keySet())
		{
			registerDirty(sObjectName, sortedRecords.get(sObjectName), dirtyFields);
		}
	}

    /**
     * Register an existing record to be updated when commitWork is called,
     *   you may also provide a reference to the parent record instance (should also be registered as new separately)
     *
     * @param record An existing SObject instance to be updated during commitWork
     * @param relatedToParentField A SObjectField reference to the child field that associates the child record with its parent
     * @param relatedToParentRecord A SObject instance of the parent record (should also be registered as new separately)
     **/
    public void registerDirty(SObject record, Schema.SObjectField relatedToParentField, SObject relatedToParentRecord)
    {
	    registerDirty(new List<SObject> {record}, relatedToParentField, relatedToParentRecord);
    }

	/**
	 * Register existing records to be updated when commitWork is called,
	 * it provide a reference to the parent record instance (should also be registered as new separately)
	 *
	 * @param records Existing records to be updated during commitWork
	 * @param relatedToParentField A SObjectField reference to the child field that associates the child record with its parent
	 * @param relatedToParentRecord A SObject instance of the parent record (should also be registered as new separately)
	 **/
	public void registerDirty(List<SObject> records, Schema.SObjectField relatedToParentField, SObject relatedToParentRecord)
	{
		if (records.isEmpty()) return;

		Map<String, List<SObject>> sortedRecords = sortAndValidateForExistingNonEvent(m_dirtyMapByType, records);
		for (String sObjectName : sortedRecords.keySet())
		{
			registerDirty(sObjectName, sortedRecords.get(sObjectName), relatedToParentField, relatedToParentRecord);
		}
	}

    /**
     * Register a list of existing records to be updated during the commitWork method
     *
     * @param records A list of existing records
     **/
    public void registerDirty(List<SObject> records)
    {
	    registerDirty(records, new List<SObjectField>());
    }

    /**
     * Register a new or existing record to be inserted/updated during the commitWork method
     *
     * @param record A new or existing record
     **/
    public void registerUpsert(SObject record)
    {
	    registerUpsert(new List<SObject> {record});
    }

    /**
     * Register a list of mix of new and existing records to be inserted updated during the commitWork method
     *
     * @param records A list of mix of new and existing records
     **/
    public void registerUpsert(List<SObject> records)
    {
	    List<SObject> forInsert = new List<SObject>();
	    List<SObject> forUpdate = new List<SObject>();
	    for (SObject record : records)
	    {
		    if (record.Id == null) forInsert.add(record);
		    else forUpdate.add(record);
	    }
	    if (!forInsert.isEmpty()) registerNew(forInsert);
	    if (!forUpdate.isEmpty()) registerDirty(forUpdate);
    }

    /**
     * Register an existing record to be deleted during the commitWork method
     *
     * @param record An existing record
     **/
    public void registerDeleted(SObject record)
    {
	    registerDeleted(new List<SObject> {record});
    }

    /**
     * Register a list of existing records to be deleted during the commitWork method
     *
     * @param records A list of existing records
     **/
    public void registerDeleted(List<SObject> records)
    {
	    if (records.isEmpty()) return;

	    Map<String, List<SObject>> sortedRecords = sortAndValidateForExistingNonEvent(m_deletedMapByType, records);
	    for (String sObjectName : sortedRecords.keySet())
	    {
		    registerDeleted(sObjectName, sortedRecords.get(sObjectName));
	    }
    }

	/**
     * Register a list of existing records to be deleted and removed from the recycle bin during the commitWork method
     *
     * @param records A list of existing records
     **/
    public void registerPermanentlyDeleted(List<SObject> records)
    {
	    this.registerEmptyRecycleBin(records);
	    this.registerDeleted(records);
    }

	/**
     * Register a list of existing records to be deleted and removed from the recycle bin during the commitWork method
     *
     * @param record A list of existing records
     **/
    public void registerPermanentlyDeleted(SObject record)
    {
	    registerPermanentlyDeleted(new List<SObject> {record});
    }

    /**
     * Register a newly created SObject (Platform Event) instance to be published when commitWork is called
     *
     * @param record A newly created SObject (Platform Event) instance to be inserted during commitWork
     **/
    public void registerPublishBeforeTransaction(SObject record)
    {
        String sObjectType = record.getSObjectType().getDescribe().getName();

		assertForEventSObjectType(sObjectType);
		assertForSupportedSObjectType(m_publishBeforeListByType, sObjectType);

        m_publishBeforeListByType.get(sObjectType).add(record);
    }

    /**
     * Register a list of newly created SObject (Platform Event) instance to be published when commitWork is called
     *
     * @param records A list of existing records
     **/
    public void registerPublishBeforeTransaction(List<SObject> records)
    {
        for (SObject record : records)
        {
            this.registerPublishBeforeTransaction(record);
        }
    }

    /**
     * Register a newly created SObject (Platform Event) instance to be published when commitWork is called
     *
     * @param record A newly created SObject (Platform Event) instance to be inserted during commitWork
     **/
    public void registerPublishAfterSuccessTransaction(SObject record)
    {
        String sObjectType = record.getSObjectType().getDescribe().getName();

		assertForEventSObjectType(sObjectType);
		assertForSupportedSObjectType(m_publishAfterSuccessListByType, sObjectType);

        m_publishAfterSuccessListByType.get(sObjectType).add(record);
    }

    /**
     * Register a list of newly created SObject (Platform Event) instance to be published when commitWork is called
     *
     * @param records A list of existing records
     **/
    public void registerPublishAfterSuccessTransaction(List<SObject> records)
    {
        for (SObject record : records)
        {
            this.registerPublishAfterSuccessTransaction(record);
        }
    }
    /**
     * Register a newly created SObject (Platform Event) instance to be published when commitWork is called
     *
     * @param record A newly created SObject (Platform Event) instance to be inserted during commitWork
     **/
    public void registerPublishAfterFailureTransaction(SObject record)
    {
        String sObjectType = record.getSObjectType().getDescribe().getName();

		assertForEventSObjectType(sObjectType);
		assertForSupportedSObjectType(m_publishAfterFailureListByType, sObjectType);

        m_publishAfterFailureListByType.get(sObjectType).add(record);
    }

    /**
     * Register a list of newly created SObject (Platform Event) instance to be published when commitWork is called
     *
     * @param records A list of existing records
     **/
    public void registerPublishAfterFailureTransaction(List<SObject> records)
    {
        for (SObject record : records)
        {
            this.registerPublishAfterFailureTransaction(record);
        }
    }

    /**
     * Takes all the work that has been registered with the UnitOfWork and commits it to the database
     **/
	public void commitWork()
	{
		Savepoint sp = Database.setSavepoint();
		Boolean wasSuccessful = false;
		try
		{
			doCommitWork();
			wasSuccessful = true;
		}
		catch (Exception e)
		{
			Database.rollback(sp);
			throw e;
		}
		finally
		{
			doAfterCommitWorkSteps(wasSuccessful);
		}
	}

	/**
	 * Adds the records to the delete queue for the given SObjectType
	 *
	 * @param sObjectName The SObjectType name of the records
	 * @param records SObjects to register as deleted
	 */
	protected void registerDeleted(String sObjectName, List<SObject> records)
	{
		m_deletedMapByType.get(sObjectName).putAll(records);
	}

	/**
	 * Adds the records to the dirty and relationship queue for the given SObjectType
	 *
	 * @param sObjectName The SObjectType name of the records
	 * @param records SObjects to register as dirty
	 * @param relatedToParentField A SObjectField reference to the child field that associates the child record with its parent
	 * @param relatedToParentRecord A SObject instance of the parent record (should also be registered as new separately)
	 */
	protected void registerDirty(
			String sObjectName,
			List<SObject> records,
			Schema.SObjectField relatedToParentField,
			SObject relatedToParentRecord)
	{
		m_dirtyMapByType.get(sObjectName).putAll(records);

		if (relatedToParentRecord == null || relatedToParentField == null) return;

		registerRelationship(sObjectName, records, relatedToParentField, relatedToParentRecord);
	}

	/**
	 * Adds the records to the dirty queue for the given SObjectType
	 *
	 * @param sObjectName The SObjectType name of the records
	 * @param records SObjects to register as dirty
	 * @param dirtyFields A list of modified fields
	 */
	protected void registerDirty(String sObjectName, List<SObject> records, List<SObjectField> dirtyFields)
	{
		// Register the record as dirty, if no dirty fields or all records are not registered as dirty
		if (dirtyFields.isEmpty()
				||
				!m_dirtyMapByType.get(sObjectName).keySet().containsAll(new Map<Id, SObject>(records).keySet()))
		{
			m_dirtyMapByType.get(sObjectName).putAll(records);
		}
		else
		{
			// Check records one by one and resolve dirty fields.
			for (SObject record : records)
			{
				// Register the record as dirty, if record isn't registered already
				if (!m_dirtyMapByType.get(sObjectName).containsKey(record.Id))
				{
					m_dirtyMapByType.get(sObjectName).put(record.Id, record);
				}
				else
				{
					// Update the registered record's fields
					SObject registeredRecord = m_dirtyMapByType.get(sObjectName).get(record.Id);

					for (SObjectField dirtyField : dirtyFields)
					{
						registeredRecord.put(dirtyField, record.get(dirtyField));
					}

					m_dirtyMapByType.get(sObjectName).put(record.Id, registeredRecord);
				}
			}
		}
	}

	/**
	 * Adds the records to the emptyRecycleBin queue for the given SObjectType
	 *
	 * @param sObjectName  The SObjectType name of the records
	 * @param records Records to register as emptyRecycleBin
	 */
	protected void registerEmptyRecycleBin(String sObjectName, List<SObject> records)
	{
		m_emptyRecycleBinMapByType.get(sObjectName).putAll(records);
	}

	/**
	 * Adds the records to the insert queue for the given SObjectType
	 *
	 * @param sObjectName The SObjectType name of the records
	 * @param records Records to register as new, all of the given SObjectType
	 * @param relatedToParentField A SObjectField reference to the child field that associates the child record with its parent
	 * @param relatedToParentRecord A SObject instance of the parent record (should also be registered as new separately)
	 */
	protected void registerNew(
			String sObjectName,
			List<SObject> records,
			Schema.SObjectField relatedToParentField,
			SObject relatedToParentRecord)
	{
		m_newListByType.get(sObjectName).addAll(records);

		if (relatedToParentRecord == null || relatedToParentField == null) return;

		registerRelationship(sObjectName, records, relatedToParentField, relatedToParentRecord);
	}

	/**
	 * Adds the records to the relationship queue for the given SObjectType
	 *
	 * @param sObjectName The SObjectType name of the records
	 * @param records Existing or newly created records
	 * @param relatedToField A SObjectField reference to the field that relates the given records to the relatedTo record
	 * @param relatedTo A SObject instance (yet to be committed to the database)
	 */
	protected void registerRelationship(
			String sObjectName,
			List<SObject> records,
			Schema.SObjectField relatedToField,
			SObject relatedTo)
	{
		m_relationships.get(sObjectName).add(records, relatedToField, relatedTo);
	}

	private void doCommitWork()
	{
		onCommitWorkStarting();
		onPublishBeforeEventsStarting();
		publishBeforeEventsStarting();
		onPublishBeforeEventsFinished();

		onDMLStarting();
		insertDmlByType();
		updateDmlByType();
		deleteDmlByType();
		emptyRecycleBinByType();
		resolveEmailRelationships();
		onDMLFinished();

		onDoWorkStarting();
		doWork();
		onDoWorkFinished();
		onCommitWorkFinishing();
	}

	private void doAfterCommitWorkSteps(Boolean wasSuccessful)
	{
		if (wasSuccessful)
		{
			doAfterCommitWorkSuccessSteps();
		}
		else
		{
			doAfterCommitWorkFailureSteps();
		}
		onCommitWorkFinished(wasSuccessful);
	}

	private void doAfterCommitWorkSuccessSteps()
	{
		onPublishAfterSuccessEventsStarting();
		publishAfterSuccessEvents();
		onPublishAfterSuccessEventsFinished();
	}

	private void doAfterCommitWorkFailureSteps()
	{
		onPublishAfterFailureEventsStarting();
		publishAfterFailureEvents();
		onPublishAfterFailureEventsFinished();
	}

	private void publishBeforeEventsStarting()
	{
		for (Schema.SObjectType sObjectType : m_sObjectTypes)
		{
			m_dml.eventPublish(m_publishBeforeListByType.get(sObjectType.getDescribe().getName()));
		}
	}

	private void insertDmlByType()
	{
		for (Schema.SObjectType sObjectType : m_sObjectTypes)
		{
			m_relationships.get(sObjectType.getDescribe().getName()).resolve();
			m_dml.dmlInsert(m_newListByType.get(sObjectType.getDescribe().getName()));
		}
	}

	private void updateDmlByType()
	{
		for (Schema.SObjectType sObjectType : m_sObjectTypes)
		{
			m_dml.dmlUpdate(m_dirtyMapByType.get(sObjectType.getDescribe().getName()).values());
		}
	}

	private void deleteDmlByType()
	{
		Integer objectIdx = m_sObjectTypes.size() - 1;
		while (objectIdx >= 0)
		{
			m_dml.dmlDelete(m_deletedMapByType.get(m_sObjectTypes[objectIdx--].getDescribe().getName()).values());
		}
	}

	private void emptyRecycleBinByType()
	{
		Integer objectIdx = m_sObjectTypes.size() - 1;
		while (objectIdx >= 0)
		{
			m_dml.emptyRecycleBin(m_emptyRecycleBinMapByType.get(m_sObjectTypes[objectIdx--].getDescribe().getName()).values());
		}
	}

	private void resolveEmailRelationships()
	{
		m_relationships.get(Messaging.SingleEmailMessage.class.getName()).resolve();
	}

	private void doWork()
	{
		m_workList.add(m_emailWork);
		for (IDoWork work : m_workList)
		{
			work.doWork();
		}
	}

	private void publishAfterSuccessEvents()
	{
		for (Schema.SObjectType sObjectType : m_sObjectTypes)
		{
			m_dml.eventPublish(m_publishAfterSuccessListByType.get(sObjectType.getDescribe().getName()));
		}
	}

	private void publishAfterFailureEvents()
	{
		for (Schema.SObjectType sObjectType : m_sObjectTypes)
		{
			m_dml.eventPublish(m_publishAfterFailureListByType.get(sObjectType.getDescribe().getName()));
		}
	}

	@TestVisible
	private void assertForNonEventSObjectType(String sObjectType)
	{
		if (sObjectType.length() > 3 && sObjectType.right(3)  == '__e')
		{
			throw new UnitOfWorkException(
					String.format(Label.fflib_SObjectUnitOfWork_event_SObjectType_must_use_publish,
							new List<String> { sObjectType }
					)
			);
		}
	}

	@TestVisible
	private void assertForEventSObjectType(String sObjectType)
	{
		if (sObjectType.length() > 3 && sObjectType.right(3) != '__e')
		{
			throw new UnitOfWorkException(
					String.format(Label.fflib_SObjectUnitOfWork_non_event_SObjectType_used_with_publish,
							new List<String> {sObjectType}
					)
			);
		}
	}

	private void assertForExistingRecord(SObject record)
	{
		if (record.Id == null)
			throw new UnitOfWorkException(Label.fflib_SObjectUnitOfWork_new_records_not_supported);
	}

	private void assertForNewRecord(SObject record)
	{
		if (record.Id != null)
			throw new UnitOfWorkException(Label.fflib_SObjectUnitOfWork_only_new_records_supported);
	}

	@TestVisible
	private void assertForSupportedSObjectType(Map<String, Object> theMap, String sObjectType)
	{
		if (!theMap.containsKey(sObjectType))
		{
			throw new UnitOfWorkException(
					String.format(
							Label.fflib_SObjectUnitOfWork_not_supported_SObjectType,
							new List<String> {sObjectType}
					)
			);
		}
	}

	private Map<String, List<SObject>> sortAndValidateForExistingNonEvent(Map<String, Object> theMap, List<SObject> records)
	{
		Map<String, List<SObject>> result = new Map<String, List<SObject>>();
		for (SObject record : records)
		{
			String sObjectName = record.getSObjectType().getDescribe().getName();

			assertForSupportedSObjectType(theMap, sObjectName);
			assertForExistingRecord(record);
			assertForNonEventSObjectType(sObjectName);

			if (result.containsKey(sObjectName))
			{
				result.get(sObjectName).add(record);
			}
			else
			{
				result.put(sObjectName, new List<SObject> {record});
			}
		}
		return result;
	}

	private Map<String, List<SObject>> sortAndValidateForNewNonEvent(Map<String, Object> theMap, List<SObject> records)
	{
		Map<String, List<SObject>> result = new Map<String, List<SObject>>();
		for (SObject record : records)
		{
			String sObjectName = record.getSObjectType().getDescribe().getName();

			assertForSupportedSObjectType(theMap, sObjectName);
			assertForNewRecord(record);
			assertForNonEventSObjectType(sObjectName);

			if (result.containsKey(sObjectName))
			{
				result.get(sObjectName).add(record);
			}
			else
			{
				result.put(sObjectName, new List<SObject> {record});
			}
		}
		return result;
	}

	private Map<String, List<SObject>> sortAndValidateForNonEvent(Map<String, Object> theMap, List<SObject> records)
	{
		Map<String, List<SObject>> result = new Map<String, List<SObject>>();
		for (SObject record : records)
		{
			String sObjectName = record.getSObjectType().getDescribe().getName();

			assertForSupportedSObjectType(theMap, sObjectName);
			assertForNonEventSObjectType(sObjectName);

			if (result.containsKey(sObjectName))
			{
				result.get(sObjectName).add(record);
			}
			else
			{
				result.put(sObjectName, new List<SObject> {record});
			}
		}
		return result;
	}

	private class Relationships
	{
		private List<IRelationship> m_relationships = new List<IRelationship>();

		public void resolve()
		{
			// Resolve relationships
			for (IRelationship relationship : m_relationships)
			{
				//relationship.Record.put(relationship.RelatedToField, relationship.RelatedTo.Id);
				relationship.resolve();
            }

        }

        public void add(SObject record, Schema.SObjectField relatedToField, Schema.SObjectField externalIdField, Object externalId)
        {
            if (relatedToField == null) {
                throw new UnitOfWorkException(Label.fflib_SObjectUnitOfWork_invalid_argument_relatedToField_null);
            }

            String relationshipName = relatedToField.getDescribe().getRelationshipName();
            if (String.isBlank(relationshipName)) {
                throw new UnitOfWorkException(Label.fflib_SObjectUnitOfWork_invalid_argument_relatedToField_invalid);
            }

            List<Schema.SObjectType> relatedObjects = relatedToField.getDescribe().getReferenceTo();
            Schema.SObjectType relatedObject = relatedObjects[0];

            String externalIdFieldName = externalIdField.getDescribe().getName();
            Boolean relatedHasExternalIdField = relatedObject.getDescribe().fields.getMap().keySet().contains(externalIdFieldName.toLowerCase());
            Boolean externalIdFieldIsValid = externalIdField.getDescribe().isExternalId();

            if (!relatedHasExternalIdField) {
                throw new UnitOfWorkException(Label.fflib_SObjectUnitOfWork_invalid_argument_externalIdField_unknown);
            }

            if (!externalIdFieldIsValid) {
                throw new UnitOfWorkException(Label.fflib_SObjectUnitOfWork_invalid_argument_externalIdField_invalid);
            }

	        RelationshipByExternalId relationship = new RelationshipByExternalId();
	        relationship.Record = record;
	        relationship.RelatedToField = relatedToField;
	        relationship.RelatedTo = relatedObject;
	        relationship.RelationshipName = relationshipName;
	        relationship.ExternalIdField = externalIdField;
	        relationship.ExternalId = externalId;
	        m_relationships.add(relationship);
        }

	    public void add(List<SObject> records, Schema.SObjectField relatedToField, SObject relatedTo)
	    {
		    for (SObject record : records)
		    {
			    add(record, relatedToField, relatedTo);
		    }
	    }

	    public void add(SObject record, Schema.SObjectField relatedToField, SObject relatedTo)
	    {
		    // Relationship to resolve
		    Relationship relationship = new Relationship();
		    relationship.Record = record;
		    relationship.RelatedToField = relatedToField;
		    relationship.RelatedTo = relatedTo;
		    m_relationships.add(relationship);
	    }

        public void add(Messaging.SingleEmailMessage email, SObject relatedTo)
        {
            EmailRelationship emailRelationship = new EmailRelationship();
            emailRelationship.email = email;
            emailRelationship.relatedTo = relatedTo;
            m_relationships.add(emailRelationship);
        }
    }

    private interface IRelationship
    {
        void resolve();
    }

    private class RelationshipByExternalId implements IRelationship
    {
        public SObject Record;
        public Schema.SObjectField RelatedToField;
        public Schema.SObjectType RelatedTo;
        public String RelationshipName;
        public Schema.SObjectField ExternalIdField;
        public Object ExternalId;

        public void resolve()
        {
            SObject relationshipObject = this.RelatedTo.newSObject();
            relationshipObject.put( ExternalIdField.getDescribe().getName(), this.ExternalId );
            this.Record.putSObject( this.RelationshipName, relationshipObject );
        }
    }

    private class Relationship implements IRelationship
    {
        public SObject Record;
        public Schema.SObjectField RelatedToField;
        public SObject RelatedTo;

        public void resolve()
        {
            this.Record.put( this.RelatedToField, this.RelatedTo.Id);
        }
    }

    private class EmailRelationship implements IRelationship
    {
        public Messaging.SingleEmailMessage email;
        public SObject relatedTo;

        public void resolve()
        {
            this.email.setWhatId( this.relatedTo.Id );
        }
    }

    /**
     * UnitOfWork Exception
     **/
    public class UnitOfWorkException extends Exception {}

    /**
     * Internal implementation of Messaging.sendEmail, see outer class registerEmail method
     **/
    public interface IEmailWork extends IDoWork
    {
        void registerEmail(Messaging.Email email);
    }

    private class SendEmailWork implements IEmailWork
    {
        private List<Messaging.Email> emails;

        public SendEmailWork()
        {
            this.emails = new List<Messaging.Email>();
        }

        public void registerEmail(Messaging.Email email)
        {
            this.emails.add(email);
        }

        public void doWork()
        {
            if (emails.size() > 0) Messaging.sendEmail(emails);
        }
    }
}
