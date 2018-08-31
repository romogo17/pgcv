DROP SCHEMA IF EXISTS  pgcv_io CASCADE;
CREATE SCHEMA pgcv_io;


-- =============================================
-- Author:      Roberto Mora
-- Description: Reads an image from a file into an ndarray_int4
--
-- Parameters:
--   filename - filename of the image (path)
-- Returns:     An N-dimensional array of type int4
-- =============================================
CREATE FUNCTION pgcv_io.image_read(filename varchar)
  RETURNS pgcv_core.ndarray_int4
AS $$
import numpy as np
from PIL import Image

img = Image.open(filename)
img = np.array(img)

return (list(img.shape), np.ravel(img))
$$ LANGUAGE plpython3u STRICT;


-- =============================================
-- Author:      Roberto Mora
-- Description: Writes an image from an ndarray_int4 into the specified filename (path)
--
-- Parameters:
--   image - the image represented by a ndarray_int4
--   filename - filename of the image (path)
-- Returns:     true if the image was saved successfully
-- =============================================
CREATE FUNCTION pgcv_io.image_write(image pgcv_core.ndarray_int4, filename varchar)
  RETURNS boolean
AS $$
import numpy as np
from PIL import Image

img = np.array(image["data"]).reshape(image["shape"]).astype('uint8')
img = Image.fromarray(img)
img.save(filename)

return True
$$ LANGUAGE plpython3u STRICT;


/**
aall
 */

-- =============================================
-- These functions test the IO functions
-- =============================================
-- SELECT shape FROM pgcv_io.image_read('/Users/ro/U/[ Asistencia ] - Proyecto de Investigacion/Source_Images/mdb155.pgm');
--
-- DO $$
-- DECLARE arr pgcv_core.ndarray_int4;
-- BEGIN
-- SELECT shape, data FROM pgcv_io.image_read('/Users/ro/U/[ Asistencia ] - Proyecto de Investigacion/Source_Images/mdb155.pgm') INTO arr;
-- PERFORM pgcv_io.image_write(arr, '/Users/ro/Desktop/pba.png');
-- END
-- $$
