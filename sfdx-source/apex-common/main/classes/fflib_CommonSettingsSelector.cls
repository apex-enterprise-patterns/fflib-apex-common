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
 * Selector-like class for fflib_CommonSettings__mdt, the settings record that configures fflib-apex-common
 *
 * Deliberately does not extend fflib_SObjectSelector: the base selector reads these settings to determine its
 * default DataAccess, so depending on it here would be circular. Queries always run in SYSTEM_MODE because
 * library configuration must be readable regardless of the running user's permissions.
 **/
public virtual inherited sharing class fflib_CommonSettingsSelector
{
	public static final String DEFAULT_RECORD_NAME = 'Default';

	public static fflib_CommonSettingsSelector newInstance()
	{
		return new fflib_CommonSettingsSelector();
	}

	public virtual List<fflib_CommonSettings__mdt> selectByDeveloperName(Set<String> developerNames)
	{
		String soql = String.format(
				'SELECT {0}, {1}, {2} FROM {3} WHERE {1} IN :developerNames ORDER BY {1}',
				new List<Object> {
					fflib_CommonSettings__mdt.Id,
					fflib_CommonSettings__mdt.DeveloperName,
					fflib_CommonSettings__mdt.DefaultDataAccess__c,
					fflib_CommonSettings__mdt.SObjectType
				}
			);
		return (List<fflib_CommonSettings__mdt>) Database.query(soql, AccessLevel.SYSTEM_MODE);
	}

	/**
	 * Returns the Default settings record, or null if it does not exist
	 **/
	public virtual fflib_CommonSettings__mdt selectDefault()
	{
		List<fflib_CommonSettings__mdt> records = selectByDeveloperName(new Set<String> { DEFAULT_RECORD_NAME });
		return records.isEmpty() ? null : records[0];
	}
}
