from skimage import img_as_ubyte
from skimage.io import imread, imsave
from block_distortion import distort_image

# Read Image
input_image = imread("test.jpg") # Read image
distorted = distort_image(input_image) # Create distorted image
imsave("./output.png", img_as_ubyte(distorted)) # Save image
