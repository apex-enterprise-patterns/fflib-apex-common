public with sharing class fflib_InPredicate  extends fflib_Predicate {
    public fflib_InPredicate(String comparisonOperator,
        String field,
        Object value,
        fflib_QueryFactory fflibQueryFactory) {
        super(comparisonOperator, field, value, fflibQueryFactory);
    }

    override
	public void appendSOQLString(fflib_StringBuilder sb) {
		if ( comparisonOperator == fflib_ComparisonOperator.NOT_IN ) {
			sb.add( ' not' );
		}
		sb.add( fflib_ComparisonOperator.IS_IN + '(' );
		if(value instanceof List<fflib_Expression>) {
			List<fflib_Expression> listExpressions= ((List<fflib_Expression>)value);
			listExpressions.get(0).appendSOQLString(sb);
			for (Integer i = 1; i < listExpressions.size(); i++) {
				sb.add(', ');
				listExpressions.get(i).appendSOQLString(sb);
			}
		}else{
			List<Object> listExpressions= ((List<Object>)value);
			for (Integer i = 0; i < listExpressions.size(); i++) {
				appendSOQLString(sb, listExpressions.get(i));
				sb.add(', ');

			}
		}
		sb.add( ')' );
	}

}