/**
 * This class represents an "IN" predicate in the fflib_CriteriaBuilder class.
 * It extends the fflib_Predicate class and provides additional functionality for handling "IN" comparisons.
 */
public with sharing class fflib_InPredicate extends fflib_Predicate {

    /**
     * Constructs a new fflib_InPredicate with the specified comparison operator, field, value, and query factory.
     *
     * @param comparisonOperator the comparison operator of the predicate
     * @param field              the field to compare
     * @param value              the value to compare
     * @param fflibQueryFactory  the query factory to use
     */
    public fflib_InPredicate(String comparisonOperator, String field, Object value, fflib_QueryFactory fflibQueryFactory) {
        super(comparisonOperator, field, value, fflibQueryFactory);
    }

    /**
     * Appends the SOQL string representation of the "IN" predicate to the specified string builder.
     *
     * @param sb the string builder to append the SOQL string to
     */
    override
    public void appendSOQLString(fflib_StringBuilder sb) {
        sb.add(fflibQueryFactory.getFieldPath(field, null));

        sb.add(comparisonOperator + '(');

        if (value instanceof List<fflib_Expression>) {
            List<fflib_Expression> listExpressions = ((List<fflib_Expression>) value);
            listExpressions.get(0).appendSOQLString(sb);
            for (Integer i = 1; i < listExpressions.size(); i++) {
                sb.add(', ');
                listExpressions.get(i).appendSOQLString(sb);
            }
        } else if (value instanceof List<Object>) {
            List<Object> listExpressions = ((List<Object>) value);
            fflib_StringBuilder builder = new fflib_StringBuilder.CommaDelimitedListBuilder();
            for (Integer i = 0; i < listExpressions.size(); i++) {
                appendSOQLString(builder, listExpressions.get(i));
            }
            sb.add(builder.toString());
        } else if (value instanceof fflib_QueryFactory) {
            sb.add(((fflib_QueryFactory) value).toSOQL());
        } else {
            appendSOQLString(sb, value);
        }
        sb.add(')');
    }
}