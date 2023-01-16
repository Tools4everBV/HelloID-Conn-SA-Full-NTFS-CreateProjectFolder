$createOU = $projectFolderCreateOu
$groupDescription = $form.description
$groupName = $form.naming.groupName
$projectFolderPath = $form.naming.folderPath

try {
    $projectFolder = New-Item -path $projectFolderPath -ItemType Directory -force -ea Stop 
    
    Write-Information "Succesfully created projectFolder [$projectFolderPath]"
    $Log = @{
        Action            = "CreateResource" # optional. ENUM (undefined = default) 
        System            = "FileSystem" # optional (free format text) 
        Message           = "Succesfully created projectFolder [$projectFolderPath]" # required (free format text) 
        IsError           = $false # optional. Elastic reporting purposes only. (default = $false. $true = Executed action returned an error) 
        TargetDisplayName = $projectFolderPath # optional (free format text) 
        TargetIdentifier  = "" # optional (free format text) 
    }
    #send result back  
    Write-Information -Tags "Audit" -MessageData $log
     
    try {
        $adGroup = New-ADGroup -Name $groupName -Description $groupDescription -GroupScope Global -GroupCategory Security -Path $createOU
 
        Write-Information "Succesfully created AD group [$groupName]"
        $Log = @{
            Action            = "CreateResource" # optional. ENUM (undefined = default) 
            System            = "ActiveDirectory" # optional (free format text) 
            Message           = "Succesfully created AD group [$groupName]" # required (free format text) 
            IsError           = $false # optional. Elastic reporting purposes only. (default = $false. $true = Executed action returned an error) 
            TargetDisplayName = $groupName # optional (free format text) 
            TargetIdentifier  = $createOU # optional (free format text) 
        }
        #send result back  
        Write-Information -Tags "Audit" -MessageData $log
        
        try {
            $acl = Get-Acl $projectFolderPath
            $acl.SetAccessRuleProtection($False, $False)
 
            #add security group for this folder and all children
            $newRule = [System.Security.AccessControl.FileSystemAccessRule]::new("$groupName","Modify", "ContainerInherit, ObjectInherit", "None", "Allow")
            $acl.AddAccessRule($newRule)
 
            Set-Acl $projectFolderPath $acl
 
           Write-Information "Succesfully updated projectFolder permissions"
           $Log = @{
                Action            = "UpdateResource" # optional. ENUM (undefined = default) 
                System            = "FileSystem" # optional (free format text) 
                Message           = "Succesfully updated projectFolder permissions" # required (free format text) 
                IsError           = $false # optional. Elastic reporting purposes only. (default = $false. $true = Executed action returned an error) 
                TargetDisplayName = $projectFolderPath # optional (free format text) 
                TargetIdentifier  = "'$groupName','Modify', 'ContainerInherit, ObjectInherit', 'None', 'Allow'" # optional (free format text) 
            }
            #send result back  
            Write-Information -Tags "Audit" -MessageData $log
            
        } catch {
            Write-Error "Error updating projectFolder permissions. Error: $($_.Exception.Message)"
            $Log = @{
                Action            = "UpdateResource" # optional. ENUM (undefined = default) 
                System            = "FileSystem" # optional (free format text) 
                Message           = "Could not update projectFolder permissions" # required (free format text) 
                IsError           = $true # optional. Elastic reporting purposes only. (default = $false. $true = Executed action returned an error) 
                TargetDisplayName = $projectFolderPath # optional (free format text) 
                TargetIdentifier  = "'$groupName','Modify', 'ContainerInherit, ObjectInherit', 'None', 'Allow'" # optional (free format text) 
            }
            #send result back  
            Write-Information -Tags "Audit" -MessageData $log            
        }
    } catch {
        Write-Error "Error creating AD group [$groupName]. Error: $($_.Exception.Message)"
        $Log = @{
            Action            = "CreateResource" # optional. ENUM (undefined = default) 
            System            = "ActiveDirectory" # optional (free format text) 
            Message           = "Could not create AD group [$groupName]" # required (free format text) 
            IsError           = $true # optional. Elastic reporting purposes only. (default = $false. $true = Executed action returned an error) 
            TargetDisplayName = $groupName # optional (free format text) 
            TargetIdentifier  = $createOU # optional (free format text) 
        }
        #send result back  
        Write-Information -Tags "Audit" -MessageData $log        
    }
} catch {
    Write-Error "Could not create projectFolder [$projectFolderPath]. Error: $($_.Exception.Message)"
    $Log = @{
        Action            = "CreateResource" # optional. ENUM (undefined = default) 
        System            = "FileSystem" # optional (free format text) 
        Message           = "Error creating projectFolder [$projectFolderPath]" # required (free format text) 
        IsError           = $true # optional. Elastic reporting purposes only. (default = $false. $true = Executed action returned an error) 
        TargetDisplayName = $projectFolderPath # optional (free format text) 
        TargetIdentifier  = "" # optional (free format text) 
    }
    #send result back  
    Write-Information -Tags "Audit" -MessageData $log    
}
