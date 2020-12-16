/**
 * File Name: fflib_EventFeatureTest
 * Description:
 *
 * @author : architect ir. Wilhelmus G.J. Velzeboer | wvelzebo@its.jnj.com
 */
@IsTest
private class fflib_EventFeatureTest
{
	private static final String EVENT = 'MyEvent';
	private static Boolean eventListenerCalled = false;

	@IsTest
	static void testBehavior()
	{
		TestApplication application = new TestApplication();
		fflib_SObjectEvent sObjectEvent = new fflib_SObjectEvent();
		sObjectEvent.operationType = System.TriggerOperation.BEFORE_INSERT;
		sObjectEvent.records = new List<Account>
		{
				new Account(Name = 'Test Account')
		};

		System.Test.startTest();
		application.eventEmitter.emit(sObjectEvent);
		System.Test.stopTest();

		System.assert(eventListenerCalled, 'Whoops Listener was not called');
	}


	// Interface class for the event listener
	private interface OnChangedAccountSanitizer extends fflib_EventListener	{	}

	// Implementation of the event listener
	private class OnChangedAccountSanitizerImp
			extends fflib_SObjectEventListener
			implements OnChangedAccountSanitizer
	{
		public override void onBeforeInsert()
		{
			eventListenerCalled = true;
		}
	}

	// The selector returning the listeners for the given event
	private class EventListenerSelector implements fflib_EventListenerSelector
	{
		public List<fflib_EventListenerConfig> getEventListeners(String namespace, String eventName)
		{
			return new List<fflib_EventListenerConfig>
			{
					new fflib_EventListenerConfig(OnChangedAccountSanitizer.class)
			};
		}
	}

	// The Application class to test the feature
	private class TestApplication
	{
		public fflib_BindingResolver EventListenerBindings =
				new fflib_ClassicBindingResolver(
						new Map<Type, Type>
						{
								OnChangedAccountSanitizer.class => OnChangedAccountSanitizerImp.class
						}
				);

		public fflib_ApplicationEventEmitter eventEmitter =
				new fflib_ApplicationEventEmitterImp(
						'MyNameSpace',
						EventListenerSelector.class,
						EventListenerBindings
				);
	}
}