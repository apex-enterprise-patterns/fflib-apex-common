public interface fflib_IQueryFactoryBase
{
	fflib_IQueryFactoryBase addOrdering(fflib_QueryFactoryBase.Ordering ordering);
	fflib_IQueryFactoryBase addOrdering(String fieldName, fflib_QueryFactoryBase.SortOrder direction);
	fflib_IQueryFactoryBase addOrdering(String fieldName, fflib_QueryFactoryBase.SortOrder direction, Boolean nullsLast);
	fflib_IQueryFactoryBase deepClone();
	String getCondition();
	Integer getLimit();
	Integer getOffset();
	List<fflib_QueryFactoryBase.Ordering> getOrderings();
	List<String> getSelectedFields();
	List<fflib_IQueryFactoryBase> getSubselectQueries();
	fflib_IQueryFactoryBase selectField(String fieldName);
	fflib_IQueryFactoryBase selectFields(List<String> fieldNameList);
	fflib_IQueryFactoryBase selectFields(Set<String> fieldNameSet);
	fflib_IQueryFactoryBase setCondition(String clause);
	fflib_IQueryFactoryBase setLimit(Integer value);
	fflib_IQueryFactoryBase setOffset(Integer value);
	fflib_IQueryFactoryBase setOrdering(fflib_QueryFactoryBase.Ordering ordering);
	fflib_IQueryFactoryBase setOrdering(String fieldName, fflib_QueryFactoryBase.SortOrder direction);
	fflib_IQueryFactoryBase setOrdering(String fieldName, fflib_QueryFactoryBase.SortOrder direction, Boolean nullsLast);
	fflib_IQueryFactoryBase setSortSelectFields(Boolean value);
    fflib_IQueryFactoryBase setSubselectQuery(String relationshipName, fflib_IQueryFactoryBase subselectQuery);
	fflib_IQueryFactoryBase subselectQuery(String relationshipName);
	String toSOQL();
}