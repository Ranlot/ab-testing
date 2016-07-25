generateOneHistory <- function(conversionRate, numberOfEvents) {
  runif(numberOfEvents) <= conversionRate
}

generateBootstraps <- function(repetitionNumber, empiricalHistory, numberOfEvents) {
  sample(empiricalHistory, numberOfEvents, replace = T) %>% sum / numberOfEvents
}