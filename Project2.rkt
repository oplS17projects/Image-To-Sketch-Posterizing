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
;(require (except-in picturing-programs))
(require racket/string)

;; This library is use for do the gaussian blur
(require images/flomap)
(require (except-in racket/draw make-pen make-color))
(define img-name "house.jpg")

;(define path (string-append (path->string (current-directory)) img-name))

;; read the image
;(define imginput (bitmap "house.jpg"))
(define imginput (make-object bitmap% img-name))

;; get image height
;(define img-height (- (image-height imginput) 1))
(define img-height (- (send imginput get-height) 1))

;; get image width
;(define img-width (- (image-width imginput) 1))
(define img-width (- (send imginput get-width) 1))


;; =============================
;; Read image to bitmap% object

(define pixels (make-bytes (* img-height img-width 4)))

(send imginput get-argb-pixels 0 0 img-width img-height pixels)

(define PixelsList (bytes->list pixels))

;(get-pixel-color 0 0 img-name)
;(get-pixel-color 1 0 img-name)


;(define out (open-output-file "testlist.txt" #:exists 'replace))
;(write testlist out)
;(close-output-port out)


;(define out1 (open-output-file "pixels.txt" #:exists 'replace))
;(write (list->bytes testlist) out1)
;(close-output-port out1)




;; ============================
;; Get to single list with 1 value represent for 1 pixel in the list
(define (get-r lst) (cadr lst))
(define (get-g lst) (caddr lst))
(define (get-b lst) (cadddr lst))
(define (remain-lst lst) (cddddr lst))

(define (join-value red green blue)
 ; (list red green blue))
  (bitwise-ior (bitwise-and red #xFF) (arithmetic-shift (bitwise-and green #xFF) 8) (arithmetic-shift (bitwise-and blue #xFF) 16)))
  
 
(define (RGBmap-iter result lst)
  (if (null? lst)
      result
      (RGBmap-iter
       (cons result (join-value (get-r lst) (get-g lst) (get-b lst)))
       (remain-lst lst))))


(define RGBmap
  (RGBmap-iter '() PixelsList))


(define out1 (open-output-file "RGBmap.txt" #:exists 'replace))
(write RGBmap out1)
(close-output-port out1)




(define numrgb (bitwise-ior (bitwise-and 12 #xFF) (arithmetic-shift (bitwise-and 20 #xFF) 8) (arithmetic-shift (bitwise-and 30 #xFF) 16)))


(define (extract-rgb num)
  (local
    [(define red (bitwise-bit-field num 0 7))
     (define green (bitwise-bit-field num 8 15))
     (define blue (bitwise-bit-field num 16 23))]
    (list red green blue)))
        







