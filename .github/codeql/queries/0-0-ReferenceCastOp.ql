/**
 * This is an automatically generated file
 *
 * @name Reference Casted
 * @kind alert
 * @problem.severity warning
 * @id java/orion/reference-casted/0/0
 */
 
import java
import orion_dataflow
import utils

/** The single field selected by this generated CAST query. */
private predicate orionCastField(Field field) {
  exists(Class entity |
    isEntity(entity) and
    entity.hasName("Visit") and
    field = entity.getAField() and
    field.hasName("location")
  )
}

/** The replacement type still supports the resolved old-type operation. */
private predicate orionNewTypeSupportsCall(MethodCall consumer) {
  exists(RefType replacementType |
    replacementType.getName() = "String" and
    replacementType.getASupertype*().getSourceDeclaration() =
      consumer.getMethod().getDeclaringType().getSourceDeclaration()
  )
}

/** A method operation that genuinely requires the field's previous type. */
private predicate orionCastOldTypeSink(
  Field field, DataFlow::Node sink, MethodCall consumer
) {
  orionCastField(field) and
  isOldTypeMethodCall(consumer, field) and
  not orionNewTypeSupportsCall(consumer) and
  sink = DataFlow::exprNode(consumer.getQualifier())
}

module OrionCastGlobalConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    exists(Field field, Expr expression |
      orionCastField(field) and
      readsFieldValue(expression, field) and
      source = DataFlow::exprNode(expression)
    )
  }

  predicate isSink(DataFlow::Node sink) {
    exists(Field field, MethodCall consumer |
      orionCastOldTypeSink(field, sink, consumer)
    )
  }

  /** Do not re-enter an independently read affected-field source. */
  predicate isBarrierIn(DataFlow::Node node) { isSource(node) }
}

module OrionCastGlobalFlow = DataFlow::Global<OrionCastGlobalConfig>;

/**
 * Interprocedural flow only: local paths remain the responsibility of the
 * existing lightweight predicates in orion_dataflow.qll.
 */
predicate fieldValueGloballyFlowsToOldTypeConsumer(
  Field field, Expr source, MethodCall consumer
) {
  orionCastField(field) and
  readsFieldValue(source, field) and
  orionCastOldTypeSink(
    field, DataFlow::exprNode(consumer.getQualifier()), consumer
  ) and
  OrionCastGlobalFlow::flow(
    DataFlow::exprNode(source),
    DataFlow::exprNode(consumer.getQualifier())
  ) and
  not DataFlow::localFlow(
    DataFlow::exprNode(source),
    DataFlow::exprNode(consumer.getQualifier())
  )
}

from Class entity, Field referenceField, Location usageLoc, string message,
     string oldType, string newType
where
  isEntity(entity) and
  entity.hasName("Visit") and
  referenceField = entity.getAField() and
  referenceField.hasName("location") and
  oldType = referenceField.getType().getName() and
  newType = "String" and
  (
    usageLoc = referenceField.getLocation() and
    message = "Reference '" + referenceField.getName() + "' in entity '" +
      entity.getName() + "' will change type from '" + oldType + "' to '" +
      newType + "'."

    or
    exists(Method accessor |
      (isGetter(accessor, referenceField) or isSetter(accessor, referenceField)) and
      usageLoc = accessor.getLocation() and
      message = "Accessor '" + accessor.getName() +
        "' exposes the old reference type '" + oldType + "'."
    )

    or
    exists(MethodCall accessorCall |
      callsAccessor(accessorCall, referenceField) and
      usageLoc = accessorCall.getLocation() and
      message = "Call to reference accessor '" +
        accessorCall.getMethod().getName() + "' depends on old type '" +
        oldType + "'."
    )

    or
    exists(MethodCall call, StringLiteral propertyName |
      isFrameworkFieldNameCall(call, propertyName, referenceField) and
      usageLoc = propertyName.getLocation() and
      message = "Persistence API uses reference '" + referenceField.getName() +
        "' whose type will change from '" + oldType + "' to '" + newType + "'."
    )

    or
    exists(Expr expression |
      usesFieldWithTypeDependency(expression, referenceField) and
      usageLoc = expression.getLocation() and
      message = "Code uses reference '" + referenceField.getName() +
        "' as old type '" + oldType + "'."
    )

    or
    exists(LocalVariableDeclExpr variable, Expr source |
      source = variable.getInit() and
      readsFieldValue(source, referenceField) and
      variable.getType().getName() = oldType and
      oldType != newType and
      usageLoc = variable.getLocation() and
      message = "Variable declaration expects old reference type '" + oldType + "'."
    )

    or
    exists(Assignment assignment, Expr source |
      source = assignment.getRhs() and
      readsFieldValue(source, referenceField) and
      assignment.getDest().getType().getName() = oldType and
      oldType != newType and
      usageLoc = assignment.getLocation() and
      message = "Assignment expects old reference type '" + oldType + "'."
    )

    or
    exists(MethodCall call, Expr source, int i |
      source = call.getArgument(i) and
      readsFieldValue(source, referenceField) and
      call.getMethod().getParameterType(i).getName() = oldType and
      oldType != newType and
      usageLoc = call.getLocation() and
      message = "Method call expects old reference type '" + oldType + "'."
    )

    or
    exists(Annotation association |
      association = referenceField.getAnAnnotation() and
      isAssociationAnnotation(association) and
      usageLoc = association.getLocation() and
      message = "Persistence association for reference '" +
        referenceField.getName() + "' must be reviewed for type '" + newType + "'."
    )

    or
    exists(Annotation referenceMapping |
      isReferenceMappingAnnotation(referenceMapping, referenceField) and
      usageLoc = referenceMapping.getLocation() and
      message = "Reference mapping metadata for '" +
        referenceField.getName() + "' may depend on the old identifier type."
    )

    or
    exists(Class targetEntity, Field targetId, Annotation idAnnotation |
      fieldTargetsEntity(referenceField, targetEntity) and
      targetId = targetEntity.getAField() and
      idAnnotation = targetId.getAnAnnotation() and
      isIdAnnotation(idAnnotation) and
      targetId.getType().getName() = oldType and
      oldType != newType and
      usageLoc = targetId.getLocation() and
      message = "Referenced identifier '" + targetId.getName() +
        "' in entity '" + targetEntity.getName() +
        "' still has old type '" + oldType + "'."
    )

    or
    exists(Expr source, MethodCall consumer |
      fieldValueFlowsToOldTypeConsumer(referenceField, source, consumer) and
      usageLoc = consumer.getLocation() and
      message = "[Potential] Reference value from '" +
        referenceField.getName() + "' flows locally to old-type operation '" +
        consumer.getMethod().getName() + "'."
    )

    or
    exists(Expr source, MethodCall consumer |
      fieldValueGloballyFlowsToOldTypeConsumer(
        referenceField, source, consumer
      ) and
      usageLoc = consumer.getLocation() and
      message = "[Global] Reference value from '" +
        referenceField.getName() + "' reaches old-type operation '" +
        consumer.getMethod().getName() +
        "' across method boundaries after conversion to '" + newType + "'."
    )
  )
select usageLoc, message
