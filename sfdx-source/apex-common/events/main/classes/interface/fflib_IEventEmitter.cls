/**
 * File Name: fflib_EventEmitter
 * Description: Interface for the Events Emitter
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
public interface fflib_IEventEmitter
{
	/**
	 * Add a new listener for a given event name
	 *
	 * @param eventName The event name of the listener
	 * @param listener The class object type of the listener
	 *
	 * @return Returns an instance of fflib_EventEmitter to allow for method chaining
	 */
	fflib_EventListenerConfig addListener(String eventName, Type listener);

	/**
	 * Adds multiple listener for a given event name
	 *
	 * @param eventName The event name of the listeners
	 * @param eventListenerConfigs The configured listeners to add
	 */
	void addListeners(String eventName, List<fflib_EventListenerConfig> eventListenerConfigs);

	/**
	 * Removes a single listener from listening to an event
	 *
	 * @param eventName  The event name of the listener to remove
	 * @param listener The class type of the listener
	 */
	void removeListener(String eventName, Type listener);

	/**
	 * Removes all listeners for the given event
	 *
	 * @param eventName The event name for which all listener should be removed
	 */
	void removeAllListeners(String eventName);

	/**
	 * Emits an event without payload data
	 *
	 * @param eventName The name of the event to emit
	 */
	void emit(String eventName);

	/**
	 * Emits an event with payload data
	 *
	 * @param eventName The name of the event to emit
	 * @param eventData The payload data
	 */
	void emit(String eventName, Object eventData);

	/**
	 * Emits the given event
	 *
	 * @param event The event to emit
	 */
	void emit(fflib_IEvent event);
}