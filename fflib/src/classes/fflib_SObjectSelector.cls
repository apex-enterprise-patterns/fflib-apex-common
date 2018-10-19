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

/**
 * Class providing common database query support for abstracting and encapsulating query logic
 **/
public abstract with sharing class fflib_SObjectSelector extends fflib_SObjectSelectorBase
	implements fflib_ISObjectSelector
{
    /**
     * Constructs the Selector, defaults to not including any FieldSet fields automatically
     **/
    public fflib_SObjectSelector()
    {
        super(false);
    }

    /**
     * Constructs the Selector
     *
     * @param includeFieldSetFields Set to true if the Selector queries are to include Fieldset fields as well
     **/
    public fflib_SObjectSelector(Boolean includeFieldSetFields)
    {
        super(includeFieldSetFields, true, false);
    }

    /**
     * Constructs the Selector
     *
     * @param includeFieldSetFields Set to true if the Selector queries are to include Fieldset fields as well
     **/
    public fflib_SObjectSelector(Boolean includeFieldSetFields, Boolean enforceCRUD, Boolean enforceFLS)
    {
        super(includeFieldSetFields, enforceCRUD, enforceFLS, true);
    }

    /**
     * Constructs the Selector
     *
     * @param includeFieldSetFields Set to true if the Selector queries are to include Fieldset fields as well
     * @param enforceCRUD Enforce CRUD security
     * @param enforeFLS Enforce Field Level Security
     * @param sortSelectFields Set to false if selecting many columns to skip sorting select fields and improve performance
     **/
    public fflib_SObjectSelector(Boolean includeFieldSetFields, Boolean enforceCRUD, Boolean enforceFLS, Boolean sortSelectFields)
    {
        super(includeFieldSetFields, enforceCRUD, enforceFLS, sortSelectFields);
    }
}