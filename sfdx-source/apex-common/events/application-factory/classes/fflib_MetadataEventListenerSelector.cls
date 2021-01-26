/**
 * File Name: fflib_MetadataEventListenerSelector
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
public virtual with sharing class fflib_MetadataEventListenerSelector
		extends fflib_SObjectSelector
		implements fflib_IEventListenerSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				fflib_EventListener__mdt.Id,
				fflib_EventListener__mdt.AppName__c,
				fflib_EventListener__mdt.DeveloperName,
				fflib_EventListener__mdt.EventName__c,
				fflib_EventListener__mdt.InterfaceType__c,
				fflib_EventListener__mdt.NamespacePrefix,
				fflib_EventListener__mdt.Priority__c,
				fflib_EventListener__mdt.QualifiedApiName,
				fflib_EventListener__mdt.QueuedAction__c
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return fflib_EventListener__mdt.sObjectType;
	}

	public List<fflib_EventListenerConfig> getEventListeners(String namespace, String eventName)
	{
		List<fflib_EventListener__mdt> eventListeners = selectByNamespaceAndName(namespace, eventName);
		return getEventListenerConfigs(eventListeners);
	}

	private List<fflib_EventListenerConfig> getEventListenerConfigs(List<fflib_EventListener__mdt> eventListeners)
	{
		List<fflib_EventListenerConfig> result = new List<fflib_EventListenerConfig>();
		for (fflib_EventListener__mdt eventListener : eventListeners)
		{
			System.Type interfaceType = getInterfaceType(eventListener);
			result.add(
					new fflib_EventListenerConfig(interfaceType)
							.setRunInQueue(eventListener.QueuedAction__c)
							.setPriority(Integer.valueOf(eventListener.Priority__c))
			);
		}
		return result;
	}

	private Type getInterfaceType(fflib_EventListener__mdt eventListener)
	{
		try
		{
			Type result = Type.forName(eventListener.InterfaceType__c);
			return result;
		}
		catch (Exception e)
		{
			throw new fflib_MetadataEventListenerSelectorException('Whoops...');
			// todo - error handling
		}
	}

	private List<fflib_EventListener__mdt> selectByNamespaceAndName(String namespace, String eventName)
	{
		List<fflib_EventListener__mdt> result =
				(List<fflib_EventListener__mdt>) Database.query(
						newQueryFactory()
								.setCondition('NamespacePrefix = :namespace AND EventName__c = :eventName')
								.toSOQL()
				);
		result.addAll(
				(List<fflib_EventListener__mdt>) Database.query(
						newQueryFactory()
								.setCondition('AppName__c = :namespace AND EventName__c = :eventName')
								.toSOQL()
				)
		);
		return result;
	}

	public class fflib_MetadataEventListenerSelectorException extends Exception
	{
	}
}