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