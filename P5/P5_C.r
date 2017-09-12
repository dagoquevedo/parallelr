#Project : Montecarlo Simulation - Forecast
#Author  : Dago Quevedo
#Date    : Sep 2017

unlink("img/P5_C*.png")
unlink("img/P5_C*.gif")

suppressMessages(library(doParallel))
suppressMessages(library(forecast))
library(ggplot2)
library(grid)

accuracy = function(exp,result) {
	sum_mape    <- 0
	sum_wmape_1 <- 0
	sum_wmape_2 <- 0
	n			<- 0

	for(i in 1:length(result)) {
		if(exp[i] > 0) {
			n = n +1
			sum_mape    <- sum_mape + abs((exp[i] - result[i]) / exp[i])
			sum_wmape_1 <- sum_wmape_1 + abs((exp[i] - result[i]) / exp[i]) * exp[i]
			sum_wmape_2 <- sum_wmape_2 + exp[i]
	  	}
	}

	MAPE  <- sum_mape/n
	WMAPE <- sum_wmape_1/sum_wmape_2
	
	return(c(MAPE, WMAPE))
}


method_1 = function(data, N, M)	{	
	gen.set = function(size, d.mean, d.sdev, lower, upper) {
	  set <- rnorm(size * 3, mean = d.mean, sd = d.sdev)
	  set <- set[set >= lower & set <= upper]
	  return(sample(set, size))
	}
	
	data.mean <- mean(data)
	data.sdev <- sd  (data)
	data.min  <- min (data)
	data.max  <- max (data)
	result    <- data.frame()

	for(f in 1:M) {
	 	S 		<- foreach(i = 1:M, .combine = c) %dopar% gen.set(N, data.mean, data.sdev, data.min, data.max)
		valor   <- ceiling(mean(S))
	  	result  <- rbind(result,cbind(valor))
	}
	
	return(result)
}


method_2 = function(data, N, M) {
	serie.ts <- ts(data, frequency = 1)
	fit		 <- auto.arima(serie.ts)
	result 	 <- data.frame()

	S <- foreach(i = 1:N, .combine = rbind, .packages = "forecast") %dopar% {
			simulate(fit, M)
		}
	
	for(i in 1:M) {
		valor  <- ceiling(mean(S[,i], na.rm = T))
		result <- rbind(result, cbind(valor))
	}
	
	return(result)
}

data      <- read.csv("dat/zika.csv", header=TRUE, sep=",")
data.fcs  <- data[data$expo == 0, ]
data.exp  <- data[data$expo == 1, ]

cl = makeCluster(detectCores() - 1)
registerDoParallel(cl)

M = length(data.exp$valor)

for(N in c(50,100,1000,5000,10000)) {
	result.method.1 <- method_1(data.fcs$valor, N, M)
	result.method.2 <- method_2(data.fcs$valor, N, M)
	ac1 			<- accuracy(data.exp$valor, result.method.1$valor)
	ac2 			<- accuracy(data.exp$valor, result.method.2$valor)
	
	ac <- data.frame()
	ac <- rbind(ac, cbind(metodo = "Modelo 1", val = round(ac1[2] * 100), accuracy = "WMAPE"))
	ac <- rbind(ac, cbind(metodo = "Modelo 2", val = round(ac2[2] * 100), accuracy = "WMAPE"))
	
	ac$val = as.double(levels(ac$val))[ac$val]
	
	df <- data.frame()
	df <- rbind(df, data.frame(x = rep(1:M), y = data.exp$valor		  , Variable = "Real"))
	df <- rbind(df, data.frame(x = rep(1:M), y = result.method.1$valor, Variable = "Modelo 1"))
	df <- rbind(df, data.frame(x = rep(1:M), y = result.method.2$valor, Variable = "Modelo 2"))

	output = paste("img/P5_C",formatC(N,width=4,format="d",flag="0"),".png",sep="")  
	png(output, width = 10, height = 4, units = "in", res = 200)
	
	grid.newpage()
	pushViewport(viewport(layout = grid.layout(1, 2)))
	
	plot1 = ggplot(data = df, aes(x = x, y = y)) + geom_line(aes(colour=Variable)) + 
			labs(x = "Semana", y = "Casos") + 
			labs(title = "Resultado de la simulación", subtitle = sprintf("Tamaño de muestra: %d", N)) +
			theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5)) +
			ylim(-5, 80)
	
	plot2 = ggplot(data =ac , aes(x = metodo, y = val, fill = as.factor(accuracy)))+
			geom_bar(stat="identity",position="dodge") +  
			xlab("Modelo")+ylab("Valor de evaluación (%)") +
			labs(title = "Acertividad del pronóstico", subtitle = sprintf("Tamaño de muestra: %d", N)) +
			theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5)) +
			scale_fill_discrete(name = "Evaluación") +
			ylim(-5, 200)
	
	print(plot1, vp = viewport(layout.pos.row = 1, layout.pos.col = 1))
	print(plot2, vp = viewport(layout.pos.row = 1, layout.pos.col = 2))
	if(!is.null(dev.list())) dev.off()
}

stopCluster(cl)

system(sprintf("convert -delay %d img/P5_C*.png img/P5_C.gif",100))
unlink("img/P5_C*.png")

