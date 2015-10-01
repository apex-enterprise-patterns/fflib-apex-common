/**
 * This class ports the TestDataBuilder pattern (http://www.natpryce.com/articles/000714.html) invented by Nat Pryce (http://www.natpryce.com/)
 * to the world of Apex and Salesforce.com.
 *
 * While test data in unit tests should be as simple as possible and could even be mocked with frameworks like ApexMock,
 * complex enterprise software also needs integration tests.The TestDataBuilder pattern reduces complexity,
 * eliminates redundancy and improves readability while setting up complex test data structures for such tests.
 *
 * Learn how to replace your redundant, error-prone and test-specific helper classes with a set of small domain classes
 * and how to write super-readable test by checking the sample code in fflib-apex-common-samplecode/blob/master/fflib-sample-code/src/classes/InvoicingServiceTest.cls
 */
 public virtual class fflib_DomainObjectBuilder {

    public SObject record;

    private Map<Schema.SObjectField, fflib_DomainObjectBuilder> parentByRelationship = new Map<Schema.SObjectField, fflib_DomainObjectBuilder>();

    private static fflib_SObjectUnitOfWork uow = initUnitOfWork();
    private static Set<fflib_DomainObjectBuilder> objects = new Set<fflib_DomainObjectBuilder>();


    // CONSTRUCTORS

    /**
     * Constructs a standalone Domain object
     */
    public fflib_DomainObjectBuilder(SObjectType type) {
        this.record = type.newSObject(null, true);

        objects.add(this);
    }

    /**
     * Constructs a child/dependent Domain object
     */
    public fflib_DomainObjectBuilder(SObjectType type, Schema.SObjectField parentRelationship, fflib_DomainObjectBuilder parent) {
        this(type);

        setParent(parentRelationship, parent);
    }

    /**
     * Constructs a linker Domain object
     */
    public fflib_DomainObjectBuilder(SObjectType type,
                        Schema.SObjectField leftRelationship, fflib_DomainObjectBuilder left,
                        Schema.SObjectField rightRelationship, fflib_DomainObjectBuilder right) {
        this(type);

        setParent(leftRelationship, left);
        setParent(rightRelationship, right);
    }


    // PUBLIC METHODS

    /**
     * Build method as defined by the TestDataBuilder pattern. Call this method on
     * any of the Domain objects created in your test method and everything created
     * in memory will be inserted.
     * The later you call it the fewer DMLs your test does consume. As single call is enough
     * but you can also call it multiple times to simulate multiple DML operations in your tests.
     */
    public SObject build() {
        for(fflib_DomainObjectBuilder obj: objects) {
            uow.registerNew(obj.record);

            for(Schema.SObjectField rel: obj.parentByRelationship.keySet()) {
                fflib_DomainObjectBuilder parent = obj.parentByRelationship.get(rel);
                uow.registerRelationship(obj.record, rel, parent.record);
            }
        }

        uow.commitWork();

        uow = initUnitOfWork();
        objects.clear();

        return record;
    }


    // PROTECTED METHODS

    protected fflib_DomainObjectBuilder setParent(Schema.SObjectField parentRelationship, fflib_DomainObjectBuilder parent) {

        // Note: The parent registered last always wins!
        fflib_DomainObjectBuilder oldParent = parentByRelationship.get(parentRelationship);

        if(oldParent != null) {
            oldParent.clearTree();
        }

        parentByRelationship.put(parentRelationship, parent);

        // Note: Return parent instead of this as we call this always from the parent
        return parent;
    }


    protected fflib_DomainObjectBuilder set(String fieldName, Object value) {
        record.put(fieldName, value);
        return this;
    }


    protected fflib_DomainObjectBuilder set(Schema.SObjectField field, Object value) {
        record.put(field, value);
        return this;
    }


    // PRIVATE METHODS

    private void clearTree() {
        for(fflib_DomainObjectBuilder obj : parentByRelationship.values()) {
            obj.clearTree();
        }

        objects.remove(this);
    }


    private static fflib_SObjectUnitOfWork initUnitOfWork() {
        return new fflib_SObjectUnitOfWork(new List<SObjectType> {
                                                    Opportunity.SObjectType,
                                                    Product2.SObjectType,
                                                    PriceBookEntry.SObjectType,
                                                    OpportunityLineItem.SObjectType });
    }
}
