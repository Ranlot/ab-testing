genericSave <- function(successRate, testRate, numberOfEvents, isPvalueComparison) {
  
  outputFile <- sprintf("output/oneTailedResult_%f_%f_%d_pValCompar_%s.csv", successRate, testRate, numberOfEvents, isPvalueComparison)
  
  saveData <- function(dataFile) {
    write.csv(dataFile, file = outputFile, quote = F, row.names = F)
  }
  
  saveData
}