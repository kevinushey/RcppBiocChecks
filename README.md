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
