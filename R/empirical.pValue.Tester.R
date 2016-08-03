makeGenericTest <- function(successRate, testRate, numberOfEvents, isPvalueComparison) {
  
  numberOfBootstraps <- 1e5
  
  generateOneHistory <- function() {
    runif(numberOfEvents) <= successRate
  }
  
  generateOneExactHistory <- function() {
    sum(rbinom(numberOfEvents, 1, successRate))
  }
  
  generateSingleBootstrap <- function(dummyRepetitionIndex, empiricalHistory) {
    sample(empiricalHistory, numberOfEvents, replace = T) %>% sum / numberOfEvents
  }
  
  #2) generate the bootstrapped samples for empirical p-value estimation (probability that a bootstrap will yield a lower successRate than the testRate)
  generateManyBootstraps <- function(empiricalData) {
    bootstrapsData <- mclapply(1:numberOfBootstraps, generateSingleBootstrap, empiricalHistory = empiricalData, mc.cores = detectCores() - 1) %>% unlist
    empirical.P.value <- sum(bootstrapsData < testRate) / numberOfBootstraps
    empirical.P.value
  }
  
  closedTest <- function(dummyRepetitionIndex) {
    
    #generate some empirical data with expected successRate and measure the actual successRate.
    empiricalData <- generateOneHistory()
    observedSuccessRate <- empiricalData %>% sum / numberOfEvents
    
    #theoretical p-value based on "One-proportion z-test"
    #https://en.wikipedia.org/wiki/Statistical_hypothesis_testing
    theoretical.Z.score <- one.prop.z.test(sampleProportion = observedSuccessRate, targetProportion = testRate, numberOfEvents = numberOfEvents)
    theoretical.P.value <- 1 - theoretical.Z.score %>% pnorm
    
    if (isPvalueComparison) {
      
      #generate the bootstrapped samples for empirical p-value estimation (probability that a bootstrap will yield a lower successRate than the testRate)
      empirical.P.value <- generateManyBootstraps(empiricalData)
      cat(sprintf("observedRate = %.4f\tempirical p-value %.4f\ttheoretical p-value %.4f\n", observedSuccessRate, empirical.P.value, theoretical.P.value))
      c("observedRate" = observedSuccessRate, "empirical p-value" = empirical.P.value, "theoretical p-value" = theoretical.P.value)
      
    } else {
      
      #cat(sprintf("observedRate = %.4f\ttheoretical p-value %.4f\n", observedSuccessRate, theoretical.P.value))
      c("observedRate" = observedSuccessRate, "theoretical p-value" = theoretical.P.value)
      
    }

  }
  
  closedTest
}
