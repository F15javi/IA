patches-own [
  snake-lenght1
  snake-lenght2
  father     ; Previous patch in this partial path
  Cost-path  ; Stores the cost of the path to the current patch
  visited?   ; has the path been visited previously? That is,
  active?    ; at least one path has been calculated going through this patch

]

globals [
  score1
  score2
  new-heading
  old-heading

  p-valids   ; Valid Patches for moving not wall)
  p-valids2   ; Valid Patches for moving not wall)
  Start1     ; Starting patch
  Start2
  Final-Cost ; The final cost of the path given by A*
]



to setup
  ca

  set score1 0
  set score2 0
   cro 1 [

    set shape "square"
    set size 1.2
    set color blue


  ]
  cro 1 [

    set shape "square"
    set size 1.2
    set color brown


  ]
  Ask patches
  [
    set pcolor green
    set father nobody
    set Cost-path 0
    set visited? false
    set active? false
  ]


  ask one-of patches with [distancexy 0 0 > 5 AND abs pxcor != 16 and abs pycor != 16]
  [set  pcolor yellow]
  ask patches with [abs pxcor = 0 or abs pycor = 0 or abs pxcor = 32 or abs pycor = 32] [set pcolor red]
  set p-valids patches with [pcolor = green or pcolor = yellow]
  set p-valids2 patches with [pcolor = green or pcolor = yellow]
  set start1 one-of patches with [pxcor = 16 and pycor = 17]
  set start2 one-of patches with [pxcor = 10 and pycor = 10]

end


; Patch report to estimate the total expected cost of the path starting from
; in Start, passing through it, and reaching the #Goal
to-report Total-expected-cost [#Goal]
  report Cost-path + Heuristic #Goal
end

; Patch report to reurtn the heuristic (expected length) from the current patch
; to the #Goal
to-report Heuristic [#Goal]
  report distance #Goal
end





; A* algorithm. Inputs:
;   - #Start     : starting point of the search.
;   - #Goal      : the goal to reach.
;   - #valid-map : set of agents (patches) valid to visit.
; Returns:
;   - If there is a path : list of the agents of the path.
;   - Otherwise          : false

to-report A* [#Start #Goal #valid-map]
  ; clear all the information in the agents
  ask #valid-map with [visited?]
  [
    set father nobody
    set Cost-path 0
    set visited? false
    set active? false
  ]
  ; Active the staring point to begin the searching loop
  ask #Start
  [
    set father self
    set visited? true
    set active? true
  ]
  ; exists? indicates if in some instant of the search there are no options to
  ; continue. In this case, there is no path connecting #Start and #Goal
  let exists? true
  ; The searching loop is executed while we don't reach the #Goal and we think
  ; a path exists
  while [not [visited?] of #Goal and exists?]
  [
    ; We only work on the valid pacthes that are active
    let options #valid-map with [active?]
    ; If any
    ifelse any? options
    [
      ; Take one of the active patches with minimal expected cost
      ask min-one-of options [Total-expected-cost #Goal]
      [
        ; Store its real cost (to reach it) to compute the real cost
        ; of its children
        let Cost-path-father Cost-path
        ; and deactivate it, because its children will be computed right now
        set active? false
        ; Compute its valid neighbors
        let valid-neighbors neighbors4 with [member? self #valid-map]
        ask valid-neighbors
        [
          ; There are 2 types of valid neighbors:
          ;   - Those that have never been visited (therefore, the
          ;       path we are building is the best for them right now)
          ;   - Those that have been visited previously (therefore we
          ;       must check if the path we are building is better or not,
          ;       by comparing its expected length with the one stored in
          ;       the patch)
          ; One trick to work with both type uniformly is to give for the
          ; first case an upper bound big enough to be sure that the new path
          ; will always be smaller.
          let t ifelse-value visited? [ Total-expected-cost #Goal] [2 ^ 20]
          ; If this temporal cost is worse than the new one, we substitute the
          ; information in the patch to store the new one (with the neighbors
          ; of the first case, it will be always the case)
          if t > (Cost-path-father + distance myself + Heuristic #Goal)
          [
            ; The current patch becomes the father of its neighbor in the new path
            set father myself
            set visited? true
            set active? true
            ; and store the real cost in the neighbor from the real cost of its father
            set Cost-path Cost-path-father + distance father
            set Final-Cost precision Cost-path 3
          ]
        ]
      ]
    ]
    ; If there are no more options, there is no path between #Start and #Goal
    [
      set exists? false
    ]
  ]
  ; After the searching loop, if there exists a path
  ifelse exists?
  [
    ; We extract the list of patches in the path, form #Start to #Goal
    ; by jumping back from #Goal to #Start by using the fathers of every patch
    let current #Goal
    set Final-Cost (precision [Cost-path] of #Goal 3)
    let rep (list current)
    While [current != #Start]
    [
      set current [father] of current
      set rep fput current rep
    ]
    report rep
  ]
  [
    ; Otherwise, there is no path, and we return False
    report false
  ]
end

to-report Look-for-Goal1


  let Goal one-of patches with [pcolor = yellow]

  ; Compute the path between Start and Goal
  let path A* Start1 Goal p-valids
  set p-valids patches with [pcolor != blue and pcolor != red and pcolor != brown]


  ; If any...

  if path != false [




    ; Set the Goal and the new Start point
    if length path > 1 [set Start1 item 1 path]
    if length path <= 1 [set Start1 Goal]



    report path
  ]

end
to-report Look-for-Goal2


  let Goal2 one-of patches with [pcolor = yellow]

  ; Compute the path between Start and Goal
  let path A* Start2 Goal2 p-valids2
  set p-valids2 patches with [pcolor != blue and pcolor != red and pcolor != brown]



  print "#######################"
  print Start2
  print Goal2
  print path

  if path != false [




    ; Set the Goal and the new Start point
    if length path > 1 [set Start2 item 1 path]
    if length path <= 1 [set Start2 Goal2]



    report path
  ]

end

 to go
  LET not-dead true

  let camino1 Look-for-Goal1
  let camino2 Look-for-Goal2

  ask turtles with [who = 0] [move-to item 0 camino1
   if pcolor = red  or pcolor = black [set not-dead false]

    if pcolor = yellow
    [
      set score1 (score1 + 1)
      ask one-of patches with [distance turtle 0 > 5 AND pcolor = green]
      [set pcolor yellow]
    ]


  set snake-lenght1 score1 + 5
    set pcolor blue

  ask patches with [snake-lenght1 > 0]
  [set snake-lenght1 (snake-lenght1 - 1)
    If snake-lenght1 = 0 [set pcolor green]]

  ]
    If not-dead = false [finish-game stop]
  wait 1 / 8
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ask turtles with [who = 1] [move-to item 0 camino2
   if pcolor = red  or pcolor = black [set not-dead false]

    if pcolor = yellow
    [
      set score2 (score2 + 1)
      ask one-of patches with [distance turtle 0 > 5 AND pcolor = green]
      [set pcolor yellow]
    ]


  set snake-lenght2 score2 + 5
    set pcolor brown

  ask patches with [snake-lenght2 > 0]
  [set snake-lenght2 (snake-lenght2 - 1)
    If snake-lenght2 = 0 [set pcolor green]]

  ]
    If not-dead = false [finish-game stop]
  wait 1 / 8
end





to move-left

  ask turtles
  [set heading 270]

end
to move-right
  ask turtles
  [set heading 90]
end
to move-up
  ask turtles
  [set heading 0]
end
to move-down
  ask turtles
  [set heading 180]
end
to finish-game
  stop
 ; ct cp
 ;; ask patch 22 16
 ; [set plabel "GAME OVER!"
 ;  set plabel-color white]
end
@#$#@#$#@
GRAPHICS-WINDOW
212
10
649
448
-1
-1
13.0
1
30
1
1
1
0
0
0
1
0
32
0
32
0
0
1
ticks
60.0

BUTTON
720
181
784
214
up
move-up\n
NIL
1
T
OBSERVER
NIL
W
NIL
NIL
1

BUTTON
718
258
789
291
down
move-down\n
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
656
219
723
252
left
move-left\n
NIL
1
T
OBSERVER
NIL
A
NIL
NIL
1

BUTTON
788
218
856
251
right
move-right
NIL
1
T
OBSERVER
NIL
D
NIL
NIL
1

BUTTON
70
33
197
66
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
88
80
196
113
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
50
280
112
325
SCORE 1
score1
0
1
11

MONITOR
120
280
182
325
SCORE 2
score2
17
1
11

@#$#@#$#@
## WHAT IS IT?

It is the **Snake Game** developed into a new _Titanic SS Model_! Your job is to not crash into the _magenta_ mines and discover the many illustrious wonders of the sea while dropping your passangers into the green patches in the ocean. This increases your fame and makes you a target for natorious pirates especially after getting a score of 5.

## HOW IT WORKS

You first need to press the **Restart/Start** button and then press **Start Going**. After taking these two necessary precautions for your ship, you can finally set off! While you are at it, make _sure_ to not crash into any red or magenta and collect as much _green_ as possible. Once you feel **adventerous** enough (no need to fear: no sharks), you can face the drunken pirates by pressing p or **challenge mode**. They will try to manage their way into your coffer of a ship. Be careful! 



## CREDITS AND REFERENCES

The Movie: _pirates of the carrebien_ and _Titanic_
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

ship
true
10
Polygon -13345367 true true 90 90 150 60 150 105 180 105 180 120 165 120 165 150 150 150 150 195 90 150 90 90 90 90

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
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
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
1
@#$#@#$#@
