Function Save-Chart {
    Param
    (
        [Parameter(Mandatory=$true)] [string]$ChartType,
        [Parameter(Mandatory=$true)] [array]$ChartData,
        [Parameter(Mandatory=$true)] [hashtable]$OutputParams,
        [hashtable]$ChartParams
    )
    
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Windows.Forms.DataVisualization

    $Chart = New-Object System.Windows.Forms.DataVisualization.Charting.Chart
    $ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
    $Series = New-Object -TypeName System.Windows.Forms.DataVisualization.Charting.Series
    $ChartTypes = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]

    $Series.ChartType = $ChartTypes::$ChartType
    $Chart.Series.Add($Series)
    $Chart.ChartAreas.Add($ChartArea)

    $Chart.Series['Series1'].Points.DataBindXY($ChartData.Keys, $ChartData.Values)

    #Chart Title
    if ($ChartParams.Contains('ChartTitleParams')) {
        $ChartTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title
        
        ForEach ($TitleParam in $ChartParams.ChartTitleParams.Keys) {
            $ChartTitle.$TitleParam = $ChartParams.ChartTitleParams.$TitleParam    
        }

        $Chart.Titles.Add($ChartTitle)
        $ChartParams.Remove('ChartTitleParams')
    }

    #Chart Legend
    if ($ChartParams.Contains('LegendParams')) {
        $Legend = New-Object System.Windows.Forms.DataVisualization.Charting.Legend

        ForEach ($LegendParam in $ChartParams.LegendParams.Keys) {
            $Legend.$LegendParam = $ChartParams.LegendParams.$LegendParam    
        }

        $Chart.Legends.Add($Legend)
        $Chart.Series["Series1"].LegendText = "#VALX (#VALY)"
        $ChartParams.Remove('LegendParams')
    }

    #3D Chart
    if ($ChartParams.Contains('3DParams')) {
        ForEach ($3DParam in $ChartParams.'3DParams'.Keys) {
            $ChartArea.Area3DStyle.$3DParam = $ChartParams.'3DParams'.$3DParam    
        }
        $ChartParams.Remove('3DParams')
    }

    #Dataset labelling, enabled by default
    $Chart.Series['Series1']['PieLabelStyle'] = $ChartParams.PieLabelStyle
    $ChartParams.Remove('PieLabelStyle')

    ForEach ($Param in $ChartParams.Keys) {
        $Chart.$Param = $ChartParams.$Param    
    }

    #Output chart
    $Chart.SaveImage($OutputParams.Path, $OutputParams.FileType)
}

#test driver
$thisChartType = "Line"
$thisChartData = @{}
$thisChartParams = @{
    Width = 700
    Height = 700
    Left = 10
    Top = 10
    BackColor = [System.Drawing.Color]::White
    BorderColor = 'Black'
    BorderDashStyle = 'Solid'
    ChartTitleParams = @{
        Text = 'Top 5 Processes by Working Set Memory'
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
$thisOutputParams = @{
    Path = "$PSScriptRoot\chart.jpg"
    FileType = 'jpeg'
}

$Processes = Get-Process | Sort-Object WS -Descending | Select-Object -First 10
$DuplicateKeys = @{}

ForEach ($Process in $Processes)
{
    if ($thisChartData.Contains($Process.Name)) 
    {
        if ($DuplicateKeys.Contains($Process.Name)) 
        {
            $DuplicateKeys.$($Process.Name)++
        }
        else 
        {
            $DuplicateKeys.Add($Process.Name, 2)
        }
        $thisChartData.Add("$($Process.Name)[$($DuplicateKeys.$($Process.Name))]", $Process.WS)
    }  
    else 
    {
        $thisChartData.Add($Process.Name, $Process.WS)
    } 
}

Save-Chart $thisChartType $thisChartData $thisOutputParams $thisChartParams 