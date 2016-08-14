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