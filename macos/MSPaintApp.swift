import Cocoa
import WebKit

private let titleBarHeight: CGFloat = 31
private let windowControlsWidth: CGFloat = 132

final class FramelessWebView: WKWebView {
	override func mouseDown(with event: NSEvent) {
		let point = convert(event.locationInWindow, from: nil)
		let isInTitleBar = bounds.height - point.y <= titleBarHeight
		let isInWindowControls = point.x >= bounds.width - windowControlsWidth

		if isInTitleBar && !isInWindowControls {
			if event.clickCount == 2 {
				window?.zoom(nil)
			} else {
				window?.performDrag(with: event)
			}
			return
		}

		super.mouseDown(with: event)
	}
}

final class AppDelegate: NSObject, NSApplicationDelegate, WKNavigationDelegate, WKScriptMessageHandler {
	private var window: NSWindow!
	private var webView: WKWebView!

	func applicationDidFinishLaunching(_ notification: Notification) {
		let configuration = WKWebViewConfiguration()
		configuration.preferences.javaScriptCanOpenWindowsAutomatically = true

		let userContentController = WKUserContentController()
		userContentController.addUserScript(WKUserScript(
			source: """
			window.MSPAINT_MACOS_APP = true;
			document.documentElement.classList.add("native-window-shell");
			""",
			injectionTime: .atDocumentStart,
			forMainFrameOnly: true
		))
		userContentController.add(self, name: "windowControl")
		configuration.userContentController = userContentController

		webView = FramelessWebView(frame: .zero, configuration: configuration)
		webView.navigationDelegate = self
		webView.setValue(false, forKey: "drawsBackground")

		window = NSWindow(
			contentRect: NSRect(x: 0, y: 0, width: 1100, height: 720),
			styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
			backing: .buffered,
			defer: false
		)
		window.title = "MS Paint"
		window.titleVisibility = .hidden
		window.titlebarAppearsTransparent = true
		window.isMovableByWindowBackground = false
		window.minSize = NSSize(width: 760, height: 520)
		window.contentView = webView
		hideNativeWindowControls()
		window.center()
		window.makeKeyAndOrderFront(nil)

		loadPaint()
	}

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		true
	}

	func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
		guard message.name == "windowControl", let action = message.body as? String else {
			return
		}

		switch action {
		case "minimize":
			window.miniaturize(nil)
		case "maximize":
			window.zoom(nil)
		case "close":
			window.performClose(nil)
		default:
			break
		}
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

	private func hideNativeWindowControls() {
		[
			NSWindow.ButtonType.closeButton,
			NSWindow.ButtonType.miniaturizeButton,
			NSWindow.ButtonType.zoomButton,
		].forEach { buttonType in
			window.standardWindowButton(buttonType)?.isHidden = true
		}
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
