/**
 * File Name: fflib_ClassicServiceBindingResolver
 * Description: Service class binding resolver based on the classic AEP 1.0 definition with static maps
 * Copyright (c) 2020 Johnson & Johnson
 *
 * @author : architect ir. Wilhelmus G.J. Velzeboer | wvelzebo@its.jnj.com
 */
public virtual class fflib_ClassicServiceBindingResolver
		implements fflib_ServiceBindingResolver
{

	protected Map<Type, Type> implementationTypeByInterfaceType;
	protected Map<Type, Object> mockImplementationByInterfaceType;

	/**
	 * Class constructor
	 *
	 * @param implementationTypeByInterfaceType A map linking the interface type to its implementation type
	 */
	public fflib_ClassicServiceBindingResolver(Map<Type, Type> implementationTypeByInterfaceType)
	{
		this.implementationTypeByInterfaceType = implementationTypeByInterfaceType;
		this.mockImplementationByInterfaceType = new Map<Type, Object>();
	}

	/**
	 * Returns a new instance of the Apex class associated with the given Apex interface
	 *   Will return any mock implementation of the interface provided via setMock
	 *   Note that this method will not check the configured Apex class actually implements the interface
	 *
	 * @param serviceInterfaceType Apex interface type
	 *
	 * @return Instance of the implementation type
	 * @exception DeveloperException Is thrown if there is no registered Apex class for the interface type
	 **/
	public virtual Object newInstance(Type serviceInterfaceType)
	{
		// Mock implementation?
		if (mockImplementationByInterfaceType.containsKey(serviceInterfaceType))
			return mockImplementationByInterfaceType.get(serviceInterfaceType);

		// Create an instance of the type implementing the given interface
		Type serviceImpl = implementationTypeByInterfaceType.get(serviceInterfaceType);
		if (serviceImpl == null)
			throw new DeveloperException('No implementation registered for service interface ' + serviceInterfaceType.getName());

		return serviceImpl.newInstance();
	}

	/**
	 * Replaces the linked implementation for the Apex interface.
	 *
	 * @param serviceInterfaceType The interface type for this new implementation
	 * @param serviceImplementationType The replacement implementation type for the given interface type
	 */
	public virtual void replaceWith(Type serviceInterfaceType, Type serviceImplementationType)
	{
		implementationTypeByInterfaceType.put(serviceInterfaceType, serviceImplementationType);
	}

	/**
	 * Replaces the linked implementation for a mocked implementation, used in unit-test
	 *
	 * @param serviceInterfaceType The interface type for this new implementation
	 * @param serviceInstance The mock instance for the given interface type
	 */
	public virtual void setMock(Type serviceInterfaceType, Object serviceInstance)
	{
		if (!System.Test.isRunningTest())
			throw new DeveloperException('The setMock method should only be invoked from a unit-test context');

		mockImplementationByInterfaceType.put(serviceInterfaceType, serviceInstance);
	}

	/**
	 * Exception representing a developer coding error, not intended for end user eyes
	 **/
	public class DeveloperException extends Exception {}
}