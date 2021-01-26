/**
 * File Name: fflib_ClassicServiceBindingResolverTest 
 * Description: Unit test class for the Service class binding resolver based on the classic AEP 1.0 definition with static maps
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
@IsTest
private class fflib_ClassicBindingResolverTest
{
	@IsTest
	static void itShouldReturnTheServiceInstance()
	{
		// GIVEN a configured service binding resolver with an interface linked to an implementation
		fflib_IBindingResolver service = generateConfiguredServiceBindingResolver();

		// WHEN we request the implementation for the interface
		Object result = service.newInstance(ServiceInterface.class);

		// THEN the result should be the instance of the fflib_TestServiceInterface
		System.assert(
				result instanceof ServiceImplementation,
				'Incorrect implementation returned'
		);
	}

	@IsTest
	static void itShouldReturnTheInstance_NoImplementationRegisteredException()
	{
		// GIVEN an empty service binding resolver
		fflib_IBindingResolver service =
				new fflib_ClassicBindingResolver(new Map<Type, Type> {});

		// WHEN we request an instance of the implementation for the interface
		Boolean exceptionThrown = false;
		try
		{
			service.newInstance(ServiceInterface.class);
		} catch (fflib_ClassicBindingResolver.DeveloperException e)
		{
			exceptionThrown = true;
		}

		// THEN an exception should have been thrown
		System.assert(
				exceptionThrown,
				'An exception should have been thrown as the requested interface is not present'
		);
	}

	@IsTest
	static void itShouldReturnTheMockInstance()
	{
		// GIVEN a configured service binding resolver with an interface linked to an implementation
		//    where the interface has been replaced with a mock
		fflib_IBindingResolver service = generateConfiguredServiceBindingResolver();


		service.setMock(ServiceInterface.class, new AlternativeServiceImplementation());

		// WHEN we request an instance for the interface
		ServiceInterface result = (ServiceInterface) service.newInstance(ServiceInterface.class);

		// THEN the result should be the mock instance of the type fflib_TestServiceInterface
		System.assert(
				result instanceof AlternativeServiceImplementation,
				'Incorrect implementation returned'
		);
	}

	@IsTest
	static void itShouldReturnTheReplacedInstance()
	{
		// GIVEN a configured service binding resolver with an interface linked to an implementation
		//   where the implementation is replaced for an alternative implementation instance
		fflib_IBindingResolver service = generateConfiguredServiceBindingResolver();
		service.replaceWith(ServiceInterface.class, new AlternativeServiceImplementation());

		// WHEN we request the implementation for the interface
		ServiceInterface result = (ServiceInterface) service.newInstance(ServiceInterface.class);

		// THEN it should return the alternative implementation
		System.assert(
				result instanceof AlternativeServiceImplementation,
				'Incorrect implementation returned, expected the alternative implementation'
		);
	}

	@IsTest
	static void itShouldReturnTheReplacedImplementation()
	{
		// GIVEN a configured service binding resolver with an interface linked to an implementation
		//   where the implementation is replaced for an alternative implementation
		fflib_IBindingResolver service = generateConfiguredServiceBindingResolver();
		service.replaceWith(ServiceInterface.class, AlternativeServiceImplementation.class);

		// WHEN we request the implementation for the interface
		ServiceInterface result = (ServiceInterface) service.newInstance(ServiceInterface.class);

		// THEN it should return the alternative implementation
		System.assert(
				result instanceof AlternativeServiceImplementation,
				'Incorrect implementation returned, expected the alternative implementation'
		);
	}

	private static fflib_ClassicBindingResolver generateConfiguredServiceBindingResolver()
	{
		return new fflib_ClassicBindingResolver(
				new Map<Type, Type>
				{
						ServiceInterface.class => ServiceImplementation.class
				}
		);
	}

	interface ServiceInterface
	{
		void myMethod();
	}

	class ServiceImplementation implements ServiceInterface
	{
		public void myMethod(){}
	}

	class AlternativeServiceImplementation implements ServiceInterface
	{
		public void myMethod(){}
	}
}