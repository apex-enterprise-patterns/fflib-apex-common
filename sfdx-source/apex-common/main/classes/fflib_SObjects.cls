/**
 * File Name: fflib_SObjects 
 * Description: 
 * Copyright (c) 2020 Johnson & Johnson
 * @author: architect ir. Wilhelmus G.J. Velzeboer | wvelzebo@its.jnj.com 
 */
public virtual class fflib_SObjects
		extends fflib_Objects
{

	public Schema.DescribeSObjectResult SObjectDescribe {get; private set;}

	/**
	 * Class constructor
	 */
	public fflib_SObjects(List<Object> objects)
	{
		// todo - assert for SObjectType
		this((List<SObject>) objects);
	}

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

	public virtual override Object getType()
	{
		return getSObjectType();
	}

	public virtual SObjectType getSObjectType()
	{
		return SObjectDescribe.getSObjectType();
	}

	protected virtual Set<Object> getFieldValues(Schema.SObjectField sObjectField)
	{
		Set<Object> result = new Set<Object>();
		for (SObject record : getRecords())
		{
			result.add(record.get(sObjectField));
		}
		return result;
	}

	public virtual Schema.SObjectType getObjectType()
	{
		return SObjectDescribe.getSObjectType();
	}

	protected virtual fflib_SObjects selectByFieldValue(Schema.SObjectField sObjectField, Object value)
	{
		return selectByFieldValues(
				sObjectField,
				new Set<Object>{ value }
		);
	}

	protected virtual fflib_SObjects selectByFieldValues(Schema.SObjectField sObjectField, Set<Object> values)
	{
		List<SObject> result = new List<SObject>();
		for (SObject record : getRecords())
		{
			if (values.contains(record.get(sObjectField)))
			{
				result.add(record);
			}
		}
		return new fflib_SObjects(result, getObjectType());
	}

	protected virtual void setFieldValue(Schema.SObjectField sObjectField, Object value)
	{
		for (SObject record : getRecords())
		{
			record.put(sObjectField, value);
		}
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