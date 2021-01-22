/*
* This class serves as a container of the result of a DML operation.
*
* This class generisizes the use of the plethora of DML result classes that are a part of Apex such as
* SaveResult, DeleteResult, and UndeleteResult
 */

public with sharing class fflib_DmlOperationResult {

	private final Id recordId;
	private final Boolean success;
	private final List<Database.Error> errors;

	/**
	 * Constructs a new DML operation result from a result of an insert or update database transaction
	 *
	 * @param saveResult Save result from a database transaction
	 */
	public fflib_DmlOperationResult(Database.SaveResult saveResult) {
		this(saveResult.getId(), saveResult.isSuccess(), saveResult.getErrors());
	}

	/**
	 * Constructs a new DML operation result from a result of a delete database transaction
	 *
	 * @param saveResult Delete result from a database transaction
	 */
	public fflib_DmlOperationResult(Database.DeleteResult deleteResult) {
		this(deleteResult.getId(), deleteResult.isSuccess(), deleteResult.getErrors());
	}

	/**
	 * Constructs a new DML operation result from a result of an undelete database transaction
	 *
	 * @param saveResult Undelete result from a database transaction
	 */
	public fflib_DmlOperationResult(Database.UndeleteResult undeleteResult) {
		this(undeleteResult.getId(), undeleteResult.isSuccess(), undeleteResult.getErrors());
	}

	/**
	 * Constructs a DML operation result
	 *
	 * @param recordId Id of an SObject
	 * @param success Boolean if result was successful or not
	 * @param errors List of database errors from a database transaction
	 */
	public fflib_DmlOperationResult(Id recordId, Boolean success, List<Database.Error> errors) {
		this.recordId = recordId;
		this.success = success;
		this.errors = errors;
	}

	/**
	 * Returns SObject Id this class was constructed with
	 *
	 * @return SObject Id
	 */
	public Id getId() {
		return recordId;
	}

	/**
	 * Returns boolean this class was constructed with
	 *
	 * @return success boolean
	 */
	public Boolean isSuccess() {
		return success;
	}

	/**
	 * Returns database errors this class was constructed with
	 *
	 * @return Database errors from a database transaction
	 */
	public List<Database.Error> getErrors() {
		return errors;
	}
}