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

@IsTest(IsParallel=true)
private class fflib_CriteriaTest
{

	private static final Integer HIGHER_NUMBER = 98765;
	private static final Integer A_NUMBER = 54321;
	private static final Integer SAME_NUMBER = A_NUMBER;
	private static final Integer LOWER_NUMBER = 0;
	private static final String A_STRING = 'Example';
	private static final String SAME_STRING = A_STRING;
	private static final String ANOTHER_STRING = 'Something Else';
	private static final String HELLO_WORLD = 'Hello World!';
	private static final Boolean FAILING = false;


	@IsTest
	static void itShouldEvaluateAnEqualsToCondition()
	{
		System.assert(
				new fflib_Criteria()
						.andCriteria()
						.equalTo(Account.Name, A_STRING)
						.evaluate(new Account(Name = SAME_STRING))
		);
	}

	@IsTest
	static void itShouldEvaluateAnEqualsToCondition_ReturningFalse()
	{
		System.assert(
				new fflib_Criteria()
						.equalTo(Account.Name, A_STRING)
						.evaluate(new Account(Name = ANOTHER_STRING))
						== FAILING
		);
	}
	@IsTest
	static void itShouldEvaluateAnEqualsToCondition_NullValues()
	{
		System.assert(
				new fflib_Criteria()
						.equalTo(Account.Name, A_STRING)
						.evaluate(new Account())
						== FAILING
		);
	}

	@IsTest
	static void itShouldEvaluateANotEqualsToCondition()
	{
		System.assert(
				new fflib_Criteria()
						.notEqualTo(Account.Name, A_STRING)
						.evaluate(new Account(Name = ANOTHER_STRING))
		);
	}

	@IsTest
	static void itShouldEvaluateANotEqualsToCondition_ReturningFalse()
	{
		System.assert(
				new fflib_Criteria()
						.notEqualTo(Account.Name, A_STRING)
						.evaluate(new Account(Name = SAME_STRING))
						== FAILING
		);
	}

	@IsTest
	static void itShouldEvaluateAddGreaterOrEqualToCondition()
	{
		System.assert(
				new fflib_Criteria()
						.greaterOrEqualTo(Account.AnnualRevenue, A_NUMBER)
						.evaluate(new Account(AnnualRevenue = HIGHER_NUMBER))
		);
	}

	@IsTest
	static void itShouldEvaluateAddGreaterOrEqualToCondition_Equal()
	{
		System.assert(
				new fflib_Criteria()
						.greaterOrEqualTo(Account.AnnualRevenue, A_NUMBER)
						.evaluate(new Account(AnnualRevenue = SAME_NUMBER))
		);
	}

	@IsTest
	static void itShouldEvaluateAddGreaterOrEqualToCondition_ReturningFalse()
	{
		System.assert(
				new fflib_Criteria()
						.greaterOrEqualTo(Account.AnnualRevenue, A_NUMBER)
						.evaluate(new Account(AnnualRevenue = LOWER_NUMBER))
						== FAILING
		);
	}
	@IsTest
	static void itShouldEvaluateAddGreaterOrEqualToCondition_NullValues()
	{
		System.assert(
				new fflib_Criteria()
						.greaterOrEqualTo(Account.AnnualRevenue, A_NUMBER)
						.evaluate(new Account())
						== FAILING
		);
	}

	@IsTest
	static void itShouldEvaluateAddGreaterThanCondition()
	{
		System.assert(
				new fflib_Criteria()
						.greaterThan(Account.AnnualRevenue, A_NUMBER)
						.evaluate(new Account(AnnualRevenue = HIGHER_NUMBER))
		);
	}

	@IsTest
	static void itShouldEvaluateAddGreaterThanCondition_EqualValues()
	{
		System.assert(
				new fflib_Criteria()
						.greaterThan(Account.AnnualRevenue, A_NUMBER)
						.evaluate(new Account(AnnualRevenue = SAME_NUMBER))
						== FAILING
		);
	}

	@IsTest
	static void itShouldEvaluateAddGreaterThanCondition_ReturningFalse()
	{
		System.assert(
				new fflib_Criteria()
						.greaterThan(Account.AnnualRevenue, A_NUMBER)
						.evaluate(new Account(AnnualRevenue = LOWER_NUMBER))
						== FAILING
		);
	}
	@IsTest
	static void itShouldEvaluateAddGreaterThanCondition_NullValues()
	{
		System.assert(
				new fflib_Criteria()
						.greaterThan(Account.AnnualRevenue, A_NUMBER)
						.evaluate(new Account())
						== FAILING
		);
	}

	@IsTest
	static void itShouldEvaluateAddLessOrEqualToCondition()
	{
		System.assert(
				new fflib_Criteria()
						.lessOrEqualTo(Account.AnnualRevenue, A_NUMBER)
						.evaluate(new Account(AnnualRevenue = LOWER_NUMBER))
		);
	}

	@IsTest
	static void itShouldEvaluateAddLessOrEqualToCondition_Equal()
	{
		System.assert(
				new fflib_Criteria()
						.lessOrEqualTo(Account.AnnualRevenue, A_NUMBER)
						.evaluate(new Account(AnnualRevenue = SAME_NUMBER))
		);
	}

	@IsTest
	static void itShouldEvaluateAddLessOrEqualToCondition_ReturningFalse()
	{
		System.assert(
				new fflib_Criteria()
						.lessOrEqualTo(Account.AnnualRevenue, A_NUMBER)
						.evaluate(new Account(AnnualRevenue = HIGHER_NUMBER))
						== FAILING
		);
	}
	@IsTest
	static void itShouldEvaluateAddLessOrEqualToCondition_NullValues()
	{
		System.assert(
				new fflib_Criteria()
						.lessOrEqualTo(Account.AnnualRevenue, A_NUMBER)
						.evaluate(new Account())
		);
	}

	@IsTest
	static void itShouldEvaluateAddLessThanCondition()
	{
		System.assert(
				new fflib_Criteria()
						.lessThan(Account.AnnualRevenue, A_NUMBER)
						.evaluate(new Account(AnnualRevenue = LOWER_NUMBER))
		);
	}

	@IsTest
	static void itShouldEvaluateAddLessThanCondition_EqualValues()
	{
		System.assert(
				new fflib_Criteria()
						.lessThan(Account.AnnualRevenue, A_NUMBER)
						.evaluate(new Account(AnnualRevenue = SAME_NUMBER))
						== FAILING
		);
	}

	@IsTest
	static void itShouldEvaluateAddLessThanCondition_ReturningFalse()
	{
		System.assert(
				new fflib_Criteria()
						.lessThan(Account.AnnualRevenue, A_NUMBER)
						.evaluate(new Account(AnnualRevenue = HIGHER_NUMBER))
						== FAILING
		);
	}

	@IsTest
	static void itShouldEvaluateAddLessThanCondition_NullValues()
	{
		System.assert(
				new fflib_Criteria()
						.lessThan(Account.AnnualRevenue, A_NUMBER)
						.evaluate(new Account())
		);
	}

	@IsTest
	static void itShouldEvaluateInSetCondition_Decimal()
	{
		System.assert(
				new fflib_Criteria()
						.inSet(Account.AnnualRevenue, new Set<Decimal> {1.1, 2.2})
						.evaluate(new Account(AnnualRevenue = 1.1))
		);
	}

	@IsTest
	static void itShouldEvaluateInSetCondition_Id()
	{
		Id idOne = fflib_IDGenerator.generate(Account.SObjectType);
		Id idTwo = fflib_IDGenerator.generate(Account.SObjectType);
		System.assert(
				new fflib_Criteria()
						.inSet(Account.Id, new Set<Id> {idOne, idTwo})
						.evaluate(new Account(Id = idOne))
		);
	}

	@IsTest
	static void itShouldEvaluateInSetCondition_Integer()
	{
		System.assert(
				new fflib_Criteria()
						.inSet(Account.NumberOfEmployees, new Set<Integer> {1, 10})
						.evaluate(new Account(NumberOfEmployees = 1))
		);
	}

	@IsTest
	static void itShouldEvaluateInSetCondition()
	{
		System.assert(
				new fflib_Criteria()
						.inSet(Account.Type, new Set<String> {A_STRING, HELLO_WORLD})
						.evaluate(new Account(Type = SAME_STRING))
		);
	}

	@IsTest
	static void itShouldEvaluateInSetCondition_ReturningFalse()
	{
		System.assert(
				new fflib_Criteria()
						.inSet(Account.Type, new Set<String> {A_STRING, HELLO_WORLD})
						.evaluate(new Account(Type = ANOTHER_STRING))
						== FAILING
		);
	}

	@IsTest
	static void itShouldEvaluateInSetCondition_NullValues()
	{
		System.assert(
				new fflib_Criteria()
						.inSet(Account.Type, new Set<String> {A_STRING, HELLO_WORLD})
						.evaluate(new Account())
						== FAILING
		);
	}

	@IsTest
	static void itShouldEvaluateNotInSetCondition()
	{
		System.assert(
				new fflib_Criteria()
						.notInSet(Account.Name, new Set<String> {A_STRING, HELLO_WORLD})
						.evaluate(new Account(Name = ANOTHER_STRING))
		);
	}

	@IsTest
	static void itShouldEvaluateNotInSetCondition_Failing()
	{
		System.assert(
				new fflib_Criteria()
						.notInSet(Account.Name, new Set<String> {A_STRING, HELLO_WORLD})
						.evaluate(new Account(Name = SAME_STRING))
						== FAILING
		);
	}

	@IsTest
	static void itShouldEvaluateNotInSetCondition_Decimal()
	{
		System.assert(
				new fflib_Criteria()
						.notInSet(Account.AnnualRevenue, new Set<Decimal> {1.1, 2.2})
						.evaluate(new Account(AnnualRevenue = 3.3))
		);
	}

	@IsTest
	static void itShouldEvaluateNotInSetCondition_Id()
	{
		Id idOne = fflib_IDGenerator.generate(Account.SObjectType);
		Id idTwo = fflib_IDGenerator.generate(Account.SObjectType);
		Id idThree = fflib_IDGenerator.generate(Account.SObjectType);
		System.assert(
				new fflib_Criteria()
						.notInSet(Account.Id, new Set<Id> {idOne, idTwo})
						.evaluate(new Account(Id = idThree))
		);
	}

	@IsTest
	static void itShouldEvaluateNotInSetCondition_Integer()
	{
		System.assert(
				new fflib_Criteria()
						.notInSet(Account.NumberOfEmployees, new Set<Integer> {1, 10})
						.evaluate(new Account(NumberOfEmployees = 2))
		);
	}

	@IsTest
	static void itShouldEvaluateOrCondition_First()
	{
		System.assert(
				new fflib_Criteria()
						.orCriteria()
						.equalTo(Account.Name, A_STRING)
						.equalTo(Account.Name, ANOTHER_STRING)
						.evaluate(new Account(Name = A_STRING))
		);
	}

	@IsTest
	static void itShouldEvaluateOrCondition_Second()
	{
		System.assert(
				new fflib_Criteria()
						.orCriteria()
						.equalTo(Account.Name, A_STRING)
						.equalTo(Account.Name, ANOTHER_STRING)
						.evaluate(new Account(Name = ANOTHER_STRING))
		);
	}

	@IsTest
	static void itShouldEvaluateOrCondition_Failing()
	{
		System.assert(
				new fflib_Criteria()
						.orCriteria()
						.equalTo(Account.Name, A_STRING)
						.equalTo(Account.Name, ANOTHER_STRING)
						.evaluate(new Account(Name = HELLO_WORLD))
						== FAILING
		);
	}

	@IsTest
	static void itShouldEvaluateAddOrCondition_First()
	{
		System.assert(
				new fflib_Criteria()
						.equalTo(Account.Name, A_STRING)
						.addOrCriteria(
						new fflib_Criteria()
								.equalTo(Account.AccountNumber, '001')
								.equalTo(Account.AccountNumber, '002')
				)
						.evaluate(new Account(Name = A_STRING, AccountNumber = '001'))
		);
	}

	@IsTest
	static void itShouldEvaluateAddOrCondition_Second()
	{
		System.assert(
				new fflib_Criteria()
						.equalTo(Account.Name, A_STRING)
						.addOrCriteria(
						new fflib_Criteria()
								.equalTo(Account.AccountNumber, '001')
								.equalTo(Account.AccountNumber, '002')
				)
						.evaluate(new Account(Name = A_STRING, AccountNumber = '002'))
		);
	}

	@IsTest
	static void itShouldEvaluateAddOrCondition_Failing()
	{
		System.assert(
				new fflib_Criteria()
						.equalTo(Account.Name, A_STRING)
						.addOrCriteria(
						new fflib_Criteria()
								.equalTo(Account.AccountNumber, '001')
								.equalTo(Account.AccountNumber, '002')
				)
						.evaluate(new Account(Name = ANOTHER_STRING, AccountNumber = '001'))
						== FAILING
		);
	}

	@IsTest
	static void itShouldEvaluateAddAndCondition_First()
	{
		System.assert(
				new fflib_Criteria()
						.orCriteria()
						.equalTo(Account.Name, A_STRING)
						.equalTo(Account.Name, ANOTHER_STRING)
						.addAndCriteria(
						new fflib_Criteria()
								.equalTo(Account.Name, HELLO_WORLD)
								.equalTo(Account.AccountNumber, '002')
				)
						.evaluate(new Account(Name = ANOTHER_STRING))
		);
	}

	@IsTest
	static void itShouldEvaluateAddAndCondition_Second()
	{
		System.assert(
				new fflib_Criteria()
						.orCriteria()
						.equalTo(Account.Name, A_STRING)
						.equalTo(Account.Name, ANOTHER_STRING)
						.addAndCriteria(
						new fflib_Criteria()
								.equalTo(Account.Name, HELLO_WORLD)
								.equalTo(Account.AccountNumber, '002')
				)
						.evaluate(new Account(Name = HELLO_WORLD, AccountNumber = '002'))
		);
	}

	@IsTest
	static void itShouldEvaluateAddAndCondition_SecondFailing()
	{
		System.assert(
				new fflib_Criteria()
						.orCriteria()
						.equalTo(Account.Name, A_STRING)
						.equalTo(Account.Name, ANOTHER_STRING)
						.addAndCriteria(
						new fflib_Criteria()
								.equalTo(Account.Name, HELLO_WORLD)
								.equalTo(Account.AccountNumber, '002')
				)
						.evaluate(new Account(Name = HELLO_WORLD))
						== FAILING
		);
	}

	@IsTest
	static void itShouldEvaluateEmptyCondition()
	{
		System.assert(
				new fflib_Criteria()
						.evaluate(new Account())
		);
	}

	@IsTest
	static void itShouldGenerateQueryString_EqualsToCondition()
	{
		System.assertEquals(
				'Name=\'Example\'',
				new fflib_Criteria()
						.andCriteria()
						.equalTo(Account.Name, A_STRING)
						.toSOQL()
		);
	}

	@IsTest
	static void itShouldGenerateQueryString_AddOrCondition()
	{
		System.assertEquals(
				'Name=\'Example\' AND (AccountNumber=\'001\' OR AccountNumber=\'002\')',
				new fflib_Criteria()
						.equalTo(Account.Name, A_STRING)
						.addOrCriteria(
						new fflib_Criteria()
								.equalTo(Account.AccountNumber, '001')
								.equalTo(Account.AccountNumber, '002')
				)
						.toSOQL()
		);
	}
}