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


	public void accept(fflib_Expression sqlTreeWalker) {
		//sqlTreeWalker.visitJunction( this );
	}


	virtual public void appendSOQLString(fflib_StringBuilder sb) {
		String fieldPath = fflibQueryFactory.getFieldPath(field, null);

		sb.add(fieldPath);
		sb.add(comparisonOperator);

		appendSOQLString( sb, value );

	}

	public void appendSOQLString(fflib_StringBuilder sb,  Object value) {
		String fieldPath = fflibQueryFactory.getFieldPath(field, null);
		Schema.DisplayType fieldType= fflibQueryFactory.fieldTypeIndexedByName.get(fieldPath);

		switch on fieldType {
			when DATE {
				appendDate(sb, value);
			  }
			  when DATETIME {
				  appendDateTime(sb, value);
			  }
			  when else {
				  appendStringLiteral( sb, value );
			  }
			}
	}

	@TestVisible
	private static void appendStringLiteral(fflib_StringBuilder sb, Object value) {
		String str = '' + value;
		if (( value instanceof String || value instanceof Id) ) {
			str = str.startsWith(':') ? str : '\'' + value + '\'';
			sb.add( str );

		}else{
			sb.add( str );
		}
	}

	@TestVisible
	private static void appendDate(fflib_StringBuilder sb, Object value) {
		if (value instanceof Date) {
			String dateValue= Datetime.newInstance(((Date)value).year(), ((Date)value).month(), ((Date)value).day()).format('YYYY-MM-dd').split(' ')[0];
			sb.add(dateValue);
		} else if (value instanceof String) {
			sb.add(''+ value);
		} else {
			throw new IllegalArgumentException();
		}
	}

	@TestVisible
	private static void appendDateTime(fflib_StringBuilder sb, Object value) {
		if (value instanceof Datetime) {
			sb.add('' + ((Datetime) value).format('yyyy-MM-dd') + 'T' + ((Datetime) value).format('HH:mm:ss') + 'Z');
		} else if (value instanceof String) {
			sb.add(''+ value);

		} else {
			throw new IllegalArgumentException();
		}
	}
}