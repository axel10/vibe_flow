# Clean up debug JIT cache (kernel_blob.bin ~105MB) from previous flutter run
Remove-Item -Force -ErrorAction SilentlyContinue "build/flutter_assets/kernel_blob.bin", "build/windows/x64/runner/Release/data/flutter_assets/kernel_blob.bin"

flutter build windows --release --no-tree-shake-icons --dart-define=CHANNEL=store

# Ensure no leftover kernel_blob.bin in Release before packaging
Remove-Item -Force -ErrorAction SilentlyContinue "build/windows/x64/runner/Release/data/flutter_assets/kernel_blob.bin"

# Bundle VC Runtime DLLs into Release directory before packaging MSIX
$dlls = @("msvcp140.dll", "msvcp140_1.dll", "msvcp140_2.dll", "msvcp140_codecvt_ids.dll", "vcruntime140.dll", "vcruntime140_1.dll", "vcruntime140_threads.dll")
$destDir = "build/windows/x64/runner/Release"
foreach ($dll in $dlls) {
    $sysPath = Join-Path $env:SystemRoot "System32\$dll"
    if (Test-Path $sysPath) {
        Copy-Item $sysPath -Destination $destDir -Force
        Write-Host "Bundled $dll into Release directory."
    }
}

dart run msix:create --build-windows false