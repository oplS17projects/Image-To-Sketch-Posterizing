# Sketch Posterizing

### Version: 1.0

### Team Member:
+ Duy Truong
+ Chuong Vu
### Overview

For Pencil Posterrizing Poject, our team used racket language to edit and create a new image from the original image. We have a lot different ways to convert (cartoon, gray, sketch). Our team focus on Sketch posterizing. However, Our team also implement some extra filters can help the user can convert to different type of image. we used 2 different algorithms to convert the image.
1. Using the bitmap
2. Read the bitmap and convert value of RGB to 1 24 bits values.

### Analysis
An digital image is a contributed by millions pixel/dot. And each pixel is contain 3 values Reg/Green/Blue (RGB) and these value make a color. Our program is load every pixel (RGB) into a list of list (or we can say 2-dimension array or matrix x/y). The pixel in the matrix is represent each dot on the image so it help us easily keep track the color at the position x/y. By that, we can can change the color to anything we want and for this project, our goal it convert the image to cartoon/stretch image.
Our team try to use less the library of the racket, we implement new function base on the following algorithm:
* Invert Image
* Gray Scale
* Color Image Dodge Merge
* Poterzing Image

### Library
For the libary of the racket, Our team use only two library to edit the image.
* String - Using Sting libary to read and store the pixel of the image
* flomap - to make a `flomap` for generate the Gaussian Blur filter.
* draw make-pen make-color - support bitmap% different type object of bitmap. To convert from bitmap to flomap

### Deliverable and Demonstration
We successfully to convert from the original image to pencil image.

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

* Image Ouput
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
* Image Output

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

* Image output:

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

Output Example:

## Algorithm 2:

## Image:
Input:
![alt text][input]
Output:
![alt text][output]

### Evaluation of Results
We are almost there, we are now searching for a good algorithm that do a filter, which it use to combine this filter and BW to create a new image.

* The BW image is very simple, it is made from gray value and gray value is the mean of RGB values.
* Filter, we are searching for a good algorithm now. There are many image’s filter such as Median Blur, Bilateral filter, Min filter. 

We may use Median Blur and redraw the image based on detect and enhance edges algorithm to create a new image.


## Architecture Diagram

![alt text][Drawing]

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
[output]: https://github.com/oplS17projects/Image-To-Cartoon/blob/master/Sample-output.png
[diagram]: https://github.com/oplS17projects/Image-To-Cartoon/blob/master/Diagram.png
