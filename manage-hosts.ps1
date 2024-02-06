param (
  [Parameter (Mandatory, ParameterSetName = 'Add', position = 2)]
  [Parameter (Mandatory, ParameterSetName = 'Remove', position = 2)]
  [string[]]$hostName,
  [Parameter (Mandatory, ParameterSetName = 'Add', position = 1)]
  [string[]]$ip,
  [Parameter (Mandatory, ParameterSetName = 'Add')]
  [switch]$add,
  [Parameter (Mandatory, ParameterSetName = 'Remove')]
  [switch]$remove,
  [Parameter (Mandatory, ParameterSetName = 'List')]
  [switch]$list
)
begin {
  $hostFilePath = "$($Env:WinDir)\system32\Drivers\etc\hosts"
  $currentList = get-content $hostFilePath
  $escapedHostname = [Regex]::Escape($hostName)
  $patternToMatch = If ($CheckHostnameOnly) { ".*\s+$escapedHostname.*" } Else { ".*$DesiredIP\s+$escapedHostname.*" }
}
process {
  if ($add) {
    write-host "adding $($ip.PadRight(20, ' ')) $Hostname"
    if ($currentList -match "^\d.*\s+$patternToMatch.*") {
      write-host "$hostName is already added in the current list - no action taken"
    } else {
      add-content -encoding UTF8 $hostFilePath ($ip.PadRight(20, " ") + "$hostName")
      write-host "added $ip - $hostName to hosts"
    }
  }
  if ($remove) {
    write-host "removing $($Hostname)"
    if ($currentList -match "^\d.*\s+$escapedHostname.*") {
      $currentList -notmatch "^\d.*\s+$escapedHostname.*" | out-file $hostFilePath
      write-host "removed $hostName out of hosts"
    } else {
      write-host "$hostName is not in the current list - no action taken"
    }
  }
  if ($list) {
    foreach ($line in $currentList) {
      write-host $line
    }
  }
}