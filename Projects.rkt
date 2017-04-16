#lang racket
;; Version 0.3


;; Due to the time consumming, image with size less than 1024x800.
;; Idea:
;; 1. Read pixel from image
;; 2. Convert to Gray Scale
;; 3. Invert Colors from Gray Scale
;; 4. Apply Gaussian Blur to Inverted Color
;; 5. Merge 2 and 4 to get a sketch image

; for get-pixel-color
(require (except-in picturing-programs))
(require racket/string)

;; This library is use for do the gaussian blur
(require images/flomap)
(require (except-in racket/draw make-pen make-color))
(define img-name "13.JPG")

;; read the image
(define imginput (bitmap "13.JPG"))
;(define imginput (make-object bitmap% img-name))

;; get image height
(define img-height (- (image-height imginput) 1))
;(define img-height (- (send imginput get-height) 1))


;; get image width
(define img-width (- (image-width imginput) 1))
;(define img-width (- (send imginput get-width) 1))


;; convert struct/anything to string
(define (any->string any) 
  (with-output-to-string (lambda () (write any))))

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
    (list (string->number (list-ref str1 0)) (string->number (list-ref str1 1)) (string->number (list-ref str1 2)))))

;; read pixel-by-pixel to list
;; sample picture height = 561 and width = 460
;; (get-pixel-color x y pic) where x = width and y = height
;; color return red/green/blue/alpha

;;==============================
;; Function to read each pixel and save to list
(define (RGBList-iter width height img)
  (for/list ([x (in-range 0 height)])
    (for/list ([y (in-range 0 width)])
           (get-pixel-helper x y img))))

(display 'here2)
;; save to text file for test
;;(define out (open-output-file "test.txt" #:exists 'replace))
;;(write RGBList out)
;;(close-output-port out)


;; 1. Read pixel from image
(define RGBList
  (RGBList-iter img-width img-height imginput))

(display 'here3)
;; ==============================
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


;; ==============================
;; Convert RGB Scale to GrayScale

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


;;==============================
;; Join list
;; Convert 2D-List to 1D-List with make-color object
;; make-color object is use for convert the list to bitmap (image)

(define (lst-value lst)
  (make-color (list-ref lst 0) (list-ref lst 1) (list-ref lst 2)))

;; Read each pixel according to (x,y)
(define (MakeColorObjectList lstvalue width height)
  (for/list ([x (in-range 0 height)])
    (for/list ([y (in-range 0 width)])
      (lst-value (list-ref (list-ref lstvalue x) y))
      )))

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


;; ==============================
;; Function to Inverted Color from Gray Scale
;; The inverted color basically just subtract individual R/G/B from 255 for each pixel
;; Similer with Join List but we don't use the make-color becaus we want to change value later

(define (Invert-Value lst)
  (list (- 255 (list-ref lst 0)) (- 255 (list-ref lst 1)) (- 255(list-ref lst 2))))
  
(define (MakeInvert invertlist width height)
  (for/list ([x (in-range 0 height)])
    (for/list ([y (in-range 0 width)])
      (Invert-Value (list-ref (list-ref invertlist x) y))
      )))

;; Function InvertColor take a list and return a list
(define(InvertColor GrayScale)
  (MakeInvert GrayScale img-width img-height))


;; ==============================
;; Apply Gaussian Blur to Color bitmap
;; By using the flomap library, apply the built-in function flomap-gaussian-blur
;; to get the blur image

;; Read image to bitmap% object
(define dm (make-object bitmap% img-name))

;; convert it to flomap
(define fm (bitmap->flomap dm))

;; Make the gaussian blur
(define GblurImg (flomap->bitmap (flomap-gaussian-blur (flomap-inset fm 12) 3)))

;; Read RGB from blur image (color image)
(define RGBBlurList
  (RGBList-iter img-width img-height GblurImg))

(display 'here4)
;;==============================
;; Main funtion start from here.
;;******************************

;; 2. Convert to Gray Scale
(define GrayList MakeGrayList)

;; 3. Invert Colors from Gray Scale
(define InvertColorList (InvertColor GrayList))

;; 4. Apply Gaussian Blur to Inverted Color
(define GBlurList RGBBlurList)


;; ==============================
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
(define bwGblurImg (flomap->bitmap (flomap-gaussian-blur (flomap-inset bwfm 4) 4)))

;; Red RGB from blur image
(define BWRGBBlurList
  (RGBList-iter img-width img-height bwGblurImg))


;;=============================
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

;;(define out3 (open-output-file "Color-Dodge-Blend-Merge.txt" #:exists 'replace))
;;(write Color-Dodge-Blend-Merge out3)
;;(close-output-port out3)







;;=============================
;; Duy
;;Create Posterize list

;(define posterizeValue 20)

;(define PosterizingFilterList
;  (posterize GBlurList img-width img-height posterizeValue))

;;(define out3 (open-output-file "PosterizeList.txt" #:exists 'replace))
;;(write PosterizeList out3)
;;(close-output-port out3)


;;==============================
;; Join to single list before convert to bitmap
;; Convert to make-color object from list

;; Create Single BW List
;(define FinalGrayList
;  (join-list GrayList 0 (length GrayList) null))
;(color-list->bitmap FinalGrayList img-width img-height)


;; Create Single Invert BW List
;(define FinalInvertColorList
;  (join-list InvertColorList 0 (length InvertColorList) null))
;(color-list->bitmap FinalInvertColorList img-width img-height)


;; Create Single Guassian Blur List
;(define FinalGBlurList
;  (join-list GBlurList 0 (length GBlurList) null))
;(color-list->bitmap FinalGBlurList img-width img-height)

;; Create Single Posterize List
;;(define FinalPosterizeList
;;  (join-list PosterizingFilterList 0 (length PosterizingFilterList) null))
;(color-list->bitmap FinalGrayList img-width img-height)

;; Create Single Inverted Blur List
;(define FinalInvertedBlurList
;  (join-list BWRGBBlurList 0 (length BWRGBBlurList) null))
;(color-list->bitmap FinalInvertedBlurList img-width img-height)

;; 5. Merge 2 and 4 to get a sketch image
(define FinalSketch
  (join-list Color-Dodge-Blend-Merge 0 (length Color-Dodge-Blend-Merge) null))
(color-list->bitmap FinalSketch img-width img-height)


;;==============================
(define save-photo
  (save-image (color-list->bitmap FinalSketch img-width img-height) "Sketch.png"))

