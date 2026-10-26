# Ejecuta una consulta DAX contra el modelo abierto en Power BI Desktop usando el ADOMD que trae Desktop
# (no requiere el MCP ni su EULA). Devuelve filas separadas por '|'.
# Uso: & dax.ps1 -Titulo 'PyG_MODELO_V1' -QueryFile consulta.dax [-MaxRows 100]
#      & dax.ps1 -Port 51234 -Query 'EVALUATE ROW("x", [Mi Medida])'
# Guardar el .dax en UTF-8 si tiene tildes ([IO.File]::WriteAllText con UTF8Encoding).
param([string]$Titulo, [int]$Port, [string]$QueryFile, [string]$Query, [int]$MaxRows = 100)
if (-not $Port) { $Port = & (Join-Path $PSScriptRoot 'puerto_desktop.ps1') -Titulo $Titulo }
if ($QueryFile) { $Query = [IO.File]::ReadAllText($QueryFile) }
Add-Type -Path "C:\Program Files\Microsoft Power BI Desktop\bin\Microsoft.PowerBI.AdomdClient.dll"
$cn = New-Object Microsoft.AnalysisServices.AdomdClient.AdomdConnection("Data Source=localhost:$Port")
$cn.Open()
try {
    $cmd = $cn.CreateCommand(); $cmd.CommandText = $Query
    $rd = $cmd.ExecuteReader()
    $cols = 0..($rd.FieldCount - 1) | ForEach-Object { $rd.GetName($_) -replace '^.*\[(.*)\]$', '$1' }
    $rows = @(); $n = 0
    while ($rd.Read() -and $n -lt $MaxRows) {
        $o = [ordered]@{}
        for ($i = 0; $i -lt $rd.FieldCount; $i++) { $o[$cols[$i]] = $rd.GetValue($i) }
        $rows += [pscustomobject]$o; $n++
    }
    $rd.Close()
    $rows | ConvertTo-Csv -NoTypeInformation -Delimiter '|'
} finally { $cn.Close() }
