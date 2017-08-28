## Introducción
La teoría de colas es una área de las matemáticas dentro de la investigación de operaciones que estudia el comportamiento de las líneas de espera. En el campo computacional de nuestro interés, se relaciona con la asignación y el ordenamiento de las tareas a un determinado núcleo del CPU de tal manera de minimizar el tiempo total de ejecución de las tareas, este problema de ordenamiento se denomina programación de tareas (<i>scheduling</i>), teniendo la particularidad de ser en tiempo real (<i>Real-time scheduling problem</i>)[1,2].

## Objetivo
El objetivo principal de esta práctica es el análisis sistemático de las diferencias en los tiempos de ejecución dada una ordenación de tareas y un número de núcleos disponibles. En específico: 

1. Analizar las diferencias en los tiempos de ejecución cuando varia el ordenamientos de las tareas y el número de núcleos habilitados en el <i>cluster</i>; argumentar con un sustento gráfico las posibles causas de estas diferencias.

2. Diseñar una prueba estadísticas para determinar: (a) si las diferencias observadas respecto al número de núcleos habilitados en el </i>cluster</i> son significativas; (b) si las diferencias observadas respecto los ordenamiento de las tareas son significativas.

## Experimentación
### Condiciones experimentales
La operación a evaluar es la determinación de si un número entero <a href="https://www.codecogs.com/eqnedit.php?latex=n" target="_blank"><img src="https://latex.codecogs.com/gif.latex?n" title="n" /></a>, es o no un número primo. El algoritmo base codificado en R es el siguiente [5]:

```
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
```
Como puede deducirse, el número de operaciones requeridas esta en función del numero entero <a href="https://www.codecogs.com/eqnedit.php?latex=n" target="_blank"><img src="https://latex.codecogs.com/gif.latex?n" title="n" /></a>; para determinar la primalidad de <a href="https://www.codecogs.com/eqnedit.php?latex=n" target="_blank"><img src="https://latex.codecogs.com/gif.latex?n" title="n" /></a>, el mayor factor primo que se necesita no es mayor que <a href="https://www.codecogs.com/eqnedit.php?latex=\sqrt(n)" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\sqrt(n)" title="\sqrt(n)" /></a>, por lo cual el número de candidatos a factor primo es aproximadamente:

<p align="center">
<a href="https://www.codecogs.com/eqnedit.php?latex=\frac{n}{\ln\sqrt(n)-1}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\frac{n}{\ln\sqrt(n)-1}" title="\frac{n}{\ln\sqrt(n)-1}" /></a>,
</p>

esta expresión crece cada vez más lentamente en función de <a href="https://www.codecogs.com/eqnedit.php?latex=n" target="_blank"><img src="https://latex.codecogs.com/gif.latex?n" title="n" /></a>. Para el experimento, se establecen diferentes ordenamientos de números enteros a partir de un conjunto ordenado inicial <a href="https://www.codecogs.com/eqnedit.php?latex=\mathbb{Q}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\mathbb{Q}" title="\mathbb{Q}" /></a>, definido por:

<p align="center">
<a href="https://www.codecogs.com/eqnedit.php?latex=\mathbb{Q}=\left&space;\{a,\dots,&space;b&space;\right&space;\}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\mathbb{Q}=\left&space;\{a,\dots,&space;b&space;\right&space;\}" title="\mathbb{Q}=\left \{a,\dots, b \right \}" /></a>,
</p>

donde <a href="https://www.codecogs.com/eqnedit.php?latex=a" target="_blank"><img src="https://latex.codecogs.com/gif.latex?a" title="a" /></a> y <a href="https://www.codecogs.com/eqnedit.php?latex=b" target="_blank"><img src="https://latex.codecogs.com/gif.latex?b" title="b" /></a> son el inicio y el final del conjunto ordenado respectivamente, y <a href="https://www.codecogs.com/eqnedit.php?latex=a,b>&space;0" target="_blank"><img src="https://latex.codecogs.com/gif.latex?a,b>&space;0" title="a,b> 0" /></a>, <a href="https://www.codecogs.com/eqnedit.php?latex=n\in\mathbb{Q}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?n\in\mathbb{Q}" title="n\in\mathbb{Q}" /></a>. En este caso se utilizo una muestra a evaluar de 5,000 números enteros, entre los rangos 10,000 y 15,000. La siguiente tabla muestra los cinco conjuntos creados a partir de realizar variaciones en el ordenamiento del conjunto inicial <a href="https://www.codecogs.com/eqnedit.php?latex=\mathbb{Q}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\mathbb{Q}" title="\mathbb{Q}" /></a>.

| Conjunto| Ordenamiento        |
| :---:   |     :---            |
| A   | Ascendente              |
| B   | Descendente             |
| C   | Aleatorio               |
| D   | Aleatorio               |
| E   | Aleatorio               |

El experimento consiste en determinar para cada número entero (en el orden de cada conjunto) si es o no un número primo, usando el algoritmo `is_prime`, variando en cada ejecución el número de núcleos habilitados en el <i>cluster</i> y realizando 30 repeticiones de la totalidad del experimento. En cada ejecución, se genera una tupla con la siguiente estructura `(core, conjunto, tiempo)`.

### Condiciones computacionales
Se hace uso de una instancia SO Linux (Ubuntu 16.04) 64-bits, con procesador Intel (R) Core (TM) i7-5600U CPU @ 2.60 GHz y 12 GB de memoria RAM con 2 núcleos y 4 procesadores lógicos. La aplicación se ha codificado en R, haciendo uso del paquete `doParallel` [4] que incluye la función `foreach`, la cual permite la ejecución paralela de los procesos a partir de la declaración de un <i>cluster</i> con <a href="https://www.codecogs.com/eqnedit.php?latex=k" target="_blank"><img src="https://latex.codecogs.com/gif.latex?k" title="k" /></a> núcleos activos.

### Resultados
La Figura 1 representa el resultado de la ejecución con 30 repeticiones, divido por el número de núcleos disponibles. La tendencia que se muestra es la de un decrecimiento en los tiempo de computo conforme se incrementa el número de núcleos disponibles en el <i>cluster</i>, siendo esta tendencia menor entre el incremento de 3 a 4.

<p align="center">
  <img src="https://github.com/dagoquevedo/parallelr/blob/master/P3/P3_A.png"/><br>
  <b>Figura 1.</b> Variación del tiempo en función de los núcleos habilitados y el ordenamiento del conjunto.
</p>

Sin embargo, no se visualiza un efecto relevante en el tiempo de computo entre los diferentes conjuntos de prueba. La Figura 2(a) despliega una comparación del tiempo en función del número de núcleos habilitados. Se aprecia nuevamente el efecto positivo que tiene el incremento de núcleos durante el procesamiento de tareas. La Figura 2(b) despliega una comparación del tiempo en función de los conjuntos de prueba, se aprecia como el tipo de ordenamiento no tiene un efecto relevante en el tiempo de computo.
 
<p align="center">
  <img src="https://github.com/dagoquevedo/parallelr/blob/master/P3/P3_C.png"/><br>
  <b>Figura 2.</b> Variación del tiempo en función de los núcleos habilitados y el ordenamiento del conjunto.
</p>

La Figura 3 muestra la actividad de los núcleos durante la ejecución de la experimentación. La lectura de las estadísticas del CPU fue posible usando el comando `mpstat`. Conforme se agregan más núcleos al <i>cluster</i> la actividad del CPU se incrementa, pero logra mantener un balanceo de cargas entre los núcleos habilitados.

<p align="center">
  <img src="https://github.com/dagoquevedo/parallelr/blob/master/P3/P3_B.gif"/><br>
  <b>Figura 3.</b> Actividad de los núcleos del CPU durante la ejecución del experimento.
</p>

Para confirmar las conclusiones del análisis gráfico se procede a realizar un análisis estadístico, formulando las siguientes hipótesis alternativas, <a href="https://www.codecogs.com/eqnedit.php?latex=H_a" target="_blank"><img src="https://latex.codecogs.com/gif.latex?H_a" title="H_a" /></a>: El número de núcleos disponibles tiene un efecto significativo en el tiempo de computo. <a href="https://www.codecogs.com/eqnedit.php?latex=H_b" target="_blank"><img src="https://latex.codecogs.com/gif.latex?H_b" title="H_b" /></a>: El ordenamiento del conjunto de números enteros tiene un efecto significativo en el tiempo de computo. Bajo la posibilidad de que la distribución de la muestra no cumpla con las condiciones de normalidad, se opta por usar una prueba no paramétrica de Kruskal-Wallis [3]. Se establece un nivel de significancia <a href="https://www.codecogs.com/eqnedit.php?latex=\alpha&space;=&space;5\%" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\alpha&space;=&space;5\%" title="\alpha = 5\%" /></a>. La siguiente tabla muestra el resultado de este análisis.

| Hipótesis | <i>p</i>-value |
| :---:  | :--- |
| <a href="https://www.codecogs.com/eqnedit.php?latex=H_b" target="_blank"><img src="https://latex.codecogs.com/gif.latex?H_a" title="H_a" /></a> | 2.45e-16 |
| <a href="https://www.codecogs.com/eqnedit.php?latex=H_b" target="_blank"><img src="https://latex.codecogs.com/gif.latex?H_b" title="H_b" /></a> | 0.148234 |

En el caso de la hipótesis alternativa <a href="https://www.codecogs.com/eqnedit.php?latex=H_b" target="_blank"><img src="https://latex.codecogs.com/gif.latex?H_a" title="H_a" /></a>, el <i>p</i>-value que se obtiene es lo suficientemente menor respecto el nivel de significancia <a href="https://www.codecogs.com/eqnedit.php?latex=\alpha&space;=&space;5\%" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\alpha&space;=&space;5\%" title="\alpha = 5\%" /></a>, por lo que se rechaza la hipótesis nula y se acepta la hipótesis alternativa. Por el contrario la hipótesis alternativa <a href="https://www.codecogs.com/eqnedit.php?latex=H_b" target="_blank"><img src="https://latex.codecogs.com/gif.latex?H_b" title="H_b" /></a> se rechaza, al obtener un valor de <i>p</i>-value mayor al nivel de significancia. Por lo anterior, los resultados estadísticos confirman el análisis gráfico del experimento.

## Conclusiones
A partir de la evidencia empírica y estadística mostrada en los resultados, se puede concluir lo siguiente:

1. El número de núcleos habilitados en el <i>cluster</i> afecta de manera positiva el tiempo de procesamiento de las tareas. Esto tiene perfecto sentido en una instancia con procesador multinúcleo dado que los trabajos se asignan entre el número de núcleos habilitados, por lo cual el CPU realiza un balanceo de las asignaciones, minimizando así el tiempo de cómputo. Una vez asignadas las tareas, cada núcleo ejecuta la actividad en un orden FIFO (<i>first in, first out</i>), este aspecto queda en evidencia en la Figura 1, notesé el escenario de un sólo núcleo habilitado, siendo este el más lento en concretar las tareas.

2. El ordenamiento de los conjuntos no tiene una afectación significativa en el tiempo de procesamiento de las tareas. Cabe señalar, que el ligero aumento en el tiempo cuando el ordenamiento es descendente, es debido a que los números más grandes (que requiere un mayor orden de operaciones) son inicialmente computados por el algoritmo `is_prime`, bloqueando por un mayor tiempo el uso de los núcleos para operaciones subsecuentes. Sin embargo la evidencia gráfica y estadística determina que tal afectación en el tiempo no logra ser lo suficientemente significativa.

#### Bibliografía
1. S.K. Dhall y C.L. Liu, On a Real-Time Scheduling Problem, <i>Operations Research</i>, 26:127-140, 1978.
2. A. Burchard, J. Liebeherr, Y. Oh, S.H. Son. New Strategies for Assigning Real-Time Tasks to Multiprocessor. <i>Systems IEEE Transactions on Computers</i>, 44(12):1429-1442, 1995.
3. W.H. Kruskal y W.A. Wallis. Use of ranks in one-criterion variance analysis. <i>Journal of the American Statistical Association</i> 47(260): 583-621, 1952.
4. R. Calaway, S. Weston, D. Tenenbaum. Foreach Parallel Adaptor for the 'parallel' Package. <i>R Package</i>, https://cran.r-project.org/web/packages/doParallel/doParallel.pdf.
5. S.E. Schaeffer. Práctica 3: teoría de colas, <i>R paralelo: simulación & análisis de datos</i> http://elisa.dyndns-web.com/teaching/comp/par/p3.html.
