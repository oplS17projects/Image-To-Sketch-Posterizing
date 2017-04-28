# Image To Sketch posterizing

## Duy Truong
### April 28, 2017

# Overview
For this project, Our team try to read the Image Data which is RGB value and store it. After that Our team edit there value to create new image. Compiling these image we have sketching image.

**Authorship note:** All of the code described here was written by myself.

# Libraries Used
For the algorithm 1:

```
; for get-pixel-color
(require (except-in picturing-programs))
(require racket/string)

;; This library is use for do the gaussian blur
(require images/flomap)
(require (except-in racket/draw make-pen make-color))
```

* The ```(except-in picturing-programs)``` this library is used to read the pixel-color.
* The ```racket/string``` this library is used to convert from string number and store it to list.
* The ```images/flomap``` this library is used to convert the image to flomap and used that flomap to applied the gaussian blur.
* The ```(except-in racket/draw make-pen make-color)``` this library is used convert image to bitmap% and convert bitmap% to image.

For the algorithm 2:

```
(require images/flomap)
(require (except-in racket/draw make-pen make-color))
```

* The ```images/flomap``` library is used to get pixel from bitmap% and convert flomap back to bitmap%.
* The ```(except-in racket/draw make-pen make-color)``` this library is used convert image to bitmap% and convert bitmap% to image.


# Key Code Excerpts

The key of this project is storing pixel data and edit the data. Our team have 2 algorithm to store the data. I store the data by using list and 2-D list my partner find the way to store it into 24bit number. I used some knowledge which I have learned in UMass Lowell's COMP.3010 OPL class to applied to this project. 

Five examples are shown and they are individually numbered.

## 1. Joining the 2-D list become 1 list Using  recursive process and append.

* Input and Output: It will get the 2-D list and merge it to 1-D list.

* Code:

```
;;(define (join-list-next list-calculated count max result)
;;  (if (= count max)
;;      result
;;      (join-list list-calculated (+ count 1) max (append result (list-ref list-calculated count))))) 

;; Function join-list take a 2D-list and return 1D-list
(define (join-list lst count max result)
  (local
    [(define ResultList (MakeColorObjectList lst img-width img-height))]
    (append* ResultList)))
  ;(join-list-next ResultList count max result)))
```  


* Disscusion: To join the list, First time I try to use the recursive process and append. when I run it take too much time. So I try to use the append* which have in the racket library, the running time is shorter. Final I choose to use the append* for project to reduce the running time.

When we compare the algorithm 1 (using 2D-list) and algorithm 2 (1 list). Because in the algorithm 2 we only have one list, so we can skip this step. It reduce the running time a lot.


## 2. Color for gray sacle using recursive process, cons and Procedural Abstraction.

* Input and Output: It will get one number (24bit number of RGB) and return one number 24bits of gray scale.

* Code:

```
(define (get-gray-value num)
  (local
    [(define red (bitwise-bit-field num 0 8))
     (define green (bitwise-bit-field num 8 16))
     (define blue (bitwise-bit-field num 16 24))
     (define value (quotient (+ red green blue) 3))]
    (join-value value value value)))


(define (gray-scale-helper result lst )
  (if (null? lst)
      result
      (gray-scale-helper (cons (get-gray-value (car lst)) result) (cdr lst))))

(define gray-scale
  (gray-scale-helper '() RGBmap))
```

* Discussion: for this code, I use the Procedural Abstraction ```null?``` to check the list is empty or not. After that I applied the recursive process concept which I learned in OPL class. For the result, I used cons to add new element to the list.

When we compare with the algorithm 1.

```
(define (gray-point-value lst)
  (local
    [(define gray (quotient (+ (list-ref lst 0) (list-ref lst 1) (list-ref lst 2)) 3))]
    (list gray gray gray)))

(define (GrayList-iter-value data width height)
  (for/list ([x (in-range 0 height)])
    (for/list ([y (in-range 0 width)])
      (gray-point-value (list-ref (list-ref data x) y))
      )))
```
The algorithm 1 will make more time to run because it using 2 for/list. we need to store it 2 time to create list in list.


## 3. Initialization using a Global Object

* Disscusion: For the algorithm 1, I define a global variable. That can help me to avoid to re-call the function multible time and it is easy to check and apply the data to new filter.

* Code:

```
(define InvertColorList (InvertColor GrayList))


(define BWimage (color-list->bitmap (join-list InvertColorList 0 (length InvertColorList) null) img-width img-height))
```
## 3. Calculating Posterizing Point by using Conditional

* Discustion: This function will calculate the new pixel base on the numOfArea and numOfValues and posterizing value. If the posterizing value is low it will reduce the color of the picture. For example if your posterizing and is 2. The output of the face picture will be the face is black and the backround is white. I tried to look up function can help me to rounding number but I could not find it. So I wrote round-num function. For example 2.5 -> 3 and 2.4 -> 2. I use if and cond a lot for this function. I also use the ```local``` to create new variable only use inside the function.

* Code:
```
define (round-num num-ori num-int)
  (if (< (- num-ori num-int) 0.5)
      (floor num-ori)
      (ceiling num-ori)))

(define (posterize-point lst numOfArea numOfValues)
  (local
    [(define redAreaFloat (/ (list-ref lst 0) numOfArea))
     (define redArea (round-num redAreaFloat (floor redAreaFloat)))
     (define greenAreaFloat (/ (list-ref lst 1) numOfArea))
     (define greenArea (round-num greenAreaFloat (floor greenAreaFloat)))
     (define blueAreaFloat (/ (list-ref lst 2) numOfArea))
     (define blueArea (round-num blueAreaFloat (floor blueAreaFloat)))
     (define newredfloat 0.0)
     (define newgreengfloat 0.0)
     (define newbluefloat 0.0)
     (define newred 0)
     (define newgreen 0)
     (define newblue 0)]
    
    (cond
      [(> redArea redAreaFloat)(set! redArea (- redArea 1))])
    (set! newredfloat (* numOfValues redArea))
    (set! newred (round-num newredfloat (floor newredfloat)))
    (cond
      [(> newred newredfloat)(set! newred (- newred 1))])
	  
    (cond
      [(> greenArea greenAreaFloat)(set! greenArea (- greenArea 1))])
    (set! newgreengfloat (* numOfValues greenArea))
    (set! newgreen (round-num newgreengfloat (floor newgreengfloat)))
    (cond
      [(> newgreen newgreengfloat)(set! newgreen (- newgreen 1))])
    
    (cond
      [(> blueArea blueAreaFloat)(set! blueArea (- blueArea 1))])
    (set! newbluefloat (* numOfValues blueArea))
    (set! newblue (round-num newbluefloat (floor newbluefloat)))
    (cond
      [(> newblue newbluefloat)(set! newblue (- newblue 1))])
    (list newred newgreen newblue)
    
    ))
```
## 4. Extract RGB value from 24 bits number and using car and cdr to get the value of RGB

* Discussion: For this function I used the knowledge about car and cdr which I learned in OPL class to implement this function. We get 24 bits number and convert to format (255 red green blue). and Using this one to edit the value.


* Code:

```
(define (get-r lst) (cadr lst))
(define (get-g lst) (caddr lst))
(define (get-b lst) (cadddr lst))
(define (remain-lst lst) (cddddr lst))

;; function extract number to red/green/blue value from binary
(define (extract-rgb num)
  (local
    [(define red (bitwise-bit-field num 0 8))
     (define green (bitwise-bit-field num 8 16))
     (define blue (bitwise-bit-field num 16 24))]
    (list 255 red green blue)))
```

