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

/**
 * Provides an implementation of the Enterprise Application Architecture Unit Of Work, as defined by Martin Fowler
 *   http://martinfowler.com/eaaCatalog/unitOfWork.html
 *
 * "When you're pulling data in and out of a database, it's important to keep track of what you've changed; otherwise, 
 *  that data won't be written back into the database. Similarly you have to insert new objects you create and 
 *  remove any objects you delete."
 *
 * "You can change the database with each change to your object model, but this can lead to lots of very small database calls, 
 *  which ends up being very slow. Furthermore it requires you to have a transaction open for the whole interaction, which is 
 *  impractical if you have a business transaction that spans multiple requests. The situation is even worse if you need to
 *  keep track of the objects you've read so you can avoid inconsistent reads."
 *
 * "A Unit of Work keeps track of everything you do during a business transaction that can affect the database. When you're done, 
 *  it figures out everything that needs to be done to alter the database as a result of your work."
 *
 * In an Apex context this pattern provides the following specific benifits
 *  - Applies bulkfication to DML operations, insert, update and delete
 *  - Manages a business transaction around the work and ensures a rollback occurs (even when exceptions are later handled by the caller)
 *  - Honours dependency rules between records and updates dependent relationships automatically during the commit 
 *
 * Please refer to the testMethod's in this class for example usage 
 *
 * TODO: Need to complete the 100% coverage by covering parameter exceptions in tests
 * TODO: Need to add some more test methods for more complex use cases and some unexpected (e.g. registerDirty and then registerDeleted)
 *
 **/
public virtual class fflib_SObjectUnitOfWork
{
	private List<Schema.SObjectType> m_sObjectTypes = new List<Schema.SObjectType>();
	
	private Map<String, List<SObject>> m_newListByType = new Map<String, List<SObject>>();
	
	private Map<String, List<SObject>> m_dirtyListByType = new Map<String, List<SObject>>();
	
	private Map<String, List<SObject>> m_deletedListByType = new Map<String, List<SObject>>();
	
	private Map<String, Relationships> m_relationships = new Map<String, Relationships>();

	private List<IDoWork> m_workList = new List<IDoWork>();

	private SendEmailWork m_emailWork = new SendEmailWork();
	
	/**
	 * Interface describes work to be performed during the commitWork method
	 **/
	public interface IDoWork 
	{
		void doWork();
	}

	/**
	 * Constructs a new UnitOfWork to support work against the given object list
	 *
	 * @param sObjectList A list of objects given in dependency order (least dependent first)
	 */
	public fflib_SObjectUnitOfWork(List<Schema.SObjectType> sObjectTypes)
	{
		m_sObjectTypes = sObjectTypes.clone();
			
		for(Schema.SObjectType sObjectType : m_sObjectTypes)
		{
			m_newListByType.put(sObjectType.getDescribe().getName(), new List<SObject>());
			m_dirtyListByType.put(sObjectType.getDescribe().getName(), new List<SObject>());
			m_deletedListByType.put(sObjectType.getDescribe().getName(), new List<SObject>());
			m_relationships.put(sObjectType.getDescribe().getName(), new Relationships());	
		}

		m_workList.add(m_emailWork);
	}

	/**
	 * Register a generic peace of work to be invoked during the commitWork phase
	 **/
	public void registerWork(IDoWork work)
	{
		m_workList.add(work);
	}

	/**
	 * Registers the given email to be sent during the commitWork
	 **/
	public void registerEmail(Messaging.Email email)
	{
		m_emailWork.registerEmail(email);
	}
	
	/**
	 * Register a newly created SObject instance to be inserted when commitWork is called
	 *
	 * @param record A newly created SObject instance to be inserted during commitWork
	 **/
	public void registerNew(SObject record)
	{
		registerNew(record, null, null);
	}

	/**
	 * Register a newly created SObject instance to be inserted when commitWork is called, 
	 *   you may also provide a reference to the parent record instance (should also be registered as new separatly)
	 *
	 * @param record A newly created SObject instance to be inserted during commitWork
	 * @param relatedToParentField A SObjectField reference to the child field that associates the child record with its parent
	 * @param relatedToParentRecord A SObject instance of the parent record (should also be registered as new separatly)
	 **/
	public void registerNew(SObject record, Schema.sObjectField relatedToParentField, SObject relatedToParentRecord)
	{
		// Need to think about how to handle this
		//if(record.Id != null)
		//	throw new UnitOfWorkException('Only new records can be registered as new');
		String sObjectType = record.getSObjectType().getDescribe().getName();			
		if(!m_newListByType.containsKey(sObjectType))
			throw new UnitOfWorkException(String.format('SObject type {0} is not supported by this unit of work', new String[] { sObjectType }));
		m_newListByType.get(sObjectType).add(record);				
		registerRelationship(record, relatedToParentField, relatedToParentRecord);
	}
	
	/**
	 * Register a relationship between two records that have yet to be inserted to the database. This information will be 
	 *  used during the commitWork phase to make the references only when related records have been inserted to the database.
	 *
	 * @param record An existing or newly created record
	 * @param relatedToField A SObjectField referene to the lookup field that relates the two records together
	 * @param relatedTo A SOBject instance (yet to be commited to the database)
	 */
	public void registerRelationship(SObject record, Schema.sObjectField relatedToField, SObject relatedTo)
	{
		String sObjectType = record.getSObjectType().getDescribe().getName();		
		if(!m_newListByType.containsKey(sObjectType))
			throw new UnitOfWorkException(String.format('SObject type {0} is not supported by this unit of work', new String[] { sObjectType }));
		if(relatedTo!=null && relatedToField!=null)
			m_relationships.get(sObjectType).add(record, relatedToField, relatedTo);
		else
			m_relationships.get(sObjectType).add(record);
	}
	
	/**
	 * Register an existing record to be updated during the commitWork method
	 *
	 * @param record An existing record
	 **/
	public void registerDirty(SObject record)
	{
		if(record.Id == null)
			throw new UnitOfWorkException('New records cannot be registered as dirty');
		String sObjectType = record.getSObjectType().getDescribe().getName();			
		if(!m_dirtyListByType.containsKey(sObjectType))
			throw new UnitOfWorkException(String.format('SObject type {0} is not supported by this unit of work', new String[] { sObjectType }));
		m_dirtyListByType.get(sObjectType).add(record);		
	}
	
	/**
	 * Register an existing record to be deleted during the commitWork method
	 *
	 * @param record An existing record
	 **/
	public void registerDeleted(SObject record)
	{
		if(record.Id == null)
			throw new UnitOfWorkException('New records cannot be registered for deletion');
		String sObjectType = record.getSObjectType().getDescribe().getName();			
		if(!m_deletedListByType.containsKey(sObjectType))
			throw new UnitOfWorkException(String.format('SObject type {0} is not supported by this unit of work', new String[] { sObjectType }));
		m_deletedListByType.get(sObjectType).add(record);							
	}
	
	/**
	 * Takes all the work that has been registered with the UnitOfWork and commits it to the database
	 **/
	public void commitWork()
	{
		// Wrap the work in its own transaction 
		Savepoint sp = Database.setSavePoint();		
		try
		{		
			// Insert by type
			for(Schema.SObjectType sObjectType : m_sObjectTypes)
			{
				List<SObject> resolved;
	                
				while((resolved = m_relationships.get(sObjectType.getDescribe().getName()).resolve()).size() > 0)
				{
					insert resolved;
				}
			}					
			// Update by type
			for(Schema.SObjectType sObjectType : m_sObjectTypes)
				update m_dirtyListByType.get(sObjectType.getDescribe().getName());		
			// Delete by type (in reverse dependency order)
			Integer objectIdx = m_sObjectTypes.size() - 1;
			while(objectIdx>=0)
				delete m_deletedListByType.get(m_sObjectTypes[objectIdx--].getDescribe().getName());
			// Generic work
			for(IDoWork work : m_workList)
				work.doWork();
		}
		catch (Exception e)
		{
			// Rollback
			Database.rollback(sp);
			// Throw exception on to caller
			throw e;
		}
	}
	
	private class Relationships
	{
		private SObjectRelationshipMap m_SObjectRelationshipMap = new SObjectRelationshipMap(/*128, 0.8*/);

		public List<SObject> resolve()
		{
			// Resolve relationships
			List<SObject> fullyResolved = new List<SObject>();
            
			for(SObjectRelationshipMapIterator i = m_SObjectRelationshipMap.iterator(); i.hasNext();)
			{
				SObjectRelationshipMapEntry entry = i.next();
				SObjectReferenceWrapper obj = entry.getKey();
				List<Relationship> objRelationships = entry.getValue();
                        
                        	// Cache the Id to allow editing of fields that normally get locked
                        	// for editing after insert
				String cachedId = String.valueOf(obj.Record.Id);
				obj.Record.Id = null;
                
                		// Resolve as many relationships as possible
				for(Relationship relationship : objRelationships)
				{
					if(relationship.RelatedTo.Id != null)
					{
						relationship.Record.put(relationship.RelatedToField, relationship.RelatedTo.Id);
						relationship.Resolved = true;
					}
				}
                        
                        	// Retore the Id
				obj.Record.Id = cachedId;
                
				Integer j = 0;
                
                		// Clear out any resolved relationships
				while (j < objRelationships.size())
				{
					if(objRelationships.get(j).Resolved)
					{
						objRelationships.remove(j);
					}
					else
					{
						j++;
					}
				}
                
                		// If all relationships are resolved add it to the list to be returned
                		// and remove it from future processing
				if(objRelationships.size() == 0)
				{
					m_SObjectRelationshipMap.remove(obj);
                                
					obj.Record.Id = null;
					fullyResolved.add(obj.Record);
				}
			}
            
			return fullyResolved;
		}
		
		public void add(SObject record)
		{
			// Object with no relationship
			SObjectReferenceWrapper obj = new SObjectReferenceWrapper(record);
			List<Relationship> rels = m_SObjectRelationshipMap.get(obj);
            
			if(rels == null)
			{
				rels = new List<Relationship>();
				m_SObjectRelationshipMap.put(obj, rels);
			}
		}
        
		public void add(SObject record, Schema.sObjectField relatedToField, SObject relatedTo)
		{
			// Relationship to resolve
			Relationship relationship = new Relationship();
			relationship.Record = record;
			relationship.RelatedToField = relatedToField;
			relationship.RelatedTo = relatedTo;
			relationship.Resolved = false;
            
			SObjectReferenceWrapper obj = new SObjectReferenceWrapper(record);
			List<Relationship> rels = m_SObjectRelationshipMap.get(obj);
            
			if(rels == null)
			{
				rels = new List<Relationship>();
				m_SObjectRelationshipMap.put(obj, rels);
			}
            
			rels.add(relationship);
		}
	}
	
	private class Relationship
	{
		public SObject Record;
		public Schema.sObjectField RelatedToField;
		public SObject RelatedTo;
		public Boolean Resolved;
	}
	
	static Integer s_num = 1;
    
	public static String getFakeId(Schema.SObjectType sot)
	{
		String result = String.valueOf(s_num++);
		return sot.getDescribe().getKeyPrefix() + '0'.repeat(12-result.length()) + result;
	}
	
	private class SObjectReferenceWrapper
	{
		public SObject Record;
		private Integer hashCode;
    
		public SObjectReferenceWrapper(SObject record)
		{
			this.Record = record;

			// Id is the only field guaranteed to be on every object
			// so keep a unique reference in it
			// We can't use the standard SObject hashCode to determine
			// unique records as it's based purely on field values, if there
			// was a way of getting the memory address this could work around it
			if(record.Id == null)
			{
				record.Id = getFakeId(record.getSObjectType());
			}
            
            		// We need a hashCode for fast map put operations, cache the result
            		// Use the String hashCode of the Id as System.hashCode(object.Id) does not
            		// return the same result on every call for an object
			hashCode = String.valueOf(record.Id).hashCode();
		}
    
    		// Fallback for hash collisions, compared the memory address of objects using exact equality operator
		public Boolean equals(Object obj) 
		{
			if (obj instanceof SObjectReferenceWrapper) 
			{
				SObjectReferenceWrapper o = (SObjectReferenceWrapper)obj;
				return (Record === o.Record);
			}
    
			return false;
		}
        
		public Integer hashCode()
		{
			return hashCode;
		}
	}
	
	/* Internal hashmap implementation specificly for this class, this is to work around a bug where
	* Salesforce does not always use hashCode when it's implemented on classes (even though it should) */
	private class SObjectRelationshipMap
	{
		private final Integer DEFAULT_INITIAL_CAPACITY = 16;
		private final Integer MAXIMUM_CAPACITY = 1 << 30;
		private final Decimal DEFAULT_LOAD_FACTOR = 0.75;
        
		private SObjectRelationshipMapEntry[] table;
		private Integer size;
		private Integer threshold;
		private final Decimal loadFactor;
        
		private SObjectRelationshipMapIterator iterator;
    
		public SObjectRelationshipMap() 
		{
			this.size = 0;
			this.loadFactor = DEFAULT_LOAD_FACTOR;
			this.threshold = (Integer)(DEFAULT_INITIAL_CAPACITY * DEFAULT_LOAD_FACTOR);
			this.table = new SObjectRelationshipMapEntry[DEFAULT_INITIAL_CAPACITY];
		}
    
		// internal utilities
		private Integer hash(Integer h) 
		{
			// This function ensures that hashCodes that differ only by
			// constant multiples at each bit position have a bounded
			// number of collisions (approximately 8 at default load factor).
			h ^= (h >>> 20) ^ (h >>> 12);
			return (h ^ (h >>> 7)) ^ (h >>> 4);
		}
    
		private Integer indexFor(Integer h, Integer length) 
		{
			return h & (length-1);
		}
    
		// public interface
		public List<Relationship> get(SObjectReferenceWrapper key) 
		{
			Integer hash = hash(key.hashCode());
			Integer length = table.size();
            
			for (SObjectRelationshipMapEntry e = table[indexFor(hash, length)];  e != null; e = e.next) 
			{
				SObjectReferenceWrapper k;
                
				if (e.hash == hash && ((k = e.key) == key || key.equals(k)))
				{
					return e.value;
				}
			}
            
			return null;
		}
    
		public List<Relationship> put(SObjectReferenceWrapper key, List<Relationship> value) 
		{
			Integer hash = hash(key.hashCode());
			Integer i = indexFor(hash, table.size());
            
			for (SObjectRelationshipMapEntry e = table[i]; e != null; e = e.next) 
			{
				SObjectReferenceWrapper k;
                
				if (e.hash == hash && ((k = e.key) == key || key.equals(k))) 
				{
					List<Relationship> oldValue = e.value;
					e.value = value;
					return oldValue;
				}
			}
    
			addEntry(hash, key, value, i);
			return null;
		}
    
		private void resize(Integer newCapacity) 
		{
			SObjectRelationshipMapEntry[] oldTable = table;
			Integer oldCapacity = oldTable.size();
            
			if (oldCapacity == MAXIMUM_CAPACITY) 
			{
				threshold = 2147483647; // Used since Integer.MAX_VALUE is not available in Apex
				return;
			}
    
			SObjectRelationshipMapEntry[] newTable = new SObjectRelationshipMapEntry[newCapacity];
			transfer(newTable);
			table = newTable;
			threshold = (Integer)(newCapacity * loadFactor);
		}
    
		private void transfer(SObjectRelationshipMapEntry[] newTable) 
		{
			SObjectRelationshipMapEntry[] src = table;
			Integer newCapacity = newTable.size();
			Integer length = src.size();
            
			for (Integer j = 0; j < length; j++) 
			{
				SObjectRelationshipMapEntry e = src[j];
                
				if (e != null) 
				{
					src[j] = null;
                    
					do 
					{
						SObjectRelationshipMapEntry next = e.next;
						Integer i = indexFor(e.hash, newCapacity);
						e.next = newTable[i];
						newTable[i] = e;
						e = next;
					} 
					while (e != null);
				}
			}
		}
    
		public List<Relationship> remove(SObjectReferenceWrapper key) 
		{
			SObjectRelationshipMapEntry e = removeEntryForKey(key);
			return (e == null ? null : e.value);
		}
        
		private void addEntry(Integer hash, SObjectReferenceWrapper key, List<Relationship> value, Integer bucketIndex) 
		{
			SObjectRelationshipMapEntry e = table[bucketIndex];
			table[bucketIndex] = new SObjectRelationshipMapEntry(hash, key, value, e);
            
			if (size++ >= threshold)
			{
				resize(2 * table.size());
			}
		}
    
		private SObjectRelationshipMapEntry removeEntryForKey(SObjectReferenceWrapper key) 
		{
			Integer hash = (key == null) ? 0 : hash(key.hashCode());
			Integer i = indexFor(hash, table.size());
			SObjectRelationshipMapEntry prev = table[i];
			SObjectRelationshipMapEntry e = prev;
    
			while (e != null) 
			{
				SObjectRelationshipMapEntry next = e.next;
				SObjectReferenceWrapper k;
                
				if (e.hash == hash && ((k = e.key) == key || (key != null && key.equals(k)))) 
				{
					size--;
                    
					if (prev == e)
					{
						table[i] = next;
					}
					else
					{
						prev.next = next;
					}
                    
					return e;
				}
                
				prev = e;
				e = next;
			}
    
			return e;
		}
    
        
    
		public SObjectRelationshipMapIterator iterator() 
		{
			return iterator != null ? iterator : (iterator = new SObjectRelationshipMapIterator(this));
		}
	}
    
	private class SObjectRelationshipMapEntry
	{
		private final SObjectReferenceWrapper key;
		private List<Relationship> value;
		private SObjectRelationshipMapEntry next;
		private final Integer hash;

		private SObjectRelationshipMapEntry(Integer h, SObjectReferenceWrapper k, List<Relationship> v, SObjectRelationshipMapEntry n) 
		{
			this.value = v;
			this.next = n;
			this.key = k;
			this.hash = h;
		}

		public SObjectReferenceWrapper getKey() 
		{
			return key;
		}

		public List<Relationship> getValue() 
		{
			return value;
		}

		public Boolean equals(Object o) 
		{
			if (!(o instanceof SObjectRelationshipMapEntry))
				return false;
                
			SObjectRelationshipMapEntry e = (SObjectRelationshipMapEntry)o;
			SObjectReferenceWrapper k1 = getKey();
			SObjectReferenceWrapper k2 = e.getKey();
            
			if (k1 == k2 || (k1 != null && k1.equals(k2))) 
			{
				List<Relationship> v1 = getValue();
				List<Relationship> v2 = e.getValue();
                
				if (v1 == v2 || (v1 != null && v1.equals(v2)))
				{
					return true;
				}
			}
            
			return false;
		}
	}
    
	private class SObjectRelationshipMapIterator implements System.Iterator<SObjectRelationshipMapEntry>
	{
		private SObjectRelationshipMap m;
        
		private SObjectRelationshipMapEntry next;        // next entry to return
		private Integer index;              // current slot
		private SObjectRelationshipMapEntry current;     // current entry

		private SObjectRelationshipMapIterator(SObjectRelationshipMap m) 
		{
			this.m = m;
			this.index = 0;
            
			if (m.size > 0) 
			{ // advance to first entry
				SObjectRelationshipMapEntry[] t = m.table;
				Integer length = t.size();
                
				while (index < length && (next = t[index++]) == null)
					;
			}
		}

		public Boolean hasNext() 
		{
			return next != null;
		}

		public SObjectRelationshipMapEntry next() 
		{
			SObjectRelationshipMapEntry e = next;
	            
			if (e == null)
			{
				throw new UnitOfWorkException/*NoSuchElementException*/();
			}

			if ((next = e.next) == null) 
			{
				SObjectRelationshipMapEntry[] t = m.table;
				Integer length = t.size();
                
				while (index < length && (next = t[index++]) == null)
					;
			}
            
			current = e;
            
			return e;
		}
	}
	
	/**
	 * UnitOfWork Exception
	 **/
	public class UnitOfWorkException extends Exception {}

	/** 
	 * Internal implementation of Messaging.sendEmail, see outer class registerEmail method
	 **/
	private class SendEmailWork implements IDoWork
	{
		private List<Messaging.Email> emails;

		public SendEmailWork()
		{
			this.emails = new List<Messaging.Email>();
		}

		public void registerEmail(Messaging.Email email)
		{
			this.emails.add(email);
		}

		public void doWork()
		{
			Messaging.sendEmail(emails);
		}
	}	
}
