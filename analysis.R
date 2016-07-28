library(magrittr)
library(parallel)
library(pracma)
library(latex2exp)
source("R/Utils/smartEquals.R")
source("R/significance.Wiki.R")
source("R/empirical.pValue.Tester.R")
source("R/Utils/plotter.Utils.R")
source("R/Utils/dataSaver.Utils.R")
#------------------------------------------------------------------

#how many events to we need in order to be able to say that at least 95% of the p-values are smaller than 0.05
# -> it means that given such a sample size and the difference you're testing for, there is only a 5% chance that the p-value you find would 
# be higher than 0.05

#TODO: make a bash script for cleaning out figs/ and output/
#TODO: make a progress bar with pbapply package
#https://gist.github.com/BERENZ/9236df77bfef83664305

g(successRate, testRate, numberOfEvents) %=% g(0.14, 0.1, 400)  #define the parameters we wish to investigate
g(numberOfRepetitionsForPvals, numberOfRepetitionsForBootstrap, isPvalueComparison) %=% g(1e5, 4, F)  #configuration for number of elements in the averaging

makeTheTest <- makeGenericTest(successRate, testRate, numberOfEvents, isPvalueComparison)  #get the significance testing function
saveData <- genericSave(successRate, testRate, numberOfEvents, isPvalueComparison)

if (isPvalueComparison) {
  one.Tailed.Result <- replicate(numberOfRepetitionsForBootstrap, makeTheTest()) %>% t %>% as.data.frame
  #TODO: fix the xlim and ylim of the plot
  pValueComparator(theoreticalValues = one.Tailed.Result$`theoretical p-value`, empiricalValues = one.Tailed.Result$`empirical p-value`, numberOfRepetitionsForBootstrap)
} else {
  one.Tailed.Result <- mclapply(1:numberOfRepetitionsForPvals, makeTheTest, mc.cores = detectCores() - 1)
  one.Tailed.Result <- do.call(rbind, one.Tailed.Result) %>% as.data.frame
}

saveData(one.Tailed.Result)

pValueHistogramPlotter(one.Tailed.Result, successRate, testRate, numberOfEvents)

sum(one.Tailed.Result$`theoretical p-value` < 0.05) / numberOfRepetitionsForPvals
