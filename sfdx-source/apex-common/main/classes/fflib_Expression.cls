/**
 * This interface represents an expression in the fflib_CriteriaBuilder class.
 * It defines methods for adding predicates, accepting predicates, and appending the SOQL string representation.
 */
public interface fflib_Expression {

    /**
     * Adds a predicate to the expression.
     *
     * @param predicate the predicate to add
     */
    void add(fflib_Expression predicate);

    /**
     * Accepts a predicate.
     *
     * @param fflibPredicate the predicate to accept
     */
    void accept(fflib_Expression fflibPredicate);

    /**
     * Appends the SOQL string representation of the expression to the specified string builder.
     *
     * @param sb    the string builder to append the SOQL string to
     */
	void appendSOQLString(fflib_StringBuilder sb);
}