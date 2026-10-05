/**
 * Minimal performance test for RENAME ENTITY
 *
 * @name Renamed Entity - minimal test
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
  usageLoc = oldEntity.getLocation() and
  message =
    "Entity '" + oldEntity.getName() +
    "' will be renamed to '" + newName + "'."
select usageLoc, message
