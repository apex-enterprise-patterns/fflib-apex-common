/**
 * This class represents a junction predicate in the fflib_CriteriaBuilder class.
 * It implements the fflib_Expression interface and provides functionality for combining expressions using logical operators.
 */
public class fflib_JunctionPredicate implements fflib_Expression {

    /**
     * The boolean operator of the junction predicate.
     */
    private final fflib_BooleanOperator booleanOperator;

    /**
     * The list of expressions in the junction predicate.
     */
    private List<fflib_Expression> expressions;

    /**
     * Constructs a new fflib_JunctionPredicate with the default boolean operator WITH_AND.
     */
    public fflib_JunctionPredicate() {
        this(fflib_BooleanOperator.WITH_AND);
    }

    /**
     * Constructs a new fflib_JunctionPredicate with the specified boolean operator.
     *
     * @param nature the boolean operator of the junction predicate
     */
    public fflib_JunctionPredicate(fflib_BooleanOperator nature) {
        this.booleanOperator = nature;
        this.expressions = new List<fflib_Expression>();
    }

    /**
     * Adds a predicate to the junction predicate.
     *
     * @param predicate the predicate to add
     */
    public void add(fflib_Expression predicate) {
        expressions.add(predicate);
    }
    //	public void visitJunction(fflib_Expression junction) {
    //		for ( fflib_Expression predicate : junction.getPredicates() ) {
    //			predicate.accept( this );
    //		}
    //	}
    public void accept(fflib_Expression sqlTreeWalker) {
        //sqlTreeWalker.visitJunction( this );
    }

    /**
     * Appends the SOQL string representation of the junction predicate to the specified string builder.
     *
     * @param sb the string builder to append the SOQL string to
     */
    public void appendSOQLString(fflib_StringBuilder sb) {
        final String separator = booleanOperator == fflib_BooleanOperator.WITH_AND ? ' AND ' : ' OR ';
        appendJunctionSOQLString(expressions.get(0), sb);
        for (Integer i = 1; i < expressions.size(); i++) {
            sb.add(separator);
            appendJunctionSOQLString(expressions.get(i), sb);
        }
    }

    /**
     * Appends the SOQL string representation of the expression to the specified string builder.
     *
     * @param expression the expression to append
     * @param sb         the string builder to append the SOQL string to
     */
    private void appendJunctionSOQLString(fflib_Expression expression, fflib_StringBuilder sb) {
        if (expression instanceof fflib_JunctionPredicate) {
            final fflib_JunctionPredicate junction = (fflib_JunctionPredicate) expression;
            if (booleanOperator == junction.booleanOperator || booleanOperator == fflib_BooleanOperator.WITH_OR) {
                junction.appendSOQLString(sb);
            } else {
                sb.add('(');
                junction.appendSOQLString(sb);
                sb.add(')');
            }
        } else {
            expression.appendSOQLString(sb);
        }
    }
}