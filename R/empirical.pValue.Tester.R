makeGenericTest <- function(successRate, testRate, numberOfEvents, generateBootstraps, numberOfBootstraps) {
  
  closedTest <- function(repetitionNumber) {
    
    #1) generate some empirical data with expected successRate and measure the actual successRate.
    empiricalData <- generateOneHistory(successRate, numberOfEvents)
    observedSuccessRate <- empiricalData %>% sum / numberOfEvents
    
    #2) generate the bootstrapped samples for empirical p-value estimation (probability that a bootstrap will yield a lower successRate than the testRate)
    bootstrapsData <- mclapply(1:numberOfBootstraps, generateBootstraps, empiricalHistory = empiricalData, numberOfEvents = numberOfEvents, mc.cores = detectCores() - 1) %>% unlist
    empirical.P.value <- sum(bootstrapsData < testRate) / numberOfBootstraps
    
    #3) theoretical p-value based on "One-proportion z-test"
    #https://en.wikipedia.org/wiki/Statistical_hypothesis_testing
    theoretical.Z.score <- one.prop.z.test(sampleProportion = observedSuccessRate, targetProportion = testRate, numberOfEvents = numberOfEvents)
    theoretical.P.value <- 1 - theoretical.Z.score %>% abs %>% pnorm
    
    cat(sprintf("observedRate = %.4f\tempirical p-value %.4f\ttheoretical p-value %.4f\n", observedSuccessRate, empirical.P.value, theoretical.P.value))
  }
  
  closedTest
}