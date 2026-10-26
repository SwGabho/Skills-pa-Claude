# Valida la sintaxis TMDL deserializando la carpeta definition con el TOM que trae Power BI Desktop.
# Uso: & validar_tmdl.ps1 -Definition 'C:\ruta\Modelo.SemanticModel\definition'
param([Parameter(Mandatory)][string]$Definition)
Add-Type -Path "C:\Program Files\Microsoft Power BI Desktop\bin\Microsoft.PowerBI.Tabular.dll"
$db = [Microsoft.AnalysisServices.Tabular.TmdlSerializer]::DeserializeDatabaseFromFolder($Definition)
"TMDL OK: $($db.Model.Tables.Count) tablas, $(($db.Model.Tables | ForEach-Object { $_.Measures.Count } | Measure-Object -Sum).Sum) medidas"
