$PerfisProtegidos = @("Administrador","Public","Arklok")
$Computadores = @("PC-001","PC-002")

$ModoSimulacao = $true   # coloque $false para remover de verdade

Invoke-Command -ComputerName $Computadores -ScriptBlock {

    param ($PerfisProtegidos, $ModoSimulacao)

    $ErrorActionPreference = "Stop"

    try {

        Write-Host "`n==== INICIANDO VERIFICAÇÃO EM $(hostname) ====" -ForegroundColor Cyan

        $perfis = Get-CimInstance Win32_UserProfile | Where-Object {

            $nomePerfil = Split-Path $_.LocalPath -Leaf

            $_.LocalPath -like "C:\Users\*" -and
            -not $_.Special -and
            -not $_.Loaded -and
            $PerfisProtegidos -notcontains $nomePerfil

        }

        if (-not $perfis) {
            Write-Host "Nenhum perfil elegível encontrado." -ForegroundColor Green
            return
        }

        foreach ($perfil in $perfis) {

            $nomePerfil = Split-Path $perfil.LocalPath -Leaf

            Write-Host "`nVerificando perfil: $nomePerfil" -ForegroundColor Yellow

            $perfilAtual = Get-CimInstance Win32_UserProfile -Filter "SID='$($perfil.SID)'"

            if ($perfilAtual.Loaded) {
                Write-Host "Perfil está carregado. Ignorado." -ForegroundColor Red
                continue
            }

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

    }
    catch {
        Write-Host "ERRO CRÍTICO NA EXECUÇÃO: $_" -ForegroundColor Red
    }

} -ArgumentList $PerfisProtegidos, $ModoSimulacao

