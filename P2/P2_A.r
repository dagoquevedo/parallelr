#Project : Cellular automaton
#Author  : Dago Quevedo
#Date    : Aug 2017

library(parallel)
library(sna)

unlink("P2_A*.png")
unlink("P2_A*.gif")

args = commandArgs(trailingOnly = TRUE)

if (length(args) > 0) {
    restarts = as.numeric(args[1])
    dim      = as.numeric(args[2])
    num      = dim^2
}
 
move = function(pos) {
    row   = floor((pos - 1) / dim) + 1
    col   = ((pos - 1) %% dim) + 1
    neigh = state[max(row - 1, 1) : min(row + 1, dim),
                  max(col - 1, 1) : min(col + 1, dim)]
    return(1 * ((sum(neigh) - state[row, col]) == 3))
}

max_generation = data.frame()

for (rest in 1:restarts) {
    for (prob in seq(0.1, 0.9, 0.1)) {

        state = matrix(as.numeric(runif(num) < prob), nrow = dim, ncol = dim)
        
        png("A0000.png")
        plot.sociomatrix(state, diaglab=FALSE, 
                         main = sprintf("Initial generation | Initial probability of living cell: %.1f", prob), 
                         drawlab = FALSE)
        graphics.off()

        cluster = makeCluster(detectCores())
        clusterExport(cluster, "dim")
        clusterExport(cluster, "move")

        generation = 0
        actual     = 0

        repeat {
            clusterExport(cluster, "state")
            before = sum(actual) 
            actual = parSapply(cluster, 1:num, move)
            
            if (sum(actual) == 0 || before == sum(actual)) {
                print("We all float down here, and you will too!")
                break;
            }

            generation = generation + 1
            state      = matrix(actual, nrow=dim, ncol=dim, byrow=TRUE)
            output     = paste("A",formatC(generation,width=4,format="d",flag="0"),".png",sep="")

            png(output)
            plot.sociomatrix(state, diaglab=FALSE, 
                             main = sprintf("Generation: %d | Initial probability of living cell: %.1f", generation, prob),
                             drawlab = FALSE)

            graphics.off()
        }

        max_generation = rbind(max_generation, c(prob, generation))

        system(sprintf("convert -delay %d *.png P2_A_%s.gif",40,formatC(as.integer(prob * 10),width=2,format="d",flag="0")))
        unlink("A*.png")
        
        stopCluster(cluster)            
    }
}

png("P2_A_10.png")
boxplot(max_generation[,2] ~ max_generation[,1], use.cols = FALSE,
       xlab="Initial probability of living cell", ylab="Maximum generation", 
       main=sprintf("Maximum live generation | Restarts: %d", restarts))


