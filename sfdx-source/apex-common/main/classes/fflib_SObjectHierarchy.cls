public with sharing class fflib_SObjectHierarchy {

	private final SObjectType sobjType;
	private final SObjectField lookupField;
	private final Set<SObjectField> queryFields;

	/**
	 * This constructor takes in all the necessary information to create a hierarchy. The following components are needed.
	 * First, the type of record that comprises the hierarchy must be given. A hierarchy may only 
	 * contain one type of object within it. So for example, a hierarchy cannot contain Accounts and Cases,
	 * only one or the other.
	 * Second, the lookup field that connects the records must be given.
	 * For example, in order to construct an Account hierarchy, one would give the Account.ParentId lookup field.
	 * Third, but optional, any additional fields that you want to query during the construction of the hierarchy must be given.
	 *
	 * @param sobjType SObjectType The object type within the hierarchy 
	 * @param lookupField SObjectField The lookup field used to build the hierarchy. This field must be a lookup FROM the 
	 *    given SObjectType TO the given SObjectType.
	 * @param queryFields Set<SObjectField> The list of fields that will be added to the records when the hierarchy is traversed
	 * @exception IllegalArgumentException will be thrown if any of the arguments are null
	 * @exception IllegalArgumentException will be thrown if the lookup field is not a lookup
	 * @exception IllegalArgumentException will be thrown if the lookup does not point FROM sobjType TO the sobjType
	*/
	public fflib_SObjectHierarchy(SObjectType sobjType, SObjectField lookupField, Set<SObjectField> queryFields) {

		this.assertValidConstructorParams(sobjType, lookupField, queryFields);

		this.sobjType = sobjType;
		this.lookupField = lookupField;
		this.queryFields = queryFields;

		if (this.queryFields.contains(this.lookupField)) {
			this.queryFields.remove(this.lookupField);
		}
	}

	public fflib_SObjectHierarchy(SObjectType sobjType, SObjectField lookupField) {
		this(sobjType, lookupField, new Set<SObjectField>());
	}

	private void assertValidConstructorParams(SObjectType sobjType, SObjectField lookupField, Set<SObjectField> queryFields) {
		if (sobjType == null) {
			IllegalArgumentException iae = new IllegalArgumentException();
			iae.setMessage('sobjType cannot be null.');
			throw iae;
		}
		if (lookupField == null) {
			IllegalArgumentException iae = new IllegalArgumentException();
			iae.setMessage('lookupField cannot be null.');
			throw iae;
		}
		if (queryFields == null) {
			IllegalArgumentException iae = new IllegalArgumentException();
			iae.setMessage('queryFields cannot be null');
			throw iae;
		}
		if (lookupField.getDescribe().getType() != DisplayType.REFERENCE) {
			IllegalArgumentException iae = new IllegalArgumentException();
			iae.setMessage('Cannot construct a hierarchy with a non-lookup field [' +
					lookupField.getDescribe().getName() + ']');
			throw iae;
		}
		if (!lookupField.getDescribe().getReferenceTo().contains(sobjType)) {
			IllegalArgumentException iae = new IllegalArgumentException();
			iae.setMessage('Lookup field must point to same type as SObject type [was ' +
					lookupField.getDescribe().getReferenceTo() + ', must be ' + sobjType + ']');
			throw iae;
		}
	}

	/**
	 * This function will start from each given Id, and make a list of all SObjects 
	 * until the top of the hierarchy is found. 
	 * The hierarchy is traversed by using the lookup field given in the constructor. 
	 * For each record, the set of query fields will be queried while going up the hierarchy.
	 * Thus, every record in the hierarchy will have all fields queried that were given in queryFields.
	 * 
	 * For example, say that you have an account, A. A has a parent, B. B has a parent, C. 
	 * This function will return the following if the Id for account A is given in the set of ids.
	 *
	 *	A Map of Id to SObjects, where
	 *	A -> [A, B, C]
	 *
	 * 	Each record (A, B, and C) will have all query fields queried. If the set of query fields is empty,
	 * 	it will only have the lookup field queried.
	 * @param ids Set<Id> a non-null set of ids. These ids will each represent a key in the map, whose value is the 
	 * 	list of records until the top of the hierarchy
	 * @exception IllegalArgumentException if the given set of ids is null
	 * @exception IllegalArgumentException if the given set of ids contains a cycle somewhere in its hierarchy.
	 * @return Map<Id, List<SObject>> a map of the given id to a list of SObjects representing its hierarchy 
	*/
	public Map<Id, List<SObject>> getUntilTopOfHierarchy(Set<Id> ids) {
		/** 
		 * IMPLEMENTATION:
		 * 
		 *  The following implementation uses recursion to build a n-level deep hierarchy. 
		 *
		 *	For example, say you have a hierarchy of the form:
		 *	A -> B -> C -> D -> E -> F -> G -> H -> I
		 *  where each element is a record and they are connected by a lookup field.
		 * 
		 *  The reason that there must be a recursive call is for the following reason:
		 *	There is chance that you will not be able to parse all records in the hierarchy in one SQOL query 
		 *	(since it maxes at six levels in one call).
		 *
		 *	For this, the following recursive algorithm is employed. This algorithm does technically use SOQL in a for loop,
		 *	but it is minimal as possible.
		 *
		 *	For every six levels in the hierarchy, a SOQL is done. So in the previous example, 
		 *	A -> B -> C -> D -> E -> F -> G -> H -> I
		 *	there will be two SOQLS done. One to go from A -> F, and then one to go from G -> I.
		 *
		 *	The recursion works in the following manner:
		 *	First, a multi-level SOQL is created.
		 *	Second, for each record in given in the set of ids, navigate up the hierarchy as far as possible until a null parent is found, 
		 *		or there no parent but a parent id.
		 *  If it is the former, you have reached the top of the hierarchy, and the recursion will end. (The base case)
		 *	
		 *	If it is the latter, the parent id will be used in a recursive call to get the hierarchy from the parent id to its own top.
		 * 
		 *	So before the recursive call, you will have the following:
		 *	A -> [A, B, C, D, E, F]
		 *
		 *  But F.ParentId still has a value, thus, you have not reached the top of the hierarchy. 
		 * 
		 *	Do a recursive call with F.ParentId. You will then have the following:
		 *	G -> [G, H, I], where F.ParentId == G.Id
		 * 
		 *	The lookup field on F, is used to locate G, and then the lists are concatenated. Thus, the final output will be:
		 *	A -> [A, B, C, D, E, F, G, H, I]
		 *
		 *	and the algorithm terminates once there are no more hierarchies to view.
		 *  This algorithm has no limit on how deep the hierarchy can go. The only limits is that of salesforce and the number of SOQLs to be performed.
		*/

		if (ids == null) {
			IllegalArgumentException iae = new IllegalArgumentException();
			iae.setMessage('Cannot parse hierarchy with a null set of ids');
			throw iae;
		}

		String dynamicQuery = createDynamicMultiLevelSoql(5);
		List<SObject> records = Database.query(dynamicQuery);

		Map<Id, List<SObject>> hierarchies = new Map<Id, List<SObject>>();

		Set<Id> nextStartOfHierarchies = new Set<Id>();
		for (SObject record : records) {
			if (!hierarchies.containsKey(record.Id)) {
				hierarchies.put(record.Id, new List<SObject>());
			}

			List<SObject> hierarchy = hierarchies.get(record.Id);
			hierarchy.addAll(buildQueriedHierarchy(record));

			assertNoCycle(hierarchy);

			SObject lastElementInHierarchy = hierarchy.get(hierarchy.size() - 1);
			if (lastElementInHierarchy.get(this.lookupField) != null) {
				nextStartOfHierarchies.add((Id)lastElementInHierarchy.get(this.lookupField));
			} 
		}

		if (!nextStartOfHierarchies.isEmpty()) {
			this.attachRecursiveHierarchies(hierarchies, nextStartOfHierarchies);
		}

		return hierarchies;
	}

	/**
	 * Starting from a record, iterate as high as possible into the hierarchy.
	 * The record in question was started from a multi-level query of the following form:
	 * Parent.Parent.Parent.Parent.Parent.*
	 * 
	 * Thus, the iteration will go parent by parent, until parent is null. 
	 * If parent ends up being null, but there is still a parent-id on the last record,
	 * the algorithm will start recursively from the parent id.
	 */
	private List<SObject> buildQueriedHierarchy(SObject record) {
		List<SObject> hierarchy = new List<SObject>();
		SObject iterator = record;
		while (true) {
			hierarchy.add(iterator);
			if (!doesParentExist(iterator)) {
				break;
			}
			iterator = iterator.getSObject(this.lookupField);
		}

		return hierarchy;
	}

	/**
	 * Checks if the given hierarchy has a cycle within it.
	 * It does this in the following manner.
	 * 
	 * If there are any ids that are duplicates within the list of SObjects,
	 * there must be one SObjects that has already been traversed.
	 * 
	 * If this is the case, then there is a cycle. 
	 * 
	 * For example, if you have a list A -> B -> C -> D -> E -> A
	 * A appearing twice implies a cycle, since continuing the hierarchy would result in
	 * A -> B -> C -> D -> E -> A -> B -> C -> D -> E -> A.
	 */
	private void assertNoCycle(List<SObject> sobjects) {

		Set<Id> ids = new Set<Id>();
		for (SObject sObj : sobjects) {
			ids.add(sObj.Id);
		}

		if (ids.size() != sobjects.size()) {
			IllegalArgumentException iae = new IllegalArgumentException();
			iae.setMessage('The hierarchy contained a cycle ' + sobjects +  '.');
			throw iae;
		}
	}

	/**
	 * If the record is able to find a parent sobject attached to it, this function will return true.
	 * If there is NO parent, but a LookupFieldId does exist (such as ParentId) this function will return false. 
	 * If there is NO parent and no LookupFieldId, this function will return false.
	 */
	private Boolean doesParentExist(SObject record) {
		try {
			return record.getSObject(this.lookupField) != null;
		} catch (System.SObjectException e) {
			return false;
		}
	}
	
	/**
	 * Whenever a query is done, the longest SOQL lookup field chain can be something of the following form:
	 * Parent.Parent.Parent.Parent.Parent.ParentId 
	 * 
	 * If there are five parents, and still a ParentId on the last parent, that id 
	 * will be contained within nextStartOfHierarchies.
	 * 
	 * The algorithm will be ran again, and the last record of the current hierarchy (found in hierarchies)
	 * will link its ParentId to the the newly parsed hierarchy.
	 * 
	 * For example, if hierarchies contained A -> [A, B, C, D, E, F], and then a new hierarchy was created
	 * (starting from F.ParentId) was G -> [G, H, I, J, K], then G's Id == F.ParentId.
	 * 
	 * Thus, attach the hierarchy of G to the end of A's hierarchy, giving you,
	 * A -> [A, B, C, D, E, F, G, H, I, J, K].
	 */
	private void attachRecursiveHierarchies(Map<Id, List<SObject>> hierarchies, Set<Id> nextStartOfHierarchies) {
		Map<Id, List<SObject>> recursion = this.getUntilTopOfHierarchy(nextStartOfHierarchies);

		for (Id identifier : hierarchies.keySet()) {
			List<SObject> hierarchy = hierarchies.get(identifier);
			SObject topOfHierarchySObject = hierarchy.get(hierarchy.size() - 1);

			Id parentIdLookup = (Id)topOfHierarchySObject.get(this.lookupField);
			if (recursion.containsKey(parentIdLookup)) {
				hierarchy.addAll(recursion.get(parentIdLookup));
			}
		}
	}

	/**
	 * This function will query as many lookups (along with its queryFields) as it possibly can in one SOQL statement.
	 * For example, if you were using the Account.ParentId field, while also supplying queryFields with Account.Name, the following SOQL
	 * will be created.
	 * 
	 * Name
	 * Parent.ParentId
	 * Parent.Name
	 * Parent.Parent.ParentId
	 * Parent.Parent.Name
	 * Parent.Parent.Parent.ParentId
	 * Parent.Parent.Parent.Name
	 * Parent.Parent.Parent.Parent.ParentId
	 * Parent.Parent.Parent.Parent.Name
	 * Parent.Parent.Parent.Parent.Parent.ParentId 
	 * Parent.Parent.Parent.Parent.Parent.Name
	 *
	 *	A SOQL string with field: 
	 *	Parent.Parent.Parent.Parent.Parent.Parent.ParentId 
	 *
	 *	is considered an invalid SOQL statement.
	 *  Thus, five levels of parents is the deepest this function can go.
	 */
	private String createDynamicMultiLevelSoql(Integer numLevels) {
		String dynamicSoql = 'SELECT {0} FROM ' + this.sobjType.getDescribe().getName() + ' WHERE Id IN :ids';

		List<String> fields = new List<String>();

		for (SObjectField field : this.queryFields) {
			fields.add(field.getDescribe().getName());
		}

		for (Integer i = 0; i < numLevels; i++) {
			String lookupFieldName = this.lookupField.getDescribe().getName();
			String prefix = getMultiLookupPrefix(lookupFieldName, i + 1);
			fields.add(prefix + lookupFieldName);

			for (SObjectField field : this.queryFields) {
				fields.add(prefix + field.getDescribe().getName());
			}
		}

		String completeFields = String.join(fields, ',');
		return String.format(dynamicSoql, new List<Object> {completeFields});
	}

	/**
	 * Given a field name, repeats the field name a given amount of times in SOQL format.
	 * For example, given the field Account.ParentId (which fieldName would be ParentId), and
	 * numRepeats is 4, the return of this function would be: Parent.Parent.Parent.Parent.
	 */
	private String getMultiLookupPrefix(String fieldName, Integer numRepeats) {
		String prefix = '';
		if (fieldName.endsWith('Id')) {
			prefix = fieldName.removeEnd('Id').repeat('.', numRepeats) + '.';
		} else {
			prefix = fieldName.replace('__c', '__r').repeat('.', numRepeats) + '.';
		}
		return prefix;
	}
}
