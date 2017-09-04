#Project : Voronoi (I)
#Author  : Dago Quevedo
#Date    : Sep 2017

unlink("img/P4_A*.png")

args = commandArgs(trailingOnly = T)

if (length(args) > 0) {
	n_max = as.numeric(args[1])
	k_max = as.numeric(args[2])
	distr = as.numeric(args[3])
}

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

start = function() {
    sense = sample(1:4, 1)
    xg 	  = NULL
    yg 	  = NULL
	
    if (sense == 1) {
        xg = 1
        yg = sample(1:n, 1)
    } else if (sense == 2) {
        xg = sample(1:n, 1)
        yg = 1
    } else if (sense == 3) {
        xg = n
        yg = sample(1:n, 1)
    } else {
        xg = sample(1:n, 1)
        yg = n
    }
    return(c(xg, yg))
}

spread = function(replica) {
    prob 	  = 1
    difficult = 0.99
    fissure   = voronoi
    i 		  = start()
    xg 		  = i[1]
    yg 		  = i[2]
    large 	  = 0

    while (T) {
        fissure[yg, xg] = 0
        large =  large + 1
		
        border = numeric()
        inside = numeric()
		
        for (v in 1:vc) {
            neighbor = vp[v,]
            xs = xg + neighbor$dx
            ys = yg + neighbor$dy
            if (xs > 0 & xs <= n & ys > 0 & ys <= n) {
                if (fissure[ys, xs] > 0) {
                    if (voronoi[yg, xg] == voronoi[ys, xs]) {
                        inside = c(inside, v)
                    } else {
                        border = c(border, v)
                    }
                }
            }
        }
		
        selection = 0
        if (length(border) > 0) {
            if (length(border) > 1) {
                selection = sample(border, 1)
           } else {
                selection = border
            }
            prob = 1
        } else if (length(inside) > 0) {
            if (runif(1) < prob) {
                if (length(inside) > 1) {
                    selection = sample(inside, 1)
                } else {
                    selection = inside
                }
                prob = difficult * prob
            }
        }
        if (selection > 0) {
            neighbor = vp[selection,]
            xg = xg + neighbor$dx
            yg = yg + neighbor$dy
        } else {
            break;
        }
    }
    if (large >= limit) {
        png(paste("img/P4_A_03_", replica, ".png", sep=""))
        par(mar = c(0,0,0,0))
        image(fissure, col=rainbow(k+1), xaxt='n', yaxt='n')
        graphics.off()
    }
    return(large)
}

result = data.frame()

for (n in seq(50, n_max, 50)) {
	for (k in seq(4, k_max, 4)) {
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

		png("img/P4_A_01.png")

		par(mar = c(0,0,0,0))
		image(zone   , col=rainbow(k+1), xaxt='n', yaxt='n')
		graphics.off()

		png("img/P4_A_02.png")
		par(mar = c(0,0,0,0))
		image(voronoi, col=rainbow(k+1), xaxt='n', yaxt='n')
		graphics.off()


		#Grieta	
		limit = n

		vp = data.frame(numeric(), numeric())
		for (dx in -1:1) {
			for (dy in -1:1) {
				if (dx != 0 | dy != 0) {
					vp = rbind(vp, c(dx, dy))
				}
			}
		}
		names(vp) = c("dx", "dy")
		vc = dim(vp)[1]
		
		suppressMessages(library(doParallel))
		registerDoParallel(makeCluster(detectCores() - 1))
		larges = foreach(r = 1:200, .combine=c) %dopar% spread(r)
		stopImplicitCluster()
				
		result = rbind(result, cbind(n,k,larges))
	}
}

		
png("img/P4_A_04.png",width = 7.5, height = 3, units = "in", res = 200)
par(mfrow=c(1,3))

for (k in seq(4, k_max, 4)) {
	boxplot(result[result[,2] == k, 3] ~ result[result[,2] == k, 1], 
			main = sprintf("Número de semillas: %d", k), xlab = "Tamaño de la matriz", ylab = "Largo",ylim = c(1, 100))
}
		
kruskal.test(result[, 3] ~ result[, 1]) #n
kruskal.test(result[, 3] ~ result[, 2])	#k	
		
graphics.off()

