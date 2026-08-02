import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private static var pendingFiles: [String] = []
  private static var methodChannel: FlutterMethodChannel?

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    if !flag {
      for window in sender.windows {
        if window.isMiniaturized {
          window.deminiaturize(self)
        }
        window.setIsVisible(true)
        window.makeKeyAndOrderFront(self)
      }
      NSApp.activate(ignoringOtherApps: true)
    }
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  override func application(_ sender: NSApplication, openFiles filenames: [String]) {
    NSLog("[macOS-Native] openFiles called with: \(filenames)")
    AppDelegate.handleFiles(filenames)
    sender.reply(toOpenOrPrint: .success)
  }

  override func application(_ sender: NSApplication, openFile filename: String) -> Bool {
    NSLog("[macOS-Native] openFile called with: \(filename)")
    AppDelegate.handleFiles([filename])
    return true
  }

  override func application(_ application: NSApplication, open urls: [URL]) {
    let filenames = urls.map { $0.path }
    NSLog("[macOS-Native] open urls called with: \(filenames)")
    AppDelegate.handleFiles(filenames)
  }

  private static func handleFiles(_ filenames: [String]) {
    if let channel = AppDelegate.methodChannel {
      NSLog("[macOS-Native] methodChannel is active. Invoking onOpenFiles with: \(filenames)")
      channel.invokeMethod("onOpenFiles", arguments: filenames)
    } else {
      NSLog("[macOS-Native] methodChannel is nil. Storing in pendingFiles: \(filenames)")
      AppDelegate.pendingFiles.append(contentsOf: filenames)
    }
  }

  func setupMethodChannel(_ channel: FlutterMethodChannel) {
    NSLog("[macOS-Native] setupMethodChannel called")
    AppDelegate.methodChannel = channel
    channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      NSLog("[macOS-Native] received method call: \(call.method)")
      if call.method == "getPendingFiles" {
        NSLog("[macOS-Native] returning pendingFiles: \(AppDelegate.pendingFiles)")
        result(AppDelegate.pendingFiles)
        AppDelegate.pendingFiles.removeAll()
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
