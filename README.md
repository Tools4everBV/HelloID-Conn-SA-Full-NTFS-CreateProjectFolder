# HelloID-Conn-SA-Full-NTFS-CreateProjectFolder
HelloID Service Automation Delegated Form for NTFS project folder creation including Active Directory security group and access rights


<!-- Description -->
## Description
This HelloID Service Automation Delegated Form provides NTFS project folder creation including Active Directory security group and access rights functionality. The following options are available:
 1. Enter project folder name
 2. Select available folder name and security group based on naming convention and lookup in Active Directory and the filesystem
 3. After confirmation the project folder is created, the Active Directory security group is created and the access rights are st
 
<!-- TABLE OF CONTENTS -->
## Table of Contents
* [Description](#description)
* [All-in-one PowerShell setup script](#all-in-one-powershell-setup-script)
  * [Getting started](#getting-started)
* [Post-setup configuration](#post-setup-configuration)
* [Manual resources](#manual-resources)


## All-in-one PowerShell setup script
The PowerShell script "createform.ps1" contains a complete PowerShell script using the HelloID API to create the complete Form including user defined variables, tasks and data sources.

 _Please note that this script asumes none of the required resources do exists within HelloID. The script does not contain versioning or source control_


### Getting started
Please follow the documentation steps on [HelloID Docs](https://docs.helloid.com/hc/en-us/articles/360017556559-Service-automation-GitHub-resources) in order to setup and run the All-in one Powershell Script in your own environment.

 
## Post-setup configuration
After the all-in-one PowerShell script has run and created all the required resources. The following items need to be configured according to your own environment
 1. Update the following [user defined variables](https://docs.helloid.com/hc/en-us/articles/360014169933-How-to-Create-and-Manage-User-Defined-Variables)
<table>
  <tr><td><strong>Variable name</strong></td><td><strong>Example value</strong></td><td><strong>Description</strong></td></tr>
  <tr><td>ProjectFolderRootPath</td><td>_projectFolders</td><td>Local path where the project folder is beeing created</td></tr>
  <tr><td>ProjectFolderPrefix</td><td>proj_</td><td>Prefix used for the Active Directory security group</td></tr>
</table>

## Manual resources
This Delegated Form uses the following resources in order to run

### Powershell data source 'NTFS-projectfolder-create-check-names'
This Powershell data source runs an Active Directory query and checks the filesystem for duplicate folder and security group name. The available names based on the configured naming convention are returned

### Delegated form task 'NTFS-projectfolder-create'
This delegated form task will create the project folder, Active Directory security group and set the access rights.
