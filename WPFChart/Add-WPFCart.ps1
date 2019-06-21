<#	
    .NOTES
    ===========================================================================
    Created on:   	August 2017 
    Created by:   	Andreas Nick, www.software-virtualisierung.de, www.nick-it.de
    Organization: 	Nick Informationstechnik GmbH
    .Synopsis
    A PowerShell Module component to manage WPF Charts 	
    .NOTES
    ===========================================================================
    .DESCRIPTION
    A description of the file.
#>

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

#Download Nuget DLL Files
$dataVisualization = "$PSScriptRoot" + "\lib\System.Windows.Controls.DataVisualization.Toolkit.dll"
$wpfToolkit = "$PSScriptRoot" + "\lib\WPFToolkit.dll"

if (! (Test-path $dataVisualization))
{
  Write-Error "Missing Lib $dataVisualization please reinstall the Module"
  throw "Missing Lib $dataVisualization please reinstall the Module"
}

if (! (Test-path $wpfToolkit))
{
  Write-Error "Missing Lib $wpfToolkit please reinstall the Module"
  throw "Missing Lib $wpfToolkit please reinstall the Module"
}

Add-Type -Path $dataVisualization
Add-Type -Path $wpfToolkit

<#
    .Synopsis
    Set the background color of a chart
    .DESCRIPTION
    Set the background color, use DynamicParameter to enumerate all available colors
    .EXAMPLE
    Set-ChartBackgroundColor -Chart $Chart -Foreground 'Green'
#>
function Set-ChartBackgroundColor
{
	
  [CmdletBinding()]
  param
  (
    [Parameter(Position = 0, Mandatory = $true)]
    [psobject]$Chart
  )
	
  DynamicParam
  {
		
    $ParameterName = 'Background'
    $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
    $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
    $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
    $ParameterAttribute.Mandatory = $false
    $ParameterAttribute.Position = 2
    $AttributeCollection.Add($ParameterAttribute)
		
    [String[]]$alist = ([System.Windows.Media.Brushes].DeclaredProperties).Name
    $arrSet = $alist
    $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
    $AttributeCollection.Add($ValidateSetAttribute)
    $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
    $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
    return $RuntimeParameterDictionary
  }
	
  begin
  {
    $PsBoundParameters[$ParameterName]
    $Background = $PsBoundParameters[$ParameterName]
		
  }
	
  process
  {
    $Chart.background = $Background
  }
}

<#
    .Synopsis
    Set the foreground color of a chart
    .DESCRIPTION
    Set the foreground color, use DynamicParameter to enumerate all available colors
    .EXAMPLE
    Set-ChartForegroundColor -Chart $Chart -Foreground 'Green'
#>

function Set-ChartForegroundColor
{
	
  [CmdletBinding()]
  param
  (
    [Parameter(Position = 0, Mandatory = $true)]
    [psobject]$Chart
  )
	
  DynamicParam
  {
		
    $ParameterName = 'Foreground'
    $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
    $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
    $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
    $ParameterAttribute.Mandatory = $false
    $ParameterAttribute.Position = 2
    $AttributeCollection.Add($ParameterAttribute)
		
    [String[]]$alist = ([System.Windows.Media.Brushes].DeclaredProperties).Name
    $arrSet = $alist
    $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
    $AttributeCollection.Add($ValidateSetAttribute)
    $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
    $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
    return $RuntimeParameterDictionary
  }
	
  begin
  {
    $PsBoundParameters[$ParameterName]
    $Background = $PsBoundParameters[$ParameterName]
		
  }
	
  process
  {
    $Chart.Foreground = $Foreground
  }
}


<#
    .Synopsis
    Diskpatcher function to create the wpf window, "Quota" error when not used.
    .DESCRIPTION
    
    .EXAMPLE
    
#>
function Show-WPFWindow
{
  param
  (
    [Parameter(Mandatory=$true)]
    [Windows.Window]
    $Window
  )
  
  $result = $null
  $null = $window.Dispatcher.InvokeAsync{
    $result = $window.ShowDialog()
    Set-Variable -Name result -Value $result -Scope 1
  }.Wait()
  $result
}

<#
    .Synopsis
    Remove everythink Legend, Titel and Spaces between the CHart and the parent object
    .DESCRIPTION
    Lange Beschreibung
    .EXAMPLE
    Beispiel für die Verwendung dieses Cmdlets
    .EXAMPLE
    Ein weiteres Beispiel für die Verwendung dieses Cmdlets
#>
function Remove-WpfChartBorders
{
  [CmdletBinding()]
  Param
  (
    [Parameter(Mandatory = $true,
           ValueFromPipeline = $true,
           Position = 0)]
    [psobject]$Chart
  )
	
  begin
  {
    $xamlChartTemplate = @'
      <ControlTemplate TargetType="chartingToolkit:Chart">
        <Border Background="{TemplateBinding Background}"
                BorderBrush="{TemplateBinding BorderBrush}"
                BorderThickness="{TemplateBinding BorderThickness}"
                Padding="{TemplateBinding Padding}">
          <Grid>
            <chartingprimitives:EdgePanel x:Name="ChartArea" Style="{TemplateBinding ChartAreaStyle}">
              <Grid Canvas.ZIndex="-1" Style="{TemplateBinding PlotAreaStyle}" />
              <Border Canvas.ZIndex="10" BorderBrush="#FF919191" BorderThickness="1" />
            </chartingprimitives:EdgePanel>
          </Grid>
        </Border>
      </ControlTemplate>
'@
  }
	
  process
  {
    #Eleminate Border
		
		
    [byte[]]$x1 = [system.text.encoding]::ASCII.GetBytes($xamlChartTemplate)
		
    $sr = new-object System.IO.MemoryStream -ArgumentList ($x1, 0, $x1.Length)
    $pc = new-object System.Windows.Markup.ParserContext
		
    $pc.XmlnsDictionary.Add("", "http://schemas.microsoft.com/winfx/2006/xaml/presentation")
    $pc.XmlnsDictionary.Add("x", "http://schemas.microsoft.com/winfx/2006/xaml")
    $pc.XmlnsDictionary.Add("chartingprimitives", "clr-namespace:System.Windows.Controls.DataVisualization.Charting.Primitives;assembly=System.Windows.Controls.DataVisualization.Toolkit")
    $pc.XmlnsDictionary.Add("chartingToolkit", "clr-namespace:System.Windows.Controls.DataVisualization.Charting;assembly=System.Windows.Controls.DataVisualization.Toolkit")
    $ct = [System.Windows.Controls.ControlTemplate][System.Windows.Markup.XamlReader]::Load($sr, $pc)
		
    $ChartStyle = new-object System.Windows.style
    $ChartStyle.TargetType = (New-Object System.Windows.Controls.DataVisualization.Charting.Chart).GetType()
    $ChartStyle.Setters.Add((New-object  System.Windows.Setter ([System.Windows.Controls.DataVisualization.Charting.Chart]::TemplateProperty, $ct)))
		
    $Chart.Style = $ChartStyle
  }
}


  <#
      .Synopsis
      Set Titel of a WPF Chart
      .DESCRIPTION
      Long description
      .EXAMPLE
      Example of how to use this cmdlet
      .EXAMPLE
      Another example of how to use this cmdlet
  #>
function Set-WPFChartTitel
{
	
  [CmdletBinding()]
  Param
  (
    # Param1 help description
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
    [psobject]$Chart,
    [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 1)]
    [string]$Titel,
    [String]$FontSize = "10",
    [System.Windows.FontWeight]$FontWeights = [System.Windows.FontWeights]::Bold,
    [System.Windows.Media.Brush]$Foreground = [System.Windows.Media.Brushes]::White,
    [String]$Height = "15"
		
  )
	
  Begin
  {
    if ($Titel -ne "")
    {
      $label = New-Object System.Windows.Controls.button # .Label
      $label.Content = $Titel
      $label.FontSize = $FontSize
      $label.FontWeight = $FontWeights
      $label.HorizontalContentAlignment = "left"
      $label.HorizontalAlignment = "left"
      $label.Foreground = $Foreground
      $label.Background = $Chart.Background
      $label.Height = $Height
      $label.Padding = "0"
      $label.Margin = "0"
      $Chart.Title = $label
    }
  }
}


  <#
      .Synopsis
      Remove Legend of a WPF Chart
      .DESCRIPTION
      Remove Legend of a WPF Chart
      .EXAMPLE
      Remove-ChartLegend -Chart $Chart
  #>
function Remove-WPFChartLegend
{
	
	
  [CmdletBinding()]
  Param
  (
    [Parameter(Mandatory = $true,
           ValueFromPipelineByPropertyName = $true,
           Position = 0)]
    [psobject]$Chart
		
  )
	
  Begin
  {
  }
	
  Process
  {
    $HideLegendStyle = new-Object System.Windows.Style -ArgumentList (New-Object  System.Windows.Controls.DataVisualization.Legend).GetType()
    $HideLegendStyle.Setters.Add((new-object  System.Windows.Setter ([System.Windows.Controls.DataVisualization.Legend]::WidthProperty, 0.0)))
    $HideLegendStyle.Setters.Add((new-object System.Windows.Setter ([System.Windows.Controls.DataVisualization.Legend]::HeightProperty, 0.0)))
    $HideLegendStyle.Setters.Add((new-object System.Windows.Setter ([System.Windows.Controls.DataVisualization.Legend]::VisibilityProperty, [System.Windows.Visibility]::Collapsed)))
    $Chart.LegendStyle = $HideLegendStyle
  }
  End
  {
  }
}



<#
    .Synopsis
    Create a chart with random data
    .DESCRIPTION
  
#>
function Get-WPFChartRandomChart
{
  [CmdletBinding()]
  param()
  $data = @()
  1..20 | % { $data += (new-object 'System.Collections.Generic.KeyValuePair[String, Double]' -ArgumentList "$_", (Get-Random -Maximum 100 -Minimum 0)) }
  $data | Out-ChartView -xAxisPropertie Key -yAxisPropertie Value -Background "red" -ChartArt LineSeries
}


<#
    .Synopsis
      Configure the Y axis for a chart
    .DESCRIPTION
    .PARAMETER Chart
     The parent chart object
    .PARAMETER Titel
    Titel of the Axis
    .PARAMETER Minimum 
    -100 for example
    .PARAMETER Maximum 
        100 for example
    .PARAMETER Foreground 
    The foregound color "green" or "white" for the writing pen
    .PARAMETER Forntsize
        Fontzite Size of teh writing font
    .PARAMETER Width
         Size of the axis for the space between the axis and teh draw area
    .PARAMETER IsVisiable
         Axis is invisiable with $false
    .EXAMPLE
      Set-yAchse -Chart -IsVisiable $false
    Set-yAchse -Chart
      Set-yAchse -Chart $Chart -Foreground white -Minimum 0 -Maximum 100 -Titel 'CPU [%]' -fontsize 12
#>
function Set-ChartyAxis
{
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, Position = 3)]
    [psobject]$Chart,
    [String] $Titel ="",
    $Minimum,
    $Maximum,
    $Foreground = "white",
    $fontsize = 10,
    $width,
    [switch]$ShowGridLines = $true,
    [ValidateSet("Collapsed","Hidden", "Visible") ]
    $IsVisiable = "Visible"
		
  )
	
  [System.Windows.Controls.DataVisualization.Charting.LinearAxis] $yachse = new-object System.Windows.Controls.DataVisualization.Charting.LinearAxis
  $yachse.Orientation = [System.Windows.Controls.DataVisualization.Charting.AxisOrientation]::Y
  $yachse.FontSize = $Fontsize
  $yachse.ShowGridLines = $ShowGridLines
  if ($Width) { $yachse.Width = $Width }
  if($Minimum){ $yachse.Minimum = $Minimum}
  if ($Maximum) { $yachse.Maximum = $Maximum}
  $yachse.Foreground = $Foreground
  $yachse.Name = "Y"
  $yachse.Title = $Titel
  $yachse.Visibility = $IsVisiable
  $Chart.Axes.Add($yachse)
}

<#
    .Synopsis
      Configure the X axis for a chart
    .DESCRIPTION
    .PARAMETER Chart
     The parent chart object
    .PARAMETER Titel
    Titel of the Axis
    .PARAMETER Foreground 
    The foregound color "green" or "white" for the writing pen
    .PARAMETER Forntsize
        Fontzite Size of teh writing font
    .PARAMETER Width
         Size of the axis for the space between the axis and teh draw area
    .PARAMETER IsVisiable
         Axis is invisiable with $false
    .EXAMPLE
      Set-yAchse -Chart -IsVisiable $false
    Set-yAchse -Chart
      Set-yAchse -Chart $Chart -Foreground white -Minimum 0 -Maximum 100 -Titel 'CPU [%]' -fontsize 12
#>
function Set-ChartxAxis
{
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
    [psobject]$Chart,
    [String]$Titel = "",
    $Foreground = "white",
    $fontsize = 10,
    $height,
    [switch]$ShowGridLines = $true,
    [ValidateSet("Collapsed", "Hidden", "Visible")]
    $IsVisiable = "Visible"
  )
	
	
  #$cxachse = new-object System.Windows.Controls.DataVisualization.Charting.LinearAxis
  #$cxachse.Minimum = 0
  #$cxachse.Maximum = 100
	
	
  $cxachse = new-object System.Windows.Controls.DataVisualization.Charting.CategoryAxis
  $cxachse.Orientation = [System.Windows.Controls.DataVisualization.Charting.AxisOrientation]::X
  $cxachse.FontSize = $Fontsize
  $cxachse.ShowGridLines = $ShowGridLines
  if ($height) { $yachse.Width = $Width }
  $cxachse.Foreground = $Foreground
  $cxachse.Name = "X"
  $cxachse.Title = $Titel
  $cxachse.Visibility = $IsVisiable
	
  $Chart.Series[0].IndependentAxis = $cxachse
	
	
}


<#
    .Synopsis
      Create data from a pipeline for a Chart
    .DESCRIPTION
      Create data from a pipeline for a Chart. The Data is stored in a ObservableCollection with key pairs
      "System.Collections.Generic.KeyValuePair[String, Double]"
    .EXAMPLE
    Get-Process | Add-WPFChartData -Chart $Chart -xAxisPropertie Name -yAxisPropertie CPU 
  
#>
function Add-WPFChartData
{
  [CmdletBinding()]
  Param
  (
    # Param1 help description
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
    $input,
    [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 1)]
    $xAxisPropertie,
    [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 2)]
    $yAxisPropertie,
    [Parameter(Mandatory = $true, Position = 3)]
    [psobject]$Chart,
    [Parameter(Mandatory = $false, Position = 4)]
    [ValidateSet('PieSeries', 'ColumnSeries', 'AreaSeries', 'LineSeries')]
    $ChartArt = 'LineSeries',
    [System.Windows.Media.Brush]$Foreground = "White",
    [System.Windows.Media.Brush]$Linecolor = "White"
  )
  begin
  {
    #$collection= New-Object 'System.Collections.Generic.Dictionary[String, double]'
    $collection = New-Object 'System.Collections.ObjectModel.ObservableCollection[System.Collections.Generic.KeyValuePair[String, Double]]'
		
    #$Series1 = New-Object System.Windows.Controls.DataVisualization.Charting.AreaSeries
		
    $Series1 = $null
    switch ($ChartArt)
    {
      'PieSeries' {
        $Series1 = New-Object System.Windows.Controls.DataVisualization.Charting.PieSeries
        break
      }
			
      'ColumnSeries' {
        $Series1 = New-Object System.Windows.Controls.DataVisualization.Charting.ColumnSeries
        break
      }
			
      'AreaSeries' {
        $Series1 = New-Object System.Windows.Controls.DataVisualization.Charting.AreaSeries
        break
      }
			
      Default
      {
        $Series1 = New-Object System.Windows.Controls.DataVisualization.Charting.LineSeries
				
      }
    }
		
    $Series1.Name = "SeriesOne"
    $Series1.Title = "Title"
		
    $Series1.Foreground = $Foreground
    #$Series1.Background = $Background
		
    $Series1.DependentValuePath = "Value"
    $Series1.IndependentValuePath = "Key"
    $Series1.ItemsSource = $Collection
		
    <#
        #Versteckt Y Achse
        $yachse = new-object System.Windows.Controls.DataVisualization.Charting.LinearAxis
        $yachse.Orientation = [System.Windows.Controls.DataVisualization.Charting.AxisOrientation]::Y
		
        #$yachse.FontSize = "8"
        $yachse.ShowGridLines = $true
        #$yachse.Minimum = "0"
        #$yachse.Maximum = "100"
        $yachse.Foreground = $Foreground
        $yachse.Name = "Y"
        $Chart.Axes.Add($yachse)
		
        $cxachse = new-object System.Windows.Controls.DataVisualization.Charting.CategoryAxis
        $cxachse.Orientation = [System.Windows.Controls.DataVisualization.Charting.AxisOrientation]::X
        #$cxachse.Height = "20"
        #$cxachse.FontSize = "8"
        #$cxachse.ShowGridLines = $true
        $cxachse.Foreground = $Foreground
		
        #$cxachse.ShowGridLines = $false
		
        $Series1.IndependentAxis = $cxachse
    #>
		
    if ($ChartArt -EQ 'LineSeries')
    {
      #Only change thickness not color
      $LineStyle = new-object System.Windows.style -ArgumentList (New-Object System.Windows.Shapes.Polyline).GetType()
      $LineStyle.Setters.Add((New-object  System.Windows.Setter ([System.Windows.Shapes.Polyline]::StrokeThicknessProperty, 2.0))) #Line Size
      $Series1.PolylineStyle = $LineStyle
			
      #Point Color
      $PointStyle = new-object System.Windows.style -ArgumentList (New-Object System.Windows.Controls.DataVisualization.Charting.LineDataPoint).GetType()
      $PointStyle.Setters.Add((New-object  System.Windows.Setter ([System.Windows.Controls.DataVisualization.Charting.LineDataPoint]::BackgroundProperty, $Linecolor)))
      $PointStyle.Setters.Add((New-object  System.Windows.Setter ([System.Windows.Controls.DataVisualization.Charting.LineDataPoint]::OpacityProperty, 0.0))) #hide points
      $Series1.DataPointStyle = $PointStyle
    }
		
    if ($ChartArt -EQ 'ColumnSeries')
    {
      $PointStyle = new-object System.Windows.style -ArgumentList (New-Object System.Windows.Controls.DataVisualization.Charting.ColumnDataPoint).GetType()
      $PointStyle.Setters.Add((New-object  System.Windows.Setter ([System.Windows.Controls.DataVisualization.Charting.ColumnDataPoint]::BackgroundProperty, $Linecolor)))
      $PointStyle.Setters.Add((New-object  System.Windows.Setter ([System.Windows.Controls.DataVisualization.Charting.ColumnDataPoint]::ForegroundProperty, $Linecolor)))
      $Series1.DataPointStyle = $PointStyle
    }
		
    if ($ChartArt -EQ 'AreaSeries')
    {
      $PointStyle = new-object System.Windows.style -ArgumentList (New-Object System.Windows.Controls.DataVisualization.Charting.AreaDataPoint).GetType()
      $PointStyle.Setters.Add((New-object  System.Windows.Setter ([System.Windows.Controls.DataVisualization.Charting.AreaDataPoint]::BackgroundProperty, [System.Windows.Media.Brushes]::White)))
      $PointStyle.Setters.Add((New-object  System.Windows.Setter ([System.Windows.Controls.DataVisualization.Charting.AreaDataPoint]::ForegroundProperty, [System.Windows.Media.Brushes]::White)))
      $Series1.DataPointStyle = $PointStyle
			
    }
		
		
  }
	
  process
  {
    [double]$yp = 0.0
    if ($input.$yAxisPropertie) { $yp = $input.$yAxisPropertie }
    #$datapoint = new-object psobject @{xAxisPropertie=($input.$xAxisPropertie); yAxisPropertie=$yp}
		
    #Write-Host $input
		
    $datapoint = new-object 'System.Collections.Generic.KeyValuePair[String, Double]' -ArgumentList @($input.$xAxisPropertie, $yp)
    #$datapoint
    $Collection.Add($datapoint)
    #$Collection.add($input.$xAxisPropertie, [double]$yp)
  }
	
  End
  {
    $Chart.Series.Add($Series1)
		
    Return [ref] $Collection
  }

}


<#
    .Synopsis
      Create a WPF Chart
    .DESCRIPTION
    
    .EXAMPLE
      Add-WPFCart -WPFElement $mainWindow -Background $Background 
    
#>

function Add-WPFCart
{
  [CmdletBinding()]
  param
  (
    [Parameter(Position = 0, Mandatory = $true)]
    [psobject]$WPFElement,
    [System.Windows.Media.Brush]$Background = "White",
    [System.Windows.Media.Brush]$Foreground = "Black",
    [String]$Titel = "",
    [System.Double]$Width = 0.0,
    [System.double]$Height = 0.0,
    [Parameter(Mandatory = $false)]
    [ValidateSet('PieSeries', 'ColumnSeries', 'AreaSeries', 'LineSeries')]
    $ChartArt = 'LineSeries'
		
  )
	
  $Chart = New-Object System.Windows.Controls.DataVisualization.Charting.Chart
  $Chart.LegendTitle = "Stats"
	
  if ($Width -gt 0.0)
  {
    $Chart.Width = $Width
    $Chart.Height = $Height
  }
	
  #Zero Border
  $Chart.Margin = "0"
  $Chart.Padding = "5"
  $Chart.Background = $Background
  $Chart.Foreground = $Foreground
	
	
  #Background Plot Area style
  $plotAreaStyle = new-object System.Windows.style -ArgumentList (New-Object System.Windows.Controls.Grid).GetType()
  $plotAreaStyle.Setters.Add((New-object  System.Windows.Setter ([System.Windows.Controls.Grid]::BackgroundProperty, [System.Windows.Media.Brushes]::$Background)))
  $plotAreaStyle.Setters.Add((New-object  System.Windows.Setter ([System.Windows.Controls.Grid]::MarginProperty, [System.Windows.Thickness] "2.0")))
  $chart.PlotAreaStyle = $plotAreaStyle
	
	
  #region Unbenutzt
  #styl.Setters.Add(new Setter(TemplateProperty, ct));
  #col.CellStyle = styl;  
	
  #Full Chart Template - Frame Around the Object
	
  $ChartStyle = new-object System.Windows.style
  $ChartStyle.TargetType = (New-Object System.Windows.Controls.DataVisualization.Charting.Chart).GetType()
  $ChartStyle.Setters.Add((New-object  System.Windows.Setter ([System.Windows.Controls.Border]::BackgroundProperty, [System.Windows.Media.Brushes]::black)))
  $ChartStyle.Setters.Add((New-object  System.Windows.Setter ([System.Windows.Controls.Border]::BorderBrushProperty, [System.Windows.Media.Brushes]::black)))
  $ChartStyle.Setters.Add((New-object  System.Windows.Setter ([System.Windows.Controls.Border]::BorderThicknessProperty, [System.Windows.Thickness] "1.0")))
  $ChartStyle.Setters.Add((New-object  System.Windows.Setter ([System.Windows.Controls.Border]::PaddingProperty, [System.Windows.Thickness] "10.0")))
	
  #$ChartStyle = new-object System.Windows.style
  #$templateChart = new-object System.Windows.Controls.ControlTemplate  -ArgumentList (New-Object System.Windows.Controls.DataVisualization.Charting.Chart).GetType()
	
  #$borderFactory = New-Object System.Windows.FrameworkElementFactory -ArgumentList (New-Object System.Windows.Controls.Border).GetType()
  #$borderFactory.SetValue([System.Windows.Controls.Border]::BorderThicknessProperty,  [System.Windows.Thickness] "50.0")
	
  <#
      $ChartStyle.Setters.Add((New-object  System.Windows.Setter ([System.Windows.Controls.Border]::BackgroundProperty, [System.Windows.Media.Brushes]::black )))
      $ChartStyle.Setters.Add((New-object  System.Windows.Setter ([System.Windows.Controls.Border]::BorderBrushProperty, [System.Windows.Media.Brushes]::black )))
      $ChartStyle.Setters.Add((New-object  System.Windows.Setter ([System.Windows.Controls.Border]::BorderThicknessProperty,   [System.Windows.Thickness] "20.0" )))
      $ChartStyle.Setters.Add((New-object  System.Windows.Setter ([System.Windows.Controls.Border]::PaddingProperty, [System.Windows.Thickness] "20.0" )))
  #>
	
  <#
      $ChartStyle.Setters.Add((New-object  System.Windows.Setter ([System.Windows.Controls.DataVisualization.Charting.Chart]::TemplateProperty,   $templateChart )))
      
      $grid = New-Object System.Windows.FrameworkElementFactory -ArgumentList (New-Object System.Windows.Controls.Grid).GetType()
      $grid.SetValue([System.Windows.Controls.Grid]::MarginProperty,  [System.Windows.Thickness] "5.0")
      $grid.SetValue([System.Windows.Controls.Grid]::BackgroundProperty,  [System.Windows.Media.Brushes]::AliceBlue)
    
      $edge = New-Object System.Windows.FrameworkElementFactory  -argumentList (new-object System.Windows.Controls.DataVisualization.Charting.Primitives.EdgePanel).GetType()
      $edge.SetValue( [System.Windows.Controls.DataVisualization.Charting.Primitives.EdgePanel]::NameProperty, "ChartArea")
  #>
  #elemFactory.SetBinding(Border.BackgroundProperty, new Binding { RelativeSource = RelativeSource.TemplatedParent, Path = new PropertyPath("Background") });
  #new-object System.Windows.Data.Binding -ArgumentList 
  #$edge.SetBinding([System.Windows.Controls.DataVisualization.Charting.Chart]::StyleProperty, (new-object System.Windows.data
  <#
      $grid.AppendChild($edge)
   
      $borderFactory.AppendChild($grid)
      $templateChart.VisualTree = $borderFactory
      $chart.Style = $ChartStyle
  #>
  #endregion Description
	
  $WPFElement.addChild($Chart)
  return $Chart
  #}
	}


<#
.SYNOPSIS
Create a output for x,y data like a Graph

.DESCRIPTION
Create a output for x,y data like a Graph

.PARAMETER input
Input form Pipe

.PARAMETER xAxisPropertie
Name of the position parameter @{Name=, Length=}

.PARAMETER yAxisPropertie
Name of the position parameter @{Name=, Length=}

.PARAMETER Background
Background color

.PARAMETER Foreground
Foreground color

.PARAMETER Linecolor
Line color

.PARAMETER ChartArt
Chart type 'PieSeries', 'ColumnSeries', 'AreaSeries', 'LineSeries'

.PARAMETER DisableLegende
Disable the Legend field

.EXAMPLE
Get-childItem C:\windows | Where-Object {$_.length -gt 1} | Sort-Object -Property length -Descending | Select-Object -first 10  | `
    Out-ChartView -xAxisPropertie "Name" -yAxisPropertie "Length"  -Background "Green" -ChartArt ColumnSeries

.NOTES
Andreas Nick 2017, ww.software-virtualisierung.de
#>

function Out-ChartView
{
  [CmdletBinding()]
  Param
  (
    # Param1 help description
    [Parameter(Mandatory = $true,
           ValueFromPipeline = $true,
           Position = 0)]
    $input,
    [Parameter(Mandatory = $true,
           ValueFromPipeline = $false, Position = 1)]
    $xAxisPropertie,
    [Parameter(Mandatory = $true,
           ValueFromPipeline = $false,
           Position = 2)]
    $yAxisPropertie,
    [System.Windows.Media.Brush]$Background = "green",
    [System.Windows.Media.Brush]$Foreground = "white",
    [System.Windows.Media.Brush]$Linecolor = "Black",
    [Parameter(Mandatory = $false)]
    [ValidateSet('PieSeries', 'ColumnSeries', 'AreaSeries', 'LineSeries')]
    $ChartArt = 'LineSeries',
    [Switch] $DisableLegende = $true
  )
	
  Begin
  {
    $fromPipe = @()
    # Create the application's main WPF window.
    $mainWindow = New-Object System.Windows.Window
		
    $mainWindow.ShowInTaskBar = $true
    $mainWindow.Title = "Chart"
    $mainWindow.Background = $Background
    $mainWindow.Foreground = $Foreground
    $Chart = Add-WPFCart -WPFElement $mainWindow -Background $Background -Foreground $Foreground
    if ($DisableLegende)
    {
      Remove-WPFChartLegend -chart $Chart
    }
    $chartdata = @()
		
  }
  Process
  {
    $chartdata += $_
  }
  End
  {
    $chartdata | Add-WPFChartData -Chart $Chart -xAxisPropertie $xAxisPropertie -yAxisPropertie $yAxisPropertie -ChartArt $ChartArt -Foreground $Foreground -LineColor $Linecolor
    Show-WPFWindow -Window $mainWindow
  }
}
