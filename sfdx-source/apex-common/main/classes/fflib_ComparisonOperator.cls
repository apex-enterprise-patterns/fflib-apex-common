/**
 * This class defines the comparison operators used in the fflib_CriteriaBuilder class.
 * It provides constants for various comparison operators and abstract methods for negation, inversion, broadening, and sharpening.
 */
public class fflib_ComparisonOperator {
    
    /**
     * The equal operator.
     */
    public static final String EQUAL = ' = ';
    
    /**
     * The not equal operator.
     */
    public static final String NOT_EQUAL = ' != ';
    
    /**
     * The less than operator.
     */
    public static final String LESS_THAN = ' < ';
    
    /**
     * The less than or equal operator.
     */
    public static final String LESS_THAN_OR_EQUAL = ' <= ';
    
    /**
     * The greater than operator.
     */
    public static final String GREATER_THAN = ' > ';
    
    /**
     * The greater than or equal operator.
     */
    public static final String GREATER_THAN_OR_EQUAL = ' >= ';
    
    /**
     * The 'IN' operator.
     */
    public static final String IS_IN = ' IN ';
    
    /**
     * The 'NOT IN' operator.
     */
    public static final String NOT_IN = ' NOT IN ';
    
    /**
     * The 'LIKE' operator.
     */
    public static final String IS_LIKE = ' LIKE ';
    
    /**
     * The 'NOT LIKE' operator.
     */
    public static final String NOT_LIKE = ' NOT LIKE ';
    
    /**
     * Negates the comparison operator.
     *
     * @return the negated comparison operator
     */
    //public abstract ComparisonOperator negated();
    
    /**
     * Inverts the comparison operator.
     *
     * @return the inverted comparison operator
     */
    //public abstract ComparisonOperator invert();
    
    /**
     * Broadens the comparison operator.
     *
     * @return the broadened comparison operator
     */
    //public abstract ComparisonOperator broader();
    
    /**
     * Sharpens the comparison operator.
     *
     * @return the sharpened comparison operator
     */
    //public abstract ComparisonOperator sharper();
    
    /**
     * Returns the SQL text representation of the comparison operator.
     *
     * @return the SQL text representation
     */
    //public abstract String sqlText();
}