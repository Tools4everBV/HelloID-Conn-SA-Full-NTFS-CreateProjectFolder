try {
    $projectFolder = New-Item -path $projectFolderPath -ItemType Directory -force -ea Stop
 
    Hid-Write-Status -Message "Succesfully created projectFolder [$projectFolderPath]" -Event Success
    HID-Write-Summary -Message "Succesfully created projectFolder [$projectFolderPath]" -Event Success
 
    try {
        $adGroup = New-ADGroup -Name $groupName -Description $groupDescription -GroupScope Global -GroupCategory Security -Path $createOU
 
        Hid-Write-Status -Message "Succesfully created AD group [$groupName]" -Event Success
        Hid-Write-Summary -Message "Succesfully created AD group [$groupName]" -Event Success
        try {
            $acl = Get-Acl $projectFolderPath
            $acl.SetAccessRuleProtection($False, $False)
 
            #add security group for this folder and all children
            $newRule = New-Object System.Security.AccessControl.FileSystemAccessRule("$groupName","Modify", "ContainerInherit, ObjectInherit", "None", "Allow")
            $acl.AddAccessRule($newRule)
 
            Set-Acl $projectFolderPath $acl
 
            Hid-Write-Status -Message "Succesfully updated projectFolder permissions" -Event Success
            Hid-Write-Summary -Message "Succesfully updated projectFolder permissions" -Event Success
        } catch {
            Hid-Write-Status -Message "Error updating projectFolder permissions. Error: $($_.Exception.Message)" -Event Error
            Hid-Write-Summary -Message "Could not update projectFolder permissions" -Event Failed
        }
    } catch {
        Hid-Write-Status -Message "Error creating AD group [$groupName]. Error: $($_.Exception.Message)" -Event Error
        Hid-Write-Summary -Message "Could not create AD group [$groupName]" -Event Failed
    }
} catch {
    Hid-Write-Status -Message "Could not create projectFolder [$projectFolderPath]. Error: $($_.Exception.Message)" -Event Error
    Hid-Write-Summary -Message "Error creating projectFolder [$projectFolderPath]" -Event Failed
}