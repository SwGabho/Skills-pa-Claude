# Copia medidas y columnas calculadas desde los TMDL del disco al modelo ABIERTO en Power BI Desktop (via TOM),
# para que Desktop y los archivos queden iguales y un "Guardar" de Desktop no pise los cambios.
# Uso:
#   & sync_tom.ps1 -Definition '...\definition' -Titulo 'PyG_MODELO_V1' -TablaMedidas 'MEDIDAS' -PatronMedidas '*GS_*' `
#                  -Columnas 'GOLDEN_STORE_NUEVO|LLAVE_GERENCIAL','INFORME_GERENCIAL|ANIO_MES_PDV' -DryRun
# Nombres con tildes en -Columnas: pasarlos desde la linea de comandos (no escribirlos dentro de este .ps1).
param(
    [Parameter(Mandatory)][string]$Definition,
    [string]$Titulo, [int]$Port,
    [string]$TablaMedidas, [string]$PatronMedidas,
    [string[]]$Columnas = @(),
    [switch]$DryRun
)
$ErrorActionPreference = 'Stop'
if (-not $Port) { $Port = & (Join-Path $PSScriptRoot 'puerto_desktop.ps1') -Titulo $Titulo }
Add-Type -Path "C:\Program Files\Microsoft Power BI Desktop\bin\Microsoft.PowerBI.Tabular.dll"
$src = [Microsoft.AnalysisServices.Tabular.TmdlSerializer]::DeserializeDatabaseFromFolder($Definition)
"TMDL OK"
$srv = New-Object Microsoft.AnalysisServices.Tabular.Server
$srv.Connect("Data Source=localhost:$Port")
$live = $srv.Databases[0].Model
try {
    if ($TablaMedidas -and $PatronMedidas) {
        $lt = $live.Tables[$TablaMedidas]
        foreach ($m in $src.Model.Tables[$TablaMedidas].Measures | Where-Object { $_.Name -like $PatronMedidas }) {
            $t = $lt.Measures.Find($m.Name)
            if (-not $t) { $t = New-Object Microsoft.AnalysisServices.Tabular.Measure; $t.Name = $m.Name; $lt.Measures.Add($t); "  + medida $($m.Name)" } else { "  ~ medida $($m.Name)" }
            $t.Expression = $m.Expression; $t.FormatString = $m.FormatString; $t.DisplayFolder = $m.DisplayFolder
            $t.IsHidden = $m.IsHidden; $t.Description = $m.Description; $t.DataCategory = $m.DataCategory
        }
    }
    foreach ($par in $Columnas) {
        $tabla, $col = $par -split '\|', 2
        $c = $src.Model.Tables[$tabla].Columns[$col]
        $lt = $live.Tables[$tabla]
        $t = $lt.Columns.Find($col)
        if (-not $t) { $t = New-Object Microsoft.AnalysisServices.Tabular.CalculatedColumn; $t.Name = $col; $lt.Columns.Add($t); "  + columna $tabla[$col]" } else { "  ~ columna $tabla[$col]" }
        $t.Expression = $c.Expression; $t.IsHidden = $c.IsHidden; $t.SummarizeBy = $c.SummarizeBy; $t.Description = $c.Description
        if ($c.SortByColumn) { $t.SortByColumn = $lt.Columns[$c.SortByColumn.Name] }
    }
    if ($DryRun) { $live.UndoLocalChanges(); "DryRun: sin guardar"; return }
    $live.SaveChanges() | Out-Null
    if ($Columnas.Count -gt 0) {
        $live.RequestRefresh([Microsoft.AnalysisServices.Tabular.RefreshType]::Calculate)
        $live.SaveChanges() | Out-Null
    }
    "Guardado en el modelo abierto."
} finally { $srv.Disconnect() }
