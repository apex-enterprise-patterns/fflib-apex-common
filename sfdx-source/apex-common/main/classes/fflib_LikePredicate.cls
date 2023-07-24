public class fflib_LikePredicate extends fflib_Predicate{

	public fflib_LikePredicate(String comparisonOperator,
							   String field,
							   Object value,
							   fflib_QueryFactory fflibQueryFactory) {
		super(comparisonOperator, field, value, fflibQueryFactory);
	}

	override
	public void appendSOQLString(fflib_StringBuilder sb) {
		sb.add('(');

		if(comparisonOperator == fflib_ComparisonOperator.NOT_LIKE){
			sb.add('NOT ');
		}
		sb.add(fflibQueryFactory.getFieldPath(field, null));
		sb.add(fflib_ComparisonOperator.IS_LIKE);

		appendSOQLString( sb, value );
		sb.add(')');

	}
}