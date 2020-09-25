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
	 * DEPRECATED - Simple Service Factory implementation
	 **/
	public virtual class ServiceFactory extends Deprecated
	{
		protected fflib_ClassicServiceBindingResolver bindingResolver;

		/**
		 * DEPRECATED
		 * Method kept for backwards compatibility with AEP 1.0
		 * It should no longer be used as it will be removed in a future version over AEP 2.0
		 **/
		public ServiceFactory(Map<Type, Type> serviceInterfaceTypeByServiceImplType)
		{
			logDeprecatedMessage('constructor');
			this.bindingResolver = new fflib_ClassicServiceBindingResolver(serviceInterfaceTypeByServiceImplType);
		}

		/**
		 * DEPRECATED
		 * Method kept for backwards compatibility with AEP 1.0
		 * It should no longer be used as it will be removed in a future version over AEP 2.0
		 **/
		public virtual Object newInstance(Type serviceInterfaceType)
		{
			logDeprecatedMessage('newInstance');
			try
			{
				return bindingResolver.newInstance(serviceInterfaceType);
			} catch (fflib_ClassicServiceBindingResolver.DeveloperException e)
			{
				throw new DeveloperException(e.getMessage());
			}
		}

		/**
		 * DEPRECATED
		 * Method kept for backwards compatibility with AEP 1.0
		 * It should no longer be used as it will be removed in a future version over AEP 2.0
		 **/
		@TestVisible
		private virtual void setMock(Type serviceInterfaceType, Object serviceImpl)
		{
			logDeprecatedMessage('setMock');
			bindingResolver.setMock(serviceInterfaceType, serviceImpl);
		}

		private void logDeprecatedMessage(String methodName)
		{
			logDeprecatedMessage(
					'ServiceFactory',
					methodName,
					'fflib_ServiceBindingResolver'
			);
		}
	}

	/**
	 * DEPRECATED - Simple Service Factory implementation
	 **/
	public virtual class SelectorFactory extends Deprecated
	{
		fflib_ClassicSelectorBindingResolver bindingResolver;

		/**
		 * DEPRECATED
		 * Method kept for backwards compatibility with AEP 1.0
		 * It should no longer be used as it will be removed in a future version over AEP 2.0
		 **/
		public SelectorFactory(Map<SObjectType, Type> sObjectBySelectorType)
		{
			logDeprecatedMessage('constructor');
			this.bindingResolver = new fflib_ClassicSelectorBindingResolver(sObjectBySelectorType);
		}

		/**
		 * DEPRECATED
		 * Method kept for backwards compatibility with AEP 1.0
		 * It should no longer be used as it will be removed in a future version over AEP 2.0
		 **/
		public virtual fflib_ISObjectSelector newInstance(Schema.SObjectType sObjectType)
		{
			logDeprecatedMessage('newInstance');
			return bindingResolver.newInstance(sObjectType);
		}

		/**
		 * DEPRECATED
		 * Method kept for backwards compatibility with AEP 1.0
		 * It should no longer be used as it will be removed in a future version over AEP 2.0
		 **/
		public List<SObject> selectById(Set<Id> recordIds)
		{
			logDeprecatedMessage('selectById');
			return bindingResolver.selectById(recordIds);
		}

		/**
		 * DEPRECATED
		 * Method kept for backwards compatibility with AEP 1.0
		 * It should no longer be used as it will be removed in a future version over AEP 2.0
		 **/
		public List<SObject> selectByRelationship(List<SObject> relatedRecords, SObjectField relationshipField)
		{
			logDeprecatedMessage('selectById');
			return bindingResolver.selectByRelationship(relatedRecords, relationshipField);
		}

		/**
		 * DEPRECATED
		 * Method kept for backwards compatibility with AEP 1.0
		 * It should no longer be used as it will be removed in a future version over AEP 2.0
		 **/
		public virtual void setMock(fflib_ISObjectSelector selectorInstance)
		{
			logDeprecatedMessage('setMock');
			bindingResolver.setMock(selectorInstance);
		}

		/**
		 * Added for backwards compatibility, used by the DomainFactory
		 */
		private fflib_SelectorBindingResolver getBindingResolver()
		{
			return this.bindingResolver;
		}

		private void logDeprecatedMessage(String methodName)
		{
			logDeprecatedMessage(
					'SelectorFactory',
					methodName,
					'fflib_SelectorBindingResolver'
			);
		}
	}

	/**
	 * DEPRECATED
	 * Method kept for backwards compatibility with AEP 1.0
	 * It should no longer be used as it will be removed in a future version over AEP 2.0
	 **/
	public virtual class DomainFactory extends Deprecated
	{
		fflib_ClassicDomainBindingResolver bindingResolver;

		/**
		 * DEPRECATED
		 * Method kept for backwards compatibility with AEP 1.0
		 * It should no longer be used as it will be removed in a future version over AEP 2.0
		 **/
		public DomainFactory(
				fflib_Application.SelectorFactory selectorFactory,
				Map<SObjectType, Type> sObjectByDomainConstructorType)
		{
			logDeprecatedMessage('Constructor');
			this.bindingResolver = new fflib_ClassicDomainBindingResolver(
					selectorFactory.getBindingResolver(),
					sObjectByDomainConstructorType
			);
		}

		/**
		 * DEPRECATED
		 * Method kept for backwards compatibility with AEP 1.0
		 * It should no longer be used as it will be removed in a future version over AEP 2.0
		 **/
		public virtual fflib_ISObjectDomain newInstance(Set<Id> recordIds)
		{
			logDeprecatedMessage('newInstance(Set<Id>)');
			return bindingResolver.newInstance(recordIds);
		}

		/**
		 * DEPRECATED
		 * Method kept for backwards compatibility with AEP 1.0
		 * It should no longer be used as it will be removed in a future version over AEP 2.0
		 **/
		public virtual fflib_ISObjectDomain newInstance(List<SObject> records)
		{
			logDeprecatedMessage('newInstance(Set<Id>)');
			return bindingResolver.newInstance(records);
		}

		/**
		 * DEPRECATED
		 * Method kept for backwards compatibility with AEP 1.0
		 * It should no longer be used as it will be removed in a future version over AEP 2.0
		 **/
		public virtual fflib_ISObjectDomain newInstance(List<SObject> records, SObjectType domainSObjectType)
		{
			logDeprecatedMessage('newInstance(Set<Id>)');
			return bindingResolver.newInstance(records, domainSObjectType);
		}

		/**
		 * DEPRECATED
		 * Method kept for backwards compatibility with AEP 1.0
		 * It should no longer be used as it will be removed in a future version over AEP 2.0
		 **/
		@TestVisible
		private virtual void setMock(fflib_ISObjectDomain mockDomain)
		{
			logDeprecatedMessage('setMock');
			this.bindingResolver.setMock(mockDomain);
		}

		private void logDeprecatedMessage(String methodName)
		{
			logDeprecatedMessage(
					'DomainFactory',
					methodName,
					'fflib_DomainBindingResolver'
			);
		}
	}

	private virtual class Deprecated
	{
		protected void logDeprecatedMessage(
				String deprecatedClassName,
				String methodName,
				String replacementClassName)
		{
			System.debug(
					System.LoggingLevel.WARN,
					String.format(
							'Use of the method fflib_Application.{0}.{1} is deprecated in AEP 2.0,'
									+ ' use an implementation of {2}',
							new List<String>
							{
									deprecatedClassName,
									methodName,
									replacementClassName
							}
					)
			);
		}
	}

	public class ApplicationException extends Exception { }			

	/**
	 * Exception representing a developer coding error, not intended for end user eyes
	 **/
	public class DeveloperException extends Exception { } 
}