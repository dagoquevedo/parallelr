#Project : Local search
#Author  : Dago Quevedo
#Date    : Sep 2017

suppressMessages(library(doParallel))
library(ggplot2)
library(lattice)

unlink("img/P7_A*.png")
unlink("img/P7_A*.gif")

g <- function(x, y) {
    return((((x + 0.5)^4 - 30 * x^2 - 20 * x) + 
	 		((y + 0.5)^4 - 30 * y^2 - 20 * y))/100)
}
 
low 	 <- -6
high 	 <- 5
step 	 <- 0.25
k 		 <- 30
g_max	 <- 1.301250		 

LS  <- function(time) {
    curr <- runif(2, low, high)
	best <- curr

	for (t in 1:time) {
        delta 	  <- runif(2, 0, step)
		neighbors <- rbind(   c(curr[1] + delta[1], curr[2] + delta[2]),
							  c(curr[1] - delta[1], curr[2] + delta[2]),
							  c(curr[1] + delta[1], curr[2] - delta[2]),
							  c(curr[1] - delta[1], curr[2] - delta[2])
                          )

		for(i in 1:length(neighbors[1,])) {
			if(neighbors[i,1] >= low & neighbors[i,1] <= high & 
			   neighbors[i,2] >= low & neighbors[i,2] <= high) {
				if (g(neighbors[i,1],neighbors[i,2]) > g(curr[1],curr[2])) {
					curr <- neighbors[i,]
				}
			}
		}
		
		if(g(curr[1],curr[2]) > g(best[1],best[2])) {
			best <- curr
		}
    }
    return(best)
}
 
registerDoParallel(makeCluster(detectCores() - 1))

x <- seq(low, high, length = 256)
y <- seq(low, high, length = 256)

grid 	<- expand.grid(x=x, y=y)
grid$z 	<- g(grid$x, grid$y)

for (pow in 1:5) {
    tmax 	<- 10^pow
    result 	<- foreach(i = 1:k, .combine = rbind) %dopar% LS(tmax)
	values 	<- g(result[,1],result[,2])
	best	<- which.max(values)
	gap		<- (abs(max(values) - g_max) / g_max) * 100
	
	output  <- paste("img/P7_A_1_",formatC(tmax, width = 4, format = "d", flag = "0"),".png")
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

system(sprintf("convert -delay %d img/P7_A_1_*.png img/P7_A_1.gif", 90))
unlink("img/P7_A_1_*.png")

x 		<- seq(low, high, length = 50)
y 		<- seq(low, high, length = 50)
z 		<- outer(x, y, g)
nrz   	<-nrow(z)
ncz	  	<-ncol(z)
color  	<-rainbow(256)
zgrad   <-z[-1,-1]+z[-1,-ncz]+z[-nrz,-1]+z[-nrz,-ncz]
gradient<-cut(zgrad,length(color))

for(gr in seq(4,360,4)) {
	output  = paste("img/P7_A_2_",formatC(gr, width=3, format="d",flag="0"),".png")
	png(output, width = 7, height = 7, units = "in", res = 150)
	persp(x, y, z, phi = 30, theta = gr, col =color[gradient])
	graphics.off()
}

system(sprintf("convert -delay %d img/P7_A_2_*.png img/P7_A_2.gif", 10))
unlink("img/P7_A_2_*.png")

