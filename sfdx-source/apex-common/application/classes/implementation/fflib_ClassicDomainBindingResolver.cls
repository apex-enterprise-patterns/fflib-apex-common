/**
 * File Name: fflib_ClassicDomainBindingResolver
 * Description: Domain class binding resolver based on the classic AEP 1.0 definition with static maps
 * Copyright (c) 2020 Johnson & Johnson
 *
 * @author : architect ir. Wilhelmus G.J. Velzeboer | wvelzebo@its.jnj.com
 */
public virtual class fflib_ClassicDomainBindingResolver implements fflib_DomainBindingResolver
{
	protected fflib_SelectorBindingResolver selectorBindingResolver;

	protected Map<Schema.SObjectType, Type> domainConstructorBySObjectType;

	protected Map<Schema.SObjectType, fflib_ISObjectDomain> mockDomainInstanceBySObjectType;

	/**
	 * Class constructor
	 *
	 * @param selectorBindingResolver
	 * @param domainConstructorBySObjectType
	 */
	public fflib_ClassicDomainBindingResolver(
			fflib_SelectorBindingResolver selectorBindingResolver,
			Map<SObjectType, Type> domainConstructorBySObjectType)
	{
		this.selectorBindingResolver = selectorBindingResolver;
		this.domainConstructorBySObjectType = domainConstructorBySObjectType;
		this.mockDomainInstanceBySObjectType = new Map<SObjectType, fflib_ISObjectDomain>();
	}

	/**
	 * Dynamically constructs an instance of a Domain class for the given record Ids
	 *   Internally uses the Selector Factory to query the records before passing to a
	 *   dynamically constructed instance of the application Apex Domain class
	 *
	 * @param recordIds A list of Id's of the same type
	 * @exception Throws an exception via the Selector Factory if the Ids are not all of the same SObjectType
	 *
	 * @return Instance of fflib_ISObjectDomain containing the record with the provided Ids
	 **/
	public virtual fflib_ISObjectDomain newInstance(Set<Id> recordIds)
	{
		return newInstance(selectorBindingResolver.selectById(recordIds));
	}

	/**
	 * Dynamically constructs an instance of the Domain class for the given records
	 *   Will return a Mock implementation if one has been provided via setMock
	 *
	 * @param records A concrete list (e.g. List<Account> vs List<SObject>) of records
	 * @exception Throws an exception if the SObjectType cannot be determined from the list
	 *              or the constructor for Domain class was not registered for the SOBjectType
	 *
	 * @return Instance of fflib_ISObjectDomain containing the provided records
	 **/
	public virtual fflib_ISObjectDomain newInstance(List<SObject> records)
	{
		SObjectType domainSObjectType = records.getSObjectType();
		if (domainSObjectType == null)
			throw new DeveloperException('Unable to determine SObjectType');

		// Mock implementation?
		if (mockDomainInstanceBySObjectType.containsKey(domainSObjectType))
			return mockDomainInstanceBySObjectType.get(domainSObjectType);

		// Determine SObjectType and Apex classes for Domain class
		Type domainConstructorClass = domainConstructorBySObjectType.get(domainSObjectType);
		if (domainConstructorClass == null)
			throw new DeveloperException('Domain constructor class not found for SObjectType ' + domainSObjectType);

		// Construct Domain class passing in the queried records
		fflib_SObjectDomain.IConstructable domainConstructor =
				(fflib_SObjectDomain.IConstructable) domainConstructorClass.newInstance();
		return (fflib_ISObjectDomain) domainConstructor.construct(records);
	}

	/**
	 * Dynamically constructs an instance of the Domain class for the given records and SObjectType
	 *   Will return a Mock implementation if one has been provided via setMock
	 *
	 * @param records A list records
	 * @param domainSObjectType SObjectType for list of records
	 * @exception Throws an exception if the SObjectType is not specified or if constructor for Domain class was not registered for the SObjectType
	 *
	 * @remark Will support List<SObject> but all records in the list will be assumed to be of
	 *         the type specified in sObjectType
	 *
	 * @return Instance of fflib_ISObjectDomain containing the provided records
	 **/
	public virtual fflib_ISObjectDomain newInstance(List<SObject> records, SObjectType domainSObjectType)
	{
		if (domainSObjectType == null)
			throw new DeveloperException('Must specify sObjectType');

		// Mock implementation?
		if (mockDomainInstanceBySObjectType.containsKey(domainSObjectType))
			return mockDomainInstanceBySObjectType.get(domainSObjectType);

		// Determine SObjectType and Apex classes for Domain class
		Type domainConstructorClass = domainConstructorBySObjectType.get(domainSObjectType);
		if (domainConstructorClass == null)
			throw new DeveloperException('Domain constructor class not found for SObjectType ' + domainSObjectType);

		// Construct Domain class passing in the queried records
		fflib_SObjectDomain.IConstructable2 domainConstructor =
				(fflib_SObjectDomain.IConstructable2) domainConstructorClass.newInstance();
		return (fflib_ISObjectDomain) domainConstructor.construct(records, domainSObjectType);
	}

	public void replaceWith(SObjectType domainSObjectType, Type domainConstructorImplementationType)
	{
		this.domainConstructorBySObjectType.put(domainSObjectType, domainConstructorImplementationType);
	}

	public virtual void setMock(fflib_ISObjectDomain mockDomain)
	{
		setMock(mockDomain.sObjectType(), mockDomain);
	}

	public virtual void setMock(Schema.SObjectType domainSObjectType, fflib_ISObjectDomain mockDomain)
	{
		mockDomainInstanceBySObjectType.put(domainSObjectType, mockDomain);
	}

	/**
	 * Exception representing a developer coding error, not intended for end user eyes
	 **/
	public class DeveloperException extends Exception {}
}