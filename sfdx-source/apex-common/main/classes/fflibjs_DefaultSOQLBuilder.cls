/**
 * Default implementation of SOQL query building.
 * Preserves the exact behavior of fflib_QueryFactory.toSOQL().
 * Can be extended to customize query construction without modifying fflib_QueryFactory.
 *
 * Extension points for customization:
 * - buildSelectClause()
 * - buildFromClause()
 * - buildWhereClause()
 * - buildOrderByClause()
 * - buildLimitClause()
 * - buildOffsetClause()
 * - buildAllRowsClause()
 * - buildModeClause()
 **/
public class fflibjs_DefaultSOQLBuilder implements fflibjs_ISOQLBuilder {
    protected fflib_QueryFactory queryFactory;

    public fflibjs_DefaultSOQLBuilder(fflib_QueryFactory qf) {
        this.queryFactory = qf;
    }

    /**
     * Builds the complete SOQL query by composing individual clauses.
     * Override individual build*Clause() methods to customize behavior.
     **/
    public String build() {
        String result = buildSelectClause();
        result += buildSubselectClause();
        result += buildFromClause();
        result += buildWhereClause();
        result += buildModeClause();
        result += buildOrderByClause();
        result += buildLimitClause();
        result += buildOffsetClause();
        result += buildAllRowsClause();
        return result;
    }

    /**
     * Builds the SELECT clause with field list.
     * If no fields selected, defaults to 'Id' with optional FLS checking.
     **/
    protected String buildSelectClause() {
        String result = 'SELECT ';
        
        if (queryFactory.fields.size() == 0) {
            if (queryFactory.mFlsEnforcement == fflib_QueryFactory.FLSEnforcement.LEGACY) {
                fflib_SecurityUtils.checkFieldIsReadable(queryFactory.table, 'Id');
            }
            result += 'Id';
        } else {
            List<String> fieldsToQuery = new List<String>(queryFactory.fields);
            
            if(queryFactory.sortSelectFields) {
                fieldsToQuery.sort();
            }
            
            result += String.join(fieldsToQuery, ', ');
        }
        
        return result;
    }

    /**
     * Builds the subselect (child query) clause if subqueries exist.
     * Each subquery is wrapped in parentheses.
     **/
    protected String buildSubselectClause() {
        String result = '';
        
        if(queryFactory.subselectQueryMap != null && !queryFactory.subselectQueryMap.isEmpty()) {
            for (fflib_QueryFactory childRow : queryFactory.subselectQueryMap.values()) {
                result += ', (' + childRow.toSOQL() + ') ';
            }
        }
        
        return result;
    }

    /**
     * Builds the FROM clause with table name or relationship name (for subqueries).
     **/
    protected String buildFromClause() {
        String tableName = queryFactory.relationship != null 
            ? queryFactory.relationship.getRelationshipName() 
            : queryFactory.table.getDescribe().getName();
        return ' FROM ' + tableName;
    }

    /**
     * Builds the WHERE clause if a condition expression is set.
     **/
    protected String buildWhereClause() {
        if(queryFactory.conditionExpression != null) {
            return ' WHERE ' + queryFactory.conditionExpression;
        }
        return '';
    }

    /**
     * Builds the WITH clause for USER_MODE or SYSTEM_MODE enforcement.
     * Only applied to top-level queries (relationship == null).
     **/
    protected String buildModeClause() {
        if(queryFactory.relationship == null) {
            if(queryFactory.mFlsEnforcement == fflib_QueryFactory.FLSEnforcement.USER_MODE) {
                return ' WITH USER_MODE';
            }
            else if(queryFactory.mFlsEnforcement == fflib_QueryFactory.FLSEnforcement.SYSTEM_MODE) {
                return ' WITH SYSTEM_MODE';
            }
        }
        return '';
    }

    /**
     * Builds the ORDER BY clause with all ordering specifications.
     * Each ordering includes NULLS FIRST or NULLS LAST as configured.
     **/
    protected String buildOrderByClause() {
        if(queryFactory.order.size() == 0) {
            return '';
        }
        
        String result = ' ORDER BY ';
        for(fflib_QueryFactory.Ordering o : queryFactory.order) {
            result += o.toSOQL() + ', ';
        }
        // Remove trailing ', '
        result = result.substring(0, result.length() - 2);
        return result;
    }

    /**
     * Builds the LIMIT clause if a limit is set.
     **/
    protected String buildLimitClause() {
        if(queryFactory.limitCount != null) {
            return ' LIMIT ' + queryFactory.limitCount;
        }
        return '';
    }

    /**
     * Builds the OFFSET clause if an offset is set.
     **/
    protected String buildOffsetClause() {
        if(queryFactory.offsetCount != null) {
            return ' OFFSET ' + queryFactory.offsetCount;
        }
        return '';
    }

    /**
     * Builds the ALL ROWS clause if allRows flag is set.
     * Typically used to query deleted/archived records.
     **/
    protected String buildAllRowsClause() {
        if(queryFactory.allRows) {
            return ' ALL ROWS';
        }
        return '';
    }
}
