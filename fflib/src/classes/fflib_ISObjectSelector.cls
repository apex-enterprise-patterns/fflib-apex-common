/*
* FinancialForce.com, inc. claims copyright in this software, its screen
* display designs and supporting documentation. FinancialForce and
* FinancialForce.com are trademarks of FinancialForce.com, inc. Any
* unauthorized use, copying or sale of the above may constitute an
* infringement of copyright and may result in criminal or other legal
* proceedings.
*
* Copyright (c) 2013 FinancialForce.com, inc. All rights reserved.
*/

public interface fflib_ISObjectSelector
{
	/**
	 * Provides the SObjectType for the object the given Selector is providing query logic for
	 **/
	Schema.SObjectType sObjectType();

	/**
	 * Selects by Id records using the fields defined by the Selector configuration
	 **/
	List<SObject> selectSObjectsById(Set<Id> idSet);	
}