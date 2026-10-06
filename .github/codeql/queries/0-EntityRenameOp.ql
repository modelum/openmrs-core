/**
 * Performance test for RENAME ENTITY:
 * declaration + JPA associations + @Query value extraction
 *
 * @name Renamed Entity - Query extraction test
 * @kind alert
 * @problem.severity warning
 * @id java/orion/entity-renamed/0
 */

import java
import utils

from Class oldEntity, Location usageLoc, string message, string newName
where
  oldEntity.hasName("Visit") and
  isEntity(oldEntity) and
  newName = "Appointment" and
  (
    (
      usageLoc = oldEntity.getLocation() and
      message =
        "Entity '" + oldEntity.getName() +
        "' will be renamed to '" + newName + "'."
    )

    or

    exists(Field field |
      field.getType().getName() = oldEntity.getName() and
      hasJpaAssociationTo(field) and
      usageLoc = field.getLocation() and
      message =
        "Field '" + field.getName() +
        "' references old entity name '" + oldEntity.getName() +
        "' which will be renamed to '" + newName + "'."
    )

    or

    exists(Annotation q, StringLiteral queryLiteral |
      isQuery(q) and
      queryLiteral = q.getValue("value") and
      usageLoc = q.getTarget().getLocation() and
      message = "Spring Data @Query annotation found."
    )
  )

select usageLoc, message
