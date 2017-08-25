#Project : Brownian motion
#Author  : Dago Quevedo
#Date    : Aug 2017

library(parallel)

unlink("P1*.png")

args = commandArgs(trailingOnly = TRUE)

if (length(args) > 0) {
    restarts  = as.numeric(args[1])
    steps     = as.numeric(args[2])
    dimensions= as.numeric(args[3])
    euclidea  = as.logical(args[4])
}

brownian = function(r) {
    position    = rep(0, dimension)  
    origin      = rep(0, dimension) 
    max_return  = 0    
    max_steps   = 0   
                         
    for (t in 1:duration) 
    {
        change = sample(1:dimension, 1)
        delta  = 1
        if (runif(1) < 0.5) {
            delta = -1
        }
        position[change] = position[change] + delta

        if (euclidea) {
            dist = sum(sqrt(position**2))
        } else {
            dist =  sum(abs(position))
        }

        if (dist > max_steps)      
            max_steps  = dist
        if (position == origin) 
            max_return = max_return + 1
    }
    return(c(max_steps, max_return))
}


#Experiment 1, 2

data_dist = data.frame()
data_orig = data.frame()
cluster   = makeCluster(detectCores() - 1)
duration  = steps

clusterExport(cluster, "duration")
clusterExport(cluster, "euclidea")

for (dimension in 1:dimensions) {
    clusterExport(cluster, "dimension")
    result   = parSapply(cluster, 1:restarts, brownian)
    data_dist= rbind(data_dist, result[1,])
    data_orig= rbind(data_orig, result[2,])
}

stopCluster(cluster)


#Experiment 3

data_parl = data.frame()
data_sequ = data.frame()
dimension = dimensions

cluster = makeCluster(detectCores())
clusterExport(cluster, "dimension")
clusterExport(cluster, "euclidea")

for (duration in seq(steps, steps * 20, steps))
{
    clusterExport(cluster, "duration")
    parl_time = system.time(parSapply(cluster, 1:restarts, brownian))[3]
    sequ_time = system.time(sapply            (1:restarts, brownian))[3]
    data_parl = rbind(data_parl, parl_time)
    data_sequ = rbind(data_sequ, sequ_time)
}

stopCluster(cluster)

# Plot

png("P1_A.png")
boxplot(data.matrix(data_dist), use.cols = FALSE,
       xlab="Dimension", ylab="Maximum distance", 
       main=(if (euclidea) "Euclidean" else "Manhattan"), 
       sub =sprintf("Restarts: %d | Steps: %d", restarts, steps))

graphics.off()

png("P1_B.png")
boxplot(data.matrix(data_orig), use.cols = FALSE,
       xlab="Dimension", ylab="Returns to origin", 
       main=(if (euclidea) "Euclidean" else "Manhattan"), 
       sub =sprintf("Restarts: %d | Steps: %d", restarts, steps))

graphics.off()

png("P1_C.png")
plot(data.matrix(data_sequ), xlab="Steps", ylab="Time (seg)",
    type="b", pch=19, col="red",xaxt = "n")
lines(data.matrix(data_parl), pch=18, col="blue",
    type="b",xaxt = "n")
axis(1, at=seq(5, 20, by=5), 
    labels=seq(steps * 5, steps * 20, by=steps * 5))

graphics.off()

