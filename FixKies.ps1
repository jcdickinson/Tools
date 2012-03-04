function Fix-Kies()
{
    # Kies Configuration Fix
    $key = Get-Item HKCU:\Software\Samsung\Kies2.0
    $values = Get-ItemProperty $key.PSPath
    $installPath = $values.InstallPath
    Push-Location $installPath

    # Find the configuration files.
    # Only EXE configs are affected.
    $configs = Get-ChildItem -Filter '*.exe.config' -Recurse

    foreach ($config in $configs)
    {
        Write-Host "Checking $path."
            
        $path = $config.DirectoryName + '\' + $config.Name
        
        $save = 0
        $content = [xml](Get-Content $path)

        # Remove the supportedRuntime element if it's 4.0.    
        foreach ($runtime in $content.configuration.startup.supportedRuntime)
        {
            $version = $runtime.version -eq 'v4.0'
            if ($version)
            {
                $content.configuration.startup.RemoveChild($runtime)
                $save = 1
            }
        }
        
        # Only save and make a backup if we made changes.
        if ($save -eq 1)
        {
            $backupPath = $path + '.backup'
            Copy-Item $path -Destination $backupPath -Force
            $content.Save($path)
            Write-Host "Fixed $path."
        }
    }

    Pop-Location
}

Fix-Kies  