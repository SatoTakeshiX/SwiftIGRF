<h1 align="center">SwiftIGRF</h1>
<p align="center">
    <img width="200" alt="IGRF icon" src="https://raw.githubusercontent.com/SatoTakeshiX/SwiftIGRF/main/Icon/IGRF_icon.png">
</p>

SwiftIGRF is a Swift package for evaluating any generation of the International Geomagnetic Reference Field (IGRF) geomagnetic field model. This project was inspired by the [NCEI IGRF Python package](https://www.ncei.noaa.gov/products/international-geomagnetic-reference-field).

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

## How to use

### CLI Usage

To use SwiftIGRF as a command-line tool:

1. Clone the repository
2. Build the project:
   ```bash
   swift build
   ```
3. Run the IGRF command:
   ```bash
   .build/debug/igrf
   ```
4. Follow the prompts to input your data

#### Example

Here's an example of checking geomagnetic data for Shibuya Station in Tokyo, Japan (latitude 35° 39.48', longitude 139° 42.096') for the year 2025, with output to a file:


<details>
<summary>Input example</summary>

```bash
******************************************************
*              IGRF SYNTHESIS PROGRAM                *
*                                                    *
* A program for the computation of geomagnetic       *
* field elements from the International Geomagnetic  *
* Reference Field (14th generation) as revised in    *
* December 2024 by the IAGA Working Group V-MOD.     *
*                                                    *
* It is valid for dates from 1900.0 to 2030.0;       *
* values up to 2035.0 will be computed with          *
* reduced accuracy. Values for dates before 1945.0   *
* and after 2020.0 are non-definitive, otherwise     *
* the values are definitive.                         *
*                                                    *
*                                                    *
*            (on behalf of) IAGA Working Group V-MOD *
******************************************************
 
Enter number of require IGRF generation (1 to 14)
or press "Return" for IGRF-14
Enter generation number: 
14
Loading IGRF coefficient file: /Users/satoutakeshi/local_product/Personal-Factory/flying-star-fengshui/SwiftIGRF/SHC_files/IGRF14.SHC
Successfully loaded IGRF-14 coefficients
Enter name of output file
or press 'Return' for output to screen
Enter filename: output.txt
output.txt
Choose an option:
1 - values at one location and date
2 - values at yearly intervals at one location
3 - values on a latitude/longitude grid at one date
->1
Enter format of latitudes and longitudes:
1 - in degrees & minutes
2 - in decimal degrees
->1
Enter value for coordinate system:
1 - geodetic (shape of Earth using the WGS-84 ellipsoid)
2 - geocentric (shape of Earth is approximated by a sphere)
->1
Enter latitude & longitude in degrees & minutes
(if either latitude or longitude is between -1
and 0 degrees, enter the minutes as negative).
Enter integers for degrees, floats for the minutes if needed
->35 39.48 139 42.096
Enter altitude in km:
->0
Enter decimal date in years 1900-2030:
->2025

Written to file: output.txt
```
</details>




When you run the command with the options shown above, it will generate output similar to the following:

<details>
<summary>Sample for output file</summary>

```txt
Geomagnetic field values at: 35.6580° / 139.7016°, at altitude 0.0 for 2025.0 using IGRF-14
Declination (D):  -7.855°
Inclination (I):  49.485°
Horizontal intensity (H):  30411.0 nT
Total intensity (F)     :  46811.4 nT
North component (X)     :  30125.7 nT
East component (Y)      :  -4156.1 nT
Vertical component (Z)  :  35587.6 nT
Declination SV (D):  -2.40 arcmin/yr
Inclination SV (I):  1.26 arcmin/yr
Horizontal SV (H):  6.4 nT/yr
Total SV (F)     :  29.9 nT/yr
North SV (X)     :  3.4 nT/yr
East SV (Y)      :  -21.9 nT/yr
Vertical SV (Z)  :  33.9 nT/yr
```
</details>




### Application usage 

To use this package in your Swift project, add it as a dependency in your `Package.swift` file:

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/yourusername/SwiftIGRF.git", from: "0.0.2")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: ["IGRFCore"]
    )
]
```



## Important Notes

Currently, the `MagneticFieldSynthesizer` is available for use, but the following features are not yet implemented:
- `HistoricalMagneticFieldSynthesizer` (option 2) for calculating values at a single location over multiple years
- `SpatialMagneticFieldSynthesizer` (option 3) for calculating values on a latitude/longitude grid at a single point in time

## Todo
- Implement `HistoricalMagneticFieldSynthesizer`
- Implement `SpatialMagneticFieldSynthesizer`
- Enhance documentation
- Add more tests
- Expand iOS sample application


## License

This project is released under the MIT License. See the LICENSE file for details.



