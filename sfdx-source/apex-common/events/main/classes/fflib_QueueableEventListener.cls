/**
 * File Name: fflib_QueueableEventListener 
 * Description: Abstract definition for a listener that can be executed as Queueable Apex
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
public abstract with sharing class fflib_QueueableEventListener
		implements fflib_IEventListener, Queueable
{
	private Boolean runAsQueueable = false;
	private Queueable nextQueueableAction;
	protected fflib_IEvent event;

	public void handle(fflib_IEvent event)
	{
		this.event = event;
		if (runAsQueueable)
		{
			System.enqueueJob( this );
		}
		else
		{
			run();
		}
	}

	public fflib_QueueableEventListener setRunAsQueueable()
	{
		this.runAsQueueable = true;
		return this;
	}

	public fflib_QueueableEventListener setNextQueueableAction(Queueable queueable)
	{
		this.nextQueueableAction = queueable;
		return this;
	}

	public void execute(QueueableContext param1)
	{
		try
		{
			run();
		}
		catch (Exception e)
		{
			// Todo - Add option for dynamic error handling or fflib Logger
			System.debug(e);
			System.debug(e.getStackTraceString());
		}

		if (hasNextQueueableAction())
		{
			System.enqueueJob( nextQueueableAction );
		}
	}

	protected Boolean hasNextQueueableAction()
	{
		return nextQueueableAction != null;
	}

	abstract void run();
}