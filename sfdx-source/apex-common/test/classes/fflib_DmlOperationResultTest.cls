@IsTest
private class fflib_DmlOperationResultTest {

	@IsTest
	static void constructor_SaveResult_NewInstance() {
		// Arrange
		Database.SaveResult saveResult = (Database.SaveResult)JSON.deserialize(
				'{"success":true,"id":"0013000000abcde"}', Database.SaveResult.class);

		// Act
		Test.startTest();
		fflib_DmlOperationResult dmlOperationResult = new fflib_DmlOperationResult(saveResult);
		Test.stopTest();

		// Assert
		System.assertNotEquals(null, dmlOperationResult);
	}

	@IsTest
	static void constructor_DeleteResult_NewInstance() {
		// Arrange
		Database.DeleteResult deleteResult = (Database.DeleteResult)JSON.deserialize(
				'{"success":true,"id":"0013000000abcde"}', Database.DeleteResult.class);

		// Act
		Test.startTest();
		fflib_DmlOperationResult dmlOperationResult = new fflib_DmlOperationResult(deleteResult);
		Test.stopTest();

		// Assert
		System.assertNotEquals(null, dmlOperationResult);
	}

	@IsTest
	static void constructor_UndeleteResult_NewInstance() {
		// Arrange
		Database.UndeleteResult undeleteResult = (Database.UndeleteResult)JSON.deserialize(
				'{"success":true,"id":"0013000000abcde"}', Database.UndeleteResult.class);

		// Act
		Test.startTest();
		fflib_DmlOperationResult dmlOperationResult = new fflib_DmlOperationResult(undeleteResult);
		Test.stopTest();

		// Assert
		System.assertNotEquals(null, dmlOperationResult);
	}

	@IsTest
	static void getId_SaveResult_ReturnId() {
		// Arrange
		Id sObjectId = fflib_IDGenerator.generate(Account.getSObjectType());
		Database.SaveResult saveResult = (Database.SaveResult)JSON.deserialize(
				'{"success":true,"id":"' + sObjectId + '"}', Database.SaveResult.class);

		fflib_DmlOperationResult dmlOperationResult = new fflib_DmlOperationResult(saveResult);

		// Act
		Test.startTest();
		Id actualId = dmlOperationResult.getId();
		Test.stopTest();

		// Assert
		System.assertEquals(sObjectId, actualId);
	}

	@IsTest
	static void getId_DeleteResult_ReturnId() {
		// Arrange
		Id sObjectId = fflib_IDGenerator.generate(Account.getSObjectType());
		Database.DeleteResult deleteResult = (Database.DeleteResult)JSON.deserialize(
				'{"success":true,"id":"' + sObjectId + '"}', Database.DeleteResult.class);

		fflib_DmlOperationResult dmlOperationResult = new fflib_DmlOperationResult(deleteResult);

		// Act
		Test.startTest();
		Id actualId = dmlOperationResult.getId();
		Test.stopTest();

		// Assert
		System.assertEquals(sObjectId, actualId);
	}

	@IsTest
	static void getId_UndeleteResult_ReturnId() {
		// Arrange
		Id sObjectId = fflib_IDGenerator.generate(Account.getSObjectType());
		Database.UndeleteResult undeleteResult = (Database.UndeleteResult)JSON.deserialize(
				'{"success":true,"id":"' + sObjectId + '"}', Database.UndeleteResult.class);

		fflib_DmlOperationResult dmlOperationResult = new fflib_DmlOperationResult(undeleteResult);

		// Act
		Test.startTest();
		Id actualId = dmlOperationResult.getId();
		Test.stopTest();

		// Assert
		System.assertEquals(sObjectId, actualId);
	}

	@IsTest
	static void isSuccess_SuccessfulSaveResult_ReturnTrue() {
		// Arrange
		Boolean success = true;
		Database.SaveResult saveResult = (Database.SaveResult)JSON.deserialize(
				'{"success":' + success + ',"id":""}', Database.SaveResult.class);

		fflib_DmlOperationResult dmlOperationResult = new fflib_DmlOperationResult(saveResult);

		// Act
		Test.startTest();
		Boolean isSuccess = dmlOperationResult.isSuccess();
		Test.stopTest();

		// Assert
		System.assert(isSuccess);
	}

	@IsTest
	static void isSuccess_UnsuccessfulSaveResult_ReturnFalse() {
		// Arrange
		Boolean success = false;
		Database.SaveResult saveResult = (Database.SaveResult)JSON.deserialize(
				'{"success":' + success + ',"id":""}', Database.SaveResult.class);

		fflib_DmlOperationResult dmlOperationResult = new fflib_DmlOperationResult(saveResult);

		// Act
		Test.startTest();
		Boolean isSuccess = dmlOperationResult.isSuccess();
		Test.stopTest();

		// Assert
		System.assert(!isSuccess);
	}

	@IsTest
	static void isSuccess_SuccessfulDeleteResult_ReturnTrue() {
		// Arrange
		Boolean success = true;
		Database.DeleteResult deleteResult = (Database.DeleteResult)JSON.deserialize(
				'{"success":' + success + ',"id":""}', Database.DeleteResult.class);

		fflib_DmlOperationResult dmlOperationResult = new fflib_DmlOperationResult(deleteResult);

		// Act
		Test.startTest();
		Boolean isSuccess = dmlOperationResult.isSuccess();
		Test.stopTest();

		// Assert
		System.assert(isSuccess);
	}

	@IsTest
	static void isSuccess_UnsuccessfulDeleteResult_ReturnFalse() {
		// Arrange
		Boolean success = false;
		Database.DeleteResult deleteResult = (Database.DeleteResult)JSON.deserialize(
				'{"success":' + success + ',"id":""}', Database.DeleteResult.class);

		fflib_DmlOperationResult dmlOperationResult = new fflib_DmlOperationResult(deleteResult);

		// Act
		Test.startTest();
		Boolean isSuccess = dmlOperationResult.isSuccess();
		Test.stopTest();

		// Assert
		System.assert(!isSuccess);
	}

	@IsTest
	static void isSuccess_SuccessfulUndeleteResult_ReturnTrue() {
		// Arrange
		Boolean success = true;
		Database.UndeleteResult undeleteResult = (Database.UndeleteResult)JSON.deserialize(
				'{"success":' + success + ',"id":""}', Database.UndeleteResult.class);

		fflib_DmlOperationResult dmlOperationResult = new fflib_DmlOperationResult(undeleteResult);

		// Act
		Test.startTest();
		Boolean isSuccess = dmlOperationResult.isSuccess();
		Test.stopTest();

		// Assert
		System.assert(isSuccess);
	}

	@IsTest
	static void isSuccess_UnsuccessfulUndeleteResult_ReturnFalse() {
		// Arrange
		Boolean success = false;
		Database.UndeleteResult undeleteResult = (Database.UndeleteResult)JSON.deserialize(
				'{"success":' + success + ',"id":""}', Database.UndeleteResult.class);

		fflib_DmlOperationResult dmlOperationResult = new fflib_DmlOperationResult(undeleteResult);

		// Act
		Test.startTest();
		Boolean isSuccess = dmlOperationResult.isSuccess();
		Test.stopTest();

		// Assert
		System.assert(!isSuccess);
	}

	@IsTest
	static void getErrors_SaveResultWithErrors_ReturnErrors() {
		// Arrange
		Database.SaveResult saveResult = (Database.SaveResult)JSON.deserialize(
				'{' +
						'"success":false,' +
						'"errors":[' +
						'{' +
						'"message":"You cannot do this...",' +
						'"statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"' +
						'}' +
						']' +
						'}',
				Database.SaveResult.class);

		fflib_DmlOperationResult dmlOperationResult = new fflib_DmlOperationResult(saveResult);

		// Act
		Test.startTest();
		List<Database.Error> actualErrors = dmlOperationResult.getErrors();
		Test.stopTest();

		// Assert
		System.assertEquals(saveResult.getErrors(), actualErrors);
	}

	@IsTest
	static void getErrors_DeleteResultWithErrors_ReturnErrors() {
		// Arrange
		Database.DeleteResult deleteResult = (Database.DeleteResult)JSON.deserialize(
				'{' +
						'"success":false,' +
						'"errors":[' +
						'{' +
						'"message":"You cannot do this...",' +
						'"statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"' +
						'}' +
						']' +
						'}',
				Database.DeleteResult.class);

		fflib_DmlOperationResult dmlOperationResult = new fflib_DmlOperationResult(deleteResult);

		// Act
		Test.startTest();
		List<Database.Error> actualErrors = dmlOperationResult.getErrors();
		Test.stopTest();

		// Assert
		System.assertEquals(deleteResult.getErrors(), actualErrors);
	}

	@IsTest
	static void getErrors_UndeleteResultWithErrors_ReturnErrors() {
		// Arrange
		Database.UndeleteResult undeleteResult = (Database.UndeleteResult)JSON.deserialize(
				'{' +
						'"success":false,' +
						'"errors":[' +
						'{' +
						'"message":"You cannot do this...",' +
						'"statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"' +
						'}' +
						']' +
						'}',
				Database.UndeleteResult.class);

		fflib_DmlOperationResult dmlOperationResult = new fflib_DmlOperationResult(undeleteResult);

		// Act
		Test.startTest();
		List<Database.Error> actualErrors = dmlOperationResult.getErrors();
		Test.stopTest();

		// Assert
		System.assertEquals(undeleteResult.getErrors(), actualErrors);
	}
}