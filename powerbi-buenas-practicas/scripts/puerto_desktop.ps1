# Devuelve el puerto del motor (msmdsrv) del Power BI Desktop cuya ventana empieza por -Titulo.
# Uso: & puerto_desktop.ps1 -Titulo 'PyG_MODELO_V1'
param([Parameter(Mandatory)][string]$Titulo)
$p = Get-Process PBIDesktop -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -like "$Titulo*" } | Select-Object -First 1
if (-not $p) { throw "No hay un Power BI Desktop abierto con titulo '$Titulo'." }
$ms = Get-CimInstance Win32_Process -Filter "Name='msmdsrv.exe'" | Where-Object { $_.ParentProcessId -eq $p.Id }
(Get-NetTCPConnection -OwningProcess $ms.ProcessId -State Listen | Select-Object -First 1).LocalPort
