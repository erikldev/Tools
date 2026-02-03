$Manter = @("Administrador","Public","luxxu")

$perfis = Get-CimInstance Win32_UserProfile | Where-Object { 
    $_.LocalPath -like "C:\Users\*" -and ($Manter -notcontains (Split-Path $_.LocalPath -Leaf)) 
}

Write-Host "=== PERFIS QUE SERAO REMOVIDOS ===" -ForegroundColor Red
$perfis | ForEach-Object { Write-Host "• $($_.LocalPath)" -ForegroundColor Yellow }

$confirmar = Read-Host "`nDigite 'OK' para remover ou Enter para cancelar"
if ($confirmar -eq 'OK') {
    $perfis | ForEach-Object {
        Remove-CimInstance $_
        Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$($_.SID)" -ErrorAction SilentlyContinue
    }
    Write-Host "Remocao concluida!" -ForegroundColor Green
} else {
    Write-Host "Operacao cancelada." -ForegroundColor Cyan
}
