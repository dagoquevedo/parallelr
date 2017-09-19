#Project : Multi-agent system (MAS)
#Author  : Dago Quevedo
#Date    : Sep 2017

suppressMessages(library(doParallel))
library(ggplot2)

unlink("img/*.png")
unlink("img/*.gif")

args = commandArgs(trailingOnly = T)

if (length(args) > 0) {
	restarts = as.numeric(args[1]) 
	pi_min   = as.numeric(args[2])
    pi_max   = as.numeric(args[3])
    pv_min   = as.numeric(args[4])
    pv_max   = as.numeric(args[5])
    is.plot  = as.logical(args[6])    
}

pr   = 0.02
r    = 0.10
l    = 1.5
n    = 50
v    = l / 30
tmax = n * 2

initialization = function(pi, pv) {
    e = "S"
    if (runif(1) < pv) {
        e = "R"
    } else if (runif(1) < pi) {
        e = "I"
    }
    
    agent = data.frame( x  = runif(1, 0, l), y  = runif(1, 0, l),
                        dx = runif(1,-v, v), dy = runif(1,-v, v),
                        state = e)
    return(agent)
}

infections = function(i, pr) {
    infected = F
    a = agents[i, ]
    if (a$state == "S") {
        for (j in 1:n) {
            b = agents[j, ]
            if (b$state == "I") {
                dx = a$x - b$x
                dy = a$y - b$y
                d  = sqrt(dx^2 + dy^2)
                if (d < r) {
                    pc = (r - d) / r
                    if (runif(1) < pc) {
                        infected = T
                    }
                }
            }
        }
    }
    
    if (infected) {
        a$state = "I"
    } else if (a$state == "I") {
        if (runif(1) < pr) {
            a$state = "R"
        }
    }
        
    a$x = a$x + a$dx
    a$y = a$y + a$dy

    if (a$x > l) a$x = a$x - l
    if (a$y > l) a$y = a$y - l
    if (a$x < 0) a$x = a$x + l
    if (a$y < 0) a$y = a$y + l

    return(a)
}
        
plot.1 = function(t, A) {
    aS = A[A$state == "S",]
    aI = A[A$state == "I",]
    aR = A[A$state == "R",]

    sT = formatC(t, width=3, format="d",flag="0")
    output = paste("img/P6_1_",sT,".png", sep="")
    png(output, width = 6, height = 6, units = "in", res = 150)

    plot(l, type="n", main = sprintf("Período: %s ", sT), xlim=c(0, l), ylim=c(0, l), xlab="x", ylab="y")
    mtext(bquote(p[i]: ~ .(sprintf("%.2f",pi)) ~ " | " ~ 
                 p[v]: ~ .(sprintf("%.2f",pv)) ~ " | " ~ 
                 p[r]: ~ .(sprintf("%.2f",pr))))

    if (dim(aS)[1] > 0) {
        points(aS$x, aS$y, pch=15, col="chartreuse3", bg="chartreuse3")
    }
    if (dim(aI)[1] > 0) {
        points(aI$x, aI$y, pch=16, col="firebrick2", bg="firebrick2")
    }
    if (dim(aR)[1] > 0) {
        points(aR$x, aR$y, pch=17, col="goldenrod", bg="goldenrod")
    }
    graphics.off()
}
        
plot.2 = function(B) {
	png("img/P6_2.png", width = 7, height = 5, units = "in", res = 200)	
	g <- 	ggplot(B, aes(x = t)) +
			stat_smooth(aes(x = t, y = 100 * S / n, colour="S"), se = F, method = "lm", 
						formula = y ~ poly(x, 10),size = 0.5) + 
			stat_smooth(aes(x = t, y = 100 * I / n, colour="I"), se = F, method = "lm", 
						formula = y ~ poly(x, 10), size = 0.5) +
			stat_smooth(aes(x = t, y = 100 * R / n, colour="R"), se = F, method = "lm", 
						formula = y ~ poly(x, 10), size = 0.5) +
			labs(title = "Simulación de la propagación de la infección", 
				subtitle = sprintf("Agentes: %d | Períodos: %d", n, tmax)) + theme_bw() + xlab("Período") + ylab("Porcentaje de agentes") + 
			theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5)) +
			scale_color_manual("Estado",values=c("S"="chartreuse3", "I"="firebrick2","R"="goldenrod"))

	print(g)
	graphics.off()
}

        
#### main ####
max.infecteds = data.frame(r = double(), pi = double(), pv = double(), val = double(), pct = double(), max.t = double())
agents 		  = data.frame(x = double(), y = double(), dx = double(), dy = double(), state  = character())
		
registerDoParallel(makeCluster(detectCores() - 1))

for (rep in 1:restarts) {
	print(rep)
	for(pi in seq(pi_min,pi_max,0.05)) {
		for(pv in seq(pv_min,pv_max,0.05)) {
			agents   = foreach(i = 1:n, .combine = rbind) %dopar% initialization(pi, pv)
			epidemic = data.frame(t= double(), S = double(), I = double(), R = double())

			for (t in 1:tmax) {
				aS 		  <- dim(agents[agents$state == "S",])[1]
				aI 		  <- dim(agents[agents$state == "I",])[1]
				aR 		  <- dim(agents[agents$state == "R",])[1]
				epidemic  <- rbind(epidemic, cbind(t = t, S = aS, I = aI, R = aR))

				if (aI == 0) {
					break;
				}

				agents = foreach(i = 1:n, .combine = rbind) %dopar% infections(i, pr)
				if(is.plot) {
					plot.1(t, agents)
				}
			}

			if(is.plot) {
				plot.2(epidemic)
				system(sprintf("convert -delay %d img/P6_1*.png img/P6_1.gif", 15))
				unlink("img/P6_1*.png")
			}

			max.infecteds = rbind(max.infecteds, cbind(r = rep, pi = pi, pv = pv, val =  max(epidemic$I), pct = 100 * max(epidemic$I)/n, t.max = which.max(epidemic$I)))
		}
	}
}

write.csv(max.infecteds,file="data.txt")
		
stopImplicitCluster()

avg.infecteds = aggregate(pct ~ pi + pv, max.infecteds, mean)		
avg.tmax 	  = aggregate(t.max ~ pi + pv, max.infecteds, mean)		

png("img/P6_3.png", width = 7, height = 5, units = "in", res = 200)

ggplot(data = avg.infecteds, aes(x = pi, y = pv)) +
	  geom_tile(aes(fill = pct)) + 
	  scale_fill_gradientn(colours = rev(heat.colors(256)), name = "Porcentaje") + 
	  xlab(bquote("Probabilidad de infección inicial " ~ (p[i])))+ylab(bquote("Probabilidad de vacunación " ~ (p[v]))) +
				labs(title = "Efecto en el máximo porcentaje de agentes infectados", 
					 subtitle = sprintf("Agentes: %d | Períodos: %d", n, tmax)) +
				theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5)) + 
				scale_x_continuous(breaks = seq(min(avg.infecteds$pi), max(avg.infecteds$pi), by = 0.05)) +
				scale_y_continuous(breaks = seq(min(avg.infecteds$pv), max(avg.infecteds$pv), by = 0.05))
graphics.off()
		
png("img/P6_4.png", width = 7, height = 5, units = "in", res = 200)

ggplot(data = avg.tmax, aes(x = pi, y = pv)) +
	  geom_tile(aes(fill = t.max)) + 
	  guides(fill=guide_legend(title="Períodos")) + 
	  xlab(bquote("Probabilidad de infección inicial " ~ (p[i])))+ylab(bquote("Probabilidad de vacunación " ~ (p[v]))) +
				labs(title = "Efecto en el período con máximo porcentaje de agentes infectados", 
					 subtitle = sprintf("Agentes: %d | Períodos: %d", n, tmax)) +
				theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5)) + 
				scale_x_continuous(breaks = seq(min(avg.infecteds$pi), max(avg.infecteds$pi), by = 0.05)) +
				scale_y_continuous(breaks = seq(min(avg.infecteds$pv), max(avg.infecteds$pv), by = 0.05))
graphics.off()
