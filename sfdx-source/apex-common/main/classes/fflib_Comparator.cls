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
public with sharing class fflib_Comparator
{
	public static Boolean compareTo(Object object1, fflib_Operator operator, Object object2)
	{
		Integer result = compare(object1, object2);

		if (operator == fflib_Operator.EQUALS && result == 0)
			return true;
		else if (operator == fflib_Operator.NOT_EQUALS && result != 0)
			return true;
		else if (operator == fflib_Operator.LESS_THAN && result == -1)
			return true;
		else if (operator == fflib_Operator.LESS_THAN_OR_EQUAL_TO && result != 1)
			return true;
		else if (operator == fflib_Operator.GREATER_THAN && result == 1)
			return true;
		else if (operator == fflib_Operator.GREATER_THAN_OR_EQUAL_TO && result != -1)
			return true;
		else
				return false;
	}

	public static Integer compare(Object object1, Object object2)
	{
		if (object1 == null && object2 == null)
			return 0;
		else if (object1 == null)
			return -1;
		else if (object2 == null)
			return 1;
		else if (object1 instanceof Boolean && object2 instanceof Boolean)
			return compare((Boolean) object1, (Boolean) object2);
		else if (object1 instanceof Date && object2 instanceof Date)
			return compare((Date) object1, (Date) object2);
		else if (object1 instanceof Datetime && object2 instanceof Datetime)
			return compare((Datetime) object1, (Datetime) object2);
		else if (object1 instanceof Integer && object2 instanceof Integer)
			return compare((Integer) object1, (Integer) object2);
		else if (object1 instanceof Long && object2 instanceof Long)
			return compare((Long) object1, (Long) object2);
		else if (object1 instanceof Double && object2 instanceof Double)
			return compare((Double) object1, (Double) object2);
		else if (object1 instanceof Time && object2 instanceof Time)
			return compare((Time) object1, (Time) object2);
		else if (object1 instanceof String && object2 instanceof String)
			return compare((String) object1, (String) object2);
		else
				throw new IllegalArgumentException(
						'Both arguments must be type Boolean, Date, Datetime, Decimal, Double, ID, Integer, Long, Time, or String');
	}

	public static Integer compare(Boolean b1, Boolean b2)
	{
		if (!b1 && b2) return -1;
		else if (b1 == b2) return 0;
		else return 1;
	}

	public static Integer compare(Date d1, Date d2)
	{
		if (d1 < d2) return -1;
		else if (d1 == d2) return 0;
		else return 1;
	}

	public static Integer compare(Datetime d1, Datetime d2)
	{
		if (d1 < d2) return -1;
		else if (d1 == d2) return 0;
		else return 1;
	}

	public static Integer compare(Double d1, Double d2)
	{
		if (d1 < d2) return -1;
		else if (d1 == d2) return 0;
		else return 1;
	}

	public static Integer compare(Integer i1, Integer i2)
	{
		if (i1 < i2) return -1;
		else if (i1 == i2) return 0;
		else return 1;
	}

	public static Integer compare(Long l1, Long l2)
	{
		if (l1 < l2) return -1;
		else if (l1 == l2) return 0;
		else return 1;
	}

	public static Integer compare(String s1, String s2)
	{
		if (s1 < s2) return -1;
		else if (s1 == s2) return 0;
		else return 1;
	}

	public static Integer compare(Time t1, Time t2)
	{
		return compare('' + t1, '' + t2);
	}

	/**
	 * check if a Set contains a value
	 * @param object1 - Object - a Set of objects
	 * @param object2 - Object - the object to check if its a member of the Set
	 * @return Boolean - TRUE if the object is a member of the Set
	 */
	public static Boolean contains(Object object1, Object object2)
	{
		if (object1 == null && object2 == null)
			return true;
		else if (object1 == null)
			return false;
		else if (object2 == null)
			return false;
		else if (object1 instanceof set<Date> && object2 instanceof Date)
			return ((set<Date>) object1).contains((date) object2);
		else if (object1 instanceof set<Datetime> && object2 instanceof Datetime)
			return ((set<Datetime>) object1).contains((Datetime) object2);
		else if (object1 instanceof set<Double> && object2 instanceof Double)
			return ((set<Double>) object1).contains((Double) object2);
		else if (object1 instanceof set<Id> && object2 instanceof Id)
			return ((set<Id>) object1).contains((Id) object2);
		else if (object1 instanceof set<Integer> && object2 instanceof Integer)
			return ((set<Integer>) object1).contains((Integer) object2);
		else if (object1 instanceof set<Long> && object2 instanceof Long)
			return ((set<Long>) object1).contains((Long) object2);
		else if (object1 instanceof set<Object>)
			return ((set<Object>) object1).contains((Object) object2);
		else if (object1 instanceof set<Time> && object2 instanceof Time)
			return ((set<Time>) object1).contains((Time) object2);
		else if (object1 instanceof set<String> && object2 instanceof String)
			return ((set<String>) object1).contains((String) object2);
		else
				throw new IllegalArgumentException(
						'Both arguments must be type Date, Datetime, Decimal, Double, ID, Integer, Long, Object, Time, Object or String');
	}

	public class IllegalArgumentException extends Exception	{}
}