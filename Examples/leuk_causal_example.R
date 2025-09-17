#' This file shows how we could use the survival model illustrated in the class
#' to perform causal inference. To run this, you will also need to run the
#' required code in the Leukemia.rmd file. The code augments this dataset with
#' a treatment variable (which is unassociated with the outcome) for
#' the purpose of illustration.
#' 
#' As mentioned in class, this is a bit of a hack. It is better to use BCF-style
#' models when they are available.

leuk_data$trt <- rbinom(n = nrow(leuk_data),
                        size = 1,
                        prob = 0.5)


## "Jennifer Hill" approach (2011 JCGS) use trt as a "regular" covariate

# We create two datasets, one with the treatment variable set to 0 and one with
# it set to 1. This is used as our test set.
leuk_data_0 <- leuk_data
leuk_data_0$trt <- 0
leuk_data_1 <- leuk_data
leuk_data_1$trt <- 1
leuk_data_test <- rbind(leuk_data_0, leuk_data_1)
View(leuk_data_test)

fitted_coxpe_trt <-
  BART4RS::coxpe_bart(
    formula = Surv(event_time, status) ~ age + sex + wbc + tpi + trt,
    data = leuk_data,
    test_data = leuk_data_test,
    num_burn = 1000,
    num_save = 1000,
    num_thin = 1
  )

## Samples of the regression function evaluations are contained in the $r_test
## matrix. We can compute the average log risk ratio for each individual in the
## test set as follows.

r_hat_control <- fitted_coxpe_trt$r_test[,1:nrow(leuk_data) ]
r_hat_treated <- fitted_coxpe_trt$r_test[,-(1:nrow(leuk_data))]
log_risk_ratio <- r_hat_treated - r_hat_control
average_log_risk_ratio <- rowMeans(log_risk_ratio)
hist(average_log_risk_ratio)
