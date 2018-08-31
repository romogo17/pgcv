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

-- =============================================
-- Author:      Roberto Mora
-- Description: N-dimentional array of numeric elements
-- =============================================
CREATE TYPE pgcv_core.ndarray_numeric AS (
  shape   int[],
  data    numeric[]
);

-- =============================================
-- Author:      Roberto Mora
-- Description: N-dimentional array of varchar elements
-- =============================================
CREATE TYPE pgcv_core.ndarray_varchar AS (
  shape   int[],
  data    varchar[]
);

-- =============================================
-- Author:      Roberto Mora
-- Description: Array used to describe the columns of a two dimentional array (matrix) or a set of one dimentional array (vector)
-- =============================================
CREATE TYPE pgcv_core.descriptor AS (
  elems   int,
  data    varchar[]
);
