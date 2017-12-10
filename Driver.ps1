Import-Module $PSScriptRoot\ChartLib.psm1 -force

#############
#TEST DRIVER#
#############

# Current support for Pie, Line, Column and Bar Charts
$TestChartType = "Line"
$TestChartData = @{}
$TestOutputParams = @{
    Path = "$PSScriptRoot\chart.jpg"
    FileType = 'jpeg'
}
$TestChartParams = @{
    Width = 700
    Height = 700
    Left = 10
    Top = 10
    BackColor = [System.Drawing.Color]::White
    BorderColor = 'Black'
    BorderDashStyle = 'Solid'
    'ChartAreas.AxisX.LabelStyle.Interval'   = 1
    'ChartAreas.AxisX.MajorGrid.Enabled'     = $False
    'ChartAreas.AxisX.MajorTickMark.Enabled' = $False
    ChartTitleParams = @{
        Text = 'Working Set Memory Chart'
        Font = New-Object System.Drawing.Font @('Microsoft Sans Serif','12', [System.Drawing.FontStyle]::Bold)
    }
    LegendParams = @{
        IsEquallySpacedItems = $True
        BorderColor = 'Black'
    }
    <#
    '3DParams' = @{
        Enable3D = $True
        Inclination = 50
    }#>
    PieLabelStyle = 'Disabled'
}

$Processes1 = Get-Process | Sort-Object WS -Descending | Select-Object -First 10
$Processes2 = Get-Process | Sort-Object WS -Descending | Select-Object -Last 10

#Add-DataSet $TestChartData $Processes1 'Set 1' 'Name' 'WS' 
Add-DataSet $TestChartData $Processes2 'Set 2' 'Name' 'WS' 

Save-Chart $TestChartType $TestChartData $TestOutputParams $TestChartParams