from skimage.io import imread
from block_distortion import animate_image, write_frames_to_gif

input_image = imread("./test.jpg") # Read image
frames = animate_image(input_image) # Create frames (same options available as on cmd line)
write_frames_to_gif("./output.gif", frames, duration=100) # Write to output file
