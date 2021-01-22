@IsTest
private class fflib_DmlOperationTest {

	@IsTest
	static void constructor_Arguments_NewInstance() {
		// Arrange
		SObject account = new Account();

		// Act
		Test.startTest();
		fflib_DmlOperation dmlOperation = new fflib_DmlOperation(
				account,
				fflib_DatabaseOperation.DATABASE_INSERT
		);
		Test.stopTest();

		// Assert
		System.assertNotEquals(null, dmlOperation);
	}

	@IsTest
	static void constructor_NullSObject_ThrowException() {
		// Arrange
		Exception thrownException;

		// Act
		Test.startTest();
		try {
			new fflib_DmlOperation(null, fflib_DatabaseOperation.DATABASE_DELETE);
		} catch (Exception e) {
			thrownException = e;
		}
		Test.stopTest();

		// Assert
		System.assert(thrownException instanceof IllegalArgumentException);
		System.assertEquals('Invalid SObject.', thrownException.getMessage());
	}

	@IsTest
	static void getDatabaseOperation_DatabaseOperationIsSet_ReturnDatabaseOperation() {
		// Arrange
		fflib_DatabaseOperation databaseOperation = fflib_DatabaseOperation.DATABASE_INSERT;
		fflib_DmlOperation dmlOperation = new fflib_DmlOperation(new Account(), databaseOperation);

		// Act
		Test.startTest();
		fflib_DatabaseOperation actualDatabaseOperation = dmlOperation.getDatabaseOperation();
		Test.stopTest();

		// Assert
		System.assertEquals(databaseOperation, actualDatabaseOperation);
	}

	@IsTest
	static void getSObject_SObjectIsSet_ReturnSObject() {
		// Arrange
		SObject account = new Account();
		fflib_DmlOperation dmlOperation = new fflib_DmlOperation(
				account,
				fflib_DatabaseOperation.DATABASE_INSERT
		);

		// Act
		Test.startTest();
		SObject actualSObject = dmlOperation.getSObject();
		Test.stopTest();

		// Assert
		System.assertEquals(account, actualSObject);
	}

	@IsTest
	static void getOriginalSObject_SObject_ReturnOriginalSObject() {
		// Arrange
		SObject account = new Account(Name = 'test');
		SObject originalAccount = account.clone();
		fflib_DatabaseOperation databaseOperation = fflib_DatabaseOperation.DATABASE_INSERT;

		fflib_DmlOperation dmlOperation = new fflib_DmlOperation(account, databaseOperation);
		account.put('Name', 'Changed');
		dmlOperation.setOriginalSObject(originalAccount);

		// Act
		Test.startTest();
		SObject actualSObjectToRollback = dmlOperation.getOriginalSObject();
		Test.stopTest();

		// Assert
		System.assertNotEquals(account, actualSObjectToRollback);
		System.assertEquals(originalAccount, actualSObjectToRollback);
	}

	@IsTest
	static void getDmlOperationResult_DmlOperationResultIsSet_ReturnDmlOperationResult() {
		// Arrange
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_DmlOperationResult mockOperationResult =
				(fflib_DmlOperationResult)mocks.mock(fflib_DmlOperationResult.class);

		fflib_DmlOperation dmlOperation =
				new fflib_DmlOperation(new Account(), fflib_DatabaseOperation.DATABASE_INSERT);
		dmlOperation.setDmlOperationResult(mockOperationResult);

		// Act
		Test.startTest();
		fflib_DmlOperationResult actualDmlOperationResult = dmlOperation.getDmlOperationResult();
		Test.stopTest();

		// Assert
		System.assertEquals(mockOperationResult, actualDmlOperationResult);
	}

	@IsTest
	static void getRollbackDmlOperation_DmlOperationIsSet_ReturnDmlOperation() {
		// Arrange
		fflib_DmlOperation rollbackDmlOperation = new fflib_DmlOperation(new Account(), null);
		fflib_DmlOperation dmlOperation = new fflib_DmlOperation(new Account(), null);
		dmlOperation.setRollbackDmlOperation(rollbackDmlOperation);

		// Act
		Test.startTest();
		fflib_DmlOperation actualDmlOperation = dmlOperation.getRollbackDmlOperation();
		Test.stopTest();

		// Assert
		System.assertEquals(rollbackDmlOperation, actualDmlOperation);
	}
}