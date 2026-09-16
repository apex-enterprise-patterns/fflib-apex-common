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
 */
/**
 * This class adapted from https://github.com/capeterson/Apex-Util
 * Used under a BSD license: https://github.com/capeterson/Apex-Util/blob/master/LICENSE
 */
@IsTest( isParallel = true )
private with sharing class fflib_SObjectDescribeTest {

	/**
	 * Verifies that the null-token guard in the private constructor throws InvalidDescribeException,
	 * and that a valid token is assigned correctly. Only reachable directly because the constructor
	 * is @TestVisible - the public getDescribe overloads all guard against null before ever calling it.
	 */
	@isTest
	private static void constructor(){
		try{
			new fflib_SObjectDescribe(null);
			System.Assert.fail('Expected InvalidDescribeException for null SObjectType');
		}catch(fflib_SObjectDescribe.InvalidDescribeException ex){
			System.Assert.areEqual('Invalid SObject type: null', ex.getMessage(), 'Expected other Exception message');
		}

		fflib_SObjectDescribe descr = new fflib_SObjectDescribe(Account.SObjectType);
		System.Assert.areEqual(Account.SObjectType, descr.getSObjectType(), 'Expected token to be set by constructor');
	}

	/**
	 * Verify that the different ways of getting your hands on an fflib_SObjectDescribe instance all handle null inputs
	 * (and blank/empty strings, why not?) by returning null - since there's no possible way to resolve it.
	**/
	@isTest
	private static void getDescribe_badInput(){
		String nullStr = null; //having it as a string var makes for unambiguous selection of overloads
		Schema.SObjectType nullType = null;
		Schema.DescribeSObjectResult nullDescribe = null;
		SObject nullSObject = null;
		System.Assert.areEqual(null, fflib_SObjectDescribe.getDescribe(nullStr));
		System.Assert.areEqual(null, fflib_SObjectDescribe.getDescribe(''));
		System.Assert.areEqual(null, fflib_SObjectDescribe.getDescribe(' '));
		System.Assert.areEqual(null, fflib_SObjectDescribe.getDescribe(nullType));
		System.Assert.areEqual(null, fflib_SObjectDescribe.getDescribe(nullDescribe));
		System.Assert.areEqual(null, fflib_SObjectDescribe.getDescribe(nullSObject));
	}

	@isTest
	private static void NamespacedAttributeMap_implementations(){
		fflib_SObjectDescribe.GlobalDescribeMap gdm = fflib_SObjectDescribe.getGlobalDescribe();
		Schema.SObjectType accountObjType = gdm.get('AccOunT');
		System.Assert.areEqual(accountObjType, Account.SobjectType);
		System.Assert.areEqual(Schema.getGlobalDescribe().size(), gdm.size());

		fflib_SObjectDescribe acccountDescribe = fflib_SObjectDescribe.getDescribe(accountObjType);
		fflib_SObjectDescribe.FieldsMap fields = acccountDescribe.getFields();
		System.Assert.isTrue( fields.keySet().containsAll(acccountDescribe.getFieldsMap().keySet()) );

		System.Assert.areEqual(fields.get('name'), Account.SObjectType.fields.name); //behavior of FieldsMap is tested in another method
		System.Assert.areEqual(Schema.SObjectType.Account.fields.getMap().size(), fields.size());

		System.Assert.areEqual(null, fields.get(null), 'Null input should result in null ouput.');
		System.Assert.areEqual(null, fields.get(''), 'Invalid fieldname input should result in null ouput.');
	}

	@isTest
	private static void FieldsMap(){
		String fakeNamespace = 'fflib_test';
		Map<String,Schema.SObjectField> fakeFieldData = new Map<String,Schema.SObjectField>{
			'name__c' => Contact.SObjectType.fields.name, //re-use standard field types since we can't mock them
			fakeNamespace+'__name__c' => Account.SObjectType.fields.name,
			fakeNamespace+'__otherField__c' => Account.SObjectType.fields.name,
			'createddate' => Contact.SObjectType.fields.CreatedDate
		};
		fflib_SObjectDescribe.FieldsMap fields = new fflib_SObjectDescribe.FieldsMap(fakeFieldData);
		fields.currentNamespace = fakeNamespace;
		System.Assert.areEqual(true, fields.containsKey('name__c') );
		System.Assert.areEqual(true, fields.containsKey(fakeNamespace.toUpperCase()+'__nAMe__c') );
		System.Assert.isTrue(fields.get('NAme__c') === fields.get(fakeNamespace+'__namE__c'));

		System.Assert.isTrue(!fields.keySet(false).contains('otherField__c'));
		System.Assert.isTrue(fields.keySet(false).contains(fakeNamespace+'__otherField__c'));

		System.Assert.isTrue(fields.keySet(true).contains('otherField__c'));
		System.Assert.isTrue(!fields.keySet(true).contains(fakeNamespace+'__otherField__c'));

		//keySet() no-arg overload defaults to keySet(false)
		System.Assert.areEqual(fields.keySet(false), fields.keySet());

		//containsKey: null name short-circuits to null, absent key returns false, implyNamespace=false negative path
		System.Assert.areEqual(null, fields.containsKey(null));
		System.Assert.areEqual(false, fields.containsKey('doesNotExist__c'));
		System.Assert.areEqual(false, fields.containsKey('otherField__c', false));

		//values() returns the raw underlying field values
		System.Assert.isTrue(fields.values().contains(Contact.SObjectType.fields.name));

		fields.currentNamespace = 'someOtherNamespace';
		System.Assert.areNotEqual(fields.get('name__C'), fields.get(fakeNamespace.capitalize()+'__nAme__c'));
	}

	@isTest
	private static void GlobalDescribeMap(){
		String fakeNamespace = 'fflib_test';
		Map<String,Schema.SObjectType> fakeFieldData = new Map<String,Schema.SObjectType>{
			'name__c' => Contact.SObjectType, //re-use stndard object types since we can't mock them
			fakeNamespace+'__name__c' => Account.SObjectType,
			'createddate' => Lead.SObjectType
		};
		fflib_SObjectDescribe.GlobalDescribeMap gdm = new fflib_SObjectDescribe.GlobalDescribeMap(fakeFieldData);
		gdm.currentNamespace = fakeNamespace;
		System.Assert.areEqual(true, gdm.containsKey('name__c') );
		System.Assert.areEqual(true, gdm.containsKey(fakeNamespace+'__name__c') );
		System.Assert.isTrue(gdm.get('name__c') === gdm.get(fakeNamespace+'__name__c'));

		//keySet() no-arg overload defaults to keySet(false)
		System.Assert.areEqual(gdm.keySet(false), gdm.keySet());

		//containsKey: null name short-circuits to null, absent key returns false
		System.Assert.areEqual(null, gdm.containsKey(null));
		System.Assert.areEqual(false, gdm.containsKey('doesNotExist__c'));

		//values() returns the raw underlying SObjectType values
		System.Assert.isTrue(gdm.values().contains(Contact.SObjectType));

		gdm.currentNamespace = 'someOtherNamespace';
		System.Assert.areNotEqual(gdm.get('name__c'), gdm.get(fakeNamespace+'__name__c'));
	}

	@isTest //Tests all forms of the getDescribe static
	private static void getAccountDescribes(){
        fflib_SObjectDescribe d = fflib_SObjectDescribe.getDescribe('Account');
        fflib_SObjectDescribe d2 = fflib_SObjectDescribe.getDescribe(Account.SObjectType);
        fflib_SObjectDescribe d3 = fflib_SObjectDescribe.getDescribe(Schema.SObjectType.Account);
        // fflib_SObjectDescribe d4 = fflib_SObjectDescribe.getDescribe(Account.SObjectType.getDescribe());
        // fflib_SObjectDescribe d5 = fflib_SObjectDescribe.getDescribe(new Account());
        System.Assert.areEqual('Account', d.getDescribe().getName());
        System.Assert.areEqual(d, d2, 'Expected getDescribe by String vs. Account.SObjectType to return the same cached instance.');
        System.Assert.areEqual(d, d3, 'Expected getDescribe by String vs. Schema.SObjectType.Account to return the same cached instance.');
        // System.Assert.areEqual(d, d4, 'Expected getDescribe by String vs. Account.SObjectType.getDescribe() to return the same cached instance.');
        // System.Assert.areEqual(d, d5, 'Expected getDescribe by String vs. new Account() to return the same cached instance.');
	}

	@isTest
	private static void simpleAccountFieldDescribe(){
		fflib_SObjectDescribe d = fflib_SObjectDescribe.getDescribe(Account.SObjectType);
		Map<String,Schema.SObjectField> fields;
		for(integer i = 0; i < 10; i++){
			fields = d.getFieldsMap();
		}

		// Describe Limits removed since Summer ’14.
		// https://developer.salesforce.com/releases/release/Summer14/New+Apex+Enhancements

		// Because describe limits are no longer enforced in any API version, this method is no longer available.
		// In API version 30.0 and earlier, this method is available but is deprecated.

		// System.assertEquals(1, Limits.getFieldsDescribes() );

		System.Assert.areEqual(false,fields.isEmpty());
		System.Assert.areEqual(Account.SObjectType, d.getSObjectType());
	}

	@isTest
	private static void simpleAccountFieldSetDescribe(){
		fflib_SObjectDescribe d = fflib_SObjectDescribe.getDescribe(Account.SObjectType);
		Map<String,Schema.FieldSet> fields;
		for(integer i = 0; i < 10; i++){
			fields = d.getFieldSetsMap();
		}

		// Describe Limits removed since Summer ’14.
		// https://developer.salesforce.com/releases/release/Summer14/New+Apex+Enhancements

		// Because describe limits are no longer enforced in any API version, this method is no longer available.
		// In API version 30.0 and earlier, this method is available but is deprecated.

		// System.assertEquals(1, Limits.getFieldSetsDescribes() );

		// no asserts on result size to avoid a requirement on field sets existing
	}

	@isTest
	private static void simpleAccountGetNameField(){
		fflib_SObjectDescribe d = fflib_SObjectDescribe.getDescribe(Account.SObjectType);
		Schema.SObjectField nameField = d.getNameField();
		System.Assert.areEqual('Name', nameField.getDescribe().getName());

		//second call should hit the cached nameField branch and return the same reference
		Schema.SObjectField nameField2 = d.getNameField();
		System.Assert.isTrue(nameField === nameField2, 'Expected cached nameField reference to be returned');

		//cross-check against getField() normal-path resolution of the same field
		System.Assert.areEqual(nameField, d.getField('Name'), 'Expected identical field to be retrieved via getField');
	}

	/**
	 * Covers getField's relationship-notation handling: the normal path, the custom cross-object
	 * "__r" and person-account "__pr" suffix resolution, and the standard-lookup "+Id" fallback.
	**/
	@isTest
	private static void getField_variousInputs(){
		fflib_SObjectDescribe contactDescribe = fflib_SObjectDescribe.getDescribe(Contact.SObjectType);

		//shorthand getField(name) is equivalent to getField(name, true)
		System.Assert.areEqual(contactDescribe.getField('LastName', true), contactDescribe.getField('LastName'));

		//standard lookup field accessed via cross-object short name falls back to the '+Id' lookup branch
		System.Assert.areEqual(Contact.SObjectType.fields.ReportsToId, contactDescribe.getField('ReportsTo'));

		//custom field cross-object (__r) syntax resolves to __c; field is absent so result is null,
		//but the resolution branch is still exercised
		System.Assert.areEqual(null, contactDescribe.getField('NonExistentField__r'));

		//custom field cross-object (__pr) syntax for person accounts resolves to __pc
		System.Assert.areEqual(null, contactDescribe.getField('NonExistentField__pr'));
	}

	@isTest
	private static void flushCache(){
		fflib_SObjectDescribe d = fflib_SObjectDescribe.getDescribe('Account');
		fflib_SObjectDescribe.flushCache();
		fflib_SObjectDescribe d2 = fflib_SObjectDescribe.getDescribe('Account');
		System.Assert.isTrue(d !== d2, 'Second object should be a fresh instance after a cache flush.' );
	}

	@isTest
	private static void rawGlobalDescribeCheck(){
		Map<String,Schema.SObjectType> systemGd = Schema.getGlobalDescribe();
		Map<String,Schema.SObjectType> cachedGd = fflib_SObjectDescribe.getRawGlobalDescribe();
		System.Assert.areEqual(systemGd.size(),cachedGd.size());
	}

	@isTest
	private static void getPicklistValues_validReturn(){
		List<Schema.PicklistEntry> expected = Schema.Account.Rating.getDescribe().getPicklistValues();

		List<Schema.PicklistEntry> actual = fflib_SObjectDescribe.getPicklistValues(Schema.Account.Rating);

		System.Assert.areEqual(expected.size(), actual.size(), 'Expected the same number of picklist entries as returned by the platform describe');
	}

	@isTest
	private static void getPicklistValues_nullField(){
		try {
			fflib_SObjectDescribe.getPicklistValues(null);
			System.Assert.fail('Expected a fflib_Objects.InvalidValueException because a null SObjectField was passed in and cannot be described');
		} catch (Exception ex){
			System.Assert.isInstanceOfType(ex, fflib_Objects.InvalidValueException.class, 'Expected fflib_Objects.InvalidValueException but got ' + ex);
		}
	}

	@isTest
	private static void getPicklistValues_nonPicklistField(){
		System.Assert.areEqual(
			new List<Schema.PicklistEntry>(),
			fflib_SObjectDescribe.getPicklistValues(Schema.Account.Name),
			'Expected an empty list for a non-picklist field'
		);
	}

	@isTest
	private static void getPicklistLabelsToStrings_returnsLabels(){
		List<String> values = fflib_SObjectDescribe.getPicklistLabelsToStrings(Schema.Account.Rating);

		System.Assert.isTrue(values.contains('Hot'), 'Expected the Hot picklist label to be present, unmodified (no upper-casing)');
	}

	@isTest
	private static void isValidPicklistValue_success(){
		System.Assert.isTrue(fflib_SObjectDescribe.isValidPicklistValue(Schema.Account.Rating, 'Hot'), 'Expected Hot to be a valid picklist value for Account.Rating');
	}

	@isTest
	private static void isValidPicklistValue_blankValue(){
		System.Assert.areEqual(false, fflib_SObjectDescribe.isValidPicklistValue(Schema.Account.Rating, null), 'Expected a null value to be considered invalid');
	}

	@isTest
	private static void isValidPicklistValue_invalidValue(){
		System.Assert.areEqual(false, fflib_SObjectDescribe.isValidPicklistValue(Schema.Account.Rating, 'NotARealValue'), 'Expected an unknown picklist value to be considered invalid');
	}
}