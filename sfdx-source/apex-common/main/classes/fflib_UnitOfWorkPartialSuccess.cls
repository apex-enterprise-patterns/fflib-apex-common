/*
* Behaves similarly to SObjectUnitOfWork, but allows for partial success results from committing to
* the database.
*
* Basically, this has allOrNothing set to false for DML operations. This will also return the DmlResults
* back to the commitWork caller in the same order in which they were registered.
 */

public with sharing class fflib_UnitOfWorkPartialSuccess extends fflib_SObjectUnitOfWork {

	private PartialSuccessDml partialDml;
	private Map<fflib_DatabaseOperation, List<fflib_DmlOperation>> dmlOperationsByDatabaseOperation;
	private Map<SObjectType, List<SObject>> undeleteSObjectsBySObjectType;

	/**
   * Constructs a new UnitOfWork to support work against the given object list
   *
   * @param sObjectList A list of objects given in dependency order (least dependent first)
   */
	public fflib_UnitOfWorkPartialSuccess(List<SObjectType> types) {
		super(types);
		initialize();
	}

	private void initialize() {
		partialDml = new PartialSuccessDml();
		undeleteSObjectsBySObjectType = new Map<SObjectType, List<SObject>>();
		for (SObjectType sObjectType : m_sObjectTypes) {
			undeleteSObjectsBySObjectType.put(sObjectType, new List<SObject>());
		}

		dmlOperationsByDatabaseOperation = new Map<fflib_DatabaseOperation, List<fflib_DmlOperation>>();
		for (fflib_DatabaseOperation databaseOperation : fflib_DatabaseOperation.values()) {
			dmlOperationsByDatabaseOperation.put(databaseOperation, new List<fflib_DmlOperation>());
		}
	}

	/**
     * Register a newly created SObject instance to be inserted when commitWork is called
     *
     * @param record A newly created SObject instance to be inserted during commitWork
     *
     * @return DML operation instance
     **/
	public fflib_DmlOperation registerNewDmlOperation(SObject record) {
		return registerNewDmlOperation(record, null, null);
	}

	/**
	 * Register a list of newly created SObject instances to be inserted when commitWork is called
	 *
	 * @param records A list of newly created SObject instances to be inserted during commitWork
	 *
	 * @return A list of DML operation instances
	 **/
	public List<fflib_DmlOperation> registerNewDmlOperations(List<SObject> records) {
		List<fflib_DmlOperation> dmlOperations = new List<fflib_DmlOperation>();
		for (SObject record : records) {
			dmlOperations.add(registerNewDmlOperation(record, null, null));
		}
		return dmlOperations;
	}

	/**
     * Register a newly created SObject instance to be inserted when commitWork is called,
     *   you may also provide a reference to the parent record instance (should also be registered as new separately).
     *
     * @param record A newly created SObject instance to be inserted during commitWork
     * @param relatedToParentField A SObjectField reference to the child field that associates the child record with its parent
     * @param relatedToParentRecord A SObject instance of the parent record (should also be registered as new separately)
     *
     * @return DML operation instance
     **/
	public fflib_DmlOperation registerNewDmlOperation(SObject record, SObjectField relatedToParentField,
			SObject relatedToParentRecord) {
		if (record.Id != null) {
			throw new UnitOfWorkException('Only new records can be registered as new.');
		}
		String sObjectType = record.getSObjectType().getDescribe().getName();
		if (!m_newListByType.containsKey(sObjectType)) {
			throw new UnitOfWorkException(
					'SObjectType ' + sObjectType + ' is not supported by this unit of work.');
		}

		m_newListByType.get(sObjectType).add(record);
		fflib_DmlOperation dmlOperation =
				new fflib_DmlOperation(record, fflib_DatabaseOperation.DATABASE_INSERT);
		dmlOperationsByDatabaseOperation.get(fflib_DatabaseOperation.DATABASE_INSERT).add(dmlOperation);

		if (relatedToParentRecord != null && relatedToParentField != null) {
			registerRelationship(record, relatedToParentField, relatedToParentRecord);
		}
		return dmlOperation;
	}

	/**
     * Register an existing record to be updated during the commitWork method
     *
     * @param record An existing record
     *
     * @return DML operation instance
     **/
	public fflib_DmlOperation registerDirtyDmlOperation(SObject record) {
		return registerDirtyDmlOperation(record, null, null);
	}

	/**
	 * Register a list of SObject instances to be updated when commitWork is called
	 *
	 * @param records A list of newly created SObject instances to be inserted during commitWork
	 *
	 * @return DML operation instance
	 **/
	public List<fflib_DmlOperation> registerDirtyDmlOperations(List<SObject> records) {
		List<fflib_DmlOperation> dmlOperations = new List<fflib_DmlOperation>();
		for (SObject record : records) {
			dmlOperations.add(registerDirtyDmlOperation(record, null, null));
		}
		return dmlOperations;
	}

	/**
     * Register an existing record to be updated when commitWork is called,
     *   you may also provide a reference to the parent record instance (should also be registered as new separately)
     *
     * @param record A newly created SObject instance to be inserted during commitWork
     * @param relatedToParentField A SObjectField reference to the child field that associates the child record with its parent
     * @param relatedToParentRecord A SObject instance of the parent record (should also be registered as new separately)
     *
     * @return DML operation instance
     **/
	public fflib_DmlOperation registerDirtyDmlOperation(SObject record, SObjectField relatedToParentField,
			SObject relatedToParentRecord) {
		if (record.Id == null) {
			throw new UnitOfWorkException('Only existing records can be registered as dirty.');
		}

		String sObjectType = record.getSObjectType().getDescribe().getName();
		if (!m_dirtyMapByType.containsKey(sObjectType)) {
			throw new UnitOfWorkException(
					'SObjectType ' + sObjectType + ' is not supported by this unit of work.');
		}

		m_dirtyMapByType.get(sObjectType).put(record.Id, record);
		fflib_DmlOperation dmlOperation =
				new fflib_DmlOperation(record, fflib_DatabaseOperation.DATABASE_UPDATE);
		dmlOperationsByDatabaseOperation.get(fflib_DatabaseOperation.DATABASE_UPDATE).add(dmlOperation);

		if (relatedToParentRecord != null && relatedToParentField != null) {
			registerRelationship(record, relatedToParentField, relatedToParentRecord);
		}
		return dmlOperation;
	}

	/**
	* Register an existing record to be deleted during the commitWork method
	*
	* @param record An existing record
	 *
	 * @return DML operation instance
	**/
	public fflib_DmlOperation registerDeleteDmlOperation(SObject record) {
		if (record.Id == null) {
			throw new UnitOfWorkException('Only existing records can be registered for deletion.');
		}

		String sObjectType = record.getSObjectType().getDescribe().getName();
		if (!m_deletedMapByType.containsKey(sObjectType)) {
			throw new UnitOfWorkException(
					'SObjectType ' + sObjectType + ' is not supported by this unit of work.');
		}

		m_deletedMapByType.get(sObjectType).put(record.Id, record);
		fflib_DmlOperation dmlOperation =
				new fflib_DmlOperation(record, fflib_DatabaseOperation.DATABASE_DELETE);
		dmlOperationsByDatabaseOperation.get(fflib_DatabaseOperation.DATABASE_DELETE).add(dmlOperation);

		return dmlOperation;
	}

	/**
	 * Register a list of existing records to be deleted during the commitWork method
	 *
	 * @param records A list of existing records
	 *
	 * @return DML operation instance
	 **/
	public List<fflib_DmlOperation> registerDeleteDmlOperations(List<SObject> records) {
		List<fflib_DmlOperation> dmlOperations = new List<fflib_DmlOperation>();
		for (SObject record : records) {
			dmlOperations.add(registerDeleteDmlOperation(record));
		}
		return dmlOperations;
	}

	/**
	 * Register a deleted record to be undeleted in the commitWork method
	 *
	 * @param record A deleted record
	 *
	 * @return DML operation instance
	 */
	public fflib_DmlOperation registerUndeleteDmlOperation(SObject record) {
		if (record.Id == null) {
			throw new UnitOfWorkException(
					'Only previously deleted records can be registered for undeletion.'
			);
		}

		SObjectType sObjectType = record.getSObjectType();
		if (!undeleteSObjectsBySObjectType.containsKey(sObjectType)) {
			throw new UnitOfWorkException(
					'SObjectType ' + sObjectType + ' is not supported by this unit of work.');
		}

		undeleteSObjectsBySObjectType.get(sObjectType).add(record);
		fflib_DmlOperation dmlOperation =
				new fflib_DmlOperation(record, fflib_DatabaseOperation.DATABASE_UNDELETE);
		dmlOperationsByDatabaseOperation.get(fflib_DatabaseOperation.DATABASE_UNDELETE)
				.add(dmlOperation);

		return dmlOperation;
	}

	/**
	 * Register deleted records to be undeleted in the commitWork method
	 *
	 * @param records A list of records to be undeleted
	 *
	 * @return A list of DML operations
	 */
	public List<fflib_DmlOperation> registerUndeleteDmlOperations(List<SObject> records) {
		List<fflib_DmlOperation> dmlOperations = new List<fflib_DmlOperation>();
		for (SObject record : records) {
			dmlOperations.add(registerUndeleteDmlOperation(record));
		}
		return dmlOperations;
	}

	/**
	 * Register a DML Operation to rollback in the commitWork method
	 *
	 * @param dmlOperation A DML operation instance
	 */
	public void registerRollback(fflib_DmlOperation dmlOperation) {
		if (dmlOperation == null) {
			throw new IllegalArgumentException('Invalid DML operation.');
		}
		if (dmlOperation.getDmlOperationResult() == null ||
				!dmlOperation.getDmlOperationResult().isSuccess()) {
			return;
		}

		fflib_DmlOperation rollbackDmlOperation;
		if (dmlOperation.getDatabaseOperation() == fflib_DatabaseOperation.DATABASE_INSERT) {
			rollbackDmlOperation = registerDeleteDmlOperation(dmlOperation.getSObject());
			dmlOperation.setRollbackDmlOperation(rollbackDmlOperation);
		} else if (dmlOperation.getDatabaseOperation() == fflib_DatabaseOperation.DATABASE_UPDATE) {
			rollbackDmlOperation = registerDirtyDmlOperation(dmlOperation.getOriginalSObject());
			dmlOperation.setRollbackDmlOperation(rollbackDmlOperation);
		} else if (dmlOperation.getDatabaseOperation() == fflib_DatabaseOperation.DATABASE_DELETE) {
			rollbackDmlOperation = registerUndeleteDmlOperation(dmlOperation.getSObject());
			dmlOperation.setRollbackDmlOperation(rollbackDmlOperation);
		} else if (dmlOperation.getDatabaseOperation() == fflib_DatabaseOperation.DATABASE_UNDELETE) {
			rollbackDmlOperation = registerDeleteDmlOperation(dmlOperation.getSObject());
			dmlOperation.setRollbackDmlOperation(rollbackDmlOperation);
		}
	}

	/**
	 * Register a list of DML Operations to rollback in the commitWork method
	 *
	 * @param dmlOperations A list of DML operation instances
	 */
	public void registerRollbacks(List<fflib_DmlOperation> dmlOperations) {
		for (fflib_DmlOperation dmlOperation : dmlOperations) {
			registerRollback(dmlOperation);
		}
	}

	/**
     * Takes all the work that has been registered with the UnitOfWork and commits it to the database.
     * Allows for partial success of DML operations so that it does not fail if one of the SObjects fail to be committed.
     **/
	public override void commitWork() {
		doCommitWorkPartialSuccess();
	}

	private void doCommitWorkPartialSuccess() {
		insertDmlByType();
		updateDmlByType();
		deleteDmlByType();
		undeleteDmlByType();
		reset();
	}

	private void insertDmlByType() {
		for (SObjectType type : m_sObjectTypes) {
			String typeName = fflib_SObjectDescribe.getDescribe(type).getDescribe().getName();
			m_relationships.get(typeName).resolve();

			List<SObject> sObjectsToInsert = m_newListByType.get(typeName);
			List<Database.SaveResult> saveResults = partialDml.dmlInsert(sObjectsToInsert);
			List<fflib_DmlOperation> dmlOperations = getDmlOperationsBySObjectType(
					type,
					dmlOperationsByDatabaseOperation.get(fflib_DatabaseOperation.DATABASE_INSERT)
			);
			setDmlOperationResults(saveResults, dmlOperations);
		}
	}

	private List<fflib_DmlOperation> getDmlOperationsBySObjectType(
			SObjectType sObjectType,
			List<fflib_DmlOperation> originalDmlOperations
	) {
		List<fflib_DmlOperation> dmlOperationsToReturn = new List<fflib_DmlOperation>();
		for (fflib_DmlOperation dmlOperation : originalDmlOperations) {
			if (dmlOperation.getSObject().getSObjectType() == sObjectType) {
				dmlOperationsToReturn.add(dmlOperation);
			}
		}

		return dmlOperationsToReturn;
	}

	private void setDmlOperationResults(
			List<Database.SaveResult> saveResults,
			List<fflib_DmlOperation> dmlOperations) {
		for (Integer i = 0; i < saveResults.size(); i++) {
			fflib_DmlOperationResult dmlOperationResult =
					new fflib_DmlOperationResult(saveResults[i]);
			dmlOperations[i].setDmlOperationResult(dmlOperationResult);
		}
	}

	private void updateDmlByType() {
		for (SObjectType type : m_sObjectTypes) {
			String typeName = fflib_SObjectDescribe.getDescribe(type).getDescribe().getName();

			List<SObject> sObjectsToUpdate = m_dirtyMapByType.get(typeName).values();
			List<Database.SaveResult> saveResults = partialDml.dmlUpdate(sObjectsToUpdate);

			List<fflib_DmlOperation> dmlOperations = getDmlOperationsBySObjectType(
					type,
					dmlOperationsByDatabaseOperation.get(fflib_DatabaseOperation.DATABASE_UPDATE)
			);
			setDmlOperationResults(saveResults, dmlOperations);
		}
	}

	private void deleteDmlByType() {
		Integer index = m_sObjectTypes.size() - 1;
		while (index >= 0) {
			SObjectType sObjectType = m_sObjectTypes.get(index--);
			String typeName = fflib_SObjectDescribe.getDescribe(sObjectType).getDescribe().getName();
			List<SObject> sObjectsToDelete = m_deletedMapByType.get(typeName).values();
			List<Database.DeleteResult> deleteResults = partialDml.dmlDelete(sObjectsToDelete);

			List<fflib_DmlOperation> dmlOperations = getDmlOperationsBySObjectType(
					sObjectType,
					dmlOperationsByDatabaseOperation.get(fflib_DatabaseOperation.DATABASE_DELETE)
			);
			setDmlOperationResults(deleteResults, dmlOperations);
		}
	}

	private void setDmlOperationResults(
			List<Database.DeleteResult> deleteResults,
			List<fflib_DmlOperation> dmlOperations) {
		for (Integer i = 0; i < deleteResults.size(); i++) {
			fflib_DmlOperationResult dmlOperationResult =
					new fflib_DmlOperationResult(deleteResults[i]);
			dmlOperations[i].setDmlOperationResult(dmlOperationResult);
		}
	}

	private void undeleteDmlByType() {
		for (SObjectType type : m_sObjectTypes) {
			List<SObject> sObjectsToUndelete = undeleteSObjectsBySObjectType.get(type);
			List<Database.UndeleteResult> undeleteResults = partialDml.dmlUndelete(sObjectsToUndelete);
			List<fflib_DmlOperation> dmlOperations = getDmlOperationsBySObjectType(
					type,
					dmlOperationsByDatabaseOperation.get(fflib_DatabaseOperation.DATABASE_UNDELETE)
			);
			setDmlOperationResults(undeleteResults, dmlOperations);
		}
	}
	private void setDmlOperationResults(
			List<Database.UndeleteResult> undeleteResults,
			List<fflib_DmlOperation> dmlOperations) {
		for (Integer i = 0; i < undeleteResults.size(); i++) {
			fflib_DmlOperationResult dmlOperationResult =
					new fflib_DmlOperationResult(undeleteResults[i]);
			dmlOperations[i].setDmlOperationResult(dmlOperationResult);
		}
	}

	/**
	 * Resets the member variables so that the class can be used as if newly instantiated
	 */
	public override void reset() {
		super.reset();
		initialize();
	}

	/**
	 * Interface for partial DML interactions with the database
	 */
	public interface IPartialDml {

		List<Database.SaveResult> dmlInsert(List<SObject> sObjects);

		List<Database.SaveResult> dmlUpdate(List<SObject> sObjects);

		List<Database.DeleteResult> dmlDelete(List<SObject> sObjects);

		List<Database.UndeleteResult> dmlUndelete(List<SObject> sObjects);
	}

	private class PartialSuccessDml implements IPartialDml {
		public List<Database.SaveResult> dmlInsert(List<SObject> sObjects) {
			return Database.insert(sObjects, false);
		}

		public List<Database.SaveResult> dmlUpdate(List<SObject> sObjects) {
			return Database.update(sObjects, false);
		}

		public List<Database.DeleteResult> dmlDelete(List<SObject> sObjects) {
			return Database.delete(sObjects, false);
		}

		public List<Database.UndeleteResult> dmlUndelete(List<SObject> sObjects) {
			return Database.undelete(sObjects, false);
		}
	}
}
