/**
 * Copyright (c) 2012, FinancialForce.com, inc
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

/**
 * Base class aiding in the implemetnation of a Domain Model around SObject collections
 *
 * Domain (software engineering). “a set of common requirements, terminology, and functionality
 * for any software program constructed to solve a problem in that field”,
 * http://en.wikipedia.org/wiki/Domain_(software_engineering)
 *
 * Domain Model, “An object model of the domain that incorporates both behavior and data.”,
 * “At its worst business logic can be very complex. Rules and logic describe many different "
 * "cases and slants of behavior, and it's this complexity that objects were designed to work with...”
 * Martin Fowler, EAA Patterns
 * http://martinfowler.com/eaaCatalog/domainModel.html
 *
 **/
public virtual with sharing class fflib_SObjectDomain extends fflib_SObjectDomainBase
	implements fflib_ISObjectDomain
{

	/**
	 * Constructs the domain class with the data on which to apply the behaviour implemented within
	 *
	 * @param sObjectList A concreate list (e.g. List<Account> vs List<SObject>) of records

	 **/
	public fflib_SObjectDomain(List<SObject> sObjectList)
	{
		super(sObjectList, sObjectList.getSObjectType());
	}

	/**
	 * Constructs the domain class with the data and type on which to apply the behaviour implemented within
	 *
	 * @param sObjectList A list (e.g. List<Opportunity>, List<Account>, etc.) of records
	 * @param sObjectType The Schema.SObjectType of the records contained in the list
	 *
	 * @remark Will support List<SObject> but all records in the list will be assumed to be of
	 *         the type specified in sObjectType
	 **/
	public fflib_SObjectDomain(List<SObject> sObjectList, SObjectType sObjectType)
	{
		super(sObjectList, sObjectType);
	}
	/**
	 * Interface used to aid the triggerHandler in constructing instances of Domain classes
	 **/
	public interface IConstructable
	{
		fflib_SObjectDomain construct(List<SObject> sObjectList);
	}

	/**
	 * Interface used to aid the triggerHandler in constructing instances of Domain classes
	 **/
	public interface IConstructable2 extends IConstructable
	{
		fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sObjectType);
	}
}
