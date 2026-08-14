#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  // Set unique window property to identify this Vynody instance
  ::SetPropW(GetHandle(), L"VynodyInstanceProp", (HANDLE)1);

  // Initialize communication channel
  channel_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      flutter_controller_->engine()->messenger(), "vynody/single_instance",
      &flutter::StandardMethodCodec::GetInstance());

  channel_->SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue>& call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        if (call.method_name() == "registerShortcut") {
          extern void RegisterAppUserModelIDAndShortcut();
          RegisterAppUserModelIDAndShortcut();
          result->Success(flutter::EncodableValue(true));
        } else {
          result->NotImplemented();
        }
      });

  // Note: Window display is managed by Dart via window_manager (waitUntilReadyToShow)
  // to avoid premature display with native titlebar on Windows 10.
  // flutter_controller_->engine()->SetNextFrameCallback([&]() {
  //   this->Show();
  // });
  // flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  // Clean up the window property
  ::RemovePropW(GetHandle(), L"VynodyInstanceProp");

  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_COPYDATA: {
      COPYDATASTRUCT* cds = reinterpret_cast<COPYDATASTRUCT*>(lparam);
      if (cds && cds->dwData == 1) {
        std::string payload(reinterpret_cast<char*>(cds->lpData), cds->cbData);
        
        // Split newline-separated arguments
        std::vector<std::string> args;
        size_t start = 0;
        size_t end = payload.find('\n');
        while (end != std::string::npos) {
          args.push_back(payload.substr(start, end - start));
          start = end + 1;
          end = payload.find('\n', start);
        }
        if (start < payload.size()) {
          args.push_back(payload.substr(start));
        }

        // Pass arguments list to Flutter
        flutter::EncodableList encodable_args;
        for (const auto& arg : args) {
          encodable_args.push_back(flutter::EncodableValue(arg));
        }
        if (channel_) {
          channel_->InvokeMethod("onSecondInstance", std::make_unique<flutter::EncodableValue>(encodable_args));
        }

        // Focus and activate the main window
        HWND main_hwnd = GetHandle();
        if (!::IsWindowVisible(main_hwnd)) {
          ::ShowWindow(main_hwnd, SW_SHOW);
        }
        if (::IsIconic(main_hwnd)) {
          ::ShowWindow(main_hwnd, SW_RESTORE);
        }
        ::SetForegroundWindow(main_hwnd);
        ::SetFocus(main_hwnd);
        ::SetActiveWindow(main_hwnd);
      }
      return 0;
    }
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
