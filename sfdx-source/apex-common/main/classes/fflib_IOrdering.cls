public interface fflib_IOrdering
{
	fflib_Ordering.SortOrder getDirection();
	String getField();
	String getOrdering();
	String getOrderingClause();
}