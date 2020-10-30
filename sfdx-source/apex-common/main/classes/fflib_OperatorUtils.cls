/**
 * File Name: sflib_sflib_OperatorUtils 
 * Description: 
 * Copyright (c) 2018 Johnson & Johnson
 */
public with sharing class fflib_OperatorUtils
{

	public static final fflib_Operator EQUALS = fflib_Operator.EQUALS;
	public static final fflib_Operator NOT_EQUALS = fflib_Operator.NOT_EQUALS;
	public static final fflib_Operator LESS_THAN = fflib_Operator.LESS_THAN;
	public static final fflib_Operator LESS_THAN_OR_EQUAL_TO = fflib_Operator.LESS_THAN_OR_EQUAL_TO;
	public static final fflib_Operator GREATER_THAN = fflib_Operator.GREATER_THAN;
	public static final fflib_Operator GREATER_THAN_OR_EQUAL_TO = fflib_Operator.GREATER_THAN_OR_EQUAL_TO;
	public static final fflib_Operator LIKEx = fflib_Operator.LIKEx;
	public static final fflib_Operator INx = fflib_Operator.INx;
	public static final fflib_Operator NOT_IN = fflib_Operator.NOT_IN;
	public static final fflib_Operator INCLUDES = fflib_Operator.INCLUDES;
	public static final fflib_Operator EXCLUDES = fflib_Operator.EXCLUDES;
	public static final fflib_Operator DEFAULT_sflib_Operator = EQUALS;


	public static String operatorToString(fflib_Operator op)
	{
		if (op == EQUALS)
			return '=';
		else if (op == NOT_EQUALS)
			return '!=';
		else if (op == LESS_THAN)
			return '<';
		else if (op == LESS_THAN_OR_EQUAL_TO)
			return '<=';
		else if (op == GREATER_THAN)
			return '>';
		else if (op == GREATER_THAN_OR_EQUAL_TO)
			return '>=';
		else if (op == LIKEx)
			return 'like';
		else if (op == INx)
			return 'IN';
		else if (op == NOT_IN)
			return 'NOT IN';
		else if (op == INCLUDES)
			return 'INCLUDES';
		else if (op == EXCLUDES)
			return 'EXCLUDES';
		else
				return null;
	}
}