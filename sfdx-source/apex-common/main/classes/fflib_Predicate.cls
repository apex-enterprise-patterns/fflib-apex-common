/**
 * A class that represents a predicate for building dynamic SOQL queries.
 */
public virtual class fflib_Predicate implements fflib_Expression {

    protected final String comparisonOperator {get; private set;}
    protected String field {get; private set;}
    protected Object value {get; private set;}
    protected final fflib_QueryFactory fflibQueryFactory {get; private set;}

    /**
     * Constructs a new fflib_Predicate instance.
     *
     * @param comparisonOperator The comparison operator of the predicate.
     * @param field The field of the predicate.
     * @param value The value of the predicate.
     * @param fflibQueryFactory The fflib_QueryFactory instance.
     */
    public fflib_Predicate(String comparisonOperator, String field, Object value, fflib_QueryFactory fflibQueryFactory) {
        this.comparisonOperator = comparisonOperator;
        this.field = field;
        this.value = value;
        this.fflibQueryFactory = fflibQueryFactory;
    }

    /**
     * Adds a predicate to the list of expressions.
     *
     * @param predicate The predicate to add.
     */
    public void add(fflib_Expression predicate) {
        // expressions.add(predicate);
    }

    /**
     * Accepts an fflib_Expression object to visit the predicate.
     *
     * @param sqlTreeWalker The fflib_Expression object to visit the predicate.
     */
    public void accept(fflib_Expression sqlTreeWalker) {
        // sqlTreeWalker.visitJunction(this);
    }

    /**
     * Appends the SOQL representation of the predicate to the StringBuilder.
     *
     * @param sb The StringBuilder to append the SOQL representation.
     */
    virtual public void appendSOQLString(fflib_StringBuilder sb) {
        String fieldPath = fflibQueryFactory.getFieldPath(field, null);
        sb.add(fieldPath);
        sb.add(comparisonOperator);
        appendSOQLString(sb, value);
    }

    /**
     * Appends the SOQL representation of the value to the StringBuilder.
     *
     * @param sb The StringBuilder to append the SOQL representation.
     * @param value The value to append.
     */
    public void appendSOQLString(fflib_StringBuilder sb, Object value) {
        String fieldPath = fflibQueryFactory.getFieldPath(field, null);
        Schema.DisplayType fieldType = fflibQueryFactory.fieldTypeIndexedByName.get(fieldPath);

        switch on fieldType {
            when DATE {
                appendDate(sb, value);
            }
            when DATETIME {
                appendDateTime(sb, value);
            }
            when else {
                appendStringLiteral(sb, value);
            }
        }
    }

    /**
     * Appends a string literal representation to the StringBuilder.
     *
     * @param sb The StringBuilder to append the string literal representation.
     * @param value The value to append.
     */
    @TestVisible
    private static void appendStringLiteral(fflib_StringBuilder sb, Object value) {
        String str = '' + value;
        if ((value instanceof String || value instanceof Id)) {
            str = str.startsWith(':') ? str : '\'' + value + '\'';
            sb.add(str);
        } else {
            sb.add(str);
        }
    }

    /**
     * Appends a date representation to the StringBuilder.
     *
     * @param sb The StringBuilder to append the date representation.
     * @param value The value to append.
     */
    @TestVisible
    private static void appendDate(fflib_StringBuilder sb, Object value) {
        if (value instanceof Date) {
            String dateValue = Datetime.newInstance(((Date)value).year(), ((Date)value).month(), ((Date)value).day()).format('YYYY-MM-dd').split(' ')[0];
            sb.add(dateValue);
        } else if (value instanceof String) {
            sb.add('' + value);
        } else {
            throw new IllegalArgumentException();
        }
    }

    /**
     * Appends a datetime representation to the StringBuilder.
     *
     * @param sb The StringBuilder to append the datetime representation.
     * @param value The value to append.
     */
    @TestVisible
    private static void appendDateTime(fflib_StringBuilder sb, Object value) {
        if (value instanceof Datetime) {
            sb.add('' + ((Datetime)value).format('yyyy-MM-dd') + 'T' + ((Datetime)value).format('HH:mm:ss') + 'Z');
        } else if (value instanceof String) {
            sb.add('' + value);
        } else {
            throw new IllegalArgumentException();
        }
    }
}