try {
    $iterationMax = 10
    $groupName = $datasource.inputName
    $groupDescription = $description
     
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
     
        $fullpath = $ProjectFolderRootPath + "\" + $returnGroupName
        $returnGroupName = $ProjectFolderPrefix + $returnGroupName
        $found = Get-ADGroup -Filter {Name -eq $returnGroupName}
     
        if(@($found).count -eq 0) {
            Write-information "AD group [$returnGroupName] not found"
             
            if(!(Test-Path $fullPath)) {
                Write-information "ProjectFolder [$fullPath] not found"
     
                $returnObject = @{groupName=$returnGroupName; folderPath=$fullPath}
                break;
            } else {
                Write-information "ProjectFolder [$fullPath] found"
            }
        } else {
            Write-information "AD group [$returnGroupName] found"
        }
    }
     
     
    if(-not [string]::IsNullOrEmpty($returnObject)) {
        Write-output $returnObject
    }
 
} catch {
    Write-error "Error generating names for [$groupName]. Error: $($_.Exception.Message)"
    return
}
