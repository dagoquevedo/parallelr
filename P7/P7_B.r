#Project : Local search - simulated annealing
#Author  : Dago Quevedo
#Date    : Sep 2017

suppressMessages(library(doParallel))
library(ggplot2)
library(lattice)

unlink("img/P7_B*.png")
unlink("img/P7_B*.gif")

g <- function(x,y) {
    return((((x + 0.5)^4 - 30 * x^2 - 20 * x) + 
	 		((y + 0.5)^4 - 30 * y^2 - 20 * y))/100)
}

low 	 <- -6
high 	 <- 5
step 	 <- 0.25
k 		 <- 30
T		 <- 0
xi	 	 <- 0.8
g_max	 <- 1.301250

SA  <- function(tmax, xi) {
	curr <- runif(2, low, high)
	best <- curr
	T	 <- tmax
	
	for (t in 1:tmax) {
        delta 	 <- runif(2, -step, step)
		neighbor <- c(curr[1] + delta[1], curr[2] + delta[2])
	
		if(	neighbor[1] >= low & neighbor[1] <= high  & 
		   	neighbor[2] >= low & neighbor[2] <= high) {
				d = g(neighbor[1], neighbor[2]) > g(curr[1], curr[2])
				if(d | runif(1) < exp(-d/T)) {
					curr <- neighbor
				}			
		}
		
		if(g(curr[1],curr[2]) > g(best[1],best[2])) {
			best <- curr
		}
		
		T = T * xi
    }
	
    return(best)
}

registerDoParallel(makeCluster(detectCores() - 1))

x <- seq(low, high, length = 256)
y <- seq(low, high, length = 256)

grid 	<- expand.grid(x = x, y = y)
grid$z 	<- g(grid$x, grid$y)

for (pow in 1:5) {
    tmax 	<- 10^pow
    result 	<- foreach(i = 1:k, .combine = rbind) %dopar% SA(tmax, xi)
	values 	<- g(result[,1],result[,2])
	best	<- which.max(values)
	gap		<- (abs(max(values) - g_max) / g_max) * 100
	
	output  <- paste("img/P7_B_1_",formatC(tmax, width = 4, format = "d", flag = "0"),".png")
	png(output, width = 7, height = 7, units = "in", res = 150)
	print(
			levelplot(	 z ~ x * y, grid, main = paste(formatC(tmax, width = 5, format = "d", flag = "0"),
														" iteraciones | ", formatC(k, width = 2, format = "d", flag = "0"),
													    " reinicios |",sprintf("%.2f%% gap", gap)), 
					  	 xlab.top = "Óptimos locales y globales", contour = TRUE, 
						 panel = function(...) {
									panel.levelplot(...)
									panel.abline(h = result[best,2], col = "blue")
									panel.abline(v = result[best,1], col = "blue")
									panel.xyplot(result[,1], result[,2], pch = 20, col = "red", cex = 1)
									panel.xyplot(result[best,1],result[best,2], pch = 20, col = "blue", cex = 2)
								}
					 )
		 )
    graphics.off()
}

stopImplicitCluster()

system(sprintf("convert -delay %d img/P7_B_1_*.png img/P7_B_1.gif", 90))
unlink("img/P7_B_1_*.png")

