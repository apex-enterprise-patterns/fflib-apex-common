/**
 * File Name: fflib_SObjectEventListener
 * Description: Abstract class for handling SObject Trigger events
 *              in a similar manner as the legacy fflib_SObjectDomain trigger handler
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
public abstract class fflib_SObjectEventListener
		extends fflib_QueueableEventListener
		implements fflib_EventListener
{
	protected List<SObject> records;

	public void run()
	{
		fflib_SObjectEvent sObjectEvent = (fflib_SObjectEvent) event;
		records = sObjectEvent.getRecords();

		switch on sObjectEvent.getOperationType()
		{
			when BEFORE_INSERT
			{
				onBeforeInsert();
			}
			when AFTER_INSERT
			{
				onAfterInsert();
			}
			when BEFORE_UPDATE
			{
				onBeforeUpdate();
			}
			when AFTER_UPDATE
			{
				onAfterUpdate();
			}
			when BEFORE_DELETE
			{
				onBeforeDelete();
			}
			when AFTER_DELETE
			{
				onAfterDelete();
			}
			when AFTER_UNDELETE
			{
				onAfterUndelete();
			}
		}
	}

	/**
	 * Override this to perform processing during the before insert phase
	 **/
	public virtual void onBeforeInsert() { }

	/**
	 * Override this to perform processing during the before update phase
	 **/
	public virtual void onBeforeUpdate() { }

	/**
	 * Override this to perform processing during the before delete phase
	 **/
	public virtual void onBeforeDelete() { }

	/**
	 * Override this to perform processing during the after insert phase
	 **/
	public virtual void onAfterInsert()	{ }

	/**
	 * Override this to perform processing during the after update phase
	 **/
	public virtual void onAfterUpdate()	{ }

	/**
	 * Override this to perform processing during the after delete phase, this is called by the handleAfterDelete method
	 **/
	public virtual void onAfterDelete()	{ }

	/**
	 * Override this to perform processing during the after undelete phase, this is called by the handleAfterDelete method
	 **/
	public virtual void onAfterUndelete() {	}
}