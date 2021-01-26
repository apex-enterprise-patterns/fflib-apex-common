/**
 * File Name: Objects
 * Description: Primitive domain for the object type Object
 *
 * @author : architect ir. Wilhelmus G.J. Velzeboer

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above author notice,
this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.
- Neither the name of the author nor the names of its contributors
may be used to endorse or promote products derived from this software without
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
public virtual with sharing class Objects
		implements fflib_IObjects
{
	// The objects contained in the domain
	protected List<Object> objects { get; private set; }

	// The object type of the objects contained in the domain
	private Object objectType;

	/**
	 * Class constructor
	 *
	 * @param obj The object to contain inside the domain
	 */
	public Objects(Object obj)
	{
		this(new List<Object>{ obj });
	}

	/**
	 * Class constructor
	 *
	 * @param objects The objects to contain inside the domain
	 */
	public Objects(Set<Object> objects)
	{
		this(new List<Object>(objects));
	}

	/**
	 * Class constructor
	 *
	 * @param objects The objects to contain inside the domain
	 */
	public Objects(List<Object> objects)
	{
		this(objects, Object.class);
	}

	/**
	 * Class constructor
	 *
	 * @param objects The objects to contain inside the domain
	 * @param objectType The object type of the given objects
	 */
	public Objects(List<Object> objects, Object objectType)
	{
		this.objects = objects.clone();
		this.objectType = this.objectType;
	}

	/**
	 * @param value Values to check if they are part of the domain
	 *
	 * @return True if the provided value is part of the domain
	 */
	public Boolean contains(Object value)
	{
		return getObjects().contains(value);
	}

	/**
	 * @param values Values to check if they are part of the domain
	 *
	 * @return True if all the provided values are part of the domain
	 */
	public Boolean containsAll(List<Object> values)
	{
		return containsAll(new Set<Object>(values));
	}

	/**
	 * @param values Values to check if they are part of the domain
	 *
	 * @return True if all the provided values are part of the domain
	 */
	public Boolean containsAll(Set<Object> values)
	{
		for (Object value : values)
		{
			if (!getObjects().contains(value)) return false;
		}
		return true;
	}

	/**
	 * @param value Value to check if it is part of the domain
	 *
	 * @return True if the provided value is not part of the domain
	 */
	public Boolean containsNot(Object value)
	{
		return !contains(value);
	}

	/**
	 * @param values Values to check if they are part of the domain
	 *
	 * @return True if all the provided values are not part of the domain
	 */
	public Boolean containsNot(List<Object> values)
	{
		return containsNot(new Set<Object>(values));
	}

	/**
	 * @param values Values to check if they are part of the domain
	 *
	 * @return True if all the provided values are not part of the domain
	 */
	public Boolean containsNot(Set<Object> values)
	{
		for (Object value : values)
		{
			if (getObjects().contains(value)) return false;
		}
		return true;
	}

	/**
	 * @return Returns True is the domain is empty
	 */
	public Boolean isEmpty()
	{
		return (getObjects() == null || getObjects().isEmpty());
	}

	/**
	 * @return Returns True is the domain has objects
	 */
	public Boolean isNotEmpty()
	{
		return !isEmpty();
	}

	/**
	 * @return The object type of the Domain
	 */
	public virtual Object getType()
	{
		return Object.class;
	}

	/**
	 * @return Returns the objects contains in the domain
	 */
	public List<Object> getObjects()
	{
		return this.objects;
	}

	/**
	 * @return Returns a unique set of objects which are contained in the domain
	 */
	public Set<Object> getObjectsSet()
	{
		return new Set<Object>(getObjects());
	}

	protected void setObjects(List<Object> objects)
	{
		this.objects = objects;
	}
}