testSignificanceRatio <- function(successRate, testRate) {

  closedFunction <- function(numberOfEvents) {
    
  numbOfRepetitions <- 1e5
  
  makeTheTest <- makeGenericTest(successRate, testRate, numberOfEvents, F)
  
  one.Tailed.Result <- mclapply(1:numbOfRepetitions, makeTheTest, mc.cores = detectCores() - 1)
  one.Tailed.Result <- do.call(rbind, one.Tailed.Result) %>% as.data.frame
  
  pValueHistogramPlotter(one.Tailed.Result, successRate, testRate, numberOfEvents)
  
  fractionOfSignificantRealizations <- sum(one.Tailed.Result$`theoretical p-value` < 0.05) / numbOfRepetitions
  
  cat(sprintf("successRate = %s\ttestRate = %s\tsample size = %d\tproportion of significant realizations = %.4f\n", successRate, testRate, numberOfEvents, fractionOfSignificantRealizations))
  
  c(successRate=successRate, testRate=testRate, numberOfEvents=numberOfEvents, fractionOfSignificantRealizations=fractionOfSignificantRealizations)
  
  }
  
  closedFunction
  
}


testSampleSize <- function(successRate, testRate) {
  testNumberOfEvents <- testSignificanceRatio(successRate, testRate)
  sampleSizeResult <- lapply(seq(100, 1500, by = 100), testNumberOfEvents)
  sampleSizeResult <- do.call(rbind, sampleSizeResult) %>% as.data.frame
  sampleSizeResult
}