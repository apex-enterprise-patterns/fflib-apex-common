/**
 * File Name: fflib_SelectorBindingResolver 
 * Description: Interface for resolving selector class bindings
 * Copyright (c) 2020 Johnson & Johnson
 * @author: architect ir. Wilhelmus G.J. Velzeboer | wvelzebo@its.jnj.com 
 */
public interface fflib_SelectorBindingResolver
{
	/**
	 * Creates a new instance of the associated Apex Class implementing fflib_ISObjectSelector
	 *   for the given SObjectType, or if provided via setMock returns the Mock implementation
	 *
	 * @param sObjectType An SObjectType token, e.g. Account.SObjectType
	 * @return Instance of the selector implementation
	 **/
	fflib_ISObjectSelector newInstance(Schema.SObjectType sObjectType);

	/**
	 * Replaces the linked implementation for the Apex interface.
	 *
	 * @param sObjectType The SObjectType for the new implementation
	 * @param selectorImplementationType The replacement implementation type for the given SObjectType
	 */
	void replaceWith(Schema.SObjectType sObjectType, Type selectorImplementationType);

	/**
	 * Helper method to query the given SObject records
	 *   Internally creates an instance of the registered Selector and calls its
	 *     selectSObjectById method
	 *
	 * @param recordIds The SObject record Ids, must be all the same SObjectType
	 * @return List of queried SObjects
	 **/
	List<SObject> selectById(Set<Id> recordIds);

	/**
	 * Helper method to query related records to those provided, for example
	 *   if passed a list of Opportunity records and the Account Id field will
	 *   construct internally a list of Account Ids and call the registered
	 *   Account selector to query the related Account records, e.g.
	 *
	 *     List<Account> accounts =
	 *        (List<Account>) Application.Selector.selectByRelationship(myOpportunities, Opportunity.AccountId);
	 *
	 * @param relatedRecords used to extract the related record Ids, e.g. Opportunity records
	 * @param relationshipField field in the passed records that contains the relationship records to query, e.g. Opportunity.AccountId
	 * @return A list of the queried SObjects
	 **/
	List<SObject> selectByRelationship(List<SObject> relatedRecords, SObjectField relationshipField);

	/**
	 * Replaces the linked implementation for a mocked implementation, used in unit-test
	 *
	 * @param selectorInstance The mock implementation for the given interface type
	 */
	void setMock(fflib_ISObjectSelector selectorInstance);
}