/**
 * This is an automatically generated file
 *
 * @name Feature Moved
 * @kind alert
 * @problem.severity warning
 * @id java/orion/feature-moved/0
 */
 
import java
import orion_callgraph
import orion_dataflow
import utils

/** Check if logical field Visit.indication occurs in a framework query. */
predicate usesField(Expr queryValue) {
  exists(string queryText |
    compileTimeStringValue(queryValue, queryText) and
    (
  queryText.regexpMatch(
    "(?i).*\\bVisit\\s*\\.\\s*indication\\b.*"
  )
  or
  exists(string declaredAlias, string usedAlias |
    declaredAlias = queryText.regexpCapture(
      "(?i).*(FROM|JOIN)\\s+Visit\\s+([a-zA-Z0-9_]+).*", 2
    ) and
    usedAlias = queryText.regexpCapture(
      "(?i).*\\b([a-zA-Z0-9_]+)\\s*\\.\\s*indication\\b.*", 1
    ) and
    declaredAlias = usedAlias
  )
  or
  queryText.regexpMatch("(?i).*FROM\\s+Visit\\b.*") and
  queryText.regexpMatch("(?i).*\\bWHERE\\b.*\\bindication\\b.*")
    )
  )
}
/** A Spring validation API argument that unambiguously names indication. */
predicate isSpringPropertyReference(
  MethodCall call, StringLiteral propertyName, Class entity
) {
  entity.hasName("Visit") and
  isEntity(entity) and
  propertyName.getValue() = "indication" and
  isSpringValidationPropertyCall(call, propertyName) and
  springValidationCallTargetsEntity(call, propertyName.getValue(), entity)
}

/** A selected Spring Data repository query derived from indication. */
predicate isSpringDataDerivedQuery(Method method, Class entity) {
  isSpringRepositoryMethodForEntity(method, entity) and
  method.getName().regexpMatch(
    "^(find|read|get|query|search|stream|count|exists|delete|remove).*(By|And|Or)Indication([A-Z0-9].*)?$"
  )
}

from Class sourceEntity, Field featureField, Location usageLoc, string message,
     string targetEntityName, string targetFeatureName
where
  isEntity(sourceEntity) and
  sourceEntity.hasName("Visit") and
  featureField = sourceEntity.getAField() and
  featureField.hasName("indication") and
  targetEntityName = "Encounter" and
  targetFeatureName = "indication" and
  (
    usageLoc = featureField.getLocation() and
    message = "Feature '" + featureField.getName() + "' will move from entity '" +
      sourceEntity.getName() + "' to '" + targetEntityName + "." +
      targetFeatureName + "'."

    or
    exists(Method accessor |
      (isGetter(accessor, featureField) or isSetter(accessor, featureField)) and
      usageLoc = accessor.getLocation() and
      message = "Accessor '" + accessor.getName() + "' must navigate moved feature '" +
        featureField.getName() + "' through entity '" + targetEntityName + "'."
    )

    or
    exists(MethodCall accessorCall |
      callsAccessor(accessorCall, featureField) and
      usageLoc = accessorCall.getLocation() and
      message = "Call to accessor '" + accessorCall.getMethod().getName() +
        "' must be updated for moved feature '" + featureField.getName() + "'."
    )

    or
    exists(
      Method impactedMethod, MethodCall evidence, string depth, string reason
    |
      fieldCallGraphImpact(
        featureField, impactedMethod, evidence, depth, reason
      ) and
      usageLoc = impactedMethod.getLocation() and
      message = "[CallGraph depth " + depth + "] Method '" +
        impactedMethod.getName() + "' depends on moved feature '" +
        featureField.getName() + "': it " + reason +
        " and must be redirected to its new owner."
    )

    or
    exists(FieldAccess access |
      access.getField() = featureField and
      not isAccessInsideAccessor(access, featureField) and
      usageLoc = access.getLocation() and
      message = "Direct access to moved feature '" + featureField.getName() +
        "' must use entity '" + targetEntityName + "'."
    )

    or
    exists(Annotation metadata |
      frameworkMetadataReferencesField(metadata, featureField) and
      usageLoc = metadata.getLocation() and
      message = "Persistence metadata for moved feature '" +
        featureField.getName() + "' must be updated."
    )

    or
    exists(MethodCall call, StringLiteral propertyName |
      (
        isFrameworkFieldNameCall(call, propertyName, featureField) or
        isSpringPropertyReference(call, propertyName, sourceEntity)
      ) and
      usageLoc = propertyName.getLocation() and
      message = "Property reference to moved feature '" + featureField.getName() +
        "' must use its new owner."
    )

    or
    exists(Method repositoryMethod |
      isSpringDataDerivedQuery(repositoryMethod, sourceEntity) and
      usageLoc = repositoryMethod.getLocation() and
      message = "Spring Data method '" + repositoryMethod.getName() +
        "' is derived from moved feature '" + featureField.getName() + "'."
    )

    or
    exists(Annotation namedQuery |
      isNamedQuery(namedQuery) and
      usesField(namedQuery.getValue("query")) and
      usageLoc = namedQuery.getLocation() and
      message = "Named query references moved feature '" +
        featureField.getName() + "' through its old owner."
    )

    or
    exists(Annotation query |
      isQuery(query) and usesField(query.getValue("value"))
       and
      usageLoc = query.getLocation() and
      message = "Query references moved feature '" + featureField.getName() +
        "' through its old owner."
    )

    or
    exists(Expr source, MethodCall consumer |
      fieldValueFlowsToDependentCall(featureField, source, consumer) and
      usageLoc = consumer.getLocation() and
      message = "[Potential] Value from moved feature '" +
        featureField.getName() + "' flows locally to call '" +
        consumer.getMethod().getName() + "'."
    )
  )
select usageLoc, message
