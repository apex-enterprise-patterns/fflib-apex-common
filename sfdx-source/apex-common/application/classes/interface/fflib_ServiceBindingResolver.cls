/**
 * File Name: fflib_ServiceBindingResolver 
 * Description: Interface for resolving service class bindings
 * Copyright (c) 2020 Johnson & Johnson
 * @author: architect ir. Wilhelmus G.J. Velzeboer | wvelzebo@its.jnj.com 
 */
public interface fflib_ServiceBindingResolver
{
	/**
	 * Returns a new instance of the Apex class associated with the given Apex interface
	 *
	 * @param serviceInterfaceType Apex interface type
	 * @return Instance of the implementation type
	 **/
	Object newInstance(Type serviceInterfaceType);

	/**
	 * Replaces the linked implementation for the Apex interface.
	 *
	 * @param serviceInterfaceType The interface type for this new implementation
	 * @param serviceImplementationType The replacement implementation type for the given interface type
	 */
	void replaceWith(Type serviceInterfaceType, Type serviceImplementationType);

	/**
	 * Replaces the linked implementation for a mocked implementation, used in unit-test
	 *
	 * @param serviceInterfaceType The interface type for this new implementation
	 * @param serviceInstance The mock instance for the given interface type
	 */
	void setMock(Type serviceInterfaceType, Object serviceInstance);
}