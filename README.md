# Personal configs
Configs and similar for personal use


# Winsetup
Setup-file for clean Windows-installations, for developing with .NET-core and JS
Prompts for admin rights, installs chocolatey, then installs .NET-core, Visual Studio and Node.

# Windows Terminal - WSL 
I have yet to automate this setup, perhaps I will the next time I have to set up my coding environment.

My preference is using the Windows Terminal with Zsh, Spaceship-prompt and FiraCode.

### Update Windows
This is the first, most time-consuming step. You need a recent version of Windows 10 for both security reasons and for WSL 2 to work.
CMD: `usoclient.exe ScanInstallWait RestartDevice ResumeUpdate` could perhaps work, but I have yet to test it.
https://social.technet.microsoft.com/Forums/en-US/fbc6bf0e-e1e0-4868-9af1-735f60e4ead8/usoclient?forum=win10itprogeneral


### WSL
https://docs.microsoft.com/en-us/windows/wsl/install-win10  
PowerShell: `dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart`
PowerShell: `dism.exe /online /enable-feature /quiet /featurename:VirtualMachinePlatform /all` Note: This will force a reboot.  
PowerShell: `wsl --set-default-version 2`

Afterwards, install the desired Distro from Windows Store. This seems to be perhaps the hardest part to script.

### Install FiraCode
https://github.com/tonsky/FiraCode/wiki/Installing
FiraCode is delivered through Chocolatey, but I have yet to get this to work as intended. 

### Windows Terminal, settings.json
```json
  {
      "guid": "[The-generated-UUID]",
      "hidden": false,
      "name": "Ubuntu-20.04",
      "source": "Windows.Terminal.Wsl",
      "fontFace": "Fira Code"
  }
```
