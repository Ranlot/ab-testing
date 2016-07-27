library(magrittr)
library(parallel)
source("R/Utils/smartEquals.R")
source("R/significance.Wiki.R")
source("R/empirical.pValue.Tester.R")
source("R/Utils/plotter.Utils.R")
source("R/Utils/dataSaver.Utils.R")
#------------------------------------------------------------------

#TODO: make a bash script for cleaning out figs/ and output/
#TODO: make a progress bar with pbapply package
#https://gist.github.com/BERENZ/9236df77bfef83664305

g(successRate, testRate, numberOfEvents) %=% g(0.11, 0.1, 1000)  #define the parameters we wish to investigate
g(numberOfRepetitionsForPvals, numberOfRepetitionsForBootstrap, isPvalueComparison) %=% g(1e7, 4, F)  #configuration for number of elements in the averaging

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

#library(pracma)
#smallest.pValue <- sort(one.Tailed.Result$`theoretical p-value`[one.Tailed.Result$`theoretical p-value` > 0])[1]
#largest.pValue <- 1
#histBreaks <- logspace(log10(smallest.pValue), log10(largest.pValue), n=15)
#h <- hist(one.Tailed.Result$`theoretical p-value`, breaks=histBreaks, plot = F)
#plot(h$mids, h$density, log="xy")
#grid()
