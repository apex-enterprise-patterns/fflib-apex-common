/*
* This class serves as a container of DML operations performed on the database.
*
* The purpose of this is to keep track of what operations have been committed to the database
* and their results. This way, when the commitWork method of the UnitOfWorkPartialSuccess class is called,
* the caller will receive back a container of what happened with the committal of the work such as
* the SObject the operation was performed on, the result of the committal, and the ability to mark
* the DML operation for a rollback if the committal were to fail.
 */

public with sharing class fflib_DmlOperation {

	private final fflib_DatabaseOperation databaseOperation;
	private final SObject record;
	private SObject originalRecord;
	private fflib_DmlOperationResult dmlOperationResult;
	private fflib_DmlOperation rollbackDmlOperation;

	/**
	 * Constructs a new instance of a DmlOperation for tracking DML Operations from UnitOfWork
	 *
	 * @param record SObject to construct this instance with
	 * @param databaseOperation DatabaseOperation to construct this instance with
	 */
	public fflib_DmlOperation(SObject record, fflib_DatabaseOperation databaseOperation) {
		if (record == null) {
			throw new IllegalArgumentException('Invalid SObject.');
		}
		this.databaseOperation = databaseOperation;
		this.record = record;
	}

	/**
	 * Gets Database Operation this class was constructed with
	 *
	 * @return Database operation
	 */
	public fflib_DatabaseOperation getDatabaseOperation() {
		return databaseOperation;
	}

	/**
	 * Gets SObject reference this class was constructed with
	 *
	 * @return SObject
	 */
	public SObject getSObject() {
		return record;
	}

	/**
	 * Gets original SObject that was set
	 *
	 * @return Original SObject
	 */
	public SObject getOriginalSObject() {
		return originalRecord;
	}

	/**
	 * Sets original SObject for update rollback purposes
	 *
	 * @param record SObject to rollback to
	 */
	public void setOriginalSObject(SObject record) {
		this.originalRecord = record;
	}

	/**
	 * Sets DML Operation Result that occurs after commitWork is called from a unit of work
	 *
	 * @param dmlOperationResult DML Operation Result to set
	 */
	public void setDmlOperationResult(fflib_DmlOperationResult dmlOperationResult) {
		this.dmlOperationResult = dmlOperationResult;
	}

	/**
	 * Gets the DML Operation Result that was set
	 *
	 * @return DML Operation Result
	 */
	public fflib_DmlOperationResult getDmlOperationResult() {
		return dmlOperationResult;
	}

	/**
	 * Sets Rollback DML Operation for rolling back the parent DML operation
	 *
	 * @param dmlOperation DML Operation to set
	 */
	public void setRollbackDmlOperation(fflib_DmlOperation rollbackDmlOperation) {
		this.rollbackDmlOperation = rollbackDmlOperation;
	}

	/**
	 * Gets the rollback DML Operation that was set
	 *
	 * @return DML operation
	 */
	public fflib_DmlOperation getRollbackDmlOperation() {
		return rollbackDmlOperation;
	}
}