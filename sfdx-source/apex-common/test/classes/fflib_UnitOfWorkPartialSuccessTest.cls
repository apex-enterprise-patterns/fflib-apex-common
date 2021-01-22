@IsTest
private class fflib_UnitOfWorkPartialSuccessTest {

	@IsTest
	static void registerNew_SObject_ReturnDmlOperationWithSObject() {
		// Arrange
		SObject account = new Account(Name = 'test');

		fflib_UnitOfWorkPartialSuccess unitOfWork =
				new fflib_UnitOfWorkPartialSuccess(new List<SObjectType> {Account.getSObjectType()});

		// Act
		Test.startTest();
		fflib_DmlOperation actualDmlOperation = unitOfWork.registerNewDmlOperation(account);
		Test.stopTest();

		// Assert
		System.assertEquals(account, actualDmlOperation.getSObject());
	}

	@IsTest
	static void registerNew_SObjectContainsId_ThrowException() {
		// Arrange
		fflib_UnitOfWorkPartialSuccess unitOfWork =
				new fflib_UnitOfWorkPartialSuccess(new List<SObjectType> {Account.getSObjectType()});
		Account testAccount = new Account(Id = fflib_IDGenerator.generate(Account.getSObjectType()));

		Exception thrownException;

		// Act
		Test.startTest();
		try {
			unitOfWork.registerNewDmlOperation(testAccount);
		} catch (Exception e) {
			thrownException = e;
		}
		Test.stopTest();

		// Assert
		System.assert(thrownException instanceof fflib_SObjectUnitOfWork.UnitOfWorkException);
		System.assertEquals('Only new records can be registered as new.',
				thrownException.getMessage());
	}

	@IsTest
	static void registerNew_SObjectNotOfRegisteredType_ThrowException() {
		// Arrange
		fflib_UnitOfWorkPartialSuccess unitOfWork =
				new fflib_UnitOfWorkPartialSuccess(new List<SObjectType> {Account.getSObjectType()});
		Contact testContact = new Contact();

		Exception thrownException;

		// Act
		Test.startTest();
		try {
			unitOfWork.registerNewDmlOperation(testContact);
		} catch (Exception e) {
			thrownException = e;
		}
		Test.stopTest();

		// Assert
		System.assert(thrownException instanceof fflib_SObjectUnitOfWork.UnitOfWorkException);
		System.assertEquals('SObjectType Contact is not supported by this unit of work.',
				thrownException.getMessage());
	}

	@IsTest
	static void commitWork_InvalidAccount_ReturnDmlOperationResult() {
		// Arrange
		List<Account> accounts = new List<Account>();
		accounts.add(new Account());

		fflib_UnitOfWorkPartialSuccess unitOfWork = new fflib_UnitOfWorkPartialSuccess(
				new List<SObjectType> {Account.getSObjectType()}
		);
		List<fflib_DmlOperation> dmlOperations = unitOfWork.registerNewDmlOperations(accounts);

		// Act
		Test.startTest();
		unitOfWork.commitWork();
		Test.stopTest();

		// Assert
		Integer numAccounts = [SELECT COUNT() FROM Account];

		System.assertEquals(0, numAccounts);
		System.assertEquals(1, dmlOperations.size());
		System.assert(!dmlOperations[0].getDmlOperationResult().isSuccess());
	}

	@IsTest
	static void commitWork_MultipleSObjectTypes_ReturnDmlOperationResults() {
		// Arrange
		List<SObject> sobjects = new List<SObject>();
		sobjects.add(new Contact(LastName = 'test'));
		sobjects.add(new Account(Name = 'test'));

		List<SObjectType> types = new List<SObjectType> {
				Account.getSObjectType(),
				Contact.getsObjectType()
		};
		fflib_UnitOfWorkPartialSuccess unitOfWork = new fflib_UnitOfWorkPartialSuccess(types);
		List<fflib_DmlOperation> dmlOperations = unitOfWork.registerNewDmlOperations(sobjects);

		// Act
		Test.startTest();
		unitOfWork.commitWork();
		Test.stopTest();

		// Assert
		Integer numInsertedAccounts = [SELECT COUNT() FROM Account];
		Integer numInsertedContacts = [SELECT COUNT() FROM Contact];

		System.assertEquals(1, numInsertedAccounts);
		System.assertEquals(1, numInsertedContacts);
		System.assertEquals(2, dmlOperations.size());
		for (Integer i = 0; i < dmlOperations.size() - 1; i++) {
			System.assert(sobjects.contains(dmlOperations[i].getSObject()));
			System.debug(dmlOperations[i].getDmlOperationResult());
			System.assert(dmlOperations[i].getDmlOperationResult().isSuccess());
		}
	}

	@IsTest
	static void commitWork_MultipleSObjectTypesInOppositeOrder_DmlOperationsContainCorrectResults() {
		// Arrange
		List<SObjectType> sObjectTypes = new List<SObjectType> {
				Account.getSObjectType(),
				Contact.getSObjectType()
		};
		fflib_UnitOfWorkPartialSuccess unitOfWork = new fflib_UnitOfWorkPartialSuccess(sObjectTypes);

		Contact contact = new Contact(LastName = 'test');
		fflib_DmlOperation contactDmlOperation = unitOfWork.registerNewDmlOperation(contact);
		Account account = new Account(Name = 'test');
		fflib_DmlOperation accountDmlOperation = unitOfWork.registerNewDmlOperation(account);

		// Act
		Test.startTest();
		unitOfWork.commitWork();
		Test.stopTest();

		// Assert
		System.assert(contactDmlOperation.getDmlOperationResult().isSuccess());
		System.assertEquals(contact.Id, contactDmlOperation.getDmlOperationResult().getId());
		System.assert(accountDmlOperation.getDmlOperationResult().isSuccess());
		System.assertEquals(account.Id, accountDmlOperation.getDmlOperationResult().getId());
	}

	@IsTest
	static void registerDirtyDmlOperation_SObject_ReturnUpdateDmlOperation() {
		// Arrange
		Account account = new Account(Name = 'test');
		account.Id = fflib_IDGenerator.generate(Account.getSObjectType());

		fflib_UnitOfWorkPartialSuccess unitOfWork =
				new fflib_UnitOfWorkPartialSuccess(new List<SObjectType> {Account.getSObjectType()});

		// Act
		Test.startTest();
		fflib_DmlOperation actualDmlOperation =
				unitOfWork.registerDirtyDmlOperation(account);
		Test.stopTest();

		// Assert
		System.assertEquals(fflib_DatabaseOperation.DATABASE_UPDATE,
				actualDmlOperation.getDatabaseOperation());
		System.assertEquals(account, actualDmlOperation.getSObject());
	}

	@IsTest
	static void registerDirtyDmlOperation_MultipleSObjects_ReturnMultipleUpdateDmlOperation() {
		// Arrange
		Id accountId = fflib_IDGenerator.generate(Account.getSObjectType());
		Account account = new Account(Id = accountId, Name = 'test');
		Account account2 = new Account(Id = accountId, Name = 'test2');
		List<SObject> sObjects = new List<SObject> {account, account2};

		fflib_UnitOfWorkPartialSuccess unitOfWork =
				new fflib_UnitOfWorkPartialSuccess(new List<SObjectType> {Account.getSObjectType()});

		// Act
		Test.startTest();
		List<fflib_DmlOperation> actualDmlOperations =
				unitOfWork.registerDirtyDmlOperations(sObjects);
		Test.stopTest();

		// Assert
		System.assertEquals(2, actualDmlOperations.size());
		for (fflib_DmlOperation dmlOperation : actualDmlOperations) {
			System.assert(sObjects.contains(dmlOperation.getSObject()));
		}
	}

	@IsTest
	static void registerDirtyDmlOperation_NewSObject_ThrowException() {
		// Arrange
		fflib_UnitOfWorkPartialSuccess unitOfWork =
				new fflib_UnitOfWorkPartialSuccess(new List<SObjectType> {Account.getSObjectType()});
		Exception thrownException;

		// Act
		Test.startTest();
		try {
			unitOfWork.registerDirtyDmlOperation(new Account());
		} catch (Exception e) {
			thrownException = e;
		}
		Test.stopTest();

		// Assert
		System.assert(thrownException instanceof fflib_SObjectUnitOfWork.UnitOfWorkException);
		System.assertEquals('Only existing records can be registered as dirty.',
				thrownException.getMessage());
	}

	@IsTest
	static void registerDirtyDmlOperation_SObjectUnsupportedType_ThrowException() {
		// Arrange
		fflib_UnitOfWorkPartialSuccess unitOfWork =
				new fflib_UnitOfWorkPartialSuccess(new List<SObjectType> {Account.getSObjectType()});
		Exception thrownException;

		// Act
		Test.startTest();
		try {
			unitOfWork.registerDirtyDmlOperation(
					new Contact(Id = fflib_IDGenerator.generate(Contact.getSObjectType()))
			);
		} catch (Exception e) {
			thrownException = e;
		}
		Test.stopTest();

		// Assert
		System.assert(thrownException instanceof fflib_SObjectUnitOfWork.UnitOfWorkException);
		System.assertEquals('SObjectType Contact is not supported by this unit of work.',
				thrownException.getMessage());
	}

	@IsTest
	static void commitWork_SObjectIsRegisteredDirty_SObjectIsUpdated() {
		// Arrange
		Account updateAccount = new Account(Name = 'test');
		insert updateAccount;
		updateAccount.Name = 'Changed';

		fflib_UnitOfWorkPartialSuccess unitOfWork =
				new fflib_UnitOfWorkPartialSuccess(new List<SObjectType> {Account.getSObjectType()});
		fflib_DmlOperation dmlOperation = unitOfWork.registerDirtyDmlOperation(updateAccount);

		// Act
		Test.startTest();
		unitOfWork.commitWork();
		Test.stopTest();

		// Assert
		List<Account> updatedAccounts = [SELECT Name FROM Account];

		System.assertEquals(1, updatedAccounts.size());
		System.assertEquals('Changed', updatedAccounts[0].Name);
		System.assert(dmlOperation.getDmlOperationResult().isSuccess());
	}

	@IsTest
	static void commitWork_MultipleSObjectIsRegisteredDirty_SObjectIsUpdated() {
		// Arrange
		Account updateAccount = new Account(Name = 'test');
		Account updateAccount2 = new Account(Name = 'test2');
		List<SObject> sObjects = new List<SObject> {updateAccount, updateAccount2};
		insert sObjects;

		updateAccount.Name = 'Changed';
		updateAccount2.Name = 'Changed2';

		fflib_UnitOfWorkPartialSuccess unitOfWork =
				new fflib_UnitOfWorkPartialSuccess(new List<SObjectType> {Account.getSObjectType()});
		List<fflib_DmlOperation> dmlOperations = unitOfWork.registerDirtyDmlOperations(sObjects);

		// Act
		Test.startTest();
		unitOfWork.commitWork();
		Test.stopTest();

		// Assert
		List<Account> updatedAccounts = [SELECT Name FROM Account];

		System.assertEquals(2, updatedAccounts.size());
		for (Account updatedAccount : updatedAccounts) {
			System.assert(updatedAccount.Name.contains('Changed'));
		}
		for (fflib_DmlOperation dmlOperation : dmlOperations) {
			System.assert(dmlOperation.getDmlOperationResult().isSuccess());
		}
	}

	@IsTest
	static void commitWork_UpdateSObjectRelationship_SObjectIsUpdated() {
		// Arrange
		Account updateAccount = new Account(Name = 'test');
		Contact updateContact = new Contact(LastName = 'test');
		List<SObject> sObjects = new List<SObject> {updateAccount, updateContact};
		insert sObjects;

		List<SObjectType> sObjectTypes = new List<SObjectType> {
				Account.getSObjectType(),
				Contact.getSObjectType()
		};
		fflib_UnitOfWorkPartialSuccess unitOfWork = new fflib_UnitOfWorkPartialSuccess(sObjectTypes);
		fflib_DmlOperation dmlOperation =
				unitOfWork.registerDirtyDmlOperation(updateContact, Contact.AccountId, updateAccount);

		// Act
		Test.startTest();
		unitOfWork.commitWork();
		Test.stopTest();

		// Assert
		List<Account> insertedAccounts = [SELECT Id FROM Account];
		List<Contact> updatedContacts = [SELECT AccountId FROM Contact];

		System.assertEquals(1, updatedContacts.size());
		System.assertEquals(1, insertedAccounts.size());
		System.assertEquals(insertedAccounts[0].Id, updatedContacts[0].AccountId);
		System.assert(dmlOperation.getDmlOperationResult().isSuccess());
	}

	@IsTest
	static void commitWork_InsertSObjectAndUpdateDifferentSObject_BothAreCommitted() {
		// Arrange
		List<SObjectType> sObjectTypes = new List<SObjectType> {
				Account.getSObjectType(),
				Contact.getSObjectType()
		};
		fflib_UnitOfWorkPartialSuccess unitOfWork = new fflib_UnitOfWorkPartialSuccess(sObjectTypes);

		Account account = new Account(Name = 'test');
		fflib_DmlOperation insertDmlOperation = unitOfWork.registerNewDmlOperation(account);
		Contact contact = new Contact(LastName = 'test');
		insert contact;
		contact.LastName = 'Changed';
		fflib_DmlOperation updateDmlOperation = unitOfWork.registerDirtyDmlOperation(contact);

		// Act
		Test.startTest();
		unitOfWork.commitWork();
		Test.stopTest();

		// Assert
		List<Account> inserteAccounts = [SELECT Id FROM Account];
		List<Contact> updatedContacts = [SELECT LastName FROM Contact];

		System.assertEquals(1, inserteAccounts.size());
		System.assertEquals(1, updatedContacts.size());
		System.assertEquals('Changed', updatedContacts[0].LastName);
		System.assert(insertDmlOperation.getDmlOperationResult().isSuccess());
		System.assert(updateDmlOperation.getDmlOperationResult().isSuccess());
	}

	@IsTest
	static void reset_SObjectIsRegistered_NothingIsCommitted() {
		// Arrange
		Account newAccount = new Account(Name = 'test');

		fflib_UnitOfWorkPartialSuccess unitOfWork =
				new fflib_UnitOfWorkPartialSuccess(new List<SObjectType> {Account.getSObjectType()});
		fflib_DmlOperation dmlOperation = unitOfWork.registerNewDmlOperation(newAccount);

		// Act
		Test.startTest();
		unitOfWork.reset();
		unitOfWork.commitWork();
		Test.stopTest();

		// Assert
		List<Account> insertedAccounts = [SELECT Id FROM Account];
		System.assert(insertedAccounts.isEmpty());
	}

	@IsTest
	static void commitWork_UnitOfWorkIsResetAndNewSOjectIsRegistered_SObjectIsInserted() {
		// Arrange
		Account newAccount = new Account(Name = 'test');

		fflib_UnitOfWorkPartialSuccess unitOfWork =
				new fflib_UnitOfWorkPartialSuccess(new List<SObjectType> {Account.getSObjectType()});
		fflib_DmlOperation dmlOperation = unitOfWork.registerNewDmlOperation(newAccount);
		unitOfWork.reset();

		unitOfWork.registerNewDmlOperation(newAccount);

		// Act
		Test.startTest();
		unitOfWork.commitWork();
		Test.stopTest();

		// Assert
		List<Account> insertedAccounts = [SELECT Id FROM Account];
		System.assertEquals(1, insertedAccounts.size());
	}

	@IsTest
	static void registerDeleteDmlOperation_SObjectToDelete_ReturnDeleteDmlOperation() {
		// Arrange
		Id accountId = fflib_IDGenerator.generate(Account.getSObjectType());
		Account existingAccount = new Account(Id = accountId);

		fflib_UnitOfWorkPartialSuccess unitOfWork =
				new fflib_UnitOfWorkPartialSuccess(new List<SObjectType> {Account.getSObjectType()});

		// Act
		Test.startTest();
		fflib_DmlOperation dmlOperation = unitOfWork.registerDeleteDmlOperation(existingAccount);
		Test.stopTest();

		// Assert
		System.assertEquals(fflib_DatabaseOperation.DATABASE_DELETE,
				dmlOperation.getDatabaseOperation());
	}

	@IsTest
	static void registerDeleteDmlOperations_MultipleSObjectToDelete_ReturnDeleteDmlOperations() {
		// Arrange
		Id accountId = fflib_IDGenerator.generate(Account.getSObjectType());
		Account existingAccount = new Account(Id = accountId);
		Account existingAccount2 = new Account(Id = accountId);
		List<Account> accounts = new List<Account> {existingAccount, existingAccount2};

		fflib_UnitOfWorkPartialSuccess unitOfWork =
				new fflib_UnitOfWorkPartialSuccess(new List<SObjectType> {Account.getSObjectType()});

		// Act
		Test.startTest();
		List<fflib_DmlOperation> dmlOperations = unitOfWork.registerDeleteDmlOperations(accounts);
		Test.stopTest();

		// Assert
		System.assertEquals(2, dmlOperations.size());
		for (fflib_DmlOperation dmlOperation : dmlOperations) {
			System.assertEquals(fflib_DatabaseOperation.DATABASE_DELETE,
					dmlOperation.getDatabaseOperation());
		}
	}

	@IsTest
	static void registerDeleteDmlOperation_RecordWithoutId_ThrowException() {
		// Arrange
		fflib_UnitOfWorkPartialSuccess unitOfWorkPartialSuccess =
				new fflib_UnitOfWorkPartialSuccess(new List<SObjectType>());
		Exception thrownException;

		// Act
		Test.startTest();
		try {
			unitOfWorkPartialSuccess.registerDeleteDmlOperation(new Account());
		} catch (Exception e) {
			thrownException = e;
		}
		Test.stopTest();

		// Assert
		System.assert(thrownException instanceof fflib_SObjectUnitOfWork.UnitOfWorkException);
		System.assertEquals('Only existing records can be registered for deletion.',
				thrownException.getMessage());
	}

	@IsTest
	static void registerDeleteDmlOperation_UnregisteredSObjectType_ThrowException() {
		// Arrange
		fflib_UnitOfWorkPartialSuccess unitOfWorkPartialSuccess =
				new fflib_UnitOfWorkPartialSuccess(new List<SObjectType>());
		Exception thrownException;

		// Act
		Test.startTest();
		try {
			Id accountId = fflib_IDGenerator.generate(Account.getSObjectType());
			unitOfWorkPartialSuccess.registerDeleteDmlOperation(new Account(Id = accountId));
		} catch (Exception e) {
			thrownException = e;
		}
		Test.stopTest();

		// Assert
		System.assert(thrownException instanceof fflib_SObjectUnitOfWork.UnitOfWorkException);
		System.assertEquals('SObjectType Account is not supported by this unit of work.',
				thrownException.getMessage());
	}

	@IsTest
	static void commitWork_SObjectRegisteredToBeDeleted_SObjectIsDeleted() {
		// Arrange
		Account newAccount = new Account(Name = 'test');
		insert newAccount;

		fflib_UnitOfWorkPartialSuccess unitOfWork =
				new fflib_UnitOfWorkPartialSuccess(new List<SObjectType> {Account.getSObjectType()});
		fflib_DmlOperation dmlOperation = unitOfWork.registerDeleteDmlOperation(newAccount);

		// Act
		Test.startTest();
		unitOfWork.commitWork();
		Test.stopTest();

		// Assert
		Integer numAccounts = [SELECT COUNT() FROM Account];

		System.assertEquals(0, numAccounts);
		System.assert(dmlOperation.getDmlOperationResult().isSuccess());
	}

	@IsTest
	static void commitWork_MultipleSObjectTypesRegisteredForDeletion_DmlOperationsContainCorrectResults() {
		// Arrange
		List<SObjectType> sObjectTypes = new List<SObjectType> {
				Account.getSObjectType(),
				Contact.getSObjectType()
		};
		fflib_UnitOfWorkPartialSuccess unitOfWork = new fflib_UnitOfWorkPartialSuccess(sObjectTypes);

		Account account = new Account(Name = 'test');
		Contact contact = new Contact(LastName = 'test');
		insert new List<SObject> {account, contact};
		fflib_DmlOperation accountDmlOperation = unitOfWork.registerDeleteDmlOperation(account);
		fflib_DmlOperation contactDmlOperation = unitOfWork.registerDeleteDmlOperation(contact);

		// Act
		Test.startTest();
		unitOfWork.commitWork();
		Test.stopTest();

		// Assert
		System.assert(accountDmlOperation.getDmlOperationResult().isSuccess());
		System.assert(String.isNotBlank(accountDmlOperation.getDmlOperationResult().getId()));
		System.assertEquals(account.Id, accountDmlOperation.getDmlOperationResult().getId());
		System.assert(contactDmlOperation.getDmlOperationResult().isSuccess());
		System.assert(String.isNotBlank(contactDmlOperation.getDmlOperationResult().getId()));
		System.assertEquals(contact.Id, contactDmlOperation.getDmlOperationResult().getId());
	}

	@IsTest
	static void registerUndeleteDmlOperation_DeletedRecord_ReturnUndeleteDmlOperation() {
		// Arrange
		Account deletedAccount = new Account();
		deletedAccount.Id = fflib_IDGenerator.generate(Account.getSObjectType());

		fflib_UnitOfWorkPartialSuccess unitOfWork =
				new fflib_UnitOfWorkPartialSuccess(new List<SObjectType> {Account.getSObjectType()});

		// Act
		Test.startTest();
		fflib_DmlOperation dmlOperation = unitOfWork.registerUndeleteDmlOperation(deletedAccount);
		Test.stopTest();

		// Assert
		System.assertEquals(fflib_DatabaseOperation.DATABASE_UNDELETE,
				dmlOperation.getDatabaseOperation());
		System.assertEquals(deletedAccount, dmlOperation.getSObject());
	}

	@IsTest
	static void registerUndeleteDmlOperation_MultipleDeletedRecords_ReturnUndeleteDmlOperations() {
		// Arrange
		Id accountId = fflib_IDGenerator.generate(Account.getSObjectType());
		Account deletedAccount = new Account(Id = accountId);
		Account deletedAccount2 = new Account(Id = accountId);
		List<SObject> sObjects = new List<SObject> {deletedAccount, deletedAccount2};

		fflib_UnitOfWorkPartialSuccess unitOfWork =
				new fflib_UnitOfWorkPartialSuccess(new List<SObjectType> {Account.getSObjectType()});

		// Act
		Test.startTest();
		List<fflib_DmlOperation> dmlOperations = unitOfWork.registerUndeleteDmlOperations(sObjects);
		Test.stopTest();

		// Assert
		for (fflib_DmlOperation dmlOperation : dmlOperations) {
			System.assertEquals(fflib_DatabaseOperation.DATABASE_UNDELETE,
					dmlOperation.getDatabaseOperation());
			System.assert(sObjects.contains(dmlOperation.getSObject()));
		}
	}

	@IsTest
	static void registerUndeleteDmlOperation_RecordWithoutAnId_ThrowException() {
		// Arrange
		fflib_UnitOfWorkPartialSuccess unitOfWork =
				new fflib_UnitOfWorkPartialSuccess(new List<SObjectType> {Account.getSObjectType()});
		Exception thrownException;

		// Act
		Test.startTest();
		try {
			unitOfWork.registerUndeleteDmlOperation(new Account());
		} catch (Exception e) {
			thrownException = e;
		}
		Test.stopTest();

		// Assert
		System.assert(thrownException instanceof fflib_SObjectUnitOfWork.UnitOfWorkException);
		System.assertEquals('Only previously deleted records can be registered for undeletion.',
				thrownException.getMessage());
	}

	@IsTest
	static void registerUndeleteDmlOperation_SObjectTypeNotRegistered_ThrowException() {
		// Arrange
		fflib_UnitOfWorkPartialSuccess unitOfWork =
				new fflib_UnitOfWorkPartialSuccess(new List<SObjectType>());
		Exception thrownException;

		// Act
		Test.startTest();
		try {
			Id accountId = fflib_IDGenerator.generate(Account.getSObjectType());
			unitOfWork.registerUndeleteDmlOperation(new Account(Id = accountId));
		} catch (Exception e) {
			thrownException = e;
		}
		Test.stopTest();

		// Assert
		System.assert(thrownException instanceof fflib_SObjectUnitOfWork.UnitOfWorkException);
		System.assertEquals('SObjectType Account is not supported by this unit of work.',
				thrownException.getMessage());
	}

	@IsTest
	static void commitWork_RegisterSObjectForUndeletion_SObjectIsUndeleted() {
		// Arrange
		fflib_UnitOfWorkPartialSuccess unitOfWork =
				new fflib_UnitOfWorkPartialSuccess(new List<SObjectType> {Account.getSObjectType()});

		Account account = new Account(Name = 'test');
		insert account;
		delete account;

		fflib_DmlOperation dmlOperation = unitOfWork.registerUndeleteDmlOperation(account);

		// Act
		Test.startTest();
		unitOfWork.commitWork();
		Test.stopTest();

		// Assert
		Integer numAccounts = [SELECT COUNT() FROM Account];

		System.assertEquals(1, numAccounts);
		System.assert(dmlOperation.getDmlOperationResult().isSuccess());
	}

	@IsTest
	static void commitWork_RegisterSObjectsForUndeletion_SObjectsAreUndeleted() {
		// Arrange
		fflib_UnitOfWorkPartialSuccess unitOfWork =
				new fflib_UnitOfWorkPartialSuccess(new List<SObjectType> {Account.getSObjectType()});

		Account account = new Account(Name = 'test');
		Account account2 = new Account(Name = 'test2');
		List<SObject> sObjects = new List<SObject> {account, account2};
		insert sObjects;
		delete sObjects;

		List<fflib_DmlOperation> dmlOperations = unitOfWork.registerUndeleteDmlOperations(sObjects);

		// Act
		Test.startTest();
		unitOfWork.commitWork();
		Test.stopTest();

		// Assert
		Integer numAccounts = [SELECT COUNT() FROM Account];

		System.assertEquals(2, numAccounts);
		for (fflib_DmlOperation dmlOperation : dmlOperations) {
			System.assert(dmlOperation.getDmlOperationResult().isSuccess());
		}
	}

	@IsTest
	static void commitWork_MultipleRegisteredTypesAndSObjects_DmlOperationsContainCorrectResults() {
		// Arrange
		List<SObjectType> sObjectTypes = new List<SObjectType> {
				Account.getSObjectType(),
				Contact.getSObjectType(),
				Opportunity.getSObjectType()
		};
		fflib_UnitOfWorkPartialSuccess unitOfWork = new fflib_UnitOfWorkPartialSuccess(sObjectTypes);

		Integer numInvalidSObjects = 3;
		Integer numSObjectsPerOperation = 9;

		List<SObject> sObjectsToRegisterNew = new List<SObject>();
		List<SObject> sObjectsToRegisterDirty = new List<SObject>();
		List<SObject> sObjectsToRegisterDelete = new List<SObject>();
		sObjectsToRegisterNew = createSObjectsToRegister(numSObjectsPerOperation);
		sObjectsToRegisterNew.add(new Account());
		sObjectsToRegisterDirty = createSObjectsToRegister(numSObjectsPerOperation);
		sObjectsToRegisterDelete = createSObjectsToRegister(numSObjectsPerOperation);
		List<SObject> allSObjectsToInsert = new List<SObject>();
		insert sObjectsToRegisterDirty;
		insert sObjectsToRegisterDelete;

		List<fflib_DmlOperation> insertDmlOperations =
				unitOfWork.registerNewDmlOperations(sObjectsToRegisterNew);
		List<fflib_DmlOperation> deleteDmlOperations =
				unitOfWork.registerDeleteDmlOperations(sObjectsToRegisterDelete);

		for (Integer i = 0; i < sObjectsToRegisterDirty.size(); i++) {
			SObject record = sObjectsToRegisterDirty[i];
			if (record.getSObjectType() == Contact.getSObjectType()) {
				record.put('LastName', 'Changed' + i);
			} else {
				record.put('Name', 'Changed' + i);
			}
		}
		sObjectsToRegisterDirty[0].put('Name', '');
		List<fflib_DmlOperation> updateDmlOperations =
				unitOfWork.registerDirtyDmlOperations(sObjectsToRegisterDirty);

		// Act
		Test.startTest();
		unitOfWork.commitWork();
		Test.stopTest();

		// Assert
		for (Integer i; i < numSObjectsPerOperation; i++) {
			fflib_DmlOperation insertDmlOperation = insertDmlOperations[i];
			fflib_DmlOperation updateDmlOperation = updateDmlOperations[i];
			fflib_DmlOperation deleteDmlOperation = deleteDmlOperations[i];

			System.assert(insertDmlOperation.getDmlOperationResult().isSuccess());
			System.assertEquals(sObjectsToRegisterNew[i].Id,
					insertDmlOperation.getDmlOperationResult().getId());
			System.assert(updateDmlOperation.getDmlOperationResult().isSuccess());
			if (i != 0) {
				System.assertEquals(sObjectsToRegisterDirty[i].Id,
						updateDmlOperation.getDmlOperationResult().getId());
				System.assert(deleteDmlOperation.getDmlOperationResult().isSuccess());
				System.assertEquals(sObjectsToRegisterDelete[i].Id,
						deleteDmlOperation.getDmlOperationResult().getId());
			}
		}
		System.assert(!insertDmlOperations[numSObjectsPerOperation].getDmlOperationResult().isSuccess());
		System.assert(!updateDmlOperations[0].getDmlOperationResult().isSuccess());
	}

	@IsTest
	static void registerRollback_InsertDmlOperation_DeleteDmlOperationSet() {
		// Arrange
		Account newAccount = new Account(Name = 'test');
		newAccount.Id = fflib_IDGenerator.generate(Account.getSObjectType());
		Database.SaveResult saveResult = (Database.SaveResult)JSON.deserialize(
				'{"success":true,"id":"' + newAccount.Id + '"}', Database.SaveResult.class);
		fflib_DmlOperationResult dmlOperationResult = new fflib_DmlOperationResult(saveResult);
		fflib_DmlOperation dmlOperation = new fflib_DmlOperation(
				newAccount,
				fflib_DatabaseOperation.DATABASE_INSERT
		);
		dmlOperation.setDmlOperationResult(dmlOperationResult);

		fflib_UnitOfWorkPartialSuccess unitOfWork =
				new fflib_UnitOfWorkPartialSuccess(new List<SObjectType> {Account.getSObjectType()});

		// Act
		Test.startTest();
		unitOfWork.registerRollback(dmlOperation);
		Test.stopTest();

		// Assert
		fflib_DmlOperation actualDmlOperation = dmlOperation.getRollbackDmlOperation();
		System.assertEquals(fflib_DatabaseOperation.DATABASE_DELETE,
				actualDmlOperation.getDatabaseOperation());
		System.assertEquals(newAccount, actualDmlOperation.getSObject());
	}

	@IsTest
	static void registerRollback_UpdateDmlOperation_UpdateDmlOperationWithOriginalSObjectSet() {
		// Arrange
		Account updateAccount = new Account(Name = 'test');
		updateAccount.Id = fflib_IDGenerator.generate(Account.getSObjectType());
		Account originalAccount = updateAccount.clone(true);
		Database.SaveResult saveResult = (Database.SaveResult)JSON.deserialize(
				'{"success":true,"id":"' + updateAccount.Id + '"}', Database.SaveResult.class);
		fflib_DmlOperationResult dmlOperationResult = new fflib_DmlOperationResult(saveResult);
		fflib_DmlOperation dmlOperation = new fflib_DmlOperation(
				updateAccount,
				fflib_DatabaseOperation.DATABASE_UPDATE
		);
		dmlOperation.setDmlOperationResult(dmlOperationResult);
		dmlOperation.setOriginalSObject(originalAccount);
		updateAccount.Name = 'Changed';

		fflib_UnitOfWorkPartialSuccess unitOfWork =
				new fflib_UnitOfWorkPartialSuccess(new List<SObjectType> {Account.getSObjectType()});

		// Act
		Test.startTest();
		unitOfWork.registerRollback(dmlOperation);
		Test.stopTest();

		// Assert
		fflib_DmlOperation actualDmlOperation = dmlOperation.getRollbackDmlOperation();
		System.assertEquals(fflib_DatabaseOperation.DATABASE_UPDATE,
				actualDmlOperation.getDatabaseOperation());
		System.assertEquals(originalAccount, actualDmlOperation.getSObject());
	}

	@IsTest
	static void registerRollback_DeleteDmlOperation_UndeleteDmlOperationSet() {
		// Arrange
		Account newAccount = new Account(Name = 'test');
		newAccount.Id = fflib_IDGenerator.generate(Account.getSObjectType());
		Database.DeleteResult deleteResult = (Database.DeleteResult)JSON.deserialize(
				'{"success":true,"id":"' + newAccount.Id + '"}', Database.DeleteResult.class);
		fflib_DmlOperationResult dmlOperationResult = new fflib_DmlOperationResult(deleteResult);
		fflib_DmlOperation dmlOperation = new fflib_DmlOperation(
				newAccount,
				fflib_DatabaseOperation.DATABASE_DELETE
		);
		dmlOperation.setDmlOperationResult(dmlOperationResult);

		fflib_UnitOfWorkPartialSuccess unitOfWork =
				new fflib_UnitOfWorkPartialSuccess(new List<SObjectType> {Account.getSObjectType()});

		// Act
		Test.startTest();
		unitOfWork.registerRollback(dmlOperation);
		Test.stopTest();

		// Assert
		fflib_DmlOperation actualDmlOperation = dmlOperation.getRollbackDmlOperation();
		System.assertEquals(fflib_DatabaseOperation.DATABASE_UNDELETE,
				actualDmlOperation.getDatabaseOperation());
		System.assertEquals(newAccount, actualDmlOperation.getSObject());
	}

	@IsTest
	static void registerRollback_UndeleteDmlOperation_DeleteDmlOperationSet() {
		// Arrange
		Account newAccount = new Account(Name = 'test');
		newAccount.Id = fflib_IDGenerator.generate(Account.getSObjectType());
		Database.UndeleteResult undeleteResult = (Database.UndeleteResult)JSON.deserialize(
				'{"success":true,"id":"' + newAccount.Id + '"}', Database.UndeleteResult.class);
		fflib_DmlOperationResult dmlOperationResult = new fflib_DmlOperationResult(undeleteResult);
		fflib_DmlOperation dmlOperation = new fflib_DmlOperation(
				newAccount,
				fflib_DatabaseOperation.DATABASE_UNDELETE
		);
		dmlOperation.setDmlOperationResult(dmlOperationResult);

		fflib_UnitOfWorkPartialSuccess unitOfWork =
				new fflib_UnitOfWorkPartialSuccess(new List<SObjectType> {Account.getSObjectType()});

		// Act
		Test.startTest();
		unitOfWork.registerRollback(dmlOperation);
		Test.stopTest();

		// Assert
		fflib_DmlOperation actualDmlOperation = dmlOperation.getRollbackDmlOperation();
		System.assertEquals(fflib_DatabaseOperation.DATABASE_DELETE,
				actualDmlOperation.getDatabaseOperation());
		System.assertEquals(newAccount, actualDmlOperation.getSObject());
	}

	@IsTest
	static void registerRollback_Null_ThrowException() {
		// Arrange
		Exception thrownException;

		fflib_UnitOfWorkPartialSuccess unitOfWork =
				new fflib_UnitOfWorkPartialSuccess(new List<SObjectType>());

		// Act
		Test.startTest();
		try {
			unitOfWork.registerRollback(null);
		} catch (Exception e) {
			thrownException = e;
		}
		Test.stopTest();

		// Assert
		System.assert(thrownException instanceof IllegalArgumentException);
		System.assertEquals('Invalid DML operation.', thrownException.getMessage());
	}

	@IsTest
	static void registerRollback_DmlOperationWithoutResult_RollbackDmlOperationNotSet() {
		// Arrange
		fflib_UnitOfWorkPartialSuccess unitOfWork =
				new fflib_UnitOfWorkPartialSuccess(new List<SObjectType> {Account.getSObjectType()});
		Account invalidAccount = new Account();

		fflib_DmlOperation dmlOperation =
				new fflib_DmlOperation(invalidAccount, fflib_DatabaseOperation.DATABASE_INSERT);

		// Act
		Test.startTest();
		unitOfWork.registerRollback(dmlOperation);
		Test.stopTest();

		// Assert
		fflib_DmlOperation rollbackDmlOperation = dmlOperation.getRollbackDmlOperation();
		System.assertEquals(null, rollbackDmlOperation);
	}

	@IsTest
	static void registerRollback_DmlOperationWithUnsuccessfulResullt_RollbackDmlOperationNotSet() {
		// Arrange
		fflib_UnitOfWorkPartialSuccess unitOfWork =
				new fflib_UnitOfWorkPartialSuccess(new List<SObjectType> {Account.getSObjectType()});
		Account invalidAccount = new Account();

		Database.SaveResult saveResult = (Database.SaveResult)JSON.deserialize(
				'{"success":false,"id":""}', Database.SaveResult.class);
		fflib_DmlOperationResult dmlOperationResult = new fflib_DmlOperationResult(saveResult);
		fflib_DmlOperation dmlOperation =
				new fflib_DmlOperation(invalidAccount, fflib_DatabaseOperation.DATABASE_INSERT);
		dmlOperation.setDmlOperationResult(dmlOperationResult);

		// Act
		Test.startTest();
		unitOfWork.registerRollback(dmlOperation);
		Test.stopTest();

		// Assert
		fflib_DmlOperation rollbackDmlOperation = dmlOperation.getRollbackDmlOperation();
		System.assertEquals(null, rollbackDmlOperation);
	}

	@IsTest
	static void registerRollbacks_MultipleDmlOperations_RollbackDmlOperationsSet() {
		// Arrange
		Account newAccount = new Account(Name = 'test');
		newAccount.Id = fflib_IDGenerator.generate(Account.getSObjectType());
		Database.SaveResult saveResult = (Database.SaveResult)JSON.deserialize(
				'{"success":true,"id":"' + newAccount.Id + '"}', Database.SaveResult.class);
		fflib_DmlOperationResult dmlOperationResult = new fflib_DmlOperationResult(saveResult);
		fflib_DmlOperation dmlOperation =
				new fflib_DmlOperation(newAccount, fflib_DatabaseOperation.DATABASE_INSERT);
		dmlOperation.setDmlOperationResult(dmlOperationResult);
		fflib_DmlOperation dmlOperation2 =
				new fflib_DmlOperation(newAccount, fflib_DatabaseOperation.DATABASE_INSERT);
		dmlOperation2.setDmlOperationResult(dmlOperationResult);
		List<fflib_DmlOperation> dmlOperations =
				new List<fflib_DmlOperation> {dmlOperation, dmlOperation2};

		fflib_UnitOfWorkPartialSuccess unitOfWork =
				new fflib_UnitOfWorkPartialSuccess(new List<SObjectType> {Account.getSObjectType()});

		// Act
		Test.startTest();
		unitOfWork.registerRollbacks(dmlOperations);
		Test.stopTest();

		// Assert
		List<fflib_DmlOperation> actualDmlOperations = new List<fflib_DmlOperation>();
		for (fflib_DmlOperation existingDmlOperation : dmlOperations) {
			actualDmlOperations.add(existingDmlOperation.getRollbackDmlOperation());
		}

		System.assertEquals(2, actualDmlOperations.size());
		for (fflib_DmlOperation actualDmlOperation : actualDmlOperations) {
			System.assertEquals(fflib_DatabaseOperation.DATABASE_DELETE,
					actualDmlOperation.getDatabaseOperation());
		}
	}

	@IsTest
	static void commitWork_InsertRollbackRegistered_SObjectIsDeleted() {
		// Arrange
		Account newAccount = new Account(Name = 'test');
		Database.SaveResult saveResult = (Database.SaveResult)JSON.deserialize(
				'{"success":true,"id":"' + newAccount.Id + '"}', Database.SaveResult.class);
		fflib_DmlOperationResult dmlOperationResult = new fflib_DmlOperationResult(saveResult);
		fflib_DmlOperation dmlOperation = new fflib_DmlOperation(
				newAccount,
				fflib_DatabaseOperation.DATABASE_INSERT
		);
		dmlOperation.setDmlOperationResult(dmlOperationResult);
		insert newAccount;

		fflib_UnitOfWorkPartialSuccess unitOfWork =
				new fflib_UnitOfWorkPartialSuccess(new List<SObjectType> {Account.getSObjectType()});
		unitOfWork.registerRollback(dmlOperation);

		// Act
		Test.startTest();
		unitOfWork.commitWork();
		Test.stopTest();

		// Assert
		Integer numAccounts = [SELECT COUNT() FROM Account];
		fflib_DmlOperation rollbackDmlOperation = dmlOperation.getRollbackDmlOperation();
		System.assertEquals(0, numAccounts);
		System.assert(rollbackDmlOperation.getDmlOperationResult().isSuccess());
	}

	@IsTest
	static void commitWork_UpdateRollbackRegistered_SObjectIsUpdatedToOriginal() {
		// Arrange
		Account originalAccount = new Account(Name = 'test');
		insert originalAccount;
		Account updateAccount = originalAccount.clone(true);

		Database.SaveResult saveResult = (Database.SaveResult)JSON.deserialize(
				'{"success":true,"id":"' + originalAccount.Id + '"}', Database.SaveResult.class);
		fflib_DmlOperationResult dmlOperationResult = new fflib_DmlOperationResult(saveResult);
		fflib_DmlOperation dmlOperation = new fflib_DmlOperation(
				updateAccount,
				fflib_DatabaseOperation.DATABASE_UPDATE
		);
		dmlOperation.setDmlOperationResult(dmlOperationResult);
		dmlOperation.setOriginalSObject(originalAccount);

		updateAccount.Name = 'Changed';
		update updateAccount;
		Account existingAccountInDatabase = [SELECT Name FROM Account WHERE Id = :originalAccount.Id];

		fflib_UnitOfWorkPartialSuccess unitOfWork =
				new fflib_UnitOfWorkPartialSuccess(new List<SObjectType> {Account.getSObjectType()});
		unitOfWork.registerRollback(dmlOperation);

		// Act
		Test.startTest();
		unitOfWork.commitWork();
		Test.stopTest();

		// Assert
		List<Account> updatedAccounts = [SELECT Name FROM Account];
		fflib_DmlOperation rollbackDmlOperation = dmlOperation.getRollbackDmlOperation();

		System.assertEquals(1, updatedAccounts.size());
		System.assertEquals('Changed', existingAccountInDatabase.Name);
		System.assertEquals('test', updatedAccounts[0].Name);
		System.assert(rollbackDmlOperation.getDmlOperationResult().isSuccess());
	}

	@IsTest
	static void commitWork_DeleteRollbackRegistered_SObjectIsUndeleted() {
		// Arrange
		Account newAccount = new Account(Name = 'test');
		insert newAccount;
		Database.DeleteResult deleteResult = (Database.DeleteResult)JSON.deserialize(
				'{"success":true,"id":"' + newAccount.Id + '"}', Database.DeleteResult.class);
		fflib_DmlOperationResult dmlOperationResult = new fflib_DmlOperationResult(deleteResult);
		fflib_DmlOperation dmlOperation = new fflib_DmlOperation(
				newAccount,
				fflib_DatabaseOperation.DATABASE_DELETE
		);
		dmlOperation.setDmlOperationResult(dmlOperationResult);
		delete newAccount;

		fflib_UnitOfWorkPartialSuccess unitOfWork =
				new fflib_UnitOfWorkPartialSuccess(new List<SObjectType> {Account.getSObjectType()});
		unitOfWork.registerRollback(dmlOperation);

		// Act
		Test.startTest();
		unitOfWork.commitWork();
		Test.stopTest();

		// Assert
		Integer numAccounts = [SELECT COUNT() FROM Account];
		fflib_DmlOperation rollbackDmlOperation = dmlOperation.getRollbackDmlOperation();
		System.assertEquals(1, numAccounts);
		System.assert(rollbackDmlOperation.getDmlOperationResult().isSuccess());
	}

	@IsTest
	static void commitWork_UndeleteRollbackRegistered_SObjectIsDeleted() {
		// Arrange
		Account newAccount = new Account(Name = 'test');
		insert newAccount;
		Database.UndeleteResult undeleteResult = (Database.UndeleteResult)JSON.deserialize(
				'{"success":true,"id":"' + newAccount.Id + '"}', Database.UndeleteResult.class);
		fflib_DmlOperationResult dmlOperationResult = new fflib_DmlOperationResult(undeleteResult);
		fflib_DmlOperation dmlOperation = new fflib_DmlOperation(
				newAccount,
				fflib_DatabaseOperation.DATABASE_UNDELETE
		);
		dmlOperation.setDmlOperationResult(dmlOperationResult);
		delete newAccount;
		undelete newAccount;

		fflib_UnitOfWorkPartialSuccess unitOfWork =
				new fflib_UnitOfWorkPartialSuccess(new List<SObjectType> {Account.getSObjectType()});
		unitOfWork.registerRollback(dmlOperation);

		// Act
		Test.startTest();
		unitOfWork.commitWork();
		Test.stopTest();

		// Assert
		Integer numAccounts = [SELECT COUNT() FROM Account];
		fflib_DmlOperation rollbackDmlOperation = dmlOperation.getRollbackDmlOperation();
		System.assertEquals(0, numAccounts);
		System.assert(rollbackDmlOperation.getDmlOperationResult().isSuccess());
	}

	@IsTest
	static void commitWork_InsertedDmlOperationRolledBack_SObjectIsDeleted() {
		// Arrange
		fflib_UnitOfWorkPartialSuccess unitOfWork =
				new fflib_UnitOfWorkPartialSuccess(new List<SObjectType> {Account.getSObjectType()});

		Account newAccount = new Account(Name = 'test');
		fflib_DmlOperation dmlOperation = unitOfWork.registerNewDmlOperation(newAccount);
		unitOfWork.commitWork();

		// Act
		Test.startTest();
		unitOfWork.registerRollback(dmlOperation);
		unitOfWork.commitWork();
		Test.stopTest();

		// Assert
		Integer numAccounts = [SELECT COUNT() FROM Account];
		fflib_DmlOperation rollbackDmlOperation = dmlOperation.getRollbackDmlOperation();

		System.assertEquals(0, numAccounts);
		System.assert(rollbackDmlOperation.getDmlOperationResult().isSuccess());
	}

	static List<SObject> createSObjectsToRegister(Integer numSObjectsPerOperation) {
		List<SObject> sObjects = new List<SObject>();
		for (Integer i = 0; i < numSObjectsPerOperation; i++) {
			if (Math.mod(i, 3) == 0) {
				sObjects.add(new Account(Name = 'test' + i));
			}
			if (Math.mod(i, 3) == 1) {
				sObjects.add(new Contact(LastName = 'test' + i));
			}
			if (Math.mod(i, 3) == 2) {
				Opportunity opp = new Opportunity();
				opp.CloseDate = System.today();
				opp.StageName = '1. Open';
				opp.Name = 'test' + i;
				sObjects.add(opp);
			}
		}
		return sObjects;
	}
}
