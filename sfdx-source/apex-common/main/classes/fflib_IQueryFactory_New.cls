public interface fflib_IQueryFactory_New
{
	// Overrides (sortof) from fflib_IQueryFactory_New
	fflib_IQueryFactory_New addOrdering(fflib_QueryFactory_New.Ordering ordering);
	fflib_IQueryFactory_New addOrdering(String fieldName, fflib_QueryFactory_New.SortOrder direction);
	fflib_IQueryFactory_New addOrdering(String fieldName, fflib_QueryFactory_New.SortOrder direction, Boolean nullsLast);
	String getCondition();
	Set<String> getFields();
	Integer getLimit();
	Integer getOffset();
	String getOrderingClause();
	List<fflib_QueryFactory_New.Ordering> getOrderings();
	List<String> getSelectedFields();
	List<fflib_IQueryFactory_New> getSubselectQueries();
	SObjectType getTable();
	String getWhereClause();
	fflib_IQueryFactory_New selectField(String fieldName);
	fflib_IQueryFactory_New selectFields(List<String> fieldNameList);
	fflib_IQueryFactory_New selectFields(Set<String> fieldNameSet);
	fflib_IQueryFactory_New setCondition(String clause);
	fflib_IQueryFactory_New setLimit(Integer value);
	fflib_IQueryFactory_New setOffset(Integer value);
	fflib_IQueryFactory_New setOrdering(fflib_QueryFactory_New.Ordering ordering);
	fflib_IQueryFactory_New setOrdering(String fieldName, fflib_QueryFactory_New.SortOrder direction);
	fflib_IQueryFactory_New setOrdering(String fieldName, fflib_QueryFactory_New.SortOrder direction, Boolean nullsLast);
	fflib_IQueryFactory_New setSortSelectFields(Boolean value);
	fflib_IQueryFactory_New subselectQuery(String relationshipName);
	String toSOQL();

	// Schema-based methods
	fflib_IQueryFactory_New addOrdering(SObjectField field, fflib_QueryFactory_New.SortOrder direction, Boolean nullsLast);
	fflib_IQueryFactory_New addOrdering(SObjectField field, fflib_QueryFactory_New.SortOrder direction);
	fflib_IQueryFactory_New assertIsAccessible();
	fflib_IQueryFactory_New deepClone();
	Boolean equals(Object obj);
	fflib_IQueryFactory_New selectField(String fieldName, Schema.sOBjectType relatedObjectType);
	fflib_IQueryFactory_New selectField(Schema.SObjectField field);
	fflib_IQueryFactory_New selectFields(List<Schema.SObjectField> fields);
	fflib_IQueryFactory_New selectFields(Set<Schema.SObjectField> fields);
	fflib_IQueryFactory_New selectFieldSet(Schema.FieldSet fieldSet);
	fflib_IQueryFactory_New selectFieldSet(Schema.FieldSet fieldSet, Boolean allowCrossObject);
	fflib_IQueryFactory_New setEnforceFLS(Boolean enforce);
	fflib_IQueryFactory_New setOrdering(SObjectField field, fflib_QueryFactory_New.SortOrder direction, Boolean nullsLast);
	fflib_IQueryFactory_New setOrdering(SObjectField field, fflib_QueryFactory_New.SortOrder direction);
	fflib_IQueryFactory_New subselectQuery(Schema.ChildRelationship relationship);
	fflib_IQueryFactory_New subselectQuery(Schema.ChildRelationship relationship, Boolean assertIsAccessible);
	fflib_IQueryFactory_New subselectQuery(SObjectType related);
	fflib_IQueryFactory_New subselectQuery(SObjectType related, Boolean assertIsAccessible);
	fflib_IQueryFactory_New subselectQuery(String relationshipName, Boolean assertIsAccessible);
}