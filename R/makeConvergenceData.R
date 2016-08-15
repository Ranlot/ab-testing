makeConvergenceData <- function(params, testRate, numbOfReps) {
  
  successRate <- params$successRate
  sampleSize <- params$sampleSize
  
  makeOneTheorericalPval <- function() {
    observedRate <- sum(runif(sampleSize) <= successRate) / sampleSize
    1 - one.prop.z.test(observedRate, testRate, sampleSize) %>% pnorm
  }
  
  numericalResult <- sum(replicate(numbOfReps, makeOneTheorericalPval() <= 0.05)) / numbOfReps
  cat(sprintf("successRate = %s ; sampleSize = %f ; numericalResult %.4f\n", successRate, sampleSize, numericalResult))
  c("successRate" = successRate, "sampleSize" = sampleSize, "numericalResult" = 100 * numericalResult)
}