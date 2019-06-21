<#                       #>


Add-Type -assemblyName PresentationFramework
Add-Type -assemblyName PresentationCore
Add-Type -assemblyName WindowsBase
Add-Type -Assembly System.IO.Compression.Filesystem

<#
    .Synopsis
    extract dll from nuget archive
    .EXAMPLE
    Example of how to use this cmdlet
#>


function  Install-Lib
{
  [CmdletBinding()]
  Param
  (
    # Param1 help description
    [Parameter(Mandatory=$true,
        ValueFromPipelineByPropertyName=$true, Position=0)]
    $sourceFile,
    [Parameter(Mandatory=$true, Position=1)]
    [System.IO.DirectoryInfo] $destFolder
  )

  Process
  {
  
    $zip = [System.IO.Compression.ZipFile]::OpenRead($sourceFile)
    $Files = $zip.Entries | Where-Object {$_.Name -like '*.dll'} 
    
    Foreach($file in $files){ 
       $filename =  [string] $file.name
       Write-Host $("Extract " + $filename)  -ForegroundColor yellow
       $destfile = $destFolder.FullName + '\' + $filename
       write-host $destfile
       [IO.Compression.ZipFileExtensions]::ExtractToFile($file, $destfile, $true)
    }
    $zip.Dispose()
  }
}

#Download Nuget DLL Files
$dataVisualization = "$PSScriptRoot" +"\System.Windows.Controls.DataVisualization.Toolkit.dll"
$wpfToolkit = "$PSScriptRoot"  +"\WPFToolkit.dll"

if(! (Test-path $dataVisualization)){
  Write-Host "Missing: $dataVisualization try to download" -ForegroundColor Yellow
  Invoke-WebRequest -Uri "https://www.nuget.org/api/v2/package/WPFToolkit.DataVisualization/3.5.50211.1" -OutFile "$dataVisualization.zip"
  Install-Lib -sourceFile "$dataVisualization.zip" -destFolder (split-path $dataVisualization -Parent)
  Remove-Item -Path ('{0}.zip' -f $dataVisualization) -ErrorAction SilentlyContinue
  
}

if(! (Test-path $wpfToolkit)){

  Write-Host "Missing: $dataVisualization try to download" -ForegroundColor Yellow
  Invoke-WebRequest -Uri "https://www.nuget.org/api/v2/package/WPFToolkit/3.5.50211.1" -OutFile "$wpfToolkit.zip"
  Install-Lib -sourceFile "$wpfToolkit.zip" -destFolder (split-path $wpfToolkit -Parent)
  Remove-Item -Path ('{0}.zip' -f $wpfToolkit) -ErrorAction SilentlyContinue
}


Add-Type -Path $dataVisualization
Add-Type -Path $wpfToolkit
