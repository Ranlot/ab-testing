
pValueComparator <- function(theoreticalValues, empiricalValues, numberOfRepetitions) {
  
  png("figs/pValue.Comparison.png")
  
  stopifnot(numberOfRepetitions %% 2 == 0)
  
  cloudSd <- 0.015
  cloudPoints <- rnorm(2 * numberOfRepetitions, 0, cloudSd)
  g(cloudX, cloudY) %=% g(cloudPoints %>% head(numberOfRepetitions / 2), cloudPoints %>% tail(numberOfRepetitions / 2))
  
  plot(one.Tailed.Result$`theoretical p-value` + cloudX, one.Tailed.Result$`empirical p-value` + cloudY,
       xlab = "Theoretical p-value",
       ylab = "Empirical p-value",
       main = "Comparison empirical vs. theoretical p-values",
       cex=1.2, pch=5)
  abline(0, 1, col="red", lwd=2)
  grid()
    
  dev.off()
}

pValueHistogramPlotter <- function(dataSet, successRate, testRate, numberOfEvents) {
  
  png(sprintf("figs/pValHisto_%s_%s_%d.png", successRate, testRate, numberOfEvents))
  
  smallest.pValue <- sort(dataSet$`theoretical p-value`[dataSet$`theoretical p-value` > 0])[1]
  largest.pValue <- 1
  histBreaks <- logspace(log10(smallest.pValue), log10(largest.pValue), n=8)
  histo <- hist(dataSet$`theoretical p-value`, breaks=histBreaks, plot = F)
  plot(histo$mids, histo$density, log="xy", xaxt="n", yaxt="n", xlab="p-value", ylab="prob(p-value)", pch=23, cex=2, bg="blue",
       main=TeX(sprintf("$N = $%d\t$\\tilde{p} = %s$\t$p = %s$", numberOfEvents, successRate, testRate)))
  abline(v=0.05, col="red", lwd=2)
  magaxis(minorn=0, grid=T, frame.plot = F)
  
  dev.off()
}