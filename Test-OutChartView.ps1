# PSUGH 05-2017
# Andreas Nick PowerShell, WPF und Charts 

Import-Module $($PSScriptRoot +'\WPFChart') -Force

break

# Select 5 high cpu processes
get-process | Where-Object { $_.cpu -ne $null } | Sort-Object -Property cpu -Descending | Select-Object -first 10 | Out-ChartView -xAxisPropertie Name -yAxisPropertie cpu -Background "Green" -ChartArt ColumnSeries -Foreground "white" -Linecolor "white"

# find the 10 lagest files
#Top Files
Get-childItem C:\windows | Where-Object {$_.length -gt 1} | Sort-Object -Property length -Descending | Select-Object -first 10  | `
    Out-ChartView -xAxisPropertie "Name" -yAxisPropertie "Length"  -Background "Green" -ChartArt ColumnSeries


#Sinus
 $data = @()
 for($i=0.0;$i -le (2*3.2) ;$i+=0.15){
   $data += (new-object 'System.Collections.Generic.KeyValuePair[String, Double]' -ArgumentList "$i", ([math]::sin([double]$i) ))
 }
 
 $data | Out-ChartView -xAxisPropertie Key -yAxisPropertie Value -Background "red" -ChartArt LineSeries -Linecolor "white"


#Process - >CPU Total
get-process | Sort-Objectt CPU -Descending | Select-Object -first 10 |  Out-ChartView -xAxisPropertie Name -yAxisPropertie cpu  -Background "Green" -ChartArt AreaSeries -Foreground "white"


#CPU Usage
<#
get-WmiObject Win32_PerfFormattedData_PerfProc_Process `
    | Where-Object { $_.name -inotmatch '_total|idle' } `
    | ForEach-Object { 
        "Process={0,-25} CPU_Usage={1,-12} Memory_Usage_(MB)={2,-16}" -f `
            $_.Name,$_.PercentProcessorTime,([math]::Round($_.WorkingSetPrivate/1Mb,2))
    }


get-WmiObject Win32_PerfFormattedData_PerfProc_Process | Sort-Object -Property PercentProcessorTime -Descending | select -first 10 |  Select-Object -Property Name, PercentProcessorTime

#>