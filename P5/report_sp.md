## Introducción

La simulación de Monte-Carlo fue creada para integrales que no se pueden resolver por métodos analíticos. Posteriormente se utilizó para cualquier esquema que emplee números aleatorios, usando variables aleatorias con distribuciones de probabilidad conocidas [\[1\]](#bibliograf%C3%ADa). Este método es ideal para situaciones en las cuales algún valor o alguna distribución no se conoce y resulta complicado de determinar de manera analítica [\[2\]](#bibliograf%C3%ADa). El método se define como sigue

<p align="center">
<img src="https://latex.codecogs.com/gif.latex?y=\frac{1}{M}\sum_{i=1}^{N}&space;g(x_i)," />
</p>

donde ![f1] es la función que computa el factor estimado en la <img src="https://latex.codecogs.com/gif.latex?i"/>-ésima iteración, <img src="https://latex.codecogs.com/gif.latex?x_i"/> es un número aleatorio con una distribución <img src="https://latex.codecogs.com/gif.latex?\sim&space;N(\mu,\sigma^2)"/> y ![f2] es el tamaño de la muestra o número total de estimaciones independientes, el método tiene un error absoluto de la estimación que decrece a razón de <img src="https://latex.codecogs.com/gif.latex?1/\sqrt(N)"/>, según el teorema del límite central.
## Objetivo

El objetivo general de esta práctica es analizar el efecto que tiene el tamaño de la muestra sobre la calidad de los resultados y el tiempo de procesamiento. En específico, desglosamos las actividades en los siguientes objetivos:

1. Examinar el efecto del tamaño de la muestra en la precisión del estimado de una integral y realizar una comparacion del resultado obtenido con el valor resuelto por Wolfram Alpha, así como el tiempo de ejecución. La integral propuesta para el análisis es la siguiente
 
<p align = "center">
<img src="https://latex.codecogs.com/gif.latex?\int_{7}^{3}\frac{1}{\exp(x)&plus;\exp(-x)}dx\approx&space;0.048834."/>
</p>

2. Implementar la estimación del valor de <img src="https://latex.codecogs.com/gif.latex?\pi"/> propuesta por Kurt [\[3\]](#bibliograf%C3%ADa) con paralelismo y realizar una comparación del resultado obtenido con el valor resuelto por Wolfram Alph, que es aproximadamente

<p align = "center">
<img src="https://latex.codecogs.com/gif.latex?\pi&space;\approx&space;3.1415926">.
</p>

3. Se tiene la base histórica de la infección por vector del virus Zika [\[7\]](#bibliograf%C3%ADa) correspondiente al estado de Oaxaca, con observaciones de las primeras 34 semanas del año 2016 [\[6\]](#bibliograf%C3%ADa). Se deberá implementar la técnica propuesta por Kurt [\[3\]](#bibliograf%C3%ADa) para pronosticar las siguientes semanas. Calcular la precisión para los estimadores obtenidos y realizar una comparación de los valores reportados en los boletines posteriores.

## Experimentación
### Diseño

Se establecen a continuación las condiciones de diseño y definición de los experimentos. En cada uno de los métodos codificados, se tienen dos parámetros de control que afectan el comportamiento de los algoritmo: <img src="https://latex.codecogs.com/gif.latex?k">, que es el número de iteraciones que realiza el método de Monte-Carlos y <img src="https://latex.codecogs.com/gif.latex?n"> que define la cardinalidad del conjunto de números aleatorios generados bajo una distribución en cada iteración del método. Por lo anterior, el tamaño de la muestra es <a href="https://www.codecogs.com/eqnedit.php?latex=M=n\times&space;k" target="_blank"><img src="https://latex.codecogs.com/gif.latex?M=n\times&space;k" title="M=n\times k" /></a>.

1. En el cálculo de aproximación a la integral definida, los parámetros se definen como <img src="https://latex.codecogs.com/gif.latex?n\in\[500,5000\]"/>, discretizado en pasos de 500 y <img src="https://latex.codecogs.com/gif.latex?k\in\[100,1000\]"/>, discretizado en pasos de 100; ejecutando la totalidad del experimento con 20 reinicios. La distribución de los números pseudo-aleatorios esta dada por la función <img src="https://latex.codecogs.com/gif.latex?g(x)=2f(x)/\pi"/>, con límites de iteración en la generación de <img src="https://latex.codecogs.com/gif.latex?\[-6,6\]"/>, discretizado con pasos de <img src="https://latex.codecogs.com/gif.latex?\0.5"/>. La formula siguiente define el cálculo de la desviación relativa del resultado, donde <img src="https://latex.codecogs.com/gif.latex?\hat{y_i}"/> y <img src="https://latex.codecogs.com/gif.latex?y_i"/> son el valor estimado y el computado por Wolfram Alpha, respectivamente

<p align="center">
<img src="https://latex.codecogs.com/gif.latex?D=\frac{\left&space;|&space;\hat{y_i}-y_i&space;\right&space;|}{y_i}&space;\times&space;100."/>
</p>

2. Para el cálculo de aproximación de <img src="https://latex.codecogs.com/gif.latex?\pi"> los parámetros se definen como <img src="https://latex.codecogs.com/gif.latex?n\in\[100,1000\]"/>, discretizado en pasos de 100 y <img src="https://latex.codecogs.com/gif.latex?k\in\[10,100\]"/>, discretizado en pasos de 10; ejecutando la totalidad del experimento con 20 reinicios independientes. Se utiliza una distribución normal uniforme para la generación de los números pseudo-aleatorios, con límites de generación entre <img src="https://latex.codecogs.com/gif.latex?\[-0.5,0.5\]"/>. Igual que el objetivo anterior, se utiliza la desviación relativa cómo evaluación en la calidad del resultado. 

3. Para el pronóstico de los casos subsecuentes de Zika, se proponen dos modelos. **Modelo 1**: toma como base el modelo propuesto por Kurt [\[3\]](#bibliograf%C3%ADa), el cual genera valores aleatorios usando una distribución normal denotada por <img src="https://latex.codecogs.com/gif.latex?\sim&space;N(\mu,\sigma^2)"/> donde <img src="https://latex.codecogs.com/gif.latex?\mu"/> y <img src="https://latex.codecogs.com/gif.latex?\sigma^2"/>, son la media y desviación estándar de la serie de datos histórica, respectivamente. **Modelo 2**: se propone un modelo que es la combinación de Monte-Carlo y Arima; para este último se hace uso de la función `auto.arima` para determinar el mejor modelo de Arima a iterar en la simulación de Monte-Carlo. La ejecución se realiza tomando como comparación las semanas del 35 a la 40 del año 2016. Para este experimento sólo se utiliza el parámetro <img src="https://latex.codecogs.com/gif.latex?k\in\[1000,5000,10000\]"/> para controlar el número de iteraciones del método de Monte-Carlo. 
La evaluación de la asertividad del pronóstico es calculada con el WMAPE (por sus siglas en inglés de <i>weighted mean absolute percentage error</i>), definida en la siguiente formula y donde <img src="https://latex.codecogs.com/gif.latex?\hat{y_i}"/> y <img src="https://latex.codecogs.com/gif.latex?y_i"/> son el valor estimado y real, respectivamente en la <img src="https://latex.codecogs.com/gif.latex?i"/>-ésima semana

<p align = "center">
<img src="https://latex.codecogs.com/gif.latex?WMAPE&space;=\frac{\sum_{n}^{i=1}\left&space;|&space;\frac{y_i-\hat{y_i}}{y_i}&space;\right&space;|&space;y_i}{\sum_{n}^{i=1}&space;y_i&space;}" />.
</p>

### Condiciones computacionales
Se hace uso de una instancia SO Linux (Ubuntu 16.04) 64-bits, con procesador Intel (R) Core (TM) i7-5600U CPU @ 2.60 GHz y 12 GB de memoria RAM con 2 núcleos y 4 procesadores lógicos, durante la experimentación el <i>cluster</i> hizo uso de 3 núcleos. La aplicación se ha codificado en R, haciendo uso del paquete `doParallel` [\[4\]](#bibliograf%C3%ADa) que incluye la función `foreach` y el paquete `forecast` [\[5\]](#bibliograf%C3%ADa) para el uso de la función `auto.arima`.

## Resultados
La **figura 1** muestra el tiempo de ejecución y la desviación del resultado en la estimación de una integral respecto al valor computado por Wolfram Alpha. Se observa como a medida que el tamaño de la muestra aumenta, ocurre también un incremento en el tiempo de ejecución del método. Un efecto positivo ocurre en la calidad del resultado (al disminuir la desviación) conforme aumenta el tamaño la muestra.

<p align="center">
<img src="https://github.com/dagoquevedo/parallelr/blob/master/P5/img/P5_A.png"/><br>
<b>Figura 1.</b> Tiempo de ejecución y desviación del resultado en la estimación de una integral.
</p>

En la **figura 2** muestra el tiempo de ejecución y la desviación del resultado en la estimación del valor de <img src="https://latex.codecogs.com/gif.latex?\pi"/>. Se observa el mismos efecto que el experimento anterior: a medida que el tamaño de la muestra aumenta lo hace también el tiempo de ejecución del método, aunque en este caso el incremento es más notorio en combinaciones de <img src="https://latex.codecogs.com/gif.latex?n"/> y <img src="https://latex.codecogs.com/gif.latex?k"/> de mayor tamaño. Un efecto positivo vuelve a ocurrir con la calidad del resultado, al disminuir la desviación conforme aumenta el tamaño la muestra.

<p align="center">
<img src="https://github.com/dagoquevedo/parallelr/blob/master/P5/img/P5_B.png"/><br>
<b>Figura 2.</b> Tiempo de ejecución y desviación del resultado en la estimación del valor de <img src="https://latex.codecogs.com/gif.latex?\pi"/>.
</p>

Finalmente, en la **figura 3** se despliegan los resultados del pronóstico estadístico de los casos posteriores de Zika en el estado de Oaxaca de la semana 35 a la 40 del año 2016, así como su asertividad respecto al valor real. En los resultados de las distintas series de tiempo, el valor de casos reales y las generadas por los estimadores de cada modelo tienen un comportamiento distinto entre si, siendo el **Modelo 2** el que presenta una mayor variabilidad. Por otro lado la asertividad del pronóstico para ambos modelos, resulta no ser favorable, observado que el **Modelo 2** es el que menos asertividad refleja. Además de lo anterior, no se muestra una diferencia notable en los resultados entre los diferentes números de iteraciones dados por <img src="https://latex.codecogs.com/gif.latex?k"/>.

<p align="center">
<img src="https://github.com/dagoquevedo/parallelr/blob/master/P5/img/P5_C.gif"/><br>
<b>Figura 3.</b> Resultado y evaluación de la asertividad en el pronóstico del virus por vector Zika.
</p>


## Conclusiones

1. Para los experimentos del cálculo de aproximación de la integral y <img src="https://latex.codecogs.com/gif.latex?\pi"/> se confirma que el tamaño de la muestra tiene una relación con la calidad del resultado del estimador, además de obviar el hecho de un incremento en el tiempo de computo.

2. La baja calidad del pronóstico de ambos modelos confirman la incertidumbre existente en la serie de datos. La situación que se pretende estimar se conforma de otras tantas variables del entorno [\[7\]](#bibliograf%C3%ADa) (variables independientes) que afectan el número de casos en cada semana (variable dependiente), por lo cual tratar realizar un pronóstico a través de una metodología de serie de tiempo puede conllevar a resultados de pobre calidad. En este caso se recomienda realizar un levantamiento mayor de estas variables independientes (clima, humedad, región, altitud, estacionalidad, etc.) y modelar el problema como una **regresión multivariable**.

#### Bibliografía
1. P. E. Kloeden, E. Platen. <i>Numerical Solution of Stochastic Differential Equations</i>, Springer, Berlin, 1992.
2. S.E. Schaeffer. Práctica 4: Método de Monte-carlo, <i>R paralelo: simulación & análisis de datos</i>, [\[url\]](http://elisa.dyndns-web.com/teaching/comp/par/p5.html).
3. W. Kurt. 6 Neat Tricks with Monte Carlo Simulations, <i>Count Bayesie</i>, [\[url\]](https://www.countbayesie.com/blog/2015/3/3/6-amazing-trick-with-monte-carlo-simulations).
4. R. Calaway, S. Weston, D. Tenenbaum. Foreach Parallel Adaptor for the 'parallel' Package, <i>R Package</i>, [\[url\]](https://cran.r-project.org/web/packages/doParallel/doParallel.pdf).
5. R. Hyndman, M. O'Hara-Wild, C. Bergmeir, <i>et al.</i>. Package ‘forecast’, <i>R Package</i>, [\[url\]](https://cran.r-project.org/web/packages/forecast/forecast.pdf).
6. Boletín Epidemiológico, Secretaría de Salud - Dirección General de Epidemiología, 2016, [\[url\]](https://www.gob.mx/salud/acciones-y-programas/boletinepidemiologico-sistema-nacional-de-vigilancia-epidemiologica-sistema-unico-de-informacion-90794).
7. Enfermedad por el virus de Zika. OMS, 2016, [\[url\]](http://www.who.int/mediacentre/factsheets/zika/es/).

[f1]: https://latex.codecogs.com/gif.latex?g
[f2]: https://latex.codecogs.com/gif.latex?M
