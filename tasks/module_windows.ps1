[CmdletBinding()]
Param(
  [Parameter(Mandatory = $false)]
  [String]$status = "list",

  [Parameter(Mandatory = $false)]
  [String]$module,

  [Parameter(Mandatory = $false)]
  [String]$config_file = "$env:PROGRAMFILES\Metricbeat\metricbeat.yml",
)
# If an error is encountered, the script will stop instead of the default of "Continue"
$ErrorActionPreference = "Stop"
# Force a minimum timeout of 3 second to allow the response to be returned.
  $timeout = 3

If (Test-Path -Path $env:PROGRAMFILES\Metricbeat\metricbeat.exe) {
  $executable = "$env:PROGRAMFILES\Metricbeat\metricbeat.exe"
}
  & $executable -c $config_file modules $status $module

Write-Output "{""status"":""queued"",""timeout"":${timeout}}"