DROP SCHEMA IF EXISTS  pgcv_io CASCADE;
CREATE SCHEMA pgcv_io;

-- =============================================
-- Author:      Roberto Mora
-- Description: Reads an image from a file into an ndarray_int4
-- =============================================
CREATE OR REPLACE FUNCTION pgcv_io.image_read(filename varchar)
  RETURNS pgcv_core.ndarray_int4
AS $$
"""
Reads an image from a file into an ndarray_int4

Parameters
----------
filename : str
    Filename of the image (path).
Returns
-------
image : ndarray
    The image represented by a pgcv_core.ndarray_int4.
Examples
--------
>>> SELECT shape FROM pgcv_io.image_read('/path/to/image.png');
"""

import numpy as np
from PIL import Image

img = Image.open(filename)
img = np.array(img)

return (list(img.shape), np.ravel(img))
$$ LANGUAGE plpython3u STRICT;
COMMENT ON FUNCTION pgcv_io.image_read(varchar) IS 'Reads an image from a file into an ndarray_int4.';

-- =============================================
-- Author:      Roberto Mora
-- Description: Writes an image from an ndarray_int4 into the specified filename (path)
-- =============================================
CREATE OR REPLACE FUNCTION pgcv_io.image_write(image pgcv_core.ndarray_int4, filename varchar)
  RETURNS boolean
AS $$
"""
Writes an image from an ndarray_int4 into the specified filename (path)

Parameters
----------
image : ndarray
    The image represented by a pgcv_core.ndarray_int4.
filename : str
    Filename of the image (path)
Returns
-------
success : bool
    True if the image was saved successfully
Examples
--------
>>> DO $_$
>>> DECLARE arr pgcv_core.ndarray_int4;
>>> BEGIN
>>> SELECT shape, data FROM pgcv_io.image_read('/path/to/in_image.png') INTO arr;
>>> PERFORM pgcv_io.image_write(arr, '/path/to/out_image.png');
>>> END
>>> $_$
"""

import numpy as np
from PIL import Image

img = np.array(image["data"]).reshape(image["shape"]).astype('uint8')
img = Image.fromarray(img)
img.save(filename)

return True
$$ LANGUAGE plpython3u STRICT;
COMMENT ON FUNCTION pgcv_io.image_write(pgcv_core.ndarray_int4, varchar) IS 'Writes an image from an ndarray_int4 into the specified filename (path).';


-- =============================================
-- These queries test the IO functions
-- =============================================
-- SELECT shape FROM pgcv_io.image_read('/Users/ro/U/[ Asistencia ] - Proyecto de Investigacion/Source_Images/mdb155.pgm');
--
-- DO $_$
-- DECLARE arr pgcv_core.ndarray_int4;
-- BEGIN
-- SELECT shape, data FROM pgcv_io.image_read('/Users/ro/U/[ Asistencia ] - Proyecto de Investigacion/Source_Images/mdb155.pgm') INTO arr;
-- PERFORM pgcv_io.image_write(arr, '/Users/ro/Desktop/pba.png');
-- END
-- $_$