/**
 * File Name: fflib_EventEmitterImpTest
 * Description:
 *
 * @author : architect ir. Wilhelmus G.J. Velzeboer | wvelzebo@its.jnj.com
 */
@IsTest(IsParallel=true)
private class fflib_EventEmitterImpTest
{
	private static final String EVENT_NAME = 'MyEvent';

	private static Boolean priorityEventExecutedFirst = false;

	private static fflib_Event capturedEvent;

	@IsTest
	static void itShouldAddEventListeners()
	{
		// GIVEN an EventEmitter and a listener
		fflib_EventEmitterImp eventEmitter = new fflib_EventEmitterImp();

		// WHEN we add a listener for an event
		eventEmitter.addListener(EVENT_NAME, EventListener.class);

		// THEN the listener should be available
		List<fflib_EventListenerConfig> eventListeners =
				eventEmitter.getListeners(EVENT_NAME);
		System.assertEquals(1, eventListeners.size(), 'Incorrect amount of event listeners');
		System.assertEquals(
				EventListener.class, eventListeners.get(0).getListenerType(),
				'Incorrect returned event listener');
	}

	@IsTest
	static void itShouldAddListenerForEventAndHandleIt()
	{
		// GIVEN an registered Event Listener
		fflib_EventEmitter eventEmitter = new fflib_EventEmitterImp();
		eventEmitter.addListener(EVENT_NAME, EventListener.class);

		// WHEN the event is emitted for the listener
		eventEmitter.emit(EVENT_NAME);

		// THEN the listener should be executed
		System.assert(capturedEvent != null, 'No event was captured');
		System.assertEquals(EVENT_NAME, capturedEvent.getName(), 'Incorrect captured event');
	}

	@IsTest
	static void itShouldCallListenerWithTheEventData()
	{
		// GIVEN an registered Event Listener and some event data
		fflib_EventEmitter eventEmitter = new fflib_EventEmitterImp();
		eventEmitter.addListener(EVENT_NAME, EventListener.class);
		String eventData = 'Hello World';

		// WHEN the event is emitted for the listener
		eventEmitter.emit(EVENT_NAME, eventData);

		// THEN the listener should be executed
		System.assert(capturedEvent != null, 'No event was captured');
		System.assertEquals(EVENT_NAME, capturedEvent.getName(), 'Incorrect captured event');
		System.assertEquals(eventData, (String) capturedEvent.getData(), 'Incorrect event data');
	}

	@IsTest
	static void itShouldCallListenerWithHigherPriorityFirst()
	{
		// GIVEN two registered Event Listeners one with a higher priority
		fflib_EventEmitter eventEmitter = new fflib_EventEmitterImp();
		eventEmitter.addListener(EVENT_NAME, EventListener.class);
		eventEmitter.addListener(EVENT_NAME, EventListener.class).setPriority(5);
		eventEmitter.addListener(EVENT_NAME, PriorityEventListener.class).setPriority(10);

		// WHEN the event is emitted for the listener
		eventEmitter.emit(EVENT_NAME);

		// THEN the priority listener should be executed first
		System.assert(priorityEventExecutedFirst, 'Whoops, Priority Event Listener was not the first to be executed');
	}

	@IsTest
	static void itShouldRemoveListenerFromEvent()
	{
		// GIVEN two registered Event Listeners
		fflib_EventEmitter eventEmitter = new fflib_EventEmitterImp();
		eventEmitter.addListener(EVENT_NAME, EventListener.class);
		eventEmitter.addListener(EVENT_NAME, PriorityEventListener.class).setPriority(10);

		// WHEN Priority Event listener is removed and the event is emitted
		eventEmitter.removeListener(EVENT_NAME, PriorityEventListener.class);
		eventEmitter.emit(EVENT_NAME);

		// THEN the priority event should not have been executed
		System.assert(!priorityEventExecutedFirst, 'The removed Event Listener was still executed');
		System.assertEquals(EVENT_NAME, capturedEvent.getName(), 'Incorrect captured event');
	}

	@IsTest
	static void itShouldRemoveAllListenersForEvent()
	{
		// GIVEN three registered Event Listeners, two of them are for the tested event.
		fflib_EventEmitter eventEmitter = new fflib_EventEmitterImp();
		eventEmitter.addListener(EVENT_NAME, EventListener.class);
		eventEmitter.addListener(EVENT_NAME, PriorityEventListener.class).setPriority(10);

		// WHEN Priority Event listener is removed and the event is emitted
		eventEmitter.removeAllListeners(EVENT_NAME);
		eventEmitter.emit(EVENT_NAME);

		// THEN the priority event should not have been executed
		System.assertEquals(null, capturedEvent, 'Here should not be an event listener');
	}

	@IsTest
	static void itShouldRunAListenerInQueue()
	{
		// GIVEN a registered Event Listeners to execute in a queue
		fflib_EventEmitter eventEmitter = new fflib_EventEmitterImp();
		eventEmitter.addListener(EVENT_NAME, QueueableEventListener.class).setRunInQueue();

		// WHEN the event is invoked (excluding Queueable Apex)
		eventEmitter.emit(EVENT_NAME);

		// THEN the event should not be triggered in this execution context
		System.assertEquals(null, capturedEvent, 'Here should not be an event listener');

		// WHEN the event is invoked including Queueable Apex
		System.Test.startTest();
		eventEmitter.emit(EVENT_NAME);
		System.Test.stopTest();

		// THEN the event should be triggered
		System.assertNotEquals(null, capturedEvent, 'Here should not be an event listener');
	}

	private class EventListener implements fflib_EventListener
	{
		public void handle(fflib_Event event)
		{
			capturedEvent = event;
		}
	}

	private class QueueableEventListener extends fflib_QueueableEventListener
	{
		public void run()
		{
			capturedEvent = this.event;
		}
	}

	private class PriorityEventListener implements fflib_EventListener
	{
		public void handle(fflib_Event event)
		{
			if (capturedEvent == null)
			{
				priorityEventExecutedFirst = true;
			}
			capturedEvent = event;
		}
	}
}