#Project : Genetic algorithm - parallel version
#Author  : Dago Quevedo
#Date    : Oct 2017

library(testit)
library(parallel)

knapsack <- function(capacity, weight, value) {
    n <- length(weight)
    pt <- sum(weight) 
    assert(n == length(value))
    vt <- sum(value) 
    if (pt < capacity) { 
        return(vt)
    } else {
        filas <- capacity + 1 
        cols <- n + 1 
        tabla <- matrix(rep(-Inf, filas * cols),
                       nrow = filas, ncol = cols) 
        for (fila in 1:filas) {
            tabla[fila, 1] <- 0 
        }
        rownames(tabla) <- 0:capacity 
        colnames(tabla) <- c(0, value) 
        for (objeto in 1:n) { 
            for (acum in 1:(capacity+1)) { # consideramos cada fila de la tabla
                anterior <- acum - weight[objeto]
                if (anterior > 0) { # si conocemos una combinacion con ese peso
                    tabla[acum, objeto + 1] <- max(tabla[acum, objeto], tabla[anterior, objeto] + value[objeto])
                }
            }
        }
        return(max(tabla))
    }
}
 

normalize <- function(data) {
    val.min <- min(data)
    val.max <- max(data)
    range 	<- val.max - val.min
    data  	<- data - val.min
    return(data / range)
}
 
generator.weights <- function(size, val.min, val.max) {
    return(sort(round(normalize(rnorm(size)) * (val.max - val.min) + val.min)))
}
 
generator.values  <- function(weights, val.min, val.max) {
    n 		<- length(weights)
    values  <- double()
	
    for (i in 1:n) {
        avg 	<- weights[n]
        std 	<- runif(1)
        values 	<- c(values, rnorm(1, avg, std))
    }
	
    values <- normalize(values) * (val.max - val.min) + val.min
    return(values)
}
 

plot.1 <- function(optimal, best.glo, best.loc, tmax) {
	png("P10_B.png", width=600, height=300)
	plot(1:tmax, best.glo, xlab="Generación", ylab="Mayor valor objetivo", type='l', ylim=c(0.95 * min(best.glo), 1.05 * optimal))
	points(1:tmax, best.glo, pch=15)
	abline(h=optimal, col="green", lwd=3)
	graphics.off()
}


GA <- function(n, m, tmax, rep, pm, plot, roulette.pr, roulette.ps) {	
	cluster <- makeCluster(detectCores())
	
	population.initial <- function(n, m) {
		population <- t(parSapply(cluster,1:m,function(i) {
					  	return(round(runif(n)))
					  }))
		return(as.data.frame(population))
	}

	
	reproduction <- function(x, y, n) {
		pos <- sample(2:(n - 1), 1)
		xy <- c(x[1:pos], y[(pos + 1):n])
		yx <- c(y[1:pos], x[(pos + 1):n])
		
		return(rbind(xy, yx))
	}

	feasible <- function(selection, weights, capacity) {
		return(sum(unlist(selection) * weights) <= capacity)
	}

	objective<- function(selection, values) {
		return(sum(unlist(selection) * values))
	}
	
	mutation <- function(sol, n) {
		pos <- sample(1:n, 1)
		mut <- sol
		mut[,pos] <- (!unlist(mut[,pos])) * 1
		return(mut)
	}
	
	weights  <- generator.weights(n, 15, 80)
	values   <- generator.values(weights, 10, 500)
	capacity <- round(sum(weights) * 0.65)
	optimal  <- knapsack(capacity, weights, values)
	p 		 <- population.initial(n, m)
	size 	 <- dim(p)[1]

	assert(size == m)
	
	best.glo <- double()	
		
	for (iter in 1:tmax) {	
		pr 		 <- NULL
		ps		 <- NULL

		if(roulette.pr) {
			pr <- 	parSapply(cluster,1:size,function(i) {
							if(!is.null(p$obj)) {
								return(p$obj[i] / sum(p$obj))
							} 
							else { return(1) }
					})
			}
		
		p$obj <- NULL
		p$fsb <- NULL

		p <- rbind(p, t(parSapply(cluster,sample(1:size, ceiling(pm * size)),function(i) {
						return(mutation(p[i,], n))
					  }))
				  )
		
		parent <- t(parSapply(cluster,1:rep,function(i) {
						return(sample(1:size, 2, prob = pr))
					}))
	
		child  <- parSapply(cluster,1:rep,function(i) {
						return(as.matrix(unlist(reproduction(p[parent[i,1],], 
															 p[parent[i,2],], n)),ncol=n))
					})
		
		p <- rbind(p, child)
		
		size <- dim(p)[1]
		
		obj  <- double()
		fsb  <- logical()
		
		obj  <- parSapply(cluster,1:size,function(i) {
					return(objective(p[i,], values))
				})

		fsb  <- parSapply(cluster,1:size,function(i) {
					return(feasible(p[i,], weights, capacity))
				})

		p <- cbind(p, obj)
		p <- cbind(p, fsb)

		if(roulette.ps) {
			ps 	 <-	parSapply(cluster,1:size,function(i) {
							return(p$obj[i] / sum(p$obj))
					})
			keep <- sample(1:size, m, prob = ps)
		}
		else {
			keep <- order(-p[, (n + 2)], -p[, (n + 1)])[1:m]	
		}
		
		p <- p[keep,]
		
		size <- dim(p)[1]
		
		assert(size == m)
		
		p.fsb 	 <- p[p$fsb == TRUE,]
		if(dim(p.fsb)[1] > 0) {
			best.loc <- max(p.fsb$obj)
		}
		else {
			best.loc <- 0
		}
		best.glo <- c(best.glo, best.loc)
	}
	
	stopCluster(cluster)
	
	if(plot) {
		plot.1(optimal, best.glo, best.loc, tmax)
	}
	
	gap = (optimal - best.loc) / optimal
	
	return(gap)
}

time <- system.time(
			gap <- GA(50, 200, 50, 50, 0.05, T, F, F)
		)[3]

print(time)
print(gap)
