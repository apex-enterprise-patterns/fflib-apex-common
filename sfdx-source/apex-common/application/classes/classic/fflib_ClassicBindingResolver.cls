/**
 * File Name: fflib_ClassicServiceBindingResolver
 * Description: Service class binding resolver based on the classic AEP 1.0 definition with static maps
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
public virtual class fflib_ClassicBindingResolver
		implements fflib_BindingResolver
{

	protected Map<Type, Type> implementationTypeByInterfaceType;
	protected Map<Type, Object> mockImplementationByInterfaceType;

	/**
	 * Class constructor
	 *
	 * @param implementationTypeByInterfaceType A map linking the interface type to its implementation type
	 */
	public fflib_ClassicBindingResolver(Map<Type, Type> implementationTypeByInterfaceType)
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
	 * @param implementation An instance or class Type of the replacement implementation
	 */
	public virtual void replaceWith(Type serviceInterfaceType, Object implementation)
	{
		if (implementation instanceof System.Type)
		{
			implementationTypeByInterfaceType.put(serviceInterfaceType, (System.Type) implementation);
		}
		else
		{
			mockImplementationByInterfaceType.put(serviceInterfaceType, implementation);
		}
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