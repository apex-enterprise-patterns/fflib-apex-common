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
public virtual class fflib_Objects implements fflib_IObjects
{
	protected List<Object> objects { get; private set;} { objects = new List<Object>(); }

	/**
	 * Class constructor
	 */
	public fflib_Objects(List<Object> objects)
	{
		this.objects = objects.clone();
	}

	public virtual Object getType()
	{
		return Object.class;
	}

	public List<Object> getObjects()
	{
		return this.objects;
	}

	public Boolean contains(Object value)
	{
		return getObjects()?.contains(value);
	}

	public Boolean containsAll(List<Object> values)
	{
		if (values == null) return false;

		return containsAll(new Set<Object>(values));
	}

	public Boolean containsAll(Set<Object> values)
	{
		if (values == null) return false;

		for (Object value : values)
		{
			if (!getObjects()?.contains(value)) return false;
		}
		return true;
	}

	public Boolean containsNot(Object value)
	{
		return !contains(value);
	}

	public Boolean containsNot(List<Object> values)
	{
		if (values == null) return true;

		return containsNot(new Set<Object>(values));
	}

	public Boolean containsNot(Set<Object> values)
	{
		if (values == null) return true;

		for (Object value : values)
		{
			if (getObjects()?.contains(value)) return false;
		}
		return true;
	}

	public Boolean isEmpty()
	{
		return (getObjects() == null || getObjects().isEmpty());
	}

	public Boolean isNotEmpty()
	{
		return !isEmpty();
	}

	public Integer size()
	{
		return getObjects().size();
	}

	protected void setObjects(List<Object> objects)
	{
		this.objects = objects;
	}
}