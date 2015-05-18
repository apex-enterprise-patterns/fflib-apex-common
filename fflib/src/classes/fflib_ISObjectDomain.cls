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

public interface fflib_ISObjectDomain 
{
    /**
     * Returns the SObjectType this Domain class represents
     **/	
	Schema.SObjectType sObjectType();

    /**
     * Alternative to the Records property, provided to support mocking of Domain classes
     **/	
	List<SObject> getRecords();
}