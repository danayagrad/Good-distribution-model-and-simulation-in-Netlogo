;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; set model properties,  define environment, agents, and their properties.

globals [      ; Define global variables which are the properties of the whole system.
  total-order
  cost
  backlog
  order-remaining
  quantity-to-hub
  quantity-to-ret
  late-delivery
  bottle-neck
  monthly-total-order
  total-late-delivery
  absolute-demand
  old-late-delivery
]
breed [warehouses warehouse]  ; define agents.
breed [stations station]

warehouses-own [ ; set properties of warehouse.
  max-cap
  available-cap1
]

stations-own [ ; set properties of station.
  max-cap
]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; initialize environment: all displays and time.

to setup
  clear-all
  reset-ticks
  layout
  initialize
end

to go
  if ticks < 30 [ ; model should run 30 days, mimic actual performance measurement in reallife.
  process-order
  tick
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Set up graphics.

to layout  ; set location of the graphic, howerver in this analysis distance between all turtles is assume to be 1.
   create-stations 1 [ ; set station (retailers, in thhis case retailers is assumed to be a group)
    setxy 7 5          ; station position on display screen.
    set color 126      ; station colour.
    set shape "house efficiency"  ; station shape.
    set size 3                    ; size of station icon.
  ]
  create-stations 1[ ; set station ( hub)
    setxy 6 0
    set color 56
    set shape "house ranch"
    set size 5
  ]

  create-warehouses 1 [ ; set warehouse
    setxy -7 0
    set color 44
    set shape "building store"
    set size 7
  ]

  ask warehouses  [create-link-to station 0] ; create connection between warehouse and retailers.
  ask warehouses  [create-link-to station 1] ; create connection between warehouse and hub.
  ask station 1 [create-link-to station 0]   ; create connection between hun and retailers.

end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; set rules and commands for agents to follow.

to initialize  ; initialize value of agent variables at the beginning.
  ask warehouses [
    set cost 0
    set total-order 0
    set backlog 0
    set available-cap1 0

    set late-delivery 0
    set monthly-total-order 0
    set total-late-delivery 0
    set absolute-demand 0
  ]
end

to  process-order ; rules for ordering, direct delivery, and via hub delivery.
    ask warehouses [
    set old-late-delivery old-late-delivery + late-delivery           ; store yesterday backlog for future use.
    set absolute-demand demand + random demand-factor-range           ; absolute demand = base demand + random no.
    set monthly-total-order monthly-total-order + absolute-demand     ; accummulated total order until current tick.
    set total-order absolute-demand + backlog                         ; current tick total order = absolute demand + backlog
    set bottle-neck min list warehouse-max-capacity hub-max-capacity

    if warehouse-max-capacity >= hub-max-capacity [                   ; action in case warehouse cap is more than hub cap.
      set max-cap warehouse-max-capacity
      set quantity-to-hub min list hub-max-capacity total-order       ; first, calculate quantity send to hub
      set available-cap1 (max-cap - quantity-to-hub)                  ; calculate if warehoues still has any capcity left after delivery to hub
      if quantity-to-hub >= (hub-max-capacity * 0.8) [set cost cost + (1.8 * quantity-to-hub)]    ; calculate cost from delivery to hub and from hub to retailers.
      if quantity-to-hub < (hub-max-capacity * 0.8) [set cost cost + (2.16 * quantity-to-hub)]    ; calculate cost from delivery to hub and from hub to retailers.
      set order-remaining (total-order - quantity-to-hub)             ; calculate remaining order at warehouse.
      if order-remaining > 0 [
        set quantity-to-ret min list round((available-cap1 * 0.5)) order-remaining                 ; if there is still remaining order and warheouse still have capacity.
        if quantity-to-ret >= (warehouse-max-capacity * 0.8) [set cost cost +(2.75  * quantity-to-ret) ]        ; calculate cost from delivery directly to retailers.
        if quantity-to-ret < (warehouse-max-capacity * 0.8) [set cost cost + (3.3 * quantity-to-ret)]
        let available-cap2 (available-cap1 - (quantity-to-ret * 2))

    ]
  ]
    if warehouse-max-capacity < hub-max-capacity [                     ; action in case warehouse cap is less than hub cap.
      set max-cap warehouse-max-capacity
      set quantity-to-hub min list warehouse-max-capacity total-order
      set available-cap1 (max-cap - quantity-to-hub)
      if quantity-to-hub >= (hub-max-capacity * 0.8) [set cost cost + (1.8 * quantity-to-hub)]
      if quantity-to-hub < (hub-max-capacity * 0.8) [set cost cost + (2.16 * quantity-to-hub)]
      set order-remaining (total-order - quantity-to-hub)
      if order-remaining > 0 [
        set quantity-to-ret min list round((available-cap1 * 0.5)) order-remaining
        if quantity-to-ret >= (warehouse-max-capacity * 0.8) [set cost cost +(2.75  * quantity-to-ret) ]
        if quantity-to-ret < (warehouse-max-capacity * 0.8) [set cost cost + (3.3 * quantity-to-ret)]
        let available-cap2 (available-cap1 - (quantity-to-ret * 2))


      ]
    ]

     set backlog (order-remaining - quantity-to-ret)                       ; calculate remaining order for the current tick which will be carried orver to next tick.
     set late-delivery max list 0 (backlog - bottle-neck - old-late-delivery)              ; if order remain at warehouse more than 2 days, is is considered late delivery.
     set cost cost + (0 * late-delivery)                                   ; calculate penalty cost of late delivery.
     set total-late-delivery total-late-delivery + late-delivery           ; sum total late delivery untill current tick.
  ]


end

to-report average-total-cost;
  report  cost  / (monthly-total-order - backlog)                          ; calculate avarge delivery cost of all orders untill current tick.
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
448
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
8
20
71
53
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
10
72
73
105
go
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
9
159
201
192
demand
demand
0
150
120.0
5
1
NIL
HORIZONTAL

SLIDER
10
278
200
311
hub-max-capacity
hub-max-capacity
0
210
100.0
30
1
NIL
HORIZONTAL

SLIDER
11
328
200
361
warehouse-max-capacity
warehouse-max-capacity
0
200
150.0
50
1
NIL
HORIZONTAL

PLOT
665
45
930
223
Orders
NIL
NIL
0.0
30.0
0.0
5.0
true
false
"" ""
PENS
"Lat deliver" 1.0 0 -2674135 true "" "plot total-late-delivery"
"Total Order" 1.0 0 -14070903 true "" "plot monthly-total-order"

PLOT
667
258
932
436
Total Delivery Cost
NIL
NIL
0.0
30.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -8630108 true "" "plot cost"

MONITOR
965
73
1072
118
backlog
backlog
17
1
11

MONITOR
967
136
1072
181
NIL
total-order
17
1
11

MONITOR
1102
72
1209
117
order-remaining
order-remaining
17
1
11

MONITOR
1103
137
1210
182
NIL
quantity-to-ret
17
1
11

MONITOR
969
199
1072
244
NIL
late-delivery
17
1
11

MONITOR
1103
198
1209
243
quantity-to-hub
quantity-to-hub
17
1
11

BUTTON
104
76
167
109
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1102
10
1210
55
monthly-total-order
monthly-total-order
17
1
11

SLIDER
9
212
198
245
demand-factor-range
demand-factor-range
0
50
22.0
1
1
NIL
HORIZONTAL

MONITOR
963
10
1072
55
total demand
absolute-demand
17
1
11

MONITOR
966
387
1083
432
average-total-cost
average-total-cost
17
1
11

@#$#@#$#@
## WHAT IS IT?

A system of good physical distribution from warehouse to distribution hub and to retailers. In this model, retailers is considered as a whole rather than only one. The distance between the is assumed 0 and delivery to the retailers is assumed to delivery to all retailers in the nearby area.

## HOW IT WORKS
Warehouse is a main actor in this model. It decides to deliver the goods between 2 route options for shipping, either via a hub, or direct delivery to the customer.The decision rules are to choose the cheapest cost route first if the capacity of the route is available.

The warehouse can’t deliver more than its maximum capacity. One order ship to a hub, taking one capacity, while one order delivers directly to the retailer and takes 2 capacities. 

For every delivered order, cost incurs.It is assumed that the cost via the hub route is cheaper, as the distance it runs on an empty truck from the retailers back to the hub is shorter than from the retailers to the warehouse. Moreover, to mimic reality, it is also assumed that any delivery that has orders less than 80% of max capacity costs 20% more than delivery with a full, or more than 80% of max, capacity.However, the cost parameters used in this model isn't real data.

Any order that is not delivered within 2 days from the day demand is generated, is considered a late delivery order. 


## HOW TO USE IT

1. Adjust based demand and demand-factor-range to set daily demand.
2. Adjust delivery capacity of distribution hub and warehouse.
3. Press setup to reset model to its initial state.
3. pres go to run the model.

There are 3 output interface:
1. Order plot: displays number of total order and late delivery from beginning until current plot.
2. Total Delivery Cost plot: displays accummulated total cost of delivery. 
3. Average delivery cost monitor: display actual average delivery cost per order.

Other monitors are in process monitoring interfaces.They are variables that used in calculate outputs above.

## THINGS TO NOTICE

The change in average cost, and total number of late delivery.

## THINGS TO TRY

Move sliders demand and capacity sliders. Play with different combinations.

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

The penalty financial cost for late delivery code was written. However, most of late deliveries in real life doesn't result in direct financial penalty.Hence, the paramerter of this penalty is set to zero.

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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

building store
false
0
Rectangle -7500403 true true 30 45 45 240
Rectangle -16777216 false false 30 45 45 165
Rectangle -7500403 true true 15 165 285 255
Rectangle -16777216 true false 120 195 180 255
Line -7500403 true 150 195 150 255
Rectangle -16777216 true false 30 180 105 240
Rectangle -16777216 true false 195 180 270 240
Line -16777216 false 0 165 300 165
Polygon -7500403 true true 0 165 45 135 60 90 240 90 255 135 300 165
Rectangle -7500403 true true 0 0 75 45
Rectangle -16777216 false false 0 0 75 45

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

house bungalow
false
0
Rectangle -7500403 true true 210 75 225 255
Rectangle -7500403 true true 90 135 210 255
Rectangle -16777216 true false 165 195 195 255
Line -16777216 false 210 135 210 255
Rectangle -16777216 true false 105 202 135 240
Polygon -7500403 true true 225 150 75 150 150 75
Line -16777216 false 75 150 225 150
Line -16777216 false 195 120 225 150
Polygon -16777216 false false 165 195 150 195 180 165 210 195
Rectangle -16777216 true false 135 105 165 135

house colonial
false
0
Rectangle -7500403 true true 270 75 285 255
Rectangle -7500403 true true 45 135 270 255
Rectangle -16777216 true false 124 195 187 256
Rectangle -16777216 true false 60 195 105 240
Rectangle -16777216 true false 60 150 105 180
Rectangle -16777216 true false 210 150 255 180
Line -16777216 false 270 135 270 255
Polygon -7500403 true true 30 135 285 135 240 90 75 90
Line -16777216 false 30 135 285 135
Line -16777216 false 255 105 285 135
Line -7500403 true 154 195 154 255
Rectangle -16777216 true false 210 195 255 240
Rectangle -16777216 true false 135 150 180 180

house efficiency
false
0
Rectangle -7500403 true true 180 90 195 195
Rectangle -7500403 true true 90 165 210 255
Rectangle -16777216 true false 165 195 195 255
Rectangle -16777216 true false 105 202 135 240
Polygon -7500403 true true 225 165 75 165 150 90
Line -16777216 false 75 165 225 165

house ranch
false
0
Rectangle -7500403 true true 270 120 285 255
Rectangle -7500403 true true 15 180 270 255
Polygon -7500403 true true 0 180 300 180 240 135 60 135 0 180
Rectangle -16777216 true false 120 195 180 255
Line -7500403 true 150 195 150 255
Rectangle -16777216 true false 45 195 105 240
Rectangle -16777216 true false 195 195 255 240
Line -7500403 true 75 195 75 240
Line -7500403 true 225 195 225 240
Line -16777216 false 270 180 270 255
Line -16777216 false 0 180 300 180

house two story
false
0
Polygon -7500403 true true 2 180 227 180 152 150 32 150
Rectangle -7500403 true true 270 75 285 255
Rectangle -7500403 true true 75 135 270 255
Rectangle -16777216 true false 124 195 187 256
Rectangle -16777216 true false 210 195 255 240
Rectangle -16777216 true false 90 150 135 180
Rectangle -16777216 true false 210 150 255 180
Line -16777216 false 270 135 270 255
Rectangle -7500403 true true 15 180 75 255
Polygon -7500403 true true 60 135 285 135 240 90 105 90
Line -16777216 false 75 135 75 180
Rectangle -16777216 true false 30 195 93 240
Line -16777216 false 60 135 285 135
Line -16777216 false 255 105 285 135
Line -16777216 false 0 180 75 180
Line -7500403 true 60 195 60 240
Line -7500403 true 154 195 154 255

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

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Sufficient" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="30"/>
    <metric>average-total-cost</metric>
    <metric>monthly-total-order</metric>
    <metric>cost</metric>
    <metric>late-delivery</metric>
    <metric>total-late-delivery</metric>
    <enumeratedValueSet variable="demand-factor-range">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="demand">
      <value value="120"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hub-max-capacity">
      <value value="140"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="warehouse-max-capacity">
      <value value="150"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hubmorewareless" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="30"/>
    <metric>average-total-cost</metric>
    <metric>monthly-total-order</metric>
    <metric>cost</metric>
    <metric>late-delivery</metric>
    <metric>total-late-delivery</metric>
    <enumeratedValueSet variable="demand-factor-range">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="demand">
      <value value="120"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hub-max-capacity">
      <value value="140"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="warehouse-max-capacity">
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hublesswaremore" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="30"/>
    <metric>average-total-cost</metric>
    <metric>monthly-total-order</metric>
    <metric>cost</metric>
    <metric>late-delivery</metric>
    <metric>total-late-delivery</metric>
    <enumeratedValueSet variable="demand-factor-range">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="demand">
      <value value="120"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hub-max-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="warehouse-max-capacity">
      <value value="150"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="bothless" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="30"/>
    <metric>average-total-cost</metric>
    <metric>monthly-total-order</metric>
    <metric>cost</metric>
    <metric>late-delivery</metric>
    <metric>total-late-delivery</metric>
    <enumeratedValueSet variable="demand-factor-range">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="demand">
      <value value="120"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hub-max-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="warehouse-max-capacity">
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="equal" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="30"/>
    <metric>average-total-cost</metric>
    <metric>monthly-total-order</metric>
    <metric>cost</metric>
    <metric>late-delivery</metric>
    <metric>total-late-delivery</metric>
    <enumeratedValueSet variable="demand-factor-range">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="demand">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hub-max-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="warehouse-max-capacity">
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="bigrange" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="30"/>
    <metric>average-total-cost</metric>
    <metric>monthly-total-order</metric>
    <metric>cost</metric>
    <metric>late-delivery</metric>
    <metric>total-late-delivery</metric>
    <enumeratedValueSet variable="demand-factor-range">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="demand">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hub-max-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="warehouse-max-capacity">
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
0
@#$#@#$#@
