unlink("P4_A*.png")

n    = 300
k    = 12
distr= 1

cell =  function(pos) {
    row = floor((pos - 1) / n) + 1
    col = ((pos - 1) %% n) + 1
    if (zone[row, col] > 0) {
        return(zone[row, col])
    } else {
        near = 0
        dmin = n * sqrt(2)
        for (seed in 1:k) {
            dx 	 = col - x[seed]
            dy 	 = row - y[seed]
            dist = sqrt(dx^2 + dy^2)
            if (dist < dmin) {
                near = seed
                dmin = dist
            }
        }
        return(near)
    }
}

zone = matrix(rep(0, n * n), nrow = n, ncol = n)
x    = rep(0, k)
y    = rep(0, k)
row  = 0
col  = 0

for (seed in 1:k) {
	while (T) {
		if(distr == 1) {
        	row = sample(1:n, 1)
        	col = sample(1:n, 1)
		} else if(distr == 2) {
			row = rpois(n, lambda = ceiling(n/2))[1]
			col = rpois(n, lambda = ceiling(n/2))[1]
		} else if(distr == 3) {
			row = rbinom(n, ceiling(n/2), 0.5)[1]	
			col = rbinom(n, ceiling(n/2), 0.5)[1]	
		}
		
        if (zone[row, col] == 0) {
            zone[row, col] = seed
            x[seed] = col
            y[seed] = row
            break;
        }
    }
}


suppressMessages(library(doParallel))
registerDoParallel(makeCluster(detectCores() - 1))

cells = foreach(p = 1:(n * n), .combine=c) %dopar% cell(p)

stopImplicitCluster()

voronoi = matrix(cells, nrow = n, ncol = n, byrow=TRUE)

png("P4_A_01.png")

par(mar = c(0,0,0,0))
image(zone   , col=rainbow(k+1), xaxt='n', yaxt='n')
graphics.off()

png("P4_A_02.png")
par(mar = c(0,0,0,0))
image(voronoi, col=rainbow(k+1), xaxt='n', yaxt='n')
graphics.off()
	
