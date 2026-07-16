/**
 * Interface for field path resolution strategy.
 * Allows customization of how field paths are resolved and validated.
 * Supports Single Responsibility and Dependency Inversion principles.
 **/
public interface fflibjs_IFieldPathResolver {
    /**
     * Resolves a field path, handling validation, FLS checks, and relationship traversal
     * @param fieldName The field name or path (e.g., 'Name' or 'Account.Name')
     * @param relatedSObjectType Optional related SObject type for polymorphic fields
     * @return The resolved canonical field path
     **/
    String resolvePath(String fieldName, Schema.sObjectType relatedSObjectType);
}
