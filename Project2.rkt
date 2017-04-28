#lang racket
;; Version 1.0
;; This is the new algorithm use to convert image to sketch with the impoved of running time

(define start-time (current-inexact-milliseconds))
;; Due to the time consumming, image with size less than 1024x800.
;; Idea:
;; 1. Read pixel from image
;; 2. Convert to Gray Scale
;; 3. Invert Colors from Gray Scale
;; 4. Apply Gaussian Blur to Inverted Color
;; 5. Merge 2 and 4 to get a sketch image

;; This library is use for do the gaussian blur
(require images/flomap)
(require (except-in racket/draw make-pen make-color))

(define img-name "house.jpg")
;; ==============================================
;; Based functions
;; ==============================================

;; Get to single list with 1 value represent for 1 pixel in the list
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

;; this function store r/g/b to 24bits memory by using bitwise or/and with shift operators
(define (join-value red green blue)
  (let* ([redvalue (bitwise-and red #xFF)]
         [greenvalue (arithmetic-shift (bitwise-and green #xFF) 8)]
         [bluevalue (arithmetic-shift (bitwise-and blue #xFF) 16)])
    (bitwise-ior redvalue greenvalue bluevalue)))

;; Function convert back to ARGB list from list of 24bits values
(define (back-to-argb-iter result lst)
  (if (null? lst)
      result
      (back-to-argb-iter (cons (extract-rgb (car lst)) result) (cdr lst))))

(define (back-to-argb lst)
  (back-to-argb-iter '() lst))

;; ===============================
;; Posterize Function

(define levels 20)

(define (posterizeColor color)
  (if (>= color 128) 255 0))

(define (postvalue r g b)
    (join-value (posterizeColor r) (posterizeColor g) (posterizeColor b)))

(define (posterize color)
  (local
    [(define argb (extract-rgb color))
     (define red (get-r argb))
     (define green (get-g argb))
     (define blue (get-b argb))]
    (postvalue red green blue)))

;; =============================
;; Read image to bitmap% object

(define imginput (make-object bitmap% img-name))
(display "Input\n ")
imginput
;; get image height
(define img-height (- (send imginput get-height) 1))

;; get image width
(define img-width (- (send imginput get-width) 1))

;; allocate the memoery for pixels
(define pixels (make-bytes (* img-height img-width 4)))

;; read the argb value and store to pixels
(send imginput get-argb-pixels 0 0 img-width img-height pixels)

;; convert pixels to list for calcualte
(define PixelsList (bytes->list pixels))

;; ============================
;; This function read red/green/blue from PixelsList, then convert it to 24bits binays
;; then return a single list of 24bits integer

;; recursive interative process
;; time complexity for RGBmap-iter is O(N)
(define (RGBmap-iter result lst)
  (if (null? lst)
      result
      (RGBmap-iter
       (cons (join-value (get-r lst) (get-g lst) (get-b lst)) result)
       (remain-lst lst))))

;; space complexity is O(N/4)
;; It make a new list which the size of N/4 because joining 4 values ARGB into 1 value
(define RGBmap
  (RGBmap-iter '() PixelsList))

;; ===========================
;; Convert to gray scale from RGBMap

;; extract r/g/b, then return value = (r + g + b) / 3
;; then use join-value to convert back to 24 bits binary
(define (get-gray-value num)
  (let*
    [(red (bitwise-bit-field num 0 8))
     (green (bitwise-bit-field num 8 16))
     (blue (bitwise-bit-field num 16 24))
     (value (quotient (+ red green blue) 3))]
    (join-value value value value)))

(define (gray-scale-helper result lst )
  (if (null? lst)
     result
     (gray-scale-helper (cons (get-gray-value (car lst)) result) (cdr lst))))

(define gray-scale
  (gray-scale-helper '() RGBmap))


;; ===============================
;; Invert Colors from Gray Scale

;; recursive interative process
;; time complexity for invert-color is O(N)
(define (get-invert-value num)
  (let*
    [(red (bitwise-bit-field num 0 8))
     (green (bitwise-bit-field num 8 16))
     (blue (bitwise-bit-field num 16 24))]
    (join-value (- 255 red) (- 255 green) (- 255 blue))))

(define inverts-value
  (map (lambda (num) (get-invert-value num)) (reverse gray-scale)))

;; ==============================
;; Apply Gaussian Blur to Inverted Color
;; By using the flomap library, apply the built-in function flomap-gaussian-blur
;; to get the blur image

;; Convert invertes value back to argb
(define InvertedList
  (back-to-argb inverts-value))

;; apply the new pixels to bitmap% object
(send imginput set-argb-pixels 0 0 img-width img-height (list->bytes (append* InvertedList)))

;; convert it to flomap from the bitmap
(define fm (bitmap->flomap imginput))

;; apply the gaussian blur to the flopmap and also convert it back to the bitmap
;; now read the new argb from the blur
;; I mixed all the code togeter because I want to saved the memory so I dont have to make multiples object for bitmaps and pixels
(send (flomap->bitmap (flomap-gaussian-blur (flomap-inset fm 6) 2)) get-argb-pixels 0 0 img-width img-height pixels)

;;from pixels list, convert it to list for futher calcualte
(define BlurMap (bytes->list pixels))

(define BlurValue
  (RGBmap-iter '() BlurMap))

;;=============================
;; Color Dodge Blend Merge Function
;; Merge GrayList and BWRGBBlurList
;; if numblur == 255 return numblur
;; else return (numbw * 256) / (255 - numblur)

;; Using Tail Recursion for O(N) performance

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


(define (Color-Dodge-Blend-Merge BlurList GrayList)
  (define (Color-Dodge-Blend-Merge-iter result blurlist bwlist)
  (if (null? blurlist)
      result
      (Color-Dodge-Blend-Merge-iter (cons (return-dodge (car blurlist) (car bwlist)) result)
                                    (cdr blurlist) (cdr bwlist))))

  (Color-Dodge-Blend-Merge-iter '() (reverse BlurList) GrayList))

;; ===============================
;; Poterized image
(define Posterized (map (lambda (number) (posterize number)) RGBmap))

(define image
  (back-to-argb Posterized))

(send imginput set-argb-pixels 0 0 img-width img-height (list->bytes (append* image)))
(send imginput save-file "Posterized.png" 'png)

;; ===============================
;; function convert back to bitmap (image)

(define finallist
  (back-to-argb (Color-Dodge-Blend-Merge BlurValue gray-scale)))

(send imginput set-argb-pixels 0 0 img-width img-height (list->bytes (append* finallist)))
(send imginput save-file (string-append "Sketch_" img-name) 'png)

(display "Output\n ")
imginput

;; ===============================
;; calcuate the running time of the program
(define end-time (current-inexact-milliseconds))

(display "Runtime in seconds: ")
(round (/ (- end-time start-time) 1000))


;;(define out (open-output-file "PixelsList.txt" #:exists 'replace))
;;(write PixelsList out)
;;(close-output-port out)
