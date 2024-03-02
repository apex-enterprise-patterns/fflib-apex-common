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

@isTest @TestVisible
private class fflib_SecurityUtilsTest {

	@TestSetup @TestVisible
	static void testSetup() {
		// #315 Create a Permission Set that grants "Read" access to Account, Contact and Lead. We will use this in
		// Spring '21 orgs that lack the "Read Only" Profile. See:
		// https://help.salesforce.com/articleView?id=release-notes.rn_profiles_and_perms_read_only_new.htm&release=230&type=5).
		PermissionSet ps = new PermissionSet(Label = 'Read Only Permission Set', Name = 'ReadOnlyPermissionSet');
		insert ps;

		// Grant Read access to the SObjects we use for CRUD tests
		List<ObjectPermissions> objectPerms = new List<ObjectPermissions>();
		objectPerms.add(createObjectPermissions(ps.Id, 'Account', false, true, false, false));
		objectPerms.add(createObjectPermissions(ps.Id, 'Contact', false, true, false, false));
		objectPerms.add(createObjectPermissions(ps.Id, 'Lead', false, true, false, false));
		insert objectPerms;

		// Grant Read/Edit access to the SObject fields we use for FLS tests
		List<FieldPermissions> fieldPerms = new List<FieldPermissions>();
		fieldPerms.add(createFieldPermissions(ps.Id, 'Contact', 'Birthdate', true, false));
		fieldPerms.add(createFieldPermissions(ps.Id, 'Contact', 'Email', true, false));
		insert fieldPerms;
	}

	static Profile getProfile(String profileName) {
		return [SELECT Id, Name FROM Profile WHERE Name = :profileName];
	}

	static ObjectPermissions createObjectPermissions(
		Id permSetId, String objectType, Boolean canCreate, Boolean canRead,  Boolean canUpdate, Boolean canDelete
	) {
		return new ObjectPermissions(
			ParentId = permSetId,
			SobjectType = objectType,
			PermissionsCreate = canCreate,
			PermissionsRead = canRead,
			PermissionsEdit = canUpdate,
			PermissionsDelete = canDelete
		);
	}

	static FieldPermissions createFieldPermissions(
		Id permSetId, String objectType, String fieldName, Boolean canRead, Boolean canEdit
	) {
		return new FieldPermissions(
			ParentId = permSetId,
			SobjectType = objectType,
			Field = objectType + '.' + fieldName,
			PermissionsRead = canRead,
			PermissionsEdit = canEdit
		);
	}

	@TestVisible
	static User setupTestUser(Boolean limitedAccess){
		Profile p;

		if (limitedAccess) {
			try {
				p = getProfile('Minimum Access - Salesforce');
			} catch (QueryException ex) {
				if (ex.getMessage().contains('List has no rows for assignment to SObject')) {
					//#440 - not ideal, but we'll fall back to the rather liberally permissioned 'Read Only' profile that exists in very old orgs
					p = getProfile('Read Only');
				}
			}
		} else {
			p = getProfile('System Administrator');
		}

		//username global uniqueness is still enforced in tests 
		//make sure we get something unique to avoid issues with parallel tests
		String uniqueness = DateTime.now()+':'+Math.random();
		try{ 
			throw new NullPointerException();
		}catch(Exception e){
			uniqueness += e.getStackTraceString(); //includes the top level test method name without having to pass it
		}
		User usr = new User(
			username=UserInfo.getUserId()+'.'+uniqueness.HashCode()+'@'+UserInfo.getOrganizationId()+'.sfdcOrg',
			alias = 'testExec',
			email='apextests@example.com',
			emailencodingkey='UTF-8',
			lastname='Testing',
			languagelocalekey='en_US',
			localesidkey='en_US',
			profileid = p.Id,
			timezonesidkey='America/Los_Angeles'
		);
		insert usr;

		if (limitedAccess) {
			// #315 We need to assign the Perm Set to grant Account "Read" access
			PermissionSet accountReadPS = [SELECT Id FROM PermissionSet WHERE Name = 'ReadOnlyPermissionSet'];
			PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = usr.Id, PermissionSetId = accountReadPS.Id);
			insert psa;
		}
		return usr;
	}

	@isTest
	static void readonly_field_access() {
		User testUser = setupTestUser(true);
		System.runAs(testUser){
			{
				fflib_SecurityUtils.SecurityException ex;
				try{
					fflib_SecurityUtils.checkFieldIsInsertable(Account.SObjectType, 'naMe');
				}catch(fflib_SecurityUtils.SecurityException e){
					ex = e;
				}
				System.assertNotEquals(null, ex, 'Read only profile should not be able to insert Account.Name');
				System.assert(ex instanceof fflib_SecurityUtils.FlsException, 'Expected an FlsException, got '+ex.getTypeName());
			}
			{
				fflib_SecurityUtils.SecurityException ex;
				try{
					fflib_SecurityUtils.checkFieldIsReadable(Contact.SObjectType, 'LastNAME');
				}catch(fflib_SecurityUtils.SecurityException e){
					ex = e;
				}
				System.assertEquals(null, ex, 'Read only profile should be able to read Contact.LastName');
			}
			{
				fflib_SecurityUtils.SecurityException ex;
				try{
					fflib_SecurityUtils.checkFieldIsUpdateable(Lead.SObjectType, 'cOMPANY');
				}catch(fflib_SecurityUtils.SecurityException e){
					ex = e;
				}
				System.assertNotEquals(null, ex, 'Read only profile should not be able to update Lead.Company');
				System.assert(ex instanceof fflib_SecurityUtils.FlsException, 'Expected an FlsException, got '+ex.getTypeName());
			}

			fflib_SecurityUtils.BYPASS_INTERNAL_FLS_AND_CRUD = true;
			{ //no exceptions, despite no rights
				fflib_SecurityUtils.checkFieldIsInsertable(Account.SObjectType, 'naMe');
				fflib_SecurityUtils.checkFieldIsReadable(Contact.SObjectType, 'LastNAME');
				fflib_SecurityUtils.checkFieldIsUpdateable(Lead.SObjectType, 'cOMPANY');
			}
		}
	}

	@isTest
	static void readonly_object_access() {
		User testUser = setupTestUser(true);
		System.runAs(testUser){
			{
				fflib_SecurityUtils.SecurityException ex;
				try{
					fflib_SecurityUtils.checkObjectIsInsertable(Account.SObjectType);
				}catch(fflib_SecurityUtils.SecurityException e){
					ex = e;
				}
				System.assertNotEquals(null, ex, 'Read only profile should not be able to insert Account');
				System.assert(ex instanceof fflib_SecurityUtils.CrudException, 'Expected an CrudException, got '+ex.getTypeName());
			}
			{
				fflib_SecurityUtils.SecurityException ex;
				try{
					fflib_SecurityUtils.checkObjectIsReadable(Contact.SObjectType);
				}catch(fflib_SecurityUtils.SecurityException e){
					ex = e;
				}
				System.assertEquals(null, ex, 'Read only profile should be able to read Contact');
			}
			{
				fflib_SecurityUtils.SecurityException ex;
				try{
					fflib_SecurityUtils.checkObjectIsUpdateable(Lead.SObjectType);
				}catch(fflib_SecurityUtils.SecurityException e){
					ex = e;
				}
				System.assertNotEquals(null, ex, 'Read only profile should not be able to update Lead');
				System.assert(ex instanceof fflib_SecurityUtils.CrudException, 'Expected an CrudException, got '+ex.getTypeName());
			}
			{
				fflib_SecurityUtils.SecurityException ex;
				try{
					fflib_SecurityUtils.checkObjectIsDeletable(Opportunity.SObjectType);
				}catch(fflib_SecurityUtils.SecurityException e){
					ex = e;
				}
				System.assertNotEquals(null, ex, 'Read only profile should not be able to delete Opportunity');
				System.assert(ex instanceof fflib_SecurityUtils.CrudException, 'Expected an CrudException, got '+ex.getTypeName());
			}

			fflib_SecurityUtils.BYPASS_INTERNAL_FLS_AND_CRUD = true;
			{ //no exceptions, despite no rights
				fflib_SecurityUtils.checkObjectIsInsertable(Account.SObjectType);
				fflib_SecurityUtils.checkObjectIsReadable(Contact.SObjectType);
				fflib_SecurityUtils.checkObjectIsUpdateable(Lead.SObjectType);
				fflib_SecurityUtils.checkObjectIsDeletable(Opportunity.SObjectType);
			}
		}
	}

	@isTest
	static void readonly_objectAndField_access() {
		User testUser = setupTestUser(true);
		System.runAs(testUser){
			{
				fflib_SecurityUtils.SecurityException ex;
				try{
					fflib_SecurityUtils.checkInsert(
						Account.SObjectType,
						new List<String>{
							'Name',
							'ParentId',
							'ownerId'
						}
					);
				}catch(fflib_SecurityUtils.SecurityException e){
					ex = e;
				}
				System.assertNotEquals(null, ex, 'Read only profile should not be able to insert Account');
				System.assert(ex instanceof fflib_SecurityUtils.CrudException, 'Expected an CrudException, got '+ex.getTypeName());
			}
			{
				fflib_SecurityUtils.SecurityException ex;
				try{
					fflib_SecurityUtils.checkRead(
						Contact.SObjectType,
						new List<String>{
							'LastName',
							'eMaiL',
							'BirthDATE'
						}
					);
				}catch(fflib_SecurityUtils.SecurityException e){
					ex = e;
				}
				System.assertEquals(null, ex, 'Read only profile should be able to read Contact');
			}
			{
				fflib_SecurityUtils.SecurityException ex;
				try{
					fflib_SecurityUtils.checkUpdate(
						Lead.SObjectType,
						new List<String>{
							'LastName',
							'FirstNAMe',
							'cOMPANY'
						}
					);
				}catch(fflib_SecurityUtils.SecurityException e){
					ex = e;
				}
				System.assertNotEquals(null, ex, 'Read only profile should not be able to update Lead');
				System.assert(ex instanceof fflib_SecurityUtils.CrudException, 'Expected an CrudException, got '+ex.getTypeName());
			}

			fflib_SecurityUtils.BYPASS_INTERNAL_FLS_AND_CRUD = true;
			{ //no exceptions, despite no rights
				fflib_SecurityUtils.checkInsert(
					Account.SObjectType,
					new List<String>{
						'Name',
						'Type',
						'ownerId'
					}
				);
				fflib_SecurityUtils.checkRead(
					Contact.SObjectType,
					new List<String>{
						'LastName',
						'accountId',
						'ownerId'
					}
				);
				fflib_SecurityUtils.checkUpdate(
					Lead.SObjectType,
					new List<String>{
						'LastName',
						'FirstNAMe',
						'cOMPANY'
					}
				);
			}
		}
	}

	@isTest
	static void sysadmin_objectAndField_access() {
		User testUser = setupTestUser(false);
		System.runAs(testUser){
			fflib_SecurityUtils.checkInsert(
				Account.SObjectType,
				new List<Schema.SObjectField>{
					Account.SObjectType.fields.Name,
					Account.SObjectType.fields.ParentId,
					Account.SObjectType.fields.ownerId
				}
			);
			fflib_SecurityUtils.checkRead(
				Contact.SObjectType,
				new List<Schema.SObjectField>{
					Contact.SObjectType.fields.LastName,
					Contact.SObjectType.fields.accountId,
					Contact.SObjectType.fields.ownerId
				}
			);
			fflib_SecurityUtils.checkUpdate(
				Lead.SObjectType,
				new List<Schema.SObjectField>{
					Lead.SObjectType.fields.LastName,
					Lead.SObjectType.fields.FirstNAMe,
					Lead.SObjectType.fields.cOMPANY
				}
			);
		}
	}
	
}