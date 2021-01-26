/**
 * File Name: fflib_EventEmitterImp
 * Description: Implementation of the Events Emitter
 *
 * @author : architect ir. Wilhelmus G.J. Velzeboer

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above author notice,
this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.
- Neither the name of the author nor the names of its contributors
may be used to endorse or promote products derived from this software without
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
public virtual with sharing class fflib_EventEmitterImp implements fflib_IEventEmitter
{
	protected final Map<String, List<fflib_EventListenerConfig>> eventListenerMap =
			new Map<String, List<fflib_EventListenerConfig>>();

	/**
	 * Class constructor
	 */
	public fflib_EventEmitterImp()
	{
	}

	/**
	 * Add a new listener for a given event name
	 *
	 * @param eventName The event name of the listener
	 * @param listener The class object type of the listener
	 *
	 * @return Returns an instance of fflib_EventEmitter to allow for method chaining
	 */
	public virtual fflib_EventListenerConfig addListener(String eventName, Type listener)
	{
		registerEvent(eventName);
		fflib_EventListenerConfig listenerConfig = new fflib_EventListenerConfig(listener);
		registerEventListener(eventName, listenerConfig);
		return listenerConfig;
	}

	/**
	 * Adds multiple listener for a given event name
	 *
	 * @param eventName The event name of the listeners
	 * @param eventListenerConfigs The configured listeners to add
	 */
	public void addListeners(String eventName, List<fflib_EventListenerConfig> eventListenerConfigs)
	{
		registerEvent(eventName);
		eventListenerMap.get(eventName).addAll(eventListenerConfigs);
	}

	/**
	 * Removes a single listener from listening to an event
	 *
	 * @param eventName The event name of the listener to remove
	 * @param listener The class type of the listener
	 */
	public virtual void removeListener(String eventName, Type listener)
	{
		if (isNonExistingEvent(eventName)) return;

		List<fflib_EventListenerConfig> listenerConfigs = eventListenerMap.get(eventName);
		for (Integer i = 0; i < listenerConfigs.size(); i++)
		{
			if (listenerConfigs.get(i).getListenerType() == listener)
			{
				listenerConfigs.remove(i);
				break;
			}
		}
	}

	/**
	 * Removes all listeners for the given event
	 *
	 * @param eventName The event name for which all listener should be removed
	 */
	public virtual void removeAllListeners(String eventName)
	{
		if (isNonExistingEvent(eventName)) return;
		eventListenerMap.put(eventName, new List<fflib_EventListenerConfig>());
	}

	/**
	 * Emits an event without payload data
	 *
	 * @param eventName The name of the event to emit
	 *
	 * @throws EventEmitterException
	 */
	public virtual void emit(String eventName)
	{
		emit(new fflib_ApexEvent(eventName));
	}

	/**
	 * Emits an event with payload data
	 *
	 * @param eventName The name of the event to emit
	 * @param eventData The payload data
	 *
	 * @throws EventEmitterException
	 */
	public virtual void emit(String eventName, Object eventData)
	{
		emit(new fflib_ApexEvent(eventName, eventData));
	}

	/**
	 * Emits the given event
	 *
	 * @param event The event to emit
	 *
	 * @throws EventEmitterException
	 */
	public virtual void emit(fflib_IEvent event)
	{
		String eventName = event.getName();
		System.debug(System.LoggingLevel.INFO, eventName + ' event emitted');
		List<fflib_EventListenerConfig> listeners = getListeners(eventName);
		callListeners(listeners, event);
	}

	/**
	 * Asserts that the given instance is an implementation of fflib_EventListener otherwise it throws an exception
	 *
	 * @param listenerInstance The class instance to validate
	 * @param listenerConfig The listener configuration
	 *
	 * @throws EventEmitterException
	 */
	protected void assertForListenerImplementationType(
			Object listenerInstance,
			fflib_EventListenerConfig listenerConfig)
	{
		if (!(listenerInstance instanceof fflib_IEventListener))
		{
			throw new EventEmitterException(
					String.format(
							'{0} should be an implementation of fflib_EventListener',
							new List<String> {listenerConfig.getListenerType().getName()}
					)
			);
		}
	}

	/**
	 * Calls the listeners to handle the given event
	 *
	 * @param listeners The EventListenerType for the listeners
	 * @param event The Event to be handled
	 *
	 * @throws EventEmitterException
	 */
	protected void callListeners(List<fflib_EventListenerConfig> listeners, fflib_IEvent event)
	{
		for (fflib_EventListenerConfig listener : listeners)
		{
			callListener(listener, event);
		}
	}

	/**
	 * Calls the listener to handle the given event
	 *
	 * @param listener The EventListenerType
	 * @param event The Event to be handled
	 *
	 * @throws EventEmitterException
	 */
	protected void callListener(fflib_EventListenerConfig listener, fflib_IEvent event)
	{
		Object listenerInstance = getListenerInstance(listener);

		assertForListenerImplementationType(listenerInstance, listener);

		configureListener(listener, listenerInstance);

		((fflib_IEventListener) listenerInstance)
				.handle(event);
	}

	protected virtual Object getListenerInstance(fflib_EventListenerConfig listener)
	{
		return listener.getListenerType().newInstance();
	}

	protected void configureListener(fflib_EventListenerConfig listener, Object listenerInstance)
	{
		configureQueueableListener(listenerInstance, listener);
	}

	private void configureQueueableListener(Object listenerInstance, fflib_EventListenerConfig listener)
	{
		if (isQueueable(listenerInstance) && listener.isRunInQueue())
		{
			((fflib_QueueableEventListener) listenerInstance).setRunAsQueueable();
		}
	}

	private Boolean isQueueable(Object listenerInstance)
	{
		return (listenerInstance instanceof fflib_QueueableEventListener);
	}

	/**
	 * Gets a list or all the listeners for the given event name
	 *
	 * @param eventName The event name of the listeners to return
	 *
	 * @return List of listeners by priority in descending order
	 */
	@TestVisible
	protected List<fflib_EventListenerConfig> getListeners(String eventName)
	{
		List<fflib_EventListenerConfig> result = new List<fflib_EventListenerConfig>();
		if (!eventListenerMap.containsKey(eventName)) return result;

		result.addAll(eventListenerMap.get(eventName));
		result.sort();
		return result;
	}

	/**
	 * Checks if the given eventName is already registered
	 *
	 * @param eventName The name of the event to check
	 *
	 * @return True if the eventName already exists
	 */
	protected Boolean isExistingEvent(String eventName)
	{
		return this.eventListenerMap.containsKey(eventName);
	}

	/**
	 * Checks if the given eventName is not already registered
	 *
	 * @param eventName The name of the event to check
	 *
	 * @return True if the eventName does not already exists
	 */
	protected Boolean isNonExistingEvent(String eventName)
	{
		return !isExistingEvent(eventName);
	}

	/**
	 * Make sure the given eventName is registered in the Map of Listeners.
	 *
	 * @param eventName The Name of the event to register
	 */
	protected void registerEvent(String eventName)
	{
		if (isExistingEvent(eventName)) return;

		eventListenerMap.put(
				eventName,
				new List<fflib_EventListenerConfig>()
		);
	}

	/**
	 * Registers the listener for the given eventName and priority
	 *
	 * @param eventName The name of the Event of the listener
	 * @param listenerConfig The configured event listener
	 */
	protected void registerEventListener(
			String eventName,
			fflib_EventListenerConfig listenerConfig)
	{
		eventListenerMap
				.get(eventName)
				.add(listenerConfig);
	}

	public class EventEmitterException extends Exception
	{
	}
}