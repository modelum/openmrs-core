/**
 * This is an automatically generated file
 *
 * @name Relationship Renamed
 * @kind alert
 * @problem.severity warning
 * @id java/orion/relationship-renamed/0
 */
 
import java
import utils

from
  Class sourceEntity, Field relationshipField, Location usageLoc, string message,
  string oldTableName, string newTableName
where
  isEntity(sourceEntity) and
  oldTableName = "order_type_class_map" and
  newTableName = "order_type_concept_class" and

  // search a field with @JoinTable annotation
  relationshipField = sourceEntity.getAField() and
  exists(Annotation joinTable |
    getRelationshipMappingAnnotation(relationshipField, oldTableName, joinTable)
    and
    usageLoc = joinTable.getLocation() and
    message =
      "Join table name will change from '" + oldTableName + "' to '" + newTableName + "'."
  ) 
select usageLoc, message
