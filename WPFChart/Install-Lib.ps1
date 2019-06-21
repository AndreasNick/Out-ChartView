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