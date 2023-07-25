/**
 * This class represents a criteria builder for constructing dynamic queries in Apex.
 * It provides methods for building various types of predicates and combining them using logical operators.
 */
public class fflib_CriteriaBuilder {

    /**
     * The list of predicates used to build the query.
     */
    public List<fflib_Expression> predicates;

    /**
     * The query factory used to create the query.
     */
    private fflib_QueryFactory fflibQueryFactory;

    /**
     * Constructs a new fflib_CriteriaBuilder with the specified query factory.
     *
     * @param fflibQueryFactory the query factory to use
     */
    public fflib_CriteriaBuilder(fflib_QueryFactory fflibQueryFactory) {
        this.predicates = new List<fflib_Expression>();
        this.fflibQueryFactory = fflibQueryFactory;
    }

    /**
     * Creates a greater than predicate for the specified field and value.
     *
     * @param field the field to compare
     * @param value the value to compare
     * @return the greater than predicate
     */
    public fflib_Expression greatherThan(String field, Object value) {
        return mountPredicate(fflib_ComparisonOperator.GREATER_THAN, field, value);
    }

    /**
     * Creates a predicate that combines two expressions using the logical AND operator.
     *
     * @param x the first expression
     * @param y the second expression
     * @return the combined predicate
     */
    public fflib_Expression withAnd(fflib_Expression x, fflib_Expression y) {
        predicates.remove(predicates.indexOf(x));
        predicates.remove(predicates.indexOf(y));
        final fflib_JunctionPredicate junction = new fflib_JunctionPredicate();
        junction.add(x);
        junction.add(y);
        predicates.add(junction);

        return junction;
    }

    /**
     * Creates a predicate that combines two expressions using the logical OR operator.
     *
     * @param x the first expression
     * @param y the second expression
     * @return the combined predicate
     */
    public fflib_Expression withOr(fflib_Expression x, fflib_Expression y) {
        predicates.remove(predicates.indexOf(x));
        predicates.remove(predicates.indexOf(y));
        final fflib_JunctionPredicate junction = new fflib_JunctionPredicate(fflib_BooleanOperator.WITH_OR);
        junction.add(x);
        junction.add(y);
        predicates.add(junction);
        return junction;
    }

    /**
     * Creates a null predicate for the specified field.
     *
     * @param field the field to check for null
     * @return the null predicate
     */
    public fflib_Expression isNull(String field) {
        return mountPredicate(fflib_ComparisonOperator.EQUAL, field, null);
    }

    /**
     * Creates a not null predicate for the specified field.
     *
     * @param field the field to check for not null
     * @return the not null predicate
     */
    public fflib_Expression notNull(String field) {
        return mountPredicate(fflib_ComparisonOperator.NOT_EQUAL, field, null);
    }

    /**
     * Creates a false predicate for the specified field.
     *
     * @param field the field to check for false
     * @return the false predicate
     */
    public fflib_Expression isFalse(String field) {
        return mountPredicate(fflib_ComparisonOperator.EQUAL, field, false);
    }

    /**
     * Creates a true predicate for the specified field.
     *
     * @param field the field to check for true
     * @return the true predicate
     */
    public fflib_Expression isTrue(String field) {
        return mountPredicate(fflib_ComparisonOperator.EQUAL, field, true);
    }

    /**
     * Creates an "IN" predicate for the specified field and list of values.
     *
     * @param field the field to compare
     * @param value the list of values to compare
     * @return the "IN" predicate
     */
    public fflib_Expression isIn(String field, List<Object> value) {
        fflib_Predicate expression = new fflib_InPredicate(fflib_ComparisonOperator.IS_IN, field, value, fflibQueryFactory);
        predicates.add(expression);
        return expression;
    }

    /**
     * Creates a "NOT IN" predicate for the specified field and list of values.
     *
     * @param field the field to compare
     * @param value the list of values to compare
     * @return the "NOT IN" predicate
     */
    public fflib_Expression notIn(String field, List<Object> value) {
        fflib_Predicate expression = new fflib_InPredicate(fflib_ComparisonOperator.NOT_IN, field, value, fflibQueryFactory);
        predicates.add(expression);
        return expression;
    }

    /**
     * Creates an "IN" predicate for the specified field and subquery.
     *
     * @param field         the field to compare
     * @param queryFactory the subquery to compare
     * @return the "IN" predicate
     */
    public fflib_Expression isIn(String field, fflib_QueryFactory queryFactory) {
        fflib_Predicate expression = new fflib_InPredicate(fflib_ComparisonOperator.IS_IN, field, queryFactory, fflibQueryFactory);
        predicates.add(expression);
        return expression;
    }

    /**
     * Creates a "NOT IN" predicate for the specified field and subquery.
     *
     * @param field         the field to compare
     * @param queryFactory the subquery to compare
     * @return the "NOT IN" predicate
     */
    public fflib_Expression notIn(String field, fflib_QueryFactory queryFactory) {
        fflib_Predicate expression = new fflib_InPredicate(fflib_ComparisonOperator.NOT_IN, field, queryFactory, fflibQueryFactory);
        predicates.add(expression);
        return expression;
    }

    /**
     * Creates an "IN" predicate for the specified field and value.
     *
     * @param field the field to compare
     * @param value the value to compare
     * @return the "IN" predicate
     */
    public fflib_Expression isIn(String field, String value) {
        fflib_Predicate expression = new fflib_InPredicate(fflib_ComparisonOperator.IS_IN, field, value, fflibQueryFactory);
        predicates.add(expression);
        return expression;
    }
    /**
     * Creates an "NOT IN" predicate for the specified field and value.
     *
     * @param field the field to compare
     * @param value the value to compare
     * @return the "IN" predicate
     */
    public fflib_Expression notIn(String field, String value) {
        fflib_Predicate expression = new fflib_InPredicate(fflib_ComparisonOperator.NOT_IN, field, value, fflibQueryFactory);
        predicates.add(expression);
        return expression;
    }

    /**
     * Creates a greater than or equals to predicate for the specified field and value.
     *
     * @param field the field to compare
     * @param value the value to compare
     * @return the greater than or equals to predicate
     */
    public fflib_Expression greatherThanOrEqualsTo(String field, Object value) {
        return mountPredicate(fflib_ComparisonOperator.GREATER_THAN_OR_EQUAL, field, value);
    }

    /**
     * Creates an equals predicate for the specified field and value.
     *
     * @param field the field to compare
     * @param value the value to compare
     * @return the equals predicate
     */
    public fflib_Expression equals(String field, Object value) {
        return mountPredicate(fflib_ComparisonOperator.EQUAL, field, value);
    }

    /**
     * Creates a not equals predicate for the specified field and value.
     *
     * @param field the field to compare
     * @param value the value to compare
     * @return the not equals predicate
     */
    public fflib_Expression notEquals(String field, Object value) {
        return mountPredicate(fflib_ComparisonOperator.NOT_EQUAL, field, value);
    }

    /**
     * Creates a less than predicate for the specified field and value.
     *
     * @param field the field to compare
     * @param value the value to compare
     * @return the less than predicate
     */
    public fflib_Expression lessThan(String field, Object value) {
        return mountPredicate(fflib_ComparisonOperator.LESS_THAN, field, value);
    }

    /**
     * Creates a less than or equals to predicate for the specified field and value.
     *
     * @param field the field to compare
     * @param value the value to compare
     * @return the less than or equals to predicate
     */
    public fflib_Expression lessThanOrEqualsTo(String field, Object value) {
        return mountPredicate(fflib_ComparisonOperator.LESS_THAN_OR_EQUAL, field, value);
    }

    /**
     * Creates a "LIKE" predicate for the specified field and value.
     *
     * @param field the field to compare
     * @param value the value to compare
     * @return the "LIKE" predicate
     */
    public fflib_Predicate isLike(String field, Object value) {
        fflib_Predicate expression = new fflib_LikePredicate(fflib_ComparisonOperator.IS_LIKE, field, value, fflibQueryFactory);
        predicates.add(expression);
        return expression;
    }

    /**
     * Creates a "NOT LIKE" predicate for the specified field and value.
     *
     * @param field the field to compare
     * @param value the value to compare
     * @return the "NOT LIKE" predicate
     */
    public fflib_Predicate notLike(String field, Object value) {
        fflib_Predicate expression = new fflib_LikePredicate(fflib_ComparisonOperator.NOT_LIKE, field, value, fflibQueryFactory);
        predicates.add(expression);
        return expression;
    }

    //	public fflib_Predicate includes(fflib_Expression y){
//		fflib_Predicate expression= new fflib_Predicate(fflib_ComparisonOperator.GREATER_THAN, field, value);
//		predicates.add(expression);
//		return expression;
//
//	}
//
//	public fflib_Predicate excludes(fflib_Expression y){
//		fflib_Predicate expression= new fflib_Predicate(fflib_ComparisonOperator.GREATER_THAN, field, value);
//		predicates.add(expression);
//		return expression;
//
//	}


    /**
     * Converts the criteria builder to a SOQL query string.
     *
     * @return the SOQL query string
     */
    public String toSoql() {
        fflib_StringBuilder sb = new fflib_StringBuilder();
        for (fflib_Expression next : predicates) {
            System.debug('[next::fflib_Expression]:watches ' + (next));
            next.appendSOQLString(sb);
        }
        return sb.getStringValue();
    }

    /**
     * Mounts a predicate with the specified operation, field, and value.
     *
     * @param operation the operation of the predicate
     * @param field     the field to compare
     * @param value     the value to compare
     * @return the mounted predicate
     */
    private fflib_Predicate mountPredicate(String operation, String field, Object value) {
        fflib_Predicate expression = new fflib_Predicate(operation, field, value, fflibQueryFactory);
        predicates.add(expression);
        return expression;
    }
}