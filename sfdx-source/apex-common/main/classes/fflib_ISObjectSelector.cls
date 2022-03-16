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

public interface fflib_ISObjectSelector
{
	/**
	 * Set the selector to enforce FLS Security
	 */
	fflib_ISObjectSelector enforceFLS();

	/**
	 * Set the selector to ignore CRUD security
	 */
	fflib_ISObjectSelector ignoreCRUD();

	/**
     * Set the selector to automatically include the FieldSet fields when building queries
    **/
	fflib_ISObjectSelector includeFieldSetFields();

	/**
	 * Provides the SObjectType for the object the given Selector is providing query logic for
	 **/
	Schema.SObjectType sObjectType();

	/**
	 * Selects by Id records using the fields defined by the Selector configuration
	 **/
	List<SObject> selectSObjectsById(Set<Id> idSet);

	/**
     * Sets the default limit for all queries executed by the selector
     */
	fflib_ISObjectSelector setLimit(Integer queryLimit);

	/**
     * Sets the default offset for all queries executed by the selector
	 */
	fflib_ISObjectSelector setOffset(Integer queryOffset);

	/**
	 * Prevents the fields from being sorted
	 */
	fflib_ISObjectSelector unsortedSelectFields();

	/**
	 * Overwrites the selector class level Ordering
    */
	fflib_ISObjectSelector setOrdering(fflib_QueryFactory.Ordering ordering);
	fflib_ISObjectSelector setOrdering(List<fflib_QueryFactory.Ordering> ordering);
}