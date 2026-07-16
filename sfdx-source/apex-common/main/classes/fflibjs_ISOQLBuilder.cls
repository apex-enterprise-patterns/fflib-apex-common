/**
 * Interface for SOQL query building strategy.
 * Allows customization of how SOQL queries are constructed.
 * Supports Open/Closed and Dependency Inversion principles.
 **/
public interface fflibjs_ISOQLBuilder {
    /**
     * Builds the complete SOQL query string
     * @return The full SOQL query ready for execution
     **/
    String build();
}
