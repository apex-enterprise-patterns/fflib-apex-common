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