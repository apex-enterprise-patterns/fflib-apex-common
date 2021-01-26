/**
 * File Name: fflib_SObjectEvent 
 * Description: A pre-constructed event used for SObject Trigger events
 *
 * @author: architect ir. Wilhelmus G.J. Velzeboer
 *
 * Redistribution and use in source and binary forms, with or without modification,
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above author notice,
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 * - Neither the name of the author nor the names of its contributors
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
 */
public virtual with sharing class fflib_SObjectEvent implements fflib_IEvent
{
	@TestVisible
	private List<SObject> records
	{
		get
		{
			if (records == null)
			{
				records = Trigger.new;
			}
			return records;
		}
		set;
	}

	@TestVisible
	private Map<Id, SObject> oldMap
	{
		get
		{
			if (oldMap == null)
			{
				oldMap = Trigger.oldMap;
			}
			return oldMap;
		}
		set;
	}

	@TestVisible
	private System.TriggerOperation operationType
	{
		get
		{
			if (operationType == null)
			{
				operationType = Trigger.operationType;
			}
			return operationType;
		}
		set;
	}

	private String eventName
	{
		get
		{
			if (eventName == null)
			{
				eventName = String.format(
				                    '{0}.{1}',
                    new List<String>
                    {
                        ((List<SObject>) records).getSObjectType().getDescribe().getName(),
                        operationType.name()
                    }
				);
			}
			return eventName;
		}
		set;
	}

	/**
	 * Class constructor
	 */
	public fflib_SObjectEvent()
	{

	}

	public String getName()
	{
		return this.eventName;
	}

	public Object getData()
	{
		return records;
	}

	public List<SObject> getRecords()
	{
		return records;
	}

	public Map<Id, SObject> getOldMap()
	{
		return oldMap;
	}

	public System.TriggerOperation getOperationType()
	{
		return operationType;
	}
}