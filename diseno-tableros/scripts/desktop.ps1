# Abre o cierra un .pbip en Power BI Desktop y espera a que termine.
# Uso: & desktop.ps1 -Accion Abrir  -Pbip 'C:\...\Modelo.pbip' -Titulo 'Modelo'   (espera ventana + carga de visuales)
#      & desktop.ps1 -Accion Cerrar -Titulo 'Modelo'
# Notas: abrir tarda 2-4 min en modelos grandes; al cerrar, Desktop vuelve a guardar los PBIR/TMDL con su propio
# formato (releer antes de editar) y puede tardar 1-3 min; a veces ignora el primer CloseMainWindow.
param([Parameter(Mandatory)][ValidateSet('Abrir', 'Cerrar')][string]$Accion, [Parameter(Mandatory)][string]$Titulo,
      [string]$Pbip, [int]$EsperaCargaSeg = 100, [int]$TimeoutSeg = 300)
function Get-Ventana { Get-Process PBIDesktop -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -like "$Titulo*" } | Select-Object -First 1 }
if ($Accion -eq 'Abrir') {
    if (Get-Ventana) { "Ya estaba abierto"; return }
    Start-Process $Pbip
    $t = 0; do { Start-Sleep 10; $t += 10 } until ((Get-Ventana) -or $t -ge $TimeoutSeg)
    if (-not (Get-Ventana)) { throw "Desktop no abrio en $TimeoutSeg s" }
    Start-Sleep $EsperaCargaSeg
    "Abierto ($t s + $EsperaCargaSeg s de carga)"
} else {
    $p = Get-Ventana
    if (-not $p) { "No estaba abierto"; return }
    $id = $p.Id; $p.CloseMainWindow() | Out-Null
    $t = 0
    while ((Get-Process -Id $id -ErrorAction SilentlyContinue) -and $t -lt $TimeoutSeg) {
        Start-Sleep 5; $t += 5
        if ($t -eq 30 -and (Get-Process -Id $id -ErrorAction SilentlyContinue).MainWindowTitle) { (Get-Process -Id $id).CloseMainWindow() | Out-Null }
    }
    if (Get-Process -Id $id -ErrorAction SilentlyContinue) { "Sigue abierto tras $t s (revisar si hay un dialogo)" } else { "Cerrado tras $t s" }
}
