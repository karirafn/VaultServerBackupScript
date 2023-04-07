Import-Module "$($PSScriptRoot)\VaultServerModule.psm1" -Force

Start-VaultServerBackup -Version 2021 -Username "Administrator" -Password "" -BackupRoot "C:\VaultBackup" -StorageRoot "C:\VaultBackupStorage"