/**
 * File Name: fflib_BindingsSelector 
 * Description: Selector for the Custom Metadata object fflib_Binding__mdt
 *
 * @author: architect ir. Wilhelmus G.J. Velzeboer
 *
 * Redistribution and use in source and binary forms, with or without modification,
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above author notice,
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 * - Neither the name of the author nor the names of its contributors
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
 */
public without sharing class fflib_BindingsSelector extends fflib_SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				fflib_Binding__mdt.Id,
				fflib_Binding__mdt.AppName__c,
				fflib_Binding__mdt.BindingObjectAlternate__c,
				fflib_Binding__mdt.BindingObject__c,
				fflib_Binding__mdt.DeveloperName,
				fflib_Binding__mdt.NamespacePrefix,
				fflib_Binding__mdt.QualifiedAPIName,
				fflib_Binding__mdt.To__c,
				fflib_Binding__mdt.Type__c
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return fflib_Binding__mdt.SObjectType;
	}

	public List<fflib_Binding__mdt> selectById(Set<Id> idSet)
	{
		return (List<fflib_Binding__mdt>) selectSObjectsById(idSet);
	}

	public List<fflib_Binding__mdt> selectAll()
	{
		return (List<fflib_Binding__mdt>) Database.query(
				newQueryFactory()
				.toSOQL()
		);
	}
}