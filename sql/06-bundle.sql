DROP SCHEMA IF EXISTS pgcv_bundle CASCADE;
CREATE SCHEMA pgcv_bundle;

-- =============================================
-- Author:      Roberto Mora
-- Description: Returns a set of region properties found in a mammogram image
-- =============================================
CREATE OR REPLACE FUNCTION pgcv_bundle.mam_region_props(image pgcv_core.ndarray_int4, kernel int DEFAULT 5)
  RETURNS SETOF pgcv_core.regionprops
AS $$
"""
Returns a set of region properties found in a mammogram image

Parameters
----------
image : ndarray
    The image represented by a pgcv_core.ndarray_int4.
Returns
-------
regionprops : setof regionprops
    The set with the region properties, corresponding to label, area, perimeter,
    centroid, solidity, eccentricity, convex_area, circularity, orientation and bbox.
Examples
--------
>>> SELECT * FROM pgcv_bundle.mam_region_props(pgcv_io.image_read('path/to/image.png'))
>>>   WHERE area > 15 AND area < 55;
Notes
-----
The input image must be unaltered.
"""

import numpy as np
import pandas as pd
from scipy import signal
from skimage import measure, filters

img = np.array(image["data"]).reshape(image["shape"]).astype('uint8')

"""
1. Apply the mean filter
"""
img = signal.medfilt(img, kernel).astype('uint8')

"""
2. Enhance the image through the otsu enhancement
"""
thresh = filters.threshold_otsu(img)
f = thresh / (255 - thresh)
img = ((1 - f) * (255 - img * (1 + f))).astype('uint8')

"""
3. Binarize the image
"""
img = np.where(img < thresh, 0, 255)

"""
4. Calculate the regionprops
"""
# Get the regionprops
lbl = measure.label(img)
regions = measure.regionprops(lbl, coordinates='rc')

# Yield the results
for i, reg in enumerate(regions):
    yield (
        reg.label,
        reg.area,
        reg.perimeter,
        reg.centroid,
        reg.solidity,
        reg.eccentricity,
        reg.convex_area,
        4 * np.pi * reg.area / reg.perimeter ** 2 if reg.perimeter != 0 else np.inf,  # circularity
        reg.orientation,
        reg.bbox
    )
$$ LANGUAGE plpython3u STRICT;
COMMENT ON FUNCTION pgcv_bundle.mam_region_props(pgcv_core.ndarray_int4, int) IS 'Returns a set of region properties found in a mammogram image';

-- =============================================
-- Author:      Roberto Mora
-- Description: Returns an image segmented through Otsu's enhancement
-- =============================================
CREATE OR REPLACE FUNCTION pgcv_bundle.mam_segment(image pgcv_core.ndarray_int4, kernel int DEFAULT 5)
  RETURNS pgcv_core.ndarray_int4
AS $$
"""
Returns an image segmented through Otsu's enhancement

Parameters
----------
image : ndarray
    The image represented by a pgcv_core.ndarray_int4.
Returns
-------
segmented_image : ndarray
    An image segmented through Otsu's enhancement
Examples
--------
>>> SELECT * FROM pgcv_bundle.mam_segment(pgcv_io.image_read('/path/to/image.png'));
"""

import numpy as np
from scipy import signal
from skimage import filters

img = np.array(image["data"]).reshape(image["shape"]).astype('uint8')

"""
1. Apply the mean filter
"""
img = signal.medfilt(img, kernel).astype('uint8')

"""
2. Enhance the image through the otsu enhancement
"""
thresh = filters.threshold_otsu(img)
f = thresh / (255 - thresh)
img = ((1 - f) * (255 - img * (1 + f))).astype('uint8')

"""
3. Binarize the image
"""
img = np.where(img < thresh, 0, 255)

"""
4. Return the segmented image
"""

return (list(img.shape), np.ravel(img).astype('uint8'))
$$ LANGUAGE plpython3u STRICT;
COMMENT ON FUNCTION pgcv_bundle.mam_segment(pgcv_core.ndarray_int4, int) IS 'Returns an image segmented through Otsu''s enhancement';


-- =============================================
-- These queries test the bundle functions
-- =============================================
-- SELECT * FROM pgcv_bundle.mam_region_props(pgcv_io.image_read('/Users/ro/U/[ Asistencia ] - Proyecto de Investigacion/Source_Images/mdb155.pgm')) WHERE area > 15 AND area < 55;
SELECT * FROM pgcv_bundle.mam_segment(pgcv_io.image_read('/Users/ro/U/[ Asistencia ] - Proyecto de Investigacion/Source_Images/mdb155.pgm'));

select pgcv_bundle.mam_segment(image) from med_img.instance limit 1;

select shape, data, uuid from pgcv_bundle.mam_segment((select image from med_img.instance where uuid = '0a352d08-c0f2-4175-aec5-c036af5d5eb7')), med_img.instance where uuid = '0a352d08-c0f2-4175-aec5-c036af5d5eb7';


select uuid from med_img.instance;
