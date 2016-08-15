hypergridGenerator <- function(successRates, sampleSize) {
  
  generateOneParam <- function(successRate) {
    list("successRate" = successRate, "sampleSize" = sampleSize)
  }
  
  lapply(successRates, generateOneParam)
}