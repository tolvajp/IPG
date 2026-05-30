<#
.SYNOPSIS
Initializes IPG lab tenant test data.

.DESCRIPTION
This script prepares lab-only tenant data used by the IPG sample validation scenarios.

It can create or prepare test users, groups, and related assignment structures. Device objects are intentionally handled differently.

Mocking Intune managed devices is unreliable and usually not worth the effort. A useful managed device object depends on real enrollment, join state, Intune management, policy sync, and inventory data. Creating that state purely from PowerShell is painful and does not represent how Intune evaluates devices in practice.

For device validation scenarios, use real lab devices:
1. Prepare the required Windows test machines.
2. Join or register them according to the lab scenario.
3. Enroll them into Intune.
4. Wait until they appear as managed devices.
5. Add them to the required test groups.
6. Export the dataset after the tenant reflects the desired test state.

This script is a lab convenience tool, not production provisioning logic.

.NOTES
The IPG framework validates governance and assignment state. It does not attempt to manufacture realistic Intune managed device inventory from synthetic objects.
#>

Connect-MgGraph

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$PolicyJsonFolder = Join-Path -Path $PSScriptRoot -ChildPath 'PolicyJsons'
$UserPassword = 'ChangeMe-Temp-Passw0rd!'
$UserCount = 10

$DeviceNameHash = @{
    WorkstationScopeDevice01 = 'IL-1897'
    WorkstationScopeDevice02 = 'IL-6311'
    WorkstationScopeDevice03 = 'DESKTOP-1EQ6DG4'
    WorkstationScopeDevice04 = 'IL-7468'
    OutOfScopeDevice01       = 'DESKTOP-PH38D4G'
    ExtraDevice01            = 'DESKTOP-EHOJPQK'
    ExtraDevice02            = 'DESKTOP-IBBU3D7'
    ExtraDevice03            = 'DESKTOP-34QHN32'
}

if (-not (Test-Path -Path $PolicyJsonFolder -PathType Container)) {
    throw "PolicyJson folder not found: $PolicyJsonFolder"
}

$requiredModules = @(
    'Microsoft.Graph.Authentication',
    'Microsoft.Graph.Users',
    'Microsoft.Graph.Groups',
    'Microsoft.Graph.Identity.DirectoryManagement',
    'Microsoft.Graph.Identity.DirectoryManagement'
)

foreach ($module in $requiredModules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        throw "Required module not found: $module"
    }
}

Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Users
Import-Module Microsoft.Graph.Groups
Import-Module Microsoft.Graph.Identity.DirectoryManagement

$context = Get-MgContext
if (-not $context) {
    Connect-MgGraph -Scopes 'User.ReadWrite.All','Group.ReadWrite.All','GroupMember.ReadWrite.All','Device.Read.All','Organization.Read.All','DeviceManagementConfiguration.ReadWrite.All' -NoWelcome
}

$defaultDomain = (Get-MgOrganization).VerifiedDomains | Where-Object { $_.IsDefault -eq $true } | Select-Object -ExpandProperty Name -First 1

if ([string]::IsNullOrWhiteSpace($defaultDomain)) {
    throw "Default verified domain not found."
}

Write-Host "Default tenant domain: $defaultDomain"

function Get-OrCreateGroup {
    param (
        [Parameter(Mandatory)]
        [string]$DisplayName,

        [Parameter(Mandatory)]
        [string]$Description
    )

    $escapedDisplayName = $DisplayName.Replace("'", "''")
    $group = Get-MgGroup -Filter "displayName eq '$escapedDisplayName'" -ConsistencyLevel eventual -CountVariable groupCount -All | Select-Object -First 1

    if ($group) {
        return $group
    }

    New-MgGroup -DisplayName $DisplayName -Description $Description -MailEnabled:$false -MailNickname ($DisplayName -replace '[^a-zA-Z0-9]', '') -SecurityEnabled:$true
}

function Add-ObjectToGroup {
    param (
        [Parameter(Mandatory)]
        [string]$GroupId,

        [Parameter(Mandatory)]
        [string]$ObjectId
    )

    try {
        New-MgGroupMemberByRef -GroupId $GroupId -BodyParameter @{
            '@odata.id' = "https://graph.microsoft.com/v1.0/directoryObjects/$ObjectId"
        } | Out-Null
    }
    catch {
        if ($_.Exception.Message -notmatch 'added object references already exist|One or more added object references already exist') {
            throw
        }
    }
}

function Test-PropertyExists {
    param (
        [Parameter(Mandatory)]
        [object]$InputObject,

        [Parameter(Mandatory)]
        [string]$PropertyName
    )

    $null -ne ($InputObject.PSObject.Properties | Where-Object { $_.Name -eq $PropertyName } | Select-Object -First 1)
}

$groupDefinitions = @(
    @{ Name = 'ConfigurationPolicyScope-Workstation'; Description = 'IPG test device scope group - Workstation' },
    @{ Name = 'ConfigurationPolicyScope-Employee'; Description = 'IPG test user scope group - Employee' },
    @{ Name = 'ConfigurationPolicyScope-Admin'; Description = 'IPG test user scope group - Admin' },
    @{ Name = 'ConfigurationPolicyScope-Contractor'; Description = 'IPG test user scope group - Contractor' },
    @{ Name = 'IPG-Test-Audience-IT'; Description = 'IPG test audience group - IT' },
    @{ Name = 'IPG-Test-Audience-Finance'; Description = 'IPG test audience group - Finance' },
    @{ Name = 'IPG-Test-Audience-Legal'; Description = 'IPG test audience group - Legal' },
    @{ Name = 'IPG-Test-Audience-Empty'; Description = 'IPG test intentionally empty audience group' },
    @{ Name = 'IPG-Test-Audience-OutOfScope'; Description = 'IPG test audience group with out-of-scope member' },
    @{ Name = 'IPG-Test-Unrelated-Group'; Description = 'IPG test unrelated group for wrong exclude tests' }
)

$groups = @{}

foreach ($groupDefinition in $groupDefinitions) {
    $group = Get-OrCreateGroup -DisplayName $groupDefinition.Name -Description $groupDefinition.Description
    $groups[$group.DisplayName] = $group
    Write-Host "Group ready: $($group.DisplayName)"
}

$users = @()

foreach ($index in 1..$UserCount) {
    $userPrincipalName = "ipgtestuser$('{0:d2}' -f $index)@$defaultDomain"
    $displayName = "IPG Test User $('{0:d2}' -f $index)"

    $escapedUserPrincipalName = $userPrincipalName.Replace("'", "''")
    $user = Get-MgUser -Filter "userPrincipalName eq '$escapedUserPrincipalName'" -ConsistencyLevel eventual -CountVariable userCount -All | Select-Object -First 1

    if (-not $user) {
        $user = New-MgUser -AccountEnabled:$true -DisplayName $displayName -MailNickname "ipgtestuser$('{0:d2}' -f $index)" -UserPrincipalName $userPrincipalName -PasswordProfile @{
            forceChangePasswordNextSignIn = $true
            password = $UserPassword
        }
        Write-Host "User created: $userPrincipalName"
    }
    else {
        Write-Host "User exists: $userPrincipalName"
    }

    $users += $user
}

foreach ($user in $users[0..7]) {
    Add-ObjectToGroup -GroupId $groups['ConfigurationPolicyScope-Employee'].Id -ObjectId $user.Id
}

foreach ($user in $users[8..9]) {
    Add-ObjectToGroup -GroupId $groups['ConfigurationPolicyScope-Admin'].Id -ObjectId $user.Id
}

Add-ObjectToGroup -GroupId $groups['ConfigurationPolicyScope-Contractor'].Id -ObjectId $users[7].Id

Add-ObjectToGroup -GroupId $groups['IPG-Test-Audience-IT'].Id -ObjectId $users[0].Id
Add-ObjectToGroup -GroupId $groups['IPG-Test-Audience-IT'].Id -ObjectId $users[1].Id
Add-ObjectToGroup -GroupId $groups['IPG-Test-Audience-Finance'].Id -ObjectId $users[2].Id
Add-ObjectToGroup -GroupId $groups['IPG-Test-Audience-Legal'].Id -ObjectId $users[3].Id
Add-ObjectToGroup -GroupId $groups['IPG-Test-Audience-OutOfScope'].Id -ObjectId $users[9].Id
Add-ObjectToGroup -GroupId $groups['IPG-Test-Unrelated-Group'].Id -ObjectId $users[4].Id

$deviceCatalog = @{}

foreach ($deviceNameKey in $DeviceNameHash.Keys) {
    $deviceDisplayName = $DeviceNameHash[$deviceNameKey]

    if ([string]::IsNullOrWhiteSpace($deviceDisplayName)) {
        Write-Warning "Device name is empty for key: $deviceNameKey"
        continue
    }

    $escapedDeviceDisplayName = $deviceDisplayName.Replace("'", "''")
    $device = Get-MgDevice -Filter "displayName eq '$escapedDeviceDisplayName'" -ConsistencyLevel eventual -CountVariable deviceCount -All | Where-Object {
        $_.OperatingSystem -eq 'Windows' -and
        $_.AccountEnabled -eq $true
    } | Select-Object -First 1

    if (-not $device) {
        Write-Warning "Enabled Windows device not found: $deviceDisplayName"
        continue
    }

    $deviceCatalog[$deviceNameKey] = $device
}

foreach ($deviceNameKey in @('WorkstationScopeDevice01', 'WorkstationScopeDevice02', 'WorkstationScopeDevice03', 'WorkstationScopeDevice04')) {
    if (-not $deviceCatalog.ContainsKey($deviceNameKey)) {
        Write-Warning "Workstation scope device not resolved: $deviceNameKey"
        continue
    }

    Add-ObjectToGroup -GroupId $groups['ConfigurationPolicyScope-Workstation'].Id -ObjectId $deviceCatalog[$deviceNameKey].Id
    Write-Host "Device added to Workstation scope: $($deviceCatalog[$deviceNameKey].DisplayName)"
}

if ($deviceCatalog.ContainsKey('OutOfScopeDevice01')) {
    Add-ObjectToGroup -GroupId $groups['IPG-Test-Audience-OutOfScope'].Id -ObjectId $deviceCatalog['OutOfScopeDevice01'].Id
    Write-Host "Device added to out-of-scope test group: $($deviceCatalog['OutOfScopeDevice01'].DisplayName)"
}
else {
    Write-Warning "Out-of-scope device not resolved: OutOfScopeDevice01"
}

$policyFiles = Get-ChildItem -Path $PolicyJsonFolder -Filter '*.json' | Where-Object {
    $_.Name -ne 'manifest.json'
} | Sort-Object Name

if (-not $policyFiles) {
    throw "No policy JSON files found in $PolicyJsonFolder"
}

foreach ($policyFile in $policyFiles) {
    Write-Host "Importing policy JSON: $($policyFile.Name)"

    $policyJson = Get-Content -Path $policyFile.FullName -Raw | ConvertFrom-Json

    $bodyObject = [ordered]@{
        name = $policyJson.name
        description = $policyJson.description
        platforms = $policyJson.platforms
        technologies = $policyJson.technologies
        roleScopeTagIds = $policyJson.roleScopeTagIds
        templateReference = $policyJson.templateReference
        settings = $policyJson.settings
    }

    $body = $bodyObject | ConvertTo-Json -Depth 100

    $escapedPolicyName = $policyJson.name.Replace("'", "''")
    $existingPolicyUri = "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies?`$filter=name eq '$escapedPolicyName'"
    $existingPolicyResponse = Invoke-MgGraphRequest -Method GET -Uri $existingPolicyUri

    if ($existingPolicyResponse.value.Count -gt 0) {
        $policyId = $existingPolicyResponse.value[0].id
        Write-Host "Policy exists: $($policyJson.name)"
    }
    else {
        try {
            $createdPolicy = Invoke-MgGraphRequest -Method POST -Uri 'https://graph.microsoft.com/beta/deviceManagement/configurationPolicies' -Body $body -ContentType 'application/json'
            $policyId = $createdPolicy.id
            Write-Host "Policy created: $($policyJson.name)"
        }
        catch {
            Write-Warning "Policy import failed: $($policyJson.name)"
            Write-Warning $_.Exception.Message
            continue
        }
    }

    $assignmentTargets = @()

    if ((Test-PropertyExists -InputObject $policyJson -PropertyName 'assignmentTestMetadata') -and $policyJson.assignmentTestMetadata) {
        foreach ($assignment in $policyJson.assignmentTestMetadata) {
            if (-not (Test-PropertyExists -InputObject $assignment -PropertyName 'targetGroupDisplayName')) {
                continue
            }

            if (-not $groups.ContainsKey($assignment.targetGroupDisplayName)) {
                Write-Warning "Assignment group not found in catalog: $($assignment.targetGroupDisplayName)"
                continue
            }

            $assignmentType = 'Include'

            if ((Test-PropertyExists -InputObject $assignment -PropertyName 'assignmentType') -and -not [string]::IsNullOrWhiteSpace($assignment.assignmentType)) {
                $assignmentType = $assignment.assignmentType
            }

            $assignmentTargets += [pscustomobject]@{
                Group = $groups[$assignment.targetGroupDisplayName]
                AssignmentType = $assignmentType
            }
        }
    }
    elseif ($policyJson.name -match '^Workstation-') {
        $assignmentTargets += [pscustomobject]@{
            Group = $groups['ConfigurationPolicyScope-Workstation']
            AssignmentType = 'Include'
        }
    }
    elseif ($policyJson.name -match '^Employee-') {
        $assignmentTargets += [pscustomobject]@{
            Group = $groups['ConfigurationPolicyScope-Employee']
            AssignmentType = 'Include'
        }
    }
    elseif ($policyJson.name -match '^Admin-') {
        $assignmentTargets += [pscustomobject]@{
            Group = $groups['ConfigurationPolicyScope-Admin']
            AssignmentType = 'Include'
        }
    }
    elseif ($policyJson.name -match '^Contractor-') {
        $assignmentTargets += [pscustomobject]@{
            Group = $groups['ConfigurationPolicyScope-Contractor']
            AssignmentType = 'Include'
        }
    }

    if (-not $assignmentTargets) {
        Write-Warning "No assignment target resolved for policy: $($policyJson.name)"
        continue
    }

    $assignments = @()

    foreach ($assignmentTarget in $assignmentTargets) {
        $odataType = '#microsoft.graph.groupAssignmentTarget'

        if ($assignmentTarget.AssignmentType -eq 'Exclude') {
            $odataType = '#microsoft.graph.exclusionGroupAssignmentTarget'
        }

        $assignments += @{
            target = @{
                '@odata.type' = $odataType
                groupId = $assignmentTarget.Group.Id
            }
        }
    }

    $assignmentBody = @{
        assignments = $assignments
    } | ConvertTo-Json -Depth 20

    try {
        Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies('$policyId')/assign" -Body $assignmentBody -ContentType 'application/json' | Out-Null
        Write-Host "Policy assigned: $($policyJson.name)"
    }
    catch {
        Write-Warning "Policy assignment failed: $($policyJson.name)"
        Write-Warning $_.Exception.Message
    }
}

Write-Host "Done."