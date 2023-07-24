public class fflib_CriteriaBuilder{
	

	public List<fflib_Expression> predicates;
	private fflib_QueryFactory fflibQueryFactory;

	public fflib_CriteriaBuilder(fflib_QueryFactory fflibQueryFactory) {
		this.predicates = new List<fflib_Expression>();
		this.fflibQueryFactory = fflibQueryFactory;
	}

	public fflib_Expression greatherThan(String field, Object value){
		return mountPredicate(fflib_ComparisonOperator.GREATER_THAN, field, value);
	}
	public fflib_Expression withAnd(fflib_Expression x, fflib_Expression y){
		predicates.remove(predicates.indexOf(x));
		predicates.remove(predicates.indexOf(y));
		final fflib_JunctionPredicate junction = new fflib_JunctionPredicate();
		junction.add(x);
		junction.add(y);
		predicates.add(junction);

		return junction;
	}

	public fflib_Expression withOr(fflib_Expression x, fflib_Expression y ){
		predicates.remove(predicates.indexOf(x));
		predicates.remove(predicates.indexOf(y));
		final fflib_JunctionPredicate junction = new fflib_JunctionPredicate(fflib_BooleanOperator.WITH_OR);
		junction.add(x);
		junction.add(y);
		predicates.add(junction);
		return junction;

	}
	public fflib_Expression isNull(String field){
		return mountPredicate(fflib_ComparisonOperator.EQUAL, field, null);
	}

	public fflib_Expression notNull(String field){
		return mountPredicate(fflib_ComparisonOperator.NOT_EQUAL, field, null);
	}
	public fflib_Expression isFalse(String field){
		return mountPredicate(fflib_ComparisonOperator.EQUAL, field, false);
	}

	public fflib_Expression isTrue(String field){
		return mountPredicate(fflib_ComparisonOperator.EQUAL, field, true);
	}

	public fflib_Expression isIn(String field, List<Object> value){
		fflib_Predicate expression = new fflib_InPredicate(fflib_ComparisonOperator.IS_IN, field, value, fflibQueryFactory);
		predicates.add(expression);
		return expression;
	}
	public fflib_Expression notIn(String field, List<Object> value){
		fflib_Predicate expression = new fflib_InPredicate(fflib_ComparisonOperator.NOT_IN, field, value, fflibQueryFactory);
		predicates.add(expression);
		return expression;
	}
	public fflib_Expression notIn(String field, String value){
		fflib_Predicate expression = new fflib_InPredicate(fflib_ComparisonOperator.NOT_IN, field, value, fflibQueryFactory);
		predicates.add(expression);
		return expression;

	}
	public fflib_Expression isIn(String field, String value){
		fflib_Predicate expression = new fflib_InPredicate(fflib_ComparisonOperator.IS_IN, field, value, fflibQueryFactory);
		predicates.add(expression);
		return expression;
	}
	public fflib_Expression greatherThanOrEqualsTo(String field, Object value){
		return mountPredicate(fflib_ComparisonOperator.GREATER_THAN_OR_EQUAL, field, value);
	}
	public fflib_Expression equals(String field, Object value){
		return mountPredicate(fflib_ComparisonOperator.EQUAL, field, value);
	}
	public fflib_Expression notEquals(String field, Object value){
		return mountPredicate(fflib_ComparisonOperator.NOT_EQUAL, field, value);
	}

	public fflib_Expression lessThan(String field, Object value){
		return mountPredicate(fflib_ComparisonOperator.LESS_THAN, field, value);
	}

	public fflib_Expression lessThanOrEqualsTo(String field, Object value){
		return mountPredicate(fflib_ComparisonOperator.LESS_THAN_OR_EQUAL, field, value);
	}

	public fflib_Predicate isLike(String field, Object value){
		fflib_Predicate expression = new fflib_LikePredicate(fflib_ComparisonOperator.IS_LIKE, field, value, fflibQueryFactory);
		predicates.add(expression);
		return expression;
	}

	public fflib_Predicate notLike(String field, Object value){
		fflib_Predicate expression = new fflib_LikePredicate(fflib_ComparisonOperator.NOT_LIKE, field, value, fflibQueryFactory);
		predicates.add(expression);
		return expression;

	}


//	public fflib_Predicate includes(fflib_Expression y){
//		fflib_Predicate expression= new fflib_Predicate(fflib_ComparisonOperator.GREATER_THAN, field, value);
//		predicates.add(expression);
//		return expression;
//
//	}
//
//	public fflib_Predicate excludes(fflib_Expression y){
//		fflib_Predicate expression= new fflib_Predicate(fflib_ComparisonOperator.GREATER_THAN, field, value);
//		predicates.add(expression);
//		return expression;
//
//	}

	public String toSoql(){
		fflib_StringBuilder sb = new fflib_StringBuilder();
		for (fflib_Expression next : predicates) {
			System.debug('[next::fflib_Expression]:watches ' + (next));
			next.appendSOQLString(sb);
		}
		return sb.getStringValue();
	}

	public fflib_Predicate mountPredicate(String operation, String field, Object value) {
		fflib_Predicate expression = new fflib_Predicate(operation, field, value, fflibQueryFactory);
		predicates.add(expression);
		return expression;
	}
}