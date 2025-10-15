fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios fetch_certificates

```sh
[bundle exec] fastlane ios fetch_certificates
```

Fetch certificates and provisioning profiles via Match

### ios build

```sh
[bundle exec] fastlane ios build
```

Build the iOS app for a specific flavor (with signing)

### ios upload

```sh
[bundle exec] fastlane ios upload
```

Upload iOS app to TestFlight or App Store

### ios build_and_upload

```sh
[bundle exec] fastlane ios build_and_upload
```

Build and upload iOS app

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
