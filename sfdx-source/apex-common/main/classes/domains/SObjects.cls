/**
 * File Name: SObjects
 * Description: Primitive domain for the object type SObject
 *
 * @author : architect ir. Wilhelmus G.J. Velzeboer

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above author notice,
this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.
- Neither the name of the author nor the names of its contributors
may be used to endorse or promote products derived from this software without
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
public virtual class SObjects
		extends Objects
		implements fflib_SObjects
{
	protected Schema.DescribeSObjectResult SObjectDescribe { get; private set; }

	/**
	 * Class constructors
	 *
	 * @param objects The Objects of type SObjectType, to contain inside the domain
	 */
	public SObjects(List<Object> objects)
	{
		// todo - assert of objects of type SObject
		this((List<SObject>) objects);
	}

	/**
	 * Class constructor
	 *
	 * @param records The records to contain inside the domain
	 */
	public SObjects(List<SObject> records)
	{
		this(records, records.getSObjectType());
	}

	/**
	 * Class constructor
	 *
	 * @param records The records to contain inside the domain
	 * @param sObjectType The SObjectType of the records
	 */
	public SObjects(List<SObject> records, Schema.SObjectType sObjectType)
	{
		super(records, sObjectType);
		SObjectDescribe = sObjectType.getDescribe();
	}


	/**
	 * @return Return the SObjectType of the SObjects contained in the domain
	 */
	public virtual SObjectType getSObjectType()
	{
		return SObjectDescribe.getSObjectType();
	}

	/**
	 * @return The object type of the Domain
	 */
	public virtual override Object getType()
	{
		return getSObjectType();
	}

	/**
	 * @param sObjectField The Schema.SObjectField to get their Id values
	 *
	 * @return The Date values of the given sObjectField, null values are omitted
	 */
	protected virtual Dates getDateFieldValues(Schema.SObjectField sObjectField)
	{
		Set<Date> result = new Set<Date>();
		for (SObject record : getRecords())
		{
			Object fieldValue = record.get(sObjectField);
			if (fieldValue == null) continue;
			result.add((Date) fieldValue);
		}
		return new Dates(result);
	}

	/**
	 * @param sObjectField The Schema.SObjectField to get their Id values
	 * @param criteria The criteria condition that must be met to include the value in the return
	 *
	 * @return The Date values of the given sObjectField, null values are omitted
	 */
	protected virtual Dates getDateFieldValues(Schema.SObjectField sObjectField, fflib_Criteria criteria)
	{
		return new SObjects(getRecords(criteria))
				.getDateFieldValues(sObjectField);
	}

	/**
	 * @param sObjectField The Schema.SObjectField to get their Id values
	 *
	 * @return The DateTime values of the given sObjectField, null values are omitted
	 */
	protected virtual DateTimes getDateTimeFieldValues(Schema.SObjectField sObjectField)
	{
		Set<DateTime> result = new Set<DateTime>();
		for (SObject record : getRecords())
		{
			Object fieldValue = record.get(sObjectField);
			if (fieldValue == null) continue;
			result.add((DateTime) fieldValue);
		}
		return new DateTimes(result);
	}

	/**
	 * @param sObjectField The Schema.SObjectField to get their Id values
	 * @param criteria The criteria condition that must be met to include the value in the return
	 *
	 * @return The DateTime values of the given sObjectField, null values are omitted
	 */
	protected virtual DateTimes getDateTimeFieldValues(Schema.SObjectField sObjectField, fflib_Criteria criteria)
	{
		return new SObjects(getRecords(criteria))
				.getDateTimeFieldValues(sObjectField);
	}

	/**
	 * @param sObjectField The Schema.SObjectField to get their Id values
	 *
	 * @return The Decimal values of the given sObjectField, null values are omitted
	 */
	protected virtual Decimals getDecimalFieldValues(Schema.SObjectField sObjectField)
	{
		Set<Decimal> result = new Set<Decimal>();
		for (SObject record : getRecords())
		{
			Object fieldValue = record.get(sObjectField);
			if (fieldValue == null) continue;
			result.add((Decimal) fieldValue);
		}
		return new Decimals(result);
	}

	/**
	 * @param sObjectField The Schema.SObjectField to get their Id values
	 * @param criteria The criteria condition that must be met to include the value in the return
	 *
	 * @return The Decimal values of the given sObjectField, null values are omitted
	 */
	protected virtual Decimals getDecimalFieldValues(Schema.SObjectField sObjectField, fflib_Criteria criteria)
	{
		return new SObjects(getRecords(criteria))
				.getDecimalFieldValues(sObjectField);
	}

	/**
	 * @param sObjectField The Schema.SObjectField to get their Id values
	 *
	 * @return The Double values of the given sObjectField, null values are omitted
	 */
	protected virtual Doubles getDoubleFieldValues(Schema.SObjectField sObjectField)
	{
		Set<Double> result = new Set<Double>();
		for (SObject record : getRecords())
		{
			Object fieldValue = record.get(sObjectField);
			if (fieldValue == null) continue;
			result.add((Double) fieldValue);
		}
		return new Doubles(result);
	}

	/**
	 * @param sObjectField The Schema.SObjectField to get their Id values
	 * @param criteria The criteria condition that must be met to include the value in the return
	 *
	 * @return The Double values of the given sObjectField, null values are omitted
	 */
	protected virtual Doubles getDoubleFieldValues(Schema.SObjectField sObjectField, fflib_Criteria criteria)
	{
		return new SObjects(getRecords(criteria))
				.getDoubleFieldValues(sObjectField);
	}

	/**
	 * @param sObjectField The Schema.SObjectField to get their Id values
	 *
	 * @return The Id values of the given sObjectField, null values are omitted
	 */
	protected virtual Ids getIdFieldValues(Schema.SObjectField sObjectField)
	{
		Set<Id> result = new Set<Id>();
		for (SObject record : getRecords())
		{
			Object fieldValue = record.get(sObjectField);
			if (fieldValue == null) continue;
			result.add(Id.valueOf(String.valueOf(fieldValue)));
		}
		return new Ids(result);
		// todo - alternative return to avoid code duplications: return new Ids(getFieldValues(sObjectField));
	}

	/**
	 * @param sObjectField The Schema.SObjectField to get their Id values
	 * @param criteria The criteria condition that must be met to include the value in the return
	 *
	 * @return The Id values of the given sObjectField, null values are omitted
	 */
	protected virtual Ids getIdFieldValues(Schema.SObjectField sObjectField, fflib_Criteria criteria)
	{
		return new SObjects(getRecords(criteria))
				.getIdFieldValues(sObjectField);
	}

	/**
	 * @param sObjectField The Schema.SObjectField to get their values
	 *
	 * @return The Integer values of the given sObjectField, null values are omitted
	 */
	protected virtual Integers getIntegerFieldValues(Schema.SObjectField sObjectField)
	{
		Set<Integer> result = new Set<Integer>();
		for (SObject record : getRecords())
		{
			Object fieldValue = record.get(sObjectField);
			if (fieldValue == null) continue;
			result.add(Integer.valueOf(fieldValue));
		}
		return new Integers(result);
	}

	/**
	 * @param sObjectField The Schema.SObjectField to get their values
	 * @param criteria The criteria condition that must be met to include the value in the return
	 *
	 * @return The Integer values of the given sObjectField, null values are omitted
	 */
	protected virtual Integers getIntegerFieldValues(Schema.SObjectField sObjectField, fflib_Criteria criteria)
	{
		return new SObjects(getRecords(criteria))
				.getIntegerFieldValues(sObjectField);
	}

	/**
	 * @param sObjectField The Schema.SObjectField to get their values
	 *
	 * @return The values of the given sObjectField, null values are omitted
	 */
	protected virtual Objects getFieldValues(Schema.SObjectField sObjectField)
	{
		Set<Object> result = new Set<Object>();
		for (SObject record : getRecords())
		{
			Object fieldValue = record.get(sObjectField);
			if (fieldValue == null) continue;
			result.add(fieldValue);
		}
		return new Objects(result);
	}

	/**
	 * @param sObjectField The Schema.SObjectField to get their values
	 * @param criteria The criteria condition that must be met to include the value in the return
	 *
	 * @return The values of the given sObjectField, null values are omitted
	 */
	protected virtual Objects getFieldValues(Schema.SObjectField sObjectField, fflib_Criteria criteria)
	{
		return new SObjects(getRecords(criteria))
				.getFieldValues(sObjectField);
	}

	/**
	 * @param sObjectField The Schema.SObjectField to get their values
	 *
	 * @return The Long values of the given sObjectField, null values are omitted
	 */
	protected virtual Longs getLongFieldValues(Schema.SObjectField sObjectField)
	{
		Set<Long> result = new Set<Long>();
		for (SObject record : getRecords())
		{
			Object fieldValue = record.get(sObjectField);
			if (fieldValue == null) continue;
			result.add((Long) fieldValue);
		}
		return new Longs(result);
	}

	/**
	 * @param sObjectField The Schema.SObjectField to get their values
	 * @param criteria The criteria condition that must be met to include the value in the return
	 *
	 * @return The Long values of the given sObjectField, null values are omitted
	 */
	protected virtual Longs getLongFieldValues(Schema.SObjectField sObjectField, fflib_Criteria criteria)
	{
		return new SObjects(getRecords(criteria))
				.getLongFieldValues(sObjectField);
	}

	/**
	 * @return Return the SObject records contained in the domain
	 */
	public virtual List<SObject> getRecords()
	{
		return (List<SObject>) getObjects();
	}

	/**
	 * @param criteria The condition the returned record must meet
	 *
	 * @return Return the SObject records contained in the domain
	 */
	public virtual List<SObject> getRecords(fflib_Criteria criteria)
	{
		List<SObject> result = new List<SObject>();
		for (SObject record : getRecords())
		{
			if (!criteria.evaluate(record)) continue;

			result.add(record);
		}
		return result;
	}

	/**
	 * @param sObjectField The Schema.SObjectField to compare against the given value
	 * @param value The given value of the records sObjectField to include in the return
	 *
	 * @return A list with only the SObjects where the given sObjectField has the provided value
	 */
	protected virtual List<SObject> getRecordsByFieldValue(Schema.SObjectField sObjectField, Object value)
	{
		return getRecordsByFieldValues(sObjectField, new Objects(value));
	}

	/**
	 * @param sObjectField The Schema.SObjectField to compare against the given value
	 * @param values The given values of the records sObjectField to include in the return
	 *
	 * @return A list with only the SObjects where the given sObjectField value is part of the provided values
	 */
	protected virtual List<SObject> getRecordsByFieldValues(Schema.SObjectField sObjectField, Set<Object> values)
	{
		return getRecordsByFieldValues(sObjectField, new Objects(values));
	}

	/**
	 * @param sObjectField The Schema.SObjectField to compare against the given value
	 * @param values The given values of the records sObjectField to include in the return
	 *
	 * @return A list with only the SObjects where the given sObjectField value is part of the provided values
	 */
	protected virtual List<SObject> getRecordsByFieldValues(Schema.SObjectField sObjectField, Objects values)
	{
		List<SObject> result = new List<SObject>();
		for (SObject record : getRecords())
		{
			if (values.contains(record.get(sObjectField)))
			{
				result.add(record);
			}
		}
		return result;
	}

	/**
	 * @param sObjectField The Schema.SObjectField to check its value for a Blank value
	 *
	 * @return A list with only the SObjects where the given sObjectField value is either null or '')
	 */
	protected virtual List<SObject> getRecordsWithBlankFieldValues(Schema.SObjectField sObjectField)
	{
		return getRecordsWithBlankFieldValues(
				new Set<Schema.SObjectField> {sObjectField}
		);
	}

	/**
	 * @param sObjectFields The Schema.SObjectField's to check their value for a Blank value
	 *
	 * @return A list with only the SObjects where the at least one given sObjectField value is either null or '')
	 */
	protected virtual List<SObject> getRecordsWithBlankFieldValues(Set<Schema.SObjectField> sObjectFields)
	{
		List<SObject> result = new List<SObject>();
		for (SObject record : getRecords())
		{
			for (SObjectField sObjectField : sObjectFields)
			{
				if (String.isBlank((String) record.get(sObjectField)))
				{
					result.add(record);
					break;
				}
			}
		}
		return result;
	}

	/**
	 * @param sObjectFields The Schema.SObjectField's to check their value for a Blank value
	 *
	 * @return A list with only the SObjects where the at least one given sObjectField value is either null or ''
	 */
	protected virtual List<SObject> getRecordsWithAllBlankFieldValues(Set<Schema.SObjectField> sObjectFields)
	{
		List<SObject> result = new List<SObject>();
		for (SObject record : getRecords())
		{
			Boolean allBlank = true;
			for (SObjectField sObjectField : sObjectFields)
			{
				if (String.isNotBlank((String) record.get(sObjectField)))
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
	 * @param sObjectField The Schema.SObjectField to check its value for a Non-Blank value
	 *
	 * @return A list with only the SObjects where the given sObjectField value is not null or ''
	 */
	protected virtual List<SObject> getRecordsWithNotBlankFieldValues(Schema.SObjectField sObjectField)
	{
		return getRecordsWithNotBlankFieldValues(
				new Set<Schema.SObjectField> {sObjectField}
		);
	}

	/**
	 * @param sObjectFields The Schema.SObjectField's to check their value for a Non-Blank value
	 *
	 * @return A list with only the SObjects where the at least one given sObjectField value not null or ''
	 */
	protected virtual List<SObject> getRecordsWithNotBlankFieldValues(Set<Schema.SObjectField> sObjectFields)
	{
		List<SObject> result = new List<SObject>();
		for (SObject record : getRecords())
		{
			for (SObjectField sObjectField : sObjectFields)
			{
				if (String.isBlank((String) record.get(sObjectField)))
				{
					result.add(record);
					break;
				}
			}
		}
		return result;
	}

	/**
	 * @param sObjectFields The Schema.SObjectField's to check their value for a Non-Blank value
	 *
	 * @return A list with only the SObjects where the at least one given sObjectField value is not null or ''
	 */
	protected virtual List<SObject> getRecordsWithAllNotBlankFieldValues(Set<Schema.SObjectField> sObjectFields)
	{
		List<SObject> result = new List<SObject>();
		for (SObject record : getRecords())
		{
			Boolean allBlank = true;
			for (SObjectField sObjectField : sObjectFields)
			{
				if (String.isNotBlank((String) record.get(sObjectField)))
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
	 * @param sObjectField The Schema.SObjectField to get their values
	 *
	 * @return The String values of the given sObjectField
	 */
	protected virtual Strings getStringFieldValues(Schema.SObjectField sObjectField)
	{
		Set<String> result = new Set<String>();
		for (SObject record : getRecords())
		{
			result.add(String.valueOf(record.get(sObjectField)));
		}
		return new Strings(result);
	}

	/**
	 * @param sObjectField The Schema.SObjectField to get their values
	 * @param criteria The criteria condition that must be met to include the value in the return
	 *
	 * @return The String values of the given sObjectField
	 */
	protected virtual Strings getStringFieldValues(Schema.SObjectField sObjectField, fflib_Criteria criteria)
	{
		return new SObjects(getRecords(criteria))
				.getStringFieldValues(sObjectField);
	}


	/**
	 * @param sObjectField The Schema.SObjectField to change its value
	 * @param value The new value for the given sObjectField
	 */
	protected virtual void setFieldValue(Schema.SObjectField sObjectField, Object value)
	{
		for (SObject record : getRecords())
		{
			record.put(sObjectField, value);
		}
	}

	/**
	 * @param sObjectField The Schema.SObjectField to change its value
	 * @param value The new value for the given sObjectField
	 * @param criteria
	 */
	protected virtual void setFieldValue(Schema.SObjectField sObjectField, Object value, fflib_Criteria criteria)
	{
		new SObjects(getRecords(criteria))
				.setFieldValue(sObjectField, value);
	}

	/**
	 * @param sObjectFieldToCheck The SObjectField to match the key against in the provided map
	 * @param sObjectFieldToUpdate The SObjectField to store the mapped value when the key matches the value in the sObjectFieldToUpdate field
	 * @param values Map of values to store by the sObjectFieldToCheck fields value
	 */
	protected virtual void setFieldValueByMap(
			Schema.SObjectField sObjectFieldToCheck,
			Schema.SObjectField sObjectFieldToUpdate,
			Map<Object, Object> values)
	{
		for (SObject record : getRecords())
		{
			Object keyValue = record.get(sObjectFieldToCheck);
			if (values.containsKey(keyValue))
			{
				record.put(sObjectFieldToUpdate, values.get(keyValue));
			}
		}
	}
}