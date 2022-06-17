public virtual inherited sharing class fflib_QueryFactoryBase
		implements fflib_IQueryFactoryBase
{
	// ========== fflib_IQueryFactoryBase implementation ==========================================
	public virtual fflib_IQueryFactoryBase addOrdering(fflib_Ordering ordering)
	{
		orderingList.add(ordering);
		return this;
	}

	public virtual fflib_IQueryFactoryBase addOrdering(String fieldName, fflib_Ordering.SortOrder direction)
	{
		return addOrdering(new fflib_Ordering(fieldName, direction, false));
	}

	public virtual fflib_IQueryFactoryBase addOrdering(String fieldName, fflib_Ordering.SortOrder direction, Boolean nullsLast)
	{
		return addOrdering(new fflib_Ordering(fieldName, direction, nullsLast));
	}

	public virtual fflib_IQueryFactoryBase deepClone()
	{
		fflib_QueryFactoryBase clone =
				(fflib_QueryFactoryBase)
						fflib_QueryFactoryBase.newInstance(this.table)
								.setLimit(this.limitValue)
								.setOffset(this.offsetValue)
								.setCondition(this.whereClause);

		Map<String, fflib_IQueryFactoryBase> subqueries = this.subselectQueryMap;
		if(subqueries != null) {
			Map<String, fflib_IQueryFactoryBase> clonedSubqueries = new Map<String, fflib_IQueryFactoryBase>();
			for(String key : subqueries.keySet()) {
				clonedSubqueries.put(key, subqueries.get(key).deepClone());
			}
			clone.subselectQueryMap = clonedSubqueries;
		}

		clone.table = this.table;
		clone.orderingList = this.orderingList.clone();
		clone.fieldsMap = this.fieldsMap.clone();

		return clone;
	}

	public virtual Boolean equals(Object obj)
	{
		if (!(obj instanceof fflib_IQueryFactoryBase))
		{
			return false;
		}

		if ( (((fflib_IQueryFactoryBase)obj).getTable() != this.getTable()) )
		{
			return false;
		}

		if ( (((fflib_IQueryFactoryBase)obj).getFields().size() != this.getFields().size()) )
		{
			return false;
		}

		return ((fflib_IQueryFactoryBase)obj).toSOQL() == this.toSOQL();
	}

	public virtual String getCondition()
	{
		return whereClause;
	}

	public virtual Set<String> getFields()
	{
		return new Set<String>(fieldsMap.values());
	}

	public virtual Integer getLimit()
	{
		return limitValue;
	}

	public virtual Integer getOffset()
	{
		return offsetValue;
	}

	public String getOrderingClause()
	{
		if (orderingList.isEmpty())
		{
			return '';
		}

		List<String> sb = new List<String>();

		for (fflib_Ordering o : orderingList)
		{
			if (!sb.isEmpty())
			{
				sb.add('ORDER BY');
			}

			sb.add(o.getOrdering());
		}

		return String.join(sb, ', ');
	}

	public virtual List<fflib_Ordering> getOrderings()
	{
		return orderingList;
	}

	public virtual List<String> getSelectedFields()
	{
		List<String> out = new List<String>(fieldsMap.values());

		if (sortSelectFields)
		{
			out.sort();
		}

		return out;
	}

	public virtual List<fflib_IQueryFactoryBase> getSubselectQueries()
	{
		return subselectQueryMap.values();
	}

	public virtual String getTable()
	{
		return table;
	}

	public String getWhereClause()
	{
		if (String.isNotBlank(whereClause))
		{
			return 'WHERE '+ whereClause;
		}
		return '';
	}

	public virtual fflib_IQueryFactoryBase selectField(String fieldName)
	{
		String key = keyify(fieldName);
		ensureKeyifiedFieldname(key);
		fieldsMap.put(key, fieldName);
		return this;
	}

	public virtual fflib_IQueryFactoryBase selectFields(List<String> fieldNameList)
	{
		for (String fn : fieldNameList)
		{
			selectField(fn);
		}
		return this;
	}

	public virtual fflib_IQueryFactoryBase selectFields(Set<String> fieldNameSet)
	{
		selectFields(new List<String>(fieldNameSet));
		return this;
	}

	public virtual fflib_IQueryFactoryBase setCondition(String clause)
	{
		this.whereClause = clause;
		return this;
	}

	public virtual fflib_IQueryFactoryBase setLimit(Integer value)
	{
		this.limitValue = value;
		return this;
	}

	public virtual fflib_IQueryFactoryBase setOffset(Integer value)
	{
		this.offsetValue = value;
		return this;
	}

	public virtual fflib_IQueryFactoryBase setOrdering(fflib_Ordering ordering)
	{
		orderingList.clear();
		orderingList.add(ordering);
		return this;
	}

	public virtual fflib_IQueryFactoryBase setOrdering(String fieldName, fflib_Ordering.SortOrder direction)
	{
		return setOrdering(fieldName, direction, false);
	}

	public virtual fflib_IQueryFactoryBase setOrdering(String fieldName, fflib_Ordering.SortOrder direction, Boolean nullsLast)
	{
		return setOrdering(new fflib_Ordering(fieldName, direction, nullsLast));
	}

	public virtual fflib_IQueryFactoryBase setSortSelectFields(Boolean value)
	{
		this.sortSelectFields = !!value;
		return this;
	}

	public virtual fflib_IQueryFactoryBase subselectQuery(String relationshipName)
	{
		return ensureSubselectQuery(relationshipName);
	}

	public virtual String toSOQL()
	{
		List<String> sb = new List<String> {'SELECT'};

		List<String> fieldsSb = getSelectedFields();

		for (fflib_IQueryFactoryBase subQf : subselectQueryMap.values())
		{
			fieldsSb.add('(' + subQf.toSOQL() + ')');
		}

		if (fieldsSb.isEmpty())
		{
			fieldsSb.add('Id');
		}

		sb.add(String.join(fieldsSb, ', '));

		sb.add('FROM');
		sb.add(table);

		conditionallyAddToStringBuilder(sb, getWhereClause());

		conditionallyAddToStringBuilder(sb, getOrderingClause());

		if (0 < limitValue)
		{
			sb.add('LIMIT ' + limitValue);
		}

		if (0 < offsetValue)
		{
			sb.add('OFFSET ' + offsetValue);
		}

		return String.join(sb, ' ');
	}

	// ========== Construction Logic ==============================================================
	public fflib_QueryFactoryBase()
	{

	}
	private fflib_QueryFactoryBase(String table)
	{
		this.table = table;
	}

	// ========== Private Instance Logic ==========================================================
	private Map<String, String> fieldsMap = new Map<String, String>();
	private Integer limitValue = 0;
	private Integer offsetValue = 0;
	private List<fflib_Ordering> orderingList = new List<fflib_Ordering>();
	private Boolean sortSelectFields = true;
	private Map<String, fflib_IQueryFactoryBase> subselectQueryMap = new Map<String, fflib_IQueryFactoryBase>();
	private String table;
	private String whereClause;

	private fflib_IQueryFactoryBase ensureSubselectQuery(String relationshipName)
	{
		if (subselectQueryMap.containsKey(relationshipName))
		{
			return subselectQueryMap.get(relationshipName);
		}

		fflib_IQueryFactoryBase subSelectQuery = fflib_QueryFactoryBase.newInstance(relationshipName);
		subSelectQuery.setSortSelectFields(sortSelectFields);
		subselectQueryMap.put(relationshipName, subSelectQuery);

		return subSelectQuery;
	}

	// ========== Static Mocking Logic ============================================================
	private static Map<String, fflib_IQueryFactoryBase> mockInstanceMap = new Map<String, fflib_IQueryFactoryBase>();

	public static fflib_IQueryFactoryBase newInstance(String table)
	{
		String tableName = keyify(table);

		if (String.isBlank(tableName))
		{
			throw new InvalidTableNameException('"table" is required');
		}

		return
				!mockInstanceMap.containsKey(table)
						? new fflib_QueryFactoryBase(table)
						: mockInstanceMap.get(table);
	}

	@TestVisible
	private static void setMock(String table, fflib_IQueryFactoryBase mock)
	{
		mockInstanceMap.put(table, mock);
	}

	// ========== Static Logic ====================================================================
	private static void conditionallyAddToStringBuilder(List<String> sb, String value)
	{
		if (String.isNotBlank(value))
		{
			sb.add(value);
		}
	}

	private static String keyify(String value)
	{
		return value?.trim().toLowerCase();
	}

	private static void ensureKeyifiedFieldname(String value)
	{
		if (String.isBlank(value))
		{
			throw new InvalidFieldNameException('fieldName is required');
		}
	}

	private static List<String> reduceListToUniqueLowerCaseValues(List<String> valueList)
	{
		Map<String, String> returnMap = new Map<String, String>();

		for (String value : valueList)
		{
			String valueString = keyify(value);
			if (String.isNotBlank(valueString))
			{
				returnMap.put(valueString, value);
			}
		}

		return returnMap.values();
	}

	// ========== Exception Classes ===============================================================
	public class InvalidFieldNameException extends Exception
	{

	}

	public class InvalidRelationshipNameException extends Exception
	{

	}

	public class InvalidTableNameException extends Exception
	{

	}
}