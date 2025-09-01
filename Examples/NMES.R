## Load ----

library(causaldrf)
library(tidyverse)
library(SoftBart)
library(rpart)
library(rpart.plot)
data("nmes_data")

load_nmes <- function() {
  df <- nmes_data %>%
    mutate(trt = ifelse(packyears >= 17, 1, 0)) %>%
    filter(TOTALEXP > 0) %>%
    mutate(logexp = log(TOTALEXP)) %>%
    select(-packyears, -TOTALEXP, -HSQACCWT)
  return(df)
}

## Fit BCF ----

fit_nmes <- function(nmes) {
  trt <- NULL

  formula <- ~ AGESMOKE + LASTAGE + MALE + RACE3 + beltuse + educate +
    marital + SREGION + POVSTALB
  formula_e <- update(formula, trt ~ .)
  formula_y <- update(formula, logexp ~ .)

  nmes2 <- nmes %>% mutate(trt = factor(trt, levels = c(0, 1)))
  e <- softbart_probit(formula_e, data = nmes2, test_data = nmes2)
  e_hat <- e$p_test_mean

  nmes3 <- nmes %>% mutate(trt = trt - e_hat)
  fit <- vc_softbart_regression(formula = formula_y,
                                linear_var_name = "trt",
                                data = nmes3,
                                test_data = nmes3)

  return(list(regression_fit = fit,
              propensity_fit = e,
              ate_samples = rowMeans(fit$beta_test),
              ate_hat = mean(fit$beta_test),
              cate_samples = fit$beta_test,
              cate_hat = colMeans(fit$beta_test)))
}

load_nmes_fit <- function(nmes) {
  if(file.exists("cache/NMESfit.rds"))
    return(readRDS("cache/NMESfit.rds"))
  out <- fit_nmes(nmes)
  saveRDS(object = out, file = "cache/NMESfit.rds")
  return(out)
}

get_subgroups_nmes <- function(bcf_fit, nmes) {
  formula <- tau ~ AGESMOKE + LASTAGE + MALE + RACE3 + beltuse + educate +
    marital + SREGION + POVSTALB
  nmes$tau <- bcf_fit$cate_hat
  out <- list()
  out$rpart_fit <- rpart(formula, data = nmes)
  out$rpart_plot <- rpart.plot(out$rpart_fit)
  return(out)
}

kernsmooth_iter <- function(bcf_fit, nmes, iter, variable_name, bw) {
  kern_fit <- ksmooth(x = nmes[[variable_name]],
                      y = bcf_fit$cate_samples[iter,],
                      bandwidth = bw)
  return(kern_fit)
}

kernsmooth_iters <- function(bcf_fit, nmes, iters, variable_name, bw) {
  out <- list()
  for(i in 1:length(iters)) {
    out[[i]] <- kernsmooth_iter(bcf_fit, nmes, iters[i], variable_name, bw)
  }
  x <- out[[1]]$x
  y <- do.call(rbind, lapply(out, \(l) l$y))
  df <- data.frame(x = rep(x, length(iters)), y = as.numeric(t(y)),
                   iter = rep(iters, each = length(x)))
  return(df)
}

lastage_group <- function(nmes) {
  nmes %>% mutate(age_group = factor(case_when(
    LASTAGE < 47 ~ "Young",
    LASTAGE < 61 ~ "Middle",
    TRUE ~ "Old"
  )))
}

group_means <- function(bcf_fit, group_factor) {
  n_iter <- nrow(bcf_fit$cate_samples)
  n_lev <- length(levels(group_factor))
  out <- matrix(nrow = n_iter, ncol = n_lev)
  for(i in 1:n_lev) {
    lev <- levels(group_factor)[i]
    out[,i] <- rowMeans(bcf_fit$cate_samples[,group_factor == lev])
  }
  return(out)
}

## Do Analysis ----

nmes           <- load_nmes()
fitted_bcf     <- load_nmes_fit(nmes)
subgroups_nmes <- get_subgroups_nmes(fitted_bcf, nmes)

moo <- kernsmooth_iters(fitted_bcf, nmes, c(1, 100, 200, 300), "LASTAGE", 10)

nmes_age <- lastage_group(nmes)
