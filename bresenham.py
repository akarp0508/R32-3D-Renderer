def bresenham_line(x0, y0, x1, y1):
    """Generates the list of pixel coordinates for a line using Bresenham's algorithm."""
    points = []

    dx = abs(x1 - x0)
    dy = -abs(y1 - y0)

    sx = 1 if x0 < x1 else -1
    sy = 1 if y0 < y1 else -1

    err = dx + dy

    while True:
        points.append((x0, y0))
        if x0 == x1 and y0 == y1:
            break
        e2 = 2 * err
        if e2 > dy:
            err += dy
            x0 += sx
        if e2 < dx:
            err += dx
            y0 += sy

    return points

def draw_canvas(width, height, points):
    """Creates a 2D canvas and draws the points."""
    canvas = [['.' for _ in range(width)] for _ in range(height)]
    for x, y in points:
        if 0 <= x < width and 0 <= y < height:
            canvas[y][x] = '#'
    for row in canvas:
        print(' '.join(row))

# === Test Case ===
if __name__ == "__main__":
    width = 20
    height = 10
    x0, y0 = 2, 7
    x1, y1 = 1, 3

    line_points = bresenham_line(x0, y0, x1, y1)
    draw_canvas(width, height, line_points)
