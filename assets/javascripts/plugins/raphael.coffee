Raphael.fn.sector = (cx, cy, r, startAngle, endAngle) ->
  rad = Math.PI / 180;
  x1 = cx + r * Math.cos(-startAngle * rad)
  x2 = cx + r * Math.cos(-endAngle * rad)
  y1 = cy + r * Math.sin(-startAngle * rad)
  y2 = cy + r * Math.sin(-endAngle * rad)
  
  @path(["M", cx, cy, "L", x1, y1, "A", r, r, 0, +(endAngle - startAngle > 180), 0, x2, y2, "z"])

Raphael.fn.roundedRectangle = (x, y, w, h, r1, r2, r3, r4) ->
  array = []
  array = array.concat(["M", x, r1 + y, "Q", x, y, x + r1, y]) #A
  array = array.concat(["L", x + w - r2, y, "Q", x + w, y, x + w, y + r2]) #B
  array = array.concat(["L", x + w, y + h - r3, "Q", x + w, y + h, x + w - r3, y + h]) #C
  array = array.concat(["L", x + r4, y + h, "Q", x, y + h, x, y + h - r4, "Z"]) #D
  @path array