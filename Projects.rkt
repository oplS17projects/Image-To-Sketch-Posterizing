#lang racket
; Version 0.2

; for get-pixel-color
(require (except-in picturing-programs))
(require racket/string)

;; This library is use for do the gaussian blur
(require images/flomap)
(require (except-in racket/draw make-pen make-color))
(define img-name "model-9.jpg")

;; read the image
(define imgtest (bitmap "model-9.jpg"))

;; get image height
(define img-height (- (image-height imgtest) 1))

;; get image width
(define img-width (- (image-width imgtest) 1))

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
(define (get-pixel x y img)
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
            (get-pixel x y img))))

;; save to text file for test
;;(define out (open-output-file "test.txt" #:exists 'replace))
;;(write RGBList out)
;;(close-output-port out)


;; 1. Read the RGBList
(define RGBList
  (RGBList-iter img-width img-height imgtest))


;;==============================
;; Duy
;; Function for Posterize Algorithm

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



;;==============================
;; Create a gray list
;; This will be the based for any other method. The gray-point will be the final list before convert image
;(define (gray-point lst)
;  (local
;    [(define gray (quotient (+ (list-ref lst 0) (list-ref lst 1) (list-ref lst 2)) 3))]
;    (make-color gray gray gray)))

;(define (GrayList-iter width height)
;  (for/list ([x (in-range 0 height)])
;    (for/list ([y (in-range 0 width)])
;      (gray-point (list-ref (list-ref RGBList x) y))
;      )))


;; ==============================
;; This function is use for Posterizing Filter
;; Create a gray list value

(define (gray-point-value lst)
  (local
    [(define gray (quotient (+ (list-ref lst 0) (list-ref lst 1) (list-ref lst 2)) 3))]
    (list gray gray gray)))

(define (GrayList-iter-value width height)
  (for/list ([x (in-range 0 height)])
    (for/list ([y (in-range 0 width)])
      (gray-point-value (list-ref (list-ref RGBList x) y))
      )))

(define MakeGrayList
  (GrayList-iter-value img-width img-height))




;;==============================
;; Convert 2d list matrix to single list
;(define FinalList
;  (append* RGBList))
    
;; save to text file for test
;;(define out1 (open-output-file "list.txt" #:exists 'replace))
;;(write FinalList out1)
;;(close-output-port out1)

;;==============================
; Join list

;; Convert List to make-color object

(define (lst-value lst)
  (make-color (list-ref lst 0) (list-ref lst 1) (list-ref lst 2)))
  
(define (MakeColorObjectList lstvalue width height)
  (for/list ([x (in-range 0 height)])
    (for/list ([y (in-range 0 width)])
      (lst-value (list-ref (list-ref lstvalue x) y))
      )))


(define (join-list-next list-calculated count max result)
  (if (= count max)
      result
      (join-list list-calculated (+ count 1) max (append result (list-ref list-calculated count))))) 

(define (join-list lst count max result)
  (local
    [(define ResultList (MakeColorObjectList lst img-width img-height))]
    (append* ResultList)))
  ;(join-list-next ResultList count max result)))


;;==============================
; Invert
(define (Invert-Value lst)
  (list (- 255 (list-ref lst 0)) (- 255 (list-ref lst 1)) (- 255(list-ref lst 2))))
  
(define (MakeInvert invertlist width height)
  (for/list ([x (in-range 0 height)])
    (for/list ([y (in-range 0 width)])
      (Invert-Value (list-ref (list-ref invertlist x) y))
      )))

(define(InvertColor data)
  (MakeInvert data img-width img-height))





;;==============================
;; Chuong Vu
;; Gaussian Blur

;; Read image to bitmap% object
(define dm (make-object bitmap% img-name))

;; convert it to flomap
(define fm (bitmap->flomap dm))

;; Make the gaussian blur
(define GblurImg (flomap->bitmap (flomap-gaussian-blur (flomap-inset fm 12 3) 4 1)))

;; Red RGB from blur image
(define RGBBlurList
  (RGBList-iter img-width img-height GblurImg))

;;(define out3 (open-output-file "RGBBlurList.txt" #:exists 'replace))
;;(write RGBBlurList out3)
;;(close-output-port out3)

;;==============================








;;==============================
;; Convert to single list before convert it to bitmap

;; Program is start from here
;; 1. RGB List

;; 2. From RGB Convert to Black and White
(define GrayList MakeGrayList)


;; 3. Invert Color
(define InvertColorList (InvertColor GrayList))

;; 4. Gaussian Blur Filger
(define GBlurList RGBBlurList)


;;=============================
;; Duy
;;Create Posterize list

(define posterizeValue 20)

(define PosterizingFilterList
  (posterize GBlurList img-width img-height posterizeValue))

;;(define out3 (open-output-file "PosterizeList.txt" #:exists 'replace))
;;(write PosterizeList out3)
;;(close-output-port out3)

;;=============================

;;==============================
;; Join to single list before convert to bitmap
   
;; Convert to make-color object from list

(define FinalGrayList
  (join-list GrayList 0 (length GrayList) null))

(define FinalPosterizeList
  (join-list PosterizingFilterList 0 (length PosterizingFilterList) null))

(define FinalInvertColorList
  (join-list InvertColorList 0 (length InvertColorList) null))



(color-list->bitmap FinalPosterizeList img-width img-height)

(define save-photo
  (save-image (color-list->bitmap FinalPosterizeList img-width img-height) "Sample-output.png"))

