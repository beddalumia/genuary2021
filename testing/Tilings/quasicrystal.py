import math
import cmath
import itertools
import cairo


#------ Configuration --------
IMAGE_SIZE = (10000, 10000)
NUM_SUBDIVISIONS = 6
#-----------------------------


goldenRatio = (1 + math.sqrt(5)) / 2

def subdivide(triangles):
    result = []
    for color, A, B, C in triangles:
        if color == 0:
            P = A + (B - A) / goldenRatio
            result += [(0, C, P, B), (1, P, C, A)]
        elif color == 1:
            Q = B + (A - B) / goldenRatio
            R = B + (C - B) / goldenRatio
            result += [(1, R, C, A), (2, Q, R, B), (0, R, Q, A)]
        elif color == 2:
            Q = B + (A - B) / goldenRatio
            R = B + (C - B) / goldenRatio
            result += [(1, R, C, A), (3, Q, R, B), (0, R, Q, A)]
        elif color == 3:
            Q = B + (A - B) / goldenRatio
            R = B + (C - B) / goldenRatio
            result += [(1, R, C, A), (2, Q, R, B), (0, R, Q, A)]
    return result

# Create wheel of red triangles around the origin
triangles = []
for i in range(10):
    B = cmath.rect(1, (2*i - 1) * math.pi / 10)
    C = cmath.rect(1, (2*i + 1) * math.pi / 10)
    if i % 2 == 0:
        B, C = C, B  # Make sure to mirror every second triangle
    triangles.append((0, 0j, B, C))

# Perform subdivisions
for i in range(NUM_SUBDIVISIONS):
    triangles = subdivide(triangles)

## All permutations of colors

p = list(itertools.permutations([0,1,2,3], 4))

for t in p:

	# Prepare cairo surface
	surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, IMAGE_SIZE[0], IMAGE_SIZE[1])
	cr = cairo.Context(surface)
	cr.translate(IMAGE_SIZE[0] / 2.0, IMAGE_SIZE[1] / 2.0)
	wheelRadius = 1.2 * math.sqrt((IMAGE_SIZE[0] / 2.0) ** 2 + (IMAGE_SIZE[1] / 2.0) ** 2)
	cr.scale(wheelRadius, wheelRadius)

	# Draw #e76f51 triangles
	for color, A, B, C in triangles:
		if color == t[0]:
		    cr.move_to(A.real, A.imag)
		    cr.line_to(B.real, B.imag)
		    cr.line_to(C.real, C.imag)
		    cr.close_path()
	cr.set_source_rgb(231/255,111/255,81/255)
	cr.fill()    

	# Draw #2a9d8f triangles
	for color, A, B, C in triangles:
		if color == t[1]:
		    cr.move_to(A.real, A.imag)
		    cr.line_to(B.real, B.imag)
		    cr.line_to(C.real, C.imag)
		    cr.close_path()
	cr.set_source_rgb(244/255,162/255,97/255)
	cr.fill()

	# Draw #f4a261 triangles
	for color, A, B, C in triangles:
		if color == t[2]:
		    cr.move_to(A.real, A.imag)
		    cr.line_to(B.real, B.imag)
		    cr.line_to(C.real, C.imag)
		    cr.close_path()
	cr.set_source_rgb(42/255,157/255,143/255)
	cr.fill()

	# Draw #e9c46a triangles
	for color, A, B, C in triangles:
		if color == t[3]:
		    cr.move_to(A.real, A.imag)
		    cr.line_to(B.real, B.imag)
		    cr.line_to(C.real, C.imag)
		    cr.close_path()
	cr.set_source_rgb(233/255,196/255,106/255)
	cr.fill()

	# Determine line width from size of first triangle
	color, A, B, C = triangles[0]
	cr.set_line_width(abs(B - A) / 10.0)
	cr.set_line_join(cairo.LINE_JOIN_ROUND)

	# Draw outlines
	for color, A, B, C in triangles:
		cr.move_to(C.real, C.imag)
		cr.line_to(A.real, A.imag)
		cr.line_to(B.real, B.imag)
	cr.set_source_rgb(38/255,70/255,83/255)
	cr.stroke()

	# Save to PNG
	fileID = str(t[0])+str(t[1])+str(t[2])+str(t[3])
	print(fileID)
	surface.write_to_png('quasicrystal'+fileID+'.png')
