zipper <- function(xsDescribe, xs, ysDescribe, ys) {
  stopifnot(length(xs) == length(ys))
  zippedArgs <- mapply(c, xs, ys)
  row.names(zippedArgs) <- c(xsDescribe, ysDescribe)
  do.call(c, apply(zippedArgs, 2, list))
}