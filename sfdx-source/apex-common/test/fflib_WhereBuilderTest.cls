@isTest
private class fflib_WhereBuilderTest{
    @isTest
    private static void staticWhereXString(){
        String testParam = getRandomString();
        fflib_WhereBuilder builder = (fflib_WhereBuilder) fflib_WhereBuilder.whereX(testParam);
        System.assertEquals(new List<Object>{testParam}, builder.contents, 'Method call intialized builder incorrectly.');
    }
    @isTest
    private static void staticWhereXBuilder(){
        fflib_IWhereBuilder testParam = new fflib_WhereBuilder(getRandomString());
        fflib_WhereBuilder builder = (fflib_WhereBuilder) fflib_WhereBuilder.whereX(testParam);
        System.assertEquals(new List<Object>{testParam}, builder.contents, 'Method call intialized builder incorrectly.');
    }
    @isTest
    private static void staticAndXStrings(){
        String testParam1 = getRandomString();
        String testParam2 = getRandomString();
        fflib_WhereBuilder builder = (fflib_WhereBuilder) fflib_WhereBuilder.andX(testParam1, testParam2);
        System.assertEquals(new List<Object>{testParam1, 'AND', testParam2}, builder.contents, 'Method call intialized builder incorrectly.');
    }
    @isTest
    private static void staticAndXBuilders(){
        fflib_IWhereBuilder testParam1 = new fflib_WhereBuilder(getRandomString());
        fflib_IWhereBuilder testParam2 = new fflib_WhereBuilder(getRandomString());
        fflib_WhereBuilder builder = (fflib_WhereBuilder) fflib_WhereBuilder.andX(testParam1, testParam2);
        System.assertEquals(new List<Object>{testParam1, 'AND', testParam2}, builder.contents, 'Method call intialized builder incorrectly.');
    }
    @isTest
    private static void staticAndXMix(){
        String testParam1 = getRandomString();
        fflib_IWhereBuilder testParam2 = new fflib_WhereBuilder(getRandomString());
        fflib_WhereBuilder builder = (fflib_WhereBuilder) fflib_WhereBuilder.andX(testParam1, testParam2);
        System.assertEquals(new List<Object>{testParam1, 'AND', testParam2}, builder.contents, 'Method call intialized builder incorrectly.');
    }
    @isTest
    private static void staticOrXStrings(){
        String testParam1 = getRandomString();
        String testParam2 = getRandomString();
        fflib_WhereBuilder builder = (fflib_WhereBuilder) fflib_WhereBuilder.orX(testParam1, testParam2);
        System.assertEquals(new List<Object>{testParam1, 'OR', testParam2}, builder.contents, 'Method call intialized builder incorrectly.');
    }
    @isTest
    private static void staticOrXBuilders(){
        fflib_IWhereBuilder testParam1 = new fflib_WhereBuilder(getRandomString());
        fflib_IWhereBuilder testParam2 = new fflib_WhereBuilder(getRandomString());
        fflib_WhereBuilder builder = (fflib_WhereBuilder) fflib_WhereBuilder.orX(testParam1, testParam2);
        System.assertEquals(new List<Object>{testParam1, 'OR', testParam2}, builder.contents, 'Method call intialized builder incorrectly.');
    }
    @isTest
    private static void staticOrXMix(){
        String testParam1 = getRandomString();
        fflib_IWhereBuilder testParam2 = new fflib_WhereBuilder(getRandomString());
        fflib_WhereBuilder builder = (fflib_WhereBuilder) fflib_WhereBuilder.orX(testParam1, testParam2);
        System.assertEquals(new List<Object>{testParam1, 'OR', testParam2}, builder.contents, 'Method call intialized builder incorrectly.');
    }
    @isTest
    private static void ctor(){
        System.assertEquals(0, new fflib_WhereBuilder().contents.size());
    }
    @isTest
    private static void ctorString(){
        String rando = getRandomString();
        fflib_WhereBuilder builder = new fflib_WhereBuilder(rando);
        System.assertEquals(new List<Object>{rando}, builder.contents, 'Constructor initialized contents incorrectly.');
    }
    @isTest
    private static void ctorSubBuilder(){
        fflib_WhereBuilder subBuilder = new fflib_WhereBuilder();
        fflib_WhereBuilder builder = new fflib_WhereBuilder(subBuilder);
        System.assertEquals(new List<Object>{subBuilder}, builder.contents, 'Constructor initialized contents incorrectly.');
    }
    @isTest
    private static void andX(){
        fflib_WhereBuilder builder = new fflib_WhereBuilder();
        List<String> expected = new List<String>();
        for(Integer i = 0; i < 42; i++){
            String rando = getRandomString();
            expected.add('AND');
            expected.add(rando);
            builder.andX(rando);
        }
        expected.remove(0);
        System.assertEquals(expected, builder.contents, 'Contents of WhereBuilder were not as expected.');
        System.assertEquals(String.join(expected, ' '), builder.toString());
    }
    @isTest
    private static void orX(){
        fflib_WhereBuilder builder = new fflib_WhereBuilder();
        List<String> expected = new List<String>();
        for(Integer i = 0; i < 42; i++){
            String rando = getRandomString();
            expected.add('OR');
            expected.add(rando);
            builder.orX(rando);
        }
        expected.remove(0);
        System.assertEquals(expected, builder.contents, 'Contents of WhereBuilder were not as expected.');
        System.assertEquals(String.join(expected, ' '), builder.toString(), 'WhereBuilder did not build a correct string.');
    }
    @isTest
    private static void addImplEmpty(){
        String expected = getRandomString();
        fflib_WhereBuilder builder = new fflib_WhereBuilder();
        builder.addImpl(getRandomString(), expected);
        System.assertEquals(1, builder.contents.size(), 'Contents of WhereBuilder is not just the string added.');
        System.assertEquals(expected, builder.contents[0], 'Contents of WhereBuilder were not as expected.');
        System.assertEquals(expected, builder.toString(), 'WhereBuilder did not build a correct string.');
    }
    @isTest
    private static void addImplNotEmpty(){
        List<String> expected = new List<String>{getRandomString(), getRandomString(), getRandomString()};
        fflib_WhereBuilder builder = new fflib_WhereBuilder(expected[0]);
        String rando2 = getRandomString();
        builder.addImpl(expected[1], expected[2]);
        System.assertEquals(expected.size(), builder.contents.size(), 'Number of contents of WhereBuilder is not expected.');
        System.assertEquals(expected, builder.contents, 'Contents of WhereBuilder were not as expected.');
        System.assertEquals(String.join(expected, ' '), builder.toString(), 'WhereBuilder did not build a correct string.');
    }
    @isTest
    private static void formatContentString(){
        String testParam = getRandomString();
        System.assertEquals(testParam, (new fflib_WhereBuilder()).formatContent(testParam), 'formatContent did not return the unchanged string.');
    }
    @isTest
    private static void formatContentBuilder(){
        fflib_IWhereBuilder testParam = new fflib_WhereBuilder(getRandomString());
        System.assertEquals('(' + testParam.toString() + ')', (new fflib_WhereBuilder()).formatContent(testParam), 'formatContent did not return the unchanged string.');
    }
    private static String getRandomString(){
        return 'Test' + Math.random().format();
    }
}
