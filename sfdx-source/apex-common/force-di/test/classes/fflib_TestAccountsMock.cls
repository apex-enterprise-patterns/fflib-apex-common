/**
 * File Name: fflib_TestAccounts
 * Description: Mock Accounts Domain class to be used in unit-tests
 * @author: architect ir. Wilhelmus G.J. Velzeboer
 */
@IsTest
public class fflib_TestAccountsMock extends fflib_SObjectDomain
{
	public fflib_TestAccountsMock(List<Account> records)
	{
		super(records);
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable2
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new fflib_TestAccountsMock(sObjectList);
		}

		public fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sObjectType)
		{
			return new fflib_TestAccountsMock(sObjectList);
		}
	}
}