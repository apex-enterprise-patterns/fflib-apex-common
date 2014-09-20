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
 * This is a generated class with some manual modifications
 *   Use the Apex Mocks Generator, then re-apply the 'virtual' modifier
 **/
@IsTest
public class fflib_SObjectMocks 
{
	public virtual class SObjectDomain implements fflib_ISObjectDomain
	{
		private fflib_ApexMocks mocks;

		public SObjectDomain(fflib_ApexMocks mocks)
		{
			this.mocks = mocks;
		}

		public SObjectType sObjectType()
		{
			if (mocks.Verifying)
			{
				mocks.verifyMethodCall(this, 'sObjectType', new List<Object> {});
			}
			else if (mocks.Stubbing)
			{
				mocks.prepareMethodReturnValue(this, 'sObjectType', new List<Object> {});
				return null;
			}
			else
			{
				mocks.recordMethod(this, 'sObjectType', new List<Object> {});

				fflib_MethodReturnValue methodReturnValue = mocks.getMethodReturnValue(this, 'sObjectType', new List<Object> {});

				if (methodReturnValue != null)
				{
					if (methodReturnValue.ReturnValue instanceof Exception)
					{
						throw ((Exception) methodReturnValue.ReturnValue);
					}

					return (SObjectType) methodReturnValue.ReturnValue;
				}
			}

			return null;
		}

		public List<SObject> getRecords()
		{
			if (mocks.Verifying)
			{
				mocks.verifyMethodCall(this, 'getRecords', new List<Object> {});
			}
			else if (mocks.Stubbing)
			{
				mocks.prepareMethodReturnValue(this, 'getRecords', new List<Object> {});
				return null;
			}
			else
			{
				mocks.recordMethod(this, 'getRecords', new List<Object> {});

				fflib_MethodReturnValue methodReturnValue = mocks.getMethodReturnValue(this, 'getRecords', new List<Object> {});

				if (methodReturnValue != null)
				{
					if (methodReturnValue.ReturnValue instanceof Exception)
					{
						throw ((Exception) methodReturnValue.ReturnValue);
					}

					return (List<SObject>) methodReturnValue.ReturnValue;
				}
			}

			return null;
		}		
	}

	public virtual class SObjectSelector implements fflib_ISObjectSelector
	{
		private fflib_ApexMocks mocks;

		public SObjectSelector(fflib_ApexMocks mocks)
		{
			this.mocks = mocks;
		}

		public Schema.SObjectType sObjectType()
		{
			if (mocks.Verifying)
			{
				mocks.verifyMethodCall(this, 'sObjectType', new List<Object> {});
			}
			else if (mocks.Stubbing)
			{
				mocks.prepareMethodReturnValue(this, 'sObjectType', new List<Object> {});
				return null;
			}
			else
			{
				mocks.recordMethod(this, 'sObjectType', new List<Object> {});

				fflib_MethodReturnValue methodReturnValue = mocks.getMethodReturnValue(this, 'sObjectType', new List<Object> {});

				if (methodReturnValue != null)
				{
					if (methodReturnValue.ReturnValue instanceof Exception)
					{
						throw ((Exception) methodReturnValue.ReturnValue);
					}

					return (Schema.SObjectType) methodReturnValue.ReturnValue;
				}
			}

			return null;
		}

		public List<SObject> selectSObjectsById(Set<Id> idSet)
		{
			if (mocks.Verifying)
			{
				mocks.verifyMethodCall(this, 'selectSObjectsById', new List<Object> {idSet});
			}
			else if (mocks.Stubbing)
			{
				mocks.prepareMethodReturnValue(this, 'selectSObjectsById', new List<Object> {idSet});
				return null;
			}
			else
			{
				mocks.recordMethod(this, 'selectSObjectsById', new List<Object> {idSet});

				fflib_MethodReturnValue methodReturnValue = mocks.getMethodReturnValue(this, 'selectSObjectsById', new List<Object> {idSet});

				if (methodReturnValue != null)
				{
					if (methodReturnValue.ReturnValue instanceof Exception)
					{
						throw ((Exception) methodReturnValue.ReturnValue);
					}

					return (List<SObject>) methodReturnValue.ReturnValue;
				}
			}

			return null;
		}
	}

	public virtual class SObjectUnitOfWork implements fflib_ISObjectUnitOfWork
	{
		private fflib_ApexMocks mocks;

		public SObjectUnitOfWork(fflib_ApexMocks mocks)
		{
			this.mocks = mocks;
		}

		public void registerNew(SObject record)
		{
			if (mocks.Verifying)
			{
				mocks.verifyMethodCall(this, 'registerNew', new List<Object> {record});
			}
			else
			{
				mocks.recordMethod(this, 'registerNew', new List<Object> {record});
			}
		}

		public void registerNew(SObject record, Schema.sObjectField relatedToParentField, SObject relatedToParentRecord)
		{
			if (mocks.Verifying)
			{
				mocks.verifyMethodCall(this, 'registerNew', new List<Object> {record, relatedToParentField, relatedToParentRecord});
			}
			else
			{
				mocks.recordMethod(this, 'registerNew', new List<Object> {record, relatedToParentField, relatedToParentRecord});
			}
		}

		public void registerRelationship(SObject record, Schema.sObjectField relatedToField, SObject relatedTo)
		{
			if (mocks.Verifying)
			{
				mocks.verifyMethodCall(this, 'registerRelationship', new List<Object> {record, relatedToField, relatedTo});
			}
			else
			{
				mocks.recordMethod(this, 'registerRelationship', new List<Object> {record, relatedToField, relatedTo});
			}
		}

		public void registerDirty(SObject record)
		{
			if (mocks.Verifying)
			{
				mocks.verifyMethodCall(this, 'registerDirty', new List<Object> {record});
			}
			else
			{
				mocks.recordMethod(this, 'registerDirty', new List<Object> {record});
			}
		}

		public void registerDeleted(SObject record)
		{
			if (mocks.Verifying)
			{
				mocks.verifyMethodCall(this, 'registerDeleted', new List<Object> {record});
			}
			else
			{
				mocks.recordMethod(this, 'registerDeleted', new List<Object> {record});
			}
		}

		public void commitWork()
		{
			if (mocks.Verifying)
			{
				mocks.verifyMethodCall(this, 'commitWork', new List<Object> {});
			}
			else
			{
				mocks.recordMethod(this, 'commitWork', new List<Object> {});
			}
		}
	}
}