#HelloID variables
$PortalBaseUrl = "https://CUSTOMER.helloid.com"
$apiKey = "API_KEY"
$apiSecret = "API_SECRET"
$delegatedFormAccessGroupName = "Users"
 
# Create authorization headers with HelloID API key
$pair = "$apiKey" + ":" + "$apiSecret"
$bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
$base64 = [System.Convert]::ToBase64String($bytes)
$key = "Basic $base64"
$headers = @{"authorization" = $Key}
# Define specific endpoint URI
if($PortalBaseUrl.EndsWith("/") -eq $false){
    $PortalBaseUrl = $PortalBaseUrl + "/"
}
 
 
 
$variableName = "ProjectFolderCreateOU"
$variableGuid = ""
  
try {
    $uri = ($PortalBaseUrl +"api/v1/automation/variables/named/$variableName")
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false
  
    if([string]::IsNullOrEmpty($response.automationVariableGuid)) {
        #Create Variable
        $body = @{
            name = "$variableName";
            value = 'OU=HelloIDCreated,OU=Groups,OU=Enyoi,DC=enyoi-media,DC=local';
            secret = "false";
            ItemType = 0;
        }
  
        $body = $body | ConvertTo-Json
  
        $uri = ($PortalBaseUrl +"api/v1/automation/variable")
        $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false -Body $body
        $variableGuid = $response.automationVariableGuid
    } else {
        $variableGuid = $response.automationVariableGuid
    }
  
    $variableGuid
} catch {
    $_
}
  
  
  
$variableName = "ProjectFolderPrefix"
$variableGuid = ""
  
try {
    $uri = ($PortalBaseUrl +"api/v1/automation/variables/named/$variableName")
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false
  
    if([string]::IsNullOrEmpty($response.automationVariableGuid)) {
        #Create Variable
        $body = @{
            name = "$variableName";
            value = 'proj_';
            secret = "false";
            ItemType = 0;
        }
  
        $body = $body | ConvertTo-Json
  
        $uri = ($PortalBaseUrl +"api/v1/automation/variable")
        $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false -Body $body
        $variableGuid = $response.automationVariableGuid
    } else {
        $variableGuid = $response.automationVariableGuid
    }
  
    $variableGuid
} catch {
    $_
}
 
 
 
 
$variableName = "ProjectFolderRootPath"
$variableGuid = ""
  
try {
    $uri = ($PortalBaseUrl +"api/v1/automation/variables/named/$variableName")
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false
  
    if([string]::IsNullOrEmpty($response.automationVariableGuid)) {
        #Create Variable
        $body = @{
            name = "$variableName";
            value = 'C:\_projectFolders';
            secret = "false";
            ItemType = 0;
        }
  
        $body = $body | ConvertTo-Json
  
        $uri = ($PortalBaseUrl +"api/v1/automation/variable")
        $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false -Body $body
        $variableGuid = $response.automationVariableGuid
    } else {
        $variableGuid = $response.automationVariableGuid
    }
  
    $variableGuid
} catch {
    $_
}
  
  
  
  
$taskName = "NTFS-projectfolder-create-check-names"
$taskNTFScheckNamesGuid = ""
  
try {
    $uri = ($PortalBaseUrl +"api/v1/automationtasks?search=$taskName&container=1")
    $response = (Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false) | Where-Object -filter {$_.name -eq $taskName}
  
    if([string]::IsNullOrEmpty($response.automationTaskGuid)) {
        #Create Task
  
        $body = @{
            name = "$taskName";
            useTemplate = "false";
            powerShellScript = @'
try {
    $iterationMax = 10
    $groupName = $formInput.inputName
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
'@;
            automationContainer = "1";
            variables = @(@{name = "folderPefix"; value = "{{variable.ProjectFolderPrefix}}"; typeConstraint = "string"; secret = "False"},
                          @{name = "folderRootPath"; value = "{{variable.ProjectFolderRootPath}}"; typeConstraint = "string"; secret = "False"})
        }
        $body = $body | ConvertTo-Json
  
        $uri = ($PortalBaseUrl +"api/v1/automationtasks/powershell")
        $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false -Body $body
        $taskNTFScheckNamesGuid = $response.automationTaskGuid
  
    } else {
        #Get TaskGUID
        $taskNTFScheckNamesGuid = $response.automationTaskGuid
    }
} catch {
    $_
}
  
$taskNTFScheckNamesGuid
  
  
  
$dataSourceName = "NTFS-projectfolder-create-check-names"
$dataSourceNTFScheckNamesGuid = ""
  
try {
    $uri = ($PortalBaseUrl +"api/v1/datasource/named/$dataSourceName")
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false
  
    if([string]::IsNullOrEmpty($response.dataSourceGUID)) {
        #Create DataSource
        $body = @{
            name = "$dataSourceName";
            type = "3";
            model = @(@{key = "folderPath"; type = 0}, @{key = "groupName"; type = 0});
            automationTaskGUID = "$taskNTFScheckNamesGuid";
            input = @(@{description = ""; translateDescription = "False"; inputFieldType = "1"; key = "inputName"; type = "0"; options = "1"})
        }
        $body = $body | ConvertTo-Json
  
        $uri = ($PortalBaseUrl +"api/v1/datasource")
        $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false -Body $body
          
        $dataSourceNTFScheckNamesGuid = $response.dataSourceGUID
    } else {
        #Get DatasourceGUID
        $dataSourceNTFScheckNamesGuid = $response.dataSourceGUID
    }
} catch {
    $_
}
  
$dataSourceNTFScheckNamesGuid
  
 
 
  
$formName = "NTFS - Create Project Folder"
$formGuid = ""
  
try
{
    try {
        $uri = ($PortalBaseUrl +"api/v1/forms/$formName")
        $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false
    } catch {
        $response = $null
    }
  
    if(([string]::IsNullOrEmpty($response.dynamicFormGUID)) -or ($response.isUpdated -eq $true))
    {
        #Create Dynamic form
        $form = @"
[
  {
    "label": "Details",
    "fields": [
      {
        "key": "name",
        "templateOptions": {
          "label": "Project name",
          "required": true,
          "minLength": 6,
          "pattern": "^[A-Za-z0-9._-]{6,30}$",
          "placeholder": ""
        },
        "validation": {
          "messages": {
            "pattern": "Allowed Characters: a-z 0-9 . _ - \\nMinimal 6, Maximal 30 characters"
          }
        },
        "type": "input",
        "summaryVisibility": "Hide element",
        "requiresTemplateOptions": true
      },
      {
        "key": "description",
        "templateOptions": {
          "label": "Description"
        },
        "type": "input",
        "summaryVisibility": "Show",
        "requiresTemplateOptions": true
      }
    ]
  },
  {
    "label": "Naming",
    "fields": [
      {
        "key": "naming",
        "templateOptions": {
          "label": "Available name",
          "required": true,
          "grid": {
            "columns": [
              {
                "headerName": "GroupName",
                "field": "groupName"
              },
              {
                "headerName": "FolderPath",
                "field": "folderPath"
              }
            ],
            "height": 300,
            "rowSelection": "single"
          },
          "dataSourceConfig": {
            "dataSourceGuid": "$dataSourceNTFScheckNamesGuid",
            "input": {
              "propertyInputs": [
                {
                  "propertyName": "inputName",
                  "otherFieldValue": {
                    "otherFieldKey": "name"
                  }
                }
              ]
            }
          },
          "useFilter": false
        },
        "type": "grid",
        "summaryVisibility": "Show",
        "requiresTemplateOptions": true
      }
    ]
  }
]
"@
  
        $body = @{
            Name = "$formName";
            FormSchema = $form
        }
        $body = $body | ConvertTo-Json
  
        $uri = ($PortalBaseUrl +"api/v1/forms")
        $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false -Body $body
  
        $formGuid = $response.dynamicFormGUID
    } else {
        $formGuid = $response.dynamicFormGUID
    }
} catch {
    $_
}
  
$formGuid
  
  
  
  
$delegatedFormAccessGroupGuid = ""
  
try {
    $uri = ($PortalBaseUrl +"api/v1/groups/$delegatedFormAccessGroupName")
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false
    $delegatedFormAccessGroupGuid = $response.groupGuid
} catch {
    $_
}
  
$delegatedFormAccessGroupGuid
  
  
  
$delegatedFormName = "NTFS - Create Project Folder"
$delegatedFormGuid = ""
  
try {
    try {
        $uri = ($PortalBaseUrl +"api/v1/delegatedforms/$delegatedFormName")
        $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false
    } catch {
        $response = $null
    }
  
    if([string]::IsNullOrEmpty($response.delegatedFormGUID)) {
        #Create DelegatedForm
        $body = @{
            name = "$delegatedFormName";
            dynamicFormGUID = "$formGuid";
            isEnabled = "True";
            accessGroups = @("$delegatedFormAccessGroupGuid");
            useFaIcon = "True";
            faIcon = "fa fa-folder-open";
        }  
  
        $body = $body | ConvertTo-Json
  
        $uri = ($PortalBaseUrl +"api/v1/delegatedforms")
        $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false -Body $body
  
        $delegatedFormGuid = $response.delegatedFormGUID
    } else {
        #Get delegatedFormGUID
        $delegatedFormGuid = $response.delegatedFormGUID
    }
} catch {
    $_
}
  
$delegatedFormGuid
  
  
  
  
$taskActionName = "NTFS-projectfolder-create"
$taskActionGuid = ""
  
try {
    $uri = ($PortalBaseUrl +"api/v1/automationtasks?search=$taskActionName&container=8")
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false
  
    if([string]::IsNullOrEmpty($response.automationTaskGuid)) {
        #Create Task
  
        $body = @{
            name = "$taskActionName";
            useTemplate = "false";
            powerShellScript = @'
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
'@;
            automationContainer = "8";
            objectGuid = "$delegatedFormGuid";
            variables = @(@{name = "createOU"; value = "{{variable.ProjectFolderCreateOU}}"; typeConstraint = "string"; secret = "False"},
                        @{name = "groupDescription"; value = "{{form.description}}"; typeConstraint = "string"; secret = "False"},
                        @{name = "groupName"; value = "{{form.naming.groupName}}"; typeConstraint = "string"; secret = "False"},
                        @{name = "projectFolderPath"; value = "{{form.naming.folderPath}}"; typeConstraint = "string"; secret = "False"});
        }
        $body = $body | ConvertTo-Json
  
        $uri = ($PortalBaseUrl +"api/v1/automationtasks/powershell")
        $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -ContentType "application/json" -Verbose:$false -Body $body
        $taskActionGuid = $response.automationTaskGuid
  
    } else {
        #Get TaskGUID
        $taskActionGuid = $response.automationTaskGuid
    }
} catch {
    $_
}
  
$taskActionGuid