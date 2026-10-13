/**
 * This is an automatically generated file
 *
 * @name Attribute Promoted
 * @kind alert
 * @problem.severity warning
 * @id java/orion/attribute-promoted/0
 */
 
import java
import utils

from Class entity, Field existingIdField, Location usageLoc, string message, string newIdFieldName
where
  isEntity(entity) and 
  entity.hasName("Encounter") and 
  existingIdField = entity.getAField() and
  
  // field with a @Id annotation
  exists(Annotation idAnnotation |
    idAnnotation = existingIdField.getAnAnnotation() and
    isIdAnnotation(idAnnotation)
  ) and
  
  // Nombre del nuevo campo que será parte de la clave compuesta
  newIdFieldName = "encounterDatetime" and
  
  (
    (usageLoc = existingIdField.getLocation() and
     message = "Field '" + existingIdField.getName() + "' will become part of composite key. " + "A new @EmbeddedId class will be created with this field and '" + newIdFieldName + "'.")
    
    or
    // @Id, @GeneratedValue annotations
    exists(Annotation annotation |
      annotation = existingIdField.getAnAnnotation() and
      (
        isIdAnnotation(annotation) or
        isGeneratedValueAnnotation(annotation)
      ) and
      usageLoc = annotation.getLocation() and
      message = "Annotation '" + annotation.getType().getName() + "' will be removed as field becomes part of @EmbeddedId."
    )
    
    or
    // getters y setters
    exists(Method method |
      (isGetter(method, existingIdField) or isSetter(method, existingIdField)) and
      usageLoc = method.getLocation() and
      message = "Method '" + method.getName() + "' will need to be updated to use the composite key class instead of " +"accessing '" + existingIdField.getName() + "' directly."
    )
    
    or
    // direct access to the field
    exists(FieldAccess access |
      access.getField() = existingIdField and
      usageLoc = access.getLocation() and
      message = "Direct access to field '" + existingIdField.getName() + "' will need to be updated to use the composite key class."
    )
    
    or
    // Declared JPA named queries.
    exists(Annotation nq |
      isNamedQuery(nq) and
      usesField(nq.getValue("query"), existingIdField) and
      usageLoc = nq.getLocation() and
      message = "Named query uses field '" + existingIdField.getName() +
        "' which will become part of a composite key. JPQL needs to be updated."
    )

    or
    // Spring Data query annotations.
    exists(Annotation q |
      isQuery(q) and
      usesField(q.getValue("value"), existingIdField) and
      usageLoc = q.getLocation() and
      message = "Query uses field '" + existingIdField.getName() +
        "' which will become part of a composite key. JPQL needs to be updated."
    )
    
    or
    // createQuery/createNamedQuery
    exists(MethodCall call |
      (
        (isCreateQuery(call) and
         exists(StringLiteral queryLiteral |
           queryLiteral = call.getArgument(0) and
           usesField(queryLiteral, existingIdField)
         ))
        or
        (isCreateNamedQuery(call) and
         exists(StringLiteral nameArg, Annotation nq2 |
           nameArg = call.getArgument(0) and
           isNamedQuery(nq2) and
           "\"" + nameArg.getValue() + "\"" = nq2.getValue("name").toString() and
           usesField(nq2.getValue("query"), existingIdField)
         ))
      ) and
      usageLoc = call.getLocation() and
      message = "Query references field '" + existingIdField.getName() + "' which will become part of a composite key. JPQL needs to be updated."
    )
    
    or
    // foreign key references
    exists(Field foreignField, Class foreignEntity |
      isEntity(foreignEntity) and
      foreignField = foreignEntity.getAField() and
      (
        // joinColumn references 
        exists(Annotation joinColumn |
          joinColumn = foreignField.getAnAnnotation() and
          isJoinColumnAnnotation(joinColumn) and
          joinColumn.getValue("referencedColumnName").toString().replaceAll("\"", "") = existingIdField.getName()
        )
        or
        // OneToOne/ManyToOne references
        (
          foreignField.getType() = entity and
          (
            exists(Annotation association |
              association = foreignField.getAnAnnotation() and
              isAssociationAnnotation(association)
            )
          )
        )
      ) and
      usageLoc = foreignField.getLocation() and
      message = "Field '" + foreignField.getName() + "' in entity '" + foreignEntity.getName() + 
               "' references '" + existingIdField.getName() + "' which will become part of a composite key. " +
               "Foreign key relationship must be updated to use the composite key."
    )
  )
select usageLoc, message
