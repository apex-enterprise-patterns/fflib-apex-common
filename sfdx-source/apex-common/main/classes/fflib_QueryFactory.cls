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
public class fflib_QueryFactory { //No explicit sharing declaration - inherit from caller
	public enum SortOrder {ASCENDING, DESCENDING}

	/**
	 * This property is read-only and may not be set after instantiation.
	 * The {@link Schema.SObjectType} token of the SObject that will be used in the FROM clause of the resultant query.
	**/
	public Schema.SObjectType table {get; private set;}
	@TestVisible
	private Set<String> fields; 
	private String conditionExpression;
	private Integer limitCount;
	private Integer offsetCount;
	private List<Ordering> order;
	/**
	 * Integrate checking for READ Field Level Security within the selectField(s) methods
	 * This can optionally be enforced (or not) by calling the setEnforceFLS method prior to calling 
	 * one of the selectField or selectFieldset methods.
	**/
	private Boolean enforceFLS;
	
	private Boolean sortSelectFields = true;
	
	/**
	 * The relationship and  subselectQueryMap variables are used to support subselect queries.  Subselects can be added to 
	 * a query, as long as it isn't a subselect query itself.  You may have many subselects inside
	 * a query, but they may only be 1 level deep (no subselect inside a subselect)
	 * to add a subselect, call the subselectQuery method, passing in the ChildRelationship.
	**/
	private Schema.ChildRelationship relationship;
	private Map<Schema.ChildRelationship, fflib_QueryFactory> subselectQueryMap;

	private String getFieldPath(String fieldName){
		if(!fieldName.contains('.')){ //single field
			Schema.SObjectField token = fflib_SObjectDescribe.getDescribe(table).getField(fieldName.toLowerCase());
			if(token == null)
				throw new InvalidFieldException(fieldName,this.table);
			if (enforceFLS) 
				fflib_SecurityUtils.checkFieldIsReadable(this.table, token);	
			return token.getDescribe().getName();
		}

		//traversing FK relationship(s)
		List<String> fieldPath = new List<String>();
		Schema.SObjectType lastSObjectType = table;
		Iterator<String> i = fieldName.split('\\.').iterator();
		while(i.hasNext()){
			String field = i.next();
			Schema.SObjectField token = fflib_SObjectDescribe.getDescribe(lastSObjectType).getField(field.toLowerCase());
			DescribeFieldResult tokenDescribe = token != null ? token.getDescribe() : null;
			
			if (token != null && enforceFLS) {
				fflib_SecurityUtils.checkFieldIsReadable(lastSObjectType, token);
			}

			if(token != null && i.hasNext() && tokenDescribe.getSoapType() == Schema.SoapType.ID){
				lastSObjectType = tokenDescribe.getReferenceTo()[0]; //if it's polymorphic doesn't matter which one we get
				fieldPath.add(tokenDescribe.getRelationshipName());
			}else if(token != null && !i.hasNext()){
				fieldPath.add(tokenDescribe.getName());
			}else{
				if(token == null)
					throw new InvalidFieldException(field,lastSObjectType);
				else
					throw new NonReferenceFieldException(lastSObjectType+'.'+field+' is not a lookup or master-detail field but is used in a cross-object query field.');
			}
		}

		return String.join(fieldPath,'.');
	}

	@TestVisible
	private static String getFieldTokenPath(Schema.SObjectField field){
		if(field == null){
			throw new InvalidFieldException('Invalid field: null');		
		}
		return field.getDescribe().getName();
	}

	/**
	 * fflib_QueryFactory instances will be considered equal if they produce the same SOQL query.
	 * A faster comparison will first be attempted to check if they apply to the same table, and contain the same number of fields selected.
	 * This method will never return true if the provided object is not an instance of fflib_QueryFactory. 
	 * @param obj the object to check equality of.
	**/
	public Boolean equals(Object obj){
		if( !(obj instanceof fflib_QueryFactory) || ((fflib_QueryFactory)obj).table != this.table || ((fflib_QueryFactory)obj).fields.size() != this.fields.size() )
			return false;
		return ((fflib_QueryFactory)obj).toSOQL() == this.toSOQL();
	}

	/**
	 * Construct a new fflib_QueryFactory instance with no options other than the FROM clause.
	 * You *must* call selectField(s) before {@link #toSOQL} will return a valid, runnable query.
	 * @param table	the SObject to be used in the FROM clause of the resultant query. This sets the value of {@link #table}.
	**/
	public fflib_QueryFactory(Schema.SObjectType table){
		this.table = table;
		fields = new Set<String>();
		order = new List<Ordering>();
		enforceFLS = false;
	}

	/**
	 * Construct a new fflib_QueryFactory instance with no options other than the FROM clause and the relationship.
	 * This should be used when constructing a subquery query for addition to a parent query. 
	 * Objects created with this constructor cannot be added to another object using the subselectQuery method.
	 * You *must* call selectField(s) before {@link #toSOQL} will return a valid, runnable query.
	 * @param relationship the ChildRelationship to be used in the FROM Clause of the resultant Query (when set overrides value of table). This sets the value of {@link #relationship} and {@link #table}.
	**/
	private fflib_QueryFactory(Schema.ChildRelationship relationship){
		this(relationship.getChildSObject()); 
		this.relationship = relationship;
	}

	/**
	 * This method checks to see if the User has Read Access on {@link #table}. 
	 * Asserts true if User has access.
	 **/
	public fflib_QueryFactory assertIsAccessible(){
		fflib_SecurityUtils.checkObjectIsReadable(table);
		return this;
	}

	/**
	 * This method sets a flag to indicate that this query should have FLS Read
	 * permission enforced.  If this method is not called, the default behavior
	 * is that FLS read permission will not be checked.
	 * @param enforce whether to enforce field level security (read)
	 **/
	public fflib_QueryFactory setEnforceFLS(Boolean enforce){
		this.enforceFLS = enforce;
		return this;
	}

	/**
	 * Sets a flag to indicate that this query should have ordered
	 * query fields in the select statement (this at a small cost to performance).
	 * If you are processing large query sets, you should switch this off.
	 * @param doSort whether or not select fields should be sorted in the soql statement.
	 **/
	public fflib_QueryFactory setSortSelectFields(Boolean doSort){
		this.sortSelectFields = doSort;
		return this;
	}
	
	/**
	 * Selects a single field from the SObject specified in {@link #table}.
	 * Selecting fields is idempotent, if this field is already selected calling this method will have no additional impact.
	 * @param fieldName the API name of the field to add to the query's SELECT clause.
	 **/
	public fflib_QueryFactory selectField(String fieldName){ 		
		fields.add( getFieldPath(fieldName) );
		return this;
	} 
	/**
	 * Selects a field, avoiding the possible ambiguity of String API names.
	 * @see #selectField(String)
	 * @param field the {@link Schema.SObjectField} to select with this query.
	 * @exception InvalidFieldException If the field is null {@code field}.
	**/
	public fflib_QueryFactory selectField(Schema.SObjectField field){
		if(field == null)
			throw new InvalidFieldException(null,this.table);
		if (enforceFLS) 
			fflib_SecurityUtils.checkFieldIsReadable(table, field);
		fields.add( getFieldTokenPath(field) );
		return this;
	}
	/**
	 * Selects multiple fields. This acts the same as calling {@link #selectField(String)} multiple times.
	 * @param fieldNames the Set of field API names to select.
	**/
	public fflib_QueryFactory selectFields(Set<String> fieldNames){
		for(String fieldName:fieldNames){
			fields.add( getFieldPath(fieldName) );
		}	
		return this;
	}
	/**
	 * Selects multiple fields. This acts the same as calling {@link #selectField(String)} multiple times.
	 * @param fieldNames the List of field API names to select.
	**/
	public fflib_QueryFactory selectFields(List<String> fieldNames){
		for(String fieldName:fieldNames)
			fields.add( getFieldPath(fieldName) );
		return this;
	}
	/**
	 * Selects multiple fields. This acts the same as calling {@link #selectField(Schema.SObjectField)} multiple times.
	 * @param fields the set of {@link Schema.SObjectField}s to select.
	 * @exception InvalidFieldException if the fields are null {@code fields}.
	**/
	public fflib_QueryFactory selectFields(Set<Schema.SObjectField> fields){
		for(Schema.SObjectField token:fields){
			if(token == null)
				throw new InvalidFieldException();	
			if (enforceFLS) 
				fflib_SecurityUtils.checkFieldIsReadable(table, token);	
			this.fields.add( getFieldTokenPath(token) );
		}
		return this;
	}
	/**
	 * Selects multiple fields. This acts the same as calling {@link #selectField(Schema.SObjectField)} multiple times.
	 * @param fields the set of {@link Schema.SObjectField}s to select.
	 * @exception InvalidFieldException if the fields are null {@code fields}.	 
	**/
	public fflib_QueryFactory selectFields(List<Schema.SObjectField> fields){
		for(Schema.SObjectField token:fields){
			if(token == null)
				throw new InvalidFieldException();
			if (enforceFLS) 
				fflib_SecurityUtils.checkFieldIsReadable(table, token);		
			this.fields.add( getFieldTokenPath(token) );
		}
		return this;
	}
	/**
	 * @see #selectFieldSet(Schema.FieldSet,Boolean)
	**/
	public fflib_QueryFactory selectFieldSet(Schema.FieldSet fieldSet){
		return selectFieldSet(fieldSet,true);
	}
	/**
	 * This is equivalent to iterating the fields in the field set and calling {@link #selectField(String)} on each.
	 * @param fieldSet Select all fields included in the field set. 
	 * @param allowCrossObject if false this method will throw an exception if any fields in the field set reference fields on a related record.
	 * @exception InvalidFieldSetException if the fieldset is invalid for table {@code fields}.	 
	**/
	public fflib_QueryFactory selectFieldSet(Schema.FieldSet fieldSet, Boolean allowCrossObject){ 
		if(fieldSet.getSObjectType() != table)
			throw new InvalidFieldSetException('Field set "'+fieldSet.getName()+'" is not for SObject type "'+table+'"');
		for(Schema.FieldSetMember field: fieldSet.getFields()){
			if(!allowCrossObject && field.getFieldPath().contains('.'))
				throw new InvalidFieldSetException('Cross-object fields not allowed and field "'+field.getFieldPath()+'"" is a cross-object field.');
			fields.add( getFieldPath(field.getFieldPath()) );
		}
		return this;
	}
	/**
	 * @param conditionExpression Sets the WHERE clause to the string provided. Do not include the "WHERE".
	**/
	public fflib_QueryFactory setCondition(String conditionExpression){
		this.conditionExpression = conditionExpression;
		return this;
	}
	/**
	 * @returns the current value of the WHERE clause, if any, as set by {@link #setCondition}
	**/
	public String getCondition(){
		return this.conditionExpression;
	}
	/**
	 * @param limitCount if not null causes a LIMIT clause to be added to the resulting query.
	**/
	public fflib_QueryFactory setLimit(Integer limitCount){
		this.limitCount = limitCount;
		return this;
	}
	/**
	 * @returns the current value of the LIMIT clause, if any.
	**/
	public Integer getLimit(){
		return this.limitCount;
	}
	/**
	 * @param offsetCount if not null causes a OFFSET clause to be added to the resulting query.
	**/
	public fflib_QueryFactory setOffset(Integer offsetCount){
		this.offsetCount = offsetCount;
		return this;
	}
	/**
	 * @returns the current value of the OFFSET clause, if any.
	**/
	public Integer getOffset(){
		return this.offsetCount;
	}
	/**
	 * @param o an instance of {@link fflib_QueryFactory.Ordering} to be added to the query's ORDER BY clause.
	**/
	public fflib_QueryFactory addOrdering(Ordering o){
		this.order.add(o);
		return this;
	}

	/**
	 * @param o an instance of {@link fflib_QueryFactory.Ordering} to remove all existing (for instance defaults) and be added to the query's ORDER BY clause.
	 **/
	public fflib_QueryFactory setOrdering(Ordering o){
		this.order = new List<Ordering>{ o };
		return this;
	}
	/**
	 * @returns the list of orderings that will be used as the query's ORDER BY clause. You may remove elements from the returned list, or otherwise mutate it, to remove previously added orderings.
	**/
	public List<Ordering> getOrderings(){
		return this.order;
	}

	/**
	 * @returns the selected fields
	 **/
	public Set<String> getSelectedFields() { 
		return this.fields;
	}

	/**
	 * Add a subquery query to this query.  If a subquery for this relationship already exists, it will be returned.
	 * If not, a new one will be created and returned.
	 * @deprecated  Replaced by {@link #subselectQuery(String relationshipName)} and {@link #subselectQuery(ChildRelationship relationship)}
	 * @exception InvalidSubqueryRelationshipException If this method is called on a subselectQuery or with an invalid relationship 
	 * @param related The related object type
	**/
	public fflib_QueryFactory subselectQuery(SObjectType related){ 
		System.debug(LoggingLevel.WARN, 'fflib_QueryFactory.subselectQuery(Schema.SObjectType) is deprecated and will be removed in a future release. Use fflib_QueryFactory.subselectQuery(String) or fflib_QueryFactory.subselectQuery(ChildRelationship) instead.');
		return setSubselectQuery(getChildRelationship(related), false);
	}

	/**
	 * Add a subquery query to this query.  If a subquery for this relationship already exists, it will be returned.
	 * If not, a new one will be created and returned.
	 * @deprecated  Replaced by {@link #subselectQuery(String relationshipName, Boolean assertIsAccessible)} and {@link #subselectQuery(ChildRelationship relationship, Boolean assertIsAccessible)}
	 * @exception InvalidSubqueryRelationshipException If this method is called on a subselectQuery or with an invalid relationship 
	 * @param related The related object type
	 * @param assertIsAccessible indicates whether to check if the user has access to the subquery object
	**/
	public fflib_QueryFactory subselectQuery(SObjectType related, Boolean assertIsAccessible){
		System.debug(LoggingLevel.WARN, 'fflib_QueryFactory.subselectQuery(Schema.SObjectType, Boolean) is deprecated and will be removed in a future release. Use fflib_QueryFactory.subselectQuery(String, Boolean) or fflib_QueryFactory.subselectQuery(ChildRelationship, Boolean) instead.'); 
		return setSubselectQuery(getChildRelationship(related), assertIsAccessible);
	}

	/**
	 * Add a subquery query to this query.  If a subquery for this relationshipName already exists, it will be returned.
	 * If not, a new one will be created and returned.
	 * @exception InvalidSubqueryRelationshipException If this method is called on a subselectQuery or with an invalid relationship 
	 * @param relationshipName The relationshipName to be added as a subquery
	**/
	public fflib_QueryFactory subselectQuery(String relationshipName){ 
		return subselectQuery(relationshipName, false);
	}

	/**
	 * Add a subquery query to this query.  If a subquery for this relationship already exists, it will be returned.
	 * If not, a new one will be created and returned.
	 * @exception InvalidSubqueryRelationshipException If this method is called on a subselectQuery or with an invalid relationship 
	 * @param relationshipName The relationshipName to be added as a subquery
	 * @param assertIsAccessible indicates whether to check if the user has access to the subquery object
	**/
	public fflib_QueryFactory subselectQuery(String relationshipName, Boolean assertIsAccessible){
		Schema.ChildRelationship relationship = getChildRelationship(relationshipName);
		if (relationship != null) {
			return setSubselectQuery(relationship, assertIsAccessible);
		}
		throw new InvalidSubqueryRelationshipException('Invalid call to subselectQuery with relationshipName = '+relationshipName +'.  Relationship does not exist for ' + table.getDescribe().getName());	
	}

	/**
	 * Add a subquery query to this query.  If a subquery for this relationshipName already exists, it will be returned.
	 * If not, a new one will be created and returned.
	 * @exception InvalidSubqueryRelationshipException If this method is called on a subselectQuery or with an invalid relationship 
	 * @param relationship The ChildRelationship to be added as a subquery
	**/
	public fflib_QueryFactory subselectQuery(Schema.ChildRelationship relationship){ 
		return subselectQuery(relationship, false);
	}

	/**
	 * Add a subquery query to this query.  If a subquery for this relationship already exists, it will be returned.
	 * If not, a new one will be created and returned.
	 * @exception InvalidSubqueryRelationshipException If this method is called on a subselectQuery or with an invalid relationship 
	 * @param relationship The ChildRelationship to be added as a subquery
	 * @param assertIsAccessible indicates whether to check if the user has access to the subquery object
	**/
	public fflib_QueryFactory subselectQuery(Schema.ChildRelationship relationship, Boolean assertIsAccessible){
		return setSubselectQuery(relationship, assertIsAccessible);
	}

	/**
	 * Add a subquery query to this query.  If a subquery for this relationship already exists, it will be returned.
	 * If not, a new one will be created and returned.
	 * @exception InvalidSubqueryRelationshipException If this method is called on a subselectQuery or with an invalid relationship 
	 * @param relationship The ChildRelationship to be added as a subquery
	**/
	private fflib_QueryFactory setSubselectQuery(Schema.ChildRelationship relationship, Boolean assertIsAccessible){
		if (this.relationship != null){
			throw new InvalidSubqueryRelationshipException('Invalid call to subselectQuery.  You may not add a subselect query to a subselect query.');
		} 
		if (this.subselectQueryMap == null){
			this.subselectQueryMap = new Map<Schema.ChildRelationship, fflib_QueryFactory>();
		}
		if (this.subselectQueryMap.containsKey(relationship)){
			return subselectQueryMap.get(relationship);
		}
		
		fflib_QueryFactory subSelectQuery = new fflib_QueryFactory(relationship);
		
		//The child queryFactory should be configured in the same way as the parent by default - can override after if required
		subSelectQuery.setSortSelectFields(sortSelectFields);

		if(assertIsAccessible){
			subSelectQuery.assertIsAccessible();
		}
		subselectQueryMap.put(relationship, subSelectQuery);
		return subSelectQuery;
	}

	/**
	 * @returns the list of subquery instances of fflib_QueryFactory which will be added to the SOQL as relationship/child/sub-queries.
	**/
	public List<fflib_QueryFactory> getSubselectQueries(){
		if (subselectQueryMap != null) {
			return subselectQueryMap.values();
		}	
		return null;
	}

	/**
	 * Get the ChildRelationship from the Table for the object type passed in.
	 * @param objType The object type of the child relationship to get
	**/
 	private Schema.ChildRelationship getChildRelationship(SObjectType objType){
        for (Schema.ChildRelationship childRow : table.getDescribe().getChildRelationships()){
        	//occasionally on some standard objects (Like Contact child of Contact) do not have a relationship name.  
        	//if there is no relationship name, we cannot query on it, so throw an exception.
            if (childRow.getChildSObject() == objType && childRow.getRelationshipName() != null){ 
                return childRow;
            }   
        }
        throw new InvalidSubqueryRelationshipException('Invalid call to subselectQuery.  Invalid relationship for table '+table + ' and objtype='+objType);
    }

	/**
	 * Get the ChildRelationship from the Table for the relationship name passed in.
	 * @param relationshipName The name of the object's ChildRelationship on get
	**/
 	private Schema.ChildRelationship getChildRelationship(String relationshipName){
        for (Schema.ChildRelationship childRow : table.getDescribe().getChildRelationships()){
            if (childRow.getRelationshipName() == relationshipName){ 
                return childRow;
            }   
        }
        return null;
    }

	/**
	 * Add a field to be sorted on.  This may be a direct field or a field 
	 * related through an object lookup or master-detail relationship.
	 * Use the set to store unique field names, since we only want to sort
	 * by the same field one time.  The sort expressions are stored in a list
	 * so that they are applied to the SOQL in the same order that they
	 * were added in. 
	 * @param fieldName The string value of the field to be sorted on
	 * @param direction the direction to be sorted on (ASCENDING or DESCENDING)
	 * @param nullsLast whether to sort null values last (NULLS LAST keyword included).
	**/  
    public fflib_QueryFactory addOrdering(String fieldName, SortOrder direction, Boolean nullsLast){
		order.add(
			new Ordering(getFieldPath(fieldName), direction, nullsLast)
		);	
		return this;
    }

     /**
	 * Add a field to be sorted on.  This may be a direct field or a field 
	 * related through an object lookup or master-detail relationship.
	 * Use the set to store unique field names, since we only want to sort
	 * by the same field one time.  The sort expressions are stored in a list
	 * so that they are applied to the SOQL in the same order that they
	 * were added in. 
	 * @param field The SObjectField to sort.  This can only be a direct reference.
	 * @param direction the direction to be sorted on (ASCENDING or DESCENDING)
	 * @param nullsLast whether to sort null values last (NULLS LAST keyword included).
	**/
    public fflib_QueryFactory addOrdering(SObjectField field, SortOrder direction, Boolean nullsLast){
		order.add(
			new Ordering(getFieldTokenPath(field), direction, nullsLast)
		);	
		return this;
    }

    /**
	 * Add a field to be sorted on.  This may be a direct field or a field 
	 * related through an object lookup or master-detail relationship.
	 * Use the set to store unique field names, since we only want to sort
	 * by the same field one time.  The sort expressions are stored in a list
	 * so that they are applied to the SOQL in the same order that they
	 * were added in. 
	 * The "NULLS FIRST" keywords will be included by default.  If "NULLS LAST" 
	 * is required, use one of the overloaded addOrdering methods which include this parameter.
	 * @param fieldName The string value of the field to be sorted on
	 * @param direction the direction to be sorted on (ASCENDING or DESCENDING)
	**/  
    public fflib_QueryFactory addOrdering(String fieldName, SortOrder direction){
		order.add(
			new Ordering(getFieldPath(fieldName), direction)
		);	
		return this;
    }

     /**
	 * Add a field to be sorted on.  This may be a direct field or a field 
	 * related through an object lookup or master-detail relationship.
	 * Use the set to store unique field names, since we only want to sort
	 * by the same field one time.  The sort expressions are stored in a list
	 * so that they are applied to the SOQL in the same order that they
	 * were added in. 
	 * The "NULLS FIRST" keywords will be included by default.  If "NULLS LAST" 
	 * is required, use one of the overloaded addOrdering methods which include this parameter.
	 * @param field The SObjectField to sort.  This can only be a direct reference.
	 * @param direction the direction to be sorted on (ASCENDING or DESCENDING)
	**/
    public fflib_QueryFactory addOrdering(SObjectField field, SortOrder direction){
		order.add(
			new Ordering(getFieldTokenPath(field), direction)
		);	
		return this;
    }

	/**
	 * Remove existing ordering and set a field to be sorted on.  This may be a direct field or a field
	 * related through an object lookup or master-detail relationship.
	 * Use the set to store unique field names, since we only want to sort
	 * by the same field one time.  The sort expressions are stored in a list
	 * so that they are applied to the SOQL in the same order that they
	 * were added in.
	 * @param fieldName The string value of the field to be sorted on
	 * @param direction the direction to be sorted on (ASCENDING or DESCENDING)
	 * @param nullsLast whether to sort null values last (NULLS LAST keyword included).
	**/
	public fflib_QueryFactory setOrdering(String fieldName, SortOrder direction, Boolean nullsLast){
		Ordering ordr = new Ordering(getFieldPath(fieldName), direction, nullsLast);
		return setOrdering(ordr);
	}

	/**
	 * Remove existing ordering and set a field to be sorted on.  This may be a direct field or a field
	 * related through an object lookup or master-detail relationship.
	 * Use the set to store unique field names, since we only want to sort
	 * by the same field one time.  The sort expressions are stored in a list
	 * so that they are applied to the SOQL in the same order that they
	 * were added in.
	 * @param field The SObjectField to sort.  This can only be a direct reference.
	 * @param direction the direction to be sorted on (ASCENDING or DESCENDING)
	 * @param nullsLast whether to sort null values last (NULLS LAST keyword included).
	**/
	public fflib_QueryFactory setOrdering(SObjectField field, SortOrder direction, Boolean nullsLast){
		Ordering ordr = new Ordering(getFieldTokenPath(field), direction, nullsLast);
		return setOrdering(ordr);
	}

	/**
	 * Remove existing ordering and set a field to be sorted on.  This may be a direct field or a field
	 * related through an object lookup or master-detail relationship.
	 * Use the set to store unique field names, since we only want to sort
	 * by the same field one time.  The sort expressions are stored in a list
	 * so that they are applied to the SOQL in the same order that they
	 * were added in.
	 * @param fieldName The string value of the field to be sorted on
	 * @param direction the direction to be sorted on (ASCENDING or DESCENDING)
	**/
	public fflib_QueryFactory setOrdering(String fieldName, SortOrder direction){
		Ordering ordr = new Ordering(getFieldPath(fieldName), direction);
		return setOrdering(ordr);
	}

	/**
	 * Remove existing ordering and set a field to be sorted on.  This may be a direct field or a field
	 * related through an object lookup or master-detail relationship.
	 * Use the set to store unique field names, since we only want to sort
	 * by the same field one time.  The sort expressions are stored in a list
	 * so that they are applied to the SOQL in the same order that they
	 * were added in.
	 * @param field The SObjectField to sort.  This can only be a direct reference.
	 * @param direction the direction to be sorted on (ASCENDING or DESCENDING)
	**/
	public fflib_QueryFactory setOrdering(SObjectField field, SortOrder direction){
		Ordering ordr = new Ordering(getFieldTokenPath(field), direction);
		return setOrdering(ordr);
	}

	/**
	 * Convert the values provided to this instance into a full SOQL string for use with Database.query
	 * Check to see if subqueries queries need to be added after the field list.
	**/
	public String toSOQL(){
		String result = 'SELECT ';
		//if no fields have been added, just add the Id field so that the query or subquery will not just fail
		if (fields.size() == 0){
			if (enforceFLS) fflib_SecurityUtils.checkFieldIsReadable(table, 'Id');
			result += 'Id';
		}else {
			List<String> fieldsToQuery = new List<String>(fields);
		
			if(sortSelectFields){
				fieldsToQuery.sort(); 
			}	
		
			result += String.join(fieldsToQuery,', ');
		}
		
		if(subselectQueryMap != null && !subselectQueryMap.isEmpty()){
			for (fflib_QueryFactory childRow : subselectQueryMap.values()){
				result += ', (' + childRow.toSOQL() + ') ';
			}	
		}
		result += ' FROM ' + (relationship != null ? relationship.getRelationshipName() : table.getDescribe().getName());
		if(conditionExpression != null)
			result += ' WHERE '+conditionExpression;

		if(order.size() > 0){
			result += ' ORDER BY ';
			for(Ordering o:order)
				result += o.toSOQL() +', ';
			result = result.substring(0,result.length()-2);
		}
	
		if(limitCount != null)
			result += ' LIMIT '+limitCount;

		if(offsetCount != null)
			result += ' OFFSET '+offsetCount;

		return result;
	}

	/**
	 * Create a "deep" clone of this object that can be safely mutated without affecting the cloned instance
	 * @return a deep clone of this fflib_QueryFactory
	**/
	public fflib_QueryFactory deepClone(){	

		fflib_QueryFactory clone = new fflib_QueryFactory(this.table)
			.setLimit(this.limitCount)
			.setOffset(this.offsetCount)
			.setCondition(this.conditionExpression)
			.setEnforceFLS(this.enforceFLS);

		Map<Schema.ChildRelationship, fflib_QueryFactory> subqueries = this.subselectQueryMap;
		if(subqueries != null) {
			Map<Schema.ChildRelationship, fflib_QueryFactory> clonedSubqueries = new Map<Schema.ChildRelationship, fflib_QueryFactory>();
			for(Schema.ChildRelationship key : subqueries.keySet()) {
				clonedSubqueries.put(key, subqueries.get(key).deepClone());
			}
			clone.subselectQueryMap = clonedSubqueries;
		}

		clone.relationship = this.relationship;
		clone.order = this.order.clone();
		clone.fields = this.fields.clone();

		return clone;
	}
	
	public class Ordering{
		private SortOrder direction;
		private boolean nullsLast;
		private String field;

		public Ordering(String sobjType, String fieldName, SortOrder direction){
			this(
				fflib_SObjectDescribe.getDescribe(sobjType).getField(fieldName),
				direction
			);
		}
		/**
		 * Construct a new ordering instance for use with {@link fflib_QueryFactory#addOrdering}
		 * Once constructed it's properties may not be modified.
		**/
		public Ordering(Schema.SObjectField field, SortOrder direction){
			this(fflib_QueryFactory.getFieldTokenPath(field), direction, false); //SOQL docs state NULLS FIRST is default behavior
		}
		public Ordering(Schema.SObjectField field, SortOrder direction, Boolean nullsLast){
			this(fflib_QueryFactory.getFieldTokenPath(field), direction, nullsLast);
		}
		@TestVisible
		private Ordering(String field, SortOrder direction){
			this(field, direction, false);
		}
		@TestVisible
		private Ordering(String field, SortOrder direction, Boolean nullsLast){
			this.direction = direction;
			this.field = field;
			this.nullsLast = nullsLast;
		}
		public String getField(){
			return this.field;
		}
		public SortOrder getDirection(){
			return direction;
		}
		public String toSOQL(){
			return field + ' ' + (direction == SortOrder.ASCENDING ? 'ASC' : 'DESC') + (nullsLast ? ' NULLS LAST ' : ' NULLS FIRST ');
		}
	}


	
	public class InvalidFieldException extends Exception{
		private String fieldName;
		private Schema.SObjectType objectType;
		public InvalidFieldException(String fieldName, Schema.SObjectType objectType){
			this.objectType = objectType;
			this.fieldName = fieldName;
			this.setMessage( 'Invalid field \''+fieldName+'\' for object \''+objectType+'\'' );
		}
	}
	public class InvalidFieldSetException extends Exception{}
	public class NonReferenceFieldException extends Exception{}
	public class InvalidSubqueryRelationshipException extends Exception{}	
}
