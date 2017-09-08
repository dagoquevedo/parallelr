## Introducción

Los diagramas de Voronoi [\[1,2\]](#bibliograf%C3%ADa) se encuentran entre las más importantes estructuras en la geometría computacional, este codifica la información de proximidad entre los elementos. Sea <img src="https://latex.codecogs.com/gif.latex?P=\{p_1,\dots,p_n\}"/> un conjunto de puntos en el plano (o en cualquier espacio <img src="https://latex.codecogs.com/gif.latex?d"/>-dimensional), los cuales llamaremos celda. Definimos como <img src="https://latex.codecogs.com/gif.latex?\mathcal{V}(p_i)"/>, la celda de Voronoi para <img src="https://latex.codecogs.com/gif.latex?p_i"/>, como el conjunto de puntos ![f2] en el plano que están más cerca de <img src="https://latex.codecogs.com/gif.latex?p_i"/> que de cualquier otro sitio. Es decir la celda de Voronoi se define por

<p align="center">
<img src="https://latex.codecogs.com/gif.latex?\mathcal{V}(p_i)&space;=&space;\{k:&space;\left&space;\|&space;p_i&space;-&space;k&space;\right&space;\|&space;<&space;\left&space;\|&space;p_j&space;-&space;k&space;\right&space;\|,&space;\forall&space;j\neq&space;i&space;\}"/>,
</p>

donde <img src="https://latex.codecogs.com/gif.latex?\left\|p_i-k\right\|"/> denota la distancia euclídea entre los puntos <img src="https://latex.codecogs.com/gif.latex?p_i"/> y ![f2]. Si bien el diagrama de Voronoi puede definirse sobre cualquier métrica y en cualquier dimensión, en esta práctica nos enfocaremos en el caso planar y Euclidiano, donde se representará la zona por una matriz <img src="https://latex.codecogs.com/gif.latex?n\times&space;n"/> y las coordenadas serán entonces números enteros en <img src="https://latex.codecogs.com/gif.latex?\[1,n\]"/>.

## Objetivo

El objetivo principal de esta práctica es el análisis sistemático del efecto que el número de semillas y el tamaño de la zona tienen en la distribución de los largos de las grietas. Adicional a lo anterior:

1. Esparcir las ![f2] semillas con otra distribuciones probabilística y examinar el efecto que tiene cada una de ellas en la asignación de las celdas.
2. Lograr el efecto de crecimiento de las celdas alrededor de las semillas que aparecen en distintos momentos y examinar los cambios producidos en el fenómeno de propagación de grietas.

## Experimentación
### Diseño

El siguiente segmento de código [\[3\]](#bibliograf%C3%ADa) codificado en R, es la función que define la celda de Voronoi para cada celda <img src="https://latex.codecogs.com/gif.latex?p_i"/>, definida en este caso por el parámetro `pos`:

```
cell =  function(pos) {
    row = floor((pos - 1) / n) + 1
    col = ((pos - 1) %% n) + 1
    if (zone[row, col] > 0) {
        return(zone[row, col])
    } else {
        near = 0
        dmin = n * sqrt(2)
        for (seed in 1:k) {
            dx 	 = col - x[seed]
            dy 	 = row - y[seed]
            dist = sqrt(dx^2 + dy^2)
            if (dist < dmin) {
                near = seed
                dmin = dist
            }
        }
        return(near)
    }
}
```

A continuación se establecen las condiciones de diseño y definición de experimentos para satisfacer los objetivos y  analizar los resultados de esta práctica.

* Para analizar el efecto del número de semillas ![f2] y el tamaño de la zona dada por ![f1], se establece entonces tamaños de <img src="https://latex.codecogs.com/gif.latex?n\in\[50,200]"/> discretizado a 50 unidades y <img src="https://latex.codecogs.com/gif.latex?k\in\[4,12]"/> discretizado a 4 unidades. El experimento es entonces una serie de ejecuciones con las posibles combinaciones de los conjuntos discretizados ![f1] y ![f2] cómo parámetros. Se realiza un análisis estadístico para reafirmar las conclusiones empíricas.

* Se utilizan tres distribuciones probabilísticas para esparcir las ![f2] semillas en el plano cartesiano: (a), Distribución de Poisson con un <img src="https://latex.codecogs.com/gif.latex?\lambda=n/2"/>. (b) Distribución Binomial con un tamaño <img src="https://latex.codecogs.com/gif.latex?l=n/4"/>, y una probabilidad <img src="https://latex.codecogs.com/gif.latex?x=50\%"/>, (c) Distribución normal, la cual queda implicita con el uso de la función `sample`. Se realiza una única ejecución por cada distribución con <img src="https://latex.codecogs.com/gif.latex?k=12"/> y <img src="https://latex.codecogs.com/gif.latex?n=300"/>.

* Para lograr el efecto de crecimiento de las celdas alrededor de las semillas se modifica la definición de la celda de Voronoi de tal manera que contemple un radio <img src="https://latex.codecogs.com/gif.latex?r_k"/> para cada semilla ![f2] por lo que cada <img src="https://latex.codecogs.com/gif.latex?p_i"/> que estén dentro de este radio se asigne a una semilla ![f2]. se realiza una única ejecución con <img src="https://latex.codecogs.com/gif.latex?k=12"/> y <img src="https://latex.codecogs.com/gif.latex?n=400"/>. La celda de Voronoi se define ahora como sigue

<p align="center">
<img src="https://latex.codecogs.com/gif.latex?\mathcal{V}(p_i)&space;=&space;\{k:&space;\left&space;\|&space;p_i&space;-&space;k&space;\right&space;\|&space;<&space;r_k,&space;\forall&space;j\neq&space;i&space;\}"/>.
</p>

### Condiciones computacionales

Se hace uso de una instancia SO Linux (Ubuntu 16.04) 64-bits, con procesador Intel (R) Core (TM) i7-5600U CPU @ 2.60 GHz y 12 GB de memoria RAM con 2 núcleos y 4 procesadores lógicos. La aplicación se ha codificado en R, haciendo uso del paquete `doParallel` [\[4\]](#bibliograf%C3%ADa) que incluye la función `foreach`.

## Resultados

La Figura 1 muestra la comparación del tamaño de las grietas generadas para cada combinación <img src="https://latex.codecogs.com/gif.latex?(n,k)"/>. Se observa que el tamaño de la matriz si tiene un efecto en el tamaño de las grietas más no así el número de semillas distribuidas, en este caso bajo una distribución normal.

<p align="center">
<img src="https://github.com/dagoquevedo/parallelr/blob/master/P4/img/P4_A_04.png"/>
<b>Figura 1.</b> Comparación de largo de las grietas respecto al tamaño del la matriz y número de semillas.
</p>

Para confirmar las conclusiones del análisis gráfico se procede a realizar un análisis estadístico, formulando las siguientes hipótesis alternativas, ![f4]: El tamaño de la matriz dado por <img src="https://latex.codecogs.com/gif.latex?n"/> tiene un efecto sobre el tamaño de las grietas. ![f5]: El número de semillas dado por ![f2] tiene un efecto sobre el tamaño de las grietas. Bajo la posibilidad de que la distribución de la muestra no cumpla con las condiciones de normalidad, se opta por usar una prueba no paramétrica de Kruskal-Wallis [\[5\]](#bibliograf%C3%ADa). Se establece un nivel de significancia ![f6]. La tabla 1 muestra el resultado de este análisis.

<b>Tabla 1</b>. Resultados de la prueba de Kruskal-Wallis 

| Hipótesis | <i>p</i>-valor |
| :---:  | :--- |
| ![f4] | 1.338e-08 |
| ![f5] | 0.3038763 |

En el caso de la hipótesis alternativa ![f4], el <i>p</i>-valor que se obtiene es lo suficientemente menor respecto el nivel de significancia ![f6], por lo que se rechaza la hipótesis nula y se acepta la hipótesis alternativa. Por el contrario la hipótesis alternativa ![f5] se rechaza, al obtener un valor de <i>p</i>-valor mayor al nivel de significancia. Por lo anterior, los resultados estadísticos confirman el análisis gráfico del experimento.

La siguiente imagen muestra la generación de un diagrama de Voronoi con una selección de las semillas bajo una distribución normal en un espacio <img src="https://latex.codecogs.com/gif.latex?n\times&space;n"/>.
<p align="center">
<img src="https://github.com/dagoquevedo/parallelr/blob/master/P4/img/P4_A_02_1.png" height="40%" width="40%"/><br>
<b>Figura 2.</b> Diagrama de Voronoi con semillas esparcidas bajo una distribución Normal.
</p>

La siguiente imagen muestra la generación de un diagrama de Voronoi con una selección de las semillas bajo una distribución de Poisson en un espacio <img src="https://latex.codecogs.com/gif.latex?n\times&space;n"/>. Se observa como las semillas están distribuidas uniformemente en el área central de la matriz, lo que ocasiona un efecto de embudo en la figura resultante.
 
<p align="center">
<img src="https://github.com/dagoquevedo/parallelr/blob/master/P4/img/P4_A_02_2.png" height="40%" width="40%"/><br>
<b>Figura 3.</b> Diagrama de Voronoi con semillas esparcidas bajo una distribución de Poisson.
</p>

La Figura 4 muestra una animación de crecimiento de las celdas alrededor de las semillas, las cuales aparecen en momentos distintos durante la ejecución.

<p align="center">
<img src="https://github.com/dagoquevedo/parallelr/blob/master/P4/img/P4_B_02.gif" height="40%" width="40%"/><br>
<b>Figura 4.</b> Diagrama de Voronoi con un crecimiento de las celdas alrededor de las semillas.
</p>


## Conclusiones
A partir de la evidencia empírica y estadística mostrada en los resultados de la generación de diagramas de Voronoi, se concluye lo siguiente:

1. El tamaño de la matriz tiene un efecto en el largo de las grietas. Esto tiene sentido dado que a un mayor espacio en <img src="https://latex.codecogs.com/gif.latex?n\times&space;n"/> las grietas tienden a tener un mayor espacio de dispersión.

2. El número de semillas no tiene un efecto en el largo de las grietas. Esto puede deberse a que independientemente del número de semillas, se generarán fronteras entre estas, lo que da espacio una potencial propagación de una grieta.

#### Bibliografía
1. M. Berg, O. Cheong, M.V. Kreveld and M. Overmars. <i>Computational Geometry: Algorithms and Applications</i>. Springer, 3ra edición, 2008.
2. E.A. Rodríguez Tello. Diagramas de Voronoi, <i>Notas de clase</i>, Cinvestav, 2013, [\[url\]](http://www.tamps.cinvestav.mx/~ertello/gc/sesion16.pdf).
3. S.E. Schaeffer. Práctica 4: Diagramas de Voronoi, <i>R paralelo: simulación & análisis de datos</i>, [\[url\]](http://elisa.dyndns-web.com/teaching/comp/par/p4.html).
4. R. Calaway, S. Weston, D. Tenenbaum. Foreach Parallel Adaptor for the 'parallel' Package. <i>R Package</i>, [\[url\]](https://cran.r-project.org/web/packages/doParallel/doParallel.pdf).
5. W.H. Kruskal y W.A. Wallis. Use of ranks in one-criterion variance analysis. <i>Journal of the American Statistical Association</i>, 47(260): 583-621, 1952.

[f1]: https://latex.codecogs.com/gif.latex?n
[f2]: https://latex.codecogs.com/gif.latex?k
[f4]: https://latex.codecogs.com/gif.latex?H_a
[f5]: https://latex.codecogs.com/gif.latex?H_b
[f6]: https://latex.codecogs.com/gif.latex?\alpha=5\\%
