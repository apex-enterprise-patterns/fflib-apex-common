/**
 * Copyright (c), FinancialForce.com, inc
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
 * Class providing common database query support for abstracting and encapsulating query logic
 **/
public abstract with sharing class fflib_SObjectSelector
	implements fflib_ISObjectSelector
{
    /**
     * Indicates whether the sObject has the currency ISO code field for organisations which have multi-currency
     * enabled. 
     **/
    private Boolean CURRENCY_ISO_CODE_ENABLED {
        get {
            if(CURRENCY_ISO_CODE_ENABLED == null){
                CURRENCY_ISO_CODE_ENABLED = describeWrapper.getFieldsMap().keySet().contains('currencyisocode');
            }
            return CURRENCY_ISO_CODE_ENABLED;
        }
		set;
    }
     
    /**
     * Should this selector automatically include the FieldSet fields when building queries?
     **/
    private Boolean m_includeFieldSetFields;
    
    /**
     * Enforce FLS Security
     **/
   	private Boolean m_enforceFLS;

    /**
     * Enforce CRUD Security
     **/
   	private Boolean m_enforceCRUD;
   	
   /**
    * Order by field
    **/
    	private String m_orderBy;

    /**
     * Sort the query fields in the select statement (defaults to true, at the expense of performance).
     * Switch this off if you need more performant queries.
     **/
    private Boolean m_sortSelectFields;
  
   /**
   * Describe helper
   **/
   	private fflib_SObjectDescribe describeWrapper {
   		get {
   			if(describeWrapper == null)
   				describeWrapper = fflib_SObjectDescribe.getDescribe(getSObjectType());
   			return describeWrapper;
   		}
   		set;
   	}
   	 
    /**
     * Implement this method to inform the base class of the SObject (custom or standard) to be queried
     **/
    abstract Schema.SObjectType getSObjectType();
    
    /**
     * Implement this method to inform the base class of the common fields to be queried or listed by the base class methods
     **/
    abstract List<Schema.SObjectField> getSObjectFieldList();

    /**
     * Constructs the Selector, defaults to not including any FieldSet fields automatically
     **/
    public fflib_SObjectSelector()
    {
        this(false);
    }
    
    /**
     * Constructs the Selector
     *
     * @param includeFieldSetFields Set to true if the Selector queries are to include Fieldset fields as well 
     **/
    public fflib_SObjectSelector(Boolean includeFieldSetFields)
    {
        this(includeFieldSetFields, true, false);
    }
    
    /**
     * Constructs the Selector
     *
     * @param includeFieldSetFields Set to true if the Selector queries are to include Fieldset fields as well 
     **/
    public fflib_SObjectSelector(Boolean includeFieldSetFields, Boolean enforceCRUD, Boolean enforceFLS)
    {
        this(includeFieldSetFields, enforceCRUD, enforceFLS, true);
    }

    /**
     * Constructs the Selector
     *
     * @param includeFieldSetFields Set to true if the Selector queries are to include Fieldset fields as well 
     * @param enforceCRUD Enforce CRUD security
     * @param enforeFLS Enforce Field Level Security
     * @param sortSelectFields Set to false if selecting many columns to skip sorting select fields and improve performance
     **/
    public fflib_SObjectSelector(Boolean includeFieldSetFields, Boolean enforceCRUD, Boolean enforceFLS, Boolean sortSelectFields)
    {
        m_includeFieldSetFields = includeFieldSetFields;
        m_enforceCRUD = enforceCRUD;
        m_enforceFLS = enforceFLS;
        m_sortSelectFields = sortSelectFields;
    }

    /**
     * Override this method to provide a list of Fieldsets that can optionally drive inclusion of additional fields in the base queries
     **/
    public virtual List<Schema.FieldSet> getSObjectFieldSetList()
    {
        return null;
    }
    
    /**
     * Override this method to control the default ordering of records returned by the base queries, 
     * defaults to the name field of the object or CreatedDate if there is none
     **/
    public virtual String getOrderBy()
    {
        if(m_orderBy == null) {
   		m_orderBy = 'CreatedDate';
   		if(describeWrapper.getNameField() != null) {
	    		m_orderBy = describeWrapper.getNameField().getDescribe().getName();
	    	}
	}
   	return m_orderBy;
    }

    /** 
     * Returns True if this Selector instance has been instructed by the caller to include Field Set fields
     **/
    public Boolean isIncludeFieldSetFields() 
    {
        return m_includeFieldSetFields;
    }
    
    /**
     * Returns True if this Selector is enforcing FLS
     **/
    public Boolean isEnforcingFLS()
    {
    	return m_enforceFLS;
    }
    
    /**
     * Returns True if this Selector is enforcing CRUD Security
     **/
    public Boolean isEnforcingCRUD()
    {
    	return m_enforceCRUD;
    }

    /**
     * Provides access to the builder containing the list of fields base queries are using, this is demand
     *   created if one has not already been defined via setFieldListBuilder
     *
     * @depricated See newQueryFactory
     **/
    public fflib_StringBuilder.CommaDelimitedListBuilder getFieldListBuilder()
    {
        return 
            new fflib_StringBuilder.CommaDelimitedListBuilder(
                new List<String>(newQueryFactory().getSelectedFields()));
    }

    /**
     * Use this method to override the default FieldListBuilder (created on demand via getFieldListBuilder) with a custom one, 
     *   warning, this will bypass anything getSObjectFieldList or getSObjectFieldSetList returns
     *
     * @depricated See newQueryFactory
     **/    
    public void setFieldListBuilder(fflib_StringBuilder.FieldListBuilder fieldListBuilder)
    {
        // TODO: Consider if given the known use cases for this (dynamic selector optomisation) if it's OK to leave this as a null operation 
    }

    /**
     * Returns in string form a comma delimted list of fields as defined via getSObjectFieldList and optionally getSObjectFieldSetList
     *
     * @depricated See newQueryFactory
     **/    
    public String getFieldListString()
    {
        return getFieldListBuilder().getStringValue();
    }
    
    /**
     * Returns in string form a comma delimted list of fields as defined via getSObjectFieldList and optionally getSObjectFieldSetList
     * @param relation Will prefix fields with the given relation, e.g. MyLookupField__r
     *
     * @depricated See newQueryFactory
     **/    
    public String getRelatedFieldListString(String relation)
    {
        return getFieldListBuilder().getStringValue(relation + '.');
    }

    /**
     * Returns the string representaiton of the SObject this selector represents
     **/
    public String getSObjectName()
    {
        return describeWrapper.getDescribe().getName();
    }
    
    /**
     * Performs a SOQL query, 
     *   - Selecting the fields described via getSObjectFieldsList and getSObjectFieldSetList (if included) 
     *   - From the SObject described by getSObjectType
     *   - Where the Id's match those provided in the set
     *   - Ordered by the fields returned via getOrderBy
     * @returns A list of SObject's
     **/
    public List<SObject> selectSObjectsById(Set<Id> idSet)
    {
        return Database.query(buildQuerySObjectById());
    }
        
    /**
     * Performs a SOQL query, 
     *   - Selecting the fields described via getSObjectFieldsList and getSObjectFieldSetList (if included) 
     *   - From the SObject described by getSObjectType
     *   - Where the Id's match those provided in the set
     *   - Ordered by the fields returned via getOrderBy
     * @returns A QueryLocator (typically for use in a Batch Apex job)
     **/
    public Database.QueryLocator queryLocatorById(Set<Id> idSet)
    {
        return Database.getQueryLocator(buildQuerySObjectById());
    }
    
    /**
     * Throws an exception if the SObject indicated by getSObjectType is not accessible to the current user (read access)
     *
     * @depricated If you utilise the newQueryFactory method this is automatically done for you (unless disabled by the selector) 
     **/
    public void assertIsAccessible()
    {
        if(!getSObjectType().getDescribe().isAccessible())
           throw new fflib_SObjectDomain.DomainException(
                'Permission to access an ' + getSObjectType().getDescribe().getName() + ' denied.');       
    }

    /**
     * Public acccess for the getSObjectType during Mock registration 
     *   (adding public to the existing method broken base class API backwards compatability)
     **/
    public SObjectType getSObjectType2()
    {
        return getSObjectType();
    }

    /**
     * Public acccess for the getSObjectType during Mock registration 
     *   (adding public to the existing method broken base class API backwards compatability)
     **/
    public SObjectType sObjectType()
    {
        return getSObjectType();
    }
    
    /**
     * Returns a QueryFactory configured with the Selectors object, fields, fieldsets and default order by
     **/
    public fflib_QueryFactory newQueryFactory()
    {    
        return newQueryFactory(m_enforceCRUD, m_enforceFLS, true);
    }
    
    /**
     * Returns a QueryFactory configured with the Selectors object, fields, fieldsets and default order by
     **/
    public fflib_QueryFactory newQueryFactory(Boolean includeSelectorFields)
    {    
        return newQueryFactory(m_enforceCRUD, m_enforceFLS, includeSelectorFields);
    }

    /**
     * Returns a QueryFactory configured with the Selectors object, fields, fieldsets and default order by
     * CRUD and FLS read security will be checked if the corresponding inputs are true (overrides that defined in the selector).
     **/
    public fflib_QueryFactory newQueryFactory(Boolean assertCRUD, Boolean enforceFLS, Boolean includeSelectorFields)
    {
    	// Construct QueryFactory around the given SObject
        return configureQueryFactory(
        	new fflib_QueryFactory(getSObjectType2()), 
        		assertCRUD, enforceFLS, includeSelectorFields);
    }

	/**
	 * Adds the selectors fields to the given QueryFactory using the given relationship path as a prefix
	 *
	 * // TODO: This should be consistant (ideally) with configureQueryFactory below
	 **/
	public void configureQueryFactoryFields(fflib_QueryFactory queryFactory, String relationshipFieldPath)
	{
		// Add fields from selector prefixing the relationship path		
		for(SObjectField field : getSObjectFieldList())		
        	queryFactory.selectField(relationshipFieldPath + '.' + field.getDescribe().getName());
        // Automatically select the CurrencyIsoCode for MC orgs (unless the object is a known exception to the rule)
        if(Userinfo.isMultiCurrencyOrganization() && CURRENCY_ISO_CODE_ENABLED)
            queryFactory.selectField(relationshipFieldPath+'.CurrencyIsoCode');		
	}
    
    /**
     * Adds a subselect QueryFactory based on this selector to the given QueryFactor, returns the parentQueryFactory
     **/
    public fflib_QueryFactory addQueryFactorySubselect(fflib_QueryFactory parentQueryFactory)
    {    
    	return addQueryFactorySubselect(parentQueryFactory, true);
    }
        
    /**
     * Adds a subselect QueryFactory based on this selector to the given QueryFactor
     **/
    public fflib_QueryFactory addQueryFactorySubselect(fflib_QueryFactory parentQueryFactory, Boolean includeSelectorFields)
    {    	
    	fflib_QueryFactory subSelectQueryFactory = 
    		parentQueryFactory.subselectQuery(getSObjectType2());
    	return configureQueryFactory(
    		subSelectQueryFactory, 
    		m_enforceCRUD, 
    		m_enforceFLS, 
    		includeSelectorFields);
    }
        
	/**
	 * Adds a subselect QueryFactory based on this selector to the given QueryFactor, returns the parentQueryFactory
	 **/
	public fflib_QueryFactory addQueryFactorySubselect(fflib_QueryFactory parentQueryFactory, String relationshipName)
	{
		return addQueryFactorySubselect(parentQueryFactory, relationshipName, TRUE);
	}

	/**
	 * Adds a subselect QueryFactory based on this selector to the given QueryFactor
	 **/
	public fflib_QueryFactory addQueryFactorySubselect(fflib_QueryFactory parentQueryFactory, String relationshipName, Boolean includeSelectorFields)
	{
		fflib_QueryFactory subSelectQueryFactory = parentQueryFactory.subselectQuery(relationshipName);
		return configureQueryFactory(subSelectQueryFactory, m_enforceCRUD, m_enforceFLS, includeSelectorFields);
	}

    /**
     * Constructs the default SOQL query for this selector, see selectSObjectsById and queryLocatorById
     **/    
    private String buildQuerySObjectById()
    {   
        return newQueryFactory().setCondition('id in :idSet').toSOQL();
    }
    	
	/**
	 * Configures a QueryFactory instance according to the configuration of this selector
	 **/        
    private fflib_QueryFactory configureQueryFactory(fflib_QueryFactory queryFactory, Boolean assertCRUD, Boolean enforceFLS, Boolean includeSelectorFields)
    {
        // CRUD and FLS security required?
        if (assertCRUD)
        {
        	try { 
        		// Leverage QueryFactory for CRUD checking 
        		queryFactory.assertIsAccessible();
        	} catch (fflib_SecurityUtils.CrudException e) {
        		// Marshal exception into DomainException for backwards compatability
				throw new fflib_SObjectDomain.DomainException(
	                'Permission to access an ' + getSObjectType().getDescribe().getName() + ' denied.');               		
        	}
        }
        queryFactory.setEnforceFLS(enforceFLS);
                
        // Configure the QueryFactory with the Selector fields?        
        if(includeSelectorFields)
        {
	        // select the Selector fields and Fieldsets and set order
            queryFactory.selectFields(getSObjectFieldList());

	        List<Schema.FieldSet> fieldSetList = getSObjectFieldSetList();
	        if(m_includeFieldSetFields && fieldSetList != null)
	            for(Schema.FieldSet fieldSet : fieldSetList)
	                queryFactory.selectFieldSet(fieldSet);
	
	        // Automatically select the CurrencyIsoCode for MC orgs (unless the object is a known exception to the rule)
	        if(Userinfo.isMultiCurrencyOrganization() && CURRENCY_ISO_CODE_ENABLED)
	            queryFactory.selectField('CurrencyIsoCode');
        }
        
        // Parse the getOrderBy()
        for(String orderBy : getOrderBy().split(','))
        {
            List<String> orderByParts = orderBy.trim().split(' ');
            String fieldNamePart = orderByParts[0];
            String fieldSortOrderPart = orderByParts.size() > 1 ? orderByParts[1] : null;
            fflib_QueryFactory.SortOrder fieldSortOrder = fflib_QueryFactory.SortOrder.ASCENDING;
            if(fieldSortOrderPart==null)
                fieldSortOrder = fflib_QueryFactory.SortOrder.ASCENDING;
            else if(fieldSortOrderPart.equalsIgnoreCase('DESC'))
                fieldSortOrder = fflib_QueryFactory.SortOrder.DESCENDING;
            else if(fieldSortOrderPart.equalsIgnoreCase('ASC'))
                fieldSortOrder = fflib_QueryFactory.SortOrder.ASCENDING;
            queryFactory.addOrdering(fieldNamePart, fieldSortOrder, orderBy.containsIgnoreCase('NULLS LAST'));
        }           
        
        queryFactory.setSortSelectFields(m_sortSelectFields);           

        return queryFactory;    
    }    
}