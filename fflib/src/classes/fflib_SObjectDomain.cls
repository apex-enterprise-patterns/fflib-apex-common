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
public virtual with sharing class fflib_SObjectDomain
{
	/**
	 * Provides access to the data represented by this domain class
	 **/
	public List<SObject> Records { get; private set;}
	
	/**
	 * Derived from the records provided during construction, provides the native describe for the standard or custom object
	 **/
	public Schema.DescribeSObjectResult SObjectDescribe {get; private set;}

	/**
	 * Exposes the configuration for this domain class instance
	 **/ 
	public Configuration Configuration {get; private set;}    
		
	/**
	 * Useful during unit testign to assert at a more granular and robust level for errors raised during the various trigger events
	 **/	
	public static ErrorFactory Errors {get; private set;}
	
	/**
	 * Useful during unit testing to access mock support for database inserts and udpates (testing without DML)
	 **/
	public static TestFactory Test  {get; private set;}
	
	/**
	 * Retains instances of domain classes implementing trigger stateful
	 **/
	private static Map<Type, List<fflib_SObjectDomain>> TriggerStateByClass; 
	
	static
	{
		Errors = new ErrorFactory();		
		Test = new TestFactory();		
		TriggerStateByClass = new Map<Type, List<fflib_SObjectDomain>>();
	}
			
	/**
	 * Constructs the domain class with the data on which to apply the behaviour implemented within
	 **/
	public fflib_SObjectDomain(List<SObject> sObjectList)
	{
		// Ensure the domain class has its own copy of the data
		Records = sObjectList.clone(); 
		// Capture SObjectType describe for this domain class
		SObjectDescribe = Records.getSObjectType().getDescribe();
		// Configure the Domain object instance 
		Configuration = new Configuration();
	}
	
	/**
	 * Override this to apply defaults to the records, this is called by the handleBeforeInsert method
	 **/
	public virtual void onApplyDefaults() { }
	
	/**
	 * Override this to apply general validation to be performed during insert or update, called by the handleAfterInsert and handleAfterUpdate methods
	 **/
	public virtual void onValidate() {	}
	
	/**
	 * Override this to apply validation to be performed during insert, called by the handleAfterUpdate method
	 **/
	public virtual void onValidate(Map<Id,SObject> existingRecords)	{ }

	/**
	 * Override this to perform processing during the before insert phase, this is called by the handleBeforeInsert method
	 **/
    public virtual void onBeforeInsert() { }
    
	/**
	 * Override this to perform processing during the before update phase, this is called by the handleBeforeUpdate method
	 **/
    public virtual void onBeforeUpdate(Map<Id,SObject> existingRecords) { }
    
	/**
	 * Override this to perform processing during the before delete phase, this is called by the handleBeforeDelete method
	 **/
    public virtual void onBeforeDelete() { }
    
	/**
	 * Override this to perform processing during the after insert phase, this is called by the handleAfterInsert method
	 **/
    public virtual void onAfterInsert() { }
    
	/**
	 * Override this to perform processing during the after update phase, this is called by the handleAfterUpdate method
	 **/    
    public virtual void onAfterUpdate(Map<Id,SObject> existingRecords) { }
    
	/**
	 * Override this to perform processing during the after delete phase, this is called by the handleAfterDelete method
	 **/    
    public virtual void onAfterDelete() { }	
	
	/**
	 * Base handler for the Apex Trigger event Before Insert, calls the onApplyDefaults method, followed by onBeforeInsert
	 **/
    public virtual void handleBeforeInsert() 
    { 
    	onApplyDefaults(); 
    	onBeforeInsert();
    }
    
    /**
     * Base handler for the Apex Trigger event Before Update, calls the onBeforeUpdate method
     **/
    public void handleBeforeUpdate(Map<Id,SObject> existingRecords) 
    {	    	   
    	onBeforeUpdate(existingRecords);
    }
    
    /**
     * Base handler for the Apex Trigger event Before Delete, calls the onBeforeDelete method
     **/
    public void handleBeforeDelete() 
    {
    	onBeforeDelete();
    }
    
    /**
     * Base handler for the Apex Trigger event After Insert, checks object and field level security and calls the onValidate and onAfterInsert methods
     *
     * @throws DomainException if the current user context is not able to create records
     **/
    public void handleAfterInsert()
    {
    	// Retained for backwards compatability 
    	if(Configuration.EnforcingTriggerCRUDSecurity && !SObjectDescribe.isCreateable()) 
			throw new DomainException('Permission to create an ' + SObjectDescribe.getName() + ' denied.');
    	    
    	onValidate();
    	onAfterInsert(); 
    }
    
    /**
     * Base handler for the Apex Trigger event After Update, checks object and field level security and calls the onValidate, onValidate(Map<Id,SObject>) and onAfterUpdate methods
     *
     * @throws DomainException if the current user context is not able to update records
     **/
    public void handleAfterUpdate(Map<Id,SObject> existingRecords) 
    {
    	// Retained for backwards compatability
    	if(Configuration.EnforcingTriggerCRUDSecurity && !SObjectDescribe.isUpdateable()) 			    		
	   		throw new DomainException('Permission to udpate an ' + SObjectDescribe.getName() + ' denied.');
    		
	   	// Is this update a result of a Unit Of Work commit? (aka part of service called by a controller, batch or other Apex context)
   		if(fflib_SObjectUnitOfWork.isCommitting && fflib_SObjectUnitOfWork.CurrentCommit.enforcingSecurity(SObjectDescribe.getSObjectType()))
   			if(checkUpdateSecurity(existingRecords))
   				return;
    	
    	onValidate();
    	onValidate(existingRecords);
    	onAfterUpdate(existingRecords); 
    }
    
    /**
     * Base handler for the Apex Trigger event After Delete, checks object security and calls the onAfterDelete method
     *
     * @throws DomainException if the current user context is not able to delete records
     **/
    public void handleAfterDelete() 
    {
    	// Retained for backwards compatability
    	if(Configuration.EnforcingTriggerCRUDSecurity && !SObjectDescribe.isDeletable())
    		throw new DomainException('Permission to delete an ' + SObjectDescribe.getName() + ' denied.');
    	   
    	onAfterDelete();
    }	

	/**
	 * Scans the records for popualted fields and ensures the users permisisons permit them to set them
	 **/
	public static void checkInsertSecurity(SObjectType sObjectType, List<SObject> records)
	{
    	// Scan the records in this domain class for modified fields
    	Set<String> populatedFields = new Set<String>();
    	for(SObject record: Records)
    		populatedFields.addAll(resolvePopulatedFields(record));
    	// Check populated fields against the users permissions and throw an exception for any failure
    	fflib_SecurityUtils.checkInsert(sObjectType, new List<String>(populatedFields));
	}
	
	/**
	 * Scans the records being commited for fields modified (not equal) given the passed in existing records map
	 **/    
    private Boolean checkUpdateSecurity(Map<Id, SObject> existingRecords)
    {
    	// Scan the records originally commited for modified fields against those existing provided by the trigger context
    	Set<String> populatedFields = new Set<String>();
    	for(SObject record: Records)
    	{
    		// Compare against the record as it was provided to the uow (prior to any platform defaults or calculated fields that may cause false positives)
    		SObject uowRecord = fflib_SObjectUnitOfWork.CurrentCommit.Records.get(record.Id);
    		if(uowRecord==null)
    			continue; // Assume this record came from a third party trigger during the commit cycle? 
    		// Compare those fields set with those in the existing record, if they have changed add to the list of fields to check for FLS
    		for(String field : resolvePopulatedFields(uowRecord))
    			if(uowRecord.get(field)!=existingRecords.get(record.Id).get(field))
    				populatedFields.add(field);
    	}
		try {
    		// Check the fields against the user permissions and relay any failure via addError on the Trigger.new records
			fflib_SecurityUtils.checkUpdate(SObjectDescribe.getSObjectType(), new List<String>(populatedFields));
		} catch (fflib_SecurityUtils.FlsException e) {
			for(SObject record : Records)
				record.addError(e.getMessage());
			return true;
   		}    	
   		return false;
    }
    
    /**
     * Determines which fields have acctually been set in the given SObject
     **/
    private static Set<String> resolvePopulatedFields(SObject record)
    {
    	// Please upvote https://success.salesforce.com/ideaView?id=08730000000l5vbAAA)
		Set<String> populatedFieldsFromRecord = ((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(record))).keySet();
		populatedFieldsFromRecord.remove('attributes');
		return populatedFieldsFromRecord;
    }
	
	/**
	 * Interface used to aid the triggerHandler in constructing instances of Domain classes
	 *
	 * @depricated Please extend Constructor instead of implementing this interface
	 **/
	public interface IConstructable
	{
		fflib_SObjectDomain construct(List<SObject> sObjectList);
	}
	
	/**
	 * For Domain classes implementing the ITriggerStateful interface returns the instance 
	 *   of the domain class being shared between trigger invocations, returns null if
	 *   the Domain class trigger has not yet fired or the given domain class does not implement
	 *   the ITriggerStateful interface. Note this method is sensitive to recursion, meaning
	 *   it will return the applicable domain instance for the level of recursion
	 **/ 
	public static fflib_SObjectDomain getTriggerInstance(Type domainClass)
	{
		List<fflib_SObjectDomain> domains = TriggerStateByClass.get(domainClass);
		if(domains==null || domains.size()==0)
			return null;
		return domains[domains.size()-1];
	}
	
	/**
	 * Method constructs the given Domain class with the current Trigger context 
	 * before calling the applicable override methods such as beforeInsert, beforeUpdate etc.
	 **/
	public static void triggerHandler(Type domainClass)
	{		
		// Process the trigger context
		if(System.Test.isRunningTest() & Test.Database.hasRecords())
		{
			// If in test context and records in the mock database delegate initially to the mock database trigger handler
			Test.Database.testTriggerHandler(domainClass);
		}
		else
		{
			// Process the runtime Apex Trigger context 
			triggerHandler(domainClass, 
				Trigger.isBefore, 
				Trigger.isAfter, 
				Trigger.isInsert, 
				Trigger.isUpdate, 
				Trigger.isDelete, 
				Trigger.new, 
				Trigger.oldMap);
		}
	}
	
	/**
	 * Calls the applicable override methods such as beforeInsert, beforeUpdate etc. based on a Trigger context
	 **/
	private static void triggerHandler(Type domainClass, Boolean isBefore, Boolean isAfter, Boolean isInsert, Boolean isUpdate, Boolean isDelete, List<SObject> newRecords, Map<Id, SObject> oldRecordsMap)
	{	
		// After phase of trigger will reuse prior instance of domain class if ITriggerStateful implemented 
		fflib_SObjectDomain domainObject = isBefore ? null : popTriggerInstance(domainClass, isDelete ? oldRecordsMap.values() : newRecords);
		if(domainObject==null)
		{		
			// Construct the domain class constructor class
			String domainClassName = domainClass.getName(); 
			Type constructableClass = domainClassName.endsWith('Constructor') ? Type.forName(domainClassName) : Type.forName(domainClassName+'.Constructor');
			IConstructable domainConstructor = (IConstructable) constructableClass.newInstance();			
	
			// Construct the domain class with the approprite record set		
	        if(isInsert) domainObject = domainConstructor.construct(newRecords);
	        else if(isUpdate) domainObject = domainConstructor.construct(newRecords);
	        else if(isDelete) domainObject = domainConstructor.construct(oldRecordsMap.values());
	        
	        // Should this instance be reused on the next trigger invocation?
	        if(domainObject.Configuration.TriggerStateEnabled)
	        	// Push this instance onto the stack to be popped during the after phase
	        	pushTriggerInstance(domainClass, domainObject);	
		}
		
		// Invoke the applicable handler
		if(isBefore)
	    {
	        if(isInsert) domainObject.handleBeforeInsert();
	        else if(isUpdate) domainObject.handleBeforeUpdate(oldRecordsMap);
	        else if(isDelete) domainObject.handleBeforeDelete();
	    }
	    else
	    {
	        if(isInsert) domainObject.handleAfterInsert();
	        else if(isUpdate) domainObject.handleAfterUpdate(oldRecordsMap);
	        else if(isDelete) domainObject.handleAfterDelete();
	    }				
	}
	
	/**
	 * Pushes to the stack of domain classes per type a domain object instance
	 **/
	private static void pushTriggerInstance(Type domainClass, fflib_SObjectDomain domain)
	{
		List<fflib_SObjectDomain> domains = TriggerStateByClass.get(domainClass);
		if(domains==null)
			TriggerStateByClass.put(domainClass, domains = new List<fflib_SObjectDomain>());
		domains.add(domain);		
	}
	
	/**
	 * Pops from the stack of domain classes per type a domain object instance and updates the record set
	 **/
	private static fflib_SObjectDomain popTriggerInstance(Type domainClass, List<SObject> records)
	{
		List<fflib_SObjectDomain> domains = TriggerStateByClass.get(domainClass);
		if(domains==null || domains.size()==0)
			return null;		
		fflib_SObjectDomain domain = domains.remove(domains.size()-1);
		domain.Records = records; // Re-assigned as the SObject is a difference instead in after phase
		return domain;
	}
	
	/**
	 * Fluent style Configuration system for Domain class creation
	 **/
	public class Configuration
	{
		/**
		 * True if the base class is checking the users CRUD requirements before invoking trigger methods
		 **/ 
		public Boolean EnforcingTriggerCRUDSecurity {get; private set;}
		
		/**
		 * Enables reuse of the same Domain instance between before and after trigger phases (subject to recursive scenarios)
		 **/
		public Boolean TriggerStateEnabled {get; private set;}
			
		/**
		 * Default configuration 
		 **/
		public Configuration()
		{
			EnforcingTriggerCRUDSecurity = true; // Default is true for backwards compatability
			TriggerStateEnabled = false;
		}
		
		/**
		 * See associated property
		 **/
		public Configuration enableTriggerState()
		{
			TriggerStateEnabled = true;
			return this;	
		}
		
		/**
		 * See associated property
		 **/
		public Configuration disableTriggerState()
		{
			TriggerStateEnabled = false;
			return this;	
		}

		/**
		 * See associated property
		 **/
		public Configuration enforceTriggerCRUDSecurity()
		{
			EnforcingTriggerCRUDSecurity = true;
			return this;
		}

		/**
		 * See associated property
		 **/
		public Configuration disableTriggerCRUDSecurity()
		{
			EnforcingTriggerCRUDSecurity = false;
			return this;
		}
	}
		
	/**
	 * General exception class for the domain layer
	 **/
	public class DomainException extends Exception
	{
	}

	/**
	 * Ensures logging of errors in the Domain context for later assertions in tests
	 **/
	public String error(String message, SObject record)
	{
		return Errors.error(this, message, record);	
	}
	
	/**
	 * Ensures logging of errors in the Domain context for later assertions in tests
	 **/
	public String error(String message, SObject record, SObjectField field)
	{
		return Errors.error(this, message, record, field);	
	}
	
	/**
	 * Ensures logging of errors in the Domain context for later assertions in tests
	 **/
	public class ErrorFactory
	{
		private List<Error> errorList = new List<Error>(); 
		
		private ErrorFactory()
		{
			
		}
		
		public String error(String message, SObject record)
		{
			return error(null, message, record);	
		}

		private String error(fflib_SObjectDomain domain, String message, SObject record)
		{
			ObjectError objectError = new ObjectError();
			objectError.domain = domain;
			objectError.message = message;
			objectError.record = record;
			errorList.add(objectError);
			return message;	
		}
		
		public String error(String message, SObject record, SObjectField field)
		{
			return error(null, message, record, field);	
		}

		private String error(fflib_SObjectDomain domain, String message, SObject record, SObjectField field)
		{
			FieldError fieldError = new FieldError();
			fieldError.domain = domain;
			fieldError.message = message;
			fieldError.record = record;
			fieldError.field = field;
			errorList.add(fieldError);
			return message;	
		}	
			
		public List<Error> getAll()
		{ 
			return errorList.clone();
		}
		
		public void clearAll()
		{
			errorList.clear();
		}					
	}
	
	/**
	 * Ensures logging of errors in the Domain context for later assertions in tests
	 **/
	public class FieldError extends ObjectError
	{
		public SObjectField field;
		
		private FieldError()
		{		
			
		}
	}
	
	/**
	 * Ensures logging of errors in the Domain context for later assertions in tests
	 **/
	public virtual class ObjectError extends Error
	{
		public SObject record;
		
		private ObjectError()
		{
		
		}
	}
	
	/**
	 * Ensures logging of errors in the Domain context for later assertions in tests
	 **/
	public abstract class Error
	{
		public String message;
		public fflib_SObjectDomain domain;
	}

	/**
	 * Provides test context mocking facilities to unit tests testing domain classes
	 **/	
	public class TestFactory
	{
		public MockDatabase Database = new MockDatabase();
		 
		private TestFactory()
		{		
			
		}
	}
	
	/**
	 * Class used during Unit testing of Domain classes, can be used (not exclusively) to speed up test execution and focus testing
	 **/
	public class MockDatabase
	{
		private Boolean isInsert = false;
		private Boolean isUpdate = false;
		private Boolean isDelete = false;
		private List<SObject> records = new List<SObject>();
		private Map<Id, SObject> oldRecords = new Map<Id, SObject>();
		
		private MockDatabase()
		{
			
		}
			
		private void testTriggerHandler(Type domainClass)
		{
			// Mock Before
			triggerHandler(domainClass, true, false, isInsert, isUpdate, isDelete, records, oldRecords);
			
			// Mock After
			triggerHandler(domainClass, false, true, isInsert, isUpdate, isDelete, records, oldRecords);
		}
		
		public void onInsert(List<SObject> records)
		{
			this.isInsert = true;
			this.isUpdate = false;
			this.isDelete = false;
			this.records = records;
		}
		
		public void onUpdate(List<SObject> records, Map<Id, SObject> oldRecords)
		{
			this.isInsert = false;
			this.isUpdate = true;
			this.isDelete = false;
			this.records = records;
			this.oldRecords = oldRecords;
		}
		
		public void onDelete(Map<Id, SObject> records)
		{
			this.isInsert = false;
			this.isUpdate = false;
			this.isDelete = true;
			this.oldRecords = records;
		}
		
		public Boolean hasRecords()
		{
			return records!=null && records.size()>0 || oldRecords!=null && oldRecords.size()>0;
		}
	}
}