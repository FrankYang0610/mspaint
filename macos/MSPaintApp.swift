import Cocoa
import WebKit

final class AppDelegate: NSObject, NSApplicationDelegate, WKNavigationDelegate {
	private var window: NSWindow!
	private var webView: WKWebView!

	func applicationDidFinishLaunching(_ notification: Notification) {
		let configuration = WKWebViewConfiguration()
		configuration.preferences.javaScriptCanOpenWindowsAutomatically = true

		webView = WKWebView(frame: .zero, configuration: configuration)
		webView.navigationDelegate = self
		webView.setValue(false, forKey: "drawsBackground")

		window = NSWindow(
			contentRect: NSRect(x: 0, y: 0, width: 1100, height: 720),
			styleMask: [.titled, .closable, .miniaturizable, .resizable],
			backing: .buffered,
			defer: false
		)
		window.title = "MS Paint"
		window.minSize = NSSize(width: 760, height: 520)
		window.contentView = webView
		window.center()
		window.makeKeyAndOrderFront(nil)

		loadPaint()
	}

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		true
	}

	private func loadPaint() {
		guard let resourcesURL = Bundle.main.resourceURL else {
			showFatalError("Could not locate app resources.")
			return
		}

		let webRoot = resourcesURL.appendingPathComponent("web", isDirectory: true)
		let indexURL = webRoot.appendingPathComponent("index.html")
		webView.loadFileURL(indexURL, allowingReadAccessTo: webRoot)
	}

	private func showFatalError(_ message: String) {
		let alert = NSAlert()
		alert.messageText = "MS Paint could not start"
		alert.informativeText = message
		alert.alertStyle = .critical
		alert.runModal()
		NSApp.terminate(nil)
	}
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.activate(ignoringOtherApps: true)
app.run()
