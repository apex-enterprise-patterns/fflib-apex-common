/**
 * This class represents a "LIKE" predicate in the fflib_CriteriaBuilder class.
 * It extends the fflib_Predicate class and provides additional functionality for handling "LIKE" comparisons.
 */
public class fflib_LikePredicate extends fflib_Predicate {

    /**
     * Constructs a new fflib_LikePredicate with the specified comparison operator, field, value, and query factory.
     *
     * @param comparisonOperator the comparison operator of the predicate
     * @param field              the field to compare
     * @param value              the value to compare
     * @param fflibQueryFactory  the query factory to use
     */
    public fflib_LikePredicate(String comparisonOperator, String field, Object value, fflib_QueryFactory fflibQueryFactory) {
        super(comparisonOperator, field, value, fflibQueryFactory);
    }

    /**
     * Appends the SOQL string representation of the "LIKE" predicate to the specified string builder.
     *
     * @param sb the string builder to append the SOQL string to
     */
    override
    public void appendSOQLString(fflib_StringBuilder sb) {
        sb.add('(');

        if (comparisonOperator == fflib_ComparisonOperator.NOT_LIKE) {
            sb.add('NOT ');
        }
        sb.add(fflibQueryFactory.getFieldPath(field, null));
        sb.add(fflib_ComparisonOperator.IS_LIKE);

        appendSOQLString(sb, value);
        sb.add(')');
    }
}