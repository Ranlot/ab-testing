testSignificanceRatio <- function(successRate, testRate) {

  closedFunction <- function(numberOfEvents) {
    
  numbOfRepetitions <- 1e7
  
  makeTheTest <- makeGenericTest(successRate, testRate, numberOfEvents, F)
  
  one.Tailed.Result <- mclapply(1:numbOfRepetitions, makeTheTest, mc.cores = detectCores() - 1)
  one.Tailed.Result <- do.call(rbind, one.Tailed.Result) %>% as.data.frame
  
  pValueHistogramPlotter(one.Tailed.Result, successRate, testRate, numberOfEvents)
  
  fractionOfSignificantRealizations <- 100 * sum(one.Tailed.Result$`theoretical p-value` < 0.05) / numbOfRepetitions
  
  cat(sprintf("successRate = %s\ttestRate = %s\tsample size = %d\tproportion of significant realizations = %.4f\n", successRate, testRate, numberOfEvents, fractionOfSignificantRealizations))
  
  c(successRate=successRate, testRate=testRate, numberOfEvents=numberOfEvents, fractionOfSignificantRealizations=fractionOfSignificantRealizations)
  
  }
  
  closedFunction
  
}


testSampleSize <- function(successRate, testRate) {
  testNumberOfEvents <- testSignificanceRatio(successRate, testRate)
  #sampleSizeResult <- lapply(c(100, 500, 1000, 2000, 3000), testNumberOfEvents)
  sampleSizeResult <- lapply(c(100, 500), testNumberOfEvents)
  sampleSizeResult <- do.call(rbind, sampleSizeResult) %>% as.data.frame
  sampleSizeResult
}
