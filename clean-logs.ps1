#!/usr/bin/env pwsh
# Script to clean up old log files (older than 1 day)

param(
    [int]$DaysOld = 1,  # Delete logs older than this many days (default: 1)
    [switch]$DryRun,    # Show what would be deleted without actually deleting
    [switch]$All        # Delete all logs regardless of age
)

$projectRoot = $PSScriptRoot
$logsDir = Join-Path $projectRoot "logs"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  LOG CLEANUP UTILITY" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $logsDir)) {
    Write-Host "No logs directory found. Nothing to clean." -ForegroundColor Yellow
    Write-Host ""
    exit 0
}

if ($DryRun) {
    Write-Host "DRY RUN MODE - No files will be deleted" -ForegroundColor Yellow
    Write-Host ""
}

$cutoffDate = (Get-Date).AddDays(-$DaysOld)
$deletedCount = 0
$freedSpace = 0

function Remove-OldLogs {
    param(
        [string]$Directory,
        [string]$Label
    )
    
    if (-not (Test-Path $Directory)) {
        return
    }
    
    Write-Host "Scanning: $Label" -ForegroundColor Cyan
    
    if ($All) {
        $files = Get-ChildItem -Path $Directory -File -Recurse
        Write-Host "  Found: $($files.Count) files (all will be deleted)" -ForegroundColor White
    } else {
        $files = Get-ChildItem -Path $Directory -File -Recurse | Where-Object { $_.LastWriteTime -lt $cutoffDate }
        Write-Host "  Found: $($files.Count) files older than $DaysOld day(s)" -ForegroundColor White
    }
    
    if ($files.Count -eq 0) {
        Write-Host "  No files to delete" -ForegroundColor Gray
        Write-Host ""
        return
    }
    
    foreach ($file in $files) {
        $fileSize = $file.Length
        $script:freedSpace += $fileSize
        $fileSizeKB = [math]::Round($fileSize / 1KB, 2)
        $age = ((Get-Date) - $file.LastWriteTime).Days
        
        if ($DryRun) {
            Write-Host "  [DRY RUN] Would delete: $($file.Name) ($fileSizeKB KB, $age days old)" -ForegroundColor Gray
        } else {
            Write-Host "  Deleting: $($file.Name) ($fileSizeKB KB, $age days old)" -ForegroundColor Red
            Remove-Item -Path $file.FullName -Force
            $script:deletedCount++
        }
    }
    Write-Host ""
}

# Clean different log directories
Write-Host "Cleanup criteria:" -ForegroundColor Yellow
if ($All) {
    Write-Host "  Delete ALL logs" -ForegroundColor Red
} else {
    Write-Host "  Delete logs older than: $DaysOld day(s)" -ForegroundColor White
    Write-Host "  Cutoff date: $($cutoffDate.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Gray
}
Write-Host ""

# Clean backend logs
$backendLogsDir = Join-Path $logsDir "backend"
Remove-OldLogs -Directory $backendLogsDir -Label "Backend Logs (logs/backend/)"

# Clean frontend logs
$frontendLogsDir = Join-Path $logsDir "frontend"
Remove-OldLogs -Directory $frontendLogsDir -Label "Frontend Logs (logs/frontend/)"

# Clean live logs
$liveLogsDir = Join-Path $logsDir "live"
Remove-OldLogs -Directory $liveLogsDir -Label "Live Logs (logs/live/)"

# Clean snapshots
$snapshotsDir = Join-Path $logsDir "snapshots"
if (Test-Path $snapshotsDir) {
    Write-Host "Scanning: Snapshots (logs/snapshots/)" -ForegroundColor Cyan
    
    $snapshotDirs = Get-ChildItem -Path $snapshotsDir -Directory
    $oldSnapshots = @()
    
    if ($All) {
        $oldSnapshots = $snapshotDirs
        Write-Host "  Found: $($oldSnapshots.Count) snapshot directories (all will be deleted)" -ForegroundColor White
    } else {
        foreach ($dir in $snapshotDirs) {
            if ($dir.LastWriteTime -lt $cutoffDate) {
                $oldSnapshots += $dir
            }
        }
        Write-Host "  Found: $($oldSnapshots.Count) snapshot directories older than $DaysOld day(s)" -ForegroundColor White
    }
    
    if ($oldSnapshots.Count -gt 0) {
        foreach ($dir in $oldSnapshots) {
            $dirSize = (Get-ChildItem -Path $dir.FullName -Recurse | Measure-Object -Property Length -Sum).Sum
            $script:freedSpace += $dirSize
            $dirSizeKB = [math]::Round($dirSize / 1KB, 2)
            $age = ((Get-Date) - $dir.LastWriteTime).Days
            
            if ($DryRun) {
                Write-Host "  [DRY RUN] Would delete directory: $($dir.Name) ($dirSizeKB KB, $age days old)" -ForegroundColor Gray
            } else {
                Write-Host "  Deleting directory: $($dir.Name) ($dirSizeKB KB, $age days old)" -ForegroundColor Red
                Remove-Item -Path $dir.FullName -Recurse -Force
                $script:deletedCount++
            }
        }
    } else {
        Write-Host "  No directories to delete" -ForegroundColor Gray
    }
    Write-Host ""
}

# Clean summary files
$summaryFiles = Get-ChildItem -Path $logsDir -Filter "logs_summary_*.txt"
if ($All) {
    $oldSummaries = $summaryFiles
} else {
    $oldSummaries = $summaryFiles | Where-Object { $_.LastWriteTime -lt $cutoffDate }
}

if ($oldSummaries.Count -gt 0) {
    Write-Host "Scanning: Summary Files (logs/)" -ForegroundColor Cyan
    Write-Host "  Found: $($oldSummaries.Count) summary files" -ForegroundColor White
    
    foreach ($file in $oldSummaries) {
        $fileSize = $file.Length
        $script:freedSpace += $fileSize
        $fileSizeKB = [math]::Round($fileSize / 1KB, 2)
        $age = ((Get-Date) - $file.LastWriteTime).Days
        
        if ($DryRun) {
            Write-Host "  [DRY RUN] Would delete: $($file.Name) ($fileSizeKB KB, $age days old)" -ForegroundColor Gray
        } else {
            Write-Host "  Deleting: $($file.Name) ($fileSizeKB KB, $age days old)" -ForegroundColor Red
            Remove-Item -Path $file.FullName -Force
            $script:deletedCount++
        }
    }
    Write-Host ""
}

# Summary
Write-Host "========================================" -ForegroundColor Cyan
if ($DryRun) {
    Write-Host "  DRY RUN SUMMARY" -ForegroundColor Yellow
} else {
    Write-Host "  CLEANUP COMPLETE" -ForegroundColor Green
}
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$freedSpaceMB = [math]::Round($freedSpace / 1MB, 2)

if ($DryRun) {
    Write-Host "Would delete: $deletedCount items" -ForegroundColor Yellow
    Write-Host "Would free: $freedSpaceMB MB" -ForegroundColor Yellow
} else {
    if ($deletedCount -gt 0) {
        Write-Host "Deleted: $deletedCount items" -ForegroundColor Green
        Write-Host "Freed: $freedSpaceMB MB" -ForegroundColor Green
    } else {
        Write-Host "No files to delete" -ForegroundColor Gray
    }
}
Write-Host ""

if ($DryRun) {
    Write-Host "To actually delete these files, run without -DryRun:" -ForegroundColor Yellow
    Write-Host "  .\clean-logs.ps1" -ForegroundColor Gray
    Write-Host ""
}
