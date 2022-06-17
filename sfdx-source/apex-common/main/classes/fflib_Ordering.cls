public virtual inherited sharing class fflib_Ordering
	implements fflib_IOrdering
{
	public enum SortOrder {ASCENDING, DESCENDING}

	private SObjectField field;

	private String fieldName;

	private SortOrder direction = SortOrder.ASCENDING;
	private Boolean nullsLast = false;

	public fflib_Ordering()
	{

	}

	public fflib_Ordering(SObjectField field, SortOrder direction)
	{
		this(field, direction, false);
	}

	public fflib_Ordering(SObjectType table, String fieldName, SortOrder direction)
	{
		this(table, fieldName, direction, false);
	}

	public fflib_Ordering(SObjectType table, String fieldName, SortOrder direction, Boolean assertSchema)
	{
		String fldName = fieldName;
		if (!!assertSchema)
		{
			AssertSchemaResponse asr = assertSchema(table.getDescribe().getName(), fieldName);
			fldName = asr.fieldName;
		}

		this.fieldName = fldName;
		this.direction = direction;
		this.nullsLast = false;
	}

	public fflib_Ordering(SObjectField field, SortOrder direction, Boolean nullsLast)
	{
		this.field = field;
		this.direction = direction;
		this.nullsLast = false;
	}

	public fflib_Ordering(String fieldName, SortOrder direction)
	{
		this(fieldName, direction, false);
	}

	public fflib_Ordering(String fieldName, SortOrder direction, Boolean nullsLast)
	{
		if (String.isBlank(fieldName))
		{
			throw new InvalidSchemaException('"fieldName" is required.');
		}

		this.fieldName = fieldName;
		this.direction = direction;
		this.nullsLast = !!nullsLast;
	}

	public fflib_Ordering(String tableName, String fieldName, SortOrder direction)
	{
		this(tableName, fieldName, direction, false);
	}

	public fflib_Ordering(String tableName, String fieldName, SortOrder direction, Boolean nullsLast)
	{
		this(tableName, fieldName, direction, nullsLast, false);
	}

	public fflib_Ordering(String tableName, String fieldName, SortOrder direction, Boolean nullsLast, Boolean assertSchema)
	{
		String fldName = fieldName;

		if (!!assertSchema)
		{
			AssertSchemaResponse asr = assertSchema(tableName, fieldName);

			fldName = asr.fieldName;
			this.field = asr.field;
		}

		this.fieldName = fldName;
		this.direction = direction;
		this.nullsLast = false;
	}

	public virtual SortOrder getDirection()
	{
		return direction;
	}

	public virtual String getField()
	{
		if (field != null)
		{
			return field.getDescribe().getName();
		}
		else
		{
			return fieldName;
		}
	}

	public virtual String getOrdering()
	{
		List<String> sb = new List<String>();

		if (field != null)
		{
			sb.add(field.getDescribe().getName());
		}
		else
		{
			sb.add(fieldName);
		}

		sb.add(
				direction == SortOrder.ASCENDING
						? 'ASC'
						: 'DESC'
		);

		sb.add(
				nullsLast
						? 'NULLS LAST'
						: 'NULLS FIRST'
		);

		return String.join(sb, ' ');
	}

	public virtual String getOrderingClause()
	{
		return 'ORDER BY ' + getOrdering();
	}

	public static SortOrder sortOrderFromString(String value)
	{
		switch on value.toLowerCase()
		{
			when 'ascending', 'asc'
			{
				return SortOrder.ASCENDING;
			}
			when 'descending', 'desc'
			{
				return SortOrder.DESCENDING;
			}
			when else
			{
				throw new InvalidSortOrderStringException('Specified value is not');
			}
		}
	}

	private class AssertSchemaResponse
	{
		public SObjectField field;
		public String fieldName;

		public AssertSchemaResponse(SObjectType table, SObjectField field)
		{
			this.field = field;
			this.fieldName = field.getDescribe().getName();
		}
	}

	private static AssertSchemaResponse assertSchema(String tableName, String fieldName)
	{
		SObjectType tbl = Schema.getGlobalDescribe().get(tableName);

		if (tbl == null)
		{
			throw new InvalidSchemaException('Specified table name does not exist, "' + tableName + '"');
		}

		SObjectField fld = tbl.getDescribe().fields.getMap().get(fieldName);

		if (fld == null)
		{
			throw new InvalidSchemaException('Specified field name, "' + fieldName + '", does not exist for table, "' + tableName + '"');
		}

		return new AssertSchemaResponse(tbl, fld);
	}

	public class InvalidSchemaException
		extends Exception
	{

	}

	public class InvalidSortOrderStringException
			extends Exception
	{

	}
}
