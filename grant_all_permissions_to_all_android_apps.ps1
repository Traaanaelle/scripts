$ADBPath = "C:\Android\adb.exe"

# Connect your Android device via USB and enable USB debugging

# Get the list of all installed packages
$packageList = & $ADBPath shell pm list packages -3

# Iterate through each package and grant ungranted permissions
foreach ($packageLine in $packageList) {
    $packageName = $packageLine.Split(":")[1].Trim()

    # Get the list of permissions for the package
    $permissionsList = & $ADBPath shell dumpsys package $packageName | Select-String -Pattern "android.permission"

    # Iterate through each permission and grant it to the package if not already granted and available
    foreach ($permissionLine in $permissionsList) {
        $permission = $permissionLine -replace '.*permission=(.*?)\\s.*', '$1'

        # Check if the permission is already granted for the package
        $isGranted = $permissionLine -like "*granted=true*"
        if (-not $isGranted) {
            # Check if the permission is available for the package
            $isAvailable = $permissionLine -match "flags=\[.*"
            if ($isAvailable) {
                $command = "$ADBPath shell pm grant `"$packageName`" `"$permission`""

                try {
                    # Grant the permission to the package
                    Write-Host "Executing command: $command"
                    & cmd.exe /c $command
                    Write-Host "Permission '$permission' granted to package '$packageName'"
                } catch {
                    Write-Host "Error granting permission '$permission' to package '$packageName': $_"
                }
            } else {
                Write-Host "Permission '$permission' is not available for package '$packageName'"
            }
        } else {
            Write-Host "Permission '$permission' is already granted for package '$packageName'"
        }
    }
}
