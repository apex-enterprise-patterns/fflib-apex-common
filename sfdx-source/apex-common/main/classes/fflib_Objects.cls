/**
 * File Name: fflib_Objects 
 * Description: 
 * Copyright (c) 2020 Johnson & Johnson
 * @author: architect ir. Wilhelmus G.J. Velzeboer | wvelzebo@its.jnj.com 
 */
public virtual class fflib_Objects implements fflib_Domain
{
	protected List<Object> Objects { get; private set;}

	/**
	 * Class constructor
	 */
	public fflib_Objects(List<Object> objects)
	{
		this.Objects = objects.clone();
	}

	public virtual Object getType()
	{
		return Object.class;
	}

	public List<Object> getObjects()
	{
		return this.Objects;
	}

	public Boolean contains(Object value)
	{
		return getObjects().contains(value);
	}

	public Boolean containsAll(List<Object> values)
	{
		return containsAll(new Set<Object>(values));
	}

	public Boolean containsAll(Set<Object> values)
	{
		for (Object value : values)
		{
			if (!getObjects().contains(value)) return false;
		}
		return true;
	}

	public Boolean containsNot(Object value)
	{
		return !contains(value);
	}

	public Boolean containsNot(List<Object> values)
	{
		return containsNot(new Set<Object>(values));
	}

	public Boolean containsNot(Set<Object> values)
	{
		for (Object value : values)
		{
			if (getObjects().contains(value)) return false;
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
}