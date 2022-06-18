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

/**
 * QueryFactory provides an object-oriented way of building SOQL queries without resorting to string manipulation.
 * This class is not meant to be used as a replacement for all SOQL queries, and due to the relatively high overhead in both CPU and describe calls
 * should be used in places where highly dynamic queries, such as those that include field sets or are mutated heavily
 * in multiple locations are a good fit for use with fflib_QueryFactory.
 *
 * To use call construct a new instance for each query you intend to make.
 * To add additional fields to the query make use of the selectField(s) methods.
 *
 * Currently the WHERE clause of the query is manipulated as a single string, and is decidedly less OO-styled than other methods.
 * This is expected to be expanded upon in the future.
 *
 * To include one or more ORDER BY clause(s), use one of the addOrdering methods.  If not specified, the "NULLS FIRST" keywords
 * will be included by default. Constructing Ordering instances manually is discouraged.
 *
 * Subselect Queries are supported with the subselectQuery methods.
 * More than one sub-query can be added to a single query, but sub-queries can only be 1 level deep.
 * An exception will thrown from the subselectQuery method when there is an attempt to add a subquery to a sub-query
 * or to add a subquery to a query with an invalid relationship.
 *
 * Current limitations:
 * - Aggregate functions are not currently supported.
 * - Cross-object references currently require using String argument(s) to selectField(s).
 * - The behavior of serializing and deserializing an fflib_QueryFactory instance is currently untested and undefined.
 *
 * There is a google doc providing additional guidance on the use of this class with field sets at
 * https://docs.google.com/a/financialforce.com/document/d/1I4cxN4xHT4UJj_3Oi0YBL_MJ5chm-KG8kMN1D1un8-g/edit?usp=sharing
**/
public virtual inherited sharing class fflib_StringQueryFactory
		implements fflib_IStringQueryFactory
{
	// ========== fflib_IQueryFactoryBase implementation ==========================================
	public virtual fflib_IStringQueryFactory addOrdering(fflib_Ordering ordering)
	{
		orderingList.add(ordering);
		return this;
	}

	public virtual fflib_IStringQueryFactory addOrdering(String fieldName, fflib_Ordering.SortOrder direction)
	{
		return addOrdering(new fflib_Ordering(fieldName, direction, false));
	}

	public virtual fflib_IStringQueryFactory addOrdering(String fieldName, fflib_Ordering.SortOrder direction, Boolean nullsLast)
	{
		return addOrdering(new fflib_Ordering(fieldName, direction, nullsLast));
	}

	public virtual fflib_IStringQueryFactory deepClone()
	{
		fflib_StringQueryFactory clone =
				(fflib_StringQueryFactory)
						fflib_StringQueryFactory.newInstance(this.table)
								.setLimit(this.limitValue)
								.setOffset(this.offsetValue)
								.setCondition(this.whereClause);

		Map<String, fflib_IStringQueryFactory> subqueries = this.subselectQueryMap;
		if(subqueries != null) {
			Map<String, fflib_IStringQueryFactory> clonedSubqueries = new Map<String, fflib_IStringQueryFactory>();
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
		if (!(obj instanceof fflib_IStringQueryFactory))
		{
			return false;
		}

		if ( (((fflib_IStringQueryFactory)obj).getTable() != this.getTable()) )
		{
			return false;
		}

		if ( (((fflib_IStringQueryFactory)obj).getFields().size() != this.getFields().size()) )
		{
			return false;
		}

		return ((fflib_IStringQueryFactory)obj).toSOQL() == this.toSOQL();
	}

	public virtual Boolean getAllRows()
	{
		return this.allRows;
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

	public virtual List<fflib_IStringQueryFactory> getSubselectQueries()
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

	public virtual fflib_IStringQueryFactory selectField(String fieldName)
	{
		String key = keyify(fieldName);
		ensureKeyifiedFieldname(key);
		fieldsMap.put(key, fieldName);
		return this;
	}

	public virtual fflib_IStringQueryFactory selectFields(List<String> fieldNameList)
	{
		for (String fn : fieldNameList)
		{
			selectField(fn);
		}
		return this;
	}

	public virtual fflib_IStringQueryFactory selectFields(Set<String> fieldNameSet)
	{
		selectFields(new List<String>(fieldNameSet));
		return this;
	}

	public virtual fflib_IStringQueryFactory setAllRows()
	{
		this.allRows = true;
		return this;
	}

	public virtual fflib_IStringQueryFactory setCondition(String clause)
	{
		this.whereClause = clause;
		return this;
	}

	public virtual fflib_IStringQueryFactory setLimit(Integer value)
	{
		this.limitValue = value;
		return this;
	}

	public virtual fflib_IStringQueryFactory setOffset(Integer value)
	{
		this.offsetValue = value;
		return this;
	}

	public virtual fflib_IStringQueryFactory setOrdering(fflib_Ordering ordering)
	{
		orderingList.clear();
		orderingList.add(ordering);
		return this;
	}

	public virtual fflib_IStringQueryFactory setOrdering(String fieldName, fflib_Ordering.SortOrder direction)
	{
		return setOrdering(fieldName, direction, false);
	}

	public virtual fflib_IStringQueryFactory setOrdering(String fieldName, fflib_Ordering.SortOrder direction, Boolean nullsLast)
	{
		return setOrdering(new fflib_Ordering(fieldName, direction, nullsLast));
	}

	public virtual fflib_IStringQueryFactory setSortSelectFields(Boolean value)
	{
		this.sortSelectFields = !!value;
		return this;
	}

	public virtual fflib_IStringQueryFactory subselectQuery(String relationshipName)
	{
		return ensureSubselectQuery(relationshipName);
	}

	public virtual String toSOQL()
	{
		List<String> sb = new List<String> {'SELECT'};

		List<String> fieldsSb = getSelectedFields();

		for (fflib_IStringQueryFactory subQf : subselectQueryMap.values())
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

		if (allRows)
		{
			sb.add('ALL ROWS');
		}

		return String.join(sb, ' ');
	}

	// ========== Construction Logic ==============================================================
	public fflib_StringQueryFactory()
	{

	}
	private fflib_StringQueryFactory(String table)
	{
		this.table = table;
	}

	// ========== Private Instance Logic ==========================================================
	private Boolean allRows = false;
	private Map<String, String> fieldsMap = new Map<String, String>();
	private Integer limitValue = 0;
	private Integer offsetValue = 0;
	private List<fflib_Ordering> orderingList = new List<fflib_Ordering>();
	private Boolean sortSelectFields = true;
	private Map<String, fflib_IStringQueryFactory> subselectQueryMap = new Map<String, fflib_IStringQueryFactory>();
	private String table;
	private String whereClause;

	private fflib_IStringQueryFactory ensureSubselectQuery(String relationshipName)
	{
		if (subselectQueryMap.containsKey(relationshipName))
		{
			return subselectQueryMap.get(relationshipName);
		}

		fflib_IStringQueryFactory subSelectQuery = fflib_StringQueryFactory.newInstance(relationshipName);
		subSelectQuery.setSortSelectFields(sortSelectFields);
		subselectQueryMap.put(relationshipName, subSelectQuery);

		return subSelectQuery;
	}

	// ========== Static Mocking Logic ============================================================
	private static Map<String, fflib_IStringQueryFactory> mockInstanceMap = new Map<String, fflib_IStringQueryFactory>();

	public static fflib_IStringQueryFactory newInstance(String table)
	{
		String tableName = keyify(table);

		if (String.isBlank(tableName))
		{
			throw new InvalidTableNameException('"table" is required');
		}

		return
				!mockInstanceMap.containsKey(table)
						? new fflib_StringQueryFactory(table)
						: mockInstanceMap.get(table);
	}

	@TestVisible
	private static void setMock(String table, fflib_IStringQueryFactory mock)
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