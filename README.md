# Tools
Ferramentas para encurtar tarefas repetitivas.

# 🗑️ Script de Limpeza de Perfis de Usuário Windows

Script PowerShell para remover perfis de usuários do Windows mantendo apenas perfis especificados.

## 📋 Pré-requisitos
- PowerShell executado como **Administrador**
- Windows 10/11 ou Windows Server
- Permissões de administrador no sistema

## ⚠️ Avisos Importantes
- **Usuários não podem estar logados** nos perfis que serão removidos
- Dados serão **permanentemente excluídos**

## 🚀 Como Usar

### 1. Edite a lista de perfis a manter
```powershell
$Manter = @("Administrador","Public","Teste")
```

### Rota Regedit

```Erik
Computador\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\
```

### Test Conexão

```Powershell
Test-WSMan PC-NAME

