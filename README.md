<p align="center">
  <img src="https://raw.githubusercontent.com/romogo17/pgcv/master/pgcv_logo.png" width="350">
</p>

# pgcv

`pgcv` is a PostgreSQL extension for Computer Vision from the database server. The extension implements algorithms for image segmentation, in particular: digital mammogram segmentation.

The extension implements both data types and functions. The data types are PostgreSQL composite types and the functions were created using PL/Python, meaning the function's body is written in Python.

## Documentation

You can find the documentation under the docs directory [here](./docs/documentation.md)

## How `pgcv` came to be?

This extension was born in the [National University Costa Rica](https://www.una.ac.cr/) as one of the main products of the project SIA0511-16 "Databases for the storage and analysis of digital mammograms".

The extension was designed and developed by me, Roberto Mora. The first version has the purpose of creating a database for storing mammograms and information about patients using the `pgcv` data types.

However, I have tried to generalize the extension for other areas of Computer Vision (hence the name) hoping I can add new functions later on, not only those used for mammogram analysis.

## Requirements

- PostgreSQL 10 with support for PL/Python
- Python3

## Installation

The extension can be installed with the `install.py` script located in the root directory.

Execute this script with Python3 and it will copy the required files to PostgreSQL shared extension directory.

After that, connect to your PostgreSQL database and execute the following commands:

```bash
CREATE EXTENSION PLPYTHON3U;
CREATE EXTENSION PGCV;
```

## Attribution

Logo altered from an image by Freepik
