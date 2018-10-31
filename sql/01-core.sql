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
COMMENT ON TYPE pgcv_core.ndarray_int4 IS 'N-dimensional array of int4 elements. Used to represent and store images.';

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
-- Author:      Roberto Mora
-- Description: Returns the thumbnail of an image with the specified width and height
-- =============================================
CREATE OR REPLACE FUNCTION pgcv_core.thumbnail(image pgcv_core.ndarray_int4, width int DEFAULT 200, height int DEFAULT 200)
  RETURNS pgcv_core.ndarray_int4
AS $$
"""
Returns the thumbnail of an image with the specified width and height.

Parameters
----------
image : ndarray
    The image represented by a pgcv_core.ndarray_int4.
width : int
    The target width of the thumbnail, it defaults to 200.
height : int
    The target height of the thumbnail, it defaults to 200.
Returns
-------
image : ndarray
    The thumbnail of the image of type pgcv_core.ndarray_int4.
Examples
--------
>>> SELECT shape from pgcv_core.thumbnail(pgcv_io.image_read('/path/to/image.png'), 250, 250);
"""

import numpy as np
from PIL import Image

img = np.array(image["data"]).reshape(image["shape"]).astype('uint8')
img = Image.fromarray(img)

size = width, height
img.thumbnail(size)

img = np.array(img)

return (list(img.shape), np.ravel(img))
$$ LANGUAGE plpython3u STRICT;
COMMENT ON FUNCTION pgcv_core.thumbnail(pgcv_core.ndarray_int4, int, int) IS 'Returns the thumbnail of an image with the specified width and height.';

-- =============================================
-- Author:      Roberto Mora
-- Description: Returns the data uri of the thumbnail of an image with the specified width and height, encoded in base64.
-- =============================================
CREATE OR REPLACE FUNCTION pgcv_core.thumbnail_uri_base64(image pgcv_core.ndarray_int4, width int DEFAULT 200, height int DEFAULT 200)
  RETURNS VARCHAR
AS $$
"""
Returns the data uri of the thumbnail of an image with the specified width and height, encoded in base64.

Parameters
----------
image : ndarray
    The image represented by a pgcv_core.ndarray_int4.
width : int
    The target width of the thumbnail, it defaults to 200.
height : int
    The target height of the thumbnail, it defaults to 200.
Returns
-------
image : ndarray
    The thumbnail of the image encoded in a base64 data uri.
Examples
--------
>>> SELECT shape from pgcv_core.thumbnail_uri_base64(pgcv_io.image_read('/path/to/image.png'), 250, 250);
"""

import numpy as np
from PIL import Image
import base64
from io import BytesIO

img = np.array(image["data"]).reshape(image["shape"]).astype('uint8')
img = Image.fromarray(img)

size = width, height
img.thumbnail(size)

buffered = BytesIO()
img.save(buffered, format="PNG")
img_str = base64.b64encode(buffered.getvalue())

return('data:image/png;base64,' + img_str.decode("utf-8"))
$$ LANGUAGE plpython3u STRICT;
COMMENT ON FUNCTION pgcv_core.thumbnail_uri_base64(pgcv_core.ndarray_int4, int, int) IS 'Returns the data uri of the thumbnail of an image with the specified width and height, encoded in base64.';

-- =============================================
-- Author:      Roberto Mora
-- Description: Returns the data uri of an image, encoded in base64.
-- =============================================
CREATE OR REPLACE FUNCTION pgcv_core.uri_base64(image pgcv_core.ndarray_int4)
  RETURNS VARCHAR
AS $$
"""
Returns the data uri of an image, encoded in base64.

Parameters
----------
image : ndarray
    The image represented by a pgcv_core.ndarray_int4.
Returns
-------
image : ndarray
    The image encoded in a base64 data uri.
Examples
--------
>>> SELECT shape from pgcv_core.uri_base64(pgcv_io.image_read('/path/to/image.png'));
"""

import numpy as np
from PIL import Image
import base64
from io import BytesIO

img = np.array(image["data"]).reshape(image["shape"]).astype('uint8')
img = Image.fromarray(img)

buffered = BytesIO()
img.save(buffered, format="PNG")
img_str = base64.b64encode(buffered.getvalue())

return('data:image/png;base64,' + img_str.decode("utf-8"))
$$ LANGUAGE plpython3u STRICT;
COMMENT ON FUNCTION pgcv_core.uri_base64(pgcv_core.ndarray_int4) IS 'Returns the data uri of an image, encoded in base64.';


-- =============================================
-- These queries test the core functions
-- =============================================
-- SELECT * FROM pgcv_core.hash_avg(pgcv_io.image_read('/Users/ro/U/[ Asistencia ] - Proyecto de Investigacion/Source_Images/mdb155.pgm'));
--
-- SELECT * from pgcv_core.thumbnail(pgcv_io.image_read('/Users/ro/U/[ Asistencia ] - Proyecto de Investigacion/Source_Images/mdb155.pgm'))
--
-- SELECT * from pgcv_core.thumbnail_uri_base64(pgcv_io.image_read('/Users/ro/U/[ Asistencia ] - Proyecto de Investigacion/Source_Images/mdb155.pgm'))
--
-- SELECT * from pgcv_core.uri_base64(pgcv_io.image_read('/Users/ro/U/[ Asistencia ] - Proyecto de Investigacion/Source_Images/mdb155.pgm'))