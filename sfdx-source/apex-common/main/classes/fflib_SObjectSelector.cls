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
    private Boolean m_includeFieldSetFields = false;
    
    /**
     * Enforce FLS Security
     **/
    private Boolean m_enforceFLS = false;

    /**
     * Enforce CRUD Security
     **/
    private Boolean m_enforceCRUD = true;
   	
    /**
     * Order by field
     **/
    private String m_orderBy;

    /**
     * Default Query Limit
     */
    private Integer m_limit;

    /**
     * Default Query Offset
     */
    private Integer m_offset;

    /**
     * Overwrites selector class level Ordering
     */
    private List<fflib_QueryFactory.Ordering> m_ordering;

    /**
     * Sort the query fields in the select statement (defaults to true, at the expense of performance).
     * Switch this off if you need more performant queries.
     **/
    private Boolean m_sortSelectFields = true;

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
     * static variables
     **/
    private static String DEFAULT_SORT_FIELD = 'CreatedDate';
    private static String SF_ID_FIELD = 'Id';

    /**
     * Implement this method to inform the base class of the SObject (custom or standard) to be queried
     **/
    abstract Schema.SObjectType getSObjectType();
    
    /**
     * Implement this method to inform the base class of the common fields to be queried or listed by the base class methods
     **/
    abstract List<Schema.SObjectField> getSObjectFieldList();

    /**
     * Constructs the Selector with the default settings
     **/
    public fflib_SObjectSelector() { }
    
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
     * @param enforceFLS Enforce Field Level Security
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
      * defaults to the name field of the object if it is not encrypted or CreatedDate if there the object has createdDated or Id
      **/
     public virtual String getOrderBy()
     {
        if (m_orderBy == null)
        {
            Schema.SObjectField nameField = describeWrapper.getNameField();
            if (nameField != null && !nameField.getDescribe().isEncrypted())
            {
                m_orderBy = nameField.getDescribe().getName();
            }
            else
            {
                m_orderBy = DEFAULT_SORT_FIELD;
                try {
                    if (describeWrapper.getField(m_orderBy) == null)
                    {
                        m_orderBy = SF_ID_FIELD;
                    }
                }
                catch(fflib_QueryFactory.InvalidFieldException ex) {
                    m_orderBy = SF_ID_FIELD;
                }
            }
        }
        return m_orderBy;
    }


    /**
     * @description Set the selector to enforce FLS Security
     **/
    public fflib_SObjectSelector enforceFLS()
    {
        m_enforceFLS = true;
        return this;
    }

    /**
     * @description Set the selector to automatically include the FieldSet fields when building queries
     **/
    public fflib_SObjectSelector includeFieldSetFields()
    {
        this.m_includeFieldSetFields = true;
        return this;
    }

    /**
     * @description Set the selector to ignore CRUD security
     * @return
     */
    public fflib_SObjectSelector ignoreCRUD()
    {
        this.m_enforceCRUD = false;
        return this;
    }

    public fflib_SObjectSelector unsortedSelectFields()
    {
        this.m_sortSelectFields = false;
        return this;
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
        // TODO: Consider if given the known use cases for this (dynamic selector optimisation) if it's OK to leave this as a null operation
    }

    /**
     * Returns in string form a comma delimited list of fields as defined via getSObjectFieldList and optionally getSObjectFieldSetList
     *
     * @deprecated See newQueryFactory
     **/    
    public String getFieldListString()
    {
        return getFieldListBuilder().getStringValue();
    }
    
    /**
     * Returns in string form a comma delimited list of fields as defined via getSObjectFieldList and optionally getSObjectFieldSetList
     * @param relation Will prefix fields with the given relation, e.g. MyLookupField__r
     *
     * @depricated See newQueryFactory
     **/    
    public String getRelatedFieldListString(String relation)
    {
        return getFieldListBuilder().getStringValue(relation + '.');
    }

    /**
     * Returns the string representation of the SObject this selector represents
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
    public virtual List<SObject> selectSObjectsById(Set<Id> idSet)
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
    public virtual Database.QueryLocator queryLocatorById(Set<Id> idSet)
    {
        return Database.getQueryLocator(buildQuerySObjectById());
    }
    
    /**
     * Throws an exception if the SObject indicated by getSObjectType is not accessible to the current user (read access)
     *
     * @deprecated If you utilise the newQueryFactory method this is automatically done for you (unless disabled by the selector)
     **/
    public void assertIsAccessible()
    {
        if(!getSObjectType().getDescribe().isAccessible())
           throw new fflib_SObjectDomain.DomainException(
                'Permission to access an ' + getSObjectType().getDescribe().getName() + ' denied.');       
    }

    /**
     * Public access for the getSObjectType during Mock registration
     *   (adding public to the existing method broken base class API backwards compatibility)
     **/
    public SObjectType getSObjectType2()
    {
        return getSObjectType();
    }

    /**
     * Public access for the getSObjectType during Mock registration
     *   (adding public to the existing method broken base class API backwards compatibility1)
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
      * // TODO: This should be consistent (ideally) with configureQueryFactory below
      **/
     public void configureQueryFactoryFields(fflib_QueryFactory queryFactory, String relationshipFieldPath)
     {
	// Add fields from selector prefixing the relationship path		
	for(SObjectField field : getSObjectFieldList())		
	queryFactory.selectField(relationshipFieldPath + '.' + field.getDescribe().getName());
	// Automatically select the CurrencyIsoCode for MC orgs (unless the object is a known exception to the rule)
        if(UserInfo.isMultiCurrencyOrganization() && CURRENCY_ISO_CODE_ENABLED)
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
     * Sets the default limit for all queries executed by the selector
     *
     * @param queryLimit The limit used in the query
     */
    public void setLimit(Integer queryLimit)
    {
        this.m_limit = queryLimit;
    }

    /**
     * Sets the default offset for all queries executed by the selector
     *
     * @param queryOffset The offset used in the query
     */
    public void setOffset(Integer queryOffset)
    {
        this.m_offset = queryOffset;
    }

    /**
     * Overwrites the selector class level Ordering
     * It overrides the return of the method getOrderBy
     * Any additional ordering done in the selector method will added to (addOrdering)
     * or override (setOrdering) this value
     *
     * @param ordering The ordering instance of {@link fflib_QueryFactory#Ordering}
     *
     * @example
     *
     * AccountsSelector selector =
     *          (AccountsSelector) Application.Selector.newInstance(Accounts.SObjectType);
     * List<Account> records = selector
     *          .setOrdering(selector.largeAccountsFirst)
     *          .selectById(idSet);
     *
     * The selector class should contain the property below,
     * which can be also be used by the selector methods or any other method using the selector methods
     * public fflib_QueryFactory.Ordering largeAccountsFirst =
     *          new fflib_QueryFactory.Ordering(Account.NumberOfEmployees, fflib_QueryFactory.SortOrder.DESCENDING);
     */
    public void setOrdering(fflib_QueryFactory.Ordering ordering)
    {
        this.m_ordering = new List<fflib_QueryFactory.Ordering>{ ordering };
    }

    /**
     * Overwrites the selector class level Ordering
     * It overrides the return of the method getOrderBy
     * Any additional ordering done in the selector method will added to (addOrdering)
     * or override (setOrdering) this value
     *
     * @param ordering The ordering instance of {@link fflib_QueryFactory#Ordering}
     *
     * @example
     *
     * AccountsSelector selector =
     *          (AccountsSelector) Application.Selector.newInstance(Accounts.SObjectType);
     * List<Account> records = selector
     *          .setOrdering(selector.largeAccountsFirst)
     *          .selectById(idSet);
     *
     * The selector class should contain the property below,
     * which can be also be used by the selector methods or any other method using the selector methods
     * public List<fflib_QueryFactory.Ordering> largeAccountsFirst =
     *          new List<fflib_QueryFactory.Ordering>
     *          {
     *                  new fflib_QueryFactory.Ordering(Account.NumberOfEmployees, fflib_QueryFactory.SortOrder.DESCENDING)
     *          };
     */
    public void setOrdering(List<fflib_QueryFactory.Ordering> ordering)
    {
        this.m_ordering = ordering;
    }

    /**
     * Constructs the default SOQL query for this selector, see selectSObjectsById and queryLocatorById
     **/    
    protected String buildQuerySObjectById()
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
        	assertAccessibility(queryFactory);
        }
        queryFactory.setEnforceFLS(enforceFLS);

        if (includeSelectorFields)
        {
            configureSelectorFields(queryFactory);
        }
        configureOrdering(queryFactory);

        configureOffset(queryFactory, m_offset);
        configureLimit(queryFactory, m_limit);

        queryFactory.setSortSelectFields(m_sortSelectFields);

        return queryFactory;
    }

    private void assertAccessibility(fflib_QueryFactory queryFactory)
    {
        try
        {
            // Leverage QueryFactory for CRUD checking
            queryFactory.assertIsAccessible();
        }
        catch (fflib_SecurityUtils.CrudException e)
        {
            // Marshal exception into DomainException for backwards compatibility
            throw new fflib_SObjectDomain.DomainException(
                    'Permission to access an ' + getSObjectType().getDescribe().getName() + ' denied.');
        }
    }

    private void configureSelectorFields(fflib_QueryFactory queryFactory)
    {
        // select the Selector fields and Fieldsets and set order
        queryFactory.selectFields(getSObjectFieldList());

        List<Schema.FieldSet> fieldSetList = getSObjectFieldSetList();
        if (m_includeFieldSetFields && fieldSetList != null)
            for (Schema.FieldSet fieldSet : fieldSetList)
                queryFactory.selectFieldSet(fieldSet);

        // Automatically select the CurrencyIsoCode for MC orgs (unless the object is a known exception to the rule)
        if (UserInfo.isMultiCurrencyOrganization() && CURRENCY_ISO_CODE_ENABLED)
            queryFactory.selectField('CurrencyIsoCode');
    }

    private void configureOrdering(fflib_QueryFactory queryFactory)
    {
        if (this.m_ordering == null)
        {
            parseOrderBy(queryFactory, getOrderBy());
        }
        else
        {
            queryFactory.setOrdering(this.m_ordering);
        }
    }

    private void parseOrderBy(fflib_QueryFactory queryFactory, String orderbyString)
    {
        for (String orderBy : orderbyString.split(','))
        {
            List<String> orderByParts = orderBy.trim().split(' ');
            String fieldNamePart = orderByParts[0];
            String fieldSortOrderPart = orderByParts.size() > 1 ? orderByParts[1] : null;
            fflib_QueryFactory.SortOrder fieldSortOrder = fflib_QueryFactory.SortOrder.ASCENDING;
            if (fieldSortOrderPart == null)
                fieldSortOrder = fflib_QueryFactory.SortOrder.ASCENDING;
            else if (fieldSortOrderPart.equalsIgnoreCase('DESC'))
                fieldSortOrder = fflib_QueryFactory.SortOrder.DESCENDING;
            else if (fieldSortOrderPart.equalsIgnoreCase('ASC'))
                fieldSortOrder = fflib_QueryFactory.SortOrder.ASCENDING;
            queryFactory.addOrdering(fieldNamePart, fieldSortOrder, orderBy.containsIgnoreCase('NULLS LAST'));
        }
    }

    private void configureLimit(fflib_QueryFactory queryFactory, Integer queryLimit)
    {
        if (queryLimit == null) return;

        queryFactory.setLimit(queryLimit);
    }

    private void configureOffset(fflib_QueryFactory queryFactory, Integer queryOffset)
    {
        if (queryOffset == null) return;

        queryFactory.setOffset(queryOffset);
    }
}
