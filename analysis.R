library(magrittr)
library(parallel)
library(pracma)
library(latex2exp)
source("R/Utils/smartEquals.R")
source("R/significance.Wiki.R")
source("R/empirical.pValue.Tester.R")
source("R/Utils/plotter.Utils.R")
source("R/Utils/dataSaver.Utils.R")
source("R/significanceRatio.R")
#------------------------------------------------------------------

#how many events to we need in order to be able to say that at least 95% of the p-values are smaller than 0.05
# -> it means that given such a sample size and the difference you're testing for, there is only a 5% chance that the p-value you find would 
# be higher than 0.05

#TODO: make a bash script for cleaning out figs/ and output/
#TODO: make a progress bar with pbapply package
#https://gist.github.com/BERENZ/9236df77bfef83664305

g(successRate, testRate, numberOfEvents) %=% g(0.15, 0.1, 400)  #define the parameters we wish to investigate
g(numberOfRepetitionsForPvals, numberOfRepetitionsForBootstrap, isPvalueComparison) %=% g(1e5, 4, F)  #configuration for number of elements in the averaging

makeTheTest <- makeGenericTest(successRate, testRate, numberOfEvents, isPvalueComparison)  #get the significance testing function

#saveData <- genericSave(successRate, testRate, numberOfEvents, isPvalueComparison)
#saveData(one.Tailed.Result)

if (isPvalueComparison) {
  one.Tailed.Result <- replicate(numberOfRepetitionsForBootstrap, makeTheTest()) %>% t %>% as.data.frame
  #TODO: fix the xlim and ylim of the plot
  pValueComparator(theoreticalValues = one.Tailed.Result$`theoretical p-value`, empiricalValues = one.Tailed.Result$`empirical p-value`, numberOfRepetitionsForBootstrap)
} else {
  
  sampleSizes <- c(0.11, 0.12, 0.13, 0.14, 0.15)
  
  result <- lapply(sampleSizes, testSampleSize, testRate=0.1)
  names(result) <- sampleSizes
  
}


numbOfSampleSizes <- length(sampleSizes)

g(xLims, yLims) %=% g(c(-10, 1510), c(-0.05, 1.05))

plot(1, type="n", xlab="Sample size", ylab="", xlim=xLims, ylim=yLims)
par(new=T)
plotSampleSize <- function(index, dataSet) {
  relevantData <- dataSet[[index]]
  plot(relevantData$numberOfEvents, relevantData$fractionOfSignificantRealizations, col=index, 
       xaxt="n", yaxt="n", xlab="", ylab="", xlim=xLims, ylim=yLims, type="o", lwd=2)
  par(new=T)
}

sideEffect <- sapply(1:numbOfSampleSizes, plotSampleSize, dataSet=result)
grid()
legend("bottomright", sampleSizes %>% as.character, col=1:numbOfSampleSizes, lwd=2, seg.len = 1)
dev.off()

