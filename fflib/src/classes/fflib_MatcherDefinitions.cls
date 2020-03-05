/**
 * Copyright (c) 2014, FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
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
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/**
 * Class providing Apex Mocks standard matcher implementations.
 * You shouldn't need to reference the classes directly outside of the ApexMocks framework, instead use the equivalent helper method in fflib_Match
 * to construct the matcher, register the matcher and return an object of the correct type to be called in your unit test.
 * E.g. Don't construct Eq(Object toMatch), instead call fflib_Match.eq(Object toMatch).
 */
public with sharing class fflib_MatcherDefinitions
{
	/**
	 * Connective - Enum representing the possible operators for the Combined matcher. Possible values: ALL, AT_LEAST_ONE, NONE
	 */
	public Enum Connective
	{
		ALL,
		AT_LEAST_ONE,
		NONE
	}

	/*
	 * COMBINED MATCHER
	 */

	/**
	 * Combined matcher: compares the supplied argument matches one, all or none of the internal matchers
	 */
	public class Combined implements fflib_IMatcher
	{
		private Connective connectiveExpression;
		private List<fflib_IMatcher> internalMatchers;

		/**
		 * Combined constructor
		 * @param connectiveExpression Controls the combination mode, i.e. if we need to match all, any or none of the inner matchers
		 * @param internalMatchers An ordered list of the internal matchers to be combined
		 * @return fflib_MatcherDefinitions.Combined A new Combined instance
		 */
		public Combined(Connective connectiveExpression, List<fflib_IMatcher> internalMatchers)
		{
			this.connectiveExpression = validate(connectiveExpression);
			this.internalMatchers = validate(internalMatchers);
		}

		public Boolean matches(Object arg)
		{
			for (fflib_IMatcher internalMatcher : internalMatchers)
			{
				if (internalMatcher.matches(arg))
				{
					if (connectiveExpression == Connective.AT_LEAST_ONE)
					{
						//At least one match => success!
						return true;
					}
					else if (connectiveExpression == Connective.NONE)
					{
						//At least one match => failure!
						return false;
					}
				}
				else if (connectiveExpression == Connective.ALL)
				{
					//At least one mismatch => failure!
					return false;
				}
			}

			//We didn't return early.
			//If matching any, must have been no matches => failure!
			//If matching all, must have been all matches => success!
			//If matching none, must have been all mismatches => success!
			return connectiveExpression != Connective.AT_LEAST_ONE;
		}

		private Connective validate(Connective connectiveExpression)
		{
			if (connectiveExpression == null)
			{
				throw new fflib_ApexMocks.ApexMocksException('Invalid connective expression: ' + connectiveExpression);
			}

			return connectiveExpression;
		}

		private List<fflib_IMatcher>  validate(List<fflib_IMatcher> innerMatchers)
		{
			if (innerMatchers == null || innerMatchers.isEmpty())
			{
				throw new fflib_ApexMocks.ApexMocksException('Invalid inner matchers: ' + innerMatchers);
			}

			return innerMatchers;
		}
	}

	/*
	 * OBJECT MATCHERS
	 */

	/**
	 * Eq matcher: checks if the supplied argument is equal (==) to a specified object
	 */
	public class Eq implements fflib_IMatcher
	{
		private Object toMatch;

		/**
		 * Eq constructor
		 * @param toMatch The object to be compared
		 * @return fflib_MatcherDefinitions.Eq A new Eq instance
		 */
		public Eq(Object toMatch)
		{
			this.toMatch = validateNotNull(toMatch);
		}

		public Boolean matches(Object arg)
		{
			return toMatch == arg;
		}
	}

	/**
	 * RefEq matcher: checks if the supplied argument is a reference to the same object (===) as a specified object
	 */
	public class RefEq implements fflib_IMatcher
	{
		private Object toMatch;

		/**
		 * RefEq constructor
		 * @param toMatch The object to be compared
		 * @return fflib_MatcherDefinitions.RefEq A new RefEq instance
		 */
		public RefEq(Object toMatch)
		{
			this.toMatch = validateNotNull(toMatch);
		}

		public Boolean matches(Object arg)
		{
			return toMatch === arg;
		}
	}

	/*
	 * ANY MATCHERS
	 */

	/**
	 * AnyBoolean matcher: checks if the supplied argument is an instance of a Boolean
	 */
	public class AnyBoolean implements fflib_IMatcher
	{
		public Boolean matches(Object arg)
		{
			return arg != null && arg instanceof Boolean;
		}
	}

	/**
	 * AnyDate matcher: checks if the supplied argument is an instance of a Date
	 */
	public class AnyDate implements fflib_IMatcher
	{
		public Boolean matches(Object arg)
		{
			return arg != null && arg instanceof Date;
		}
	}

	/**
	 * AnyDatetime matcher: checks if the supplied argument is an instance of a Datetime
	 */
	public class AnyDatetime implements fflib_IMatcher
	{
		public Boolean matches(Object arg)
		{
			return arg != null && arg instanceof Datetime;
		}
	}

	/**
	 * AnyDecimal matcher: checks if the supplied argument is an instance of a Decimal
	 */
	public class AnyDecimal implements fflib_IMatcher
	{
		public Boolean matches(Object arg)
		{
			return arg != null && arg instanceof Decimal;
		}
	}

	/**
	 * AnyDouble matcher: checks if the supplied argument is an instance of a Double
	 */
	public class AnyDouble implements fflib_IMatcher
	{
		public Boolean matches(Object arg)
		{
			return arg != null && arg instanceof Double;
		}
	}

	/**
	 * AnyFieldSet matcher: checks if the supplied argument is an instance of a FieldSet
	 */
	public class AnyFieldSet implements fflib_IMatcher
	{
		public Boolean matches(Object arg)
		{
			return arg != null && arg instanceof Schema.FieldSet;
		}
	}

	/**
	 * AnyId matcher: checks if the supplied argument is an instance of an Id
	 */
	public class AnyId implements fflib_IMatcher
	{
		public Boolean matches(Object arg)
		{
			return arg != null && arg instanceof Id;
		}
	}

	/**
	 * AnyInteger matcher: checks if the supplied argument is an instance of an Integer
	 */
	public class AnyInteger implements fflib_IMatcher
	{
		public Boolean matches(Object arg)
		{
			return arg != null && arg instanceof Integer;
		}
	}

	/**
	 * AnyList matcher: checks if the supplied argument is an instance of a List
	 */
	public class AnyList implements fflib_IMatcher
	{
		public Boolean matches(Object arg)
		{
			return arg != null && arg instanceof List<Object>;
		}
	}

	/**
	 * AnyLong matcher: checks if the supplied argument is an instance of a Long
	 */
	public class AnyLong implements fflib_IMatcher
	{
		public Boolean matches(Object arg)
		{
			return arg != null && arg instanceof Long;
		}
	}

	/**
	 * AnyObject matcher: checks if the supplied argument is an instance of an Object
	 */
	public class AnyObject implements fflib_IMatcher
	{
		public Boolean matches(Object arg)
		{
			return arg != null;
		}
	}

	/**
	 * AnyString matcher: checks if the supplied argument is an instance of a String
	 */
	public class AnyString implements fflib_IMatcher
	{
		public Boolean matches(Object arg)
		{
			return arg != null && arg instanceof String;
		}
	}

	/**
	 * AnySObject matcher: checks if the supplied argument is an instance of an SObject
	 */
	public class AnySObject implements fflib_IMatcher
	{
		public Boolean matches(Object arg)
		{
			return arg != null && arg instanceof SObject;
		}
	}

	/**
	 * AnySObjectField matcher: checks if the supplied argument is an instance of an SObjectField
	 */
	public class AnySObjectField implements fflib_IMatcher
	{
		public Boolean matches(Object arg)
		{
			return arg != null && arg instanceof SObjectField;
		}
	}

	/**
	 * AnySObjectType matcher: checks if the supplied argument is an instance of an SObjectType
	 */
	public class AnySObjectType implements fflib_IMatcher
	{
		public Boolean matches(Object arg)
		{
			return arg != null && arg instanceof SObjectType;
		}
	}

	/*
	 * DATETIME MATCHERS
	 */

	/**
	 * DatetimeAfter matcher: checks if the supplied argument is after a specified datetime
	 */
	public class DatetimeAfter implements fflib_IMatcher
	{
		private Datetime fromDatetime;
		private Boolean inclusive;

		/**
		 * DatetimeAfter constructor
		 * @param fromDatetime The datetime to be compared
		 * @param inclusive Whether or not dates equal to the fromDatetime should be considered a match
		 * @return fflib_MatcherDefinitions.DatetimeAfter A new DatetimeAfter instance
		 */
		public DatetimeAfter(Datetime fromDatetime, Boolean inclusive)
		{
			this.fromDatetime = (Datetime)validateNotNull(fromDatetime);
			this.inclusive = (Boolean)validateNotNull(inclusive);
		}

		public Boolean matches(Object arg)
		{
			if (arg instanceof Datetime)
			{
				Datetime datetimeToCompare = (Datetime)arg;
				return inclusive ? fromDatetime <= datetimeToCompare : fromDatetime < datetimeToCompare;
			}

			return false;
		}
	}

	/**
	 * DatetimeBefore matcher: checks if the supplied argument is before a specified datetime
	 */
	public class DatetimeBefore implements fflib_IMatcher
	{
		private Datetime toDatetime;
		private Boolean inclusive;

		/**
		 * DatetimeBefore constructor
		 * @param toDatetime The datetime to be compared
		 * @param inclusive Whether or not dates equal to the toDatetime should be considered a match
		 * @return fflib_MatcherDefinitions.DatetimeBefore A new DatetimeBefore instance
		 */
		public DatetimeBefore(Datetime toDatetime, Boolean inclusive)
		{
			this.toDatetime = (Datetime)validateNotNull(toDatetime);
			this.inclusive = (Boolean)validateNotNull(inclusive);
		}

		public Boolean matches(Object arg)
		{
			if (arg instanceof Datetime)
			{
				Datetime datetimeToCompare = (Datetime)arg;
				return inclusive ? datetimeToCompare <= toDatetime : datetimeToCompare < toDatetime;
			}

			return false;
		}
	}

	/**
	 * DatetimeBetween matcher: checks if the supplied argument is between two specified datetimes
	 */
	public class DatetimeBetween implements fflib_IMatcher
	{
		private Datetime fromDatetime;
		private Boolean inclusiveFrom;
		private Datetime toDatetime;
		private Boolean inclusiveTo;

		/**
		 * DatetimeBetween constructor
		 * @param fromDatetime The lower bound datetime to be compared
		 * @param inclusiveFrom Whether or not dates equal to the fromDatetime should be considered a match
		 * @param toDatetime The upper bound dateetime to be compared
		 * @param inclusiveTo Whether or not dates equal to the toDatetime should be considered a match
		 * @return fflib_MatcherDefinitions.DatetimeBetween A new DatetimeBetween instance
		 */
		public DatetimeBetween(Datetime fromDatetime, Boolean inclusiveFrom, Datetime toDatetime, Boolean inclusiveTo)
		{
			this.fromDatetime = (Datetime)validateNotNull(fromDatetime);
			this.inclusiveFrom = (Boolean)validateNotNull(inclusiveFrom);
			this.toDatetime = (Datetime)validateNotNull(toDatetime);
			this.inclusiveTo = (Boolean)validateNotNull(inclusiveTo);
		}

		public Boolean matches(Object arg)
		{
			if (arg instanceof Datetime)
			{
				Datetime datetimeToCompare = (Datetime)arg;
				if ((inclusiveFrom ? datetimeToCompare >= fromDatetime : datetimeToCompare > fromDatetime)
						&& (inclusiveTo ? datetimeToCompare <= toDatetime : datetimeToCompare < toDatetime))
				{
					return true;
				}
			}

			return false;
		}
	}

	/*
	 * DECIMAL (AND OTHER NUMBER) MATCHERS
	 */

	/**
	 * DecimalBetween matcher: checks if the supplied argument is between two specified decimals
	 */
	public class DecimalBetween implements fflib_IMatcher
	{
		private Decimal lower;
		private Boolean inclusiveLower;
		private Decimal upper;
		private Boolean inclusiveUpper;

		/**
		 * DecimalBetween constructor
		 * @param lower The lower bound number to be compared
		 * @param inclusiveLower Whether or not numbers equal to lower should be considered a match
		 * @param upper The upper bound number to be compared
		 * @param inclusiveUpper Whether or not numbers equal to upper should be considered a match
		 * @return fflib_MatcherDefinitions.DecimalBetween A new DecimalBetween instance
		 */
		public DecimalBetween(Decimal lower, Boolean inclusiveLower, Decimal upper, Boolean inclusiveUpper)
		{
			this.lower = (Decimal)validateNotNull(lower);
			this.inclusiveLower = (Boolean)validateNotNull(inclusiveLower);
			this.upper = (Decimal)validateNotNull(upper);
			this.inclusiveUpper = (Boolean)validateNotNull(inclusiveUpper);
		}

		public Boolean matches(Object arg)
		{
			if (arg != null && arg instanceof Decimal)
			{
				Decimal longArg = (Decimal)arg;

				if ((inclusiveLower ? longArg >= lower : longArg > lower)
						&& (inclusiveUpper ? longArg <= upper : longArg < upper))
				{
					return true;
				}
			}

			return false;
		}
	}

	/**
	 * DecimalLessThan matcher: checks if the supplied argument is less than a specified decimal
	 */
	public class DecimalLessThan implements fflib_IMatcher
	{
		private Decimal toMatch;
		private Boolean inclusive;

		/**
		 * DecimalLessThan constructor
		 * @param toMatch The number to be compared against
		 * @param inclusive Whether or not numbers equal to toMatch should be considered a match
		 * @return fflib_MatcherDefinitions.DecimalLessThan A new DecimalLessThan instance
		 */
		public DecimalLessThan(Decimal toMatch, Boolean inclusive)
		{
			this.toMatch = (Decimal)validateNotNull(toMatch);
			this.inclusive = (Boolean)validateNotNull(inclusive);
		}

		public Boolean matches(Object arg)
		{
			if (arg != null && arg instanceof Decimal)
			{
				Decimal longArg = (Decimal)arg;
				return inclusive ? longArg <= toMatch : longArg < toMatch;
			}

			return false;
		}
	}

	/**
	 * DecimalMoreThan matcher: checks if the supplied argument is greater than a specified decimal
	 */
	public class DecimalMoreThan implements fflib_IMatcher
	{
		private Decimal toMatch;
		private Boolean inclusive;

		/**
		 * DecimalMoreThan constructor
		 * @param toMatch The number to be compared against
		 * @param inclusive Whether or not numbers equal to toMatch should be considered a match
		 * @return fflib_MatcherDefinitions.DecimalMoreThan A new DecimalMoreThan instance
		 */
		public DecimalMoreThan(Decimal toMatch, Boolean inclusive)
		{
			this.toMatch = (Decimal)validateNotNull(toMatch);
			this.inclusive = (Boolean)validateNotNull(inclusive);
		}

		public Boolean matches(Object arg)
		{
			if (arg != null && arg instanceof Decimal)
			{
				Decimal longArg = (Decimal)arg;
				return inclusive ? longArg >= toMatch : longArg > toMatch;
			}

			return false;
		}
	}

	/**
	 * FIELDSET MATCHERS
	 */

	/**
	 * FieldSetEquivalentTo matcher: checks the supplied argument is a field set with the same field set members as a specified field set
	 * This matcher is needed because equivalent FieldSets do not pass == checks, and we can't override equals/hashcode on FieldSets.
	 */
	public class FieldSetEquivalentTo implements fflib_IMatcher
	{
		private final Set<Schema.FieldSetMember> toMatch;

		/*
		 * Dirty test-only constructor, allowing us to test this class even if there are no field sets defined in the current org.
		 */
		@TestVisible
		public FieldSetEquivalentTo()
		{
			this.toMatch = null;
		}

		public FieldSetEquivalentTo(Schema.FieldSet toMatch)
		{
			this.toMatch = new Set<Schema.FieldSetMember>(((Schema.FieldSet)validateNotNull(toMatch)).getFields());
		}

		public Boolean matches(Object arg)
		{
			return (toMatch != null && arg != null && arg instanceof Schema.FieldSet) ? toMatch == new Set<Schema.FieldSetMember>(((FieldSet)arg).getFields()) : false;
		}
	}

	/*
	 * IS MATCHERS
	 */

	/**
	 * IsNotNull matcher: checks the supplied argument is not null
	 */
	public class IsNotNull implements fflib_IMatcher
	{
		public Boolean matches(Object arg)
		{
			return arg != null;
		}
	}

	/**
	 * IsNull matcher: checks the supplied argument is null
	 */
	public class IsNull implements fflib_IMatcher
	{
		public Boolean matches(Object arg)
		{
			return arg == null;
		}
	}

	/*
	 * LIST MATCHERS
	 */

	/**
	 * ListContains matcher: checks if the supplied argument is equal (==) to any of the elements in a specified list
	 */
	public class ListContains implements fflib_IMatcher
	{
		private Object toMatch;

		/**
		 * ListContains constructor
		 * @param toMatch The list of objects to be compared
		 * @return fflib_MatcherDefinitions.ListContains A new ListContains instance
		 */
		public ListContains(Object toMatch)
		{
			this.toMatch = toMatch;
		}

		public Boolean matches(Object arg)
		{
			if (arg != null && arg instanceof List<Object>)
			{
				for (Object o : (List<Object>)arg)
				{
					if (o == toMatch)
					{
						return true;
					}
				}
			}

			return false;
		}
	}

	/**
	 * ListIsEmpty matcher: checks if the supplied argument is an empty list
	 */
	public class ListIsEmpty implements fflib_IMatcher
	{
		public Boolean matches(Object arg)
		{
			return arg != null
					&& arg instanceof List<Object>
					&& ((List<Object>)arg).isEmpty();
		}
	}

	/*
	 * SOBJECT MATCHERS
	 */

	/**
	 * SObjectOfType matcher: checks if the supplied argument has the specified SObjectType
	 */
	public class SObjectOfType implements fflib_IMatcher
	{
		private Schema.SObjectType objectType;

		/**
		 * SObjectOfType constructor
		 * @param objectType The SObjectType to be compared
		 * @return fflib_MatcherDefinitions.SObjectOfType A new SObjectOfType instance
		 */
		public SObjectOfType(Schema.SObjectType objectType)
		{
			this.objectType = (Schema.SObjectType)validateNotNull(objectType);
		}

		public Boolean matches(Object arg)
		{
			if (arg != null && arg instanceof SObject)
			{
				SObject soArg = (SObject)arg;
				return soArg.getSObjectType() == objectType;
			}

			return false;
		}
	}

	/**
	 * SObjectWith matcher: compares the supplied argument against a Map<Schema.SObjectField, Object>, representing fields and their expected values.
	 * Note. this method silently catches exceptions getting values for the supplied fields from the arguments supplied in method calls.
	 *
	 * If your matcher is mysteriously failing for your SObject record, it may be getting silent 'SObject row was retrieved via SOQL without querying
	 * the requested field' exceptions, because you haven't queried all of the fields used in this matcher.
	 */
	public class SObjectWith implements fflib_IMatcher
	{
		private Map<Schema.SObjectField, Object> toMatch;

		/**
		 * SObjectWith constructor
		 * @param toMatch A map of fields to their values to be compared. We compare each of these fields against the supplied sobject's field values.
		 * @return fflib_MatcherDefinitions.SObjectWith A new SObjectWith instance
		 */
		public SObjectWith(Map<Schema.SObjectField, Object> toMatch)
		{
			this.toMatch = validate(toMatch);
		}

		public Boolean matches(Object arg)
		{
			if (arg != null && arg instanceof SObject)
			{
				SObject soArg = (SObject)arg;
				if (!sobjectMatches(soArg,this.toMatch))
				{
					return false;
				}
				return true;
			}

			return false;
		}

		private Map<Schema.SObjectField, Object> validate(Map<Schema.SObjectField, Object> arg)
		{
			if (arg == null || arg.isEmpty())
			{
				throw new fflib_ApexMocks.ApexMocksException('Arg cannot be null/empty: ' + arg);
			}

			return arg;
		}
	}

	/**
	* SObjectsWith matcher: compares the supplied list<Sobject> argument against a list<Map<Schema.SObjectField, Object>>, representing fields and their expected values.
	* Each list element represents one Sobject in a list supplied to a mocked method that accepts list<SObject>.
	* Each list element that is a map<Schema.SobjectField,Object> is compared against the equivalent argument list element position
	*
	* Example:
	*   You use uow.registerNew(someListofAccounts). You mock uow in the testmethod.
	*   toMatch is new list<Schema.SObjectField,Object> {
	*      new map<Schema.SobjectField,Object> {Account.Name => 'foo'},
	*      new map<Schema.SobjectField,Object> {Account.Name => 'bar'}
	*    }
	*   By default, matchers compare against argument elements in order, viz:
	* 		The matcher will compare the first Account in the list passed to uow.registerNew to the first map of field values (i.e. Account[0].Name must be 'foo')
	*   	The matcher then compares the second Account in the list passed to uow.registerNew to the second map of field values (i.e. Account[1].Name must be 'bar')
	*
	*   Optional second argument matchInOrderr if false means that each argument element is compared against all matcher elements
	*   if everuy argument is matched exactly once and no matcher matches more than once, then the match is true
	*
	* If the arity of the list passed in the mocked method doesn't agree with the arity of the map of expected field values, false is returned
	*
	* Note. this method silently catches exceptions getting values for the supplied fields from the arguments supplied in method calls.
	*
	* If your matcher is mysteriously failing for your SObject record, it may be getting silent 'SObject row was retrieved via SOQL without querying
	* the requested field' exceptions, because you haven't queried all of the fields used in this matcher.
	*/
	public class SObjectsWith implements fflib_IMatcher
	{
		private list<Map<Schema.SObjectField, Object>> toMatch;
		private Boolean matchInOrder {
			get
			{
				return matchInOrder == null ? false : matchInOrder;
			}
			set;
		}

		/**
		 * SObjectsWith constructor
		 * @param toMatch A list of maps of fields to their values to be compared. We compare each of these fields against the supplied list of sobject's field values.
		 * @return fflib_MatcherDefinitions.SObjectWith A new SObjectWith instance
		 */
		public SObjectsWith(list<Map<Schema.SObjectField, Object>> toMatch, Boolean matchInOrder)
		{
			this.toMatch = validate(toMatch);
			this.matchInOrder = matchInOrder;
		}
		public SObjectsWith(list<Map<Schema.SObjectField, Object>> toMatch)
		{
			this.toMatch = validate(toMatch);
			this.matchInOrder = true;
		}
		public Boolean matches(Object arg)
		{
			System.debug('BOE');
			if (arg != null && arg instanceof list<SObject>)
			{
				SObject[] sobjsArg = (SObject[])arg;
				list<map<Schema.SObjectField,Object>> toMatches = new list<map<Schema.SObjectField,Object>>();

				//	Counters for matchInOrder = false; not relevant for matchInOrder = true
				list<Integer> argMatchedCounts = new list<Integer>();		// # times matched by a matcher. anything other than 1 is match error
				list<Integer> matcherMatchedCounts = new list<Integer>(); 	// for each map<Schema.SObjectField,Object>
				// # args that match it. Anything other than 1 is match error

				System.debug('toMatches: '+toMatches);
				System.debug('sobjsArg: '+sobjsArg);

				for (map<Schema.SObjectField,Object> mtchElm : toMatch)
				{
					toMatches.add(mtchElm);
					matcherMatchedCounts.add(0);
				}

				if (sobjsArg.size() != toMatches.size())	// arity of arguments to mocked method doesn't agree with arity of expected matches
				{
					return false;
				}

				if (matchInOrder)
				{
					for (Integer i = 0; i < sobjsArg.size(); i++)
					{	// match in order (toMatch[i] must match arg[i])
						if (!sobjectMatches(sobjsArg[i],toMatches[i]))
						{
							return false;
						}
						return true;
					}
				}
				else
				{
					// match in any order (but every arg must be matched only once)
					for (Integer i = 0; i < sobjsArg.size(); i++)
					{
						argMatchedCounts.add(0);
						// For each arg passed to mocked method, see if any match in the list of match field maps.
						// Loop within loop so not hugely efficient but there are no IDs to rely on.
						// Avoid unit test methods that build huge lists of expected results

						for (Integer m = 0; m < toMatches.size(); m++)
						{
							if (sobjectMatches(sobjsArg[i],toMatches[m]))
							{
								argMatchedCounts[i] ++;
								matcherMatchedCounts[m] ++;
							}
						}
					}
					// Check to see that every arg was matched only once
					// Check to see that every matcher matched only once
					// Anything else is a match fail

					for (Integer i=0; i < argMatchedCounts.size(); i++)
					{
						if (argMatchedCounts[i] != 1 || matcherMatchedCounts[i] != 1)
						{
							return false;
						}
					}
					return true;
				}
			}
			return false;
		}

		private list<Map<Schema.SObjectField, Object>> validate(list<Map<Schema.SObjectField, Object>> arg)
		{
			if (arg == null || arg.isEmpty() )
			{
				throw new fflib_ApexMocks.ApexMocksException('Arg cannot be null/empty/other than list of map<Schema.SobjectField,Object>: ' + arg);
			}

			return arg;
		}


	}

	/**
	 * helper for the sObjectWith, sObjectsWith matchers
	 * Compares to see if the field values in toMatch exist in the sobj
	**/
	private static Boolean sObjectMatches(Sobject sobj, map<Schema.SobjectField,Object> toMatch)
	{
		System.debug('--------------');
		System.debug('SObject: '+sobj);
		System.debug('toMatch: '+toMatch);
		for (Schema.SObjectField f : toMatch.keySet())
		{
			Object valueToMatch = toMatch.get(f);

			try
			{
				if (sobj.get(f) != valueToMatch)
				{
					return false;
				}
			}
			catch (Exception e)
			{
				//If we fail to get the value for a field it's either:
				// - 'SObject row was retrieved via SOQL without querying the requested field' as a mismatch
				// - System.SObjectException - Account.Id does not belong to SObject type Opportunity
				//Don't care too much, just treat this as a mismatch.
				return false;
			}
		}
		System.debug('Record is valid');
		return true;  // map of expected fieldvals found in sobj arg
	}

	/**
	 * SObjectWithId matcher: checks if the supplied argument has the specified Id
	 */
	public class SObjectWithId implements fflib_IMatcher
	{
		private Id toMatch;

		/**
		 * SObjectWithId constructor
		 * @param toMatch The Id to be compared
		 * @return fflib_MatcherDefinitions.SObjectWithId A new SObjectWithId instance
		 */
		public SObjectWithId(Id toMatch)
		{
			this.toMatch = (Id)validateNotNull(toMatch);
		}

		public Boolean matches(Object arg)
		{
			if (arg != null && arg instanceof SObject)
			{
				SObject soArg = (SObject)arg;
				return soArg.Id == toMatch;
			}

			return false;
		}
	}

	/**
	 * SObjectWithName matcher: checks if the supplied argument has the specified Name
	 */
	public class SObjectWithName implements fflib_IMatcher
	{
		private String toMatch;

		/**
		 * SObjectWithName constructor
		 * @param toMatch The name to be compared
		 * @return fflib_MatcherDefinitions.SObjectWithName A new SObjectWithName instance
		 */
		public SObjectWithName(String toMatch)
		{
			this.toMatch = (String)validateNotNull(toMatch);
		}

		public Boolean matches(Object arg)
		{
			if (arg != null && arg instanceof SObject)
			{
				SObject soArg = (SObject)arg;
				Schema.DescribeSObjectResult describe = soArg.getSObjectType().getDescribe();
				for (Schema.SObjectField f : describe.fields.getMap().values())
				{
					if (f.getDescribe().isNameField())
					{
						return soArg.get(f) == toMatch;
					}
				}
			}

			return false;
		}
	}

	/*
	 * STRING MATCHERS
	 */

	/**
	 * StringContains matcher: checks if the supplied argument contains the specified substring
	 */
	public class StringContains implements fflib_IMatcher
	{
		private String toMatch;

		/**
		 * StringContains constructor
		 * @param toMatch The substring to be compared
		 * @return fflib_MatcherDefinitions.StringContains A new StringContains instance
		 */
		public StringContains(String toMatch)
		{
			this.toMatch = (String)validateNotNull(toMatch);
		}

		public Boolean matches(Object arg)
		{
			return arg != null && arg instanceof String ? ((String)arg).contains(toMatch) : false;
		}
	}

	/**
	 * StringEndsWith matcher: checks if the supplied argument ends with the specified substring
	 */
	public class StringEndsWith implements fflib_IMatcher
	{
		private String toMatch;

		/**
		 * StringEndsWith constructor
		 * @param toMatch The substring to be compared
		 * @return fflib_MatcherDefinitions.StringEndsWith A new StringEndsWith instance
		 */
		public StringEndsWith(String toMatch)
		{
			this.toMatch = (String)validateNotNull(toMatch);
		}

		public Boolean matches(Object arg)
		{
			return arg != null && arg instanceof String ? ((String)arg).endsWith(toMatch) : false;
		}
	}

	/**
	 * StringIsBlank matcher: checks if the supplied argument is a blank String
	 */
	public class StringIsBlank implements fflib_IMatcher
	{
		public Boolean matches(Object arg)
		{
			return arg == null || (arg instanceof String ? String.isBlank((String)arg) : false);
		}
	}

	/**
	 * StringIsNotBlank matcher: checks if the supplied argument is a non-blank string
	 */
	public class StringIsNotBlank implements fflib_IMatcher
	{
		public Boolean matches(Object arg)
		{
			return (arg != NULL && arg instanceof String) ? String.isNotBlank((String)arg) : false;
		}
	}

	/**
	 * StringMatches matcher: checks if the supplied argument matches the specified regex expression
	 */
	public class StringMatches implements fflib_IMatcher
	{
		private Pattern pat;

		/**
		 * StringMatches constructor
		 * @param toMatch The substring to be compared
		 * @return fflib_MatcherDefinitions.StringMatches A new StringMatches instance
		 */
		public StringMatches(String regEx)
		{
			this.pat = Pattern.compile((String)validateNotNull(regEx));
		}

		public Boolean matches(Object arg)
		{
			return arg != null && arg instanceof String ? pat.matcher((String)arg).matches() : false;
		}
	}

	/**
	 * StringStartsWith matcher: checks if the supplied argument starts with the specified substring
	 */
	public class StringStartsWith implements fflib_IMatcher
	{
		private String toMatch;

		/**
		 * StringStartsWith constructor
		 * @param toMatch The substring to be compared
		 * @return fflib_MatcherDefinitions.StringStartsWith A new StringStartsWith instance
		 */
		public StringStartsWith(String toMatch)
		{
			this.toMatch = (String)validateNotNull(toMatch);
		}

		public Boolean matches(Object arg)
		{
			return arg != null && arg instanceof String ? ((String)arg).startsWith(toMatch) : false;
		}
	}

	/*
	 * Helpers
	 */

	private static Object validateNotNull(Object arg)
	{
		if (arg == null)
		{
			throw new fflib_ApexMocks.ApexMocksException('Arg cannot be null: ' + arg);
		}

		return arg;
	}
}