/**
 * Copyright (c), FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors
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
**/
public interface fflib_ISelectorFactory
{
	/**
	 * Creates a new instance of the associated Apex Class implementing fflib_ISObjectSelector
	 *   for the given SObjectType, or if provided via setMock returns the Mock implementation
	 *
	 * @param sObjectType An SObjectType token, e.g. Account.SObjectType
	 *
	 * @return Instance of fflib_ISObjectSelector
	 **/
	fflib_ISObjectSelector newInstance(SObjectType sObjectType);

	/**
	 * Helper method to query the given SObject records
	 *   Internally creates an instance of the registered Selector and calls its
	 *     selectSObjectById method
	 *
	 * @param recordIds The SObject record Ids, must be all the same SObjectType
	 * @exception Is thrown if the record Ids are not all the same or the SObjectType is not registered
	 *
	 * @return List of queried records
	 **/
	List<SObject> selectById(Set<Id> recordIds);

	/**
	 * Helper method to query related records to those provided, for example
	 *   if passed a list of Opportunity records and the Account Id field will
	 *   construct internally a list of Account Ids and call the registered
	 *   Account selector to query the related Account records, e.g.
	 *
	 *     List<Account> accounts =
	 *        (List<Account>) Application.Selector.selectByRelationship(myOpps, Opportunity.AccountId);
	 *
	 * @param relatedRecords used to extract the related record Ids, e.g. Opportunity records
	 * @param relationshipField field in the passed records that contains the relationship records to query, e.g. Opportunity.AccountId
	 *
	 * @return List of queried records
	 **/
	List<SObject> selectByRelationship(List<SObject> relatedRecords, SObjectField relationshipField);

	/**
	 * Creates or replaces an existing binding for another
	 *
	 * @param sObjectType The SObjectType of the selector to replace
	 * @param replacementImplType The implementation type of the replacement
	 */
	void replaceWith(Schema.SObjectType sObjectType, Type replacementImplType);
}