public interface fflib_IQueryFactory_New
	extends fflib_IQueryFactoryBase
{
	fflib_IQueryFactory_New addOrdering(SObjectField field, fflib_QueryFactoryBase.SortOrder direction, Boolean nullsLast);
	fflib_IQueryFactory_New addOrdering(SObjectField field, fflib_QueryFactoryBase.SortOrder direction);
	fflib_IQueryFactory_New assertIsAccessible();
	Boolean equals(Object obj);
	fflib_IQueryFactory_New selectField(String fieldName, Schema.sOBjectType relatedObjectType);
	fflib_IQueryFactory_New selectField(Schema.SObjectField field);
	fflib_IQueryFactory_New selectFields(List<Schema.SObjectField> fields);
	fflib_IQueryFactory_New selectFields(Set<Schema.SObjectField> fields);
	fflib_IQueryFactory_New selectFieldSet(Schema.FieldSet fieldSet);
	fflib_IQueryFactory_New selectFieldSet(Schema.FieldSet fieldSet, Boolean allowCrossObject);
	fflib_IQueryFactory_New setEnforceFLS(Boolean enforce);
	fflib_IQueryFactory_New setOrdering(SObjectField field, fflib_QueryFactoryBase.SortOrder direction, Boolean nullsLast);
	fflib_IQueryFactory_New setOrdering(SObjectField field, fflib_QueryFactoryBase.SortOrder direction);
	fflib_IQueryFactory_New subselectQuery(SObjectType related);
	fflib_IQueryFactory_New subselectQuery(SObjectType related, Boolean assertIsAccessible);
	fflib_IQueryFactory_New subselectQuery(Schema.ChildRelationship relationship);
	fflib_IQueryFactory_New subselectQuery(Schema.ChildRelationship relationship, Boolean assertIsAccessible);
}