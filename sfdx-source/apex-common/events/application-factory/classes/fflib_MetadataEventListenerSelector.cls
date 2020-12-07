/**
 * File Name: fflib_MetadataEventListenerSelector
 * Description:
 *
 * @author : architect ir. Wilhelmus G.J. Velzeboer | wvelzebo@its.jnj.com
 */
public virtual with sharing class fflib_MetadataEventListenerSelector
		extends fflib_SObjectSelector
		implements fflib_EventListenerSelector
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