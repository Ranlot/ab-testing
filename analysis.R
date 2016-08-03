library(magrittr)
library(parallel)
library(pracma)
library(latex2exp)
library(magicaxis)
source("R/Utils/smartEquals.R")
source("R/significance.Wiki.R")
source("R/empirical.pValue.Tester.R")
source("R/Utils/plotter.Utils.R")
source("R/Utils/dataSaver.Utils.R")
source("R/significanceRatio.R")
source("R/pPDF.R")
#------------------------------------------------------------------

#how many events to we need in order to be able to say that at least 95% of the p-values are smaller than 0.05
# -> it means that given such a sample size and the difference you're testing for, there is only a 5% chance that the p-value you find would 
# be higher than 0.05

#TODO: make a bash script for cleaning out figs/ and output/
#TODO: make a progress bar with pbapply package
#https://gist.github.com/BERENZ/9236df77bfef83664305

g(successRate, testRate, numberOfEvents) %=% g(0.12, 0.1, 5000)  #define the parameters we wish to investigate
g(numberOfRepetitionsForPvals, numberOfRepetitionsForBootstrap, isPvalueComparison) %=% g(1e5, 4, F)  #configuration for number of elements in the averaging

makeTheTest <- makeGenericTest(successRate, testRate, numberOfEvents, isPvalueComparison)  #get the significance testing function

#saveData <- genericSave(successRate, testRate, numberOfEvents, isPvalueComparison)
#saveData(one.Tailed.Result)

if (isPvalueComparison) {
  one.Tailed.Result <- replicate(numberOfRepetitionsForBootstrap, makeTheTest()) %>% t %>% as.data.frame
  #TODO: fix the xlim and ylim of the plot
  pValueComparator(theoreticalValues = one.Tailed.Result$`theoretical p-value`, empiricalValues = one.Tailed.Result$`empirical p-value`, numberOfRepetitionsForBootstrap)
} else {
  
  successRates <- c(0.105, 0.11, 0.115, 0.12, 0.13, 0.14)
  
  result <- lapply(successRates, testSampleSize, testRate=0.1)
  names(result) <- successRates
  
}


convergencePlot(successRates, testRate, result)


