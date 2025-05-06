# SwiftIGRF

SwiftIGRF is a Swift package for evaluating any generation of the International Geomagnetic Reference Field (IGRF) geomagnetic field model. This project was inspired by the [NCEI IGRF](https://www.ncei.noaa.gov/products/international-geomagnetic-reference-field) Python package.

## Features

SwiftIGRF provides a command-line interface (CLI) tool that allows calculation of the seven main geomagnetic field components (Declination, Inclination, Total Field, Horizontal, North, East and Vertical strength, or D, I, F, H, X, Y, Z) and their respective secular variation for a given latitude, longitude, altitude, and time.

You can specify any IGRF generation from 1 to 14 (as of November 2024).

## Architecture

The project is structured with a clear separation between:
- Core calculation code (independent library)
- CLI application
- iOS sample application demonstrating how to use the core library

## Model Information

The code accepts geodetic coordinates (WGS-84) with altitude in km above the WGS-84 ellipsoid or geocentric coordinates with radius in km from Earth's center (6371.2 km is the nominal geophysical surface radius).

Location values can be entered in decimal degrees or degrees and minutes.

There are no validity checks on the models, so be aware of errors caused by extrapolation outside the valid range.

Check [NCEI IGRF](https://www.ncei.noaa.gov/products/international-geomagnetic-reference-field) for validity ranges on each generation as these vary widely. For example:
- IGRF-1 is valid from January 1, 1965 to December 31, 1979
- IGRF-13 is valid from January 1, 1900 to December 31, 2024
- IGRF-14 is valid from January 1, 1900 to December 31, 2029

## Important Notes

Currently, the `MagneticFieldSynthesizer` is available for use, but the following features are not yet implemented:
- `HistoricalMagneticFieldSynthesizer` (option 2) for calculating values at a single location over multiple years
- `SpatialMagneticFieldSynthesizer` (option 3) for calculating values on a latitude/longitude grid at a single point in time

## iOS Integration

The package includes a sample iOS application that demonstrates how to integrate and use the SwiftIGRF core library in iOS applications.

## License

This project is released under the MIT License. See the LICENSE file for details.

## Todo
- Implement `HistoricalMagneticFieldSynthesizer`
- Implement `SpatialMagneticFieldSynthesizer`
- Enhance documentation
- Add more tests
- Expand iOS sample application

