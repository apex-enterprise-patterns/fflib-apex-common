/**
 * File Name: fflib_ClassicServiceBindingResolverTest 
 * Description: Unit test class for the Service class binding resolver based on the classic AEP 1.0 definition with static maps
 * Copyright (c) 2020 Johnson & Johnson
 * @author: architect ir. Wilhelmus G.J. Velzeboer | wvelzebo@its.jnj.com 
 */
@IsTest
private class fflib_ClassicServiceBindingResolverTest
{
	@IsTest
	static void itShouldReturnTheServiceInstance()
	{
		// GIVEN a configured service binding resolver with an interface linked to an implementation
		fflib_ServiceBindingResolver service = generateConfiguredServiceBindingResolver();

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
		fflib_ServiceBindingResolver service =
				new fflib_ClassicServiceBindingResolver(new Map<Type, Type>	{});

		// WHEN we request an instance of the implementation for the interface
		Boolean exceptionThrown = false;
		try
		{
			service.newInstance(ServiceInterface.class);
		} catch (fflib_ClassicServiceBindingResolver.DeveloperException e)
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
		fflib_ServiceBindingResolver service = generateConfiguredServiceBindingResolver();


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
	static void itShouldReturnTheReplacedImplementation()
	{
		// GIVEN a configured service binding resolver with an interface linked to an implementation
		//   where the implementation is replaced for an alternative implementation
		fflib_ServiceBindingResolver service = generateConfiguredServiceBindingResolver();
		service.replaceWith(ServiceInterface.class, AlternativeServiceImplementation.class);

		// WHEN we request the implementation for the interface
		ServiceInterface result = (ServiceInterface) service.newInstance(ServiceInterface.class);

		// THEN it should return the alternative implementation
		System.assert(
				result instanceof AlternativeServiceImplementation,
				'Incorrect implementation returned, expected the alternative implementation'
		);
	}

	private static fflib_ClassicServiceBindingResolver generateConfiguredServiceBindingResolver()
	{
		return new fflib_ClassicServiceBindingResolver(
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