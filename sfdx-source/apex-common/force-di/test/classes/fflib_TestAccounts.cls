/**
 * File Name: fflib_TestAccounts 
 * Description: Accounts Domain class to be used in unit-tests
 * @author: architect ir. Wilhelmus G.J. Velzeboer
 */
@IsTest
public class fflib_TestAccounts extends fflib_SObjectDomain
{
	public fflib_TestAccounts(List<Account> records)
	{
		super(records);
	}

	public class InvalidConstructor
	{
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable2
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new fflib_TestAccounts(sObjectList);
		}

		public fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sObjectType)
		{
			return new fflib_TestAccounts(sObjectList);
		}
	}

	public class LegacyConstructor implements fflib_SObjectDomain.IConstructable
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new fflib_TestAccounts(sObjectList);
		}
	}
}