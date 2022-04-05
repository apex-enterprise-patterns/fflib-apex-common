public class fflib_WhereBuilder implements fflib_IWhereBuilder{
    @testVisible
    private List<Object> contents = new List<Object>();
    public static fflib_IWhereBuilder whereX(String condition){
        return new fflib_WhereBuilder(condition);
    }
    public static fflib_IWhereBuilder whereX(fflib_IWhereBuilder condition){
        return new fflib_WhereBuilder(condition);
    }
    public static fflib_IWhereBuilder andX(String condition1, String condition2){
        return new fflib_WhereBuilder(condition1).andX(condition2);
    }
    public static fflib_IWhereBuilder andX(String condition1, fflib_IWhereBuilder condition2){
        return new fflib_WhereBuilder(condition1).andX(condition2);
    }
    public static fflib_IWhereBuilder andX(fflib_IWhereBuilder condition1, fflib_IWhereBuilder condition2){
        return new fflib_WhereBuilder(condition1).andX(condition2);
    }
    public static fflib_IWhereBuilder orX(fflib_IWhereBuilder condition1, fflib_IWhereBuilder condition2){
        return new fflib_WhereBuilder(condition1).orX(condition2);
    }
    public static fflib_IWhereBuilder orX(String condition1, String condition2){
        return new fflib_WhereBuilder(condition1).orX(condition2);
    }
    public static fflib_IWhereBuilder orX(String condition1, fflib_IWhereBuilder condition2){
        return new fflib_WhereBuilder(condition1).orX(condition2);
    }
    @testVisible
    private fflib_WhereBuilder(){}
    @testVisible
    private fflib_WhereBuilder(String condition){
        contents.add(condition);
    }
    @testVisible
    private fflib_WhereBuilder(fflib_IWhereBuilder condition){
        contents.add(condition);
    }
    public fflib_IWhereBuilder andX(String condition){
        return this.addImpl('AND', condition);
    }
    public fflib_IWhereBuilder andX(fflib_IWhereBuilder condition){
        return this.addImpl('AND', condition);
    }
    public fflib_IWhereBuilder orX(String condition){
        return this.addImpl('OR', condition);
    }
    public fflib_IWhereBuilder orX(fflib_IWhereBuilder condition){
        return this.addImpl('OR', condition);
    }
    override public String toString(){
        if(contents.isEmpty()){
            return null;
        }
        fflib_StringBuilder.CommaDelimitedListBuilder stringBuilder = new fflib_StringBuilder.CommaDelimitedListBuilder();
        for(Object content : contents){
            stringBuilder.add(formatContent(content));
        }
        stringBuilder.setDelimiter(' ');
        return stringBuilder.toString();
    }
    @testVisible
    private fflib_IWhereBuilder addImpl(String op, Object condition){
        if(!contents.isEmpty()){
            contents.add(op);
        }
        contents.add(condition);
        return this;
    }
    @testVisible
    private String formatContent(Object content){
        String formatted = content.toString();
        if(content instanceof fflib_IWhereBuilder){
            formatted = '(' + formatted + ')';
        }
        return formatted;
    }
}
