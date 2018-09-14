<p align="center">
  <img src="https://raw.githubusercontent.com/romogo17/pgcv/master/pgcv_logo.png" width="350">
</p>

# pgcv
`pgcv` is a PostgreSQL extension for Computer Vision from the database server. It aims to be an extension that implements several image manipulation algorithms to store and manipulate images from the database server.

## Documentation
There will be two kinds of documentation available for `pgcv`. The first one is the documentation for the PostgreSQL functions. This documentation will be created once the extension has a stable API (version 1.0).

The other kind of documentation will be a blog-like explanation of how I created this extension, you can find it under the **notebooks** folder of this repository. The later information is presented in the form of Jupyter notebooks.

## How `pgcv` came to be?
This extension was born in the [National University Costa Rica](https://www.una.ac.cr/) as one of the main products of the project SIA0511-16 "Databases for the storage and analysis of digital mammograms" proposed by the professor MSc. Johnny Villalobos.

The extension was designed and developed by me, Roberto Mora. The first version has the purpose of creating a database for storing mammograms and information about patients using the `pgcv` data types. The project specifies the extension should be able to perform image segmentation on the images, to later extract objects from them that would be analyzed by geometric features.

However, I have tried to generalize the extension for other areas of Computer Vision (hence the name) hoping I can add new algorithms later on, not only those used for mammogram analysis.

Up until version 1.0 this extension represents my contribution to the project SIA0511-16. From there, I maintain this extension independently.

## Attribution

Logo altered from an image by Freepik
