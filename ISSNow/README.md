# ISSNow

SwiftUI screens and logic for a live ISS tracker. This folder does not include an Xcode project.

How to run:
1. Create a new iOS App project in Xcode (SwiftUI, iOS 16+).
2. Replace the generated Swift files with the contents of this folder.
3. Add the Swift Package dependency:
   - https://github.com/gavineadie/SatelliteKit.git (from 2.1.0).
4. Build and run on a device or simulator.

Propagation: on-device SGP4 via SatelliteKit.
Data source: https://celestrak.org/NORAD/elements/gp.php?CATNR=25544&FORMAT=TLE
