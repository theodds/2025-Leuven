
# BART R Packages

The canonical reference manual for installing R packages can be found on CRAN at
<https://cran.r-project.org/doc/manuals/r-release/R-admin.html#Installing-packages>.
Note that you will need the usual R build tools installed as well, which you may
already have installed.

- For Windows, see this link: <https://cran.r-project.org/bin/windows/Rtools/rtools44/rtools.html>.
- For macOS, you will need Xcode that you can get from the App Store.
  You will also need GNU Fortran, which you can find here: 
  <https://mac.r-project.org/tools/>.

For the packages needed in this course, we provide useful additional tips in
`Slides/computing.pdf` along with other BART computing advice such as
multi-threading.

Below you will find a brief overview of installation instructions. But, if you
encounter any problems, please consult the documentation and notes above. The
file `install.R` walks through installation of the individual packages; if you
run into problems installing after walking through the steps, it may be because
you do not have Rtools or Xcode/gfortran installed.

Many of the R packages needed can be installed from CRAN. There are
exceptions that need to be installed from other places.  Of course,
there are many ways to install an R package.  Here, we provide some
code snippets for installing packages from within an R session with
the assistance of the `remotes` package.  To install the
necessary dependencies from CRAN, you should pick a reliable local
mirror.  Here, I'm using a popular US choice.

```
options(repos=c(CRAN="http://lib.stat.cmu.edu/R/CRAN"))
install.packages("remotes", dependencies=TRUE)
install.packages("Rcpp", dependencies=TRUE)
install.packages("RcppArmadillo", dependencies=TRUE)
```

For Tony's presentations, you will need the following.

- `Batman:` contains miscellaneous BART functions and it is available here: <https://github.com/theodds/Batman>.
- `possum:` performs posterior summarization and it is available here:
<https://github.com/spencerwoody/possum>.
- `BART4RS:` some functions for fitting the Cox proportional hazards
   model and it is available here: <https://github.com/theodds/BART4RS>.
- `bcf:` the Bayesian Causal Forests package, which can be installed from CRAN.

```
library(remotes)
install_url("https://cran.r-project.org/src/contrib/Archive/bcf/bcf_1.3.1.tar.gz")
```

For Rodney's presentations, you will need the following.
- `BART3`, the development version of the BART package available at
<https://github.com/rsparapa/bnptools>.
- `hbart`, the development version of the Heteroskedastic BART
package available in the same place.

For example, you can install BART3 like so.

```
library(remotes)
install_github("rsparapa/bnptools/BART3")
```

# Replication Materials

All replication materials are in the `Examples/` directory. To use this
repository, simply do the following.

1. Clone the repository.
2. Open the .Rproj file using **RStudio**.
3. Open the notebooks in the `Examples/` directory.
4. Knit the files if desired, or run the files interactively in **RStudio**.
