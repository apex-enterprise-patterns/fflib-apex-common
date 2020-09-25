/**
 * File Name: fflib_ClassicSelectorBindingResolver
 * Description: Selector class binding resolver based on the classic AEP 1.0 definition with static maps
 * Copyright (c) 2020 Johnson & Johnson
 *
 * @author : architect ir. Wilhelmus G.J. Velzeboer | wvelzebo@its.jnj.com
 */
public virtual class fflib_ClassicSelectorBindingResolver
		implements fflib_SelectorBindingResolver
{

	protected Map<SObjectType, Type> selectorImplementationTypeBySObjectType;
	protected Map<SObjectType, fflib_ISObjectSelector> selectorMockBySObjectType;

	/**
	 * Class constructor
	 */
	public fflib_ClassicSelectorBindingResolver(Map<SObjectType, Type> selectorImplementationTypeBySObjectType)
	{
		this.selectorImplementationTypeBySObjectType = selectorImplementationTypeBySObjectType;
		this.selectorMockBySObjectType = new Map<SObjectType, fflib_ISObjectSelector>();
	}

	/**
	 * Creates a new instance of the associated Apex Class implementing fflib_ISObjectSelector
	 *   for the given SObjectType, or if provided via setMock returns the Mock implementation
	 *
	 * @param sObjectType An SObjectType token, e.g. Account.SObjectType
	 *
	 * @return Instance of the selector implementation
	 **/
	public virtual fflib_ISObjectSelector newInstance(Schema.SObjectType sObjectType)
	{
		// Mock implementation?
		if (selectorMockBySObjectType.containsKey(sObjectType))
			return selectorMockBySObjectType.get(sObjectType);

		// Determine Apex class for Selector class
		Type selectorClass = selectorImplementationTypeBySObjectType.get(sObjectType);
		if (selectorClass == null)
			throw new DeveloperException('Selector class not found for SObjectType ' + sObjectType);

		// Construct Selector class and query by Id for the records
		return (fflib_ISObjectSelector) selectorClass.newInstance();
	}

	/**
	 * Replaces the linked implementation for the Apex interface.
	 *
	 * @param sObjectType The SObjectType for the new implementation
	 * @param selectorImplementationType The replacement implementation type for the given SObjectType
	 */
	public void replaceWith(Schema.SObjectType sObjectType, Type selectorImplementationType)
	{
		this.selectorImplementationTypeBySObjectType.put(sObjectType, selectorImplementationType);
	}

	/**
	 * Helper method to query the given SObject records
	 *   Internally creates an instance of the registered Selector and calls its
	 *     selectSObjectById method
	 *
	 * @param recordIds The SObject record Ids, must be all the same SObjectType
	 *
	 * @return List of queried SObjects
	 * @exception Is thrown if the record Ids are not all the same or the SObjectType is not registered
	 **/
	public virtual List<SObject> selectById(Set<Id> recordIds)
	{
		// No point creating an empty Domain class, nor can we determine the SObjectType anyway
		if (recordIds == null || recordIds.size() == 0)
			throw new DeveloperException('Invalid record Id\'s set');

		// Determine SObjectType
		Schema.SObjectType domainSObjectType = new List<Id>(recordIds)[0].getSobjectType();
		for (Id recordId : recordIds)
		{
			if (recordId.getSobjectType() != domainSObjectType)
				throw new DeveloperException('Unable to determine SObjectType, Set contains Id\'s from different SObject types');
		}

		// Construct Selector class and query by Id for the records
		return newInstance(domainSObjectType).selectSObjectsById(recordIds);
	}

	/**
	 * Helper method to query related records to those provided, for example
	 *   if passed a list of Opportunity records and the Account Id field will
	 *   construct internally a list of Account Ids and call the registered
	 *   Account selector to query the related Account records, e.g.
	 * <p/>
	 *     List<Account> accounts =
	 *        (List<Account>) Application.Selector.selectByRelationship(myOpportunities, Opportunity.AccountId);
	 *
	 * @param relatedRecords used to extract the related record Ids, e.g. Opportunity records
	 * @param relationshipField field in the passed records that contains the relationship records to query, e.g. Opportunity.AccountId
	 *
	 * @return A list of the queried SObjects
	 **/
	public virtual List<SObject> selectByRelationship(List<SObject> relatedRecords, SObjectField relationshipField)
	{
		Set<Id> relatedIds = new Set<Id>();
		for (SObject relatedRecord : relatedRecords)
		{
			Id relatedId = (Id) relatedRecord.get(relationshipField);
			if (relatedId != null)
			{
				relatedIds.add(relatedId);
			}
		}
		return selectById(relatedIds);
	}

	public virtual void setMock(fflib_ISObjectSelector selectorInstance)
	{
		selectorMockBySObjectType.put(selectorInstance.sObjectType(), selectorInstance);
	}

	/**
	 * Exception representing a developer coding error, not intended for end user eyes
	 **/
	public class DeveloperException extends Exception {}
}