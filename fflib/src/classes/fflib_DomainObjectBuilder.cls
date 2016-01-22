/**
 * Copyright (c) 2014, FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

/**
 * Base class aiding in the implementation of Test Data Builder pattern as described by Nate Pryce
 * (http://www.natpryce.com/).  Derived classes can combine the features the Builder 
 * Pattern (http://www.c2.com/cgi/wiki?BuilderPattern) with an Object Mother pattern 
 * (http://www.c2.com/cgi/wiki?ObjectMother) to simplify the setup/creation of data.
 * 
 * While test data in unit tests should be as simple as possible and could even be mocked with frameworks like ApexMock,
 * complex enterprise software also needs integration tests. The TestDataBuilder pattern reduces complexity,
 * eliminates redundancy and improves readability while setting up complex test data structures for both
 * unit and integration tests and can also be used for production purposes.
 *
 * Learn how to replace your redundant, error-prone and test-specific helper classes with a set of small domain classes
 * and how to write more readable tests by checking the samples in the test class fflib_DomainObjectBuilderTest
 */
public abstract class fflib_DomainObjectBuilder 
{
	/**
	 * @description Maintains non-relationship field values that have been assigned to an instance of this class
	 **/
    protected Map<Schema.SObjectField, Object> m_fieldValueMap = new Map<Schema.SObjectField, Object>();

	/**
	 * @description Maintains relationship field values that have been assigned to an instance of this class
	 *              Relationship field values are references to builder instances
	 **/    
    protected Map<Schema.SObjectField, fflib_DomainObjectBuilder> m_parentByRelationship = new Map<Schema.SObjectField, fflib_DomainObjectBuilder>();

    /**
     * @description The SObjectType this Builder class represents
     **/    
    protected Schema.SObjectType m_sObjType;

    /**
     * @description The SObject this Builder class is building
     **/    
    protected SObject m_sObjRecord { get; protected set; }

    /**
     * @description Tracks all builders that have registered to be persisted to a UnitOfWork
     **/    
    private static Set<fflib_DomainObjectBuilder> m_registeredBuilders = new Set<fflib_DomainObjectBuilder>();

	/**
	 * @description Constructs the Builder class with the specified SObjectType
	 *
	 * @param type The SObject type that the builder will build
	 **/
    protected fflib_DomainObjectBuilder(SObjectType type) {
        this.m_sObjType = type;
        // passing false because of bug in SFDC - See https://success.salesforce.com/issues_view?id=a1p30000000Sz5RAAS
        // not establishing defaults also gives us an opportunity for a completely "clean" record        
        this.m_sObjRecord = m_sObjType.newSObject(null, false);
        this.IsBuilt = false;
        this.IsRegistered = false;
    }

	/**
	 * @description Copy Constructor that constructs the Builder class based on the builder specified
	 *
	 * @param copyFrom The builder to copy/clone this instance from
	 **/
    protected fflib_DomainObjectBuilder(fflib_DomainObjectBuilder copyFrom)
    {
    	this(copyFrom.getSObjectType());
    	m_fieldValueMap = copyFrom.m_fieldValueMap.clone();
    	m_parentByRelationship = copyFrom.m_parentByRelationship.clone();
    }

    /**
     * @description Commits all registered builders and their related builders to the Unit Of Work specified
     *
     * @param uow The Unit Of Work to process against
     **/    
    public static void persistRegistered(fflib_ISObjectUnitOfWork uow) {
    	persist(uow, m_registeredBuilders);
    }

    /**
     * @description Returns true if builder has been built, false otherwise
     *              A builder IsBuilt build or persist operations have completed successfully on it
     **/
    public Boolean IsBuilt { get; protected set; }

    /**
     * @description Returns true if builder has been registered, false otherwise
     *              A builder IsRegistered if registerBuilder has been called on it and the
     *              builder has not yet been built/persisted
     **/    
    public Boolean IsRegistered { get; protected set; }

    /**
     * @description Returns the SObject associated to this builder
     **/    
    public SObject getRecord() {
        return m_sObjRecord;
    }

    /**
     * @description Returns the SObjectType associated to this builder
     **/    
    public virtual Schema.SObjectType getSObjectType() {
        return m_sObjType;
    }    

    /**
     * @description Returns the SObject after building the builder and any of its related builders
     *
     * @param isNew True if the instance should not have an Id value (new record), false otherwise (existing record)
     *
     * @remarks Recommended to wrap this method with a 'build()' and 'buildNew()' in a derived class
     *          casting to the derived type to support fluent configuration
     **/  
    public virtual SObject build(Boolean isNew)
    {
    	// see if we'll let 'em through
        checkAllowBuild();

        // fire event
        beforeBuild(isNew);

        // set non-relationship field values
        for (Schema.SObjectField field : this.m_fieldValueMap.keySet()) {
            m_sObjRecord.put(field, this.m_fieldValueMap.get(field));
        }        

        // set relationship field values        
        for(Schema.SObjectField rel: this.m_parentByRelationship.keySet()) {
        	// get the related builder
            fflib_DomainObjectBuilder parent = this.m_parentByRelationship.get(rel);

            // if not built yet, we must, we must
	        if (!parent.IsBuilt) {
	        	// should not be building a builder that is registered
	        	if (parent.IsRegistered) {
	    			throw new DomainObjectBuilderException(String.format('Field {0} contains value for a builder that is marked for registration', new List<String> { rel.getDescribe().getName() }));
				}

				// related object should always be trated as existing
				parent.build(false);
			// we must have an Id value for all relationship fields - if Id is Null builder 
			// was built using isNew = true or Id has been cleared manually
			} else if (null == parent.m_sObjRecord.Id) {
				throw new DomainObjectBuilderException(String.format('Field {0} contains value for a builder that was built as new', new List<String> { rel.getDescribe().getName() }));
			}

			// set field value with related SObject Id
			m_sObjRecord.put(rel, parent.m_sObjRecord.Id);
        }        

        // establish Id value
        m_sObjRecord.Id = isNew ? null : fflib_IDGenerator.generate(getSObjectType());

        // update state of builder
        markAsBuilt();

        // fire event
        afterBuild(m_sObjRecord);

        // let 'em have it
        return m_sObjRecord;
    }

    /**
     * @description Commits this builder and its related builders to the Unit Of Work specified
     *
     * @param uow The Unit Of Work to process against
     *
     * @remarks Recommended to wrap this method with a 'persist' method in a derived class
     *          casting to the derived type to support fluent configuration
     **/ 
    public virtual SObject persistBuilder(fflib_ISObjectUnitOfWork uow)
    {
    	// persist this builder
    	persist(uow, new Set<fflib_DomainObjectBuilder> { this });

        // let 'em have it
        return m_sObjRecord;    	
    }

    /**
     * @description Registers builder to be processed by persistRegistered
     *
     * Returns itself to support fluent configuration
     *
     * @remarks Recommended to wrap this method with a 'register()' method in a derived class
     *          casting to the derived type to support fluent configuration
     **/ 
    protected virtual fflib_DomainObjectBuilder registerBuilder() {
    	// see if we'll let 'em through
    	checkAllowRegister();

        // add to registered list
       	m_registeredBuilders.add(this);

        // mark as registered
        markAsRegistered();

        // return the builder itself
        return this;
    }

    /**
     * @description Validates that builder is not registered
     *
     * @throws DomainObjectBuilderException if builder is already registered
     **/        
    protected virtual void checkIsRegistered() {
        if (IsRegistered) {
            throw new DomainObjectBuilderException('Builder has already been registered');
        }
    }

    /**
     * @description Validates that builder is not built
     *
     * @throws DomainObjectBuilderException if builder is already built
     **/ 
    protected virtual void checkIsBuilt() {
        if (IsBuilt) {
            throw new DomainObjectBuilderException('Builder has already been built');
        }
    }

    /**
     * @description Validates that builder can be built
     *
     * @throws DomainObjectBuilderException if builder is registered or is already built
     **/ 
    protected virtual void checkAllowBuild()
    {
        // should not allow build if builder is registered
        checkIsRegistered();

        // should not allow build if already built
        checkIsBuilt();     	
    }

    /**
     * @description Validates that builder can be registered
     *
     * @throws DomainObjectBuilderException if builder is registered or is already built
     **/ 
    protected virtual void checkAllowRegister()
    {
        // should not register a builder that has already been registered
        checkIsRegistered();

        // should not register a builder that has been built
        checkIsBuilt();    	
    }

    /**
     * @description Validates that builder can be changed
     *
     * @throws DomainObjectBuilderException if builder is built
     **/ 
    protected virtual void checkAllowSet()
    {
        // should not change data on builder after its built
        checkIsBuilt();    	    	
    }

    /**
     * @description This method allows subclasses to invoke any action before the SObject is built.
     *
     * @param isNew True if building as new, false otherwise (existing)
     **/ 
    protected virtual void beforeBuild(Boolean isNew) {}

    /**
     * @description This method allows subclasses to handle the SObject after it is built.
     *
     * @param sObj The SObject that has been built.
     */
    protected virtual void afterBuild(SObject sObj) {}

    /**
     * @description This method allows subclasses to handle the SObject before it is inserted
     *
     * @param sObj The SObject that has been built.
     */
    protected virtual void beforeInsert(SObject sObj) {}

    /**
     * @description This method allows subclasses to handle the SObject after it is inserted.
     *
     * @param sObj The SObject that has been built.
     */
    protected virtual void afterInsert(SObject sObj) {}

    /**
     * @description Updates the builder state to indicate it has been built
     */
    protected virtual void markAsBuilt()
    {
        // mark as built
        IsBuilt = true;
        // clear registered flag (might or might not have been registered depending on which 'build/persist' process was used
        IsRegistered = false;
    }

    /**
     * @description Updates the builder state to indicate it has been registered
     */
    protected virtual void markAsRegistered()
    {
    	// mark as registered
        IsRegistered = true;    	
    }

    /**
     * @description Update the builder field with the value specified
     *
     * @param field The SObjectField to set the value on
     * @param value The value for the SObjectField
     */
    protected virtual fflib_DomainObjectBuilder set(Schema.SObjectField field, Object value) {
    	// should not allow changing data after built
    	checkAllowSet();

    	// set field value
        m_fieldValueMap.put(field, value);

        // right back at ya
        return this;
    }

    /**
     * @description Updates the builder field with the value specified
     *
     * @param parentRelationship The SObjectField to set the value on
     * @param parent The builder instance for the SObjectField
     */
    protected virtual fflib_DomainObjectBuilder setParent(Schema.SObjectField parentRelationship, fflib_DomainObjectBuilder parent) {
    	// should not allow changing data after built
    	checkAllowSet();

        // Note: The parent registered last always wins!
		m_parentByRelationship.put(parentRelationship, parent);

		// give and you shall receive
        return this;
    }

    /**
     * @description Commits the set of builders specified and their related builders to the Unit Of Work specified
     *
     * @param uow The Unit Of Work to process against
     * @param builders The builders to persist to the Unit Of Work
     **/
    private static void persist(fflib_ISObjectUnitOfWork uow, Set<fflib_DomainObjectBuilder> builders) {
    	// track what we've prepared
    	Set<fflib_DomainObjectBuilder> preparedBuilders = new Set<fflib_DomainObjectBuilder>();

        // iterate builders processing each one
        for (fflib_DomainObjectBuilder builder :builders) {
        	prepareForCommit(uow, builder, preparedBuilders);
        }

        // commit work
        uow.commitWork();

        // iterate all builders marking them built
        for (fflib_DomainObjectBuilder builder :preparedBuilders) {
        	// mark as built
        	builder.markAsBuilt();

        	// fire event
        	builder.afterInsert(builder.m_sObjRecord);
        }

        // reset builders Set
        builders.clear();       
    }    

    /**
     * @description Prepares a builder to be committed through a Unit Of Work
     *
     * @param uow The Unit Of Work to process against
     * @param builder The builder to prepare
     * @param preparedBuilders The builders that have already been prepared during the current operation
     **/
    private static Set<fflib_DomainObjectBuilder> prepareForCommit(fflib_ISObjectUnitOfWork uow, fflib_DomainObjectBuilder builder, Set<fflib_DomainObjectBuilder> preparedBuilders) {
    	// fire event
    	builder.beforeInsert(builder.m_sObjRecord);

        // set non-relationship field values
        for (Schema.SObjectField field : builder.m_fieldValueMap.keySet()) {
            builder.m_sObjRecord.put(field, builder.m_fieldValueMap.get(field));
        }        

        // set relationship field values        
        for(Schema.SObjectField rel: builder.m_parentByRelationship.keySet()) {
        	// get related builder
            fflib_DomainObjectBuilder parent = builder.m_parentByRelationship.get(rel);
        
            // if its not in the registered list, we must manually add it to be persisted
            if (!parent.IsRegistered) {
            	// cannot persist a builder that has been built
            	if (parent.IsBuilt) {
					throw new DomainObjectBuilderException(String.format('Field {0} contains value for a builder that has already been built', new List<String> { rel.getDescribe().getName() }));
            	}
            	if (!preparedBuilders.contains(parent)) {
            		prepareForCommit(uow, parent, preparedBuilders);
            	}
            }

        	uow.registerRelationship(builder.m_sObjRecord, rel, parent.m_sObjRecord);
        }

        // register as new
        uow.registerNew(builder.m_sObjRecord);

        // we've completed the preparation
        preparedBuilders.add(builder);

        return preparedBuilders;
    }

	/**
	 * General exception class for builders
	 **/
    public class DomainObjectBuilderException extends Exception {}
}