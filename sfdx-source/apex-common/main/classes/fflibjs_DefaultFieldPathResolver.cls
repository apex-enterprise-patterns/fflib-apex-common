/**
 * Default implementation of field path resolution.
 * Preserves the exact behavior of fflib_QueryFactory.getFieldPath().
 * Can be extended or replaced to customize field resolution behavior.
 **/
public class fflibjs_DefaultFieldPathResolver implements fflibjs_IFieldPathResolver {
    private fflib_QueryFactory queryFactory;

    public fflibjs_DefaultFieldPathResolver(fflib_QueryFactory qf) {
        this.queryFactory = qf;
    }

    /**
     * Resolves field paths with full support for:
     * - Single field selection
     * - Cross-object field references (e.g., 'Account.Name')
     * - Polymorphic field handling
     * - FLS enforcement (Legacy mode)
     * - Field validation via describe
     **/
    public String resolvePath(String fieldName, Schema.sObjectType relatedSObjectType) {
        // Enforcing FLS using the legacy heuristic requires resolving the full field path to its respective
        // Describe result to test for isAccessible on the DescribeFieldResult
        // This is computationally expensive and should be bypassed if the QueryFactory instance is not
        // enforcing FLS
        // Starting in Summer '22, Apex can natively enforce CRUD and FLS with User Mode Operations
        // Someday, the LEGACY FLSEnforcement heuristic will be removed
        if(queryFactory.mFlsEnforcement == fflib_QueryFactory.FLSEnforcement.USER_MODE || 
           queryFactory.mFlsEnforcement == fflib_QueryFactory.FLSEnforcement.SYSTEM_MODE){
            return fieldName;
        }

        if(!fieldName.contains('.')) { // single field
            Schema.SObjectField token = fflib_SObjectDescribe.getDescribe(queryFactory.table).getField(fieldName.toLowerCase());
            if(token == null) {
                throw new fflib_QueryFactory.InvalidFieldException(fieldName, queryFactory.table);
            }
            if(queryFactory.mFlsEnforcement == fflib_QueryFactory.FLSEnforcement.LEGACY) {
                fflib_SecurityUtils.checkFieldIsReadable(queryFactory.table, token);
            }

            return token.getDescribe().getName();
        }

        // traversing FK relationship(s)
        List<String> fieldPath = new List<String>();
        Schema.SObjectType lastSObjectType = queryFactory.table;
        Iterator<String> i = fieldName.split('\\.').iterator();
        while(i.hasNext()){
            String field = i.next();
            Schema.SObjectField token = fflib_SObjectDescribe.getDescribe(lastSObjectType).getField(field.toLowerCase());
            DescribeFieldResult tokenDescribe = token != null ? token.getDescribe() : null;
            
            if (token != null && queryFactory.mFlsEnforcement == fflib_QueryFactory.FLSEnforcement.LEGACY) {
                fflib_SecurityUtils.checkFieldIsReadable(lastSObjectType, token);
            }

            if (token != null && i.hasNext() && (tokenDescribe.getSoapType() == Schema.SoapType.ID
                || (tokenDescribe.getSoapType() == Schema.SoapType.STRING && tokenDescribe.getType() == Schema.DisplayType.REFERENCE))) {
                List<Schema.sObjectType> relatedObjs = tokenDescribe.getReferenceTo(); //if it's polymorphic, it matters which one we use - i.e. Lead.Owner is GROUP|USER and each has different fields.

                if (relatedObjs.size() == 1 || relatedSObjectType == null) {
                    lastSObjectType = relatedObjs[0]; //caller did not specify the one to use or there's only one so use the first one
                }
                else{
                    for (Schema.sObjectType sot : relatedObjs) {
                        if (fflib_SObjectDescribe.getDescribe(sot).getDescribe().getSObjectType() == relatedSObjectType) {
                            lastSObjectType = sot;
                            break;
                        }
                    }
                }

                fieldPath.add(tokenDescribe.getRelationshipName());
            }else if(token != null && !i.hasNext()){
                fieldPath.add(tokenDescribe.getName());
            }else{
                if(token == null)
                    throw new fflib_QueryFactory.InvalidFieldException(field,lastSObjectType);
                else
                    throw new fflib_QueryFactory.NonReferenceFieldException(lastSObjectType+'.'+field+' is not a lookup or master-detail field but is used in a cross-object query field.');
            }
        }

        return String.join(fieldPath,'.');
    }
}
