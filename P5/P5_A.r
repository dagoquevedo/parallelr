#Project : Montecarlo Simulation - Integral
#Author  : Dago Quevedo
#Date    : Sep 2017

suppressMessages(library(distr))
suppressMessages(library(doParallel))
library(lattice)
library(gridExtra)

unlink("img/P5_A*.png")

args = commandArgs(trailingOnly = TRUE)

if (length(args) > 0) {
    restarts  = as.numeric(args[1])
}

f_min = -6
f_max = -f_min
f_stp = 0.25
f_min = 3
f_max = 7
x 	  = seq(f_min, f_max, f_stp)

eval_wolfram <- 0.048834111126049310840642372201942674973116537010624099836
result       <- data.frame()

f = function(x) { 
	return(1 / (exp(x) + exp(-x))) 
}

g = function(x) { 
	return((2 / pi) * f(x))
}

gen = r(AbscontDistribution(d = g))

setgen = function(size) {
    set = gen(size)
    return(sum(set >= f_min & set <= f_max))
}

registerDoParallel(makeCluster(detectCores() - 1))

for (rep in 1:restarts) {
	for (n in seq(500,5000,500)) {	
		for (k in seq(100,1000,100)) {	
			time   = system.time(sim <- foreach(i = 1:k, .combine=c) %dopar% setgen(n))[3]	
			M      = n * k
            g_x    = sum(sim) / M
			in.eval = (pi / 2) * g_x
			diff   = abs(in.eval - eval_wolfram) / eval_wolfram
			result = rbind(result, cbind(rep,n,k,M,time,in.eval,diff))
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

png("img/P5_A.png", width = 14, height = 7, units = "in", res = 200)
grid.arrange(p1,p2, ncol = 2)
