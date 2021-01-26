/**
 * File Name: ffib_SelectorFactoryImp
 * Description: Selector Binding Resolver using Force-DI
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
public virtual with sharing class fflib_ForceDiSelectorBindingResolver
		implements fflib_ISelectorBindingResolver
{
	private static final String BINDING_NAME_IDENTIFIER = '.selector.';

	protected String appName;

	public fflib_ForceDiSelectorBindingResolver(String appName)
	{
		this.appName = appName.toLowerCase();
	}

	/**
	 * Creates a new instance of the associated Apex Class implementing fflib_ISObjectSelector
	 *   for the given SObjectType, or if provided via setMock returns the Mock implementation
	 *
	 * @param sObjectType An SObjectType token, e.g. Account.SObjectType
	 *
	 * @return Instance of the selector implementation
	 **/
	public fflib_ISObjectSelector newInstance(Schema.SObjectType sObjectType)
	{
		return (fflib_ISObjectSelector) di_Injector.Org.getInstance(
				getBindingName(sObjectType)
		);
	}

	/**
	 * Replaces the linked implementation for the Apex interface.
	 *
	 * @param sObjectType The SObjectType for the new implementation
	 * @param mockType The replacement implementation name or Instance
	 */
	public void replaceWith(Schema.SObjectType sObjectType, Object mockType)
	{
		di_Injector.Org.Bindings.byName(getBindingName(sObjectType)).replaceBindingWith(mockType);
	}

	/**
	 * Helper method to query the given SObject records
	 *   Internally creates an instance of the registered Selector and calls its
	 *     selectSObjectById method
	 *
	 * @param recordIds The SObject record Ids, must be all the same SObjectType
	 *
	 * @throws DeveloperException
	 *
	 * @return List of retrieved records
	 **/
	public List<SObject> selectById(Set<Id> recordIds)
	{
		// No point creating an empty Domain class, nor can we determine the SObjectType anyway
		if (recordIds == null || recordIds.size() == 0)
		{
			// todo - convert to label
			throw new DeveloperException('Label.fflib_InvalidRecordIdSet');
		}

		// Determine SObjectType
		Schema.SObjectType domainSObjectType = new List<Id>(recordIds)[0].getSobjectType();
		for (Id recordId : recordIds)
		{
			if (recordId.getSobjectType() != domainSObjectType)
			{
				// todo - convert to label
				throw new DeveloperException('Label.fflib_SetContainsIdsFromDifferentSObjectTypes');
			}
		}

		// Construct Selector class and query by Id for the records
		return newInstance(domainSObjectType).selectSObjectsById(recordIds);
	}

	/**
	 * Helper method to query related records to those provided, for example
	 *   if passed a list of Opportunity records and the Account Id field will
	 *   construct internally a list of Account Ids and call the registered
	 *   Account selector to query the related Account records, e.g.
	 * <p/>
	 *     List<Account> accounts =
	 *        (List<Account>) Application.Selector.selectByRelationship(myOpportunities, Opportunity.AccountId);
	 *
	 * @param relatedRecords used to extract the related record Ids, e.g. Opportunity records
	 * @param relationshipField field in the passed records that contains the relationship records to query, e.g. Opportunity.AccountId
	 *
	 * @return List of retrieved records
	 **/
	public List<SObject> selectByRelationship(List<SObject> relatedRecords, SObjectField relationshipField)
	{
		Set<Id> relatedIds = new Set<Id>();
		for (SObject relatedRecord : relatedRecords)
		{
			Id relatedId = (Id) relatedRecord.get(relationshipField);
			if (relatedId != null)
			{
				relatedIds.add(relatedId);
			}
		}
		return selectById(relatedIds);
	}

	// @Deprecated - only available for backwards compatibility
	public void setMock(fflib_ISObjectSelector selectorImp)
	{
		System.debug(System.LoggingLevel.WARN, 'setMock is deprecated and replaced for replaceWith');
		replaceWith(
				((fflib_ISObjectSelector) selectorImp).sObjectType(),
				selectorImp
		);
	}

	private String getBindingName(Schema.SObjectType sObjectType)
	{
		return this.appName + BINDING_NAME_IDENTIFIER + sObjectType.getDescribe().getName();
	}

	public class DeveloperException extends Exception { }
}