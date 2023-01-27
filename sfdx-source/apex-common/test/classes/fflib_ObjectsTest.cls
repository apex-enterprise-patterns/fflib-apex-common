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

@IsTest
private class fflib_ObjectsTest
{
	private static final fflib_ObjectsTest.DataTransferObject TRANSFER_OBJECT_A = new DataTransferObject('Test A');
	private static final fflib_ObjectsTest.DataTransferObject TRANSFER_OBJECT_B = new DataTransferObject('Test B');
	private static final fflib_ObjectsTest.DataTransferObject TRANSFER_OBJECT_C = new DataTransferObject('Test C');
	private static final fflib_ObjectsTest.DataTransferObject TRANSFER_OBJECT_D = new DataTransferObject('Test D');

	@IsTest
	static void itShouldReturnTheCorrectType()
	{
		fflib_ObjectsTest.Domain dtoDomain = new Domain(
				new List<DataTransferObject>
				{
						TRANSFER_OBJECT_A,
						TRANSFER_OBJECT_B
				}
		);

		System.assertEquals(
				DataTransferObject.class,
				dtoDomain.getType(),
				'Wrong domain type'
		);
	}

	@IsTest
	static void itShouldContainTheObject()
	{
		fflib_ObjectsTest.DataTransferObject transferObject = TRANSFER_OBJECT_A;
		fflib_ObjectsTest.Domain dtoDomain = new Domain(
				new List<DataTransferObject>
				{
						transferObject,
						TRANSFER_OBJECT_B
				}
		);

		System.assert(
				dtoDomain.contains(transferObject),
				'The object should have been part of the domain'
		);
	}

	@IsTest
	static void itShouldNotContainTheObject()
	{
		fflib_ObjectsTest.Domain dtoDomain = generateDomain();

		System.assert(
				dtoDomain.containsNot(TRANSFER_OBJECT_D),
				'The object should not have been part of the domain'
		);
	}

	@IsTest
	static void itShouldNotContainTheObjects()
	{
		fflib_ObjectsTest.Domain dtoDomain = new Domain(
				new List<Object>
				{
						TRANSFER_OBJECT_A,
						TRANSFER_OBJECT_B
				});

		System.assert(
				dtoDomain.containsNot(
						new Set<Object>
						{
								TRANSFER_OBJECT_C,
								TRANSFER_OBJECT_D
						}),
				'The set of objects should not have been part of the domain'
		);
		System.assert(
				dtoDomain.containsNot(
						new List<Object>
						{
								TRANSFER_OBJECT_C,
								TRANSFER_OBJECT_D
						}),
				'The list of objects should not have been part of the domain'
		);
	}

	@IsTest
	static void itShouldHaveAnEmptyDomain()
	{
		fflib_ObjectsTest.Domain dtoDomain = new Domain(new List<DataTransferObject>());
		System.assert(dtoDomain.isEmpty(), 'Domain should be empty');
	}

	@IsTest
	static void itShouldNotBeAnEmptyDomain()
	{
		fflib_ObjectsTest.Domain dtoDomain = generateDomain();
		System.assert(dtoDomain.isNotEmpty(), 'Domain should not be empty');
		System.assertEquals(3, dtoDomain.size(), 'Incorrect amount of records in the domain');
	}

	@IsTest
	static void itShouldContainAllTheObjects()
	{
		fflib_ObjectsTest.Domain dtoDomain = generateDomain();

		System.assert(
				dtoDomain.containsAll(
						new List<DataTransferObject>
						{
								TRANSFER_OBJECT_A,
								TRANSFER_OBJECT_B
						}
				),
				'Domain should contain the whole List of objects'
		);
		System.assert(
				dtoDomain.containsAll(
						new Set<Object>
						{
								TRANSFER_OBJECT_A,
								TRANSFER_OBJECT_B
						}
				),
				'Domain should contain the whole Set of objects'
		);
	}

	@IsTest
	static void itShouldGetTheObjectType()
	{
		fflib_Objects domain = new fflib_Objects(new List<Object>());
		System.assertEquals(Object.class, domain.getType(), 'Incorrect returned type');
	}

	private static Domain generateDomain()
	{
		return new Domain(generateDataTransferObjects());
	}

	private static List<DataTransferObject> generateDataTransferObjects()
	{
		return new List<DataTransferObject>
		{
				TRANSFER_OBJECT_A,
				TRANSFER_OBJECT_B,
				TRANSFER_OBJECT_C
		};
	}

	private class Domain extends fflib_Objects
	{
		public Domain(List<Object> objects)
		{
			super(objects);
		}

		public override Object getType()
		{
			return DataTransferObject.class;
		}
	}

	private class DataTransferObject
	{
		public String MyProperty { get; set; }

		public DataTransferObject(String property)
		{
			this.MyProperty = property;
		}
	}
}