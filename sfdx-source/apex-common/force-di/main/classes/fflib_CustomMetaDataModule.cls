/**
 * File Name: fflib_di_CustomMetaDataModule
 * Description: Dependency Injection module to register the bindings
 *
 * @author : architect ir. Wilhelmus G.J. Velzeboer
 */
public with sharing class fflib_CustomMetaDataModule extends di_Module
{
	private static final String SELECTOR = 'Selector';
	private static final String SERVICE = 'Service';
	private static final String DOMAIN = 'Domain';
	private static final String APEX = 'Apex';
	private static final String SEPARATOR = '.';

	/**
	 * Iterates through the bindings and register them to force-di
	 */
	public override void configure()
	{
		for (fflib_Binding__mdt binding : new fflib_BindingsSelector().selectAll())
		{
			bind(getName(binding));
			data(binding);
			to(binding.To__c);
		}
	}

	private String getName(fflib_Binding__mdt binding)
	{
		switch on binding.Type__c.toUpperCase()
		{
			when 'SELECTOR'
			{
				return getSelectorName(binding);
			}
			when 'DOMAIN'
			{
				return getDomainName(binding);
			}
			when else
			{
				return getServiceName(binding);
			}
		}
	}

	private String getSelectorName(fflib_Binding__mdt binding)
	{
		return getAppName(binding) + SEPARATOR + SELECTOR + SEPARATOR + getKeyPrefix(binding);
	}

	private String getAppName(fflib_Binding__mdt binding)
	{
		return binding.AppName__c.trim().toLowerCase();
	}

	private String getDomainName(fflib_Binding__mdt binding)
	{
		return binding.AppName__c + SEPARATOR + DOMAIN + SEPARATOR + getKeyPrefix(binding);
	}

	private String getKeyPrefix(fflib_Binding__mdt binding)
	{
		assertForConfiguredSObjectType(binding);

		String bindingObjectApiName = getBindingObjectName(binding);

		Schema.DescribeSObjectResult[] results = Schema.describeSObjects(new String[] {bindingObjectApiName});
		if (results.size() != 1)
		{
			throw new CustomMetaDataModuleException(
					'Failed to find SObject ' + bindingObjectApiName +
							' referenced by binding ' + binding.DeveloperName);
		}
		return results.get(0).getSObjectType().getDescribe().getKeyPrefix();
	}

	private String getBindingObjectName(fflib_Binding__mdt binding)
	{
		if (String.isNotBlank(binding.BindingObject__c))
		{
			return binding.BindingObject__r.QualifiedApiName.trim().toLowerCase();
		}
		else
		{
			return binding.BindingObjectAlternate__c.trim().toLowerCase();
		}
	}

	private void assertForConfiguredSObjectType(fflib_Binding__mdt binding)
	{
		if (String.isBlank(binding.BindingObject__c)
				|| String.isBlank(binding.BindingObjectAlternate__c))
		{
			throw new CustomMetaDataModuleException('No SObject configured for binding ' + binding.DeveloperName);
		}
	}


	private String getServiceName(fflib_Binding__mdt binding)
	{
		return binding.DeveloperName;
	}


	public class CustomMetaDataModuleException extends Exception {}
}