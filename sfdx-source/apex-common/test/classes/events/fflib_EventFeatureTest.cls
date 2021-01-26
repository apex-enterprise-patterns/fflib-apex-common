/**
 * File Name: fflib_EventFeatureTest
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
	private interface OnChangedAccountSanitizer extends fflib_IEventListener
	{	}

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
	private class EventListenerSelector implements fflib_IEventListenerSelector
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
		public fflib_IBindingResolver EventListenerBindings =
				new fflib_ClassicBindingResolver(
						new Map<Type, Type>
						{
								OnChangedAccountSanitizer.class => OnChangedAccountSanitizerImp.class
						}
				);

		public fflib_IApplicationEventEmitter eventEmitter =
				new fflib_ApplicationEventEmitterImp(
						'MyNameSpace',
						EventListenerSelector.class,
						EventListenerBindings
				);
	}
}