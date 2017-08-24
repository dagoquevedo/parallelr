#Project : Cellular automaton - crystallization 1
#Author  : Dago Quevedo
#Date    : Aug 2017

library(parallel)
library(sna)

unlink("P2_B*.png")
unlink("P2_B*.gif")

args = commandArgs(trailingOnly = TRUE)

if (length(args) > 0) {
    dim      = as.numeric(args[1])
    seeds    = as.numeric(args[2])
    num      = dim^2
}

move = function(pos) {
    row = floor((pos - 1) / dim) + 1
    col = ((pos - 1) %% dim) + 1
  
    if(state[row, col] > 0) {
        return(state[row, col])
    }
    if (state[row, col] == 0) {
        neigh = state[
                        max(row - 1, 1) : min(row + 1, dim),
                        max(col - 1, 1) : min(col + 1, dim)
                     ]

    if(sum(neigh) == 0) {
        return(0)
    } else {
        neigh = setdiff(neigh, 0)
        value = unique(neigh)[which.max(tabulate(match(neigh, unique(neigh))))]
        return(value)
    }
  }
}

cluster = makeCluster(detectCores() - 1)
clusterExport(cluster, "dim")

state    = matrix(0, nrow = dim, ncol = dim)
pos_seed = sample(1:num, seeds)

for (seed in 1:seeds) {
    state[pos_seed[seed]] = seed / seeds
}

generation = 0

repeat {
    clusterExport(cluster, "state")    
    state      = matrix(parSapply(cluster,1:num,move),nrow=dim,ncol=dim,byrow = TRUE)

    if(!any(state == 0)) {
        break;
    }

    generation = generation + 1

    output = paste("B",formatC(generation,width=4,format="d",flag="0"),".png",sep="")    
    png(output)
    plot.sociomatrix(state, diaglab = FALSE, 
                     main = sprintf("Generation: %d", generation), drawlab = FALSE)
    graphics.off()
}

stopCluster(cluster)

system(sprintf("convert -delay %d *.png P2_B_%s.gif",20,'01'))
system("rm *.png")


size_states = data.frame()
size_states = rbind(size_states, as.vector(table(state)))

png("P2_B_02.png")
boxplot(data.matrix(size_states), use.cols=FALSE, 
    xlab = "Seeds", ylab = "Size", main = "Seeds size")
graphics.off()

border = c(
            1:dim,
            (num - dim + 1):num,
            seq(dim + 1, num - 2 * dim + 1, dim),
            seq(2 * dim, num - dim, dim)
          )

border_value = 0

for (i in border) {
    border_value = c(border_value, state[i])
}

border_no_seed = table(state[!state %in% unique(border_value)])

png("P2_B_03.png")
barplot(border_no_seed, main = "Seeds size without border", 
    xlab = "Seeds", ylab = "Size")
graphics.off()


