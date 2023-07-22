/*
 * Class used for involving expressions in AND/OR
 */
public class fflib_JunctionPredicate implements fflib_Expression{

	public fflib_JunctionPredicate() {
		this( fflib_BooleanOperator.WITH_AND );
	}

	public fflib_JunctionPredicate(fflib_BooleanOperator nature) {

		this.booleanOperator=nature;
		this.expressions = new List<fflib_Expression>();
	}


	private final fflib_BooleanOperator booleanOperator;


	List<fflib_Expression> expressions;

	public fflib_BooleanOperator getBooleanOperator() {
		return booleanOperator;
	}

	public void accept(fflib_Predicate fflibPredicate) {
	}

	public void add(fflib_Expression predicate) {
		expressions.add( predicate );
	}

	public String toSoql() {
		return null;
	}

	public void appendSOQLString(fflib_StringBuilder sb) {
		final String separator = booleanOperator == fflib_BooleanOperator.WITH_AND
								 ? ' and '
								 : ' or ';
		appendJunctionSOQLString( expressions.get( 0 ), sb );
		for ( Integer i = 1; i < expressions.size(); i++ ) {
			System.debug('[separator::String]:watches ' + JSON.serialize(separator));
			sb.add( separator );
			appendJunctionSOQLString( expressions.get( i ), sb );
		}
	}

	private void appendJunctionSOQLString(fflib_Expression expression, fflib_StringBuilder sb){

		System.debug('[expression::fflib_Expression]:watches' + expression);
		if ( expression instanceof fflib_JunctionPredicate ) {
			final fflib_JunctionPredicate junction = (fflib_JunctionPredicate) expression;
			// If we have the same nature, or if this is a disjunction and the operand is a conjunction,
			// then we don't need parenthesis, because the AND operator binds stronger
			if ( booleanOperator == junction.booleanOperator || booleanOperator == fflib_BooleanOperator.WITH_OR ) {
				junction.appendSOQLString( sb );
			} else {
				sb.add( '(' );
				junction.appendSOQLString( sb );
				sb.add( ')' );
			}
		} else {
			expression.appendSOQLString( sb );
		}

	}

}