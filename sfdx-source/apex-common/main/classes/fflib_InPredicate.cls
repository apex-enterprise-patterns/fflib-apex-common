public with sharing class fflib_InPredicate  extends fflib_Predicate {
    public fflib_InPredicate(String comparisonOperator,
        String field,
        Object value,
        fflib_QueryFactory fflibQueryFactory) {
        super(comparisonOperator, field, value, fflibQueryFactory);
    }

    override
	public void appendSOQLString(fflib_StringBuilder sb) {
		sb.add(fflibQueryFactory.getFieldPath(field, null));

		sb.add( comparisonOperator + '(' );

		if(value instanceof List<fflib_Expression>) {
			List<fflib_Expression> listExpressions= ((List<fflib_Expression>)value);
			listExpressions.get(0).appendSOQLString(sb);
			for (Integer i = 1; i < listExpressions.size(); i++) {
				sb.add(', ');
				listExpressions.get(i).appendSOQLString(sb);
			}
		}else if(value instanceof List<Object>){
			List<Object> listExpressions= ((List<Object>)value);
			fflib_StringBuilder builder = new fflib_StringBuilder.CommaDelimitedListBuilder();
			for (Integer i = 0; i < listExpressions.size(); i++) {
				appendSOQLString(builder, listExpressions.get(i));

			}
			sb.add(builder.toString());
		}else{
			appendSOQLString(sb, value);
		}
		sb.add( ')' );
	}

}