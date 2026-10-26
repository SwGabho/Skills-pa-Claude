# Captura la ventana de Power BI Desktop con PrintWindow (funciona aunque la ventana no este en primer plano;
# SetForegroundWindow + CopyFromScreen suele capturar la terminal porque Windows bloquea el cambio de foco).
# Uso: & captura_ventana.ps1 -Titulo 'PyG_MODELO_V1' -Out 'C:\...\captura.png'
param([Parameter(Mandatory)][string]$Titulo, [Parameter(Mandatory)][string]$Out)
Add-Type -AssemblyName System.Drawing
Add-Type @"
using System; using System.Runtime.InteropServices;
public class PWin {
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int L, T, R, B; }
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr h, IntPtr hdc, uint f);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int c);
}
"@
$p = Get-Process PBIDesktop -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -like "$Titulo*" } | Select-Object -First 1
if (-not $p) { throw "No hay ventana de Power BI Desktop con titulo '$Titulo'." }
[PWin]::ShowWindow($p.MainWindowHandle, 3) | Out-Null   # maximizar
Start-Sleep 3
$r = New-Object PWin+RECT
[PWin]::GetWindowRect($p.MainWindowHandle, [ref]$r) | Out-Null
$w = $r.R - $r.L; $h = $r.B - $r.T
$bmp = New-Object System.Drawing.Bitmap $w, $h
$g = [System.Drawing.Graphics]::FromImage($bmp)
$hdc = $g.GetHdc()
[PWin]::PrintWindow($p.MainWindowHandle, $hdc, 2) | Out-Null   # 2 = PW_RENDERFULLCONTENT
$g.ReleaseHdc($hdc)
$bmp.Save($Out, [System.Drawing.Imaging.ImageFormat]::Png)
"$Out (${w}x${h})"
