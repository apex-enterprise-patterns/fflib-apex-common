public class fflib_Predicate implements fflib_Expression{

	private final String comparisonOperator;

//	List<fflib_Expression> expressions;
	Schema.SObjectField field;
	Object value;

	private fflib_QueryFactory fflibQueryFactory;

	public fflib_Predicate(String comparisonOperator,
						   SObjectField field,
						   Object value, fflib_QueryFactory fflibQueryFactory) {
		this.comparisonOperator = comparisonOperator;
		this.field = field;
		this.value = value;
		this.fflibQueryFactory = fflibQueryFactory;

	}

	public void add(fflib_Expression predicate) {
//		expressions.add( predicate );
	}

//	public List<fflib_Expression> getPredicates() {
//		return expressions;
//	}
//
//	public boolean isEmpty() {
//		return expressions.isEmpty();
//	}

//	public void visitJunction(fflib_Predicate junction) {
//		for ( fflib_Expression predicate : junction.getPredicates() ) {
//			predicate.accept( this );
//		}
//	}


	public void accept(fflib_Predicate sqlTreeWalker) {
		//sqlTreeWalker.visitJunction( this );
	}


	public void appendSOQLString(fflib_StringBuilder sb) {
		sb.add(fflibQueryFactory.getFieldPath(field.getDescribe().getLocalName(), null));
		sb.add(comparisonOperator);

		appendSOQLString( sb, value );

	}

	public static void appendSOQLString(fflib_StringBuilder sb,  Object value) {
		final String str = ''+ value ;

		if ( value instanceof String ) {
			appendStringLiteral( sb, str );
		}
		else {
			sb.add( str );
		}
	}

	public static void appendStringLiteral(fflib_StringBuilder sb, String value) {
		//sb.add( '\'' );
		//for ( Integer i = 0; i < value.length(); i++ ) {
		//	final String c= value.substring( i, i+1 );

			sb.add('\''+ value +'\'' );
	//	}
	//	sb.add( '\'' );
	}


}