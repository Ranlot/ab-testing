library(magrittr)
library(parallel)
source("R/smartEquals.R")
source("R/significance.Wiki.R")
source("R/empirical.History.Generators.R")
source("R/empirical.pValue.Tester.R")
#------------------------------------------------------------------

g(successRate, testRate, numberOfEvents, numberOfBootstraps) %=% g(0.11, 0.1, 1000, 1000000)  #define the parameters we wish to investigate
makeTheTest <- makeGenericTest(successRate, testRate, numberOfEvents, generateBootstraps, numberOfBootstraps)  #get the significance testing function

sapply(1:5, makeTheTest)
