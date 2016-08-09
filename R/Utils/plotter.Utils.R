
genericPvalueComparator <- function(successRate, testRate, numberOfEvents) {
  pValueComparator <- function(resultDataSet, numberOfRepetitions) {
    
    png(sprintf("figs/pValue.Comparison_%s_%s_%d.png", successRate, testRate, numberOfEvents))
    
    stopifnot(numberOfRepetitions %% 2 == 0)
    
    cloudSd <- 0.015
    cloudPoints <- rnorm(2 * numberOfRepetitions, 0, cloudSd)
    g(cloudX, cloudY) %=% g(cloudPoints %>% head(numberOfRepetitions / 2), cloudPoints %>% tail(numberOfRepetitions / 2))
    
    plot(resultDataSet$`theoretical p-value` + cloudX, resultDataSet$`empirical p-value` + cloudY,
         xlab = "Theoretical p-value", xlim = c(0, 1),
         ylab = "Empirical p-value", ylim=c(0, 1),
         main = sprintf("p = %s ; p0 = %s ; N = %d", successRate, testRate, numberOfEvents),
         cex=1.2, pch=5)
    abline(0, 1, col="red", lwd=2)
    grid()
    
    dev.off()
  }
  pValueComparator
}



pValueHistogramPlotter <- function(dataSet, successRate, testRate, numberOfEvents) {
  
  png(sprintf("figs/pValHisto_%s_%s_%d.png", successRate, testRate, numberOfEvents))
  
  smallest.pValue <- sort(dataSet$`theoretical p-value`[dataSet$`theoretical p-value` > 0])[1]
  #largest.pValue <- 1
  largest.pValue <- max(dataSet$`theoretical p-value`)
  
  histBreaks <- logspace(log10(smallest.pValue), log10(largest.pValue), n=18)
  histo <- hist(dataSet$`theoretical p-value`, breaks=histBreaks, plot = F)
  
  plotThreshold <- which(histo$counts >  1e3)
  
  plot(histo$mids[plotThreshold], histo$density[plotThreshold], log="xy", xaxt="n", yaxt="n", xlab="p-value", ylab="prob(p-value)", pch=23, cex=2.7, bg="blue",
       main=TeX(sprintf("$N = $%d\t$\\tilde{p} = %s$\t$p = %s$", numberOfEvents, successRate, testRate)))
  magaxis(minorn=0, grid=T, frame.plot = F)
  
  muZ <- (successRate - testRate) * sqrt(numberOfEvents / (testRate * (1- testRate)))
  sigZ <- sqrt( (successRate * (1 - successRate)) / (testRate * (1 - testRate)) )
  
  plotRange <- logspace(log10(smallest.pValue), log10(1), n=50)
  lines(plotRange, exactPDF(muZ, sigZ, plotRange), lwd=2, col="red")
  #lines(plotRange, smallPlimitPDF(muZ, sigZ, plotRange), lwd=2, col="red")
  
  dev.off()
}


convergencePlot <- function(successRates, testRate, relevantData) {
  
  png(sprintf("convergencePlot_%s.png", testRate))
  
  numbOfSampleSizes <- length(successRates)
  
  g(xLims, yLims) %=% g(c(-10, 3010), c(-5, 105))
  
  plot(1, type="n", xlab="Sample size", ylab="", xlim=xLims, ylim=yLims, main=sprintf("Probability of significant p-value\ntest rate p = %s", testRate))
  par(new=T)
  plotSampleSize <- function(index, dataSet) {
    relevantData <- dataSet[[index]]
    plot(relevantData$numberOfEvents, relevantData$fractionOfSignificantRealizations, col=index, 
         xaxt="n", yaxt="n", xlab="", ylab="", xlim=xLims, ylim=yLims, type="o", lwd=2)
    par(new=T)
  }
  
  sideEffect <- sapply(1:numbOfSampleSizes, plotSampleSize, dataSet=result)
  grid()
  legend("bottomright", successRates %>% as.character, col=1:numbOfSampleSizes, lwd=2, seg.len = 1, ncol=3)
  dev.off()
}
