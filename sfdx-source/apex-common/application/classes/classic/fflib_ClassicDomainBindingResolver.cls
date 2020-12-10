/**
 * File Name: fflib_ClassicDomainBindingResolver
 * Description: Domain class binding resolver based on the classic AEP 1.0 definition with static maps
 *
 * @author: architect ir. Wilhelmus G.J. Velzeboer
 *
 * Redistribution and use in source and binary forms, with or without modification,
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above author notice,
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 * - Neither the name of the author nor the names of its contributors
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
 */
public virtual class fflib_ClassicDomainBindingResolver
		implements fflib_DomainBindingResolver
{
	protected fflib_SelectorBindingResolver selectorBindingResolver;

	protected Map<Object, Type> constructorTypeByObject;

	protected Map<Object, fflib_Domain> mockDomainByObject;

	/**
	 * Constructs a Domain factory, using an instance of the Selector Factory
	 *   and a map of Apex classes implementing fflib_ISObjectDomain by SObjectType
	 *   Note this will not check the Apex classes provided actually implement the interfaces
	 *     since this is not possible in the Apex runtime at present
	 *
	 * @param selectorBindingResolver , e.g. Application.Selector
	 * @param constructorTypeByObject Map of Domain classes by ObjectType
	 **/
	public fflib_ClassicDomainBindingResolver(
			fflib_SelectorBindingResolver selectorBindingResolver,
			Map<Object, Type> constructorTypeByObject)
	{
		this.selectorBindingResolver = selectorBindingResolver;
		this.constructorTypeByObject = constructorTypeByObject;
		this.mockDomainByObject = new Map<Object, fflib_Domain>();
	}

	/**
	 * Constructs a Domain factory, using an instance of the Selector Factory
	 *   and a map of Apex classes implementing fflib_ISObjectDomain by SObjectType
	 *   Note this will not check the Apex classes provided actually implement the interfaces
	 *     since this is not possible in the Apex runtime at present
	 *
	 * @param selectorBindingResolver Resolver for Selectors
	 * @param sObjectByDomainConstructorType Map of Apex classes by SObjectType
	 **/
	public fflib_ClassicDomainBindingResolver(
			fflib_SelectorBindingResolver selectorBindingResolver,
			Map<SObjectType, Type> sObjectByDomainConstructorType)
	{
		this.selectorBindingResolver = selectorBindingResolver;
		this.constructorTypeByObject = getConstructorTypeByObject(sObjectByDomainConstructorType);
		this.mockDomainByObject = new Map<Object, fflib_Domain>();
	}
	/**
	 * Dynamically constructs an instance of a Domain class for the given record Ids
	 *   Internally uses the Selector Factory to query the records before passing to a
	 *   dynamically constructed instance of the application Apex Domain class
	 *
	 * @param recordIds A list of Id's of the same type
	 * @exception Throws an exception via the Selector Factory if the Ids are not all of the same SObjectType
	 *
	 * @return Instance of the Domain
	 **/
	public virtual fflib_Domain newInstance(Set<Id> recordIds)
	{
		return newInstance(selectorBindingResolver.selectById(recordIds));
	}

	/**
	 * Dynamically constructs an instance of the Domain class for the given records
	 *   Will return a Mock implementation if one has been provided via setMock
	 *
	 * @param records A concrete list (e.g. List<Account> vs List<SObject>) of records
	 * @exception Throws an exception if the SObjectType cannot be determined from the list
	 *              or the constructor for Domain class was not registered for the SObjectType
	 *
	 * @return Instance of the Domain containing the given records
	 **/
	public virtual fflib_Domain newInstance(List<SObject> records)
	{
		SObjectType domainSObjectType = records.getSObjectType();
		if (domainSObjectType == null)
			throw new DeveloperException('Unable to determine SObjectType');

		return newInstance((List<Object>) records, (Object) domainSObjectType);
	}

	/**
	 * Dynamically constructs an instance of the Domain class for the given records and SObjectType
	 *   Will return a Mock implementation if one has been provided via setMock
	 *
	 * @param objects A list objects
	 * @param objectType ObjectType for list of objects
	 *
	 * @throws DeveloperException
	 *
	 * @return Instance of fflib_Domain containing the provided objects
	 **/
	public virtual fflib_Domain newInstance(List<Object> objects, Object objectType)
	{
		// Mock implementation?
		if (mockDomainByObject.containsKey(objectType))
			return mockDomainByObject.get(objectType);

		// Determine SObjectType and Apex classes for Domain class
		Type domainConstructorClass = constructorTypeByObject.get(objectType);
		if (domainConstructorClass == null)
			throw new DeveloperException('Domain constructor class not found for SObjectType ' + objectType);

		// Construct Domain class passing in the queried records
		Object domainConstructor = domainConstructorClass.newInstance();

		// for backwards compatibility
		if (domainConstructor instanceof fflib_SObjectDomain.IConstructable2)
		{
			return (fflib_Domain)
					((fflib_SObjectDomain.IConstructable2) domainConstructor)
							.construct((List<SObject>) objects, (SObjectType) objectType);
		}
		else if (domainConstructor instanceof fflib_SObjectDomain.IConstructable)
		{
			return (fflib_Domain)
					((fflib_SObjectDomain.IConstructable) domainConstructor)
							.construct((List<SObject>) objects);
		}

		return ((fflib_DomainConstructor) domainConstructor)
					.construct(objects);
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
	 * @return Instance of the Domain with the given records
	 **/
	public virtual fflib_Domain newInstance(List<SObject> records, SObjectType domainSObjectType)
	{
		if (domainSObjectType == null)
			throw new DeveloperException('Must specify sObjectType');

		return newInstance(
				(List<Object>) records,
				(Object) domainSObjectType
		);
	}

	public void replaceWith(fflib_Domain domain)
	{
		setMock(domain);
	}

	public void replaceWith(Object domainType, Object domainOrConstructorType)
	{
		if (domainOrConstructorType instanceof System.Type)
		{
			this.constructorTypeByObject.put(domainType, (System.Type) domainOrConstructorType);
		}
		else if (domainOrConstructorType instanceof fflib_Domain)
		{
			setMock((fflib_Domain) domainOrConstructorType);
		}
	}

	public virtual void setMock(fflib_Domain mockDomain)
	{
		mockDomainByObject.put(mockDomain.getType(), mockDomain);
	}

	private Map<Object, Type> getConstructorTypeByObject(Map<SObjectType, Type> constructorTypeBySObjectType)
	{
		Map<Object, Type> result = new Map<Object, Type>();
		for (SObjectType sObjectType : constructorTypeBySObjectType.keySet())
		{
			result.put(
					(Object) sObjectType,
					constructorTypeBySObjectType.get(sObjectType)
			);
		}
		return result;
	}

	/**
	 * Exception representing a developer coding error, not intended for end user eyes
	 **/
	public class DeveloperException extends Exception {}
}