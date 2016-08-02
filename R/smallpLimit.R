
smallPlimitPDF <- function(muZ, sigZ, p) {
  2**(pi / (2*sigZ**2) - 2) / sigZ * exp(-0.5* muZ**2 / sigZ**2) * exp(muZ / sigZ**2 * sqrt(0.5*pi*log(1 / (4*p)))) / ( p**(1 - pi / (4*sigZ**2)) * sqrt(log(1/(4*p))))
}

