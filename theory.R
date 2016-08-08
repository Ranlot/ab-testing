library(magrittr)
library(pracma)
library(parallel)
library(plotrix)
source("R/Utils/smartEquals.R")
source("R/significance.Wiki.R")

theoreticalPDF <- function(successRate, testRate, N) {
  
  #properties of the z-score
  muZ <- (successRate - testRate) * sqrt(N / (testRate*(1-testRate)))
  sigZ <- sqrt((successRate*(1-successRate)) / (testRate*(1-testRate)))
  
  #PDF of p-values
  preFactor <- exp(-muZ**2 / (2 * sigZ**2)) / sigZ
  
  function(p) preFactor * exp((1 - 1 / sigZ**2) * erfinv(1 - 2*p)**2) * exp(-sqrt(2) * muZ / sigZ**2 * erfinv(1- 2*p))
}


calcuteTheoreticalFraction <- function(successRate, testRate, N) {
  theoreticalResult <- tryCatch(100 * integrate(theoreticalPDF(successRate, testRate, N), 0.95, 1)$value, error = function(err) { 
    message(err)
    theoreticalResult <- 100.0
  })
}

makeOnePval <- function(successRate, testRate, N) {
  observedRate <- sum(runif(N) <= successRate) / N
  1 - one.prop.z.test(observedRate, testRate, N) %>% pnorm
}

g(testRate, numbOfReps) %=% g(0.1, 1e6)

successRates <- c(0.096, 0.098, 0.1, 0.102, 0.105, 0.11, 0.12)
#sampleSizes <- c(100, 500, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000)
sampleSizes <- sapply(logspace(log10(100), log10(10000), n=20), ceil)

testSucessAndSize <- function(params, testRate, numbOfReps) {
  
  successRate <- params$successRate
  N <- params$N
  

  
  numericalResult <- sum(replicate(numbOfReps, makeOnePval(successRate, testRate, N) < 0.05)) / numbOfReps
  cat(sprintf("successRate = %s ; N = %f ; numericalResult %.4f\n", successRate, N, numericalResult))
  c("successRate" = successRate, "N" = N, "numericalResult" = 100 * numericalResult)
}


generateOneParam <- function(successRate, N) {
  list("successRate" = successRate, "N" = N)
}

generateAllSuccesses <- function(successRates, N) {
  lapply(successRates, generateOneParam, N=N)
}


zipper <- function(xsDescribe, xs, ysDescribe, ys) {
  stopifnot(length(xs) == length(ys))
  zippedArgs <- mapply(c, xs, ys)
  row.names(zippedArgs) <- c(xsDescribe, ysDescribe)
  do.call(c, apply(zippedArgs, 2, list))
}

convergenceSuccessRate <- function(x, testRate, dataSet) {
  
  successRate <- x["successRates"] %>% as.double
  col <- x["plotColors"]
  
  relevantData <- dataSet[dataSet$successRate == successRate, ]
  
  #xN <- seq(100, 5000, length.out = 1000)
  xN <- logspace(log10(100), log10(10000), n=100)
  theoreticalValues <- sapply(xN, calcuteTheoreticalFraction, successRate=successRate, testRate=testRate)
  
  plot(relevantData$N, relevantData$numericalResult, col=col, xaxt="n", yaxt="n", xlab="", ylab="", xlim=xLims, ylim=yLims, cex=2, pch=5, log="xy")
  par(new=T)
  plot(xN, theoreticalValues, xaxt="n", yaxt="n", col=col, xlab="", ylab="", xlim=xLims, ylim=yLims, lwd=3, type="l", log="xy")
  par(new=T)
  
}


listOfParams <- do.call(c, lapply(sampleSizes, generateAllSuccesses, successRates=successRates))

result <- mclapply(listOfParams, testSucessAndSize, testRate=testRate, numbOfReps=numbOfReps, mc.cores = detectCores() - 1,  mc.preschedule=F)
#result <- lapply(listOfParams, testSucessAndSize, testRate=testRate, numbOfReps=numbOfReps)

result <- do.call(rbind, result) %>% as.data.frame

#--------------------------------------------------
png(sprintf("convergencePlot_%s.png", testRate))
#g(xLims, yLims) %=% g(c(-10, 5010), c(-5, 105))
g(xLims, yLims) %=% g(c(100, 10000), c(0.5, 100))
plot(1, type="n", xlab="Sample size", ylab="", xlim=xLims, ylim=yLims, main=sprintf("Probability of significant p-value\ntest rate p = %s", testRate), log="xy", xaxt="n", yaxt="n")
par(new=T)


plotColors <- rainbow(length(successRates))

whatToPlot <- zipper("successRates", successRates, "plotColors", plotColors)

sideEffect <- sapply(whatToPlot, convergenceSuccessRate, dataSet=result, testRate=testRate)

magaxis(grid=T, frame.plot = F)
legChars <- sapply(successRates, function(x) paste0(round(100 * (x - testRate) / testRate, 3), "%"))
legend(x=95, y=1.9, legChars, col=plotColors, lwd=2, seg.len = 1, ncol=2)
dev.off()

#--------------------------------------------------



 