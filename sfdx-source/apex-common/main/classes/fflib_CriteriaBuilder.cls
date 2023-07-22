public class fflib_CriteriaBuilder{
	

	public List<fflib_Expression> predicates;
	private fflib_QueryFactory fflibQueryFactory;

	public fflib_CriteriaBuilder(fflib_QueryFactory fflibQueryFactory) {
		this.predicates = new List<fflib_Expression>();
		this.fflibQueryFactory = fflibQueryFactory;
	}

	public fflib_Expression greatherThan(Schema.SObjectField field, Object value){
		fflib_Predicate expression= new fflib_Predicate(fflib_ComparisonOperator.GREATER_THAN, field, value, fflibQueryFactory);
		predicates.add(expression);
		return expression;
	}
	public fflib_Expression withAnd(fflib_Expression x, fflib_Expression y){
		final fflib_JunctionPredicate junction = new fflib_JunctionPredicate();
		junction.add(x);
		junction.add(y);
		predicates.add(junction);

		return junction;
	}
	public fflib_Expression withAnd(fflib_Expression x){
		final fflib_JunctionPredicate junction = new fflib_JunctionPredicate();
		junction.add(x);
		predicates.add(junction);

		return junction;

	}

	public fflib_Expression withOr(fflib_Expression x, fflib_Expression y ){
		final fflib_JunctionPredicate junction = new fflib_JunctionPredicate(fflib_BooleanOperator.WITH_OR);
		junction.add(x);
		junction.add(y);
		predicates.add(junction);
		return junction;

	}

	public fflib_Expression withOr(fflib_Expression x ){
		final fflib_JunctionPredicate junction = new fflib_JunctionPredicate(fflib_BooleanOperator.WITH_OR);
		junction.add(x);
		predicates.add(junction);
		return junction;
	}


	public fflib_Expression isFalse(Schema.SObjectField field){
		fflib_Predicate expression= new fflib_Predicate(fflib_ComparisonOperator.GREATER_THAN, field, false, fflibQueryFactory);
		predicates.add(expression);
		return expression;

	}

	public fflib_Expression isTrue(Schema.SObjectField field){
		fflib_Predicate expression= new fflib_Predicate(fflib_ComparisonOperator.GREATER_THAN, field, true, fflibQueryFactory);
		predicates.add(expression);
		return expression;

	}

	public fflib_Expression isIn(Schema.SObjectField field, List<Object> value){
		fflib_Predicate expression= new fflib_Predicate(fflib_ComparisonOperator.IS_IN, field, value, fflibQueryFactory);
		predicates.add(expression);
		return expression;

	}
	public fflib_Expression notIn(Schema.SObjectField field, Object value){
		fflib_Predicate expression= new fflib_Predicate(fflib_ComparisonOperator.GREATER_THAN, field, value, fflibQueryFactory);
		predicates.add(expression);
		return expression;

	}


	public fflib_Expression greatherThanOrEqualsTo(Schema.SObjectField field, Object value){
		fflib_Predicate expression= new fflib_Predicate(fflib_ComparisonOperator.GREATER_THAN_OR_EQUAL, field, value, fflibQueryFactory);
		predicates.add(expression);
		return expression;

	}
	public fflib_Expression equals(Schema.SObjectField field, Object value){
		fflib_Predicate expression= new fflib_Predicate(fflib_ComparisonOperator.EQUAL, field, value, fflibQueryFactory);
		predicates.add(expression);
		return expression;

	}
	public fflib_Expression notEquals(Schema.SObjectField field, Object value){
		fflib_Predicate expression= new fflib_Predicate(fflib_ComparisonOperator.NOT_EQUAL, field, value,fflibQueryFactory);
		predicates.add(expression);
		return expression;

	}

	public fflib_Expression lessThan(Schema.SObjectField field, Object value){
		fflib_Predicate expression= new fflib_Predicate(fflib_ComparisonOperator.LESS_THAN, field, value,fflibQueryFactory);
		predicates.add(expression);
		return expression;

	}

	public fflib_Expression lessThanOrEqualsTo(Schema.SObjectField field, Object value){
		fflib_Predicate expression= new fflib_Predicate(fflib_ComparisonOperator.LESS_THAN_OR_EQUAL, field, value,fflibQueryFactory);
		predicates.add(expression);
		return expression;

	}
//	public fflib_Predicate isLike(Schema.SObjectField field, fflib_Expression y){
//		fflib_Predicate expression= new fflib_Predicate(fflib_ComparisonOperator.GREATER_THAN, field, value);
//		predicates.add(expression);
//		return expression;
//
//	}
//
//	public fflib_Predicate notLike(fflib_Expression y){
//		fflib_Predicate expression= new fflib_Predicate(fflib_ComparisonOperator.GREATER_THAN, field, value);
//		predicates.add(expression);
//		return expression;
//
//	}


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
}