# Posterizing

### Version: 0.3

### Statement

Our project is simply convert an image to cartoon/stretch image. We plans implement an application that allow users convert any image that they wanted into a difference style.

### Analysis
An digital image is a contributed by millions pixel/dot. And each pixel is contain 3 values Reg/Green/Blue (RGB) and these value make a color. Our program is load every pixel (RGB) into a list of list (or we can say 2-dimension array or matrix x/y). The pixel in the matrix is represent each dot on the image so it help us easily keep track the color at the position x/y. By that, we can can change the color to anything we want and for this project, our goal it convert the image to cartoon/stretch image.


### Deliverable and Demonstration
We successfully converted color image to the Black-and-White (BW) image.


## Image:
![alt text][output]

### Evaluation of Results
We are almost there, we are now searching for a good algorithm that do a filter, which it use to combine this filter and BW to create a new image.

* The BW image is very simple, it is made from gray value and gray value is the mean of RGB values.
* Filter, we are searching for a good algorithm now. There are many image’s filter such as Median Blur, Bilateral filter, Min filter. 

We may use Median Blur and redraw the image based on detect and enhance edges algorithm to create a new image.


## Architecture Diagram

![alt text][diagram]

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
[x] Read RGB into 2D list 
[x] Merge the data from 2D list into single List
[x] Merge gray and filter to 2D list
[x] Work on filter
[] Addressed all bugs before demonstrate.

### Chuong Vu @vdc1703
Main: Gather information needed for the project.
[x] Convert and store the changeable RGB into 2D list
[x] Calculate gray values into new 2D list
[x] Work on filter
[x] Convert new 2D list to a new image
[] Clean up the code, ready to demonstrate


<!-- Links -->
[output]: https://github.com/oplS17projects/Image-To-Cartoon/blob/master/OutPut.PNG
[diagram]: https://github.com/oplS17projects/Image-To-Cartoon/blob/master/Diagram.png
