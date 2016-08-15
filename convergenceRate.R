library(magrittr)
library(pracma)
library(parallel)
library(plotrix)
source("R/Utils/smartEquals.R")
source("R/Utils/zipper.R")
source("R/significance.Wiki.R")
source("R/theoreticalPDF.R")
source("R/Utils/plotter.Utils.R")
source("R/hypergridGenerator.R")
source("R/makeConvergenceData.R")
library(magicaxis)

testRate <- 0.1
successRates <- c(0.096, 0.098, 0.1, 0.102, 0.105, 0.11, 0.12)
g(minSampleSize, maxSampleSize) %=% g(1e2, 1e4)

numbOfReps <- 5e4
sampleSizes <- sapply(logspace(log10(minSampleSize), log10(maxSampleSize), n=20), ceil)
listOfParams <- do.call(c, lapply(sampleSizes, hypergridGenerator, successRates=successRates))

result <- mclapply(listOfParams, makeConvergenceData, testRate=testRate, numbOfReps=numbOfReps, mc.cores = detectCores() - 1,  mc.preschedule=F)
result <- do.call(rbind, result) %>% as.data.frame

convergencePlotter(testRate, successRates, individualConvergencePlot, minSampleSize, maxSampleSize)
