globals [pa1_C pa2_C  pa1_Cn pa2_Cn id1 id2 id3 mean_c mean_cn mean_c_pink mean_cn_pink mean_c_blue mean_cn_blue ratioPower_Blue_Pink idxConv_C idxConv_Cn idxConv_C_blue idxConv_Cn_blue idxConv_C_pink idxConv_Cn_pink nSteps listConv_C listConv_Cn  listConv_C_blue listConv_Cn_blue listConv_C_pink listConv_Cn_pink  idx1]
breed [people person]
people-own [c cn]

to setup
   clear-all

   set nSteps 5000 ;; numero de pasos para evaluar la convergencia 
   
   set idxConv_C 100
   
   set listConv_C  n-values nSteps [100] ; lista que evalua la convergencia del sistema 
   set listConv_Cn n-values nSteps [100]   

   set listConv_C_blue  n-values nSteps [100] ; lista que evalua la convergencia del sistema 
   set listConv_Cn_blue n-values nSteps [100]   
   
   set listConv_C_pink  n-values nSteps [100] ; lista que evalua la convergencia del sistema 
   set listConv_Cn_pink  n-values nSteps [100]   
   
   ask patches [set pcolor white]
   
   ;; calula los parametros de CAT
   set pa1_C  (s1 / k1) 
   set pa1_Cn (s2 / k2)
   set pa2_C  (pa1_C * u / k2)
   set pa2_Cn (pa1_Cn * u / k1)
      
   setup-poblation
   
   do-plot
   
end

to setup-poblation
   set ratioPower_Blue_Pink Power_Blue / Power_Pink
   set-default-shape people "person"
   create-people number_people 
   repeat number_people [                ;; ordena a las personas en un arreglo de base 10
          ask person id1 [setxy id2 id3]
          set id1 id1 + 1
          set id2 id2 + 1
          if id2 = 10 [(set id2 0) (set id3 id3 + 1)] 
          ] 
   setup-group

 
end

to setup-group ; define los grupos 

   ask people[ ifelse (who < (number_people * ratio_pink))  ;; ajusta el ratio entre los tamaños de cada grupo 
                       [set color pink] 
                       [set color blue]   
             ]
             
   ask people  with [color = pink] [(set c initial_c_pink) (set cn initial_cn_pink)]
   
   ask people  with [color = blue] [(set c initial_c_blue) (set cn initial_cn_blue)]   
end


to go
     ask links [die]
     ask people [interaction]                                 
     tick
     do-plot
     converge
     
end

to interaction

   let pw 1
   ;; parametros del agente O
   let c_O 0
   let cn_O 0
   let pOA 0
   let pOC 0
   
   ;; parametros del agente A
   let c_A 0
   let cn_A 0
   let pAA 0
   let pAC 0
   
   ;; seleccion de los agentes 
   let nO who ;random number_people
   let A one-of other people ;random number_people
   let nA [who] of A 
   
; costrucciòn del link
   create-link-with person nA
   ask links [set color black]
   
; deterninacion de la interacciòn por la función indice de poder

if ( ([color] of person nO) =  ([color] of person nA) ) 
         [ set pw 1]   

if ( (([color] of person nO) = pink ) and (([color] of person nA) = blue) ) 
         [ set pw ratioPower_Blue_Pink]                                                 

if ( (([color] of person nO) = blue ) and (([color] of person nA) = pink) ) 
         [ set pw (1 / ratioPower_Blue_Pink)] 
                                              

   
   ;; calculo de probabilidades para el agente 0
   ask person nO [(set c_O c) (set cn_O cn) ]
   set pOA max list c_O cn_O ; o sea el máximo valor de c_O ó cn_O
   carefully [set pOC c_O / (c_O + cn_O)] [set pOC -1]

   ;; calculo de probabilidades para el agente A
   ask person nA [(set c_A c) (set cn_A cn) ]
   set pAA max list c_A cn_A 
   ;if c_A = 0 and cn_A = 0 [stop]
   carefully [set pAC c_A / (c_A + cn_A)] [set pAC -1]
   ;set pAC c_A / (c_A + cn_A)
   
   ;; navegando en el árbol    ;; NOTA IMPORTANTE!!!!!: es necesario pensar en un control para verificar que el árbol este bien implementado 
   if(random-float 1 < pOA)[       ;; primer nodo 
      if-else (random-float 1 < pOC) 
              [if-else (random-float 1 < pAA) 
                       [if-else (random-float 1 < pAC)
                                [if-else (random-float 1 < pa1_C)
                                         [ (set c_O c_O + 0.02 * pw)] 
                                         [ (set c_O c_O - 0.02 * pw)] 
                                
                                ]
                                
                                [if-else (random-float 1 < pa2_C)
                                         [ (set c_O c_O + 0.02 * pw)] 
                                         [ (set c_O c_O - 0.02 * pw)] 
                                ]
                       ] 
                       
                       [ (set c_O c_O - 0.02 * pw)]
                
              ] 
      
              [if-else (random-float 1 < pAA) 
                       [if-else (random-float 1 < pAC)
                                [if-else (random-float 1 < pa2_Cn)
                                         [ (set cn_O cn_O + 0.02 * pw)] 
                                         [ (set cn_O cn_O - 0.02 * pw)]  
                                
                                ]
                                
                                [if-else (random-float 1 < pa1_Cn)
                                         [ (set cn_O cn_O + 0.02 * pw)] 
                                         [ (set cn_O cn_O - 0.02 * pw)] 
                                ]
                       ] 
                       
                       [ (set cn_O cn_O - 0.02 * pw) ] 
              ]
      
   ]
   
   
 ; hay que normalizar la saliencia entre 0 y 1
 
   if c_O <= 0 [set c_O 0]
   if c_O >= 1 [set c_O 1]
   if cn_O <= 0 [set cn_O 0]
   if cn_O >= 1 [set cn_O 1]
     
;; guarda los valores de saliencie en sus repectivos agentes   
   ask person nO [(set c c_O) (set cn cn_O)]
   ask person nA [(set c c_A) (set cn cn_A)]
   
end


to do-plot
   let list_c  [c] of people
   let list_cn [cn] of people
   
   let list_c_pink  [c]  of people with [color = pink]
   let list_cn_pink [cn] of people with [color = pink]
   
   let list_c_blue  [c]  of people with [color = blue]
   let list_cn_blue [cn] of people with [color = blue]
   
   set mean_c  mean list_c
   set mean_cn mean list_cn 
   
   set mean_c_pink  mean list_c_pink
   set mean_cn_pink mean list_cn_pink
   
   set mean_c_blue  mean list_c_blue
   set mean_cn_blue mean list_cn_blue
   
  ;; graficar mean saliencia para cada grupo 
   set-current-plot "mean_salience" 
   
   set-current-plot-pen "c_global"
   plot mean_c
   set-current-plot-pen "cn_global"
   plot mean_cn
   set-current-plot-pen "c_pink"
   plot mean_c_pink
   set-current-plot-pen "cn_pink"
   plot mean_cn_pink
   set-current-plot-pen "c_blue"
   plot mean_c_blue
   set-current-plot-pen "cn_blue"
   plot mean_cn_blue
  
  ;; graficar histograma para cada grupo
   set-current-plot "histogram"
  
   set-current-plot-pen "c"
   set-plot-x-range 0 1.0001
   set-histogram-num-bars 10
   histogram list_c 
    
   set-current-plot-pen "cn"
   set-plot-x-range 0 1.0001
   set-histogram-num-bars 10
   histogram list_cn
 
   set-current-plot-pen "c_pink"
   set-plot-x-range 0 1.0001
   set-histogram-num-bars 10
   histogram list_c_pink
     
   set-current-plot-pen "cn_pink"
   set-plot-x-range 0 1.0001
   set-histogram-num-bars 10
   histogram list_cn_pink
   
   set-current-plot-pen "c_blue"
   set-plot-x-range 0 1.0001
   set-histogram-num-bars 10
   histogram list_c_blue
   
   set-current-plot-pen "cn_blue"
   set-plot-x-range 0 1.0001
   set-histogram-num-bars 10
   histogram list_cn_blue
end

to converge

   set idx1 ticks
   
   while [idx1 >= nSteps][set idx1 (idx1 - nSteps) ]
   
   set listConv_C  replace-item idx1 listConv_C  mean_c
   set listConv_Cn replace-item idx1 listConv_Cn mean_cn
   
   set listConv_C_blue   replace-item idx1 listConv_C_blue  mean_c_blue
   set listConv_Cn_blue  replace-item idx1 listConv_Cn_blue mean_cn_blue
  
   set listConv_C_pink   replace-item idx1 listConv_C_pink  mean_c_pink
   set listConv_Cn_pink  replace-item idx1 listConv_Cn_pink mean_cn_pink
   
   set idxConv_C  standard-deviation listConv_C 
   set idxConv_Cn standard-deviation listConv_Cn 
   
   set idxConv_C_blue  standard-deviation listConv_C_blue 
   set idxConv_Cn_blue standard-deviation listConv_Cn_blue 
   
   set idxConv_C_pink  standard-deviation listConv_C_pink 
   set idxConv_Cn_pink standard-deviation listConv_Cn_pink 

end 

@#$#@#$#@
GRAPHICS-WINDOW
207
12
643
469
-1
-1
38.73
1
10
1
1
1
0
1
1
1
0
10
0
10
0
0
1
ticks

CC-WINDOW
5
520
1097
615
Command Center
0

SLIDER
6
129
178
162
k2
k2
0
50
10
1
1
NIL
HORIZONTAL

SLIDER
10
87
182
120
u
u
0
50
6
1
1
NIL
HORIZONTAL

SLIDER
8
398
180
431
number_people
number_people
0
100
100
1
1
NIL
HORIZONTAL

BUTTON
8
472
71
505
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

SLIDER
10
47
182
80
s1
s1
1
50
9
1
1
NIL
HORIZONTAL

SLIDER
7
169
179
202
s2
s2
0
50
7
1
1
NIL
HORIZONTAL

MONITOR
4
292
61
337
NIL
pa1_C
17
1
11

MONITOR
73
292
130
337
NIL
pa2_C
17
1
11

MONITOR
5
343
62
388
NIL
pa1_Cn
17
1
11

MONITOR
74
344
131
389
NIL
pa2_Cn
17
1
11

SLIDER
10
10
182
43
k1
k1
0
50
10
1
1
NIL
HORIZONTAL

BUTTON
76
473
139
506
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

PLOT
648
16
1088
224
mean_salience
number_step
value
0.0
100.0
0.0
1.0
true
true
PENS
"c_global" 1.0 0 -10899396 true
"cn_global" 1.0 0 -2674135 true
"c_pink" 1.0 0 -2064490 true
"cn_pink" 1.0 0 -8630108 true
"c_blue" 1.0 0 -7500403 true
"cn_blue" 1.0 0 -16777216 true

SLIDER
654
394
826
427
initial_c_Blue
initial_c_Blue
0
1
0.92
.01
1
NIL
HORIZONTAL

SLIDER
653
434
825
467
initial_cn_Blue
initial_cn_Blue
0
1
0.92
.01
1
NIL
HORIZONTAL

PLOT
649
231
1087
393
histogram
NIL
NIL
0.0
10.0
0.0
10.0
true
true
PENS
"c" 1.0 1 -10899396 true
"cn" 1.0 1 -2674135 true
"c_pink" 1.0 1 -2064490 true
"cn_pink" 1.0 1 -8630108 true
"c_blue" 1.0 1 -7500403 true
"cn_blue" 1.0 1 -16777216 true

SLIDER
8
434
180
467
ratio_pink
ratio_pink
0
1
0.1
0.01
1
NIL
HORIZONTAL

SLIDER
6
208
178
241
power_blue
power_blue
0
100
1
1
1
NIL
HORIZONTAL

SLIDER
8
248
180
281
power_pink
power_pink
0
100
1
1
1
NIL
HORIZONTAL

MONITOR
135
293
185
338
NIL
ratioPower_Blue_Pink
17
1
11

SLIDER
835
395
1007
428
initial_c_Pink
initial_c_Pink
0
1
0.55
.01
1
NIL
HORIZONTAL

SLIDER
835
435
1007
468
initial_cn_Pink
initial_cn_Pink
0
1
0.55
.01
1
NIL
HORIZONTAL

@#$#@#$#@
WHAT IS IT?
-----------
This section could give a general understanding of what the model is trying to show or explain.


HOW IT WORKS
------------
This section could explain what rules the agents use to create the overall behavior of the model.


HOW TO USE IT
-------------
This section could explain how to use the model, including a description of each of the items in the interface tab.


THINGS TO NOTICE
----------------
This section could give some ideas of things for the user to notice while running the model.


THINGS TO TRY
-------------
This section could give some ideas of things for the user to try to do (move sliders, switches, etc.) with the model.


EXTENDING THE MODEL
-------------------
This section could give some ideas of things to add or change in the procedures tab to make the model more complicated, detailed, accurate, etc.


NETLOGO FEATURES
----------------
This section could point out any especially interesting or unusual features of NetLogo that the model makes use of, particularly in the Procedures tab.  It might also point out places where workarounds were needed because of missing features.


RELATED MODELS
--------------
This section could give the names of models in the NetLogo Models Library or elsewhere which are of related interest.


CREDITS AND REFERENCES
----------------------
This section could contain a reference to the model's URL on the web if it has one, as well as any other necessary credits or references.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 4.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="size_pa1_88_power_1_rPink_08" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100000"/>
    <exitCondition>(idxConv_C &lt; 0.05) and (idxConv_Cn &lt; 0.05) and (idxConv_C_blue &lt; 0.05) and (idxConv_Cn_blue &lt; 0.05) and (idxConv_C_pink &lt; 0.05) and (idxConv_Cn_pink &lt; 0.05)</exitCondition>
    <metric>pa1_C</metric>
    <metric>pa2_C</metric>
    <metric>pa1_Cn</metric>
    <metric>pa2_Cn</metric>
    <metric>mean_c</metric>
    <metric>mean_cn</metric>
    <metric>mean_c_pink</metric>
    <metric>mean_cn_pink</metric>
    <metric>mean_c_blue</metric>
    <metric>mean_cn_blue</metric>
    <enumeratedValueSet variable="k1">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="s1">
      <value value="8.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="u">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="k2">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="s2">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial_c_Pink">
      <value value="0.55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial_cn_Pink">
      <value value="0.55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial_c_Blue">
      <value value="0.92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial_cn_Blue">
      <value value="0.92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="power_blue">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="power_pink">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio_pink">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_people">
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="size_pa1_86_87_power_1" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100000"/>
    <exitCondition>(idxConv_C &lt; 0.05) and (idxConv_Cn &lt; 0.05) and (idxConv_C_blue &lt; 0.05) and (idxConv_Cn_blue &lt; 0.05) and (idxConv_C_pink &lt; 0.05) and (idxConv_Cn_pink &lt; 0.05)</exitCondition>
    <metric>pa1_C</metric>
    <metric>pa2_C</metric>
    <metric>pa1_Cn</metric>
    <metric>pa2_Cn</metric>
    <metric>mean_c</metric>
    <metric>mean_cn</metric>
    <metric>mean_c_pink</metric>
    <metric>mean_cn_pink</metric>
    <metric>mean_c_blue</metric>
    <metric>mean_cn_blue</metric>
    <enumeratedValueSet variable="k1">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="s1">
      <value value="8.6"/>
      <value value="8.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="u">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="k2">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="s2">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial_c_Pink">
      <value value="0.55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial_cn_Pink">
      <value value="0.55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial_c_Blue">
      <value value="0.92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial_cn_Blue">
      <value value="0.92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="power_blue">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="power_pink">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio_pink">
      <value value="0.1"/>
      <value value="0.2"/>
      <value value="0.3"/>
      <value value="0.4"/>
      <value value="0.6"/>
      <value value="0.8"/>
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_people">
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
