function Start-VaultServerBackup {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [int]
        $Version,

        [Parameter(Mandatory = $true)]
        [string]
        $Username,

        [Parameter(Mandatory = $true)]
        [string]
        $Password,
     
        [Parameter(Mandatory = $true)]
        [string]
        $BackupRoot,
     
        [Parameter(Mandatory = $true)]
        [string]
        $StorageRoot
    )

    $localBackupPath = Join-Path $BackupRoot "A"
    $localBackupLogPath = Join-Path $BackupRoot "backuplog.txt"
    $primaryStoragePath = Join-Path $StorageRoot "A"
    $secondaryStoragePath = Join-Path $StorageRoot "B"
    
    $processName = "Connectivity.ADMSConsole.exe"
    $command = "C:\Program Files\Autodesk\Vault Server $Version\ADMS Console\$processName"
    $arguments = "-Obackup -B`"$BackupRoot`" -VU`"$Username`" -VP`"$Password`" -VAL -S -L`"$localBackupLogPath`""

    Write-Host "Stopping Vault server"
    Stop-Process -Name $processName -ErrorAction SilentlyContinue

    Write-Host "Cascading backups"

    if (Test-Path $secondaryStoragePath) {
        Write-Host " - Deleting secondary backup (B)"
        Remove-Item $secondaryStoragePath -Recurse -Force
    } else {
        Write-Warning "Secondary storage path $secondaryStoragePath does not exist"
    }

    if (Test-Path $primaryStoragePath) {
        Write-Host " - Renaming primary backup (A) to secondary backup (B)"
        Rename-Item $primaryStoragePath $secondaryStoragePath
    } else {
        Write-Warning "Primary storage path $primaryStoragePath does not exist"
    }

    if (Test-Path $command) {
        Write-Host "Running Vault server backup"
        Start-Process -FilePath $command -ArgumentList $arguments -Wait
    } else {
        Write-Error "Vault server $Version is not installed"
        return
    }

    if (Test-Path $localBackupPath) {
        Write-Host "Copying backup to storage"
        Copy-Item $localBackupPath $primaryStoragePath
    } else {
        Write-Error "Backup not found in $localBackupPath"
        return
    }

    if (Test-Path $localBackupLogPath) {
        Write-Host "Copying backup log to storage"
        Copy-Item $localBackupLogPath $primaryStoragePath
    } else {
        Write-Error "Backup log not found at $localBackupLogPath"
    }

    Write-Host "Deleting local backup"
    Remove-Item $BackupRoot -Recurse -Force
}