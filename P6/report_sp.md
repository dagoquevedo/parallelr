# Sistema multiagente

## Introducción

Los **sistema multiagente** (MAS, por sus siglas en inglés de <i>multi-agent system</i>) [\[1,2\]](#bibliograf%C3%ADa) es un sistema compuesto de múltiples agentes con estados internos que interaccionan entre ellos, donde un **agente** se define como una entidad capaz de actuar de manera independiente, de percibir y reaccionar a las condiciones de un entorno, satisfaciendo los objetivos de diseño y sujeto a un conjunto de reglas [\[3\]](#bibliograf%C3%ADa). La **figura 1** (tomada de [\[1\]](#bibliograf%C3%ADa)) muestra el diagrama de un sistema multiagente reactivo con estado interno, en el cual se identifican **sensores** que percibe las condiciones del entorno y **actuadores** que retornan un acción hacia el entorno.

<p align="center">
<img src="https://github.com/dagoquevedo/parallelr/blob/master/P6/img/P6_5.png" width="50%" height="50%"/><br>
<b>Figura 1.</b> Sistema multiagente reactivo con estado interno.
</p>

En esta práctica se implementa un sistema multiagente con aplicaciones en la epidemiología [\[4\]](#bibliograf%C3%ADa). Los agentes podrán estar en uno de los tres estados: **S**usceptibles, **I**nfectados o **R**ecuperados, esto es conocido como el modelo SIR [\[5,6\]](#bibliograf%C3%ADa). El modelo es definido por un número de agentes <img src="https://latex.codecogs.com/gif.latex?n">, una probabilidad de infección inicial <img src="https://latex.codecogs.com/gif.latex?p_i">, una probabilidad de recuperación <img src="https://latex.codecogs.com/gif.latex?p_r"> y un máximo de períodos a simular <img src="https://latex.codecogs.com/gif.latex?t_{\max}">. Se asume que la infección produce inmunidad en los agentes recuperados por lo que ya no pueden volverse a infectar y solamente los agentes susceptibles (con estado **S**) podrán ser infectados en los períodos subsecuentes. La probabilidad de contagio <img src="https://latex.codecogs.com/gif.latex?p_c"> es proporcional a la distancia euclideana entre dos agentes <img src="https://latex.codecogs.com/gif.latex?d(i,j)"> y definida de la siguiente manera:

<p align="center">
<img src="https://latex.codecogs.com/gif.latex?p_c=\left\{\begin{matrix}&space;0,&space;&&space;\textrm{si&space;}&space;d(i,j)\geq&space;r,\\&space;\frac{r-d}{r},&space;&&space;\textrm{en&space;otro&space;caso},&space;\end{matrix}\right." />
</p>

donde <img src="https://latex.codecogs.com/gif.latex?r"> es un umbral. Los agentes tendrán coordenadas <img src="https://latex.codecogs.com/gif.latex?x"> y <img src="https://latex.codecogs.com/gif.latex?y">, una dirección y una velocidad, expresadas en términos de <img src="https://latex.codecogs.com/gif.latex?\Delta&space;x"/> y <img src="https://latex.codecogs.com/gif.latex?\Delta&space;x"/>. Los agentes se posicionan uniformemente al azar en un **torus** formado por doblar un rectángulo de <img src="https://latex.codecogs.com/gif.latex?\ell&space;\times&space;\ell"/>, visualizando en todo momento el rectángulo en un espacio de dos dimensiones.

## Objetivo

1. Identificar funcionalidades dentro del código base [\[4\]](#bibliograf%C3%ADa) que puedan ser paralelizadas e implementar una versión con alguno de los paquetes conocidos de paralelización.
2. Vacunar con probabilidad <img src="https://latex.codecogs.com/gif.latex?p_v"> a los agentes al momento de su creación de tal forma que se encuentren desde el inicio en el estado **R**, por lo que no podrán contagiarse ni propagar la infección.
3. Estudiar el efecto de las probabilidades <img src="https://latex.codecogs.com/gif.latex?p_i"> y <img src="https://latex.codecogs.com/gif.latex?p_v"> en el porcentaje máximo de infectados durante la simulación, así como el período donde ocurre este valor máximo.

## Adaptaciones en el código
Uno de los objetivos consisten en paralelizar funcionalidades contenidas en el código base. La primera funcionalidad que se ha paralelizado es la inicialización de los agentes. Este proceso puede paralelizarse debido a que no es requerida una precedencia de operaciones entre los agentes durante su creación. En esta adaptación se ha incluido la probabilidad de vacunación <img src="https://latex.codecogs.com/gif.latex?p_v">. La rutina propuesta se ha contenido en la función `initialization`, definida a continuación:

```
initialization = function(pi, pv) {
    e = "S"
    if (runif(1) < pv) {
        e = "R"
    } else if (runif(1) < pi) {
        e = "I"
    }
    
    agent = data.frame( x  = runif(1, 0, l), 
                        y  = runif(1, 0, l),
                        dx = runif(1,-v, v), 
                        dy = runif(1,-v, v), state = e)
    return(agent)
}
```

La siguiente funcionalidad que se identificó para su paralelización es la infección y movimiento de los agentes. Siguiendo el orden entre ambas funcionalidades, éstas se han incluido en la función `infections`, que se define como sigue:

```
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
```

La invocación paralela de cada función se realiza utilizando la función `foreach`. El detalle del código ajustado y utilizado en esta práctica puede ser consultado en este [repositorio](https://github.com/dagoquevedo/parallelr/tree/master/P6).

## Diseño experimental
El objetivo del experimento es estudiar el efecto de las probabilidades <img src="https://latex.codecogs.com/gif.latex?p_i"> y <img src="https://latex.codecogs.com/gif.latex?p_v"> en el máximo porcentaje de infectados durante la simulación, así como el período donde ocurre este máximo porcentaje. Un ejemplo de la ejecución del método se muestra en las siguientes imagenes, donde la **figura 2** despliega la situación del entorno en cada período de la simulación. Se observa que a medida que se incrementa <img src="https://latex.codecogs.com/gif.latex?t">, lo hace tambien el número de agentes infectados e inmunizados.

<p align="center">
<img src="https://github.com/dagoquevedo/parallelr/blob/master/P6/img/P6_1.gif" width="60%" height="60%"/><br>
<b>Figura 2.</b> Simulación de la propagación de la infección con <img src="https://latex.codecogs.com/gif.latex?t_{\max}=100"/> y <img src="https://latex.codecogs.com/gif.latex?n=50"/>.
</p>

La **figura 3** muestra una comparación por período del porcentaje de agentes en cada uno de los estados. Se aprecia como la infección tiene un efecto semejante a una campana, es decir después de alcanzarse el máximo porcentaje de agentes infectados, sigue una disminución de la infección, a la vez que el número de agentes recuperados e inmunizados aumenta; este efecto en la simulación es ocasionado por la probabilidad de recuperación <img src="https://latex.codecogs.com/gif.latex?p_r"/>.

<p align="center">
<img src="https://github.com/dagoquevedo/parallelr/blob/master/P6/img/P6_2.png" width="75%" height="75%"/><br>
<b>Figura 3.</b> Comparación por período del porcentaje de agentes en cada estado.
</p>

Para el experimento en exhaustivo, se definen los siguientes valores para cada parámetro: <img src="https://latex.codecogs.com/gif.latex?n=50"/>, <img src="https://latex.codecogs.com/gif.latex?p_i\in\[0.05,0.50\]"/>, discretizado en pasos de <img src="https://latex.codecogs.com/gif.latex?0.05"/>, <img src="https://latex.codecogs.com/gif.latex?p_v\in\[0.00,0.30\]"/>, discretizado en pasos de <img src="https://latex.codecogs.com/gif.latex?0.05"/>. En este caso, se asume que se conoce la probabilidad de recuperación <img src="https://latex.codecogs.com/gif.latex?p_r=0.02"/>. Además se tiene <img src="https://latex.codecogs.com/gif.latex?t_{\max}=100"/>, <img src="https://latex.codecogs.com/gif.latex?\ell=1.5"/> y <img src="https://latex.codecogs.com/gif.latex?r=0.10"/>. El método se ejecuta para cada combinación de valores de los  parámetros definidos, retornando el máximo porcentaje de agentes infectados en cada ejecución y el período donde ocurre este porcentaje máximo. Se realizan 30 replicas independientes del experimento. Finalmente se realiza un prueba de Kruskal-Wallis [\[8\]](#bibliograf%C3%ADa) para reafirmar los resultados empíricos, estableciendo las siguientes hipótesis alternativas:

* <img src="https://latex.codecogs.com/gif.latex?H_1"/>: <img src="https://latex.codecogs.com/gif.latex?p_i"/> tiene un efecto significativo en el porcentaje máximo de agentes infectados.
* <img src="https://latex.codecogs.com/gif.latex?H_2"/>: <img src="https://latex.codecogs.com/gif.latex?p_v"/> tiene un efecto significativo en el porcentaje máximo de agentes infectados.
* <img src="https://latex.codecogs.com/gif.latex?H_3"/>: <img src="https://latex.codecogs.com/gif.latex?p_i"/> tiene un efecto significativo en el período donde ocurre el máximo porcentaje de agentes infectados.
* <img src="https://latex.codecogs.com/gif.latex?H_4"/>: <img src="https://latex.codecogs.com/gif.latex?p_v"/> tiene un efecto significativo en el período donde ocurre el máximo porcentaje de agentes infectados.

### Condiciones computacionales
Se hace uso de una instancia SO Linux (Ubuntu 16.04) 64-bits, con procesador Intel (R) Core (TM) i7-5600U CPU @ 2.60 GHz y 12 GB de memoria RAM con 2 núcleos y 4 procesadores lógicos, durante la experimentación el <i>cluster</i> hizo uso de 3 núcleos. La aplicación se ha codificado en R, haciendo uso del paquete `doParallel` [\[7\]](#bibliograf%C3%ADa) que incluye la función `foreach`.

## Resultados
La **figura 4** muestra un mapa de calor que expresa para cada combinación de probabilidades <img src="https://latex.codecogs.com/gif.latex?(p_i,p_v)"/> la media de los máximos porcentajes de agentes infectados.

<p align="center">
<img src="https://github.com/dagoquevedo/parallelr/blob/master/P6/img/P6_3.png" width="75%" height="75%"/><br>
<b>Figura 4.</b> Efecto de las probabilidades de vacunación e infección inicial en el máximo porcentaje de agentes infectados.
</p>

Se observa como a medida que incrementa <img src="https://latex.codecogs.com/gif.latex?p_v"/> y decrementa <img src="https://latex.codecogs.com/gif.latex?p_i"/> el máximo porcentaje de agentes infectados tiende a decrecer; por el contrario al incrementar <img src="https://latex.codecogs.com/gif.latex?p_i"/> y decrementar <img src="https://latex.codecogs.com/gif.latex?p_v"/> este valor aumenta. El comportamiento es más evidente cuando <img src="https://latex.codecogs.com/gif.latex?p_v=0.00"/>, alcanzando la situción más crítica del escenario del experimento.

La **figura 5** muestra un mapa de calor que expresa para cada combinación de probabilidades <img src="https://latex.codecogs.com/gif.latex?(p_i,p_v)"/> la media del período donde se alcanzo el máximo porcentaje de agentes infectados.

<p align="center">
<img src="https://github.com/dagoquevedo/parallelr/blob/master/P6/img/P6_4.png" width="75%" height="75%"/><br>
<b>Figura 5.</b> Efecto de las probabilidades de vacunación e infección inicial en el período donde ocurre el máximo porcentaje de agentes infectados.
</p>

Se observa como a medida que incrementa <img src="https://latex.codecogs.com/gif.latex?p_i"/> el máximo porcentaje de agentes infectados tiende a ocurrir en períodos más tempranos; por el contrario al decrementar <img src="https://latex.codecogs.com/gif.latex?p_i"/> el máximo porcentaje tiende a ocurrir en períodos más tardíos; no se observa un efecto significativo de <img src="https://latex.codecogs.com/gif.latex?p_v"/> en este valor. El **cuadro 1** contiene el resultado de la prueba estadística de Kruskal-Wallis con un nivel de significancia de <img src="https://latex.codecogs.com/gif.latex?\alpha=5\%"/>.

<caption><b>Cuadro 1.</b> Resultados de la prueba de Kruskal-Wallis.</caption>

| Hipótesis | <img src="https://latex.codecogs.com/gif.latex?p"/>-valor |
|:---------:|:--------:|
|<img src="https://latex.codecogs.com/gif.latex?H_1"/>|<img src="https://latex.codecogs.com/gif.latex?1.6&space;\times&space;10^{-13}"/>|
|<img src="https://latex.codecogs.com/gif.latex?H_2"/>|<img src="https://latex.codecogs.com/gif.latex?2.2&space;\times&space;10^{-16}"/>|
|<img src="https://latex.codecogs.com/gif.latex?H_3"/>|<img src="https://latex.codecogs.com/gif.latex?2.2&space;\times&space;10^{-16}"/>|
|<img src="https://latex.codecogs.com/gif.latex?H_4"/>|<img src="https://latex.codecogs.com/gif.latex?0.58794538"/>|

Los resultados muestran que <img src="https://latex.codecogs.com/gif.latex?p_i"/> y <img src="https://latex.codecogs.com/gif.latex?p_v"/> tienen un efecto significativo en el porcentaje máximo de agentes infectados. En el caso del período donde ocurre el máximo porcentaje de agentes infectados, se confirma que sólo <img src="https://latex.codecogs.com/gif.latex?p_i"/> tiene un efecto significativo en este valor, y no así <img src="https://latex.codecogs.com/gif.latex?p_v"/>, cuyo <img src="https://latex.codecogs.com/gif.latex?p"/>-valor resulto ser mayor al nivel de significancia. Lo anterior es consistente con el análisis gráfico discutido en la **figura 4** y **figura 5**. 

## Conclusiones

A partir de la evidencia empírica y estadística mostrada en la sección de [Resultados](#resultados), se puede concluir lo siguiente:

* <img src="https://latex.codecogs.com/gif.latex?p_i"/> y <img src="https://latex.codecogs.com/gif.latex?p_v"/> tienen un efecto significativo sobre la propagación de una infección. Cuando se incrementa <img src="https://latex.codecogs.com/gif.latex?p_v"/> y decrementar <img src="https://latex.codecogs.com/gif.latex?p_i"/> el máximo porcentaje de agentes infectados **decrece**, demostrando la efectividad de la inmunización como medida preventiva. Por el contrario si se incrementa <img src="https://latex.codecogs.com/gif.latex?p_i"/> y decrementa <img src="https://latex.codecogs.com/gif.latex?p_v"/> el valor se **incrementa**.

* <img src="https://latex.codecogs.com/gif.latex?p_i"/> tiene un efecto significativo sobre el período donde ocurre la máxima propagación de la infección. Esto es, si se incrementa <img src="https://latex.codecogs.com/gif.latex?p_i"/> la máxima propagación de la infección ocurre en períodos más tempranos; por el contrario al decrementar <img src="https://latex.codecogs.com/gif.latex?p_i"/> este máximo ocurre en períodos más tardíos. Esto tiene perfecto sentido debido a que a un mayor número de agentes infectados en la etapa inicial, la infección hacia agentes susceptibles ocurre de manera más ágil.


#### Bibliografía
1. J. Béjar. Sistemas multiagentes. <i>Notas de curso: Enginyeria del Coneixement i Sistemes Distribuïts Intel.ligents</i>, Universitat Politècnica de Catalunya, 2016, [\[url\]](http://www.cs.upc.edu/~bejar/ecsdi/Teoria/ECSDI02a-Agentes.pdf).
2. M. Wooldridge. <i>An Introduction to Multiagent Systems</i>. John Wiley & Sons, 2002.
3. L. Padgham, M. Winikoff. <i>Developing Intelligent Agent Systems</i>. John Wiley & Sons, 2004.
4. S.E. Schaeffer. Práctica 6: Sistema multiagente. <i>R paralelo: simulación & análisis de datos</i>, [\[url\]](http://elisa.dyndns-web.com/teaching/comp/par/p6.html).
5. W.O. Kermack, A.G. McKendrick. A Contribution to the Mathematical Theory of Epidemics. <i>Proceedings of the Royal Society A</i>. 115(772): 700–721, Agosto, 1927, [\[doi\]](http://doi.org/10.1098/rspa.1927.0118).
6. H.W. Hethcote, Three Basic Epidemiological Models. En <i>Applied Mathematical Ecology</i>, Springer, 1989, [\[doi\]](http://doi.org/10.1007/978-3-642-61317-3_5). 
7. R. Calaway, S. Weston, D. Tenenbaum. Foreach Parallel Adaptor for the 'parallel' Package. <i>R Package</i>, [\[url\]](https://cran.r-project.org/web/packages/doParallel/doParallel.pdf).
8. W.H. Kruskal y W.A. Wallis. Use of ranks in one-criterion variance analysis. <i>Journal of the American Statistical Association</i>, 47(260): 583-621, 1952, [\[doi\]](http://doi.org/10.2307/2280779).