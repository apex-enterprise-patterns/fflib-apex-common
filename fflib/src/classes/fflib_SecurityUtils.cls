/**
 * Copyright (c) 2014, FinancialForce.com, inc
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

/**
 * Utility class for checking FLS/CRUD. NOTE: all "check" methods will throw a SecurityException (or subclass) if the
 * user does not have the proper security granted.
 **/
public class fflib_SecurityUtils  
{
    @testVisible 
    private Enum OperationType { CREATE, READ, MODIFY, DEL } //UPDATE and DELETE are reserved words

    /**
     * SecurityException is never be thrown directly by fflib_SecurityUtils, instead all 
     * forms of CRUD and FLD violations throw subclasses of it. It is provided as a conveneience
     * in the event you wish to handle CRUD and FLS violations the same way (e.g. die and display an error)
    **/
    public virtual class SecurityException extends Exception {
        protected OperationType m_operation;
        protected Schema.SObjectType m_objectType;
    }

    /**
     * CrudException represents a running user's lack of read/create/update/delete access at a profile (or permission set)
     * level. Sharing and field level security issues will never cause this.
     **/
    public class CrudException extends SecurityException{
    	
    	private CrudException(OperationType operation, Schema.SObjectType objectType){
    		this.m_operation = operation;
    		this.m_objectType = objectType;
    		if(operation == OperationType.CREATE)
    			this.setMessage(System.Label.fflib_security_error_object_not_insertable);
    		else if(operation == OperationType.READ)
    			this.setMessage(System.Label.fflib_security_error_object_not_readable);
    		else if(operation == OperationType.MODIFY)
    			this.setMessage(System.Label.fflib_security_error_object_not_updateable);
    		else if(operation == OperationType.DEL)
    			this.setMessage(System.Label.fflib_security_error_object_not_deletable);

    		this.setMessage(
    			String.format(
    				this.getMessage(),
    				new List<String>{
    					objectType.getDescribe().getName()
    				} 
    			)
    		);
    	}
    }
    /**
     * FlsException represents a running user's lack of field level security to a specific field at a profile (or permission set) level
     * Sharing and CRUD security issues will never cause this to be thrown.
     **/
    public class FlsException extends SecurityException{
    	private Schema.SObjectField m_fieldToken;

    	private FlsException(OperationType operation, Schema.SObjectType objectType, Schema.SObjectField fieldToken){
    		this.m_operation = operation;
    		this.m_objectType = objectType;
    		this.m_fieldToken = fieldToken;
    		if(operation == OperationType.CREATE)
    			this.setMessage(System.Label.fflib_security_error_field_not_insertable);
    		else if(operation == OperationType.READ)
    			this.setMessage(System.Label.fflib_security_error_field_not_readable);
    		else if(operation == OperationType.MODIFY)
    			this.setMessage(System.Label.fflib_security_error_field_not_updateable);

    		this.setMessage(
    			String.format(
	    			this.getMessage(),
	    			new List<String>{
	    				objectType.getDescribe().getName(),
	    				fieldToken.getDescribe().getName()
	    			}
	    		)
    		);
    	}
    }
    
    /**
     * If set to true all check methods will always return void, and never throw exceptions.
     * This should really only be set to true if an app-wide setting to disable in-apex
     * FLS and CRUD checks exists and is enabled.
     * Per security best practices setting BYPASS should be an a opt-in, and not the default behavior.
     **/
    public static boolean BYPASS_INTERNAL_FLS_AND_CRUD = false;

    /**
	 * Check{Insert,Read,Update} methods check both FLS and CRUD
    **/
    
    /**
     * Checks both insert FLS and CRUD for the specified object type and fields.
     * @exception FlsException if the running user does not have insert rights to any fields in {@code fieldNames}.
     * @exception CrudException if the running user does not have insert rights to {@code objType}
     **/
    public static void checkInsert(SObjectType objType, List<String> fieldNames)
    {
    	checkObjectIsInsertable(objType);
    	for (String fieldName : fieldNames)
    	{
    		checkFieldIsInsertable(objType, fieldName);
    	}
    }
    
    /**
     * Identical to {@link #checkInsert(SObjectType,List<String>)}, except with SObjectField instead of String field references.
     * @exception FlsException if the running user does not have insert rights to any fields in {@code fieldTokens}.
     * @exception CrudException if the running user does not have insert rights to {@code objType}
     **/
    public static void checkInsert(SObjectType objType, List<SObjectField> fieldTokens)
    {
    	checkObjectIsInsertable(objType);
    	for (SObjectField fieldToken : fieldTokens)
    	{
    		checkFieldIsInsertable(objType, fieldToken);
    	}
    }

    /**
     * Checks both read FLS and CRUD for the specified object type and fields.
     * @exception FlsException if the running user does not have read rights to any fields in {@code fieldNames}.
     * @exception CrudException if the running user does not have read rights to {@code objType}
     **/
    public static void checkRead(SObjectType objType, List<String> fieldNames)
    {
        checkObjectIsReadable(objType);
        for (String fieldName : fieldNames)
        {
            checkFieldIsReadable(objType, fieldName);
        }
    }
    
    /**
     * Identical to {@link #checkRead(SObjectType,List<String>)}, except with SObjectField instead of String field references.
     * @exception FlsException if the running user does not have read rights to any fields in {@code fieldTokens}.
     * @exception CrudException if the running user does not have read rights to {@code objType}
     **/
    public static void checkRead(SObjectType objType, List<SObjectField> fieldTokens)
    {
        checkObjectIsReadable(objType);
        for (SObjectField fieldToken : fieldTokens)
        {
            checkFieldIsReadable(objType, fieldToken);
        }
    }

    /**
     * Checks both update FLS and CRUD for the specified object type and fields.
     * @exception FlsException if the running user does not have update rights to any fields in {@code fieldNames}.
     * @exception CrudException if the running user does not have update rights to {@code objType}
     **/
    public static void checkUpdate(SObjectType objType, List<String> fieldNames)
    {
        checkObjectIsUpdateable(objType);
        for (String fieldName : fieldNames)
        {
            checkFieldIsUpdateable(objType, fieldName);
        }
    }
    
    /**
     * Identical to {@link #checkUpdate(SObjectType,List<String>)}, except with SObjectField instead of String field references.
     * @exception FlsException if the running user does not have update rights to any fields in {@code fieldTokens}.
     * @exception CrudException if the running user does not have update rights to {@code objType}
     **/
    public static void checkUpdate(SObjectType objType, List<SObjectField> fieldTokens)
    {
        checkObjectIsUpdateable(objType);
        for (SObjectField fieldToken : fieldTokens)
        {
            checkFieldIsUpdateable(objType, fieldToken);
        }
    }

    /**
	 * CheckFieldIs* method check only FLS
    **/

    /**
     * Checks insert field level security only (no CRUD) for the specified fields on {@code objType}
     * @exception FlsException if the running user does not have insert rights to the {@code fieldName} field.
    **/
    public static void checkFieldIsInsertable(SObjectType objType, String fieldName)
    {
        checkFieldIsInsertable(objType, fflib_SObjectDescribe.getDescribe(objType).getField(fieldName));
    }

    /**
     * Identical to {@link #checkFieldIsInsertable(SObjectType,String)}, except with SObjectField instead of String field reference.
     * @exception FlsException if the running user does not have insert rights to the {@code fieldName} field.
    **/
    public static void checkFieldIsInsertable(SObjectType objType, SObjectField fieldToken)
    {
        checkFieldIsInsertable(objType, fieldToken.getDescribe());
    }

    /**
     * Identical to {@link #checkFieldIsInsertable(SObjectType,String)}, except with DescribeFieldResult instead of String field reference.
     * @exception FlsException if the running user does not have insert rights to the {@code fieldName} field.
    **/
    public static void checkFieldIsInsertable(SObjectType objType, DescribeFieldResult fieldDescribe)
    {
    	if (BYPASS_INTERNAL_FLS_AND_CRUD)
    	    return;
        if (!fieldDescribe.isCreateable())
            throw new FlsException(OperationType.CREATE, objType, fieldDescribe.getSObjectField());
    }
    
    /**
     * Checks read field level security only (no CRUD) for the specified fields on {@code objType}
     * @exception FlsException if the running user does not have read rights to the {@code fieldName} field.
    **/
    public static void checkFieldIsReadable(SObjectType objType, String fieldName)
    {
    	checkFieldIsReadable(objType, fflib_SObjectDescribe.getDescribe(objType).getField(fieldName));
    }

    /**
     * Identical to {@link #checkFieldIsReadable(SObjectType,String)}, except with SObjectField instead of String field reference.
     * @exception FlsException if the running user does not have read rights to the {@code fieldName} field.
    **/
    public static void checkFieldIsReadable(SObjectType objType, SObjectField fieldToken)
    {
    	checkFieldIsReadable(objType, fieldToken.getDescribe());
    }

    /**
     * Identical to {@link #checkFieldIsReadable(SObjectType,String)}, except with DescribeFieldResult instead of String field reference.
     * @exception FlsException if the running user does not have read rights to the {@code fieldName} field.
    **/
    public static void checkFieldIsReadable(SObjectType objType, DescribeFieldResult fieldDescribe)
    {
    	if (BYPASS_INTERNAL_FLS_AND_CRUD)
            return;
    	if (!fieldDescribe.isAccessible())
            throw new FlsException(OperationType.READ, objType, fieldDescribe.getSObjectField());
    }
    

    /**
     * Checks update field level security only (no CRUD) for the specified fields on {@code objType}
     * @exception FlsException if the running user does not have update rights to the {@code fieldName} field.
    **/    
    public static void checkFieldIsUpdateable(SObjectType objType, String fieldName)
    {
        checkFieldIsUpdateable(objType, fflib_SObjectDescribe.getDescribe(objType).getField(fieldName));
    }

    /**
     * Identical to {@link #checkFieldIsUpdateable(SObjectType,String)}, except with SObjectField instead of String field reference.
     * @exception FlsException if the running user does not have update rights to the {@code fieldName} field.
    **/
    public static void checkFieldIsUpdateable(SObjectType objType, SObjectField fieldToken)
    {
        checkFieldIsUpdateable(objType, fieldToken.getDescribe());
    }

    /**
     * Identical to {@link #checkFieldIsUpdateable(SObjectType,String)}, except with DescribeFieldResult instead of String field reference.
     * @exception FlsException if the running user does not have update rights to the {@code fieldName} field.
    **/
    public static void checkFieldIsUpdateable(SObjectType objType, DescribeFieldResult fieldDescribe)
    {
    	if (BYPASS_INTERNAL_FLS_AND_CRUD)
            return;
        if (!fieldDescribe.isUpdateable())
            throw new FlsException(OperationType.MODIFY, objType, fieldDescribe.getSObjectField());
	}

	/**
	 * CheckObjectIs* methods check only CRUD
	**/
    
    /**
     * Checks insert CRUD for the specified object type.
     * @exception CrudException if the running uder does not have insert rights to the {@code objType} SObject.
    **/
    public static void checkObjectIsInsertable(SObjectType objType)
    {
    	if (BYPASS_INTERNAL_FLS_AND_CRUD)
            return;
    	if (!objType.getDescribe().isCreateable())
    	{
    		throw new CrudException(OperationType.CREATE, objType);
    	}
    }
    
    /**
     * Checks read CRUD for the specified object type.
     * @exception CrudException if the running uder does not have read rights to the {@code objType} SObject.
    **/
    public static void checkObjectIsReadable(SObjectType objType)
    {
    	if (BYPASS_INTERNAL_FLS_AND_CRUD)
            return;
        if (!objType.getDescribe().isAccessible())
        	throw new CrudException(OperationType.READ, objType);
    }

    /**
     * Checks update CRUD for the specified object type.
     * @exception CrudException if the running uder does not have update rights to the {@code objType} SObject.
    **/    
    public static void checkObjectIsUpdateable(SObjectType objType)
    {
    	if (BYPASS_INTERNAL_FLS_AND_CRUD)
            return;
        if (!objType.getDescribe().isUpdateable())
        	throw new CrudException(OperationType.MODIFY, objType);
    }

    /**
     * Checks delete CRUD for the specified object type.
     * @exception CrudException if the running uder does not have delete rights to the {@code objType} SObject.
    **/    
    public static void checkObjectIsDeletable(SObjectType objType)
    {
    	if (BYPASS_INTERNAL_FLS_AND_CRUD)
            return;
        if (!objType.getDescribe().isDeletable())
            throw new CrudException(OperationType.DEL, objType);
    }
}