DROP SCHEMA IF EXISTS pgcv_measure CASCADE;
CREATE SCHEMA pgcv_measure;

-- =============================================
-- Author:      Roberto Mora
-- Description: Returns a json array with the region properties found in a binary image
-- =============================================
CREATE OR REPLACE FUNCTION pgcv_measure.region_props_json(image pgcv_core.ndarray_int4)
  RETURNS jsonb
AS $$
"""
Returns a json array with the region properties of a binary image

Parameters
----------
image : ndarray
    The image represented by a pgcv_core.ndarray_int4.
Returns
-------
regionprops : jsonb
    The json array with the region properties, corresponding to label, area, perimeter,
    centroid, solidity, eccentricity, convex_area, circularity, orientation and bbox.
Examples
--------
>>> SELECT pgcv_measure.region_props_json(pgcv_io.image_read('/path/to/binarized/image.png'));
Notes
-----
The input image must be binarized
"""

import numpy as np
import pandas as pd
from skimage import measure
import json

img = np.array(image["data"]).reshape(image["shape"]).astype('uint8')

# Get the regionprops
lbl = measure.label(img)
regions = measure.regionprops(lbl, coordinates='rc')

# Initialize the DataFrame with the desired columns
columns = [('label', int),
           ('area', int),
           ('perimeter', float),
           ('centroid', object),
           ('solidity', float),
           ('eccentricity', float),
           ('convex_area', int),
           ('circularity', float),
           ('orientation', float),
           ('bbox', object)]
df = pd.DataFrame({k: pd.Series(dtype=t) for k, t in columns})

# Fill the DataFrame
for i, reg in enumerate(regions):
    df.loc[i] = [
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
    ]

result = df.to_json(orient='records', double_precision=4)

return (result)
$$ LANGUAGE plpython3u STRICT;
COMMENT ON FUNCTION pgcv_measure.region_props_json(pgcv_core.ndarray_int4) IS 'Returns a json array with the region properties found in a binary image.';

-- =============================================
-- Author:      Roberto Mora
-- Description: Returns a set of region properties found in a binary image
-- =============================================
CREATE OR REPLACE FUNCTION pgcv_measure.region_props(image pgcv_core.ndarray_int4)
  RETURNS SETOF pgcv_core.regionprops
AS $$
"""
Returns a set of region properties found in a binary image

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
>>> SELECT * FROM pgcv_measure.region_props(pgcv_io.image_read('/Users/ro/Desktop/prueba.png'))
>>>   WHERE area > 15 AND area < 55;
Notes
-----
The input image must be binarized
"""

import numpy as np
from skimage import measure

img = np.array(image["data"]).reshape(image["shape"]).astype('uint8')

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
COMMENT ON FUNCTION pgcv_measure.region_props(pgcv_core.ndarray_int4) IS 'Returns a set of region properties found in a binary image.';


-- =============================================
-- These queries test the measure functions
-- =============================================
-- SELECT pgcv_measure.region_props_json(pgcv_io.image_read('/Users/ro/Desktop/prueba.png'))::json->2 as props;
--
-- SELECT pgcv_measure.region_props_json(pgcv_io.image_read('/Users/ro/Desktop/prueba.png'));
--
-- SELECT * FROM pgcv_measure.region_props(pgcv_io.image_read('/Users/ro/Desktop/prueba.png')) WHERE area > 15 AND area < 55;
