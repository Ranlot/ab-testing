
genericPvalueComparator <- function(successRate, testRate, numberOfEvents) {
  pValueComparator <- function(resultDataSet, numberOfRepetitions) {
    
    png(sprintf("figs/pValue.Comparison_%s_%s_%d.png", successRate, testRate, numberOfEvents))
    
    stopifnot(numberOfRepetitions %% 2 == 0)
    
    cloudSd <- 0.015
    cloudPoints <- rnorm(2 * numberOfRepetitions, 0, cloudSd)
    g(cloudX, cloudY) %=% g(cloudPoints %>% head(numberOfRepetitions / 2), cloudPoints %>% tail(numberOfRepetitions / 2))
    
    plot(resultDataSet$`theoretical p-value` + cloudX, resultDataSet$`empirical p-value` + cloudY,
         xlab = "Theoretical p-value", xlim = c(0, 1),
         ylab = "Bootstrapped p-value", ylim=c(0, 1),
         main = sprintf("p* = %s ; p0 = %s ; N = %d", successRate, testRate, numberOfEvents),
         cex=1.2, pch=5)
    abline(0, 1, col="red", lwd=2)
    grid()
    
    dev.off()
  }
  pValueComparator
}


convergencePlotter <- function(testRate, successRates, individualConvergencePlot) {
  
  png(sprintf("convergencePlot_%s.png", testRate))
  
  g(xLims, yLims) %=% g(c(100, 10000), c(0.5, 100))
  
  individualConvergencePlot <- function(x, testRate, dataSet) {
    
    successRate <- x["successRates"] %>% as.double
    col <- x["plotColors"]
    
    relevantData <- dataSet[dataSet$successRate == successRate, ]
    
    xN <- logspace(log10(100), log10(10000), n=100)
    theoreticalValues <- sapply(xN, calcuteTheoreticalFraction, successRate=successRate, testRate=testRate)
    
    plot(relevantData$N, relevantData$numericalResult, col=col, xaxt="n", yaxt="n", xlab="", ylab="", xlim=xLims, ylim=yLims, cex=2, pch=5, log="xy")
    par(new=T)
    plot(xN, theoreticalValues, xaxt="n", yaxt="n", col=col, xlab="", ylab="", xlim=xLims, ylim=yLims, lwd=3, type="l", log="xy")
    par(new=T)
    
  }
  
  plot(1, type="n", xlab="Sample size", ylab="", xlim=xLims, ylim=yLims, main=sprintf("Probability of significant p-value\ntest rate p = %s", testRate), log="xy", xaxt="n", yaxt="n")
  par(new=T)
  
  plotColors <- rainbow(length(successRates))
  whatToPlot <- zipper("successRates", successRates, "plotColors", plotColors)
  
  sideEffect <- sapply(whatToPlot, individualConvergencePlot, dataSet=result, testRate=testRate)
  
  magaxis(grid=T, frame.plot = F)
  legChars <- sapply(successRates, function(x) paste0(round(100 * (x - testRate) / testRate, 3), "%"))
  legend(x=95, y=1.9, legChars, col=plotColors, lwd=2, seg.len = 1, ncol=2)
  dev.off()
}


# keep as we may want to look at exact PDF in the future
# pValueHistogramPlotter <- function(dataSet, successRate, testRate, numberOfEvents) {
#   
#   png(sprintf("figs/pValHisto_%s_%s_%d.png", successRate, testRate, numberOfEvents))
#   
#   smallest.pValue <- sort(dataSet$`theoretical p-value`[dataSet$`theoretical p-value` > 0])[1]
#   #largest.pValue <- 1
#   largest.pValue <- max(dataSet$`theoretical p-value`)
#   
#   histBreaks <- logspace(log10(smallest.pValue), log10(largest.pValue), n=18)
#   histo <- hist(dataSet$`theoretical p-value`, breaks=histBreaks, plot = F)
#   
#   plotThreshold <- which(histo$counts >  1e3)
#   
#   plot(histo$mids[plotThreshold], histo$density[plotThreshold], log="xy", xaxt="n", yaxt="n", xlab="p-value", ylab="prob(p-value)", pch=23, cex=2.7, bg="blue",
#        main=TeX(sprintf("$N = $%d\t$\\tilde{p} = %s$\t$p = %s$", numberOfEvents, successRate, testRate)))
#   magaxis(minorn=0, grid=T, frame.plot = F)
#   
#   muZ <- (successRate - testRate) * sqrt(numberOfEvents / (testRate * (1- testRate)))
#   sigZ <- sqrt( (successRate * (1 - successRate)) / (testRate * (1 - testRate)) )
#   
#   plotRange <- logspace(log10(smallest.pValue), log10(1), n=50)
#   lines(plotRange, exactPDF(muZ, sigZ, plotRange), lwd=2, col="red")
#   #lines(plotRange, smallPlimitPDF(muZ, sigZ, plotRange), lwd=2, col="red")
#   
#   dev.off()
# }