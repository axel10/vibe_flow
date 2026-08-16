#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>
#include <vector>
#include <string>
#include <shlobj.h>
#include <propkey.h>
#include <propvarutil.h>
#include <appmodel.h>

#include "flutter_window.h"
#include "utils.h"

bool IsPackaged() {
  UINT32 length = 0;
  LONG rc = GetCurrentPackageFullName(&length, NULL);
  return rc != APPMODEL_ERROR_NO_PACKAGE;
}

void RegisterAppUserModelIDAndShortcut() {
  if (IsPackaged()) {
    return;
  }

  // Set explicit AppUserModelID for the current process
  const wchar_t* appId = L"axel10.vynody.player";
  SetCurrentProcessExplicitAppUserModelID(appId);

  // Dynamically create a Start Menu shortcut if it does not exist
  wchar_t startMenuPath[MAX_PATH];
  if (SUCCEEDED(SHGetFolderPathW(NULL, CSIDL_PROGRAMS, NULL, 0, startMenuPath))) {
    std::wstring shortcutPath = std::wstring(startMenuPath) + L"\\Vynody.lnk";
    
    // Get current executable path
    wchar_t exePath[MAX_PATH];
    GetModuleFileNameW(NULL, exePath, MAX_PATH);

    // Create or update the shortcut
    IShellLinkW* psl;
    HRESULT hr = CoCreateInstance(CLSID_ShellLink, NULL, CLSCTX_INPROC_SERVER, IID_IShellLinkW, (LPVOID*)&psl);
    if (SUCCEEDED(hr)) {
      psl->SetPath(exePath);
      psl->SetIconLocation(exePath, 0);
      
      // Get directory of the executable for working directory
      std::wstring exeDir = exePath;
      size_t lastSlash = exeDir.find_last_of(L"\\/");
      if (lastSlash != std::wstring::npos) {
        exeDir = exeDir.substr(0, lastSlash);
      }
      psl->SetWorkingDirectory(exeDir.c_str());

      // Set AppUserModelID on the shortcut's property store
      IPropertyStore* pps;
      hr = psl->QueryInterface(IID_IPropertyStore, (LPVOID*)&pps);
      if (SUCCEEDED(hr)) {
        PROPVARIANT pv;
        InitPropVariantFromString(appId, &pv);
        hr = pps->SetValue(PKEY_AppUserModel_ID, pv);
        if (SUCCEEDED(hr)) {
          hr = pps->Commit();
        }
        PropVariantClear(&pv);
        pps->Release();
      }

      if (SUCCEEDED(hr)) {
        IPersistFile* ppf;
        hr = psl->QueryInterface(IID_IPersistFile, (LPVOID*)&ppf);
        if (SUCCEEDED(hr)) {
          hr = ppf->Save(shortcutPath.c_str(), TRUE);
          ppf->Release();
        }
      }
      psl->Release();
    }
  }
}

// Struct to store hwnd during EnumWindows search
struct FindWindowData {
  HWND hwnd = nullptr;
};

// Callback to find the existing window by checking for VynodyInstanceProp property
BOOL CALLBACK FindVynodyWindowProc(HWND hwnd, LPARAM lParam) {
  wchar_t class_name[256];
  if (::GetClassNameW(hwnd, class_name, 256) && wcscmp(class_name, L"FLUTTER_RUNNER_WIN32_WINDOW") == 0) {
    if (::GetPropW(hwnd, L"VynodyInstanceProp") == (HANDLE)1) {
      auto data = reinterpret_cast<FindWindowData*>(lParam);
      data->hwnd = hwnd;
      return FALSE; // Stop enumerating
    }
  }
  return TRUE;
}

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  
  // Single Instance Mutex Check (Local namespace prevents session collision)
  HANDLE mutex = ::CreateMutexW(nullptr, TRUE, L"Local\\Vynody_SingleInstance_Mutex");
  if (mutex == nullptr || ::GetLastError() == ERROR_ALREADY_EXISTS) {
    // Another instance is already running
    FindWindowData data;
    ::EnumWindows(FindVynodyWindowProc, reinterpret_cast<LPARAM>(&data));

    if (data.hwnd != nullptr) {
      std::vector<std::string> args = GetCommandLineArguments();
      std::string payload;
      for (size_t i = 0; i < args.size(); ++i) {
        payload += args[i];
        if (i < args.size() - 1) payload += "\n";
      }

      COPYDATASTRUCT cds;
      cds.dwData = 1;
      cds.cbData = static_cast<DWORD>(payload.size());
      cds.lpData = const_cast<char*>(payload.c_str());

      ::SendMessageW(data.hwnd, WM_COPYDATA, reinterpret_cast<WPARAM>(data.hwnd), reinterpret_cast<LPARAM>(&cds));
    }

    if (mutex != nullptr) {
      ::CloseHandle(mutex);
    }
    return EXIT_SUCCESS; // Quit the second instance
  }

  AppendRunnerLog("=== wWinMain start ===");
  AppendRunnerLog(std::string("raw command line: ") + Utf8FromUtf16(command_line));

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  const bool attached_console = ::AttachConsole(ATTACH_PARENT_PROCESS);
  if (!attached_console && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
    AppendRunnerLog("console attached via debugger");
  } else if (attached_console) {
    AppendRunnerLog("console attached to parent process");
  } else {
    AppendRunnerLog("no console attached");
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();
  AppendRunnerLog(
      std::string("parsed args count=") + std::to_string(command_line_arguments.size()) +
      " args=" + [&]() {
        std::string joined;
        for (size_t i = 0; i < command_line_arguments.size(); ++i) {
          if (i > 0) joined += " | ";
          joined += command_line_arguments[i];
        }
        return joined;
      }());

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"Vynody", origin, size)) {
    AppendRunnerLog("window.Create failed");
    if (mutex != nullptr) {
      ::ReleaseMutex(mutex);
      ::CloseHandle(mutex);
    }
    return EXIT_FAILURE;
  }
  AppendRunnerLog("window.Create succeeded");
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  // Release mutex before exit
  if (mutex != nullptr) {
    ::ReleaseMutex(mutex);
    ::CloseHandle(mutex);
  }

  AppendRunnerLog("message loop exited");
  ::CoUninitialize();
  AppendRunnerLog("=== wWinMain end ===");
  return EXIT_SUCCESS;
}
