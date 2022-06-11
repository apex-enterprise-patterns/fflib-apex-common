public inherited sharing class fflib_QueryFactory_New
	extends fflib_QueryFactoryBase
	implements fflib_IQueryFactory_New
{
	// ========== fflib_IQueryFactory_New implementation ==========================================
	public fflib_IQueryFactory_New addOrdering(SObjectField field, fflib_QueryFactoryBase.SortOrder direction, Boolean nullsLast)
	{
		super.addOrdering(getFieldTokenPath(field), direction, nullsLast);
		return this;
	}

	public fflib_IQueryFactory_New addOrdering(SObjectField field, fflib_QueryFactoryBase.SortOrder direction)
	{
		super.addOrdering(getFieldTokenPath(field), direction);
		return this;
	}

	public fflib_IQueryFactory_New assertIsAccessible()
	{
		fflib_SecurityUtils.checkObjectIsReadable(table);
		return this;
	}

	public override Boolean equals(Object obj)
	{
		if (!(obj instanceof fflib_IQueryFactoryBase))
		{
			return false;
		}

		if ( !(((fflib_QueryFactory_New)obj).getTable() != this.getTable()) )
		{
			return false;
		}

		if ( !(((fflib_QueryFactory_New)obj).getFields().size() != this.getFields().size()) )
		{
			return false;
		}

		return ((fflib_QueryFactory_New)obj).toSOQL() == this.toSOQL();
	}

	public fflib_IQueryFactory_New selectField(String fieldName, SObjectType relatedSObjectType)
	{
		super.selectField(getFieldPath(fieldName, relatedSObjectType));
		return this;
	}

	public fflib_IQueryFactory_New selectField(SObjectField field)
	{
		if(field == null)
		{
			throw new InvalidFieldException(null, this.table);
		}

		if (enforceFLS)
		{
			fflib_SecurityUtils.checkFieldIsReadable(table, field);
		}

		super.selectField( getFieldTokenPath(field) );
		return this;
	}

	public fflib_IQueryFactory_New selectFields(List<SObjectField> fields)
	{
		for(Schema.SObjectField token:fields)
		{
			if(token == null)
			{
				throw new InvalidFieldException();
			}

			if (enforceFLS)
			{
				fflib_SecurityUtils.checkFieldIsReadable(table, token);
			}

			super.selectField( getFieldTokenPath(token) );
		}
		return this;
	}

	public fflib_IQueryFactory_New selectFields(Set<SObjectField> fields)
	{
		selectFields(new List<SObjectField>(fields));
		return this;
	}

	public fflib_IQueryFactory_New selectFieldSet(FieldSet fieldSet)
	{
		selectFieldSet(fieldSet, true);
		return this;
	}

	public fflib_IQueryFactory_New selectFieldSet(FieldSet fieldSet, Boolean allowCrossObject)
	{
		if (fieldSet.getSObjectType() != table)
		{
			throw new InvalidFieldSetException('Field set "' + fieldSet.getName() + '" is not for SObject type "' + table + '"');
		}

		for (FieldSetMember field: fieldSet.getFields())
		{
			if (!allowCrossObject && field.getFieldPath().contains('.'))
			{
				throw new InvalidFieldSetException('Cross-object fields not allowed and field "' + field.getFieldPath() + '"" is a cross-object field.');
			}
			super.selectField( getFieldTokenPath(field.getSObjectField()) );
		}

		return this;
	}

	public fflib_IQueryFactory_New setEnforceFLS(Boolean enforce)
	{
		enforceFLS = enforce;
		return this;
	}

	public fflib_IQueryFactory_New setOrdering(SObjectField field, fflib_QueryFactoryBase.SortOrder direction, Boolean nullsLast)
	{
		super.setOrdering(new Ordering(getFieldTokenPath(field), direction, nullsLast));
		return this;
	}

	public fflib_IQueryFactory_New setOrdering(SObjectField field, fflib_QueryFactoryBase.SortOrder direction)
	{
		setOrdering(field, direction, false);
		return this;
	}

	public fflib_IQueryFactory_New subselectQuery(SObjectType related)
	{
		subselectQuery(related, false);
		return this;
	}

	public fflib_IQueryFactory_New subselectQuery(SObjectType related, Boolean assertIsAccessible)
	{
		return setSubselectQuery(getChildRelationship(related), assertIsAccessible);
	}

	public fflib_IQueryFactory_New subselectQuery(ChildRelationship relationship)
	{
		return setSubselectQuery(relationship, false);
	}

	public fflib_IQueryFactory_New subselectQuery(ChildRelationship relationship, Boolean assertIsAccessible)
	{
		return setSubselectQuery(relationship, assertIsAccessible);
	}

	// ========== Private Construction Logic ======================================================
	private fflib_QueryFactory_New(SObjectType table)
	{
		this.table = table;
	}

	// ========== Private Instance Logic ==========================================================
	private Boolean assertIsAccessible = false;
	private ChildRelationship relationship;
	private Boolean enforceFLS = false;
	private SObjectType table;

	private ChildRelationship getChildRelationship(SObjectType objType)
	{
		for (ChildRelationship childRow : table.getDescribe().getChildRelationships())
		{
			//occasionally on some standard objects (Like Contact child of Contact) do not have a relationship name.
			//if there is no relationship name, we cannot query on it, so throw an exception.
			if (childRow.getChildSObject() == objType && childRow.getRelationshipName() != null)
			{
				return childRow;
			}
		}

		throw new InvalidSubqueryRelationshipException('Invalid call to subselectQuery.  Invalid relationship for table '+table + ' and objtype='+objType);
	}

	private String getFieldPath(String fieldName, SObjectType relatedSObjectType)
	{
		if(!fieldName.contains('.'))
		{
			Schema.SObjectField token = fflib_SObjectDescribe.getDescribe(this.table).getField(fflib_QueryFactory_New.keyify(fieldName));
			if (token == null)
			{
				throw new InvalidFieldException(fieldName, this.table);
			}
			if (enforceFLS)
			{
				fflib_SecurityUtils.checkFieldIsReadable(this.table, token);
			}
			return getFieldTokenPath(token);
		}

		List<String> fieldPath = new List<String>();
		SObjectType lastSObjectType = this.table;
		Iterator<String> i = fieldName.split('\\.').iterator();
		while(i.hasNext())
		{
			String field = i.next();
			Schema.SObjectField token = fflib_SObjectDescribe.getDescribe(lastSObjectType).getField(fflib_QueryFactory_New.keyify(field));
			DescribeFieldResult tokenDescribe = token != null ? token.getDescribe() : null;

			if (token == null)
			{
				throw new InvalidFieldException(field, lastSObjectType);
			}

			if (enforceFLS)
			{
				fflib_SecurityUtils.checkFieldIsReadable(lastSObjectType, token);
			}

			if (i.hasNext() && tokenDescribe.getSoapType() == SoapType.ID)
			{
				List<SObjectType> relatedObjs = tokenDescribe.getReferenceTo(); //if it's polymorphic, it matters which one we use - i.e. Lead.Owner is GROUP|USER and each has different fields.

				if (relatedObjs.size() == 1 || relatedSObjectType == null)
				{
					lastSObjectType = relatedObjs[0]; //caller did not specify the one to use or there's only one so use the first one
				}
				else
				{
					for (SObjectType sot : relatedObjs)
					{
						if (fflib_SObjectDescribe.getDescribe(sot).getDescribe().getSObjectType() == relatedSObjectType)
						{
							lastSObjectType = sot;
							break;
						}
					}
				}

				fieldPath.add(tokenDescribe.getRelationshipName());
				continue;
			}
			else if (!i.hasNext())
			{
				fieldPath.add(tokenDescribe.getName());
				continue;
			}

			throw new NonReferenceFieldException(lastSObjectType + '.' + field + ' is not a lookup or master-detail field but is used in a cross-object query field.');
		}

		return String.join(fieldPath,'.');
	}

	private fflib_IQueryFactory_New setSubselectQuery(ChildRelationship relationship, Boolean assertIsAccessible)
	{
		if (this.relationship != null)
		{
			throw new InvalidSubqueryRelationshipException('Invalid call to subselectQuery.  You may not add a subselect query to a subselect query.');
		}

		fflib_IQueryFactory_New subselectQuery = fflib_QueryFactory_New.newInstance(relationship.getChildSObject());

		if(assertIsAccessible)
		{
			subselectQuery.assertIsAccessible();
		}

		return subselectQuery;
	}

	// ========== Static Mocking Logic ============================================================
	private static Map<SObjectType, fflib_IQueryFactory_New> mockInstanceMap = new Map<SObjectType, fflib_IQueryFactory_New>();

	public static fflib_IQueryFactory_New newInstance(SObjectType table)
	{
		if (table == null)
		{
			throw new InvalidTableException('"table" is required');
		}

		return
			!mockInstanceMap.containsKey(table)
			? new fflib_QueryFactory_New(table)
			: mockInstanceMap.get(table);
	}

	// ========== Static Logic ====================================================================
	@TestVisible
	private static void setMock(SObjectType table, fflib_IQueryFactory_New mock)
	{
		mockInstanceMap.put(table, mock);
	}

	private static String getFieldTokenPath(SObjectField field)
	{
		if(field == null){
			throw new InvalidFieldException('Invalid field: null');
		}
		return field.getDescribe().getName();
	}

	private static String keyify(String value)
	{
		return value?.trim().toLowerCase();
	}

	// ========== Exception Classes ===============================================================
	public class AccessibilityException
			extends Exception
	{

	}

	public class InvalidFieldException
		extends Exception
	{
		private String fieldName;
		private Schema.SObjectType objectType;
		public InvalidFieldException(String fieldName, Schema.SObjectType objectType){
			this.objectType = objectType;
			this.fieldName = fieldName;
			this.setMessage( 'Invalid field \''+fieldName+'\' for object \''+objectType+'\'' );
		}
	}

	public class InvalidFieldSetException
		extends Exception
	{

	}

	public class InvalidSubqueryRelationshipException
		extends Exception
	{

	}

	public class InvalidTableException
		extends Exception
	{

	}

	public class NonReferenceFieldException
		extends Exception
	{

	}
}