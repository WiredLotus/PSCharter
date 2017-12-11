# Adding .NET classes
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

Function Save-Chart 
{
    Param
    (
        [Parameter(Mandatory=$true)] [string]$ChartType,
        [Parameter(Mandatory=$true)] [array]$ChartData,
        [Parameter(Mandatory=$true)] [hashtable]$OutputParams,
        [hashtable]$ChartParams
    )

    $Chart = New-Object System.Windows.Forms.DataVisualization.Charting.Chart
    $ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea

    $Chart.ChartAreas.Add($ChartArea)

    ForEach ($DataSet in $ChartData.Keys) 
    {
        [void]$Chart.Series.Add($DataSet)
        $Chart.Series[$DataSet].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::$ChartType
        #Series width
        if ($ChartData.$DataSet.Contains('SeriesBorderWidth')) 
        {
            $Chart.Series[$DataSet].BorderWidth = $ChartData.$DataSet.SeriesBorderWidth;
            $ChartData.$DataSet.Remove('SeriesBorderWidth')
        }
        #Series color
        if ($ChartData.$DataSet.Contains('SeriesColor')) 
        {
            $Chart.Series[$DataSet].Color = $ChartData.$DataSet.SeriesColor;
            $ChartData.$DataSet.Remove('SeriesColor')
        }

        $Chart.Series[$DataSet].Points.DataBindXY($ChartData.$DataSet.Keys, $ChartData.$DataSet.Values)
    }

    #Chart Title
    if ($ChartParams.Contains('ChartTitleParams')) 
    {
        $ChartTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title
        
        ForEach ($TitleParam in $ChartParams.ChartTitleParams.Keys) 
        {
            $ChartTitle.$TitleParam = $ChartParams.ChartTitleParams.$TitleParam    
        }

        $Chart.Titles.Add($ChartTitle)
        $ChartParams.Remove('ChartTitleParams')
    }

    #Chart Legend
    if ($ChartParams.Contains('LegendParams')) 
    {
        $Legend = New-Object System.Windows.Forms.DataVisualization.Charting.Legend

        ForEach ($LegendParam in $ChartParams.LegendParams.Keys) 
        {
            $Legend.$LegendParam = $ChartParams.LegendParams.$LegendParam    
        }

        $Chart.Legends.Add($Legend)
        if ($ChartType -eq 'Pie') 
        {
            $Chart.Series[$DataSet].LegendText = "#VALX (#VALY)"
        }
        $ChartParams.Remove('LegendParams')
    }

    #3D Chart
    if ($ChartParams.Contains('3DParams')) 
    {
        ForEach ($3DParam in $ChartParams.'3DParams'.Keys) 
        {
            $ChartArea.Area3DStyle.$3DParam = $ChartParams.'3DParams'.$3DParam    
        }
        $ChartParams.Remove('3DParams')
    }

    #Pie chart dataset labelling - enabled by default
    if ($ChartParams.Contains('PieLabelStyle')) 
    {
        $Chart.Series[$DataSet]['PieLabelStyle'] = $ChartParams.PieLabelStyle
        $ChartParams.Remove('PieLabelStyle')
    }

    ForEach ($Param in $ChartParams.Keys) 
    {
        if ($Param.contains('.'))
        {
            Set-NestedChartProperty $Chart $Param $ChartParams.$Param
        }
        else
        {
            $Chart.$Param = $ChartParams.$Param
        }
    }

    #Output chart
    $Chart.SaveImage($OutputParams.Path, $OutputParams.FileType)
}

#Format dataset and add to target datasets hashtable
Function Add-DataSet 
{
    Param
    (
        [Parameter(Mandatory=$true)] [hashtable]$TargetDataSets,
        [Parameter(Mandatory=$true)] [array]$DataSet,
        [Parameter(Mandatory=$true)] [string]$DataSetName,
        [Parameter(Mandatory=$true)] [string]$XVar,
        [Parameter(Mandatory=$true)] [string]$YVar,
        $BorderWidth,
        $SeriesColor
    )
    $FormattedDataSet  = @{}
    $DuplicateKeys = @{}

    ForEach ($SetObject in $DataSet)
    {
        if ($FormattedDataSet.Contains($SetObject.$XVar)) 
        {
            if ($DuplicateKeys.Contains($SetObject.$XVar)) 
            {
                $DuplicateKeys.$($SetObject.$XVar)++
            }
            else 
            {
                $DuplicateKeys.Add($SetObject.$XVar, 2)
            }
            $FormattedDataSet.Add("$($SetObject.$XVar)[$($DuplicateKeys.$($SetObject.$XVar))]", $SetObject.$YVar)
        }  
        else 
        {
            $FormattedDataSet.Add($SetObject.$XVar, $SetObject.$YVar)
        } 
    }

    $TargetDataSets.Add($DataSetName, $FormattedDataSet)

    if ($BorderWidth) 
    {
        $TargetDataSets.$DataSetName.Add('SeriesBorderWidth', $BorderWidth)
    }
    if ($SeriesColor) 
    {
        $TargetDataSets.$DataSetName.Add('SeriesColor', $SeriesColor)
    }
}

Function Set-NestedChartProperty 
{
    Param
    (
        [Parameter(Mandatory=$true)] $TargetChart,
        [Parameter(Mandatory=$true)] [string]$NestedProperty,
        [Parameter(Mandatory=$true)] $PropertyValue
    )
    $CurrentProperty = $($NestedProperty -split '\.',2)[0] 

    if ($NestedProperty.contains('.'))
    {
        Set-NestedChartProperty $TargetChart.$CurrentProperty $($NestedProperty -split '\.',2)[1] $PropertyValue
    } 
    else 
    {
        $TargetChart.$NestedProperty = $PropertyValue
    }
}

