try {
    $iterationMax = 10
    $groupName = $formInput.inputName
     
    function Remove-StringLatinCharacters
    {
        PARAM ([string]$String)
        [Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("Cyrillic").GetBytes($String))
    }
     
    $groupName = Remove-StringLatinCharacters $groupName
    $groupName = $groupName.trim() -replace '\s+', ' '
     
     
    for($i = 0; $i -lt $iterationMax; $i++) {   
        if($i -eq 0) {
            $returnGroupName = $groupName
        } else {
            $returnGroupName = $groupName + "_$i"
        }
     
        $fullpath = $folderRootPath + "\" + $returnGroupName
        $returnGroupName = $folderPefix + $returnGroupName
        $found = Get-ADGroup -Filter {Name -eq $returnGroupName}
     
        if(@($found).count -eq 0) {
            Hid-Write-Status -Message "AD group [$returnGroupName] not found" -Event Information
             
            if(!(Test-Path $fullPath)) {
                Hid-Write-Status -Message "ProjectFolder [$fullPath] not found" -Event Information
     
                $returnObject = @{groupName=$returnGroupName; folderPath=$fullPath}
                break;
            } else {
                Hid-Write-Status -Message "ProjectFolder [$fullPath] found" -Event Information
            }
        } else {
            Hid-Write-Status -Message "AD group [$returnGroupName] found" -Event Information
        }
    }
     
     
    if([string]::IsNullOrEmpty($returnObject)) {
        Hid-Add-TaskResult -ResultValue []
    } else {
        Hid-Add-TaskResult -ResultValue $returnObject
    }
 
} catch {
    HID-Write-Status -Message "Error generating names for [$groupName]. Error: $($_.Exception.Message)" -Event Error
    HID-Write-Summary -Message "Error generating names for [$groupName]" -Event Failed
     
    Hid-Add-TaskResult -ResultValue []
}