DROP SCHEMA IF EXISTS  pgcv_histogram CASCADE;
CREATE SCHEMA pgcv_histogram;

-- =============================================
-- Author:      Roberto Mora
-- Description: Compute the histogram of a set of data and the bin edges
-- =============================================
CREATE OR REPLACE FUNCTION pgcv_histogram.hist_bin_edges(image pgcv_core.ndarray_int4, bins int DEFAULT 10, as_float boolean DEFAULT TRUE,
  OUT hist numeric[], OUT bin_edges numeric[])
AS $$
"""
Compute the histogram of a set of data and the bin edges

Parameters
----------
image : ndarray
    The image represented by a pgcv_core.ndarray_int4.
bins : int, optional
    Number of bins in the histogram. Defaults to 10
as_float : bool, optional
    Indicates if the image should be converted as float for the histogram computation. Defaults to TRUE
Returns
-------
hist : array
    The histogram represented by an numeric array.
bin_edges : array
    The bin_edges represented by a numeric array.
Examples
--------
>>> SELECT * FROM pgcv_histogram.hist_bin_edges(pgcv_io.image_read('/path/to/image.png'));
>>> SELECT * FROM pgcv_histogram.hist_bin_edges(pgcv_io.image_read('/path/to/image.png'), 5, FALSE);
>>> SELECT * FROM pgcv_histogram.hist_bin_edges(pgcv_io.image_read('/path/to/image.png'), 5);
Notes
-----
The bin_edges array is of length (length(hist) + 1)
"""

import numpy as np
from skimage import img_as_float

img = np.array(image["data"]).reshape(image["shape"]).astype('uint8')
if (as_float == True):
  img = img_as_float(img)
hist, bin_edges = np.histogram(img, bins)

return (hist, bin_edges)
$$ LANGUAGE plpython3u STRICT;
COMMENT ON FUNCTION pgcv_histogram.hist_bin_edges(pgcv_core.ndarray_int4, int, boolean, OUT int[], OUT numeric[]) IS 'Compute the histogram of a set of data and the bin edges. The user can choose to convert the image to float';

-- =============================================
-- Author:      Roberto Mora
-- Description: Compute the normalized histogram of a set of data and the bin centers
-- =============================================
CREATE OR REPLACE FUNCTION pgcv_histogram.hist_bin_centers(image pgcv_core.ndarray_int4, bins int DEFAULT 10,
  OUT hist numeric[], OUT bin_centers numeric[])
AS $$
"""
Compute the normalized histogram of a set of data and the bin centers

Parameters
----------
image : ndarray
    The image represented by a pgcv_core.ndarray_int4.
bins : int, optional
    Number of bins in the histogram. Defaults to 10
Returns
-------
hist : array
    The normalized histogram represented by an numeric array.
bin_centers : array
    The bin_centers represented by a numeric array.
Examples
--------
>>> SELECT * FROM pgcv_histogram.hist_bin_centers(pgcv_io.image_read('/path/to/image.png'), 5);
>>> SELECT * FROM pgcv_histogram.hist_bin_centers(pgcv_io.image_read('/path/to/image.png'));
Notes
-----
The bin_centers array is of length length(hist)
"""

import numpy as np
from skimage import exposure, img_as_float

img = np.array(image["data"]).reshape(image["shape"]).astype('uint8')
img = img_as_float(img)
hist, bin_centers = exposure.histogram(img, bins)

return (hist, bin_centers)
$$ LANGUAGE plpython3u STRICT;
COMMENT ON FUNCTION pgcv_histogram.hist_bin_centers(pgcv_core.ndarray_int4, int, OUT int[], OUT numeric[]) IS 'Compute the normalized histogram of a set of data and the bin centers.';


-- =============================================
-- These queries test the histogram functions
-- =============================================
-- SELECT * FROM pgcv_histogram.hist_bin_edges(pgcv_io.image_read('/Users/ro/U/[ Asistencia ] - Proyecto de Investigacion/Source_Images/mdb155.pgm'));
-- SELECT * FROM pgcv_histogram.hist_bin_edges(pgcv_io.image_read('/Users/ro/U/[ Asistencia ] - Proyecto de Investigacion/Source_Images/mdb155.pgm'), 5, FALSE);
-- SELECT * FROM pgcv_histogram.hist_bin_edges(pgcv_io.image_read('/Users/ro/U/[ Asistencia ] - Proyecto de Investigacion/Source_Images/mdb155.pgm'), 5);
--
-- SELECT * FROM pgcv_histogram.hist_bin_centers(pgcv_io.image_read('/Users/ro/U/[ Asistencia ] - Proyecto de Investigacion/Source_Images/mdb155.pgm'), 5);
-- SELECT * FROM pgcv_histogram.hist_bin_centers(pgcv_io.image_read('/Users/ro/U/[ Asistencia ] - Proyecto de Investigacion/Source_Images/mdb155.pgm'));
