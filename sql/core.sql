DROP SCHEMA IF EXISTS  pgcv_core CASCADE;
CREATE SCHEMA pgcv_core;

-- =============================================
-- Author:      Roberto Mora
-- Description: N-dimentional array of int4 elements
-- =============================================
CREATE TYPE pgcv_core.ndarray_int4 AS (
  shape   int[],
  data    int[]
);
COMMENT ON TYPE pgcv_core.ndarray_int4 IS 'N-dimensional array of int4 elements. Generally used to manipulate images.';

-- =============================================
-- Author:      Roberto Mora
-- Description: Region properties of an object found in a binary image
-- =============================================
CREATE TYPE pgcv_core.regionprops AS (
  label         int,
  area          int,
  perimeter     float,
  centroid      float[2],
  solidity      float,
  eccentricity  float,
  convex_area   int,
  circularity   float,
  orientation   float,
  bbox          int[4]
);
COMMENT ON TYPE pgcv_core.regionprops IS 'Region properties of an object found in a binary image.';

-- =============================================
-- Author:      Roberto Mora
-- Description: Calculates the average hash of an image
-- =============================================
CREATE OR REPLACE FUNCTION pgcv_core.hash_avg(image pgcv_core.ndarray_int4, size int DEFAULT 8)
  RETURNS varchar
AS $$
"""
Calculates the average hash of an image.

Parameters
----------
image : ndarray
    The image represented by a pgcv_core.ndarray_int4.
size : int, optional
    Size of the hash. This size is used to resize the supplied image using 'lanczos' interpolation.
Returns
-------
hash : str
    The average hash in base 16.
Examples
--------
>>> SELECT pgcv_core.hash_avg(pgcv_io.image_read('/path/to/image.png'));
Notes
-----
The input image must be grayscale.
"""

import numpy as np
from scipy import misc

img = np.array(image["data"]).reshape(image["shape"]).astype('uint8')
pixels = misc.imresize(img, (size, size), 'lanczos')
avg = pixels.mean()
diff = pixels > avg

# Binary array to hex
h = 0
s = []
for i,v in enumerate(diff.flatten()):
  if v: h += 2**(i % 8)
  if (i % 8) == 7:
    s.append(hex(h)[2:].rjust(2, '0'))
    h = 0
return "".join(s)
$$ LANGUAGE plpython3u STRICT;
COMMENT ON FUNCTION pgcv_core.hash_avg(pgcv_core.ndarray_int4, int) IS 'Calculates the average hash of an image.';


-- =============================================
-- These queries test the core functions
-- =============================================
-- SELECT * FROM pgcv_core.hash_avg(pgcv_io.image_read('/Users/ro/U/[ Asistencia ] - Proyecto de Investigacion/Source_Images/mdb155.pgm'));
