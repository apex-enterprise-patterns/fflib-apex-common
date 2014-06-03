/**
 * Copyright (c) 2014, FinancialForce.com, inc
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
 * QueryFactor provides an object-oriented way of building SOQL queries without resorting to string manipulation.
 * This class is not meant to be used as a replacement for all SOQL queries, and due to the relativley high overhead in both CPU and describe calls 
 * should be used in places where highly dynamic queries, such as those that include field sets or are mutated heavilly
 * in multiple locations are a good fit for use with fflib_QueryFactory.
 * 
 * To use call construct a new instance for each query you intend to make.
 * To add additional fields to the query make use of the selectField(s) methods.
 *
 * Currently the WHERE clause of the query is manipulated as a single string, and is decidedly less OO-styled than other methods.
 * This is expected to be expanded upon in the future.
 * 
 * Subselect Queries are supported with the subselectQuery method.  
 * More than one sub-query can be added to a single query, but sub-queries can only be 1 level deep.  
 * An exception will thrown from the subselectQuery method when there is an attempt to add a subquery to a sub-query
 * or to add a subquery to a query with an invalid relationship.
 *
 * Current limitations:
 * - Aggregate functions are not currently supported.
 * - Cross-object references currently require using String argument(s) to selectField(s).
 * - The behavior of serializing and deserializing an fflib_QueryFactory instance is currently untested and undefined.
**/
public class fflib_QueryFactory { //No explicit sharing declaration - inherit from caller
	public enum SortOrder {ASCENDING, DESCENDING}

	/**
	 * This property is read-only and may not be set after instantiation.
	 * The {@link Schema.SObjectType} token of the SObject that will be used in the FROM clause of the resultant query.
	**/
	public Schema.SObjectType table {get; private set;}
	private Set<QueryField> fields; 
	private String conditionExpression;
	private Integer limitCount;
	private Integer offset;
	private List<Ordering> order;
	/**
	 * The relationship and  subselectQueryMap variables are used to support subselect queries.  Subselects can be added to 
	 * a query, as long as it isn't a subselect query itself.  You may have many subselects inside
	 * a query, but they may only be 1 level deep (no subselect inside a subselect)
	 * to add a subselect, call the subselectQuery method, passing in the ChildRelationship.
	**/
	private Schema.ChildRelationship relationship;
	private Map<Schema.ChildRelationship, fflib_QueryFactory> subselectQueryMap;

	private QueryField getFieldToken(String fieldName){
		QueryField result;
		if(!fieldName.contains('.')){ //single field
			Schema.SObjectField token = fflib_SObjectDescribe.getDescribe(table).getField(fieldName);
			if(token == null)
				throw new InvalidFieldException(fieldName,this.table);
			result = new QueryField(table,token);
		}else{ //traversing FK relationship(s)
			List<Schema.SObjectField> fieldPath = new List<Schema.SObjectField>();
			Schema.sObjectType lastSObjectType = table;
			Iterator<String> i = fieldName.split('\\.').iterator();
			while(i.hasNext()){
				String field = i.next();
				Schema.SObjectField token = fflib_SObjectDescribe.getDescribe(lastSObjectType).getField(field);
				if(token != null && i.hasNext() && token.getDescribe().getSOAPType() == Schema.SOAPType.ID){
					lastSObjectType = token.getDescribe().getReferenceTo()[0]; //if it's polymorphic doesn't matter which one we get
					fieldPath.add(token);
				}else if(token != null && !i.hasNext()){
					fieldPath.add(token);
				}else{
					if(token == null)
						throw new InvalidFieldException(field,lastSObjectType);
					else
						throw new NonReferenceFieldException(lastSObjectType+'.'+field+' is not a lookup or master-detail field but is used in a cross-object query field.');
				}

			}
			result = new QueryField(this.table, fieldPath);
		}
		return result;
	}

	/**
	 * fflib_QueryFactory instances will be considered equal if they produce the same SOQL query.
	 * A faster comparison will first be attempted to check if they apply to the same table, and contain the same number of fields selected.
	 * This method will never return true if the provided object is not an instance of fflib_QueryFactory. 
	 * @param obj the object to check equality of.
	**/
	public boolean equals(Object obj){
		if( !(obj instanceof fflib_QueryFactory) || ((fflib_QueryFactory)obj).table != this.table || ((fflib_QueryFactory)obj).fields.size() != this.fields.size() )
			return false;
		return ((fflib_QueryFactory)obj).toString() == this.toString();
	}

	/**
	 * Construct a new fflib_QueryFactory instance with no options other than the FROM caluse. 
	 * You *must* call selectField(s) before {@link #toSOQL} will return a valid, runnable query.
	 * @param table	the SObject to be used in the FROM clause of the resultant query. This sets the value of {@link #table}.
	**/
	public fflib_QueryFactory(Schema.SObjectType table){
		this.table = table;
		fields = new Set<QueryField>();
		order = new List<Ordering>();
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
	 * Selects a single field from the SObject specified in {@link #table}.
	 * Selecting fields is idempotent, if this field is already selected calling this method will have no additional impact.
	 * @param fieldName the API name of the field to add to the query's SELECT clause.
	 **/
	public fflib_QueryFactory selectField(String fieldName){ 
		fields.add( getFieldToken(fieldName) );
		return this;
	}
	/**
	 * Selects a field, avoiding the possible ambiguitiy of String API names.
	 * @see #selectField(String)
	 * @param field the {@link Schema.SObjectField} to select with this query.
	 * @exception InvalidFieldException If the field is null {@code field}.
	**/
	public fflib_QueryFactory selectField(Schema.SObjectField field){
		if(field == null)
			throw new InvalidFieldException(null,this.table);
		fields.add( new QueryField(table,field) );
		return this;
	}
	/**
	 * Selects multiple fields. This acts the same as calling {@link #selectField(String)} multiple times.
	 * @param fieldNames the Set of field API names to select.
	**/
	public fflib_QueryFactory selectFields(Set<String> fieldNames){
		Set<QueryField> toAdd = new Set<QueryField>();
		for(String fieldName:fieldNames)
			toAdd.add( getFieldToken(fieldName) );
		fields.addAll(toAdd);
		return this;
	}
	/**
	 * Selects multiple fields. This acts the same as calling {@link #selectField(String)} multiple times.
	 * @param fieldNames the List of field API names to select.
	**/
	public fflib_QueryFactory selectFields(List<String> fieldNames){
		Set<QueryField> toAdd = new Set<QueryField>();
		for(String fieldName:fieldNames)
			toAdd.add( getFieldToken(fieldName) );
		fields.addAll(toAdd);
		return this;
	}
	/**
	 * Selects multiple fields. This acts the same as calling {@link #selectField(Schema.SObjectField)} multiple times.
	 * @param fieldNames the set of {@link Schema.SObjectField}s to select.
	 * @exception InvalidFieldException if the fields are null {@code fields}.
	**/
	public fflib_QueryFactory selectFields(Set<Schema.SObjectField> fields){
		for(Schema.SObjectField token:fields){
			if(token == null)
				throw new InvalidFieldException();
			this.fields.add( new QueryField(table, token) );
		}
		return this;
	}
	/**
	 * Selects multiple fields. This acts the same as calling {@link #selectField(Schema.SObjectField)} multiple times.
	 * @param fieldNames the set of {@link Schema.SObjectField}s to select.
	 * @exception InvalidFieldException if the fields are null {@code fields}.	 
	**/
	public fflib_QueryFactory selectFields(List<Schema.SObjectField> fields){
		for(Schema.SObjectField token:fields){
			if(token == null)
				throw new InvalidFieldException();
			this.fields.add( new QueryField(table, token) );
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
	 * This is equivielent to iterating the fields in the field set and calling {@link #selectField(String)} on each.
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
			fields.add( getFieldToken(field.getFieldPath()) );
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
	 * @param limitCount if not null causes a LIMIT caluse to be added to the resulting query.
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
	 * @param o an instance of {@link fflib_QueryFactory.Ordering} to be added to the query's ORDER BY clause.
	**/
	public fflib_QueryFactory addOrdering(Ordering o){
		this.order.add(o);
		return this;
	}
	/**
	 * @returns the list of orderings that will be used as the query's ORDER BY clause. You may remove elements from the returned list, or otherwise mutate it, to remove previously added orderings.
	**/
	public List<Ordering> getOrderings(){
		return this.order;
	}
	/**
	 * Add a subquery query to this query.  If a subquery for this relationship already exists, it will be returned.
	 * If not, a new one will be created and returned.
	 * @exception InvalidSubqueryRelationshipException If this method is called on a subselectQuery or with an invalid relationship 
	 * @param relationship The ChildRelationship to be added as a subquery
	**/
	public fflib_QueryFactory subselectQuery(ChildRelationship relationship){
		if (this.subselectQueryMap == null){
			this.subselectQueryMap = new Map<ChildRelationship, fflib_QueryFactory>();
		}
		if (this.subselectQueryMap.containsKey(relationship)){
			return subselectQueryMap.get(relationship);
		}
		if (this.relationship != null){
			throw new InvalidSubqueryRelationshipException('Invalid call to subselectQuery.  You may not add a subselect query to a subselect query.');
		} else if (!isRelationshipValid(relationship)) {
			throw new InvalidSubqueryRelationshipException('Invalid call to subselectQuery.  Invalid relationship for table.');
		}	
		fflib_QueryFactory subselectQuery = new fflib_QueryFactory(relationship);
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
	 * When a subselect is being added, check to make sure that the relationship on that object
	 * is valid for the parent's object type (table)
	**/
	private boolean isRelationshipValid(Schema.ChildRelationship relationship){
        for (Schema.ChildRelationship childRow : table.getDescribe().getChildRelationships()) {
            if (childRow.getRelationshipName() == relationship.getRelationshipName()) {
                return true;
            }
        }
        return false;
	}

	/**
	 * Convert the values provided to this instance into a full SOQL string for use with Database.query
	 * Check to see if subqueries queries need to be added after the field list.
	**/
	public String toSOQL(){
		String result = 'SELECT ';
		for(QueryField field:fields){
			result += field + ', ';
		}
		if (subselectQueryMap != null && !subselectQueryMap.isEmpty()) {
			for (fflib_QueryFactory childRow : subselectQueryMap.values()) {
				result += ' (' + childRow.toSOQL() + '), ';
			}	
		}
		result = result.substring(0,result.length()-2) + ' FROM ' + (relationship != null ? relationship.getRelationshipName() : table.getDescribe().getName());
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
		return result;
	}
	
	public class Ordering{
		private SortOrder direction;
		private boolean nullsFirst;
		private Schema.SObjectField field;

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
			this.direction = direction;
			this.field = field;
		}
		public Schema.SObjectField getField(){
			return field;
		}
		public SortOrder getDirection(){
			return direction;
		}
		public String toSOQL(){
			return field + ' ' + (direction == SortOrder.ASCENDING ? 'ASC' : 'DESC');
		}
	}

	@testVisible 
	private class QueryField{
		List<Schema.SObjectField> fields;

		@testVisible 
		private QueryField(Schema.SObjectType table, List<Schema.SObjectField> fields){
			if(fields == null || fields.size() == 0)
				throw new InvalidFieldException(null, table);
			this.fields = fields.clone(); //don't let clients mutate after setting!
		}
		@testVisible 
		private QueryField(Schema.SObjectType table, Schema.SObjectField field){
			if(field == null)
				throw new InvalidFieldException(null, table);
			fields = new List<Schema.SObjectField>{ field };
		}
		public override String toString(){
			String result = '';
			Iterator<Schema.sObjectField> i = fields.iterator();
			while(i.hasNext()){
				String fieldName = i.next().getDescribe().getName();
				if(fieldName.endsWithIgnoreCase('Id') && i.hasNext())
					fieldName = fieldName.removeEndIgnoreCase('Id');
				if(fieldName.endsWithIgnoreCase('__c') && i.hasNext())
					fieldName = fieldName.removeEndIgnoreCase('__c')+'__r';
				result += fieldName + (i.hasNext() ? '.' :'');
			}
			return result;
		} 
		public integer hashCode(){
			return String.valueOf(this.fields).hashCode();
		}
		public boolean equals(Object obj){
			if(!(obj instanceof QueryField))
				return false;
			if( String.valueOf(((QueryField) obj).fields) != String.valueOf(this.fields))
				return false;
			Set<Schema.SObjectField> objFields = new Set<Schema.SObjectField>();
			objFields.addAll( ((QueryField)obj).fields );
			objFields.retainAll(this.fields);
			objFields.removeAll(this.fields);
			return objFields.size() == 0;
		}
	}
	
	public class InvalidFieldException extends Exception{
		private String fieldName;
		private Schema.SObjectType objectType;
		public InvalidFieldException(String fieldname, Schema.SObjectType objectType){
			this.objectType = objectType;
			this.fieldName = fieldName;
			this.setMessage( 'Invalid field \''+fieldName+'\' for object \''+objectType+'\'' );
		}
	}
	public class InvalidFieldSetException extends Exception{}
	public class NonReferenceFieldException extends Exception{}
	public class InvalidSubqueryRelationshipException extends Exception{}
	
}
