param(
    [ValidateSet('build', 'flash', 'monitor')][string]$Action = 'build',
    [string]$Port
)
$ErrorActionPreference = 'Stop'
$env:PYTHONUTF8 = '1'
if ($Action -ne 'build' -and -not $Port) { throw 'Specify the verified device port with -Port.' }
if (-not (Get-Command idf.py -ErrorAction SilentlyContinue)) {
    if (-not $env:IDF_PATH -or -not (Test-Path (Join-Path $env:IDF_PATH 'export.ps1'))) {
        throw 'Activate ESP-IDF v6.0.1, or set IDF_PATH to its installation directory.'
    }
    . (Join-Path $env:IDF_PATH 'export.ps1')
}
$projectPath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
Push-Location $projectPath
try {
    if ($Action -eq 'monitor') {
        python tools/muse/monitor.py $Port 30
    } else {
        $idfArgs = @('-B', 'build-muse-dfrobot-unihiker-k10', '-DIDF_TARGET=esp32s3',
            '-DSDKCONFIG=build-muse-dfrobot-unihiker-k10/sdkconfig',
            '-DSDKCONFIG_DEFAULTS=sdkconfig.defaults;devices/sdkconfig.muse;devices/sdkconfig.muse-dfrobot-unihiker-k10')
        if ($Action -eq 'flash') { $idfArgs += @('-p', $Port) }
        idf.py @idfArgs $Action
    }
    if ($LASTEXITCODE -ne 0) { throw "ESP-IDF $Action failed ($LASTEXITCODE)" }
} finally { Pop-Location }
