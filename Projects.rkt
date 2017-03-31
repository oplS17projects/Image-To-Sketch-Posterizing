#lang racket

;(require (except-in racket/draw make-pen))
;(require (prefix-in htdp: 2htdp/image))
;; for bitmap
;(require (except-in 2htdp/image make-color))

; for get-pixel-color
(require (except-in picturing-programs))
(require racket/string)

;(require 2htdp/image)
;(require picturing-programs)

;; read the image
(define imgtest (bitmap "test.png"))

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
(define (get-pixel x y)
  (local
    [(define str (any->string (get-pixel-color y x imgtest)))
     (define str1 (string-split (substring str 15 (- (string-length str) 1))))]
    (list (string->number (list-ref str1 0)) (string->number (list-ref str1 1)) (string->number (list-ref str1 2)))))

;; read pixel-by-pixel to list
;; sample picture height = 561 and width = 460
;; (get-pixel-color x y pic) where x = width and y = height
;; color return red/green/blue/alpha
(define pixlist
  (list (list (get-pixel 1 1) (get-pixel 1 2) (get-pixel 1 3) (get-pixel 1 4))
        (list (get-pixel 300 148) (get-pixel 300 149) (get-pixel 300 150))
        ))

;;==============================
;; Function to read each pixel and save to list
(define (RGBList-iter width height)
  (for/list ([x (in-range 0 height)])
    (for/list ([y (in-range 0 width)])
            (get-pixel x y))))
    
(define RGBList
  (RGBList-iter img-width img-height))

;; save to text file for test
(define out (open-output-file "test.txt" #:exists 'replace))
(write RGBList out)
(close-output-port out)


;;==============================
;;Create a gray list
;; This will be the based for any other method. The gray-point will be the final list before convert image
(define (gray-point lst)
  (local
    [(define gray (quotient (+ (list-ref lst 0) (list-ref lst 1) (list-ref lst 2)) 3))]
    (make-color gray gray gray)))
  
(define (GrayList-iter width height)
  (for/list ([x (in-range 0 height)])
    (for/list ([y (in-range 0 width)])
      (gray-point (list-ref (list-ref RGBList x) y))
      )))

(define GrayList
  (GrayList-iter img-width img-height))

;;==============================
;; Convert 2d list matrix to single list
(define FinalList
  (append* RGBList))
    
;; save to text file for test
(define out1 (open-output-file "list.txt" #:exists 'replace))
(write FinalList out1)
(close-output-port out1)

;;==============================
; Join list
(define FinalGrayList
  (append* GrayList))

;; save to text file for test
(define grayout (open-output-file "grayout.txt" #:exists 'replace))
(write FinalGrayList grayout)
(close-output-port grayout)


;; from pixel to bitmap
;; the form of color is the struct so it need to be a list of color struct so it can convert to bitmap
;;(scale 30 (color-list->bitmap (car pixlist) 4 1))
;;(scale 30 (color-list->bitmap (cadr pixlist) 3 1))
(color-list->bitmap FinalGrayList img-width img-height)


(define save-photo
  (save-image (color-list->bitmap FinalGrayList img-width img-height)))
