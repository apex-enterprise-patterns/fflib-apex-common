/**
 * File Name: fflib_DomainBindingResolver 
 * Description: Interface for resolving domain class bindings
 * Copyright (c) 2020 Johnson & Johnson
 * @author: architect ir. Wilhelmus G.J. Velzeboer | wvelzebo@its.jnj.com 
 */
public interface fflib_DomainBindingResolver
{
	/**
	 * Dynamically constructs an instance of a Domain class for the given record Ids
	 *   Internally uses the Selector Factory to query the records before passing to a
	 *   dynamically constructed instance of the application Apex Domain class
	 *
	 * @param recordIds A list of Id's of the same type
	 * @return Instance of fflib_ISObjectDomain containing the record with the provided Ids
	 **/
	fflib_ISObjectDomain newInstance(Set<Id> recordIds);

	/**
	 * Dynamically constructs an instance of the Domain class for the given records
	 *   Will return a Mock implementation if one has been provided via setMock
	 *
	 * @param records A concrete list (e.g. List<Account> vs List<SObject>) of records
	 * @return Instance of fflib_ISObjectDomain containing the provided records
	 **/
	fflib_ISObjectDomain newInstance(List<SObject> records);

	/**
	 * Dynamically constructs an instance of the Domain class for the given records and SObjectType
	 *   Will return a Mock implementation if one has been provided via setMock
	 *
	 * @param records A list records
	 * @param domainSObjectType SObjectType for list of records
	 **/
	fflib_ISObjectDomain newInstance(List<SObject> records, SObjectType domainSObjectType);

	/**
	 * Replaces the linked implementation for the Apex interface.
	 *
	 * @param domainSObjectType The interface type for this new implementation
	 * @param domainConstructorImplementationType The replacement implementation type for the given interface type
	 *    this should be the domain Constructor which is an implementation of fflib_SObjectDomainConstructor
	 */
	void replaceWith(Schema.SObjectType domainSObjectType, Type domainConstructorImplementationType);

	/**
	 * Replaces the linked implementation for a mocked implementation, used in unit-test
	 *
	 * @param mockDomain The mock instance for the given interface type
	 */
	void setMock(fflib_ISObjectDomain mockDomain);

	/**
	 * Replaces the linked implementation for a mocked implementation, used in unit-test
	 *
	 * @param domainSObjectType The SObjectType to mock
	 * @param mockDomain The mock instance for the given interface type
	 */
	void setMock(Schema.SObjectType domainSObjectType, fflib_ISObjectDomain mockDomain);
}