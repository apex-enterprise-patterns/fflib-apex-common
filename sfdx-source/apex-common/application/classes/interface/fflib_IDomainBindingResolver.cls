/**
 * File Name: fflib_DomainBindingResolver 
 * Description: Interface for resolving domain class bindings
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
public interface fflib_IDomainBindingResolver
{
	/**
	 * Dynamically constructs an instance of a Domain class for the given record Ids
	 *   Internally uses the Selector Factory to query the records before passing to a
	 *   dynamically constructed instance of the application Apex Domain class
	 *
	 * @param recordIds A list of Id's of the same type
	 *
	 * @return Instance of fflib_Domain containing the record with the provided Ids
	 **/
	fflib_IDomain newInstance(Set<Id> recordIds);

	/**
	 * Dynamically constructs an instance of the Domain class for the given records
	 *   Will return a Mock implementation if one has been provided via setMock
	 *
	 * @param records A concrete list (e.g. List<Account> vs List<SObject>) of records
	 *
	 * @return Instance of fflib_Domain containing the provided records
	 **/
	fflib_IDomain newInstance(List<SObject> records);

	/**
	 * Dynamically constructs an instance of the Domain class for the given records and SObjectType
	 *   Will return a Mock implementation if one has been provided via setMock
	 *
	 * @param records A list records
	 * @param domainSObjectType SObjectType for list of records
	 *
	 * @return Instance of fflib_Domain containing the provided records
	 **/
	fflib_IDomain newInstance(List<SObject> records, SObjectType domainSObjectType);

	/**
	 * Dynamically constructs an instance of the Domain class for the given records and SObjectType
	 *   Will return a Mock implementation if one has been provided via setMock
	 *
	 * @param objects A list objects
	 * @param objectType ObjectType for list of objects
	 *
	 * @return Instance of fflib_Domain containing the provided objects
	 **/
	fflib_IDomain newInstance(List<Object> objects, Object objectType);

	/**
	 * Replaces the implementation of the given domain
	 *
	 * @param domainImplementation The replacement implementation for the given interface type
	 *    this should be the domain Constructor which is an implementation of fflib_SObjectDomainConstructor
	 */
	void replaceWith(fflib_IDomain domainImplementation);

	/**
	 * Replaces the linked implementation for the Apex interface.
	 *
	 * @param domainType The interface type for this new implementation
	 * @param domainConstructorImplementationType The replacement implementation type for the given interface type
	 *    this should be the domain Constructor which is an implementation of fflib_SObjectDomainConstructor
	 */
	void replaceWith(Object domainType, Object domainConstructorImplementationType);

	/**
	 * Replaces the linked implementation for a mocked implementation, used in unit-test
	 *
	 * @param mockDomain The mock instance for the given interface type
	 */
	void setMock(fflib_IDomain mockDomain);
}