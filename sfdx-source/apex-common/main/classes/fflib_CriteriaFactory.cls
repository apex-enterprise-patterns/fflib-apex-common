public inherited sharing class fflib_CriteriaFactory {
  private String referenceFieldNamePreffix;
  private List<String> criteria;
  private List<Boolean> trueIfAndJoinElements;
  private Boolean nextJoinFlagValue;

  public fflib_CriteriaFactory() {
    referenceFieldNamePreffix = null;
    criteria = new List<String>();
    trueIfAndJoinElements = new List<Boolean>();
    nextJoinFlagValue = true;
  }

  public fflib_CriteriaFactory withOr() {
    nextJoinFlagValue = false;
    return this;
  }

  public fflib_CriteriaFactory withAnd() {
    nextJoinFlagValue = true;
    return this;
  }

  public String toCriteria() {
    List<String> finalCriteriaElements = new List<String>();
    Iterator<String> criteriaIterator = criteria.iterator();
    Iterator<Boolean> joinIterator = trueIfAndJoinElements.iterator();
    while (criteriaIterator.hasNext()) {
      finalCriteriaElements.add(criteriaIterator.next());
      if (joinIterator.hasNext()) {
        finalCriteriaElements.add(joinIterator.next() ? 'AND' : 'OR');
      }
    }
    return String.join(finalCriteriaElements, ' ');
  }

  public fflib_CriteriaFactory configureForReferenceField(Schema.SObjectField referenceField) {
    referenceFieldNamePreffix = referenceField.getDescribe().getRelationshipName() + '.';
    return this;
  }

  public fflib_CriteriaFactory equalsTo(Schema.SObjectField field, Object fieldValue) {
    addCriteria(fieldName(field) + ' = ' + wrapIntoQuotesIfString(fieldValue));
    return this;
  }

  private String fieldName(Schema.SObjectField field) {
    String fieldName = field.getDescribe().getName();
    return referenceFieldNamePreffix != null ? referenceFieldNamePreffix + fieldName : fieldName;
  }

  private String wrapIntoQuotesIfString(Object value) {
    if (value instanceof String) {
      return '\'' + value + '\'';
    }
    return '' + value;
  }

  public fflib_CriteriaFactory notEqualsTo(Schema.SObjectField field, Object fieldValue) {
    addCriteria(fieldName(field) + ' != ' + wrapIntoQuotesIfString(fieldValue));
    return this;
  }

  public fflib_CriteriaFactory greaterOrEqual(Schema.SObjectField field, Object fieldValue) {
    addCriteria(fieldName(field) + ' >= ' + fieldValue);
    return this;
  }

  public fflib_CriteriaFactory greaterThan(Schema.SObjectField field, Object fieldValue) {
    addCriteria(fieldName(field) + ' > ' + fieldValue);
    return this;
  }

  public fflib_CriteriaFactory lessThan(Schema.SObjectField field, Object fieldValue) {
    addCriteria(fieldName(field) + ' < ' + fieldValue);
    return this;
  }

  public fflib_CriteriaFactory lessOrEqual(Schema.SObjectField field, Object fieldValue) {
    addCriteria(fieldName(field) + ' <= ' + fieldValue);
    return this;
  }

  public fflib_CriteriaFactory isIn(Schema.SObjectField field, List<Object> inValues) {
    addCriteria(fieldName(field) + ' IN ' + wrapIntoBrackets(convertToInValuesAsString(inValues)));
    return this;
  }

  public fflib_CriteriaFactory isIn(Schema.SObjectField field, String subSelect) {
    addCriteria(fieldName(field) + ' IN ' + wrapIntoBrackets(subSelect));
    return this;
  }

  public fflib_CriteriaFactory isNotIn(Schema.SObjectField field, List<Object> inValues) {
    addCriteria(fieldName(field) + ' NOT IN ' + wrapIntoBrackets(convertToInValuesAsString(inValues)));
    return this;
  }

  public fflib_CriteriaFactory isNotIn(Schema.SObjectField field, String subSelect) {
    addCriteria(fieldName(field) + ' NOT IN ' + wrapIntoBrackets(subSelect));
    return this;
  }

  private String wrapIntoBrackets(String value) {
    return '(' + value + ')';
  }

  private String convertToInValuesAsString(List<Object> inValues) {
    if (inValues instanceof List<String>) {
      return convertToInString(inValues);
    }
    return String.join(inValues, ',');
  }

  private String convertToInString(List<Object> inValues) {
    return wrapIntoQuotesIfString(String.join(inValues, '\',\''));
  }

  public fflib_CriteriaFactory composite(fflib_CriteriaFactory complexCriteria) {
    addCriteria(wrapIntoBrackets(complexCriteria.toCriteria()));
    return this;
  }

  public fflib_CriteriaFactory isLike(Schema.SObjectField field, Object fieldValue) {
    addCriteria(fieldName(field) + ' LIKE ' + wrapIntoQuotesIfString(fieldValue));
    return this;
  }

  public fflib_CriteriaFactory isNotLike(Schema.SObjectField field, Object fieldValue) {
    String singleCriteria = 'NOT ' + fieldName(field) + ' LIKE ' + wrapIntoQuotesIfString(fieldValue);
    addCriteria(wrapIntoBrackets(singleCriteria));
    return this;
  }

  public fflib_CriteriaFactory isNull(Schema.SObjectField field) {
    addCriteria(fieldName(field) + ' = NULL');
    return this;
  }

  public fflib_CriteriaFactory isNotNull(Schema.SObjectField field) {
    addCriteria(fieldName(field) + ' != NULL');
    return this;
  }

  private void addCriteria(String criterion) {
    if (!criteria.isEmpty()) {
      trueIfAndJoinElements.add(nextJoinFlagValue);
      withAnd();
    }
    criteria.add(criterion);
  }
}
