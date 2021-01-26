/**
 * File Name: fflib_ApplicationEventsEmitterImp
 * Description: Implementation of the Application Events Emitter
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
public with sharing class fflib_ApplicationEventEmitterImp
		extends fflib_EventEmitterImp
		implements fflib_IApplicationEventEmitter
{
	private fflib_IBindingResolver bindingResolver;
	private Boolean disabled = false;
	private String namespace;
	private System.Type selectorType;

	private fflib_IEventListenerSelector selector
	{
		get
		{
			if (selector == null)
			{
				Object selectorInstance = selectorType.newInstance();
				if (!(selectorInstance instanceof fflib_IEventListenerSelector))
				{
					throw new fflib_ApplicationEventEmitterException(
							'Event Listener Selector should be an implementation of fflib_EventListenerSelector'
					);
				}
				selector = (fflib_IEventListenerSelector) selectorInstance;
			}
			return selector;
		}
		private set;
	}

	/**
	 * Class constructor
	 */
	public fflib_ApplicationEventEmitterImp(String namespace, System.Type selectorClassType)
	{
		this(namespace, selectorClassType, null);
	}

	public fflib_ApplicationEventEmitterImp(
			String namespace,
			System.Type selectorClassType,
			fflib_IBindingResolver bindingResolver)
	{
		this.namespace = namespace;
		this.selectorType = selectorClassType;
		this.bindingResolver = bindingResolver;
	}

	/**
	 * Disables the event resolver,
	 * particular useful in the context of unit-test to avoid execution of the event listeners
	 */
	public void disableAll()
	{
		this.disabled = true;
	}

	public override void emit(fflib_IEvent event)
	{
		if (disabled) return;

		String eventName = event.getName();
		if (isNonExistingEvent(eventName))
		{
			loadEventListeners(eventName);
		}

		super.emit(event);
	}

	public void enableAll()
	{
		this.disabled = false;
	}

	protected override Object getListenerInstance(fflib_EventListenerConfig listener)
	{
		return bindingResolver.newInstance(listener.getListenerType());
	}

	private void loadEventListeners(String eventName)
	{
		List<fflib_EventListenerConfig> eventListenerConfigs = selector.getEventListeners(namespace, eventName);
		addListeners(eventName, eventListenerConfigs);
	}

	public class fflib_ApplicationEventEmitterException extends Exception {}
}