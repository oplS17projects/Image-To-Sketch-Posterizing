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

(define list-output (open-output-file "argb.txt" #:exists 'replace))
(write PixelsList list-output)
(close-output-port list-output)

;; ============================
;; function extract number to red/green/blue value from binary
(define (extract-rgb num)
  (local
    [(define red (bitwise-bit-field num 0 8))
     (define green (bitwise-bit-field num 8 16))
     (define blue (bitwise-bit-field num 16 24))]
    (list 255 red green blue)))

;; ============================
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



;(define out (open-output-file "RGBmap.txt" #:exists 'replace))
;(write RGBmap out)
;(close-output-port out)


;; ===========================
;; Convert to gray scale
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

;(define out1 (open-output-file "grayscale.txt" #:exists 'replace))
;(write gray-scale out1)
;(close-output-port out1)
        
;; =================================
;; Function convert back to ARGB list

(define (back-to-argb-iter result lst)
  (if (null? lst)
      result
      (back-to-argb-iter (cons (extract-rgb (car lst)) result) (cdr lst))))

(define (back-to-argb lst)
  (back-to-argb-iter '() lst))

;(define out1 (open-output-file "RGBMap-return.txt" #:exists 'replace))
;(write (back-to-argb gray-scale) out1)
;(close-output-port out1)


;; ===============================
;; function convert back to bitmap (image)

(define test (make-object bitmap% img-width img-height))

(define finallist
  (reverse (back-to-argb gray-scale)))
  
(define out1 (open-output-file "finallist.txt" #:exists 'replace))
(write (append* (reverse (back-to-argb gray-scale))) out1)
(close-output-port out1)

(send test set-argb-pixels 0 0 img-width img-height (list->bytes (append* finallist)))





































