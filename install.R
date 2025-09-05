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

install.packages("tidyverse")
install.packages("devtools")
install.packages("RcppArmadillo")
install.packages("Rcpp")
install.packages("patchwork")
install.packages("spBayesSurv")
install.packages("mgcv")
install.packages("rpart")
install.packages("rpart.plot")
install.packages("tidybayes")
install.packages("ggdist")
install.packages("latex2exp")
install.packages("caret")
install.packages("bcf")
install.packages("nftbart")
install.packages("LearnBayes")

## Github remote installs
library("remotes")
install_github("remcc/mBART_shlib/mBART")
install_github("rsparapa/bnptools/BART3")
install_github("theodds/Batman")
install_github("theodds/BART4RS")
##install_github("spencerwoody/possum") ## not needed

