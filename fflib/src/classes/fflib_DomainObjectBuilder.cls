public virtual class fflib_DomainObjectBuilder {
    
    public SObject record;

    private Map<Schema.SObjectField, fflib_DomainObjectBuilder> parentByRelationship = new Map<Schema.SObjectField, fflib_DomainObjectBuilder>();
    
    private static fflib_SObjectUnitOfWork uow = initUnitOfWork();
    private static Set<fflib_DomainObjectBuilder> objects = new Set<fflib_DomainObjectBuilder>();
    
    
    // CONSTRUCTORS

    public fflib_DomainObjectBuilder(SObjectType type) {
        this.record = type.newSObject(null, true);
        
        objects.add(this);
    }
    
    
    public fflib_DomainObjectBuilder(SObjectType type, Schema.SObjectField parentRelationship, fflib_DomainObjectBuilder parent) {
        this(type);
        
        setParent(parentRelationship, parent);
    }
    
    
    public fflib_DomainObjectBuilder(SObjectType type,
                        Schema.SObjectField leftRelationship, fflib_DomainObjectBuilder left,
                        Schema.SObjectField rightRelationship, fflib_DomainObjectBuilder right) {
        this(type);
        
        setParent(leftRelationship, left);
        setParent(rightRelationship, right);
    }
    
    
    // PUBLIC METHODS
    
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