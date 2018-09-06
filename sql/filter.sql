DROP SCHEMA IF EXISTS  pgcv_filter CASCADE;
CREATE SCHEMA pgcv_filter;

-- =============================================
-- Author:      Roberto Mora
-- Description: Perform a median filter on an N-dimensional array.
-- =============================================
CREATE OR REPLACE FUNCTION pgcv_filter.blur_median(image pgcv_core.ndarray_int4, kernel int DEFAULT 3)
  RETURNS pgcv_core.ndarray_int4
AS $$
"""
Perform a median filter on an N-dimensional array.

Apply a median filter to the input array using a local window-size given by kernel.

Parameters
----------
image : ndarray
    The image represented by a pgcv_core.ndarray_int4.
kernel : int, optional
    Local window-size giving the size of the median filter. Defaults to 3
Returns
-------
image : ndarray
    The image represented by a pgcv_core.ndarray_int4.
Examples
--------
>>> DO $_$
>>> DECLARE
>>>   arr pgcv_core.ndarray_int4;
>>>   arr2 pgcv_core.ndarray_int4;
>>> BEGIN
>>> SELECT shape, data FROM pgcv_io.image_read('/path/to/image.png') INTO arr;
>>> SELECT shape, data FROM pgcv_filter.blur_median(arr, 4) INTO arr2;
>>> PERFORM pgcv_io.image_write(arr, '/path/to/unmodified_image.png');
>>> PERFORM pgcv_io.image_write(arr2, '/path/to/modified_image.png');
>>> END
>>> $_$
Notes
-----
Kernel size must be odd
"""

import numpy as np
from scipy import signal

global kernel

if kernel % 2 == 0:
  plpy.notice('Invalid kernel size "{}". Kernel must be odd. Default size 3 will be used instead'.format(kernel))
  kernel = 3

img = np.array(image["data"]).reshape(image["shape"]).astype('uint8')
med = signal.medfilt(img, kernel).astype('uint8')

return (list(med.shape), np.ravel(med))
$$ LANGUAGE plpython3u STRICT;
COMMENT ON FUNCTION pgcv_filter.blur_median(pgcv_core.ndarray_int4, int) IS 'Perform a median filter on an N-dimensional array.';

-- =============================================
-- Author:      Roberto Mora
-- Description: Calculates a threshold value based on Otsu's method.
-- =============================================
CREATE OR REPLACE FUNCTION pgcv_filter.threshold_otsu(image pgcv_core.ndarray_int4)
  RETURNS float
AS $$
"""
Calculates a threshold value based on Otsu's method.

Parameters
----------
image : ndarray
    The image represented by a pgcv_core.ndarray_int4.
Returns
-------
thresh : float
    A float that is the Otsu's threshold.
Examples
--------
>>> SELECT pgcv_filter.threshold_otsu(pgcv_io.image_read('/path/to/image.png'));
"""

import numpy as np
from skimage import filters

img = np.array(image["data"]).reshape(image["shape"]).astype('uint8')
thresh = filters.threshold_otsu(img)

return thresh
$$ LANGUAGE plpython3u STRICT;
COMMENT ON FUNCTION pgcv_filter.threshold_otsu(pgcv_core.ndarray_int4) IS 'Calculates a threshold value based on Otsu''s method.';

-- =============================================
-- Author:      Roberto Mora
-- Description: Enhances an image using the otsu threshold. Used for mammogram analysis
-- =============================================
CREATE OR REPLACE FUNCTION pgcv_filter.enhancement_otsu(image pgcv_core.ndarray_int4)
  RETURNS pgcv_core.ndarray_int4
AS $$
"""
Enhances an image using the otsu threshold. Used for mammogram analysis.

Parameters
----------
image : ndarray
    The image represented by a pgcv_core.ndarray_int4.
Returns
-------
image : ndarray
    Enhanced image represented by a pgcv_core.ndarray_int4.
Examples
--------
>>> SELECT * from pgcv_filter.enhancement_otsu(pgcv_io.image_read('/path/to/image.png'));
>>> SELECT * from pgcv_io.image_write(
>>>     pgcv_filter.enhancement_otsu(
>>>         pgcv_filter.blur_median(
>>>             pgcv_io.image_read('/path/to/in_image.png'), 5
>>>         )
>>>     ), '/path/to/out_image.png');
Notes
-----
The median blur should be applied previous to this enhancement
"""

import numpy as np
from skimage import filters

img = np.array(image["data"]).reshape(image["shape"]).astype('uint8')
thresh = filters.threshold_otsu(img)
f = thresh / (255 - thresh)

img = (1 - f) * (255 - img * (1 + f))

return (list(img.shape), np.ravel(img).astype('uint8'))
$$ LANGUAGE plpython3u STRICT;
COMMENT ON FUNCTION pgcv_filter.enhancement_otsu(pgcv_core.ndarray_int4) IS 'Enhances an image using the otsu threshold. Used for mammogram analysis';


-- =============================================
-- These queries test the filtering functions
-- =============================================
-- DO $_$
-- DECLARE
--   arr pgcv_core.ndarray_int4;
--   arr2 pgcv_core.ndarray_int4;
-- BEGIN
-- SELECT shape, data FROM pgcv_io.image_read('/Users/ro/U/[ Asistencia ] - Proyecto de Investigacion/Source_Images/mdb155.pgm') INTO arr;
-- SELECT shape, data FROM pgcv_filter.blur_median(arr, 4) INTO arr2;
-- PERFORM pgcv_io.image_write(arr, '/Users/ro/Desktop/pba.png');
-- PERFORM pgcv_io.image_write(arr2, '/Users/ro/Desktop/pba2.png');
-- END
-- $_$
--
-- SELECT * from pgcv_io.image_write(
--     pgcv_filter.enhancement_otsu(
--         pgcv_filter.blur_median(
--             pgcv_io.image_read('/Users/ro/U/[ Asistencia ] - Proyecto de Investigacion/Source_Images/mdb155.pgm'), 5
--         )
--     ), '/Users/ro/Desktop/pba.png');
