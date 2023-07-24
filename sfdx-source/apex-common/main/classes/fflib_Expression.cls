public interface fflib_Expression{

	//String toSoql();

	void add(fflib_Expression predicate);

	//TODO: Validate if data is accepted by fieldType and operation Type
	void accept(fflib_Expression fflibPredicate);

	void appendSOQLString(fflib_StringBuilder sb);

}