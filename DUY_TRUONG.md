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


## 2. Invert Color for gray sacle using recursive process, cons and Procedural Abstraction.

* Input and Output: It will get one number (24bit number of RGB) and return one number 24bits of invert gray scale.

* Code:

```
(define (invert-color result lst)
(if (null? lst)
    result
    (invert-color (cons (get-invert-value (car lst)) result) (cdr lst))))
	
(define (get-invert-value num)
  (local
    [(define red (bitwise-bit-field num 0 8))
     (define green (bitwise-bit-field num 8 16))
     (define blue (bitwise-bit-field num 16 24))]
    (join-value (- 255 red) (- 255 green) (- 255 blue))))
```

* Discussion: for this code, I use the Procedural Abstraction ```null?``` to check the list is empty or not. After that I applied the recursive process concept which I learned in OPL class. For the result, I used cons to add new element to the list.

When we compare with the algorithm 1.

```
(define (Invert-Value lst)
  (list (- 255 (list-ref lst 0)) (- 255 (list-ref lst 1)) (- 255(list-ref lst 2))))
  
(define (MakeInvert invertlist width height)
  (for/list ([x (in-range 0 height)])
    (for/list ([y (in-range 0 width)])
      (Invert-Value (list-ref (list-ref invertlist x) y))
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


