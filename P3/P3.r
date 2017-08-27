#Project : Queueing theory
#Author  : Dago Quevedo
#Date    : Aug 2017

library(doParallel)

unlink("P3*.png")
unlink("P3*.gif")

args = commandArgs(trailingOnly = T)

if (length(args) > 0) {
    range_s = as.numeric(args[1])
    range_e = as.numeric(args[2])
    restart = as.numeric(args[3])
}

is_prime = function(n) {
	if (n == 1 || n == 2) {
    	return(T)
    }
	if (n %% 2 == 0) {
    	return(F)
	}
	for (i in seq(3, max(3, ceiling(sqrt(n))), 2)) {
    	if ((n %% i) == 0) {
        	return(F)
		}
    }
    return(T)
}

cpu_stats = function (core, cores) {
	sys_tx = system(sprintf("mpstat -P ALL | grep -A %d '%%usr' | tail -n %d | sed -n '{s/^ *//;s/ *$//;s/  */|/gp;};'", 
								cores + 1, cores), intern = TRUE)
	cnx_tx = textConnection(sys_tx)
	cpu_st = read.csv(cnx_tx, sep = "|", head = FALSE)

	close(cnx_tx)
		
	output = paste(	"P3_B",	
				   	formatC(core,width=2,format="d",flag="0"),
					formatC(r	,width=4,format="d",flag="0"), 
					".png",sep="")    
    png(output)
	barplot(cpu_st$V4, main = sprintf("CPU activity | Test using %d cores", core), 
			xlab = "Cores", ylab="CPU used (%)", ylim = c(0,50), 
			col=c("darkblue","red", "green", "yellow"))
	axis(1, at=seq(1, cores, by=1), 
    	labels=seq(1, cores, by=1))
		
	graphics.off()	
}

set_A = range_s:range_e	#1
set_B = range_e:range_s	#2
set_C = sample(set_A)	#3
set_D = sample(set_A)	#4
set_E = sample(set_A)	#5
result= data.frame()
cores = detectCores()

for(core in 1:cores) {
	cl = makeCluster(core)
	registerDoParallel(cl)
	
	for(r in 1:restart) {
		cpu_stats(core,cores)
		result = rbind(result, 	c(core, 1, system.time(foreach(n = set_A, .combine = c) %dopar% is_prime(n))[3]),	
								c(core, 2, system.time(foreach(n = set_B, .combine = c) %dopar% is_prime(n))[3]),
								c(core, 3, system.time(foreach(n = set_C, .combine = c) %dopar% is_prime(n))[3]),
								c(core, 4, system.time(foreach(n = set_D, .combine = c) %dopar% is_prime(n))[3]),
								c(core, 5, system.time(foreach(n = set_E, .combine = c) %dopar% is_prime(n))[3])
					  )
	}
	stopCluster(cl)
}

system(sprintf("convert -delay %d P3_B*.png P3_B.gif",10))
unlink("P3_B*.png")

png("P3_A.png",width = 3 * cores, height = 4, units = "in", res = 1200)
par(mfrow=c(1,cores))

for(core in 1:cores) {
	boxplot(result[result[,1] == core, 3] ~ result[result[,1] == core, 2], 
			main = sprintf("Number of cores: %d", core), xlab = "Set of jobs", ylab = "Time (s)", 
			ylim = c(min(result[,3]), max(result[,3]) * 0.75), xaxt = "n")
	axis(1, at=1:5, labels=toupper(letters[1:5]))	

}
graphics.off()

kruskal.test(result[, 3] ~ result[, 1])

