public inherited sharing class fflib_CriteriaFactory {
  private static final String AND_JOIN = 'AND';
  private static final String OR_JOIN = 'OR';
  private static final String ELEMENTS_JOIN = ' ';
  private String referenceFieldName;
  private List<String> criteria;
  private List<Boolean> trueIfAndJoinElements;
  private Boolean nextJoinFlagValue;
  private CriteriaSize sizeMonitor;

  private fflib_CriteriaFactory() {
    referenceFieldName = null;
    criteria = new List<String>();
    trueIfAndJoinElements = new List<Boolean>();
    nextJoinFlagValue = true;
    sizeMonitor = new CriteriaSize();
  }

  public static fflib_CriteriaFactory builder() {
    return new fflib_CriteriaFactory();
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
    List<String> allCriteriaElements = new List<String>();
    Iterator<String> criteriaIterator = criteria.iterator();
    Iterator<Boolean> joinIterator = trueIfAndJoinElements.iterator();
    while (criteriaIterator.hasNext()) {
      allCriteriaElements.add(criteriaIterator.next());
      if (joinIterator.hasNext()) {
        allCriteriaElements.add(joinIterator.next() ? AND_JOIN : OR_JOIN);
      }
    }
    return String.join(allCriteriaElements, ELEMENTS_JOIN);
  }

  public fflib_CriteriaFactory configureForReferenceField(Schema.SObjectField referenceField) {
    referenceFieldName = referenceField.getDescribe().getRelationshipName();
    return this;
  }

  public fflib_CriteriaFactory equalsTo(Schema.SObjectField field, Object fieldValue) {
    addCriteria(field(field) + ' = ' + value(field, fieldValue));
    return this;
  }

  private String field(Schema.SObjectField field) {
    String fieldName = field.getDescribe().getName();
    return referenceFieldName != null ? referenceFieldName + '.' + fieldName : fieldName;
  }

  private String value(Schema.SObjectField field, Object fieldValue) {
    String value = null;
    switch on field.getDescribe().getType() {
      when DATE {
        value = dateValue(fieldValue);
      }
      when DATETIME {
        value = datetimeValue(fieldValue);
      }
      when else {
        value = stringValue(fieldValue);
      }
    }
    return value;
  }

  private String dateValue(Object fieldValue) {
    String value = null;
    if (fieldValue instanceof Date) {
      value = formatDate((Date) fieldValue);
    } else if (fieldValue instanceof String) {
      value = String.valueOf(fieldValue);
    } else {
      throw new IllegalArgumentException();
    }
    return value;
  }

  private String formatDate(Date dateValue) {
    List<String> dateParts = new List<String>{
      withLeadingZero(dateValue.year()),
      withLeadingZero(dateValue.month()),
      withLeadingZero(dateValue.day())
    };
    return String.join(dateParts, '-');
  }

  private String withLeadingZero(Integer oneTwoDigits) {
    return oneTwoDigits > 9 ? '' + oneTwoDigits : '0' + oneTwoDigits;
  }

  private String datetimeValue(Object fieldValue) {
    String value = null;
    if (fieldValue instanceof Datetime) {
      value = formatDatetime((Datetime) fieldValue);
    } else if (fieldValue instanceof String) {
      value = String.valueOf(fieldValue);
    } else {
      throw new IllegalArgumentException();
    }
    return value;
  }

  private String formatDatetime(Datetime dateTimeValue) {
    Time timeValue = dateTimeValue.timeGmt();
    List<String> timeParts = new List<String>{
      withLeadingZero(timeValue.hour()),
      withLeadingZero(timeValue.minute()),
      withLeadingZero(timeValue.second())
    };
    return formatDate(dateTimeValue.dateGmt()) + 'T' + String.join(timeParts, ':') + 'Z';
  }

  private String stringValue(Object valueObj) {
    String value = String.valueOf(valueObj);
    if (valueObj instanceof String) {
      value = isBindingVariable(value) ? value : '\'' + value + '\'';
    }
    return value;
  }

  private Boolean isBindingVariable(String value) {
    return value.startsWith(':');
  }

  public fflib_CriteriaFactory equalsTo(SoqlDateFunction df, Integer fieldValue) {
    addCriteria(dateFunction(df) + ' = ' + fieldValue);
    return this;
  }

  private String dateFunction(SoqlDateFunction df) {
    return df.dateFunction + wrapIntoBrackets(field(df.field));
  }

  public fflib_CriteriaFactory notEqualsTo(Schema.SObjectField field, Object fieldValue) {
    addCriteria(field(field) + ' != ' + value(field, fieldValue));
    return this;
  }

  public fflib_CriteriaFactory notEqualsTo(SoqlDateFunction df, Integer fieldValue) {
    addCriteria(dateFunction(df) + ' != ' + fieldValue);
    return this;
  }

  public fflib_CriteriaFactory greaterOrEqual(Schema.SObjectField field, Object fieldValue) {
    addCriteria(field(field) + ' >= ' + value(field, fieldValue));
    return this;
  }

  public fflib_CriteriaFactory greaterOrEqual(SoqlDateFunction df, Integer fieldValue) {
    addCriteria(dateFunction(df) + ' >= ' + fieldValue);
    return this;
  }

  public fflib_CriteriaFactory greaterThan(Schema.SObjectField field, Object fieldValue) {
    addCriteria(field(field) + ' > ' + value(field, fieldValue));
    return this;
  }

  public fflib_CriteriaFactory greaterThan(SoqlDateFunction df, Integer fieldValue) {
    addCriteria(dateFunction(df) + ' > ' + fieldValue);
    return this;
  }

  public fflib_CriteriaFactory lessThan(Schema.SObjectField field, Object fieldValue) {
    addCriteria(field(field) + ' < ' + value(field, fieldValue));
    return this;
  }

  public fflib_CriteriaFactory lessThan(SoqlDateFunction df, Integer fieldValue) {
    addCriteria(dateFunction(df) + ' < ' + fieldValue);
    return this;
  }

  public fflib_CriteriaFactory lessOrEqual(Schema.SObjectField field, Object fieldValue) {
    addCriteria(field(field) + ' <= ' + value(field, fieldValue));
    return this;
  }

  public fflib_CriteriaFactory lessOrEqual(SoqlDateFunction df, Integer fieldValue) {
    addCriteria(dateFunction(df) + ' <= ' + fieldValue);
    return this;
  }

  public fflib_CriteriaFactory isIn(Schema.SObjectField field, List<Object> inValues) {
    addCriteria(field(field) + ' IN ' + fieldInValue(field, inValues));
    return this;
  }

  private String fieldInValue(Schema.SObjectField field, Object inValues) {
    String value = null;
    if (inValues instanceof List<Object>) {
      value = convertToInValuesAsString((List<Object>) inValues);
    } else {
      value = String.valueOf(inValues);
    }
    return wrapIntoBrackets(value);
  }

  public fflib_CriteriaFactory isIn(Schema.SObjectField field, String subSelect) {
    addCriteria(field(field) + ' IN ' + fieldInValue(field, subSelect));
    return this;
  }

  public fflib_CriteriaFactory isIn(SoqlDateFunction df, List<Integer> inValues) {
    addCriteria(dateFunction(df) + ' IN ' + fieldInValue(df.field, inValues));
    return this;
  }

  public fflib_CriteriaFactory isNotIn(Schema.SObjectField field, List<Object> inValues) {
    addCriteria(field(field) + ' NOT IN ' + fieldInValue(field, inValues));
    return this;
  }

  public fflib_CriteriaFactory isNotIn(Schema.SObjectField field, String subSelect) {
    addCriteria(field(field) + ' NOT IN ' + fieldInValue(field, subSelect));
    return this;
  }

  public fflib_CriteriaFactory isNotIn(SoqlDateFunction df, List<Integer> inValues) {
    addCriteria(dateFunction(df) + ' NOT IN ' + fieldInValue(df.field, inValues));
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
    return stringValue(String.join(inValues, '\',\''));
  }

  public fflib_CriteriaFactory composite(fflib_CriteriaFactory complexCriteria) {
    addCriteria(wrapIntoBrackets(complexCriteria.toCriteria()));
    return this;
  }

  public fflib_CriteriaFactory isLike(Schema.SObjectField field, String fieldValue) {
    addCriteria(field(field) + ' LIKE ' + value(field, fieldValue));
    return this;
  }

  public fflib_CriteriaFactory isNotLike(Schema.SObjectField field, String fieldValue) {
    String singleCriteria = 'NOT ' + field(field) + ' LIKE ' + value(field, fieldValue);
    addCriteria(wrapIntoBrackets(singleCriteria));
    return this;
  }

  public fflib_CriteriaFactory isNull(Schema.SObjectField field) {
    addCriteria(field(field) + ' = NULL');
    return this;
  }

  public fflib_CriteriaFactory isNotNull(Schema.SObjectField field) {
    addCriteria(field(field) + ' != NULL');
    return this;
  }

  private void addCriteria(String criterion) {
    if (!criteria.isEmpty()) {
      sizeMonitor.register(nextJoinFlagValue);
      trueIfAndJoinElements.add(nextJoinFlagValue);
      withAnd();
    }
    sizeMonitor.register(criterion);
    criteria.add(criterion);
  }

  private class CriteriaSize {
    private final Integer whereLimit = 4000;
    private Integer criteriaSize = 0;

    private void register(Boolean trueIfAndJoinElement) {
      criteriaSize += trueIfAndJoinElement ? AND_JOIN.length() : OR_JOIN.length();
      criteriaSize += 2 * ELEMENTS_JOIN.length();
      failIfLimitBreached();
    }

    private void register(String criterion) {
      criteriaSize += criterion.length();
      failIfLimitBreached();
    }

    private void failIfLimitBreached() {
      if (whereLimit < criteriaSize) {
        throw new WhereClauseLimitException();
      }
    }
  }

  public class WhereClauseLimitException extends Exception {
  }

  public static SoqlDateFunction dateFunction(DateFunction df, Schema.SObjectField field) {
    SoqlDateFunction result = new SoqlDateFunction();
    result.field = field;
    result.dateFunction = df;
    return result;
  }

  public class SoqlDateFunction {
    public Schema.SObjectField field { get; set; }
    public DateFunction dateFunction;
  }

  public enum DateFunction {
    CALENDAR_MONTH,
    CALENDAR_QUARTER,
    CALENDAR_YEAR,
    DAY_IN_MONTH,
    DAY_IN_WEEK,
    DAY_IN_YEAR,
    DAY_ONLY,
    FISCAL_MONTH,
    FISCAL_QUARTER,
    FISCAL_YEAR,
    HOUR_IN_DAY,
    WEEK_IN_MONTH,
    WEEK_IN_YEAR
  }
}
