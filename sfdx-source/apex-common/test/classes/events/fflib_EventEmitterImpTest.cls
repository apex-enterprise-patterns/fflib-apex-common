/**
 * File Name: fflib_EventEmitterImpTest
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
@IsTest(IsParallel=true)
private class fflib_EventEmitterImpTest
{
	private static final String EVENT_NAME = 'MyEvent';

	private static Boolean priorityEventExecutedFirst = false;

	private static fflib_IEvent capturedEvent;

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
		fflib_IEventEmitter eventEmitter = new fflib_EventEmitterImp();
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
		fflib_IEventEmitter eventEmitter = new fflib_EventEmitterImp();
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
		fflib_IEventEmitter eventEmitter = new fflib_EventEmitterImp();
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
		fflib_IEventEmitter eventEmitter = new fflib_EventEmitterImp();
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
		fflib_IEventEmitter eventEmitter = new fflib_EventEmitterImp();
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
		fflib_IEventEmitter eventEmitter = new fflib_EventEmitterImp();
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

	private class EventListener implements fflib_IEventListener
	{
		public void handle(fflib_IEvent event)
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

	private class PriorityEventListener implements fflib_IEventListener
	{
		public void handle(fflib_IEvent event)
		{
			if (capturedEvent == null)
			{
				priorityEventExecutedFirst = true;
			}
			capturedEvent = event;
		}
	}
}