/**
 * File Name: fflib_EventListenerConfig
 * Description: a DTO class with configurations for an event listener
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
public virtual with sharing class fflib_EventListenerConfig
		implements Comparable
{
	protected Type listenerType;
	protected Integer priority = 0;
	protected Boolean runInQueue = false;

	public fflib_EventListenerConfig(Type listenerType)
	{
		this.listenerType = listenerType;
	}

	public Integer compareTo(Object compareTo)
	{
		fflib_EventListenerConfig compareToListener = (fflib_EventListenerConfig) compareTo;
		Integer compareToPriority = compareToListener.getPriority();
		if (this.priority == compareToPriority) return 0;
		if (this.priority > compareToPriority) return -1;
		return 1;
	}

	public Integer getPriority()
	{
		return this.priority;
	}

	public Type getListenerType()
	{
		return this.listenerType;
	}

	public Boolean isRunInQueue()
	{
		return this.runInQueue;
	}

	public fflib_EventListenerConfig setPriority(Integer priority)
	{
		this.priority = priority;
		return this;
	}

	public fflib_EventListenerConfig setRunInQueue()
	{
		return setRunInQueue(true);
	}

	public fflib_EventListenerConfig setRunInQueue(Boolean isRunningInQueue)
	{
		this.runInQueue = isRunningInQueue;
		return this;
	}
}