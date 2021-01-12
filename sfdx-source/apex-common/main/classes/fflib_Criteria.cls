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
public virtual with sharing class fflib_Criteria
		implements Evaluator
{
	// Add brace when generated to SQL
	private Boolean embraced = false;

	// List to hold all evaluators
	private List<Evaluator> evaluators;

	// The type of comparator NONE | AND | OR
	private String comparatorType;


	/**
	 * populate private variables with default settings.
	 */
	public fflib_Criteria()
	{
		this.evaluators = new List<Evaluator>();
		this.comparatorType = 'AND';
	}

	/**
	 * Changes the default comparator for each criteria to OR
	 *
	 * @return Instance of fflib_Criteria
	 *
	 * @example
	 *  new fflib_Criteria()
	 *          .orCriteria()
	 *          .equalTo(Account.Name, 'Example')
	 *  		.equalTo(Account.AccountNumber, '1234567')
	 *
	 *  Evaluates:
	 *      Name = 'Example' OR AccountNumber = '1234567'
	 */
	public fflib_Criteria orCriteria()
	{
		this.comparatorType = 'OR';
		return this;
	}

	/**
	 * Changes the default comparator for each criteria to AND.
	 * By default the comparator is set to AND,
	 * so this method should only be used in custom implementations extended from fflib_Criteria
	 *
	 * @return Instance of fflib_Criteria
	 *
	 * @example
	 *  new MyCustomCriteria()
	 *          .andCriteria()
	 *          .equalTo(Account.Name, 'Example')
	 *  		.equalTo(Account.AccountNumber, '1234567')
	 *
	 *  Evaluates:
	 *      Name = 'Example' AND AccountNumber = '1234567'
	 */
	public fflib_Criteria andCriteria()
	{
		this.comparatorType = 'AND';
		return this;
	}

	/**
	 * Adds a sub criteria with OR comparator
	 *
	 * @param subCriteria The condition of the sub criteria
	 *
	 * @return Instance of fflib_Criteria
	 *
	 * @example
	 * new fflib_Criteria()
	 *          .equalTo(Account.Name, 'Example')
	 *          .addOrCriteria(
	 *              new fflib_Criteria()
	 *              		.equalTo(Account.AccountNumber, '0001')
	 *              		.equalTo(Account.AccountNumber, '0002'))
	 *
	 *  Evaluates:
	 *      Account.Name = 'Example' AND (Account.AccountNumber = '0001' OR Account.AccountNumber = '0002')
	 */
	public fflib_Criteria addOrCriteria(fflib_Criteria subCriteria)
	{
		subCriteria.orCriteria();
		subCriteria.setEmbraced(true);
		evaluators.add(subCriteria);
		return this;
	}

	/**
	 * Adds a sub criteria with AND comparator
	 *
	 * @param subCriteria The condition of the sub criteria
	 *
	 * @return Instance of fflib_Criteria
	 *
	 * @example
	 * new fflib_Criteria()
	 *          .orCriteria()
	 *          .equalTo(Account.Name, 'Example')
	 *          .addAndCriteria(
	 *              new fflib_Criteria()
	 *              		.equalTo(Account.AccountNumber, '0001')
	 *              		.equalTo(Account.ShippingCountry, 'USA'))
	 *
	 *  Evaluates:
	 *      Name = 'Example' OR (AccountNumber = '0001' AND ShippingCountry = 'USA')
	 */
	public fflib_Criteria addAndCriteria(fflib_Criteria subCriteria)
	{
		subCriteria.andCriteria();
		subCriteria.setEmbraced(true);
		evaluators.add(subCriteria);
		return this;
	}

	/**
	 * add an equal to criteria comparing a fields value to a given value
	 *
	 * @param field The sObjectField to evaluate
	 * @param value The value to be compared to the fields value
	 *
	 * @return Instance of fflib_Criteria
	 *
	 * @example
	 *  new fflib_Criteria()
	 *          .equalTo(Account.Name, 'Example')
	 *
	 * Evaluates:
	 *      Name = 'Example'
	 */
	public fflib_Criteria equalTo(Schema.SObjectField field, Object value)
	{
		evaluators.add(new FieldEvaluator(field, fflib_Operator.EQUALS, value));
		return this;
	}

	/**
	 * add a not equal to criteria while comparing a fields value to a given value
	 *
	 * @param field The sObjectField to evaluate
	 * @param value The value to be compared to the fields value
	 *
	 * @return Instance of fflib_Criteria
	 *
	 * @example
	 *  new fflib_Criteria()
	 *          .notEqualTo(Account.Name, 'Example')
	 *
	 * Evaluates:
	 *      Name != 'Example'
	 */
	public fflib_Criteria notEqualTo(Schema.SObjectField field, Object value)
	{
		evaluators.add(new FieldEvaluator(field, fflib_Operator.NOT_EQUALS, value));
		return this;
	}

	/**
	 * Evaluates the stored criteria based on the given SObject
	 *
	 * @param record The SObject to evaluate
	 *
	 * @return The Boolean result of the evaluated criteria
	 */
	public Boolean evaluate(Object record)
	{
		if (this.evaluators.isEmpty()) return true;

		Boolean result = !(this.comparatorType == 'OR');
		for (Evaluator evaluator : evaluators)
		{
			Boolean evaluateResult = evaluator.evaluate(record);
			if (evaluateResult && (this.comparatorType == 'OR' || this.comparatorType == 'NONE'))
			{
				return true;
			}
			else if (!evaluateResult && this.comparatorType == 'AND')
			{
				return false;
			}
		}
		return result;
	}

	/**
	 * compares the fields values to be greater or equal to the given value
	 * Evaluates to false if the field value is null
	 *
	 * @param field The field to use its value
	 * @param value The value to be compared to the fields value
	 *
	 * @return Instance of fflib_Criteria
	 *
	 * @example
	 *  new fflib_Criteria()
	 *          .greaterOrEqualTo(Account.AnnualRevenue, 54321)
	 *
	 * Evaluates:
	 *      AnnualRevenue >= 54321
	 */
	public fflib_Criteria greaterOrEqualTo(Schema.SObjectField field, Object value)
	{
		evaluators.add(new FieldEvaluator(field, fflib_Operator.GREATER_THAN_OR_EQUAL_TO, value));
		return this;
	}

	/**
	 * compares the fields values to be greater or equal to the given value
	 * Evaluates to false if the field value is null
	 *
	 * @param field The field to use its value
	 * @param value The value to be compared to the fields value
	 *
	 * @return Instance of fflib_Criteria
	 *
	 * @example
	 *  new fflib_Criteria()
	 *          .greaterThan(Account.AnnualRevenue, 54321)
	 *
	 * Evaluates:
	 *      AnnualRevenue > 54321
	 */
	public fflib_Criteria greaterThan(Schema.SObjectField field, Object value)
	{
		evaluators.add(new FieldEvaluator(field, fflib_Operator.GREATER_THAN, value));
		return this;
	}

	/**
	 * compares the fields values to be less or equal to the given value
	 * Evaluates to true if the field value is null
	 *
	 * @param field The field to use its value
	 * @param value The value to be compared to the fields value
	 *
	 * @return Instance of fflib_Criteria
	 *
	 * @example
	 *  new fflib_Criteria()
	 *          .lessOrEqualTo(Account.AnnualRevenue, 54321)
	 *
	 * Evaluates:
	 *      AnnualRevenue <= 54321
	 */
	public fflib_Criteria lessOrEqualTo(Schema.SObjectField field, Object value)
	{
		evaluators.add(new FieldEvaluator(field, fflib_Operator.LESS_THAN_OR_EQUAL_TO, value));
		return this;
	}


	/**
	 * compares the fields values to be greater or equal to the given value
	 * Evaluates to true if the field value is null
	 *
	 * @param field The field to use its value
	 * @param value The value to be compared to the fields value
	 *
	 * @return Instance of fflib_Criteria
	 *
	 * @example
	 *  new fflib_Criteria()
	 *          .lessThan(Account.AnnualRevenue, 54321)
	 *
	 * Evaluates:
	 *      AnnualRevenue < 54321
	 */
	public fflib_Criteria lessThan(Schema.SObjectField field, Object value)
	{
		evaluators.add(new FieldEvaluator(field, fflib_Operator.LESS_THAN, value));
		return this;
	}

	/**
	 * checks if the given sets contains the fields values
	 *
	 * @param field The field to use its value
	 * @param values The value to be compared to the fields value
	 *
	 * @return Instance of fflib_Criteria
	 *
	 * @example
	 *  new fflib_Criteria()
	 *          .inSet(Account.Type, new Set<Object>{'Customer', 'Competitor', 'Partner'})
	 *
	 * Evaluates:
	 *      Account.Type IN ('Customer','Competitor','Partner')
	 */
	public fflib_Criteria inSet(Schema.SObjectField field, Set<Object> values)
	{
		return inSet(field, new Objects(values));
	}
	public fflib_Criteria inSet(Schema.SObjectField field, Set<Date> values)
	{
		return inSet(field, new Objects(new List<Date>(values)));
	}
	public fflib_Criteria inSet(Schema.SObjectField field, Set<DateTime> values)
	{
		return inSet(field, new Objects(new List<DateTime>(values)));
	}
	public fflib_Criteria inSet(Schema.SObjectField field, Set<Decimal> values)
	{
		return inSet(field, new Objects(new List<Decimal>(values)));
	}
	public fflib_Criteria inSet(Schema.SObjectField field, Set<Double> values)
	{
		return inSet(field, new Objects(new List<Double>(values)));
	}
	public fflib_Criteria inSet(Schema.SObjectField field, Set<Id> values)
	{
		return inSet(field, new Objects(new List<Id>(values)));
	}
	public fflib_Criteria inSet(Schema.SObjectField field, Set<Integer> values)
	{
		return inSet(field, new Objects(new List<Integer>(values)));
	}
	public fflib_Criteria inSet(Schema.SObjectField field, Set<Long> values)
	{
		return inSet(field, new Objects(new List<Long>(values)));
	}
	public fflib_Criteria inSet(Schema.SObjectField field, Set<String> values)
	{
		return inSet(field, new Objects(new List<String>(values)));
	}
	public fflib_Criteria inSet(Schema.SObjectField field, Objects values)
	{
		evaluators.add(new FieldSetEvaluator(field, fflib_Operator.INx, values));
		return this;
	}

	/**
	 * checks if the given sets contains the fields values
	 *
	 * @param field The field to use its value
	 * @param values The value to be compared to the fields value
	 *
	 * @return Instance of fflib_Criteria
	 *
	 * @example
	 *  new fflib_Criteria()
	 *          .notInSet(Account.Type, new Set<Object>{'Customer', 'Competitor', 'Partner'})
	 *
	 * Evaluates:
	 *      Account.Type NOT IN ('Customer','Competitor','Partner')
	 */
	public fflib_Criteria notInSet(Schema.SObjectField field, Set<Date> values)
	{
		return notInSet(field, new Objects(new List<Date>(values)));
	}
	public fflib_Criteria notInSet(Schema.SObjectField field, Set<DateTime> values)
	{
		return notInSet(field, new Objects(new List<DateTime>(values)));
	}
	public fflib_Criteria notInSet(Schema.SObjectField field, Set<Decimal> values)
	{
		return notInSet(field, new Objects(new List<Decimal>(values)));
	}
	public fflib_Criteria notInSet(Schema.SObjectField field, Set<Double> values)
	{
		return notInSet(field, new Objects(new List<Double>(values)));
	}
	public fflib_Criteria notInSet(Schema.SObjectField field, Set<Id> values)
	{
		return notInSet(field, new Objects(new List<Id>(values)));
	}
	public fflib_Criteria notInSet(Schema.SObjectField field, Set<Integer> values)
	{
		return notInSet(field, new Objects(new List<Integer>(values)));
	}
	public fflib_Criteria notInSet(Schema.SObjectField field, Set<Long> values)
	{
		return notInSet(field, new Objects(new List<Long>(values)));
	}
	public fflib_Criteria notInSet(Schema.SObjectField field, Set<String> values)
	{
		return notInSet(field, new Objects(new List<String>(values)));
	}
	public fflib_Criteria notInSet(Schema.SObjectField field, Set<Object> values)
	{
		return notInSet(field, new Objects(values));
	}
	public fflib_Criteria notInSet(Schema.SObjectField field, Objects values)
	{
		evaluators.add(new FieldSetEvaluator(field, fflib_Operator.NOT_IN, values));
		return this;
	}

	/**
	 * Generates the SOQL equivalent of the criteria provided
	 *
	 * @return The "where" part in the SOQL statement
	 */
	public String toSOQL()
	{
		if (this.evaluators.isEmpty()) return '';

		String result = '';
		for (Evaluator evaluator : this.evaluators)
		{
			if (result != '')
			{
				result += ' ' + this.comparatorType + ' ';
			}
			result += evaluator.toSOQL();
		}

		if (this.embraced) result = '(' + result + ')';

		return result;
	}

	private static String operatorToString(fflib_Operator operator)
	{
		if (operator == fflib_Operator.EQUALS)
			return '=';
		else if (operator == fflib_Operator.NOT_EQUALS)
			return '!=';
		else if (operator == fflib_Operator.LESS_THAN)
			return '<';
		else if (operator == fflib_Operator.LESS_THAN_OR_EQUAL_TO)
			return '<=';
		else if (operator == fflib_Operator.GREATER_THAN)
			return '>';
		else if (operator == fflib_Operator.GREATER_THAN_OR_EQUAL_TO)
			return '>=';
		else if (operator == fflib_Operator.LIKEx)
			return ' like ';
		else if (operator == fflib_Operator.INx)
			return ' IN ';
		else if (operator == fflib_Operator.NOT_IN)
			return ' NOT IN ';
		else if (operator == fflib_Operator.INCLUDES)
			return ' INCLUDES ';
		else if (operator == fflib_Operator.EXCLUDES)
			return ' EXCLUDES ';
		else
				return null;
	}

	/**
	 * Adds braces to the condition when generated to SOQL
	 *
	 * @param embraced Braces will be added if set to TRUE
	 */
	private void setEmbraced(Boolean embraced)
	{
		this.embraced = embraced;
	}

	/**
	 * @param value The value to convert
	 *
	 * @return Returns the given value converted to literal string
	 */
	private static String toLiteral(final Object value)
	{
		if (value == null) return 'null';

		if (value instanceof String || value instanceof Id)
		{
			String manipulated = (String) value;
			return '\'' + manipulated + '\'';
		}
		else if (value instanceof Boolean ||
				value instanceof Integer ||
				value instanceof Long ||
				value instanceof Double ||
				value instanceof Decimal)
		{
			return '' + value;
		}
		else if (value instanceof Date)
		{
			return '' + Datetime.newInstance(((Date) value).year(), ((Date) value).month(), ((Date) value).day()).format('yyyy-MM-dd');
		}
		else if (value instanceof Datetime)
		{
			return '' + ((Datetime) value).format('yyyy-MM-dd') + 'T' + ((Datetime) value).format('HH:mm:ss') + 'Z';
		}

		throw new CriteriaException(
				'invalid value; value must a primitive type (String|Id|Boolean|Integer|Long|Double|Decimal|Date|Datetime)'
		);
	}

	/**
	 * @param values The values to convert
	 *
	 * @return Returns the given values converted to literal string separated by a comma
	 */
	private static String toLiteral(final Objects values)
	{
		if (values.isEmpty()) return '';

		String result = '(';
		for (Object obj : values.getObjects())
		{
			if (result != '(')
			{
				result += ',';
			}
			result += toLiteral(obj);
		}
		return result + ')';
	}

	/**
	 * Generic criteria handler for comparing against sets
	 */
	private class FieldSetEvaluator implements Evaluator
	{
		private Schema.SObjectField sObjectField;
		private Objects values;
		private fflib_Operator operator;

		public FieldSetEvaluator(Schema.SObjectField sObjectField, fflib_Operator operator, Objects values)
		{
			this.sObjectField = sObjectField;
			this.values = values;
			this.operator = operator;
		}

		public Boolean evaluate(Object record)
		{
			if (!(record instanceof SObject))
				throw new CriteriaException('Only records of type SObject can have fieldCriteria');

			Object fieldValue = ((SObject) record).get(this.sObjectField);
			Boolean isIn = this.values.contains(fieldValue);
			return ((operator == fflib_Operator.INx && isIn) || (operator == fflib_Operator.NOT_IN && !isIn));
		}

		public String toSOQL()
		{
			return String.format(
					'{0} {2} {3}',
					new List<String>
					{
							this.sObjectField.getDescribe().getName(),
							operatorToString(this.operator),
							toLiteral(this.values)
					}
			);
		}
	}

	private interface Evaluator
	{
		Boolean evaluate(Object obj);
		String toSOQL();
	}

	/**
	 * Generic field Evaluator
	 */
	private class FieldEvaluator implements Evaluator
	{
		private Schema.SObjectField sObjectField;
		private Object value;
		private fflib_Operator operator;

		public FieldEvaluator(Schema.SObjectField sObjectField, fflib_Operator operator, Object value)
		{
			this.sObjectField = sObjectField;
			this.value = value;
			this.operator = operator;
		}

		public Boolean evaluate(Object record)
		{
			if (!(record instanceof SObject))
				throw new CriteriaException('Only records of type SObject can have fieldCriteria');

			Object fieldValue = ((SObject) record).get(this.sObjectField);

			return fflib_Comparator.compareTo(fieldValue, operator, this.value);
		}

		public String toSOQL()
		{
			return String.join(
					new List<String>
					{
							this.sObjectField.getDescribe().getName(),
							operatorToString(this.operator),
							toLiteral(this.value)
					},
					''
			);
		}
	}

	private virtual class Objects
	{
		protected List<Object> objects { get; private set; }

		public Objects(Set<Object> objects)
		{
			this(new List<Object>(objects));
		}

		public Objects(List<Object> objects)
		{
			this.objects = objects;
		}

		public Boolean contains(Object value)
		{
			return getObjects().contains(value);
		}

		public Boolean isEmpty()
		{
			return (getObjects() == null || getObjects().isEmpty());
		}

		public List<Object> getObjects()
		{
			return this.objects;
		}
	}

	/**
	 * Class exception handler
	 */
	public class CriteriaException extends Exception { }
}