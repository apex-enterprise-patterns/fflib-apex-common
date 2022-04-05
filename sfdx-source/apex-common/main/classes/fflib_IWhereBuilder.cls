public interface fflib_IWhereBuilder {
    fflib_IWhereBuilder andX(String condition);
    fflib_IWhereBuilder andX(fflib_IWhereBuilder condition);
    fflib_IWhereBuilder orX(String condition);
    fflib_IWhereBuilder orX(fflib_IWhereBuilder condition);
}