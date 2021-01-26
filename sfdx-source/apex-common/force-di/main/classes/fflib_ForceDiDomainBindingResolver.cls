/**
 * File Name: fflib_DomainFactoryImp
 * Description:  Domain factory for Domains configured as bindings to the force-di
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
public virtual with sharing class fflib_ForceDiDomainBindingResolver
		implements fflib_IDomainBindingResolver
{
	protected String appName;
	protected fflib_ISelectorBindingResolver selectorResolver;

	public fflib_ForceDiDomainBindingResolver(
			String appName,
			fflib_ISelectorBindingResolver selectorResolver)
	{
		this.appName = appName.toLowerCase();
		this.selectorResolver = selectorResolver;
	}

	/**
	 * Queries the objects and constructs a new domain instance for the query result
	 *
	 * @param recordIds Record ids to register in the domain
	 * @throws DeveloperException when the SObjectType could not be retrieved from the List<SObject>,
	 * @throws DeveloperException when the implementation is null or its not an instance of fflib_SObjectDomain.IConstructable2
	 *
	 * @return Instance of a SObjectDomain class
	 */
	public fflib_IDomain newInstance(Set<Id> recordIds)
	{
		return newInstance(selectorResolver.selectById(recordIds));
	}

	/**
	 * Gets the SObjectType and constructs a new instance of the domain
	 *
	 * @param records Records to register in the domain
	 *
	 * @return SObjectDomain instance or the mocked version
	 * @throws DeveloperException when the SObjectType could not be retrieved from the List<SObject>,
	 * @throws DeveloperException when the implementation is null or its not an instance of fflib_SObjectDomain.IConstructable2
	 */
	public fflib_IDomain newInstance(List<SObject> records)
	{
		Schema.SObjectType sObjectType = records.getSObjectType();
		assertForValidSObjectType(sObjectType);
		return newInstance(records, sObjectType);
	}

	/**
	 * Gets the instance for the domain constructor from force-di and constructs a new domain
	 *
	 * @param records Records to register in the domain
	 * @param sObjectType The SObjectType of the provided objects
	 *
	 * @throws DeveloperException
	 *
	 * @return Domain instance or the mocked version
	 */
	public fflib_IDomain newInstance(List<SObject> records, Schema.SObjectType sObjectType)
	{
		return newInstance(
				(List<Object>) records,
				(Object) sObjectType
		);
	}

	/**
	 * Gets the instance for the domain constructor from force-di and constructs a new domain
	 *
	 * @param objects The objects to register in the domain
	 * @param objectType The ObjectType of the provided objects
	 *
	 * @throws DeveloperException
	 *
	 * @return Domain instance or the mocked version
	 */
	public fflib_IDomain newInstance(List<Object> objects, Object objectType)
	{
		Object implementation = getImplementationFromInjector(objectType);

		// Check if we are dealing with a mocked & stubbed domain here
		if (System.Test.isRunningTest() && (implementation instanceof fflib_IDomain))
			return (fflib_IDomain) implementation;

		assertForDomainConstructorImplementation(implementation);
		return constructDomainInstance(implementation, objects, objectType);
	}

	/**
	 * Dynamically replace a domain implementation at runtime
	 *
	 * @param domainImpl The new implementation of the domain
	 */
	public void replaceWith(fflib_IDomain domainImpl)
	{
		replaceWith(domainImpl.getType(), (Object) domainImpl);
	}

	/**
	 * Replaces the linked implementation for the Apex interface.
	 *
	 * @param domainType The interface type for this new implementation
	 * @param domainImplementationOrConstructorType The replacement implementation type for the given interface type
	 *    this should be the domain Constructor which is an implementation of fflib_SObjectDomainConstructor
	 */
	public void replaceWith(Object domainType, Object domainImplementationOrConstructorType)
	{
		di_Injector.Org.Bindings.byName(
				getBindingName(domainType)
		)
				.replaceBindingWith(domainImplementationOrConstructorType);
	}

	public void setMock(fflib_IDomain mockDomain)
	{
		replaceWith(mockDomain);
	}

	/**
	 * assertForDomainConstructorImplementation
	 *
	 * @param implementation Implementation returned by the binding to be validated
	 *
	 * @throws fflib_DeveloperException when the implementation is null or its not an instance of fflib_SObjectDomain.IConstructable2
	 */
	private void assertForDomainConstructorImplementation(Object implementation)
	{
		System.debug('assertForDomainConstructorImplementation');
		System.debug('----------------------------');
		System.debug('fflib_SObjectDomain.IConstructable2: '+(implementation instanceof fflib_SObjectDomain.IConstructable2));
		System.debug('fflib_SObjectDomain.IConstructable: '+(implementation instanceof fflib_SObjectDomain.IConstructable));
		System.debug('fflib_DomainConstructor: '+(implementation instanceof fflib_IDomainConstructor));
		System.debug('Type: '+(implementation instanceof System.Type));
		System.debug('----------------------------');

		if ((implementation instanceof fflib_SObjectDomain.IConstructable2) ||
				(implementation instanceof fflib_SObjectDomain.IConstructable) ||
				(implementation instanceof fflib_IDomainConstructor)) return;
		// todo - convert to label
		throw new DeveloperException('Label.fflib_DomainConstructorMissing');
	}

	/**
	 * assertForValidSObjectType
	 *
	 * @param sObjectType
	 *
	 * @throws DeveloperException
	 */
	private void assertForValidSObjectType(SObjectType sObjectType)
	{
		if (sObjectType == null)
		{
			// todo convert to label
			throw new DeveloperException('Label.fflib_UnableToDetermineSObjectType');
		}
	}

	/**
	 * Takes the constructorImplementation, cast it to the correct type and call the 'construct' method to create a new instance of the domain
	 *
	 * @param constructorImp
	 * @param objects
	 * @param objectType
	 *
	 * @return instance of fflib_Domain
	 */
	private fflib_IDomain constructDomainInstance(
			Object constructorImp,
			List<Object> objects,
			Object objectType)
	{
		// For backwards compatibility
		if (!(constructorImp instanceof fflib_SObjectDomain.IConstructable2) &&
				(constructorImp instanceof fflib_SObjectDomain.IConstructable))
		{
			System.debug(System.LoggingLevel.WARN, 'DEPRECATED: Use fflib_DomainConstructor to construct domains');
			return (fflib_ISObjectDomain)
					(((fflib_SObjectDomain.IConstructable) constructorImp)
							.construct((List<SObject>) objects));
		}
		else if (constructorImp instanceof fflib_SObjectDomain.IConstructable2)
		{
			System.debug(System.LoggingLevel.WARN, 'DEPRECATED: Use fflib_DomainConstructor to construct domains');
			return (fflib_ISObjectDomain)
					(((fflib_SObjectDomain.IConstructable2) constructorImp)
							.construct((List<SObject>) objects, (Schema.SObjectType) objectType));
		}

		return ((fflib_IDomainConstructor) constructorImp)
				.construct(objects);
	}

	/**
	 * Constructs the binding name with; AppName, "domain" and SObjectType
	 *
	 * @param objectType
	 *
	 * @return The constructed binding name
	 */
	private String getBindingName(Object objectType)
	{
		return this.appName + '.domain.' + String.valueOf(objectType);
	}

	/**
	 * Gets the bindingName for the provided SObjectType and requests an instance from force-di
	 *
	 * @param objectType
	 *
	 * @return Instance of fflib_ISObjectDomain.IConstructable2
	 */
	private Object getImplementationFromInjector(Object objectType)
	{
		return di_Injector.Org.getInstance(
				getBindingName(objectType)
		);
	}

	public class DeveloperException extends Exception {	}
}