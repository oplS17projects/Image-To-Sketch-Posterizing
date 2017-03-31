# FP3: Final Project Assignment 3: Exploration 2
Due Sunday, March 26, 2017
Team : Image Converter
Team Member: Duy Truong & Chuong vu


(require racket/string)
My name: Duy Truong

Write what you did!
Remember that this report must include:
My team split the work into 2 parts:
 + Read and Calculate pixel
 + Store the data before and after calculate
I used the string library to store the pixel value before and after calculate.

Code & Explaination:

```Racket
#lang racket

(define (get-pixel x y)
  (local
    [(define str (any->string (get-pixel-color y x imgtest)))
     (define str1 (string-split (substring str 15 (- (string-length str) 1))))]
    (list (string->number (list-ref str1 0)) (string->number (list-ref str1 1)) (string->number (list-ref str1 2)))))

```

I used string-split to split the the string after we read from image. Because the data we get from (get-pixel-color y x imgtest) is read data. we do not allow to edit the data. So we store it in to the new list with struct '( red green blue).
```
(define (RGBList-iter width height)
  (for/list ([x (in-range 0 height)])
    (for/list ([y (in-range 0 width)])
            (get-pixel x y))))    
(define RGBList
  (RGBList-iter img-width img-height))
```
we used the for/list to read thought the image and store the data as list.
when we read the hold picture, we have list inside list. So to draw picture i use Append* to merge list inside list to one list.


![Screenshot](Output test.png)

<!-- Links -->
[FP1]: https://github.com/oplS17projects/FP1
[schedule]: https://github.com/oplS17projects/FP-Schedule
[markdown]: https://help.github.com/articles/markdown-basics/
[forking]: https://guides.github.com/activities/forking/
[ref-clone]: http://gitref.org/creating/#clone
[ref-commit]: http://gitref.org/basic/#commit
[ref-push]: http://gitref.org/remotes/#push
[pull-request]: https://help.github.com/articles/creating-a-pull-request
