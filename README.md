# MS Paint

A trimmed local copy of the MS Paint-style web drawing app from
<https://mspaint.humanhead.com>, based on JS Paint.

This repository keeps the drawing interface and the local assets needed to run
it, while removing the original page shell around it, including navigation,
ads, analytics, and article content.

## Live Demo

GitHub Pages:

```text
https://frankyang0610.github.io/mspaint/
```

## Run Locally

You can serve the web app with any static file server:

```sh
python3 -m http.server 8765
```

Then open:

```text
http://127.0.0.1:8765/
```

## Build the macOS App

The macOS app is a small native AppKit wrapper around a `WKWebView`. It loads
the local `index.html` from the app bundle, uses a frameless window with
Windows-style controls in the web UI, and does not require Electron.

Requirements:

- macOS
- Xcode Command Line Tools
- `swiftc`, `sips`, `iconutil`, and `codesign`

Build:

```sh
./scripts/build-macos-app.sh
```

The app will be created at:

```text
build/MS Paint.app
```

The build script also refreshes a convenience copy at:

```text
MS Paint.app
```

The generated `.app` bundle is intentionally ignored by Git. Commit the source
files and rebuild the bundle when needed.

## License

This project is distributed under the MIT License.

The original JS Paint copyright notice is retained, and this repository also
adds attribution for the local modifications. See [LICENSE](LICENSE).
