# Image to Sketch / Posterizing

### Version: 1.0

### Team Member:
+ Duy Truong
+ Chuong Vu

### Statement

The idea of this project is using racket to perform a conversion of normal image into sketch image. We both have never done image edit before we find it this project is really interesting how other programs such as Adobe Photoshop can be a powerful image-editing software.

### Analysis

A digital image is a contributed by millions pixel/dot. Each pixel is a color, and each color is the mixed of red green and blue (RGB). Our program is read the entire pixel from an image into a list (we can think of 2-dimension array or matrix x/y). Each value in the matrix is represent for a pixel value of the image. By that, we can change the color to anything we want and for this project, our goal it convert the image to stretch image.
Our team try to use less the library of the racket, we implement new function base on the follow Architecture Diagram:

![alt text][diagram]

For this project, we have two different programs do to the same thing. Why? Because after we finished the first one, the runtime is too slow for convert so we rewrite the whole thing with differents algoritms so the running time is improved.

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
;; This library is use for do the gaussian blur
(require images/flomap)
(require (except-in racket/draw make-pen make-color))
```


### Deliverable and Demonstration
We successfully to convert from the image to sketch.

Output:
![alt text][sketch]

And also an extra posterized image
Output:
![alt text][posterized]


### Function Detail

## Algorithm 1:
1. Get pixel function
```racket
;; function get pixel at x and y
;; Local str is use to convert the color struct to string
;; Local str1 get the substring and split it into a list
;; finally, convert back the string to number go now I get RGB value number
;; Note: We have to use this method because the get-pixel-color library is create the
;; immunate struct which is can't change but We only need RGB value for calculation
;; so We choice to write my own function to return the RGB from get-pixel-color.
(define (get-pixel-helper x y img)
  (local
    [(define str (any->string (get-pixel-color y x img)))
     (define str1 (string-split (substring str 15 (- (string-length str) 1))))]
    (list (string->number (list-ref str1 0)) (string->number (list-ref str1 1)) (string->number (list-ref str1 2)))))

```

2. Save to List
```Racket
;; Function to read each pixel and save to list
(define (RGBList-iter width height img)
  (for/list ([x (in-range 0 height)])
    (for/list ([y (in-range 0 width)])
           (get-pixel-helper x y img))))
```

3. Convert to gray scale
* Input : RGB list
* Output : Gray-List
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

4. Convert to Inverted Gray Image
* Input: Gray-List
* Output: InvertColor-List

```Racket

(define (Invert-Value lst)
  (list (- 255 (list-ref lst 0)) (- 255 (list-ref lst 1)) (- 255(list-ref lst 2))))
  
(define (MakeInvert invertlist width height)
  (for/list ([x (in-range 0 height)])
    (for/list ([y (in-range 0 width)])
      (Invert-Value (list-ref (list-ref invertlist x) y))
      )))
```

5. Apply Gaussian Blur
* Input: InvertColor-List
* Ouput: Blured-List

```Racket

;; Read image to bitmap% object
(define dm (make-object bitmap% img-name))

;; convert it to flomap
(define fm (bitmap->flomap dm))

;; Make the gaussian blur
(define GblurImg (flomap->bitmap (flomap-gaussian-blur (flomap-inset fm 12) 3)))

;; Read RGB from blur image (color image)
(define RGBBlurList
  (RGBList-iter img-width img-height GblurImg))
```


6. Image Color Dodge Merge
* Input: Blured-List && Gray-List
* Output: Final Image
 
 ```Racket
 ;; Apply Gaussian Blur to Inverted Color

(define BWimage (color-list->bitmap (join-list InvertColorList 0 (length InvertColorList) null) img-width img-height))

;; Save BWinvert image
(define save-temp (save-image BWimage "temp.png"))

;; Read image to bitmap% object
(define bwdm (make-object bitmap% "temp.png"))

;; Delete temp file
(delete-file "temp.png")

;; convert it to flomap
(define bwfm (bitmap->flomap bwdm))

;; Make the gaussian blur
(define bwGblurImg (flomap->bitmap (flomap-gaussian-blur (flomap-inset bwfm 12) 0)))

;; Red RGB from blur image
(define BWRGBBlurList
  (RGBList-iter img-width img-height bwGblurImg))
 ```
 
# Extra filter:
* Posterizing:
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

## Algorithm 2:

1. Get pixels value
* Input: Image
* Output: List of RGB value
```racket 

;; Read image to bitmap% object

(define pixels (make-bytes (* img-height img-width 4)))

(send imginput get-argb-pixels 0 0 img-width img-height pixels)

(define PixelsList (bytes->list pixels))

```

2. Convert RGB value to 24 bits
* Input: RGB value
* Output: one 24 bits values represent for RGB

```racket
;; Get to single list with 1 value represent for 1 pixel in the list
(define (get-r lst) (cadr lst))
(define (get-g lst) (caddr lst))
(define (get-b lst) (cadddr lst))
(define (remain-lst lst) (cddddr lst))

;; using bitwise or/and with shift to store RGB value to 24 bits.
(define (join-value red green blue)
  (bitwise-ior (bitwise-and red #xFF) (arithmetic-shift (bitwise-and green #xFF) 8) (arithmetic-shift (bitwise-and blue #xFF) 16)))
  
(define (RGBmap-iter result lst)
  (if (null? lst)
      result
      (RGBmap-iter
       (cons (join-value (get-r lst) (get-g lst) (get-b lst)) result)
       (remain-lst lst))))


(define RGBmap
  (RGBmap-iter '() PixelsList))

```

3. Function help extract one 24 bits value to RGB
* Input : 1 number
* Output : RGB values

```racket
(define (extract-rgb num)
  (local
    [(define red (bitwise-bit-field num 0 8))
     (define green (bitwise-bit-field num 8 16))
     (define blue (bitwise-bit-field num 16 24))]
    (list 255 red green blue)))
    
    
```

4. Convert to gray scale
* Input: Number
* Output:  24bits Gray Number 

```racket

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
5.  Invert Colors from Gray Scale
* Input: Gray Number 
* Output:  24bits Invert Number 

```racket

(define (get-invert-value num)
  (local
    [(define red (bitwise-bit-field num 0 8))
     (define green (bitwise-bit-field num 8 16))
     (define blue (bitwise-bit-field num 16 24))]
    (join-value (- 255 red) (- 255 green) (- 255 blue))))

(define (invert-color result lst)
  (if (null? lst)
      result
      (invert-color (cons (get-invert-value (car lst)) result) (cdr lst))))

(define inverts-value
  (invert-color '() gray-scale))
```

6. Apply Gaussian Blur to Inverted Color
* Input: Invert Number 
* Output:  24bits Blur Invert Number 

```racket
;; By using the flomap library, apply the built-in function flomap-gaussian-blur
;; to get the blur image

(define InvertedBitmap (make-object bitmap% img-width img-height))

(define InvertedList
  (back-to-argb inverts-value))

(send InvertedBitmap set-argb-pixels 0 0 img-width img-height (list->bytes (append* InvertedList)))

;; convert it to flomap
(define fm (bitmap->flomap InvertedBitmap))

;; Make the gaussian blur
(define GblurImg (flomap->bitmap (flomap-gaussian-blur (flomap-inset fm 8) 2)))

(send GblurImg get-argb-pixels 0 0 img-width img-height  pixels)

(define BlurMap (bytes->list pixels))

(define BlurValue
  (RGBmap-iter '() BlurMap))
```
7. Color Dodge Blend Merge Function
* Input: Invert Blur Number and Gray value 
* Output:  final image value

```racket
;; Merge GrayList and BWRGBBlurList
;; if numblur == 255 return numblur
;; else return (numbw * 256) / (255 - numblur)

(define (colordodge numblur numbw)
  (if (equal? 255 numblur)
      numblur
      (min 255 (round (/ (* numbw 256) (- 255 numblur)))))) 

(define (value-return blist glist)
  (join-value (colordodge (get-r blist) (get-r glist))
        (colordodge (get-g blist) (get-g glist))
        (colordodge (get-b blist) (get-b glist))
        ))

(define (return-dodge num1 num2)
  (local
    [(define rgb1 (extract-rgb num1))
     (define rgb2 (extract-rgb num2))]
    (value-return rgb1 rgb2)))


(define (Color-Dodge-Blend-Merge-iter result blurlist bwlist)
  (if (null? blurlist)
      result
      (Color-Dodge-Blend-Merge-iter (cons (return-dodge (car blurlist) (car bwlist)) result)
                                    (cdr blurlist) (cdr bwlist))))


(define Color-Dodge-Blend-Merge
  (Color-Dodge-Blend-Merge-iter '() (reverse BlurValue) gray-scale))
  ```


##Running Time:

Algorithm 1: 77 seconds.
Algorithm 2: 14 seconds.
  
## Image:
Input:
![alt text][input]

BlurImage:
![alt text][BlurImage]

GrayImage:
![alt text][grayimage]

InvertImage:
![alt text][InvertImage]

InvertBlur:
![alt text][InvertBlur]


### Evaluation of Results
We are almost there, we are now searching for a good algorithm that do a filter, which it use to combine this filter and BW to create a new image.

* The BW image is very simple, it is made from gray value and gray value is the mean of RGB values.
* Filter, we are searching for a good algorithm now. There are many image’s filter such as Median Blur, Bilateral filter, Min filter. 

We may use Median Blur and redraw the image based on detect and enhance edges algorithm to create a new image.



1. Load the Input image
2. Read every pixel of the Image which are the RGB value and store it into 2D list.
3. Calculate gray values
4. Create filter
5. Combine gray values and filter
6. Create new image 


## Schedule

### First Milestone (Sun Apr 9)
- [x] Finished Posterizing Filter
- [x] Finished InvertColor Filter

We both will work on Gaussian Blur Filter. After that we will combine the filter and gray filter togeter to get the final image.

### Second Milestone (Sun Apr 16)
- [x] Got the Gaussian Blur filter works
- [x] Convert image to sketch.

At this point, we use another two racket library with is `(require images/flomap)` and `(require (except-in racket/draw make-pen make-color)).` to make a `flomap` for generate the Gaussian Blur filter.

### Public Presentation (Mon Apr 24, Wed Apr 26, or Fri Apr 28 [your date to be determined later])
- [ ] 
Wrap up everything, all bugs should be addressed. Clean up the code and ready to demonstrate.

## Group Responsibilities

### Duy Truong @duytruong92
Main: Clean up, QA for program
- [x] Read RGB into 2D list 
- [x] Merge the data from 2D list into single List
- [x] Merge gray and filter to 2D list
- [x] Work on filter
- [ ] Addressed all bugs before demonstrate.

### Chuong Vu @vdc1703
Main: Gather information needed for the project.
- [x] Convert and store the changeable RGB into 2D list
- [x] Calculate gray values into new 2D list
- [x] Work on filter
- [x] Convert new 2D list to a new image
- [ ] Clean up the code, ready to demonstrate


<!-- Links -->
[input]: https://github.com/oplS17projects/Image-To-Cartoon/blob/master/house.jpg
[sketch]: https://github.com/oplS17projects/Image-To-Cartoon/blob/master/Sketch.png
[posterized]: https://github.com/oplS17projects/Image-To-Cartoon/blob/master/Posterized.png
[diagram]: https://github.com/oplS17projects/Image-To-Cartoon/blob/master/Diagram.png
[grayimage]: https://github.com/oplS17projects/Image-To-Cartoon/blob/master/GrayImage.png
[InvertImage]: https://github.com/oplS17projects/Image-To-Cartoon/blob/master/InvertImage.png
[InvertBlur]: https://github.com/oplS17projects/Image-To-Cartoon/blob/master/InvertBlur.png
[BlurImage]: https://github.com/oplS17projects/Image-To-Cartoon/blob/master/BlurImage.png
