# Image to Sketch / Posterizing

### Version: 1.0

### Team Member:
+ Duy Truong
+ Chuong Vu

### Statement

The idea of this project is use racket to perform a convert an image into sketch. We both have never done image edit before we find it this project is really interesting how other programs such as Adobe Photoshop can be a powerful image-editing software.

### Analysis

A digital image is a contributed of millions pixel/dot. Each pixel is a color, and each color is mixed of red green and blue (RGB) color. Our program will read the entire pixel from an image and store all the value RGB into a single list (we can also imagine of 2-dimension array or matrix x/y). Each value in the matrix is represent a pixel of the image. By that, we can change the color value (RGB) to anything we want to make a new picture and for this project, our goal it convert the image to stretch image.

Our team try to use less the library of the racket, we implement new function base on the follow Architecture Diagram:

<p align="center"><img src="https://github.com/oplS17projects/Image-To-Cartoon/blob/master/Diagram.png" /></p>

For this project, we have two different programs do to the same thing. Why? Because after we finished the first one, the runtime is so slow to convert an image so we decided to write a new program with differents algoritms to improve the running time.

### Library

#### For the first algorithm (Algoirthm-1), we use:
```racket
(require (except-in picturing-programs)) ;; use to read the pixel and convert back to image
(require racket/string)	;; convert anything to string

;; This library is use for do the gaussian blur
(require images/flomap)
(require (except-in racket/draw make-pen make-color))
```
#### For the second algorithm (Algoirthm-2), we use:

```racket
;; This library is use to read the RGB and do the gaussian blur
(require images/flomap)
(require (except-in racket/draw make-pen make-color))
```


### Deliverable and Demonstration
We successfully to convert from the image to sketch.


## Functional Detail

### Algorithm 1:

* Read pixels from image and store into RGBList

```racket
;; function get pixel at x and y
;; Local str is use to convert the color struct to string
;; Local str1 get the substring and split it into a list
;; finally, convert back the string to number go now I get RGB value number
;; Note: I have to use this method because the get-pixel-color library is create the
;; immunate struct which is can't change but I only need RGB value for calculation
;; so I choice to write my own function to return the RGB from get-pixel-color.
(define (get-pixel-helper x y img)
  (local
    [(define str (any->string (get-pixel-color y x img)))
     (define str1 (string-split (substring str 15 (- (string-length str) 1))))]
    (list (string->number (list-ref str1 0)) 
			(string->number (list-ref str1 1)) 
			(string->number (list-ref str1 2)))))
```

* Convert Color to Gray-Scale
	- The grayscale basically is the value of (Red + Green + Blue) / 3 for all R/G/B
	
```Racket
(define (gray-point-value lst)
  (local
    [(define gray (quotient (+ (list-ref lst 0) (list-ref lst 1) (list-ref lst 2)) 3))]
    (list gray gray gray)))

(define (GrayList-iter-value data width height)
  (for/list ([x (in-range 0 height)])
    (for/list ([y (in-range 0 width)])
      (gray-point-value (list-ref (list-ref data x) y))
      )))

(define MakeGrayList
  (GrayList-iter-value RGBList img-width img-height))
```

* From the grayscale, make an Inverted Color list
	- For each RGB in a pixel, we subtract from 255. This will make an inverted

```Racket

(define (Invert-Value lst)
  (list (- 255 (list-ref lst 0)) (- 255 (list-ref lst 1)) (- 255(list-ref lst 2))))

(define (MakeInvert invertlist width height)
  (for/list ([x (in-range 0 height)])
    (for/list ([y (in-range 0 width)])
      (Invert-Value (list-ref (list-ref invertlist x) y))
      )))
```

* Apply Gaussian Blur into the Inverted Color list
	- Since the gaussian blur only the a flomap as an input for, we have to converted the Inverted Color to bitmap. From the bitmap, it can convert to flomap to do the gaussian blur.

```Racket
;; Convert Inverted Color to bitmap
(define BWimage 
	(color-list->bitmap (join-list InvertColorList 0 (length InvertColorList) null) 
						img-width img-height))

;; Save BWinvert image
(define save-temp (save-image BWimage "temp.png"))

;; Read image to bitmap% object
(define bwdm (make-object bitmap% "temp.png"))

;; Delete temp file
(delete-file "temp.png")

;; convert it to flomap
(define bwfm (bitmap->flomap bwdm))

;; Make the gaussian blur
(define bwGblurImg (flomap->bitmap (flomap-gaussian-blur (flomap-inset bwfm 6) 2)))

;; Red RGB from blur image
(define BWRGBBlurList
  (RGBList-iter img-width img-height bwGblurImg))
```

* Color Dodge Blend
	- This use to merger the gaussian blur and the grayscale together, the final result will be sketch.
	
 ```Racket
;; Color Dodge Blend Merge Function
;; Merge GrayList and BWRGBBlurList
;; if numblur == 255 return numblur
;; else return (numbw * 256) / (255 - numblur)

(define (colordodge numblur numbw)
  (if (equal? 255 numblur)
      numblur
      (min 255 (round (/ (* numbw 256) (- 255 numblur)))))) 

(define (lst-bend blurlist bwlist)
  (list (colordodge (list-ref blurlist 0) (list-ref bwlist 0))
        (colordodge (list-ref blurlist 1) (list-ref bwlist 1))
        (colordodge (list-ref blurlist 2) (list-ref bwlist 2))
        ))
  
(define (Color-Dodge-Blend-Merge-iter blurlist bwlist width height)
  (for/list ([x (in-range 0 height)])
    (for/list ([y (in-range 0 width)])
      (lst-bend (list-ref (list-ref blurlist x) y) (list-ref (list-ref bwlist x) y))
      )))

(define Color-Dodge-Blend-Merge
  (Color-Dodge-Blend-Merge-iter BWRGBBlurList GrayList img-width img-height))

 ```
 
* Extra filter: Posterizing
```Racket
;; Function for Posterize Filter Algorithm
(define (round-num num-ori num-int)
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
   
(define (posterize data width height value)
  (cond [(and (>= value 2) (<= value 255))
      (local
        [(define numOfAreas (/ 256 value))
         (define numOfValues (/ 255 (- value 1)))]
        (for/list ([x (in-range 0 height)])
          (for/list ([y (in-range 0 width)])
            (posterize-point (list-ref (list-ref data x) y) numOfAreas numOfValues)
      )))]))
```

### Algorithm 2:

* The steps and calculation is pretty much same as the first algorithm, but the way we read and store RGB is totaly different.

* We read and store the RGB value into 24bits binary. By doing this, it save a lot memory and also decrease the reading time from the list.

```racket
;; function extract number to red/green/blue value from binary
(define (extract-rgb num)
  (local
    [(define red (bitwise-bit-field num 0 8))
     (define green (bitwise-bit-field num 8 16))
     (define blue (bitwise-bit-field num 16 24))]
    (list 255 red green blue)))

;; this function store r/g/b to 24bits memory by using bitwise or/and with shift operators
(define (join-value red green blue)
  (bitwise-ior (bitwise-and red #xFF) (arithmetic-shift (bitwise-and green #xFF) 8) (arithmetic-shift (bitwise-and blue #xFF) 16)))
```

This is how we stored the RGB into 24 bits binary, which using bitwise and with xFF and then shift it to the correct position in 24 bits binary.

<p align="center"><img src="https://github.com/oplS17projects/Image-To-Cartoon/blob/master/24bits.JPG" /></p>

* Store data
	- By storing into a single list, the running time is O(n).

```racket
;; This function read red/green/blue from PixelsList, then convert it to 24bits binays
;; then return a single list of 24bits integer
(define (RGBmap-iter result lst)
  (if (null? lst)
      result
      (RGBmap-iter
       (cons (join-value (get-r lst) (get-g lst) (get-b lst)) result)
       (remain-lst lst))))

(define RGBmap
  (RGBmap-iter '() PixelsList))
```
* So after we stored to the 24 bits binary, the list of pixels now is only a single list. It helps read faster than the algoirthm 1 which is list inside a list (2D List). Example of 24 bits binary for RGB in the list: `'(16777215 16777215 16777215 8026746 6842472.....)`


## Running Time:

* The running time to convert a 1024x629 image to sketch is:
- Algorithm 1: 56 seconds.
- Algorithm 2: 10 seconds.

* Time Complexity
- Algorithm 1: **O(n^2)** - Quadratic
- Algorithm 2: **O(n)** - Linear

## Image:
Steps:
![alt text][sketch]

Input:
![alt text][input]

GrayScale:
![alt text][grayimage]

InvertedImage:
![alt text][InvertImage]

InvertedBlur:
![alt text][InvertedBlur]

Final Output:
![alt text][sketch]

And also an extra posterized image
Output:
![alt text][posterized]


## Schedule

### First Milestone (Sun Apr 9)
- [x] Finished Posterizing Filter
- [x] Finished InvertColor Filter

We both will work on Gaussian Blur Filter. After that we will combine the filter and gray filter togeter to get the final image.

### Second Milestone (Sun Apr 16)
- [x] Got the Gaussian Blur filter works
- [x] Convert image to sketch.

At this point, we use another two racket library with is `(require images/flomap)` and `(require (except-in racket/draw make-pen make-color)).` to make a `flomap` for generate the Gaussian Blur filter.

### Public Presentation (Fri Apr 28)
- [x] Rewrite the everything with new algoirthm to improved the running time
- [x] Wrap up everything, all bugs should be addressed. Clean up the code and ready to demonstrate.

## Group Responsibilities

### Duy Truong @duytruong92
Main: Clean up, QA for program
- [x] Read RGB into 2D list 
- [x] Merge the data from 2D list into single List
- [x] Merge gray and filter to 2D list
- [x] Work on filter
- [x] Work on Inverted/Blur image (new algorithm)
- [x] Work on color-dodge-blend (new algorithm)
- [x] Addressed all bugs before demonstrate.

### Chuong Vu @vdc1703
Main: Gather information needed for the project.
- [x] Convert and store the changeable RGB into 2D list
- [x] Calculate gray values into new 2D list
- [x] Work on filter
- [x] Convert new 2D list to a new image
- [x] Read/extract pixels in 24 bits binary (new algorithm)
- [x] Convert result to image
- [x] Clean up the code, ready to demonstrate

<!-- Links -->
[input]: https://github.com/oplS17projects/Image-To-Cartoon/blob/master/house.jpg
[sketch]: https://github.com/oplS17projects/Image-To-Cartoon/blob/master/Architecture.png
[posterized]: https://github.com/oplS17projects/Image-To-Cartoon/blob/master/Posterized.png
[24bits]: https://github.com/oplS17projects/Image-To-Cartoon/blob/master/24bits.JPG
[steps]: https://github.com/oplS17projects/Image-To-Cartoon/blob/master/ConvertSteps.png
[diagram]: https://github.com/oplS17projects/Image-To-Cartoon/blob/master/Diagram.png
[grayimage]: https://github.com/oplS17projects/Image-To-Cartoon/blob/master/GrayImage.png
[InvertImage]: https://github.com/oplS17projects/Image-To-Cartoon/blob/master/InvertImage.png
[InvertedBlur]: https://github.com/oplS17projects/Image-To-Cartoon/blob/master/InvertedBlur.png

