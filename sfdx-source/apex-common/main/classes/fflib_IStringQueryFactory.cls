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
public interface fflib_IStringQueryFactory
{
	fflib_IStringQueryFactory addOrdering(fflib_Ordering ordering);
	fflib_IStringQueryFactory addOrdering(String fieldName, fflib_Ordering.SortOrder direction);
	fflib_IStringQueryFactory addOrdering(String fieldName, fflib_Ordering.SortOrder direction, Boolean nullsLast);
	fflib_IStringQueryFactory deepClone();
	Boolean equals(Object obj);
	String getCondition();
	Set<String> getFields();
	Integer getLimit();
	Integer getOffset();
	String getOrderingClause();
	List<fflib_Ordering> getOrderings();
	List<String> getSelectedFields();
	List<fflib_IStringQueryFactory> getSubselectQueries();
	String getTable();
	String getWhereClause();
	fflib_IStringQueryFactory selectField(String fieldName);
	fflib_IStringQueryFactory selectFields(List<String> fieldNameList);
	fflib_IStringQueryFactory selectFields(Set<String> fieldNameSet);
	fflib_IStringQueryFactory setCondition(String clause);
	fflib_IStringQueryFactory setLimit(Integer value);
	fflib_IStringQueryFactory setOffset(Integer value);
	fflib_IStringQueryFactory setOrdering(fflib_Ordering ordering);
	fflib_IStringQueryFactory setOrdering(String fieldName, fflib_Ordering.SortOrder direction);
	fflib_IStringQueryFactory setOrdering(String fieldName, fflib_Ordering.SortOrder direction, Boolean nullsLast);
	fflib_IStringQueryFactory setSortSelectFields(Boolean value);
	fflib_IStringQueryFactory subselectQuery(String relationshipName);
	String toSOQL();
}