# Búsqueda Local

## Introducción

La **búsqueda local** es un método de optimización heurística que retorna un óptimo local, el cual inicia desde una solución inicial <img src="https://latex.codecogs.com/gif.latex?x" />, y durante cada iteración aplica una transformación a la solución concurrente <img src="https://latex.codecogs.com/gif.latex?x" /> generando un vecindario <img src="https://latex.codecogs.com/gif.latex?N(x)" />, el mejor elemento evaluado se denota como <img src="https://latex.codecogs.com/gif.latex?x'" />, si <img src="https://latex.codecogs.com/gif.latex?f(x')" /> mejora a <img src="https://latex.codecogs.com/gif.latex?f(x)" />, entonces <img src="https://latex.codecogs.com/gif.latex?x=x'" />. El método se detiene cual el número máximo de iteraciones es alcanzado. En esta práctica se implementarán métodos de de optimización heurística sencilla para encontrar máximos locales de funciones, tomando los ejemplos propuestos por Womersley [\[1\]](#bibliograf%C3%ADa).

## Objetivos

1. Desarrollar una búsqueda local para máximizar una función bidimensional, e implementar una visualización de cómo procede la búsqueda en una gráfica de proyección plana [\[2\]](#bibliograf%C3%ADa). La función a maximizar <img src="https://latex.codecogs.com/gif.latex?g(\boldsymbol{x})">, donde <img src="https://latex.codecogs.com/gif.latex?\boldsymbol{x}\in\mathbb{R}^2"/> y <img src="https://latex.codecogs.com/gif.latex?-6\leq&space;g(\boldsymbol{x})\leq&space;5">, es definida como:

<p align="center">
<a href="https://www.codecogs.com/eqnedit.php?latex=g(\boldsymbol{x})&space;=&space;\left&space;(\sum_{2}^{i=1}(x_i&space;&plus;&space;0.5)^4-30x^2_i-20x_i&space;\right&space;)&space;/&space;100" target="_blank"><img src="https://latex.codecogs.com/gif.latex?g(\boldsymbol{x})&space;=&space;\left&space;(\sum_{2}^{i=1}(x_i&space;&plus;&space;0.5)^4-30x^2_i-20x_i&space;\right&space;)&space;/&space;100." title="g(\boldsymbol{x}) = \left (\sum_{2}^{i=1}(x_i + 0.5)^4-30x^2_i-20x_i \right ) / 100" /></a>
</p>

2. Implementar el algoritmo de búsqueda local de **recocido simulado** para máximizar la función <img src="https://latex.codecogs.com/gif.latex?g(\boldsymbol{x})"/> y realizar un diseño experimental para examinar los efectos del valor inicial de la temperatura <img src="https://latex.codecogs.com/gif.latex?T"> y el valor de reducción de la temperatura <img src="https://latex.codecogs.com/gif.latex?\xi"> en la calidad de la solución. En este método, si <img src="https://latex.codecogs.com/gif.latex?g(\boldsymbol{x}')>g(\boldsymbol{x})"/> entonces la probabilidad de selección es <img src="https://latex.codecogs.com/gif.latex?P(\boldsymbol{x},\boldsymbol{x}',T)=1"/>, en caso contrario:

<p align="center">
<img src="https://latex.codecogs.com/gif.latex?P(\boldsymbol{x}',\boldsymbol{x},T)=\exp(-(g(\boldsymbol{x})-g(\boldsymbol{x}'))/T)."/>  
</p>

## Implementación y diseño experimental

1. El movimiento que se ha implementado para la búsqueda local de la maximización de <img src="https://latex.codecogs.com/gif.latex?g(\boldsymbol{x})"/>, consiste en realizar dos movimientos aleatorios <img src="https://latex.codecogs.com/gif.latex?\inline&space;\Delta&space;x"/> y <img src="https://latex.codecogs.com/gif.latex?\inline&space;\Delta&space;y"> cuyas combinaciones posibles generan cuatro movimientos para las coordenadas <img src="https://latex.codecogs.com/gif.latex?x"/> y <img src="https://latex.codecogs.com/gif.latex?y"/>.

2. Para el diseño experimental del algoritmo de búsqueda de **recocido simulado**, se establece ejecutarlo con distintos valores para el máximo de iteraciones, es decir <img src="https://latex.codecogs.com/gif.latex?\inline&space;t_{\max}\in\left&space;\{&space;10,10^2,10^3,10^4&space;\right&space;\}"/> y <img src="https://latex.codecogs.com/gif.latex?\inline&space;\xi\in\left&space;\{&space;0.545,0.995&space;\right&space;\}"/> con una discretización de <img src="https://latex.codecogs.com/gif.latex?\inline&space;0.15"/>. Establecemos que <img src="https://latex.codecogs.com/gif.latex?T=t_{\max}"/>. Se realizan 50 replicas para cada combinación de los parámetros definidos. Tomando como referencia la solución <img src="https://latex.codecogs.com/gif.latex?g(\boldsymbol{x}^*"/> que obtiene el máximo valor posible, es decir <img src="https://latex.codecogs.com/gif.latex?g(\boldsymbol{x}^*)\approx&space;1.30125"/> y la solución <img src="https://latex.codecogs.com/gif.latex?\boldsymbol{x}"/> estimada por el método, se calcula la desviación relativa (gap %) de la manera siguiente:

<p align="center">
<a href="https://www.codecogs.com/eqnedit.php?latex=\mathrm{gap&space;\%}=\frac{\left&space;|&space;g(\boldsymbol{x})-g(\boldsymbol{x}^*)&space;\right&space;|}{g(\boldsymbol{x}^*)}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\mathrm{gap&space;\%}=\frac{\left&space;|&space;g(\boldsymbol{x})-g(\boldsymbol{x}^*)&space;\right&space;|}{g(\boldsymbol{x}^*)}." title="\mathrm{gap \%}=\frac{\left | g(\boldsymbol{x})-g(\boldsymbol{x}^*) \right |}{g(\boldsymbol{x}^*)}" /></a>
</p>

### Condiciones computacionales
Instancia SO Linux (Ubuntu 16.04) 64-bits, con procesador Intel (R) Core (TM) i7-5600U CPU @ 2.60 GHz y 12 GB de memoria RAM con 2 núcleos y 4 procesadores lógicos. El <i>cluster</i> hizo uso de 3 núcleos. La aplicación se ha codificado en R, haciendo uso del paquete `doParallel` [\[3\]](#bibliograf%C3%ADa) que incluye la función `foreach`.

## Resultados
La **figura 1** muestra la función <img src="https://latex.codecogs.com/gif.latex?g(\boldsymbol{x})"> graficada en tres dimensiones, se observa cómo los valores extremos de la función son los que alcanzan los máximos valores de la superficie.

<p align="center">
<img src="https://github.com/dagoquevedo/parallelr/blob/master/P7/img/P7_A_2.gif" width="75%" height="75%"/><br>
<b>Figura 1.</b> Superficie en tres dimensiones de la función <img src="https://latex.codecogs.com/gif.latex?g(\boldsymbol{x})">.
</p>

La **figura 2** refleja una ejecución de la **búsqueda local** para máximizar la función <img src="https://latex.codecogs.com/gif.latex?\inline&g(\boldsymbol{x})"> y expresada de forma plana, se observa cómo al incrementar <img src="https://latex.codecogs.com/gif.latex?t_{\max}">, las soluciones obtenidas tienden a concentrarse en los puntos extremos, reduciendo el valor de gap %.

<p align="center">
<img src="https://github.com/dagoquevedo/parallelr/blob/master/P7/img/P7_A_1.gif" width="60%" height="60%"/><br>
<b>Figura 2.</b> Iteraciones de la búsqueda local para aproximar al máximo de la función <img src="https://latex.codecogs.com/gif.latex?g(\boldsymbol{x})">.
</p>

La **figura 3** refleja una ejecución del método de **recocido simulado** para máximizar la función <img src="https://latex.codecogs.com/gif.latex?\inline&g(\boldsymbol{x})"> y expresada de forma plana, igual que la búsqueda local se observa cómo al incrementar <img src="https://latex.codecogs.com/gif.latex?t_{\max}">, las soluciones obtenidas tienden a concentrarse en los puntos extremos, reduciendo el valor de gap %.

<p align="center">
<img src="https://github.com/dagoquevedo/parallelr/blob/master/P7/img/P7_B_1.gif" width="60%" height="60%"/><br>
<b>Figura 3.</b> Iteraciones del recocido simulado para aproximar al máximo de la función <img src="https://latex.codecogs.com/gif.latex?g(\boldsymbol{x})">.
</p>

La **figura 4** muestra el resultado del experimento de los efectos resultantes de la variación de los parámetros <img src="https://latex.codecogs.com/gif.latex?T"> y <img src="https://latex.codecogs.com/gif.latex?\xi">, los valores estan dados por el promedio entre replicas para cada combinación posible de parametros <img src="https://latex.codecogs.com/gif.latex?T"> y <img src="https://latex.codecogs.com/gif.latex?(T,\xi)">. Aquí, vemos como <img src="https://latex.codecogs.com/gif.latex?T"> tiene un efecto positivo en la disminución del gap, por otro lado al decrementar el valor de <img src="https://latex.codecogs.com/gif.latex?xi">, el enfriamiento de <img src="https://latex.codecogs.com/gif.latex?T"> se realiza más agresivamente, por lo cual no da una mayor holgura a seleccionar soluciones basado en una probabilidad <img src="https://latex.codecogs.com/gif.latex?\exp(-\delta/T)">, donde <img src="https://latex.codecogs.com/gif.latex?\delta"> es la diferencia respecto la solución concurrente en cada iteración.
 
<p align="center">
<img src="https://github.com/dagoquevedo/parallelr/blob/master/P7/img/P7_B_3.png" width="95%" height="95%"/><br>
<b>Figura 4.</b> Efectos de los parámetros <img src="https://latex.codecogs.com/gif.latex?T"> y <img src="https://latex.codecogs.com/gif.latex?\xi"> en el rendimiento del algoritmo de recocido simulado.
</p>


#### Bibliografía
1. R. Womersley. Local and Global Optimization: Formulation, Methods and Applications. <i>School of Mathematics & Statistics</i>, University of New South Wales, 2008, [\[url\]](http://web.maths.unsw.edu.au/~rsw/lgopt.pdf).
3. S.E. Schaeffer. Práctica 7: Búsqueda local. <i>R paralelo: simulación & análisis de datos</i>, [\[url\]](http://elisa.dyndns-web.com/teaching/comp/par/p7.html).
4. R. Calaway, S. Weston, D. Tenenbaum. Foreach Parallel Adaptor for the 'parallel' Package. <i>R Package</i>, [\[url\]](https://cran.r-project.org/web/packages/doParallel/doParallel.pdf).
