## for testing that this all works in a fresh R
## library without any other packages installed
if(FALSE) {
  # Create a new, empty directory for our test library
  test_lib <- file.path(tempdir(), "test_lib")
  dir.create(test_lib, showWarnings = FALSE)

  # Set the new directory as our library path
  .libPaths(test_lib)
}

## Install CRAN packages

options(repos=c(CRAN="https://ftp.belnet.be/mirror/CRAN"))
install.packages("remotes", dependencies=TRUE)
install.packages("tidyverse", dependencies=TRUE)
install.packages("devtools", dependencies=TRUE)
install.packages("RcppArmadillo", dependencies=TRUE)
install.packages("Rcpp", dependencies=TRUE)
install.packages("patchwork", dependencies=TRUE)
install.packages("spBayesSurv", dependencies=TRUE)
install.packages("mgcv", dependencies=TRUE)
install.packages("rpart", dependencies=TRUE)
install.packages("rpart.plot", dependencies=TRUE)
install.packages("tidybayes", dependencies=TRUE)
install.packages("ggdist", dependencies=TRUE)
install.packages("latex2exp", dependencies=TRUE)
install.packages("caret", dependencies=TRUE)
install.packages("bcf", dependencies=TRUE)
install.packages("nftbart", dependencies=TRUE)
install.packages("LearnBayes", dependencies=TRUE)

## Install GitHub packages

library("remotes")
install_github("remcc/mBART_shlib/mBART")
install_github("rsparapa/bnptools/BART3")
install_github("theodds/Batman")
install_github("theodds/BART4RS")
install_github("spencerwoody/possum")

