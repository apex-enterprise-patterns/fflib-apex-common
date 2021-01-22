@IsTest
private class fflib_DatabaseOperationTest {

	@IsTest
	static void databaseOperations_DatabaseOperations_ReturnDatabaseOperations() {
		// Assert
		System.assertEquals('DATABASE_INSERT', fflib_DatabaseOperation.DATABASE_INSERT.name());
		System.assertEquals('DATABASE_UPDATE', fflib_DatabaseOperation.DATABASE_UPDATE.name());
		System.assertEquals('DATABASE_DELETE', fflib_DatabaseOperation.DATABASE_DELETE.name());
		System.assertEquals('DATABASE_UNDELETE', fflib_DatabaseOperation.DATABASE_UNDELETE.name());
	}
}