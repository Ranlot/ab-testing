library(magrittr)
library(parallel)
library(pracma)
library(latex2exp)
library(magicaxis)
library(optparse)
source("R/Utils/smartEquals.R")
source("R/significance.Wiki.R")
source("R/empirical.pValue.Tester.R")
source("R/Utils/plotter.Utils.R")
#------------------------------------------------------------------

option_list <- list(
  make_option("--successRate", type="numeric"),
  make_option("--testRate", type="numeric"),
  make_option("--numberOfEvents", type="numeric")
)

opt <- parse_args(OptionParser(option_list=option_list))

g(successRate, testRate, numberOfEvents) %=% g(opt$successRate, opt$testRate, opt$numberOfEvents)
averageSize <- 200
#g(successRate, testRate, numberOfEvents, averageSize) %=% g(0.102, 0.1, 50, 200)

makeTheTest <- makeGenericTest(successRate, testRate, numberOfEvents)  #get the significance testing function
pValueComparatorPlotter <- genericPvalueComparator(successRate, testRate, numberOfEvents)

result <- mclapply(1:averageSize, makeTheTest, mc.cores = detectCores() - 1)
result <- do.call(rbind, result) %>% as.data.frame

pValueComparatorPlotter(result, averageSize)
