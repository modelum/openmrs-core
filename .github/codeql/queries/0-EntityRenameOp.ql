/**
 * Performance test for RENAME ENTITY:
 * declaration + JPA associations + annotated queries
 *
 * @name Renamed Entity - declaration associations and queries
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

    exists(Annotation q |
      isQuery(q) and
      usesOldEntity(q.getValue("value"), oldEntity) and
      usageLoc = q.getTarget().getLocation() and
      message =
        "Query uses old entity name '" + oldEntity.getName() +
        "' which will be renamed to '" + newName + "'."
    )

    or

    exists(Annotation nq, Annotation q |
      isNamedQuery(nq) and
      isQuery(q) and
      isEqual(nq.getValue("name"), q.getValue("name")) and
      usesOldEntity(nq.getValue("query"), oldEntity) and
      usageLoc = q.getTarget().getLocation() and
      message =
        "Named query uses old entity name '" + oldEntity.getName() +
        "' which will be renamed to '" + newName + "'."
    )
  )

select usageLoc, message
