$Manter = @("Administrador","Public","Arklok")

$perfis = Get-CimInstance Win32_UserProfile | Where-Object {
    -not $_.Loaded -and
    $_.LocalPath -like "C:\Users\*" -and
    ($Manter -notcontains (Split-Path $_.LocalPath -Leaf))
}

if ($perfis.Count -eq 0) {
    Write-Host "Nenhum perfil encontrado para remocao." -ForegroundColor Cyan
    return
}

Write-Host "=== PERFIS QUE SERAO REMOVIDOS ===" -ForegroundColor Red
$perfis | ForEach-Object {
    Write-Host "• $($_.LocalPath)" -ForegroundColor Yellow
}

$confirmar = Read-Host "`nDigite 'OK' para remover ou Enter para cancelar"

if ($confirmar -ne 'OK') {
    Write-Host "Operacao cancelada." -ForegroundColor Cyan
    return
}

$total = $perfis.Count
$contador = 0
$marcos = @(20, 50, 75, 100)
$proximoMarco = $marcos[0]

foreach ($perfil in $perfis) {
    $contador++

    try {
        $perfil | Invoke-CimMethod -MethodName Delete
    }
    catch {
        Write-Warning "Falha ao remover $($perfil.LocalPath)"
    }

    $percentual = [math]::Floor(($contador / $total) * 100)

    if ($percentual -ge $proximoMarco) {
        Write-Host "Progresso: $proximoMarco% concluido..." -ForegroundColor Cyan
        $marcos = $marcos | Where-Object { $_ -gt $proximoMarco }
        if ($marcos.Count -gt 0) {
            $proximoMarco = $marcos[0]
        }
    }
}

Write-Host "Remocao concluida! (100%)" -ForegroundColor Green
