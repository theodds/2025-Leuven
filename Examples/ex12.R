
library(BART3)

set.seed(34)
N <- 2500
L <- 130
Q <- N+L
P <- 20
x.train <- matrix(runif(P*N, -1, 1), nrow = N, ncol = P)
x.test  <- matrix(runif(P*Q, -1, 1), nrow = Q, ncol = P)
x <- seq(-1, 1.25, 0.25)
x.test[1:130, 1:5] <- 0
x.test[ 1:10, 1] <- x
x.test[11:20, 2] <- x
x.test[21:30, 3] <- x
h <- 30
for(i in 1:10)
    for(j in 1:10) {
        h <- h+1
        x.test[h, 4] <- x[i]
        x.test[h, 5] <- x[j]
}
print(h)

mu. <- function(Z) Z[ , 1]^3-Z[ , 2]^2+Z[ , 3]-Z[ , 4]*Z[ , 5]
sd. <- 0.5
y.train <- rnorm(N, mu.(x.train), sd.)
y.test  <- rnorm(Q, mu.(x.test), sd.)
summary(y.train)
summary(y.test[-(1:L)])

options(mc.cores = 8)
file. <- "ex1.rds"
if(file.exists(file.)) {
    post <- readRDS(file.)
} else if(.Platform$OS.type == 'unix') {
    post <- mc.gbart(x.train, y.train, x.test, sparse = TRUE, seed = 21)
    saveRDS(post, file.)
    plot(post$sigma[ , 1], type = 'l', ylim = c(0, max(post$sigma)), 
         ylab = expression(sigma))
    for(i in 2:8) lines(post$sigma[ , i], col = i)
    abline(v = 100, h = c(0, sd.), col = 8)
    abline(h = post$sigma.mean, lty = 2)
    check <- maxRhat(post$sigma., post$chains)
    acf(post$sigma., main = expression(sigma)) 
    points(check$rho)
    ## plot(post$accept[ , i], type = 'l', ylim = 0:1, ylab = 'MH')
    ## for(i in 2:8) lines(post$accept[ , i], col = i)
    ## abline(v = 100, h = 0:1, col = 8)
} else {
    set.seed(12)
    post <- gbart(x.train, y.train, x.test, sparse = TRUE)
    saveRDS(post, file.)
    acf(post$sigma., main = expression(sigma)) 
}
   
plot(x.test[1:10, 1], mu.(x.test[1:10, ]), type = 'n', 
     ylim = c(min(post$yhat.test.lower[1:L]),
              max(post$yhat.test.upper[1:L])),
     xlab = 'x', ylab = 'f(x)')
abline(v = 1, col = 8)
legend('topleft', legend = c('+cubic', '-quadratic', '+linear'),
       lwd = 2, col = c(1, 2, 4))
pred <- list()
for(i in 1:3) {
    h <- 2^(i-1)
    j <- (1+(i-1)*10):(i*10)
    X <- matrix(0, nrow = L, ncol = P)
    X[ , i] <- seq(-1, 1.25, length.out = L)
    lines(X[ , i], mu.(X), lwd=2, col=h) ## truth
    pred[[i]] <- FPD(post, cbind(x.test[j, i]), i)
    lines(x.test[j, i], pred[[i]]$yhat.test.mean, lty=2, col=h)
    lines(x.test[j, i], pred[[i]]$yhat.test.lower, lty=3, col=h)
    lines(x.test[j, i], pred[[i]]$yhat.test.upper, lty=3, col=h)
    points(x.test[j[9:10], i], pred[[i]]$yhat.test.mean[9:10], col=h)
}
 
