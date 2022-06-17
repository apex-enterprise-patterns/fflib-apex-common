public interface fflib_IQueryFactoryBase
{
	fflib_IQueryFactoryBase addOrdering(fflib_Ordering ordering);
	fflib_IQueryFactoryBase addOrdering(String fieldName, fflib_Ordering.SortOrder direction);
	fflib_IQueryFactoryBase addOrdering(String fieldName, fflib_Ordering.SortOrder direction, Boolean nullsLast);
	fflib_IQueryFactoryBase deepClone();
	Boolean equals(Object obj);
	String getCondition();
	Set<String> getFields();
	Integer getLimit();
	Integer getOffset();
	String getOrderingClause();
	List<fflib_Ordering> getOrderings();
	List<String> getSelectedFields();
	List<fflib_IQueryFactoryBase> getSubselectQueries();
	String getTable();
	String getWhereClause();
	fflib_IQueryFactoryBase selectField(String fieldName);
	fflib_IQueryFactoryBase selectFields(List<String> fieldNameList);
	fflib_IQueryFactoryBase selectFields(Set<String> fieldNameSet);
	fflib_IQueryFactoryBase setCondition(String clause);
	fflib_IQueryFactoryBase setLimit(Integer value);
	fflib_IQueryFactoryBase setOffset(Integer value);
	fflib_IQueryFactoryBase setOrdering(fflib_Ordering ordering);
	fflib_IQueryFactoryBase setOrdering(String fieldName, fflib_Ordering.SortOrder direction);
	fflib_IQueryFactoryBase setOrdering(String fieldName, fflib_Ordering.SortOrder direction, Boolean nullsLast);
	fflib_IQueryFactoryBase setSortSelectFields(Boolean value);
	fflib_IQueryFactoryBase subselectQuery(String relationshipName);
	String toSOQL();
}