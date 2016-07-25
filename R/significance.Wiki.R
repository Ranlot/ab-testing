one.prop.z.test <- function(sampleProportion, targetProportion, numberOfEvents) {
  (sampleProportion - targetProportion) / sqrt(targetProportion * (1 - targetProportion)) * sqrt(numberOfEvents)
}