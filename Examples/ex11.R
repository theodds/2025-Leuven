
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

file. <- "ex1.rds"
if(file.exists(file.)) {
    post <- readRDS(file.)
} else if(.Platform$OS.type == 'unix') {
    options(mc.cores = 8)
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
   

levels. <- quantile(-outer(x[-10], x[-10]), (1:4)/5)
contour(x, x, -outer(x, x), levels = levels.)
abline(v = 1, h = 1, col = 8)
z <- matrix(nrow = 10, ncol = 10)
h <- 30
for(i in 1:10)
    for(j in 1:10) {
        h <- h+1
        z[i, j] <- post$yhat.test.mean[h] ## x4:i, x5:j
}
contour(x, x, z, add = TRUE, col = 2, levels = levels.)

file. <- "ex11.rds"
if(file.exists(file.)) {
    trees <- readRDS(file.)
} else {
    trees <- read.trees(post$treedraws, x.train)
    saveRDS(trees, file.)
}

str(trees)
object.size(trees)
print(object.size(trees), units = 'MB')

branch <- list()
leaf <- list()
var <- list()
depth <- matrix(0, nrow = 1000, ncol = 200)
for(i in 1:127) {
    branch[[i]] <- (trees[ , , i, 1] == 1)
    leaf[[i]] <- (trees[ , , i, 1] == 2)
    var[[i]] <- trees[ , , i, 2]
    depth <- pmax(depth, floor(log2(leaf[[i]]*i)))
}
str(depth)
table(depth)/200000

a <- table(var[[1]][var[[1]]>0])/sum(var[[1]]>0)
print(a)
print(cumsum(a))
plot(a, ylim = 0:1, xlab = 'x', ylab = 'node:1')
points(cumsum(a), col = 4)
abline(h = 0:1, v = 5.5, col = 8)
abline(h = 0.05, col = 2)

x4.b <- (trees[ , , 1, 2] == 4) ## root branch on x4
x4.b[!branch[[1]]] <- NA
x4.c <- ## node 2 or 3 children branch on x4
    (trees[ , , 2, 2] == 4) | (trees[ , , 3, 2] == 4) 
x4.c[!(branch[[2]] | branch[[3]])] <- NA
x5.b <- (trees[ , , 1, 2] == 5) ## root branch on x5
x5.b[!branch[[1]]] <- NA
x5.c <- ## node 2 or 3 children branch on x5
    (trees[ , , 2, 2] == 5) | (trees[ , , 3, 2] == 5)
x5.c[!(branch[[2]] | branch[[3]])] <- NA
x45  <- (x4.b & x5.c) | (x4.c & x5.b)
## interaction potential
addmargins(table(x45[(x4.b | x5.b) & (branch[[2]] | branch[[3]])]))

x1.b <- (trees[ , , 1, 2] == 1) ## root branch on x1
x1.b[!branch[[1]]] <- NA
x1.c <- (trees[ , , 2, 2] == 1) | (trees[ , , 3, 2] == 1) 
x1.c[!(branch[[2]] | branch[[3]])] <- NA
x2.b <- (trees[ , , 1, 2] == 2) ## root branch on x2
x2.b[!branch[[1]]] <- NA
x2.c <- (trees[ , , 2, 2] == 2) | (trees[ , , 3, 2] == 2)
x2.c[!(branch[[2]] | branch[[3]])] <- NA
x12  <- (x1.b & x2.c) | (x1.c & x2.b)
addmargins(table(x12[(x1.b | x2.b) & (branch[[2]] | branch[[3]])]))

