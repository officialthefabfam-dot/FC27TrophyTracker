# FC 27 Trophy Tracker

A personal iPhone trophy cabinet for **FC 27 Manager Career Mode**. Add your wins manually and keep a record of your club's achievements.

## Features
- Dark football-inspired cabinet with gold trophy styling
- Manually add trophies, competitions, seasons, clubs, categories and dates
- Trophy, season and cup statistics
- Search and category filtering
- Local persistence on the device

## Build
The GitHub Actions workflow in `.github/workflows/build-ios.yml` builds an unsigned iOS app and uploads it as a workflow artifact. Open the **Actions** tab and run **Build iOS app**.

**Note:** The generated IPA is unsigned. Installing it requires a compatible sideloading workflow and signing/setup appropriate to your device. This is not an App Store release.

## Local build
Install XcodeGen, run `xcodegen generate`, then build the `FC27TrophyTracker` scheme in Xcode.
