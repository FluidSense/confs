# Script for automating https://docs.microsoft.com/en-us/windows/wsl/install-win10
# By https://github.com/FluidSense

# if not elevated process
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
  # Relaunch as an elevated process:
  Start-Process powershell.exe "-File",('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
  exit
}
echo "Running WSL Installation as Administrator"
If ([System.Environment]::OSVersion.Version.Build -ge 20262) {
    # Versions at or above 20262 comes with wsl installation script, run that instead of continuing
    echo "Windows Version should ship with WSL installation, defaulting to shipped version."
    wsl --install
}
Else {
    $RegPath = "HKCU:\Software\PersonalConfigWSLSetup"
    If (-Not (Test-Path $RegPath)) {
        echo "Enabling program state..."
        New-Item -Path $RegPath -Value "Init"
    }
    $RetryAttempts = 0
    $CurrentState = (Get-ItemProperty -Path $RegPath).'(default)'
    While($RetryAttempts -le 1) {
        Switch($CurrentState) {
            "Init" 
            {
                echo "Enabling Windows Features needed for WSL"
                Start-Sleep -Seconds 1
                dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
                Set-Item -Path $RegPath -Value "DismRestarting"
                dism.exe /online /enable-feature /quiet /featurename:VirtualMachinePlatform /all
                Break
            }
            "DismRestarting" 
            {
                echo "Running from state after reboot"
                Start-Sleep -Seconds 1
                $WSLEnabledInfo = Get-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux"
                $VMPlatformInfo = Get-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform"
                If(-Not $WSLEnabledInfo.State -or -Not $WSLEnabledInfo.State) {
                # Last step failed, go back
                    Set-Item -Path $RegPath -Value "Init"
                    # Unexpected return to while-start, increase retryAttempts
                    $RetryAttemps++
                    Break
                }
                echo "Installing WSL driver"
                Start-Sleep -Seconds 1
                $TmpLocation = "{0}\AppData\Local\Temp\wsl_update_x64.msi" -f $env:USERPROFILE
                    Try {
                    Invoke-WebRequest https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi -OutFile $TmpLocation
                    Start-Process $TmpLocation -Wait
                    Remove-Item $TmpLocation
                } 
                Catch {
                    Write-Error $_
                    $RetryAttempts++
                    Break
                }
                wsl --set-default-version 2
                Set-Item -Path $RegPath -Value "Finished"
                Break
            }
            "Finished" 
            {
                echo "WSL2 Installation complete! Download your favorite distro from the Windows Store."
                Read-Host -Prompt "Press any key to exit.."
                exit
            }
            Default 
            {
                echo "Program state unrecognized. Retrying..."
                $RetryAttempts++
                Break;
            }
        }
    }
    If($RetryAttempts -gt 1) {
        Write-Error "Retried WSL Installation too many times. Failed at enabling features through DISM."
        Read-Host -Prompt "Press any key to exit.."
        exit
    }
}