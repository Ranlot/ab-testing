library(magrittr)
library(pracma)
library(parallel)
library(plotrix)
source("R/Utils/smartEquals.R")
source("R/Utils/zipper.R")
source("R/significance.Wiki.R")
source("R/theoreticalPDF.R")
source("R/Utils/plotter.Utils.R")
library(magicaxis)

makeOnePval <- function(successRate, testRate, N) {
  observedRate <- sum(runif(N) <= successRate) / N
  1 - one.prop.z.test(observedRate, testRate, N) %>% pnorm
}

g(testRate, numbOfReps) %=% g(0.1, 1e4)

successRates <- c(0.096, 0.098, 0.1, 0.102, 0.105, 0.11, 0.12)
sampleSizes <- sapply(logspace(log10(100), log10(10000), n=20), ceil)

testSucessAndSize <- function(params, testRate, numbOfReps) {
  
  successRate <- params$successRate
  N <- params$N
  

  
  numericalResult <- sum(replicate(numbOfReps, makeOnePval(successRate, testRate, N) <= 0.05)) / numbOfReps
  cat(sprintf("successRate = %s ; N = %f ; numericalResult %.4f\n", successRate, N, numericalResult))
  c("successRate" = successRate, "N" = N, "numericalResult" = 100 * numericalResult)
}


generateOneParam <- function(successRate, N) {
  list("successRate" = successRate, "N" = N)
}

generateAllSuccesses <- function(successRates, N) {
  lapply(successRates, generateOneParam, N=N)
}


listOfParams <- do.call(c, lapply(sampleSizes, generateAllSuccesses, successRates=successRates))

result <- mclapply(listOfParams, testSucessAndSize, testRate=testRate, numbOfReps=numbOfReps, mc.cores = detectCores() - 1,  mc.preschedule=F)
result <- do.call(rbind, result) %>% as.data.frame

convergencePlotter(testRate, successRates, individualConvergencePlot)
