
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

IP <- function(A, B, trees) { ## interaction potential
    branch <- list()
    for(i in 1:3) branch[[i]] <- (trees[ , , i, 1] == 1)
    xA.b <- (trees[ , , 1, 2] == A) ## root branch on xA
    xA.b[!branch[[1]]] <- NA
    xA.c <- ## node 2 or 3 children branch on xA
        (trees[ , , 2, 2] == A) | (trees[ , , 3, 2] == A) 
    xA.c[!(branch[[2]] | branch[[3]])] <- NA
    xB.b <- (trees[ , , 1, 2] == B) ## root branch on xB
    xB.b[!branch[[1]]] <- NA
    xB.c <- ## node 2 or 3 children branch on xB
        (trees[ , , 2, 2] == B) | (trees[ , , 3, 2] == B)
    xB.c[!(branch[[2]] | branch[[3]])] <- NA
    xAB <- (xA.b & xB.c) | (xA.c & xB.b)
    return(list(AB = xAB, A.root = xA.b, B.root = xB.b, 
                A.child = xA.c, B.child = xB.c,
                branch = branch))
}

x12 <- IP(1, 2, trees)
addmargins(table(x12$AB[(x12$A.root | x12$B.root) & (x12$branch[[2]] | x12$branch[[3]])]))

x45 <- IP(4, 5, trees)
addmargins(table(x45$AB[(x45$A.root | x45$B.root) & (x45$branch[[2]] | x45$branch[[3]])]))

