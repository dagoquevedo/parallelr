unlink("P4_B*.png")
unlink("P4_B*.gif")

n    = 400
k    = 12
seed = 0

cell =  function(pos,radius) {
    row = floor((pos - 1) / n) + 1
    col = ((pos - 1) %% n) + 1
    if (zone[row, col] > 0) {
        return(zone[row, col])
    } else {
        near = 0
        for (s in 1:seed) {
            dx 	 = col - x[s]
            dy 	 = row - y[s]
            dist = sqrt(dx^2 + dy^2)
            if(dist < radius - (s - 1)) {
                near = s
                break;
            }
        }
        return(near)
    }
}

zone = matrix(rep(0, n * n), nrow = n, ncol = n)
x    = rep(0, k)
y    = rep(0, k)

suppressMessages(library(doParallel))
registerDoParallel(makeCluster(detectCores()))

radius = 1

while(any(zone == 0) && radius < n) {
    if(seed < k) {
        seed = seed + 1
        while (T) {
            row = sample(1:n, 1)
            col = sample(1:n, 1)
            if (zone[row, col] == 0) {
                zone[row, col] = seed
                x[seed] = col
                y[seed] = row
                break;
            }
        }
    }   
        
    cells = foreach(p = 1:(n * n), .combine = c) %dopar% cell(p, radius)
    zone  = matrix(cells, nrow = n, ncol = n, byrow=TRUE)  
    
    output = paste("B",formatC(radius, width=4, format="d", flag="0"), ".png", sep="")    
    png(output)
    par(mar = c(0,0,0,0))
    image(zone, col=rainbow(k+1), xaxt='n', yaxt='n')
    graphics.off()
        
    radius = radius + 1
}


png("P4_B_01.png")
par(mar = c(0,0,0,0))
image(zone, col=rainbow(k+1), xaxt='n', yaxt='n')
graphics.off()


system(sprintf("convert -delay %d B*.png P4_B_%s.gif",10,'02'))
unlink("B*.png")

stopImplicitCluster()


#Grieta
	
#limit = n # grietas de que largo minimo queremos graficar
 
#start = function() {
#    sense = sample(1:4, 1)
#    xg 	  = NULL
#    yg 	  = NULL
	
#    if (sense == 1) {
#        xg = 1
#        yg = sample(1:n, 1)
#    } else if (sense == 2) {
#        xg = sample(1:n, 1)
#        yg = 1
#    } else if (sense == 3) {
#        xg = n
#        yg = sample(1:n, 1)
#    } else {
#        xg = sample(1:n, 1)
#        yg = n
#    }
#    return(c(xg, yg))
#}
	
#vp = data.frame(numeric(), numeric()) # posiciones de posibles vecinos
#for (dx in -1:1) {
#    for (dy in -1:1) {
#        if (dx != 0 | dy != 0) { # descartar la posicion misma
#            vp = rbind(vp, c(dx, dy))
#        }
#    }
#}
#names(vp) = c("dx", "dy")
#vc = dim(vp)[1]
    
	
#spread = function(replica) {
    # probabilidad de propagacion interna
#    prob 	  = 1
#    difficult = 0.99
#    fissure   = voronoi # marcamos la grieta en una copia
#    i 		  = start() # posicion inicial al azar
#    xg 		  = i[1]
#    yg 		  = i[2]
#    large 	  = 0
	
#    while (T) { # hasta que la propagacion termine
#        fissure[yg, xg] = 0 # usamos el cero para marcar la grieta
#        large =  large + 1
		
#        border = numeric()
#        inside = numeric()
		
#        for (v in 1:vc) {
#            neighbor = vp[v,]
#            xs = xg + neighbor$dx # columna del vecino potencial
#            ys = yg + neighbor$dy # fila del vecino potencial
#            if (xs > 0 & xs <= n & ys > 0 & ys <= n) { # no sale de la zone
#                if (fissure[ys, xs] > 0) { # aun no hay grieta ahi
#                    if (voronoi[yg, xg] == voronoi[ys, xs]) {
#                        inside = c(inside, v)
#                    } else { # frontera
#                        border = c(border, v)
#                    }
#                }
#            }
#        }
		
#        selection = 0
#        if (length(border) > 0) { # siempre tomamos frontera cuando haya
#            if (length(border) > 1) {
#                selection = sample(border, 1)
#            } else {
#                selection = border # sample sirve con un solo elemento
#            }
#            prob = 1 # estamos nuevamente en la frontera
#        } else if (length(inside) > 0) { # no hubo frontera para propagar
#            if (runif(1) < prob) { # intentamos en el difficultinterior
#                if (length(inside) > 1) {
#                    selection = sample(inside, 1)
#                } else {
#                    selection = inside
#                }
#                prob = difficult * prob # mas dificil a la siguiente
#            }
#        }
#        if (selection > 0) { # si se va a propagar
#            neighbor = vp[selection,]
#            xg = xg + neighbor$dx
#            yg = yg + neighbor$dy
#        } else {
#            break # ya no se propaga
#        }
#    }
#    if (large >= limit) {
#        png(paste("p4g_", replica, ".png", sep=""))
#        par(mar = c(0,0,0,0))
#        image(fissure, col=rainbow(k+1), xaxt='n', yaxt='n')
#        graphics.off()
#    }
#    return(large)
#}
	
#suppressMessages(library(doParallel))
#registerDoParallel(makeCluster(detectCores() - 1))
#larges = foreach(r = 1:200, .combine=c) %dopar% spread(r)
#stopImplicitCluster()
#summary(larges)





