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
@NamespaceAccessible
@SuppressWarnings('PMD.EmptyStatementBlock, PMD.ClassNamingConventions, PMD.MethodNamingConventions, PMD.FieldNamingConventions, PMD.PropertyNamingConventions, PMD.ApexDoc, PMD.ExcessiveParameterList, PMD.CyclomaticComplexity, PMD.CognitiveComplexity')
public virtual class fflib_SObjects
		extends fflib_Objects
		implements fflib_ISObjects
{

	@NamespaceAccessible
	public Schema.DescribeSObjectResult sObjectDescribe {get; private set;}

	/**
	 * Useful during unit testing to assert at a more granular and robust level for errors raised during the various trigger events
	 */
	@NamespaceAccessible
	public static ErrorFactory Errors  {get; private set;}

	static
	{
		Errors = new ErrorFactory();
	}

	/**
	 * Cached record count of the domain, avoiding repeated calls to getRecords().size() in tight loops
	 */
	private Integer numRecords
	{
		get
		{
			if (numRecords == null)
			{
				numRecords = getRecords().size();
			}
			return numRecords;
		}
		private set;
	}

	/**
	 * Class constructor
	 */
	@NamespaceAccessible
	public fflib_SObjects(List<SObject> records)
	{
		super(records);
	}

	@NamespaceAccessible
	public fflib_SObjects(List<SObject> records, Schema.SObjectType sObjectType)
	{
		super(records);
		this.sObjectDescribe = sObjectType.getDescribe();
	}

	/**
	 * @return Return the SObject records contained in the domain
	 */
	@NamespaceAccessible
	public virtual List<SObject> getRecords()
	{
		return (List<SObject>) getObjects();
	}

	/**
	 * @return Return the SObject record Ids contained in the domain
	 */
	@NamespaceAccessible
	public virtual Set<Id> getRecordIds()
	{
		return new Map<Id, SObject>(getRecords()).keySet();
	}

	/**
	 * Method to 'pluck' Id's out of a collection of SObjects, from a given Id field
	 *
	 * @param field The Id field to fetch values from
	 *
	 * @return Set of (unique) Id's listed in the specified field, excluding null values
	 */
	@NamespaceAccessible
	public virtual Set<Id> getRecordIds(Schema.SObjectField field)
	{
		return getRecordIds(field, false);
	}

	/**
	 * Method to 'pluck' Id's out of a collection of SObjects, from a given Id field
	 *
	 * @param field The Id field to fetch values from
	 * @param includeNulls Set to true to include null values in the returned set
	 *
	 * @return Set of (unique) Id's populated from the given field
	 */
	@NamespaceAccessible
	public virtual Set<Id> getRecordIds(Schema.SObjectField field, Boolean includeNulls)
	{
		Set<Id> result = new Set<Id>();
		List<SObject> records = getRecords();
		for (Integer i = 0; i < numRecords; i++)
		{
			Id foundId = (Id) records[i].get(field);
			if (foundId != null || includeNulls)
			{
				result.add(foundId);
			}
		}
		return result;
	}

	/**
	 * Method to 'pluck' Id's out of a collection of SObjects via a dotted relationship path
	 *
	 * @param fieldWithDotRelation The dotted relationship path (e.g. 'Owner.ContactId') to pluck the Id's from
	 *
	 * @return Set of Id's populated from the resolved relationship field, excluding null values
	 */
	@NamespaceAccessible
	public virtual Set<Id> getRecordIdsFromRelationship(String fieldWithDotRelation)
	{
		Set<Id> result = new Set<Id>();
		List<String> relationshipParts = fieldWithDotRelation.split('\\.');
		List<SObject> records = getRecords();
		for (Integer i = 0; i < numRecords; i++)
		{
			Id foundId = (Id) records[i].getSObject(relationshipParts[0])?.get(relationshipParts[1]);
			if (foundId != null)
			{
				result.add(foundId);
			}
		}
		return result;
	}

	@NamespaceAccessible
	public virtual override Object getType()
	{
		return getSObjectType();
	}

	/**
	 * @return Return the SObjectType of the SObjects contained in the domain
	 */
	@NamespaceAccessible
	public virtual SObjectType getSObjectType()
	{
		return this.sObjectDescribe.getSObjectType();
	}

	/**
	 * Adds an error message to the records in the domain
	 *
	 * @param message The error message to add to each record
	 */
	@NamespaceAccessible
	public virtual void addError(String message)
	{
		List<SObject> records = getRecords();
		for (Integer i = 0; i < numRecords; i++)
		{
			SObject record = records[i];
			record.addError(error(message, record));
		}
	}

	/**
	 * Adds an error message to the a field records in the domain
	 *
	 * @param field The field where the error should be reported
	 * @param message The error message to add to the given field on each record
	 */
	@NamespaceAccessible
	public virtual void addError(Schema.SObjectField field, String message)
	{
		List<SObject> records = getRecords();
		for (Integer i = 0; i < numRecords; i++)
		{
			SObject record = records[i];
			record.addError(field, error(message, record, field));
		}
	}

	/**
	 * Clear the field value on all the records of the domain
	 * @param field The field to nullify
	 */
	@NamespaceAccessible
	public virtual void clearField(Schema.SObjectField field)
	{
		clearFields(new Set<Schema.SObjectField>{ field });
	}

	/**
	 * Clear the field values on all the records of the domain
	 * @param fields The fields to nullify
	 */
	@NamespaceAccessible
	public virtual void clearFields(Set<Schema.SObjectField> fields)
	{
		List<SObject> records = getRecords();
		for (Integer i = 0; i < numRecords; i++)
		{
			SObject record = records[i];
			for (SObjectField field : fields)
			{
				record.put(field, null);
			}
		}
	}

	/**
	 * Ensures logging of errors in the Domain context for later assertions in tests
	 *
	 * @param message
	 * @param record
	 *
	 * @return Returns the Error message
	 **/
	@NamespaceAccessible
	protected virtual String error(String message, SObject record)
	{
		return Errors.error(this, message, record);
	}

	/**
	 * Ensures logging of errors in the Domain context for later assertions in tests
	 *
	 * @param message
	 * @param record
	 * @param field
	 *
	 * @return Returns the Error message
	 **/
	@NamespaceAccessible
	protected virtual String error(String message, SObject record, Schema.SObjectField field)
	{
		return fflib_SObjects.Errors.error(this, message, record, field);
	}

	/**
	 * @param field The SObjectField reference of the type Id
	 *
	 * @return Return a set with all the Id values of the given field
	 */
	@TestVisible
	@NamespaceAccessible
	protected Set<Id> getIdFieldValues(Schema.SObjectField field)
	{
		Set<Id> result = new Set<Id>();
		List<SObject> records = getRecords();
		for (Integer i = 0; i < numRecords; i++)
		{
			result.add((Id) records[i].get(field));
		}
		return result;
	}

	/**
	 * @param field The SObjectField reference of the type String
	 *
	 * @return Return a set with all the String values of the given field
	 */
	@TestVisible
	@NamespaceAccessible
	protected Set<String> getStringFieldValues(Schema.SObjectField field)
	{
		return getStringFieldValues(field, true);
	}

	/**
	 * @param field The SObjectField reference of the type String
	 * @param includeNulls Set to false to exclude null/blank values from the returned set
	 *
	 * @return Return a set with the String values of the given field
	 */
	@TestVisible
	@NamespaceAccessible
	protected Set<String> getStringFieldValues(Schema.SObjectField field, Boolean includeNulls)
	{
		Set<String> result = new Set<String>();
		List<SObject> records = getRecords();
		for (Integer i = 0; i < numRecords; i++)
		{
			String foundString = (String) records[i].get(field);
			if (String.isNotBlank(foundString) || includeNulls)
			{
				result.add(foundString);
			}
		}
		return result;
	}

	/**
	 * @param field The SObjectField reference
	 *
	 * @return Return a set with all the values of the given field
	 */
	@TestVisible
	@NamespaceAccessible
	protected virtual Set<Object> getFieldValues(Schema.SObjectField field)
	{
		Set<Object> result = new Set<Object>();
		List<SObject> records = getRecords();
		for (Integer i = 0; i < numRecords; i++)
		{
			result.add(records[i].get(field));
		}
		return result;
	}

	/**
	 * @param field The Schema.SObjectField to compare against the given value
	 * @param value The given value of the records field to include in the return
	 *
	 * @return A list with only the SObjects where the given field has the provided value
	 */
	@NamespaceAccessible
	protected virtual List<SObject> getRecordsByFieldValue(Schema.SObjectField field, Object value)
	{
		return getRecordsByFieldValues(field, new Set<Object>{value});
	}

	/**
	 * @param field The Schema.SObjectField to compare against the given value
	 * @param values The given values of the records field to include in the return
	 *
	 * @return A list with only the SObjects where the given field value is part of the provided values
	 */
	@NamespaceAccessible
	protected virtual List<SObject> getRecordsByFieldValues(Schema.SObjectField field, Set<Object> values)
	{
		List<SObject> result = new List<SObject>();
		List<SObject> records = getRecords();
		for (Integer i = 0; i < numRecords; i++)
		{
			SObject record = records[i];
			if (values?.contains(record.get(field)))
			{
				result.add(record);
			}
		}
		return result;
	}

	/**
	 * @param field The Schema.SObjectField to check its value for a Blank value
	 *
	 * @return A list with only the SObjects where the given field value is either null or '')
	 */
	@NamespaceAccessible
	protected virtual List<SObject> getRecordsWithBlankFieldValues(Schema.SObjectField field)
	{
		return getRecordsWithBlankFieldValues(
				new Set<Schema.SObjectField> {field}
		);
	}

	/**
	 * @param fields The Schema.SObjectFields to check their value for a Blank value
	 *
	 * @return A list with only the SObjects where the at least one given field value is either null or '')
	 */
	@NamespaceAccessible
	protected virtual List<SObject> getRecordsWithBlankFieldValues(Set<Schema.SObjectField> fields)
	{
		List<SObject> result = new List<SObject>();
		List<SObject> records = getRecords();
		for (Integer i = 0; i < numRecords; i++)
		{
			SObject record = records[i];
			for (SObjectField field : fields)
			{
				if (String.isNotBlank(String.valueOf(record.get(field)))) continue;

				result.add(record);
				break;
			}
		}
		return result;
	}

	/**
	 * @param fields The Schema.SObjectFields to check their value for a Blank value
	 *
	 * @return A list with only the SObjects where all given field values are either null or ''
	 */
	@NamespaceAccessible
	protected virtual List<SObject> getRecordsWithAllBlankFieldValues(Set<Schema.SObjectField> fields)
	{
		List<SObject> result = new List<SObject>();
		List<SObject> records = getRecords();
		for (Integer i = 0; i < numRecords; i++)
		{
			SObject record = records[i];
			Boolean allBlank = true;
			for (SObjectField field : fields)
			{
				if (String.isNotBlank(String.valueOf(record.get(field))))
				{
					allBlank = false;
					break;
				}
			}
			if (allBlank) result.add(record);
		}
		return result;
	}

	/**
	 * @param field The Schema.SObjectField to check its value for a Non-Blank value
	 *
	 * @return A list with only the SObjects where the given field value is not null or ''
	 */
	@NamespaceAccessible
	protected virtual List<SObject> getRecordsWithNotBlankFieldValues(Schema.SObjectField field)
	{
		return getRecordsWithNotBlankFieldValues(
				new Set<Schema.SObjectField> {field}
		);
	}

	/**
	 * @param fields The Schema.SObjectFields to check their value for a Non-Blank value
	 *
	 * @return A list with only the SObjects where the at least one given field value not null or ''
	 */
	@NamespaceAccessible
	protected virtual List<SObject> getRecordsWithNotBlankFieldValues(Set<Schema.SObjectField> fields)
	{
		List<SObject> result = new List<SObject>();
		List<SObject> records = getRecords();
		for (Integer i = 0; i < numRecords; i++)
		{
			SObject record = records[i];
			for (SObjectField field : fields)
			{
				if (String.isNotBlank(String.valueOf(record.get(field))))
				{
					result.add(record);
					break;
				}
			}
		}
		return result;
	}

	/**
	 * @param fields The Schema.SObjectFields to check their value for a Non-Blank value
	 *
	 * @return A list with only the SObjects where all given field values are not null or ''
	 */
	@NamespaceAccessible
	protected virtual List<SObject> getRecordsWithAllNotBlankFieldValues(Set<Schema.SObjectField> fields)
	{
		List<SObject> result = new List<SObject>();
		List<SObject> records = getRecords();
		for (Integer i = 0; i < numRecords; i++)
		{
			SObject record = records[i];
			Boolean allNonBlank = true;
			for (SObjectField field : fields)
			{
				if (String.isBlank(String.valueOf(record.get(field))))
				{
					allNonBlank = false;
					break;
				}
			}
			if (allNonBlank) result.add(record);
		}
		return result;
	}

	/**
	 * Modifies a value of a field for all records in the domain
	 *
	 * @param field The reference to the SObjectField to be modified
	 * @param value The value to store in the given SObjectField
	 */
	@NamespaceAccessible
	protected virtual void setFieldValue(Schema.SObjectField field, Object value)
	{
		List<SObject> records = getRecords();
		for (Integer i = 0; i < numRecords; i++)
		{
			records[i].put(field, value);
		}
	}

	/**
	 * @param fieldToCheck The SObjectField to match the key against in the provided map
	 * @param fieldToUpdate The SObjectField to store the mapped value when the key matches the value in the fieldToUpdate field
	 * @param values Map of values to store by the fieldToCheck fields value
	 */
	@NamespaceAccessible
	protected virtual void setFieldValueByMap(
			Schema.SObjectField fieldToCheck,
			Schema.SObjectField fieldToUpdate,
			Map<Object, Object> values)
	{
		List<SObject> records = getRecords();
		for (Integer i = 0; i < numRecords; i++)
		{
			SObject record = records[i];
			Object keyValue = record.get(fieldToCheck);
			if (values?.containsKey(keyValue))
			{
				record.put(fieldToUpdate, values.get(keyValue));
			}
		}
	}

	/**
	 * Method to easily construct a Map from a List of SObjects, having a field from the SObject being set as key.
	 * E.g. used when preparing queried records to be easily accessible (grouped) by a queried field
	 *
	 * @param identifierField SObjectField whose value should be used as the record-identifier (map key)
	 * @param toLowerCase Set to true to lowercase the resulting map keys (case-insensitive grouping)
	 *
	 * @return Map keyed by the identifierField value, containing the List of SObjects sharing that value
	 *
	 * @throws fflib_Objects.InvalidValueException when a record has no value for the requested identifier field
	 * @throws System.SObjectException when the SObjectField doesn't belong/exist on the provided record
	 */
	@NamespaceAccessible
	public virtual Map<String, List<SObject>> groupRecordsByFieldValue(Schema.SObjectField identifierField, Boolean toLowerCase)
	{
		Map<String, List<SObject>> result = new Map<String, List<SObject>>();
		List<SObject> records = getRecords();
		for (Integer i = 0; i < numRecords; i++)
		{
			SObject record = records[i];
			String recordKey = String.valueOf(record.get(identifierField));

			if (String.isBlank(recordKey))
			{
				throw new fflib_Objects.InvalidValueException('No value was set for ' + identifierField + ' on ' + record);
			}
			if (toLowerCase)
			{
				recordKey = recordKey.toLowerCase();
			}

			List<SObject> existingRecordsForKey = result.get(recordKey);
			if (existingRecordsForKey != null)
			{
				existingRecordsForKey.add(record);
			}
			else
			{
				result.put(recordKey, new List<SObject>{ record });
			}
		}
		return result;
	}

	/**
	 * Method to easily construct a Map from a List of SObjects, having a field from the SObject being set as key.
	 * E.g. used when preparing queried records to be easily accessible (grouped) by a queried field
	 *
	 * @param identifierField SObjectField whose value should be used as the record-identifier (map key)
	 *
	 * @return Map keyed by the identifierField value, containing the List of SObjects sharing that value
	 *
	 * @throws fflib_Objects.InvalidValueException when a record has no value for the requested identifier field
	 * @throws System.SObjectException when the SObjectField doesn't belong/exist on the provided record
	 */
	@NamespaceAccessible
	public virtual Map<String, List<SObject>> groupRecordsByFieldValue(Schema.SObjectField identifierField)
	{
		return groupRecordsByFieldValue(identifierField, false);
	}

	/**
	 * Method to retrieve a list of Schema.PicklistEntry with label and (api) value for any object
	 *
	 * @param objectType String value of the object
	 * @param selectedField String value of the picklist (multi-select) field
	 *
	 * @return List containing the picklist entry describes
	 *
	 * @throws fflib_Objects.InvalidValueException when the SObjectType or field cannot be found
	 */
	@NamespaceAccessible
	public virtual List<Schema.PicklistEntry> getPicklistValues(String objectType, String selectedField)
	{
		fflib_SObjectDescribe objectDescribe = fflib_SObjectDescribe.getDescribe(objectType);
		if (objectDescribe == null)
		{
			throw new fflib_Objects.InvalidValueException('The provided SObjectType ' + objectType + ' seems to be invalid (not found in Global Describe)');
		}

		SObjectField field = objectDescribe.getDescribe().fields.getMap().get(selectedField.toLowerCase());
		if (field == null)
		{
			throw new fflib_Objects.InvalidValueException('No ' + selectedField + ' field seems to exist on ' + objectType);
		}

		return field.getDescribe().getPicklistValues();
	}

	/**
	 * Method to retrieve a list of Strings with the (upper-cased) label values of a picklist
	 *
	 * @param objectType String value of the object
	 * @param selectedField String value of the picklist (multi-select) field
	 *
	 * @return List containing the picklist values as upper-cased strings
	 */
	@NamespaceAccessible
	public virtual List<String> getPicklistValuesToStrings(String objectType, String selectedField)
	{
		List<Schema.PicklistEntry> picklistValues = getPicklistValues(objectType, selectedField);
		List<String> result = new List<String>();
		for (Integer i = 0, j = picklistValues.size(); i < j; i++)
		{
			result.add(picklistValues[i].getLabel().toUpperCase());
		}
		return result;
	}

	/**
	 * @param sObjField The Picklist field in which the provided value should be checked
	 * @param sObjType The SObjectType to which the picklist belongs (cannot be reliably derived from SObjectField alone, hence a separate input)
	 * @param value The value which is checked
	 *
	 * @return True when the value is a valid entry for the provided picklist field, false otherwise or when value was blank
	 */
	@NamespaceAccessible
	public virtual Boolean isValidPicklistValue(Schema.SObjectField sObjField, Schema.SObjectType sObjType, String value)
	{
		if (String.isBlank(value))
		{
			return false;
		}

		List<Schema.PicklistEntry> picklistValues = getPicklistValues(String.valueOf(sObjType), String.valueOf(sObjField));
		for (Integer i = 0, j = picklistValues.size(); i < j; i++)
		{
			if (picklistValues[i].getValue().equalsIgnoreCase(value))
			{
				return true;
			}
		}

		return false;
	}

	/**
	 * Ensures logging of errors in the Domain context for later assertions in tests
	 */
	@NamespaceAccessible
	public virtual class ErrorFactory
	{
		private List<Error> errorList = new List<Error>();

		private ErrorFactory() {	}

		@NamespaceAccessible
		public String error(String message, SObject record)
		{
			return error(null, message, record);
		}

		@NamespaceAccessible
		public String error(fflib_SObjects domain, String message, SObject record)
		{
			ObjectError objectError = new ObjectError();
			objectError.domain = domain;
			objectError.message = message;
			objectError.record = record;
			errorList.add(objectError);
			return message;
		}

		@NamespaceAccessible
		public String error(String message, SObject record, SObjectField field)
		{
			return error(null, message, record, field);
		}

		@NamespaceAccessible
		public String error(fflib_ISObjects domain, String message, SObject record, SObjectField field)
		{
			FieldError fieldError = new FieldError();
			fieldError.domain = domain;
			fieldError.message = message;
			fieldError.record = record;
			fieldError.field = field;
			errorList.add(fieldError);
			return message;
		}

		@NamespaceAccessible
		public List<Error> getAll()
		{
			return errorList.clone();
		}

		@NamespaceAccessible
		public void clearAll()
		{
			errorList.clear();
		}
	}

	/**
	 * Ensures logging of errors in the Domain context for later assertions in tests
	 **/
	@NamespaceAccessible
	public virtual class FieldError extends ObjectError
	{
		@NamespaceAccessible
		public SObjectField field;

		@NamespaceAccessible
		public FieldError()	{ }
	}

	/**
	 * Ensures logging of errors in the Domain context for later assertions in tests
	 **/
	@NamespaceAccessible
	public virtual class ObjectError extends Error
	{
		@NamespaceAccessible
		public SObject record;

		@NamespaceAccessible
		public ObjectError() { }
	}

	/**
	 * Ensures logging of errors in the Domain context for later assertions in tests
	 **/
	@NamespaceAccessible
	public abstract class Error
	{
		@NamespaceAccessible
		public String message;
		@NamespaceAccessible
		public fflib_ISObjects domain;
	}
}