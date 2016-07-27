
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

