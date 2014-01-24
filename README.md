Rcpp Bioconductor Check Logs
============================

Constructed on 2014-01-22 16:00:58

Error Summary
-------------

`flowWorkspace` fails due to failed tests unrelated to `Rcpp`.

`Rdisop` fails because it depends on both `RcppClassic` and `Rcpp`.

`mzR` fails because it tries to include `Rcpp/iostream/Rostream.h`, which
no longer exists (consolidated into `Rcpp/iostream/Rstreambuf.h`) (fixed for
purposes of this test, since many packages depend on it)

In summary: `Rcpp` is in good shape for BioConductor.

Needs Namespace Updates
-----------------------

`CDM`: Error in din.jml.devcrit(dat = dat, datresp = dat.resp, latresp, guess,  : 
  function 'dataptr' not provided by package 'Rcpp'

`sirt`: Error in mml_calc_like(dat2 = dat2, dat2resp = dat2.resp, probs = probsM,  : 
  function 'dataptr' not provided by package 'Rcpp'

`TAM`: Error in theta.sq2(theta) : 
  function 'dataptr' not provided by package 'Rcpp'

Needs Investigation
-------------------

`geiger` fails with a segfault; not sure if it's Rcpp's fault or not.