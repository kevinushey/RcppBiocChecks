#!/usr/bin/r

## set to TRUE if you want to force updates
forceUpdate <- FALSE

cat("Started at ", format(Sys.time()), "\n")
#library(parallel)

## use a test-local directory, install Rcpp, RcppArmadillo, ... there
## this will work for sub-shells such as the ones started by system() below
lib <- "/tmp/RcppDepends/lib"
Sys.setenv("R_LIBS_USER"=lib)
Sys.setenv("_R_CHECK_FORCE_SUGGESTS_"=0)

## for the borked src/Makevars of ExactNumCI
Sys.setenv("BOOSTLIB"="/usr/include")
suppressMessages(library(pkgDepTools))

countBioc <- function(vers="release") {
  deps <- makeDepGraph(paste("http://bioconductor.org/packages/", vers, "/bioc/", sep=""), type="source", dosize=FALSE)
  rcpp <- inEdges("Rcpp", deps)
  return(rcpp[[1]])
}

setwd("/tmp/RcppDepends")

AP.BioC <- union( countBioc("2.14"), countBioc("release") )
res <- data.frame(pkg=AP.BioC, res=NA)

#for (pi in 1:nrow(res)) {
#lres <- mclapply(1:nrow(res), mc.cores = 4, FUN=function(pi) {
exit_codes <- lapply(AP.BioC, function(p) {
  
  tarballs <- sort( list.files("tarballs", full.names=TRUE, pattern=p) )
  
  if (forceUpdate) {
    biocLite(p, suppressUpdates=TRUE, lib=lib, destdir=normalizePath("tarballs"))
  }
  
  if (length(tarballs)) {
    tarball <- tarballs[1]
  } else {
    cat("No tarball available for package", p, "\n")
    return( setNames(NA, p) )
  }
  
  pkg <- gsub(".*/", "", tarball)
  pkg <- gsub("\\.tar\\.gz", "", pkg)
  cat("Starting check for package '", p, "'.\n", sep="")
  rc <- system(paste("R CMD check --no-manual --no-vignettes ", tarball, " > ", "logs/", pkg, ".log", sep=""))
  if (rc == 0) {
    cat("Package '", p, "' checked successfully at ", strftime(Sys.time(), "%Y%m%d-%H%M%S"), ".\n\n", sep="")
  } else {
    cat("Package '", p, "' failed R CMD check at ", strftime(Sys.time(), "%Y%m%d-%H%M%S"), ".\n\n", sep="")
  }
  return( setNames(rc, p) )
})

res <- data.frame(
  pkg=lapply(res, names),
  code=unlist(res)
)

logs <- list.files("logs")

res <- do.call(rbind, lres)
print(res)
write.table(res, file=paste("results/result-", strftime(Sys.time(), "%Y%m%d-%H%M%S"), ".txt", sep=""), sep=",")
save(res, file=paste("result-", strftime(Sys.time(), "%Y%m%d-%H%M%S"), ".RData", sep=""))
cat("Ended at ", format(Sys.time()), "\n")

## Collate all the most relevant results into a nice repository
lapply(AP.BioC, function(pkg) {
  dir.create( file.path("results", pkg), showWarnings=FALSE, recursive=TRUE )
  
  ## copy the log file
  pkg_logs <- sort(list.files("logs", pattern=pkg, full.names=TRUE))
  if (length(pkg_logs)) {
    pkg_log <- pkg_logs[1]
    filename <- gsub(".*/(.*)_.*", "\\1", pkg_log)
    file.copy(pkg_log, file.path("results", pkg, paste0(filename, ".log")), overwrite=TRUE)
  }
  
  ## copy relevant output from R CMD check, if available
  Rcheck <- paste0(pkg, ".Rcheck")
  dest <- file.path("results", pkg, Rcheck)
  if (file.exists(Rcheck)) {
    ## copy the check and install logs, if possible
    install.log <- file.path(Rcheck, "00install.out")
    if (file.exists(install.log)) {
      file.copy(install.log, file.path("results", pkg, paste0(pkg, "-install.log")), overwrite=TRUE)
    }
    
    check.log <- file.path(Rcheck, "00check.log")
    if (file.exists(check.log)) {
      file.copy(check.log, file.path("results", pkg, paste0(pkg, "-check.log")), overwrite=TRUE)
    }
  }
  
})

## Construct a README.md file containinga summary for each package
write <- function(...) {
  cat(..., sep="\n", file="README.md", append=TRUE)
}

unlink("README.md")

write(
  "Rcpp Biocondcutor Check Logs",
  "============================",
  "\n",
  paste("Constructed on", Sys.time()),
  "\n"
)

## Move the results to a timestamped folder
time <- strftime( Sys.time(), "%Y%m%d" )
dir.create( paste0("results-", time), showWarnings=FALSE )
file.copy("results/.", paste0("results-", time), recursive=TRUE)
