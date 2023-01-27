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
public virtual class fflib_SObjects
		extends fflib_Objects
		implements fflib_ISObjects
{

	public Schema.DescribeSObjectResult SObjectDescribe {get; private set;}

	/**
	 * Useful during unit testing to assert at a more granular and robust level for errors raised during the various trigger events
	 **/
	public static ErrorFactory Errors  {get; private set;}

	static
	{
		Errors = new ErrorFactory();
	}

	/**
	 * Class constructor
	 */
	public fflib_SObjects(List<SObject> records)
	{
		super(records);
	}

	public fflib_SObjects(List<SObject> records, Schema.SObjectType sObjectType)
	{
		super(records);
		SObjectDescribe = sObjectType.getDescribe();
	}

	public virtual List<SObject> getRecords()
	{
		return (List<SObject>) getObjects();
	}

	public virtual Set<Id> getRecordIds()
	{
		return new Map<Id, SObject>(getRecords()).keySet();
	}

	public virtual override Object getType()
	{
		return getSObjectType();
	}

	public virtual SObjectType getSObjectType()
	{
		return SObjectDescribe.getSObjectType();
	}

	/**
	 * Adds an error message to the records in the domain
	 *
	 * @param message The error message to add to each record
	 */
	protected void addError(String message)
	{
		for (SObject record : getRecords())
		{
			record.addError(error(message, record));
		}
	}

	/**
	 * Adds an error message to the a field records in the domain
	 *
	 * @param field The field where the error should be reported
	 * @param message The error message to add to the given field on each record
	 */
	@TestVisible
	protected virtual void addError(Schema.SObjectField field, String message)
	{
		for (SObject record : getRecords())
		{
			record.addError(field, error(message, record, field));
		}
	}

	/**
	 * Clear the field value on all the records of the domain
	 * @param field The field to nullify
	 */
	@TestVisible
	protected virtual void clearField(Schema.SObjectField field)
	{
		clearFields(new Set<Schema.SObjectField>{ field });
	}

	/**
	 * Clear the field values on all the records of the domain
	 * @param fields The fields to nullify
	 */
	@TestVisible
	protected virtual void clearFields(Set<Schema.SObjectField> fields)
	{
		for (SObject record : getRecords())
		{
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
	protected Set<Id> getIdFieldValues(Schema.SObjectField field)
	{
		Set<Id> result = new Set<Id>();
		for (SObject record : getRecords())
		{
			result.add((Id) record.get(field));
		}
		return result;
	}

	/**
	 * @param field The SObjectField reference of the type String
	 *
	 * @return Return a set with all the String values of the given field
	 */
	@TestVisible
	protected Set<String> getStringFieldValues(Schema.SObjectField field)
	{
		Set<String> result = new Set<String>();
		for (SObject record : getRecords())
		{
			result.add((String) record.get(field));
		}
		return result;
	}

	/**
	 * @param field The SObjectField reference
	 *
	 * @return Return a set with all the values of the given field
	 */
	@TestVisible
	protected virtual Set<Object> getFieldValues(Schema.SObjectField field)
	{
		Set<Object> result = new Set<Object>();
		for (SObject record : getRecords())
		{
			result.add(record.get(field));
		}
		return result;
	}

	/**
	 * @param field The Schema.SObjectField to compare against the given value
	 * @param value The given value of the records field to include in the return
	 *
	 * @return A list with only the SObjects where the given field has the provided value
	 */
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
	protected virtual List<SObject> getRecordsByFieldValues(Schema.SObjectField field, Set<Object> values)
	{
		List<SObject> result = new List<SObject>();
		for (SObject record : getRecords())
		{
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
	protected virtual List<SObject> getRecordsWithBlankFieldValues(Set<Schema.SObjectField> fields)
	{
		List<SObject> result = new List<SObject>();
		for (SObject record : getRecords())
		{
			for (SObjectField field : fields)
			{
				if (String.isNotBlank((String) record.get(field))) continue;

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
	protected virtual List<SObject> getRecordsWithAllBlankFieldValues(Set<Schema.SObjectField> fields)
	{
		List<SObject> result = new List<SObject>();
		for (SObject record : getRecords())
		{
			Boolean allBlank = true;
			for (SObjectField field : fields)
			{
				if (String.isNotBlank((String) record.get(field)))
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
	protected virtual List<SObject> getRecordsWithNotBlankFieldValues(Set<Schema.SObjectField> fields)
	{
		List<SObject> result = new List<SObject>();
		for (SObject record : getRecords())
		{
			for (SObjectField field : fields)
			{
				if (String.isNotBlank((String) record.get(field)))
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
	protected virtual List<SObject> getRecordsWithAllNotBlankFieldValues(Set<Schema.SObjectField> fields)
	{
		List<SObject> result = new List<SObject>();
		for (SObject record : getRecords())
		{
			Boolean allNonBlank = true;
			for (SObjectField field : fields)
			{
				if (String.isBlank((String) record.get(field)))
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
	protected virtual void setFieldValue(Schema.SObjectField field, Object value)
	{
		for (SObject record : getRecords())
		{
			record.put(field, value);
		}
	}

	/**
	 * @param fieldToCheck The SObjectField to match the key against in the provided map
	 * @param fieldToUpdate The SObjectField to store the mapped value when the key matches the value in the fieldToUpdate field
	 * @param values Map of values to store by the fieldToCheck fields value
	 */
	protected virtual void setFieldValueByMap(
			Schema.SObjectField fieldToCheck,
			Schema.SObjectField fieldToUpdate,
			Map<Object, Object> values)
	{
		for (SObject record : getRecords())
		{
			Object keyValue = record.get(fieldToCheck);
			if (values?.containsKey(keyValue))
			{
				record.put(fieldToUpdate, values.get(keyValue));
			}
		}
	}

	/**
     * Ensures logging of errors in the Domain context for later assertions in tests
     **/
	public virtual class ErrorFactory
	{
		private List<Error> errorList = new List<Error>();

		private ErrorFactory() {	}

		public String error(String message, SObject record)
		{
			return error(null, message, record);
		}

		public String error(fflib_SObjects domain, String message, SObject record)
		{
			ObjectError objectError = new ObjectError();
			objectError.domain = domain;
			objectError.message = message;
			objectError.record = record;
			errorList.add(objectError);
			return message;
		}

		public String error(String message, SObject record, SObjectField field)
		{
			return error(null, message, record, field);
		}

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

		public List<Error> getAll()
		{
			return errorList.clone();
		}

		public void clearAll()
		{
			errorList.clear();
		}
	}

	/**
	 * Ensures logging of errors in the Domain context for later assertions in tests
	 **/
	public virtual class FieldError extends ObjectError
	{
		public SObjectField field;

		public FieldError()	{ }
	}

	/**
	 * Ensures logging of errors in the Domain context for later assertions in tests
	 **/
	public virtual class ObjectError extends Error
	{
		public SObject record;

		public ObjectError() { }
	}

	/**
	 * Ensures logging of errors in the Domain context for later assertions in tests
	 **/
	public abstract class Error
	{
		public String message;
		public fflib_ISObjects domain;
	}
}