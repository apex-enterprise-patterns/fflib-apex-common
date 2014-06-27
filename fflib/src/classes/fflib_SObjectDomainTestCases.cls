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
 * Class contains Domain classes used by the tests in fflib_SObjectDomainTest, 
 *   they have to be public as the triggerHandler leverages Type.forName which does not observe @TestVisible
 **/
public with sharing class fflib_SObjectDomainTestCases 
{
	/**
	 * Test domain class (ideally this would be in the test class, however Type.newInstance does not see such classes)
	 **/
	public with sharing class TestSObjectDomain extends fflib_SObjectDomain
	{
		private String someState;
		
		public TestSObjectDomain(List<Opportunity> sObjectList)
		{
			// Domain classes are initialised with lists to enforce bulkification throughout
			super(sObjectList);
		}
		
		public override void onApplyDefaults()
		{
			// Not required in production code
			super.onApplyDefaults();
			
			// Apply defaults to Testfflib_SObjectDomain
			for(Opportunity opportunity : (List<Opportunity>) Records)
			{
				opportunity.CloseDate = System.today().addDays(30);						
			}
		}
	
		public override void onValidate()	
		{
			// Not required in production code
			super.onValidate();
			
			// Validate Testfflib_SObjectDomain
			for(Opportunity opp : (List<Opportunity>) Records)
			{
				if(opp.Type!=null && opp.Type.startsWith('Existing') && opp.AccountId == null)
				{
					opp.AccountId.addError( error('You must provide an Account for Opportunities for existing Customers.', opp, Opportunity.AccountId) );					
				}			
			}		
		}
		
		public override void onValidate(Map<Id,SObject> existingRecords)
		{
			// Not required in production code	
			super.onValidate(existingRecords);
			
			// Validate changes to Testfflib_SObjectDomain
			for(Opportunity opp : (List<Opportunity>) Records)
			{
				Opportunity existingOpp = (Opportunity) existingRecords.get(opp.Id);
				if(opp.Type != existingOpp.Type)
				{
					opp.Type.addError( error('You cannot change the Opportunity type once it has been created.', opp, Opportunity.Type) );
				}
			}
		}
		
		public override void onBeforeDelete()
		{
			// Not required in production code
			super.onBeforeDelete();
			
			// Validate changes to Testfflib_SObjectDomain
			for(Opportunity opp : (List<Opportunity>) Records)
			{
				opp.addError( error('You cannot delete this Opportunity.', opp) );
			}			
		}
		
		public override void onBeforeInsert()
		{
			// Assert this variable is null in the after insert (since this domain class is stateless)
			someState = 'This should not survice the trigger after phase';
		}
		
		public override void onAfterInsert()
		{
			// This is a stateless domain class, so should not retain anything betweet before and after
			System.assertEquals(null, someState);
		}
	}	
	
	/**
	 * Typically an inner class to the domain class, supported here for test purposes
	 **/	
	public class TestSObjectDomainConstructor implements fflib_SObjectDomain.IConstructable
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new TestSObjectDomain(sObjectList);
		}
	}
	
	/**
	 * Test domain class (ideally this would be in the test class, however Type.newInstance does not see such classes)
	 **/
	public with sharing class TestSObjectStatefulDomain 
		extends fflib_SObjectDomain 
	{
		public String someState;
		
		public TestSObjectStatefulDomain(List<Opportunity> sObjectList)
		{
			super(sObjectList);

			// Ensure this instance is re-used in the after trigger phase (subject to recursive scenarios)		
			Configuration.enableTriggerState();
		}
		
		public override void onBeforeInsert() 
		{
			// This must always be null, as we do not reuse domain instances within recursive scenarios (different record sets)
			System.assertEquals(null, someState);
			
			// Process records			 
			List<Opportunity> newOpps = new List<Opportunity>();
			for(Opportunity opp : (List<Opportunity>) Records)
			{
				// Set some state sensitive to the incoming records
				someState = 'Error on Record ' + opp.Name;
				
				// Create a new Opportunity record to trigger recursive code path?
				if(opp.Name.equals('Test Recursive 1'))
					newOpps.add(new Opportunity ( Name = 'Test Recursive 2', Type = 'Existing Account' ));
			}				
			
			// If testing recursiving emulate an insert 	
			if(newOpps.size()>0)
			{
				// This will force recursion and thus validate via the above assert results in a new domain instance
				fflib_SObjectDomain.Test.Database.onInsert(newOpps);		
				fflib_SObjectDomain.triggerHandler(TestSObjectStatefulDomainConstructor.class);
			}								
		}
		
		public override void onAfterInsert() 
		{ 
			// Use the state set in the before insert (since this is a stateful domain class)
			if(someState!=null)
				for(Opportunity opp : (List<Opportunity>) Records)
					opp.addError(error(someState, opp));
		}		
	}
	
	
	/**
	 * Typically an inner class to the domain class, supported here for test purposes
	 **/	
	public class TestSObjectStatefulDomainConstructor implements fflib_SObjectDomain.IConstructable
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new TestSObjectStatefulDomain(sObjectList);
		}
	}
}