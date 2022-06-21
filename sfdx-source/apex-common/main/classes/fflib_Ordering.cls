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
		this(table, fieldName, direction, true);
	}

	public fflib_Ordering(SObjectType table, String fieldName, SortOrder direction, Boolean assertSchema)
	{
		String fldName = fieldName;
		if (assertSchema == true)
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
		this.fieldName = field.getDescribe().getName();
		this.direction = direction;
		this.nullsLast = nullsLast == true;
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
		this.nullsLast = nullsLast == true;
	}

	// These constructors having the String tablename parameter, implicitly perform Schema assertion
	// since otherwise, the tablename has no usage within the order-by clause.
	public fflib_Ordering(String tableName, String fieldName, SortOrder direction)
	{
		this(tableName, fieldName, direction, true);
	}

	public fflib_Ordering(String tableName, String fieldName, SortOrder direction, Boolean nullsLast)
	{
		this(tableName, fieldName, direction, nullsLast, true);
	}

	public fflib_Ordering(String tableName, String fieldName, SortOrder direction, Boolean nullsLast, Boolean assertSchema)
	{
		if (assertSchema == true)
		{
			AssertSchemaResponse asr = assertSchema(tableName, fieldName);
			this.field = asr.field;
		}

		this.fieldName = fieldName;
		this.direction = direction;
		this.nullsLast = false;
	}

	public virtual SortOrder getDirection()
	{
		return direction;
	}

	public virtual String getField()
	{
		return fieldName;
	}

	public virtual String getOrdering()
	{
		List<String> sb = new List<String>();

		sb.add(getField());

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

	private class AssertSchemaResponse
	{
		public SObjectField field;
		public String fieldName;

		public AssertSchemaResponse(SObjectField field)
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

		return new AssertSchemaResponse(fld);
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
