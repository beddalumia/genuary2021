# Adapted from https://preshing.com/20110831/penrose-tiling-explained/

import math
import cmath
import cairo


#------ Configuration --------
IMAGE_SIZE = (8000, 3600)
NUM_SUBDIVISIONS = 7
#-----------------------------


goldenRatio = (1 + math.sqrt(5)) / 2

def subdivide(triangles):
    result = []
    for color, A, B, C in triangles:
        if color == 0:
            # Subdivide half-kite triangles
            Q = A + (B - A) / goldenRatio
            R = B + (C - B) / goldenRatio
            result += [(1, R, Q, B), (0, Q, A, R), (0, C, A, R)]
        else:
            # Subdivide half-dart triangles
            P = C + (A - C) / goldenRatio
            result += [(1, B, P, A), (0, P, C, B)]
    return result

# Create wheel of half-kites around the origin
triangles = []
for i in range(10):
    B = cmath.rect(1, (2*i - 1) * math.pi / 10)
    C = cmath.rect(1, (2*i + 1) * math.pi / 10)
    if i % 2 == 0:
        B, C = C, B  # Make sure to mirror every second triangle
    triangles.append((0, B, 0j, C))

# Perform subdivisions
for i in range(NUM_SUBDIVISIONS):
    triangles = subdivide(triangles)

# Prepare cairo surface
surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, IMAGE_SIZE[0], IMAGE_SIZE[1])
cr = cairo.Context(surface)
cr.translate(IMAGE_SIZE[0] / 2.0, IMAGE_SIZE[1] / 2.0)
wheelRadius = 1.2 * math.sqrt((IMAGE_SIZE[0] / 2.0) ** 2 + (IMAGE_SIZE[1] / 2.0) ** 2)
cr.scale(wheelRadius, wheelRadius)

# Draw half-kites triangles
for color, A, B, C in triangles:
    if color == 0:
        cr.move_to(A.real, A.imag)
        cr.line_to(B.real, B.imag)
        cr.line_to(C.real, C.imag)
        cr.close_path()
cr.set_source_rgb(233/255,196/255,106/255)
cr.fill()

# Draw half-darts triangles
for color, A, B, C in triangles:
    if color == 1:
        cr.move_to(A.real, A.imag)
        cr.line_to(B.real, B.imag)
        cr.line_to(C.real, C.imag)
        cr.close_path()
cr.set_source_rgb(231/255,111/255,81/255)
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
surface.write_to_png('p2_tile.png')
