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
public interface fflib_IDomainFactory
{
	/**
	 * Dynamically constructs an instance of a Domain class for the given record Ids
	 *   Internally uses the Selector Factory to query the records before passing to a
	 *   dynamically constructed instance of the application Apex Domain class
	 *
	 * @param recordIds A list of Id's of the same type
	 * @exception Throws an exception via the Selector Factory if the Ids are not all of the same SObjectType
	 *
	 * @return Instance of the Domain
	 **/
	fflib_IDomain newInstance(Set<Id> recordIds);

	/**
	 * Dynamically constructs an instance of the Domain class for the given records
	 *   Will return a Mock implementation if one has been provided via setMock
	 *
	 * @param records A concrete list of records, e.g.; `List<Account>` or `List<SObject>`)
	 *
	 * @exception Throws an exception if the SObjectType cannot be determined from the list
	 *              or the constructor for Domain class was not registered for the SObjectType
	 *
	 * @return Instance of the Domain containing the given records
	 **/
	fflib_IDomain newInstance(List<SObject> records);

	/**
	 * Dynamically constructs an instance of the Domain class for the given records
	 *   Will return a Mock implementation if one has been provided via setMock
	 *
	 * @param objects A concrete list of Objects, e.g.; `List<Account>` or `List<SObject>`)
	 * @param objectType
	 *
	 * @exception Throws an exception if the SObjectType cannot be determined from the list
	 *              or the constructor for Domain class was not registered for the SObjectType
	 *
	 * @return Instance of the Domain containing the given Objects
	 **/
	fflib_IDomain newInstance(List<Object> objects, Object objectType);

	/**
	 * Dynamically constructs an instance of the Domain class for the given records and SObjectType
	 *   Will return a Mock implementation if one has been provided via setMock
	 *
	 * @param records A list records
	 * @param domainSObjectType SObjectType for list of records
	 *
	 * @exception Throws an exception if the SObjectType is not specified or if constructor for Domain class was not registered for the SObjectType
	 *
	 * @remark Will support List<SObject> but all records in the list will be assumed to be of
	 *         the type specified in sObjectType
	 *
	 * @return Instance of the Domain containing the given records
	 **/
	fflib_IDomain newInstance(List<SObject> records, SObjectType domainSObjectType);

	/**
	 * Creates or replaces an existing binding for another
	 *
	 * @param sObjectType The SObjectType of the domain to replace
	 * @param replacementImplType The implementation type of the replacement
	 */
	void replaceWith(Schema.SObjectType sObjectType, Type replacementImplType);
}