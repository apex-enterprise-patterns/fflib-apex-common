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
 * Class provides inner classes implementing factories for the main components
 * of the Apex Enterprise Patterns, Service, Unit Of Work, Selector and Domain.
 *   See the sample applications Application.cls file for an example
 **/
public virtual class fflib_Application
{
	/**
	 * Class implements a Unit of Work factory
	 **/
	public virtual class UnitOfWorkFactory
	{
		private List<SObjectType> m_objectTypes;
		private fflib_ISObjectUnitOfWork m_mockUow;

		/**
		 * Constructs a Unit Of Work factory
		 *
		 * @param objectTypes List of SObjectTypes in dependency order
		 **/
		public UnitOfWorkFactory(List<SObjectType> objectTypes)
		{
			m_objectTypes = objectTypes.clone();
		}

		/**
		 * Returns a new fflib_SObjectUnitOfWork configured with the 
		 *   SObjectType list provided in the constructor, returns a Mock implementation
		 *   if set via the setMock method
		 **/
		public fflib_ISObjectUnitOfWork newInstance()
		{
			// Mock?
			if(m_mockUow!=null)
				return m_mockUow;
			return new fflib_SObjectUnitOfWork(m_objectTypes);
		}


		/**
		 * Returns a new fflib_SObjectUnitOfWork configured with the
		 *   SObjectType list provided in the constructor, returns a Mock implementation
		 *   if set via the setMock method
		 **/
		public fflib_ISObjectUnitOfWork newInstance(fflib_SObjectUnitOfWork.IDML dml)
		{
			// Mock?
			if(m_mockUow!=null)
				return m_mockUow;
			return new fflib_SObjectUnitOfWork(m_objectTypes, dml);
		}


		/**
		 * Returns a new fflib_SObjectUnitOfWork configured with the
		 *   SObjectType list specified, returns a Mock implementation
		 *   if set via the setMock method
		 *
		 * @remark If mock is set, the list of SObjectType in the mock could be different
		 *         then the list of SObjectType specified in this method call
		 **/
		public fflib_ISObjectUnitOfWork newInstance(List<SObjectType> objectTypes)
		{
			// Mock?
			if(m_mockUow!=null)
				return m_mockUow;
			return new fflib_SObjectUnitOfWork(objectTypes);
		}		

		/**
		 * Returns a new fflib_SObjectUnitOfWork configured with the
		 *   SObjectType list specified, returns a Mock implementation
		 *   if set via the setMock method
		 *
		 * @remark If mock is set, the list of SObjectType in the mock could be different
		 *         then the list of SObjectType specified in this method call
		 **/
		public fflib_ISObjectUnitOfWork newInstance(List<SObjectType> objectTypes, fflib_SObjectUnitOfWork.IDML dml)
		{
			// Mock?
			if(m_mockUow!=null)
				return m_mockUow;
			return new fflib_SObjectUnitOfWork(objectTypes, dml);
		}


		@TestVisible
		private void setMock(fflib_ISObjectUnitOfWork mockUow)
		{
			m_mockUow = mockUow;
		}
	}

	/**
	 * Simple Service Factory implementaiton
	 **/
	public virtual class ServiceFactory
	{
		protected Map<Type, Type> m_serviceInterfaceTypeByServiceImplType;

		protected Map<Type, Object> m_serviceInterfaceTypeByMockService;

		/**
		 * Constructs a simple Service Factory, 
		 *   using a Map of Apex Interfaces to Apex Classes implementing the interface
		 *   Note that this will not check the Apex Classes given actually implement the interfaces
		 *     as this information is not presently available via the Apex runtime
		 *
		 * @param serviceInterfaceTypeByServiceImplType Map ofi interfaces to classes
		 **/
		public ServiceFactory(Map<Type, Type> serviceInterfaceTypeByServiceImplType)
		{
			m_serviceInterfaceTypeByServiceImplType = serviceInterfaceTypeByServiceImplType;
			m_serviceInterfaceTypeByMockService = new Map<Type, Object>();
		}

		/**
		 * Returns a new instance of the Apex class associated with the given Apex interface
		 *   Will return any mock implementation of the interface provided via setMock
		 *   Note that this method will not check the configured Apex class actually implements the interface
		 *
		 * @param serviceInterfaceType Apex interface type
		 * @exception Is thrown if there is no registered Apex class for the interface type
		 **/
		public virtual Object newInstance(Type serviceInterfaceType)
		{
			// Mock implementation?
			if(m_serviceInterfaceTypeByMockService.containsKey(serviceInterfaceType))
				return m_serviceInterfaceTypeByMockService.get(serviceInterfaceType);

			// Create an instance of the type impleneting the given interface
			Type serviceImpl = m_serviceInterfaceTypeByServiceImplType.get(serviceInterfaceType);
			if(serviceImpl==null)
				throw new DeveloperException('No implementation registered for service interface ' + serviceInterfaceType.getName());	
			return serviceImpl.newInstance();
		}

		@TestVisible
		private virtual void setMock(Type serviceInterfaceType, Object serviceImpl)
		{
			m_serviceInterfaceTypeByMockService.put(serviceInterfaceType, serviceImpl);
		}
	}

	/**
	 * Class implements a Selector class factory
	 **/
	public virtual class SelectorFactory
	{
		protected Map<SObjectType, Type> m_sObjectBySelectorType;
		protected Map<SObjectType, fflib_ISObjectSelector> m_sObjectByMockSelector;

		/**
		 * Consturcts a Selector Factory linking SObjectType's with Apex Classes implement the fflib_ISObjectSelector interface
		 *   Note that the factory does not chekc the given Apex Classes implement the interface
		 *     currently this is not possible in Apex.
		 *
		 * @Param sObjectBySelectorType Map of SObjectType's to Selector Apex Classes
		 **/
		public SelectorFactory(Map<SObjectType, Type> sObjectBySelectorType)
		{
			m_sObjectBySelectorType = sObjectBySelectorType;
			m_sObjectByMockSelector = new Map<SObjectType, fflib_ISObjectSelector>();		
		}

		/**
		 * Creates a new instance of the associated Apex Class implementing fflib_ISObjectSelector
		 *   for the given SObjectType, or if provided via setMock returns the Mock implementaton
		 *
		 * @param sObjectType An SObjectType token, e.g. Account.SObjectType
		 **/
		public virtual fflib_ISObjectSelector newInstance(SObjectType sObjectType)
		{
			// Mock implementation?
			if(m_sObjectByMockSelector.containsKey(sObjectType))
				return m_sObjectByMockSelector.get(sObjectType);

			// Determine Apex class for Selector class			
			Type selectorClass = m_sObjectBySelectorType.get(sObjectType);
			if(selectorClass==null)
				throw new DeveloperException('Selector class not found for SObjectType ' + sObjectType);

			// Construct Selector class and query by Id for the records
			return (fflib_ISObjectSelector) selectorClass.newInstance();			
		}

		/**
		 * Helper method to query the given SObject records
		 *   Internally creates an instance of the registered Selector and calls its
		 *     selectSObjectById method
		 *
		 * @param recordIds The SObject record Ids, must be all the same SObjectType
		 * @exception Is thrown if the record Ids are not all the same or the SObjectType is not registered
		 **/
		public List<SObject> selectById(Set<Id> recordIds)
		{
			// No point creating an empty Domain class, nor can we determine the SObjectType anyway
			if(recordIds==null || recordIds.size()==0)
				throw new DeveloperException('Invalid record Id\'s set');	

			// Determine SObjectType
			SObjectType domainSObjectType = new List<Id>(recordIds)[0].getSObjectType();
			for(Id recordId : recordIds)
				if(recordId.getSobjectType()!=domainSObjectType)
					throw new DeveloperException('Unable to determine SObjectType, Set contains Id\'s from different SObject types');	

			// Construct Selector class and query by Id for the records
			return newInstance(domainSObjectType).selectSObjectsById(recordIds);
		}

		/**
		 * Helper method to query related records to those provided, for example
		 *   if passed a list of Opportunity records and the Account Id field will
		 *   construct internally a list of Account Ids and call the registered 
		 *   Account selector to query the related Account records, e.g.
		 *
		 *     List<Account> accounts = 
		 *        (List<Account>) Applicaiton.Selector.selectByRelationship(myOpps, Opportunity.AccountId);
		 *
		 * @param relatedRecords used to extract the related record Ids, e.g. Opportunty records
		 * @param relationshipField field in the passed records that contains the relationship records to query, e.g. Opportunity.AccountId
		 **/
		public List<SObject> selectByRelationship(List<SObject> relatedRecords, SObjectField relationshipField)
		{
			Set<Id> relatedIds = new Set<Id>();
			for(SObject relatedRecord : relatedRecords)
			{
				Id relatedId = (Id) relatedRecord.get(relationshipField);
				if(relatedId!=null)
					relatedIds.add(relatedId);
			}
			return selectById(relatedIds);
		}

		@TestVisible
		private virtual void setMock(fflib_ISObjectSelector selectorInstance)
		{
			m_sObjectByMockSelector.put(selectorInstance.sObjectType(), selectorInstance);
		} 
	}

	/**
	 * Class implements a Domain class factory
	 **/
	public virtual class DomainFactory
	{
		protected fflib_Application.SelectorFactory m_selectorFactory;

		protected Map<SObjectType, Type> m_sObjectByDomainConstructorType;

		protected Map<SObjectType, fflib_ISObjectDomain> m_sObjectByMockDomain;

		/**
		 * Consturcts a Domain factory, using an instance of the Selector Factory
		 *   and a map of Apex classes implementing fflib_ISObjectDomain by SObjectType
		 *   Note this will not check the Apex classes provided actually implement the interfaces
		 *     since this is not possible in the Apex runtime at present
		 *
		 * @param selectorFactory, e.g. Application.Selector
		 * @param sObjectByDomainConstructorType Map of Apex classes by SObjectType
		 **/
		public DomainFactory(fflib_Application.SelectorFactory selectorFactory,
			Map<SObjectType, Type> sObjectByDomainConstructorType)
		{
			m_selectorFactory = selectorFactory;
			m_sObjectByDomainConstructorType = sObjectByDomainConstructorType;
			m_sObjectByMockDomain = new Map<SObjectType, fflib_ISObjectDomain>();
		}			

		/**
		 * Dynamically constructs an instance of a Domain class for the given record Ids
		 *   Internally uses the Selector Factory to query the records before passing to a
		 *   dynamically constructed instance of the application Apex Domain class
		 *
		 * @param recordIds A list of Id's of the same type
		 * @exception Throws an exception via the Selector Factory if the Ids are not all of the same SObjectType
		 **/
		public virtual fflib_ISObjectDomain newInstance(Set<Id> recordIds)
		{
			return newInstance(m_selectorFactory.selectById(recordIds));

		}	

		/**
		 * Dynamically constructs an instace of the Domain class for the given records
		 *   Will return a Mock implementation if one has been provided via setMock
		 *
		 * @param records A concreate list (e.g. List<Account> vs List<SObject>) of records
		 * @exception Throws an exception if the SObjectType cannot be determined from the list 
		 *              or the constructor for Domain class was not registered for the SOBjectType
		 **/
		public virtual fflib_ISObjectDomain newInstance(List<SObject> records)
		{
			SObjectType domainSObjectType = records.getSObjectType();
			if(domainSObjectType==null)
				throw new DeveloperException('Unable to determine SObjectType');

			// Mock implementation?
			if(m_sObjectByMockDomain.containsKey(domainSObjectType))
				return m_sObjectByMockDomain.get(domainSObjectType);

			// Determine SObjectType and Apex classes for Domain class
			Type domainConstructorClass = m_sObjectByDomainConstructorType.get(domainSObjectType);
			if(domainConstructorClass==null)
				throw new DeveloperException('Domain constructor class not found for SObjectType ' + domainSObjectType);

			// Construct Domain class passing in the queried records
			fflib_SObjectDomain.IConstructable domainConstructor = 
				(fflib_SObjectDomain.IConstructable) domainConstructorClass.newInstance();		
			return (fflib_ISObjectDomain) domainConstructor.construct(records);
		}	

		/**
		 * Dynamically constructs an instace of the Domain class for the given records and SObjectType
		 *   Will return a Mock implementation if one has been provided via setMock
		 *
		 * @param records A list records
		 * @param domainSObjectType SObjectType for list of records
		 * @exception Throws an exception if the SObjectType is not specified or if constructor for Domain class was not registered for the SObjectType
		 *
		 * @remark Will support List<SObject> but all records in the list will be assumed to be of
		 *         the type specified in sObjectType
		 **/
		public virtual fflib_ISObjectDomain newInstance(List<SObject> records, SObjectType domainSObjectType)
		{
			if(domainSObjectType==null)
				throw new DeveloperException('Must specify sObjectType');

			// Mock implementation?
			if(m_sObjectByMockDomain.containsKey(domainSObjectType))
				return m_sObjectByMockDomain.get(domainSObjectType);

			// Determine SObjectType and Apex classes for Domain class
			Type domainConstructorClass = m_sObjectByDomainConstructorType.get(domainSObjectType);
			if(domainConstructorClass==null)
				throw new DeveloperException('Domain constructor class not found for SObjectType ' + domainSObjectType);

			// Construct Domain class passing in the queried records
			fflib_SObjectDomain.IConstructable2 domainConstructor = 
				(fflib_SObjectDomain.IConstructable2) domainConstructorClass.newInstance();
			return (fflib_ISObjectDomain) domainConstructor.construct(records, domainSObjectType);
		}

		@TestVisible
		private virtual void setMock(fflib_ISObjectDomain mockDomain)
		{
			m_sObjectByMockDomain.put(mockDomain.sObjectType(), mockDomain);			
		}
	}

	public class ApplicationException extends Exception { }			

	/**
	 * Exception representing a developer coding error, not intended for end user eyes
	 **/
	public class DeveloperException extends Exception { } 
}