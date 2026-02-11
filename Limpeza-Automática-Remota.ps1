$PerfisProtegidos = @("Administrador","Public","Arklok")

$Computadores = @("AKL-WRK-242732")

$ModoSimulacao = $true
 
Invoke-Command -ComputerName $Computadores -ScriptBlock {
 
    param ($PerfisProtegidos, $ModoSimulacao)
 
    $ErrorActionPreference = "Stop"
 
    Write-Host "`n==== INICIANDO VERIFICAÇÃO EM $(hostname) ====" -ForegroundColor Cyan
 
    $usuarioAtivo = (Get-CimInstance Win32_ComputerSystem).UserName

    if ($usuarioAtivo) {

        $usuarioAtivo = $usuarioAtivo.Split('\')[-1]

        Write-Host "Usuário ativo detectado: $usuarioAtivo" -ForegroundColor Yellow

    }
 
    $ListaProtegidaFinal = $PerfisProtegidos

    if ($usuarioAtivo) {

        $ListaProtegidaFinal += $usuarioAtivo

    }
 
    Write-Host "Perfis protegidos:" -ForegroundColor Cyan

    $ListaProtegidaFinal | ForEach-Object { Write-Host " - $_" }
 
    $perfis = Get-CimInstance Win32_UserProfile | Where-Object {
 
        $nomePerfil = Split-Path $_.LocalPath -Leaf
 
        $_.LocalPath -like "C:\Users\*" -and

        -not $_.Special -and

        $ListaProtegidaFinal -notcontains $nomePerfil

    }
 
    if (-not $perfis) {

        Write-Host "`nNenhum perfil elegível encontrado." -ForegroundColor Green

        return

    }
 
    foreach ($perfil in $perfis) {
 
        $nomePerfil = Split-Path $perfil.LocalPath -Leaf

        Write-Host "`nProcessando perfil: $nomePerfil" -ForegroundColor Yellow
 
        if ($ModoSimulacao) {

            Write-Host "[SIMULAÇÃO] Removeria: $($perfil.LocalPath)" -ForegroundColor Magenta

            continue

        }
 
        try {

            Remove-CimInstance -InputObject $perfil -ErrorAction Stop
 
            Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$($perfil.SID)" `

                -Recurse -Force -ErrorAction SilentlyContinue
 
            Write-Host "Removido com sucesso: $nomePerfil" -ForegroundColor Green

        }

        catch {

            Write-Host "ERRO ao remover $nomePerfil : $_" -ForegroundColor Red

        }

    }
 
    Write-Host "`n==== FINALIZADO EM $(hostname) ====" -ForegroundColor Cyan
 
} -ArgumentList $PerfisProtegidos, $ModoSimulacao

 
