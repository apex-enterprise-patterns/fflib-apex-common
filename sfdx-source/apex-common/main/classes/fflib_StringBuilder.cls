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
 * Helper class, roughly based on the Java version, but subclassed to assist in a number of use cases in this library
 * 
 * NOTE: Aspects of this where developed before recent improvements to String handling, as such could likely be enhanced at this stage.
 **/
public virtual class fflib_StringBuilder
{
	protected List<String> buffer = new List<String>();
	
	/**
	 * Construct an empty StringBuilder
	 **/
	public fflib_StringBuilder() {}
	
	/**
	 * Construct a StringBuilder with the given values
	 **/
	public fflib_StringBuilder(List<String> values)
	{
		add(values);
	}
	
	/**
	 * Add the given values to the StringBuilder
	 **/
	public virtual void add(List<String> values)
	{
		buffer.addAll(values);
	}

	/**
	 * Add the given value to the StringBuilder
	 **/
	public virtual void add(String value)
	{
		buffer.add(value);
	}
	
	public virtual override String toString()
	{
		return String.join(buffer, '');
	}

	/**
	 * Return the state of the StringBuilder
	 **/
	public virtual String getStringValue()
	{
		return toString();
	}

	/**
	 * Subclasses the StringBuilder to produce a comma delimited concatenation of strings
	 **/
	public virtual with sharing class CommaDelimitedListBuilder extends fflib_StringBuilder
	{
		String itemPrefix = '';
		String delimiter = ',';
		
		public CommaDelimitedListBuilder() {}

		public CommaDelimitedListBuilder(List<String> values)
		{
			super(values);
		}
		
		public void setItemPrefix(String itemPrefix)
		{
			this.itemPrefix = itemPrefix;
		}
		
		public void setDelimiter(String delimiter)
		{
			this.delimiter = delimiter;
		}
		
		public String getStringValue(String itemPrefix)
		{
			setItemPrefix(itemPrefix);
			return toString();
		}
		
		public override String toString()
		{
			return itemPrefix + String.join(buffer, delimiter + itemPrefix);
		}
	}

	/** 
	 * Subclasses the StringCommaDelimitedBuilder to accept native SObjectField tokens and optional FieldSet definitions to concatinate when building queries
	 **/
	public virtual with sharing class FieldListBuilder extends CommaDelimitedListBuilder
	{
		public FieldListBuilder(List<Schema.SObjectField> values)
		{
			this(values, null);
		}
		
		public FieldListBuilder(List<Schema.SObjectField> values, List<Schema.FieldSet> fieldSets)
		{
			// Create a distinct set of fields (or field paths) to select
			for(Schema.SObjectField value : values)
				add(String.valueOf(value)); // Alternative to value.getDescribe().getName()
			
			if(fieldSets!=null)
				for(Schema.Fieldset fieldSet : fieldSets)
					for(Schema.FieldSetMember fieldSetMember : fieldSet.getFields())
						add(fieldSetMember.getFieldPath());
		}
	}
	
	/**
	 * Subclasses the FieldListBuilder to auto sense and include when needed the CurrencyIsoCode field in the field list
	 **/
	public with sharing class MultiCurrencyFieldListBuilder extends FieldListBuilder
	{
		public MultiCurrencyFieldListBuilder(List<Schema.SObjectField> values)
		{
			this(values, null);
		}
		
		public MultiCurrencyFieldListBuilder(List<Schema.SObjectField> values, List<Schema.FieldSet> fieldSets)
		{
			super(values, fieldSets);
			
			// Dynamically add CurrencyIsoCode field for multi-currency organisations
			if(UserInfo.isMultiCurrencyOrganization())
				add('CurrencyIsoCode');
		}
	}	
}