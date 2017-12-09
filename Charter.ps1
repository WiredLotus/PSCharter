<#https://blogs.technet.microsoft.com/richard_macdonald/2009/04/28/charting-with-powershell/

https://bytecookie.wordpress.com/2012/04/13/tutorial-powershell-and-microsoft-chart-controls-or-how-to-spice-up-your-reports/

https://learn-powershell.net/2016/09/18/building-a-chart-using-powershell-and-chart-controls/

https://msdn.microsoft.com/en-us/library/dd456632.aspx
#>

$Processes = Get-Process | Sort-Object WS -Descending | Select-Object -First 10

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

$Chart = New-Object System.Windows.Forms.DataVisualization.Charting.Chart
$ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$Series = New-Object -TypeName System.Windows.Forms.DataVisualization.Charting.Series
$ChartTypes = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]

$Series.ChartType = $ChartTypes::Pie

$Chart.Series.Add($Series)
$Chart.ChartAreas.Add($ChartArea)


$Chart.Series['Series1'].Points.DataBindXY($Processes.Name, $Processes.WS)

$Chart.Width = 700
$Chart.Height = 700
$Chart.Left = 10
$Chart.Top = 10
$Chart.BackColor = [System.Drawing.Color]::White
$Chart.BorderColor = 'Black'
$Chart.BorderDashStyle = 'Solid'

$ChartTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title
$ChartTitle.Text = 'Top 5 Processes by Working Set Memory'
$Font = New-Object System.Drawing.Font @('Microsoft Sans Serif','12', [System.Drawing.FontStyle]::Bold)
$ChartTitle.Font =$Font
$Chart.Titles.Add($ChartTitle)

$Chart.Series['Series1']['PieLabelStyle'] = 'Disabled'

$Legend = New-Object System.Windows.Forms.DataVisualization.Charting.Legend
$Legend.IsEquallySpacedItems = $True
$Legend.BorderColor = 'Black'
$Chart.Legends.Add($Legend)
$Chart.Series["Series1"].LegendText = "#VALX (#VALY)"

#region Windows Form to Display Chart
$AnchorAll = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right -bor
[System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left
$Form = New-Object Windows.Forms.Form
$Form.Width = 740
$Form.Height = 490
$Form.controls.add($Chart)
$Chart.Anchor = $AnchorAll

$Form.Add_Shown({$Form.Activate()})
[void]$Form.ShowDialog()
#endregion Windows Form to Display Chart

$Chart.SaveImage('F:\Code\chart.jpg', 'jpeg')