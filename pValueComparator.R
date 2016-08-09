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

g(successRate, testRate, numberOfEvents, averageSize) %=% g(0.102, 0.1, 2500, 200)  #define the parameters we wish to investigate

makeTheTest <- makeGenericTest(successRate, testRate, numberOfEvents)  #get the significance testing function
pValueComparatorPlotter <- genericPvalueComparator(successRate, testRate, numberOfEvents)

result <- mclapply(1:averageSize, makeTheTest, mc.cores = detectCores() - 1)
result <- do.call(rbind, result) %>% as.data.frame

pValueComparatorPlotter(result, averageSize)
