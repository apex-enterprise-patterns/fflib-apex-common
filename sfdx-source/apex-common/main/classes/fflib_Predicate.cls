public virtual class fflib_Predicate implements fflib_Expression{

	protected final String comparisonOperator{get; private set;}

//	List<fflib_Expression> expressions;
	protected String field {get; private set;}
	protected Object value {get; private set;}

	protected final fflib_QueryFactory fflibQueryFactory {get; private set;}

	public fflib_Predicate(String comparisonOperator,
							String field,
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


	virtual public void appendSOQLString(fflib_StringBuilder sb) {
		sb.add(fflibQueryFactory.getFieldPath(field, null));
		sb.add(comparisonOperator);

		appendSOQLString( sb, value );

	}

	public static void appendSOQLString(fflib_StringBuilder sb,  Object value) {
		final String str = ''+ value ;
		if ( value instanceof String || value instanceof Id) {
			appendStringLiteral( sb, str );
		}else if (value instanceof Date) {
			sb.add('' + Datetime.newInstance(((Date) value).year(), ((Date) value).month(), ((Date) value).day()).format('yyyy-MM-dd'));
		}// else if (value instanceof Datetime) {
//			sb.add('' + ((Datetime) value).format('yyyy-MM-dd') + 'T' + ((Datetime) value).format('HH:mm:ss') + 'Z');
//		}
		else {
			sb.add( str );
		}
	}

	public static void appendStringLiteral(fflib_StringBuilder sb, String value) {
		//sb.add( '\'' );
		//for ( Integer i = 0; i < value.length(); i++ ) {
		//	final String c= value.substring( i, i+1 );
		if(!value.startsWith(':')){
			sb.add('\''+ value +'\'' );
		}else{
			sb.add( value );
		}

	//	}
	//	sb.add( '\'' );
	}


}