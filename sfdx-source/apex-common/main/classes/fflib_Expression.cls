public interface fflib_Expression{

	//String toSoql();

	void add(fflib_Expression predicate);


	void accept(fflib_Predicate fflibPredicate);

	void appendSOQLString(fflib_StringBuilder sb);

}