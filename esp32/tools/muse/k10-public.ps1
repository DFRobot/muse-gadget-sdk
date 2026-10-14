param(
    [ValidateSet('build', 'flash', 'package')][string]$Action = 'build',
    [string]$Port
)
$ErrorActionPreference = 'Stop'
$env:PYTHONUTF8 = '1'
if ($Action -eq 'flash' -and -not $Port) { throw 'Specify the verified device port with -Port.' }
if (-not (Get-Command idf.py -ErrorAction SilentlyContinue)) {
    if (-not $env:IDF_PATH -or -not (Test-Path (Join-Path $env:IDF_PATH 'export.ps1'))) {
        throw 'Activate ESP-IDF v6.0.1, or set IDF_PATH to its installation directory.'
    }
    . (Join-Path $env:IDF_PATH 'export.ps1')
}
$projectPath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
Push-Location $projectPath
try {
    $publicBuild = 'build-muse-k10-public'
    $idfArgs = @('-B', $publicBuild, '-DIDF_TARGET=esp32s3',
        "-DSDKCONFIG=$publicBuild/sdkconfig",
        '-DSDKCONFIG_DEFAULTS=sdkconfig.defaults;devices/sdkconfig.muse;devices/sdkconfig.muse-dfrobot-unihiker-k10;devices/sdkconfig.muse-k10-public')
    # Never silently reuse a private configuration in the public directory.
    if (Test-Path "$publicBuild/sdkconfig") {
        $configText = Get-Content "$publicBuild/sdkconfig" -Raw
        if ($configText -notmatch '(?m)^CONFIG_GADGET_SDK_RUNTIME_ONLY=y\r?$') {
            throw 'Public build directory has an incompatible config. Use a new public build directory.'
        }
    }
    idf.py @idfArgs build
    if ($LASTEXITCODE -ne 0) { throw "Public build failed ($LASTEXITCODE)" }
    python tools/muse/package_k10_public.py $publicBuild
    if ($LASTEXITCODE -ne 0) { throw 'Public firmware credential audit/package failed' }
    if ($Action -eq 'flash') {
        idf.py @idfArgs -p $Port flash
        if ($LASTEXITCODE -ne 0) { throw "Flash failed ($LASTEXITCODE)" }
    }
} finally { Pop-Location }
