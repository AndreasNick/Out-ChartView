# Out-ChartView

Out-ChartView should output graphs from the command line. Similar to the command Out GridView. The whole thing was created in 2017 for the former PowerShell Saturday in Germany Hannover.

## How does it work?

First the module must be imported. This can also be in the module memory, for example. I am also planning to store a version in the PowerShell gallery.

```powershell
#In the Script folder
Import-Module $($PSScriptRoot +'\WPFChart')
Import-Module 'YOURPATH\'+'\WPFChart') 

#In the module path (PowerShell Gallerie)
Import-Module 'WPFChart'
```

Now data can easily be output via the pipe. Here, for example, is a chart for the largest processes

```powershell
# find the 10 lagest files
# Top Files
Get-childItem C:\windows | Where-Object {$_.length -gt 1} | Sort-Object -Property length -Descending | Select-Object -first 10  | `
    Out-ChartView -xAxisPropertie "Name" -yAxisPropertie "Length"  -Background "Green" -ChartArt ColumnSeries

```

![Column_Graph](https://github.com/AndreasNick/Out-ChartView/blob/master/Chard_ColumnSeries.jpg?raw=true){: width=250px}


A list of PowerShell objects is always passed. The names of the elements are defined with the parameters -xAxisProperties and yAxisProperties. 
```powershell
Get-ChildItem C:\Windows\ -File | Select-Object -Property Name,Length  -First 5
```

| Name         | Length |
| ------------ | ------ |
| bfsvc.exe    | 78848  |
| bnetunin.exe | 86528  |
| bootstat.dat | 67584  |
| calc.exe     | 798720 |
| comsetup.log | 7630   |

returns a list of objects @{Name=, Length=} and exactly this data is output.
```powershell
 $data = @()
 for($i=0.0;$i -le (2*3.2) ;$i+=0.15){
   $data += (new-object 'System.Collections.Generic.KeyValuePair[String, Double]' -ArgumentList "$i", ([math]::sin([double]$i) ))
 }
```
Such a list can also be created via PowerShell. Here for example a Hatrh with the elements Key and Double. This will then return a nice Sinus.
```powershell
 $data | Out-ChartView -xAxisPropertie Key -yAxisPropertie Value -Background "red" -ChartArt LineSeries -Linecolor "white"
```
![Sinus_Graph](https://github.com/AndreasNick/Out-ChartView/blob/master/Chart_LineSeries.jpg?raw=true)
