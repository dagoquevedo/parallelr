#Project : Montecarlo Simulation - Pi
#Author  : Dago Quevedo
#Date    : Sep 2017

suppressMessages(library(doParallel))
library(lattice)
library(gridExtra)

unlink("img/P5_B*.png")

args = commandArgs(trailingOnly = TRUE)

if (length(args) > 0) {
    restarts  = as.numeric(args[1])
}

eval_wolfram <- 3.141592653589793238462643383279502884197169399375105820974
result 		 <- data.frame()

f = function(size) {
	xs <- runif(size, min=-0.5, max=0.5)
	ys <- runif(size, min=-0.5, max=0.5)
	return (xs^2 + ys^2 <= 0.5^2)
}

registerDoParallel(makeCluster(detectCores() - 1))

for (rep in 1:restarts) {
	for (n in seq(100,1000,100)) {	
		for (k in seq(10,100,10)) {	
			time   <- system.time(in.circle <- foreach(i = 1:k, .combine = c) %dopar% f(n))[3]
			M      <- n * k
			pi.eval<- (sum(in.circle)/M) * 4
			diff   <- abs(pi.eval - eval_wolfram) / eval_wolfram
			result <- rbind(result, cbind(rep,n,k,M,time,pi.eval,diff))
		}
	}
}

stopImplicitCluster()

p1 <- 	wireframe(time ~ n * k, data = result,
		  xlab          = list("Iteraciones", rot = 35), 
		  ylab          = list("Tamaño de la muestra", rot = -35), 
		  zlab          = list("Tiempo (s)", rot = 94),
		  main          = "(a) Tiempo de ejecución de la simulación",
		  drape         = TRUE,
		  colorkey      = FALSE,
		  scales        = list(arrows=FALSE), # z = list(arrows=TRUE)),
		  screen        = list(z = 45, x = -60),
		  par.settings  = list(axis.line = list(col = "transparent")),
		  col.regions   = rev(heat.colors(100))
		)

p2 <- 	wireframe(diff ~ n * k, data = result,
		  xlab          = list("Iteraciones", rot = 20), 
		  ylab          = list("Tamaño de la muestra", rot = -19), 
		  zlab          = list("Desviación (%)", rot = 94),
		  main          = "(b) Desviación respecto el valor de Wolfram",
		  drape         = TRUE,
		  colorkey      = FALSE,
		  scales        = list(arrows=FALSE), # z = list(arrows=TRUE)),
		  screen        = list(z = 225, x = -60),
		  par.settings  = list(axis.line = list(col = "transparent")),
		  col.regions   = rev(heat.colors(100))
		)

png("img/P5_B.png", width = 14, height = 7, units = "in", res = 200)
grid.arrange(p1,p2, ncol = 2)
