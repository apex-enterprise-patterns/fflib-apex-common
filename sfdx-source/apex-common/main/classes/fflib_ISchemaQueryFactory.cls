public interface fflib_ISchemaQueryFactory
{
	// Overrides (sortof) from fflib_IQueryFactory_New
	fflib_ISchemaQueryFactory addOrdering(fflib_SchemaQueryFactory.Ordering ordering);
	fflib_ISchemaQueryFactory addOrdering(String fieldName, fflib_SchemaQueryFactory.SortOrder direction);
	fflib_ISchemaQueryFactory addOrdering(String fieldName, fflib_SchemaQueryFactory.SortOrder direction, Boolean nullsLast);
	String getCondition();
	Set<String> getFields();
	Integer getLimit();
	Integer getOffset();
	String getOrderingClause();
	List<fflib_SchemaQueryFactory.Ordering> getOrderings();
	List<String> getSelectedFields();
	List<fflib_ISchemaQueryFactory> getSubselectQueries();
	SObjectType getTable();
	String getWhereClause();
	fflib_ISchemaQueryFactory selectField(String fieldName);
	fflib_ISchemaQueryFactory selectFields(List<String> fieldNameList);
	fflib_ISchemaQueryFactory selectFields(Set<String> fieldNameSet);
	fflib_ISchemaQueryFactory setCondition(String clause);
	fflib_ISchemaQueryFactory setLimit(Integer value);
	fflib_ISchemaQueryFactory setOffset(Integer value);
	fflib_ISchemaQueryFactory setOrdering(fflib_SchemaQueryFactory.Ordering ordering);
	fflib_ISchemaQueryFactory setOrdering(String fieldName, fflib_SchemaQueryFactory.SortOrder direction);
	fflib_ISchemaQueryFactory setOrdering(String fieldName, fflib_SchemaQueryFactory.SortOrder direction, Boolean nullsLast);
	fflib_ISchemaQueryFactory setSortSelectFields(Boolean value);
	fflib_ISchemaQueryFactory subselectQuery(String relationshipName);
	String toSOQL();

	// Schema-based methods
	fflib_ISchemaQueryFactory addOrdering(SObjectField field, fflib_SchemaQueryFactory.SortOrder direction, Boolean nullsLast);
	fflib_ISchemaQueryFactory addOrdering(SObjectField field, fflib_SchemaQueryFactory.SortOrder direction);
	fflib_ISchemaQueryFactory assertIsAccessible();
	fflib_ISchemaQueryFactory deepClone();
	Boolean equals(Object obj);
	fflib_ISchemaQueryFactory selectField(String fieldName, Schema.sOBjectType relatedObjectType);
	fflib_ISchemaQueryFactory selectField(Schema.SObjectField field);
	fflib_ISchemaQueryFactory selectFields(List<Schema.SObjectField> fields);
	fflib_ISchemaQueryFactory selectFields(Set<Schema.SObjectField> fields);
	fflib_ISchemaQueryFactory selectFieldSet(Schema.FieldSet fieldSet);
	fflib_ISchemaQueryFactory selectFieldSet(Schema.FieldSet fieldSet, Boolean allowCrossObject);
	fflib_ISchemaQueryFactory setEnforceFLS(Boolean enforce);
	fflib_ISchemaQueryFactory setOrdering(SObjectField field, fflib_SchemaQueryFactory.SortOrder direction, Boolean nullsLast);
	fflib_ISchemaQueryFactory setOrdering(SObjectField field, fflib_SchemaQueryFactory.SortOrder direction);
	fflib_ISchemaQueryFactory subselectQuery(Schema.ChildRelationship relationship);
	fflib_ISchemaQueryFactory subselectQuery(Schema.ChildRelationship relationship, Boolean assertIsAccessible);
	fflib_ISchemaQueryFactory subselectQuery(SObjectType related);
	fflib_ISchemaQueryFactory subselectQuery(SObjectType related, Boolean assertIsAccessible);
	fflib_ISchemaQueryFactory subselectQuery(String relationshipName, Boolean assertIsAccessible);
}