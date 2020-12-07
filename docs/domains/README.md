# Domains

The domain is a wrapper around a list of objects with low level business logic. A domain typically contains these methods;;

- Getters <br/>
  To retrieve information for the objects inside the domain
- Setters <br/>
  Change data on the objects in the domain
- Selectors <br/>
  Select a subset of records based on criteria
- Business logic <br/>
  Perform complex operations on the objects of the domain, no external references out side the domain. 

The objects contained in a domain can be of these data-types;

- SObjects
- Compound domains
- Data Transfer Objects (DTO's)  
