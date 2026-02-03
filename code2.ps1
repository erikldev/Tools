$Manter = @("Administrador","Public","luxxu")

$perfis = @(Get-CimInstance Win32_UserProfile | Where-Object {
    $_.LocalPath -like "C:\Users\*" -and
    ($Manter -notcontains (Split-Path $_.LocalPath -Leaf))
})

if ($perfis.Count -eq 0) {
    Write-Host "Nenhum perfil encontrado para remocao." -ForegroundColor Cyan
    return
}

Write-Host "=== PERFIS QUE SERAO REMOVIDOS ===" -ForegroundColor Red
$perfis | ForEach-Object { Write-Host "• $($_.LocalPath)" -ForegroundColor Yellow }

$confirmar = Read-Host "`nDigite 'OK' para remover ou Enter para cancelar"

if ($confirmar -eq 'OK') {

    $total = $perfis.Count
    $contador = 0

    foreach ($perfil in $perfis) {
        $contador++

        Write-Progress `
            -Activity "Removendo perfis de usuario" `
            -Status "($contador de $total) $($perfil.LocalPath)" `
            -PercentComplete ([math]::Round(($contador / $total) * 100))

        Remove-CimInstance $perfil
        Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$($perfil.SID)" `
            -ErrorAction SilentlyContinue
    }

    Write-Progress -Activity "Removendo perfis de usuario" -Completed
    Write-Host "Remocao concluida!" -ForegroundColor Green

} else {
    Write-Host "Operacao cancelada." -ForegroundColor Cyan
}
