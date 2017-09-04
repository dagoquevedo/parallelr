#Project : Voronoi (II)
#Author  : Dago Quevedo
#Date    : Sep 2017

unlink("img/P4_B*.png")
unlink("img/P4_B*.gif")

args = commandArgs(trailingOnly = T)

if (length(args) > 0) {
	n = as.numeric(args[1])
	k = as.numeric(args[2])
}

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


png("img/P4_B_01.png")
par(mar = c(0,0,0,0))
image(zone, col=rainbow(k+1), xaxt='n', yaxt='n')
graphics.off()


system(sprintf("convert -delay %d B*.png P4_B_%s.gif",10,'02'))
unlink("img/B*.png")

stopImplicitCluster()
