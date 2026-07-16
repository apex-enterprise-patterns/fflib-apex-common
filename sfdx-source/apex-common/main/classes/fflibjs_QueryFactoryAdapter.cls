/**
 * Adapter that extends fflib_QueryFactory with strategy pattern support.
 * Allows consumers to customize field resolution and SOQL building without forking fflib_QueryFactory.
 *
 * USAGE EXAMPLES:
 *
 * // Using default implementations (preserves existing behavior):
 * fflibjs_QueryFactoryAdapter qf = new fflibjs_QueryFactoryAdapter(Account.SObjectType);
 * qf.selectField('Name').setCondition('Active = true');
 * String soql = qf.toSOQL();
 *
 * // With custom field path resolver:
 * fflibjs_QueryFactoryAdapter qf = new fflibjs_QueryFactoryAdapter(Account.SObjectType)
 *     .setFieldPathResolver(new CustomFieldPathResolver());
 *
 * // With custom SOQL builder:
 * fflibjs_QueryFactoryAdapter qf = new fflibjs_QueryFactoryAdapter(Account.SObjectType)
 *     .setSOQLBuilder(new CustomSOQLBuilder());
 *
 * // With both custom strategies:
 * fflibjs_QueryFactoryAdapter qf = new fflibjs_QueryFactoryAdapter(Account.SObjectType)
 *     .setFieldPathResolver(new CustomFieldPathResolver())
 *     .setSOQLBuilder(new CustomSOQLBuilder());
 **/
public class fflibjs_QueryFactoryAdapter {
    private fflib_QueryFactory queryFactory;
    private fflibjs_IFieldPathResolver fieldPathResolver;
    private fflibjs_ISOQLBuilder soqlBuilder;

    /**
     * Creates an adapter for the given SObject type.
     * Initializes with default implementations of field path resolution and SOQL building.
     **/
    public fflibjs_QueryFactoryAdapter(Schema.SObjectType table) {
        this.queryFactory = new fflib_QueryFactory(table);
        this.fieldPathResolver = new fflibjs_DefaultFieldPathResolver(queryFactory);
        this.soqlBuilder = new fflibjs_DefaultSOQLBuilder(queryFactory);
    }

    /**
     * Creates an adapter wrapping an existing fflib_QueryFactory instance.
     **/
    public fflibjs_QueryFactoryAdapter(fflib_QueryFactory qf) {
        this.queryFactory = qf;
        this.fieldPathResolver = new fflibjs_DefaultFieldPathResolver(queryFactory);
        this.soqlBuilder = new fflibjs_DefaultSOQLBuilder(queryFactory);
    }

    /**
     * Sets a custom field path resolver.
     * @param resolver Implementation of fflibjs_IFieldPathResolver
     * @return this for method chaining
     **/
    public fflibjs_QueryFactoryAdapter setFieldPathResolver(fflibjs_IFieldPathResolver resolver) {
        this.fieldPathResolver = resolver;
        return this;
    }

    /**
     * Sets a custom SOQL builder.
     * @param builder Implementation of fflibjs_ISOQLBuilder
     * @return this for method chaining
     **/
    public fflibjs_QueryFactoryAdapter setSOQLBuilder(fflibjs_ISOQLBuilder builder) {
        this.soqlBuilder = builder;
        return this;
    }

    /**
     * Gets the underlying fflib_QueryFactory instance for direct access if needed.
     **/
    public fflib_QueryFactory getQueryFactory() {
        return queryFactory;
    }

    /**
     * Generates the SOQL query using the configured builder.
     * @return Complete SOQL query string ready for execution
     **/
    public String toSOQL() {
        return soqlBuilder.build();
    }

    // ============================================
    // Delegated methods to queryFactory
    // ============================================

    public fflibjs_QueryFactoryAdapter selectField(String fieldName) {
        queryFactory.selectField(fieldName);
        return this;
    }

    public fflibjs_QueryFactoryAdapter selectField(String fieldName, Schema.sObjectType relatedObjectType) {
        queryFactory.selectField(fieldName, relatedObjectType);
        return this;
    }

    public fflibjs_QueryFactoryAdapter selectField(Schema.SObjectField field) {
        queryFactory.selectField(field);
        return this;
    }

    public fflibjs_QueryFactoryAdapter selectFields(Set<String> fieldNames) {
        queryFactory.selectFields(fieldNames);
        return this;
    }

    public fflibjs_QueryFactoryAdapter selectFields(List<String> fieldNames) {
        queryFactory.selectFields(fieldNames);
        return this;
    }

    public fflibjs_QueryFactoryAdapter selectFields(Set<Schema.SObjectField> fields) {
        queryFactory.selectFields(fields);
        return this;
    }

    public fflibjs_QueryFactoryAdapter selectFields(List<Schema.SObjectField> fields) {
        queryFactory.selectFields(fields);
        return this;
    }

    public fflibjs_QueryFactoryAdapter selectFieldSet(Schema.FieldSet fieldSet) {
        queryFactory.selectFieldSet(fieldSet);
        return this;
    }

    public fflibjs_QueryFactoryAdapter selectFieldSet(Schema.FieldSet fieldSet, Boolean allowCrossObject) {
        queryFactory.selectFieldSet(fieldSet, allowCrossObject);
        return this;
    }

    public fflibjs_QueryFactoryAdapter setCondition(String conditionExpression) {
        queryFactory.setCondition(conditionExpression);
        return this;
    }

    public String getCondition() {
        return queryFactory.getCondition();
    }

    public fflibjs_QueryFactoryAdapter setLimit(Integer limitCount) {
        queryFactory.setLimit(limitCount);
        return this;
    }

    public Integer getLimit() {
        return queryFactory.getLimit();
    }

    public fflibjs_QueryFactoryAdapter setOffset(Integer offsetCount) {
        queryFactory.setOffset(offsetCount);
        return this;
    }

    public Integer getOffset() {
        return queryFactory.getOffset();
    }

    public fflibjs_QueryFactoryAdapter addOrdering(fflib_QueryFactory.Ordering o) {
        queryFactory.addOrdering(o);
        return this;
    }

    public fflibjs_QueryFactoryAdapter setOrdering(fflib_QueryFactory.Ordering o) {
        queryFactory.setOrdering(o);
        return this;
    }

    public List<fflib_QueryFactory.Ordering> getOrderings() {
        return queryFactory.getOrderings();
    }

    public Set<String> getSelectedFields() {
        return queryFactory.getSelectedFields();
    }

    public fflibjs_QueryFactoryAdapter addOrdering(String fieldName, fflib_QueryFactory.SortOrder direction, Boolean nullsLast) {
        queryFactory.addOrdering(fieldName, direction, nullsLast);
        return this;
    }

    public fflibjs_QueryFactoryAdapter addOrdering(Schema.SObjectField field, fflib_QueryFactory.SortOrder direction, Boolean nullsLast) {
        queryFactory.addOrdering(field, direction, nullsLast);
        return this;
    }

    public fflibjs_QueryFactoryAdapter addOrdering(String fieldName, fflib_QueryFactory.SortOrder direction) {
        queryFactory.addOrdering(fieldName, direction);
        return this;
    }

    public fflibjs_QueryFactoryAdapter addOrdering(Schema.SObjectField field, fflib_QueryFactory.SortOrder direction) {
        queryFactory.addOrdering(field, direction);
        return this;
    }

    public fflibjs_QueryFactoryAdapter setOrdering(String fieldName, fflib_QueryFactory.SortOrder direction, Boolean nullsLast) {
        queryFactory.setOrdering(fieldName, direction, nullsLast);
        return this;
    }

    public fflibjs_QueryFactoryAdapter setOrdering(Schema.SObjectField field, fflib_QueryFactory.SortOrder direction, Boolean nullsLast) {
        queryFactory.setOrdering(field, direction, nullsLast);
        return this;
    }

    public fflibjs_QueryFactoryAdapter setOrdering(String fieldName, fflib_QueryFactory.SortOrder direction) {
        queryFactory.setOrdering(fieldName, direction);
        return this;
    }

    public fflibjs_QueryFactoryAdapter setOrdering(Schema.SObjectField field, fflib_QueryFactory.SortOrder direction) {
        queryFactory.setOrdering(field, direction);
        return this;
    }

    public fflibjs_QueryFactoryAdapter setAllRows() {
        queryFactory.setAllRows();
        return this;
    }

    public fflibjs_QueryFactoryAdapter setSortSelectFields(Boolean doSort) {
        queryFactory.setSortSelectFields(doSort);
        return this;
    }

    public fflibjs_QueryFactoryAdapter setEnforceFLS(Boolean enforce) {
        queryFactory.setEnforceFLS(enforce);
        return this;
    }

    public fflibjs_QueryFactoryAdapter setEnforceFLS(fflib_QueryFactory.FLSEnforcement enforcement) {
        queryFactory.setEnforceFLS(enforcement);
        return this;
    }

    public fflibjs_QueryFactoryAdapter assertIsAccessible() {
        queryFactory.assertIsAccessible();
        return this;
    }

    public fflib_QueryFactory subselectQuery(String relationshipName) {
        return queryFactory.subselectQuery(relationshipName);
    }

    public fflib_QueryFactory subselectQuery(String relationshipName, Boolean assertIsAccessible) {
        return queryFactory.subselectQuery(relationshipName, assertIsAccessible);
    }

    public fflib_QueryFactory subselectQuery(Schema.ChildRelationship relationship) {
        return queryFactory.subselectQuery(relationship);
    }

    public fflib_QueryFactory subselectQuery(Schema.ChildRelationship relationship, Boolean assertIsAccessible) {
        return queryFactory.subselectQuery(relationship, assertIsAccessible);
    }

    public List<fflib_QueryFactory> getSubselectQueries() {
        return queryFactory.getSubselectQueries();
    }

    public Schema.SObjectType getTable() {
        return queryFactory.table;
    }
}
