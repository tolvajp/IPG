# Azure Automation execution

## Purpose

The IPG audit can be executed from Azure Automation to run governance checks on a recurring basis and send the result as an HTML email report.

The repository provides the audit logic, managed identity authentication support, result formatting, and mail body generation.

The Azure Automation Account, scheduling, sender mailbox, monitoring, and operational ownership are platform responsibilities and should be coordinated with the automation or cloud platform team.

## Execution model

The automated execution model is:

1. Azure Automation starts the runbook.
2. The runbook imports the IPG module.
3. The runbook connects to Microsoft Graph using the Automation Account managed identity.
4. The runbook executes the IPG audit.
5. The audit result is converted into an HTML mail body.
6. The runbook sends the HTML report by using Microsoft Graph `sendMail`.

The runbook should use managed identity authentication. Interactive authentication must not be used for scheduled execution.

## Runtime requirements

The Automation Account must provide a PowerShell runtime compatible with the IPG module.

Required runtime:

```text
PowerShell 7.2
```

Required Automation Account modules:

```text
IPG
Microsoft.Graph.Authentication
Microsoft.Graph.Groups
Microsoft.Graph.Beta.DeviceManagement
Microsoft.Graph.Users
Microsoft.Graph.DeviceManagement
```

Additional Microsoft Graph modules may be required if the audit scope is extended in the future.

## Managed identity requirements

The Automation Account must have a system-assigned or user-assigned managed identity.

The managed identity must receive Microsoft Graph application permissions required by the audit and mail delivery flow.

Required Microsoft Graph application permissions:

```text
DeviceManagementConfiguration.Read.All
DeviceManagementManagedDevices.Read.All
Group.Read.All
GroupMember.Read.All
User.ReadBasic.All
Device.Read.All
Mail.Send
```

The permissions must be granted as application permissions and admin consent must be completed.

## Sender mailbox requirement

Email delivery uses Microsoft Graph `sendMail`.

The sender must be an existing Exchange Online mailbox.

Example:

```text
ipg-alerts@contoso.com
```

The recipient can be an internal or external email address, subject to the tenant's Exchange Online mail flow and security policies.

Because `Mail.Send` application permission is powerful, production environments should restrict the managed identity to the intended sender mailbox by using the organization's preferred Exchange Online application access control model.

## Runbook logic

The runbook should keep platform-specific values outside the IPG module logic.

Typical runbook responsibilities:

```text
Import IPG module
Resolve the module-local configuration path
Capture the audit run time
Run the audit with managed identity authentication
Generate the HTML mail body
Send the email report through Microsoft Graph
```

Example runbook pattern:

```powershell
Import-Module IPG
Import-Module Microsoft.Graph.Authentication

$ErrorActionPreference = 'Stop'

$senderUserPrincipalName = 'ipg-alerts@contoso.com'
$recipientAddress = 'team@example.com'
$auditRunTime = Get-Date

$module = Get-Module IPG
$configPath = Join-Path -Path $module.ModuleBase -ChildPath 'Config/configuration.json'

try {
    $auditResult = Start-IPGConfigurationPolicyAudit -ConfigPath $configPath -AuthenticationMode ManagedIdentity -ErrorAction Stop
    $htmlBody = New-IPGAuditMailBody -AuditResult $auditResult -RunTime $auditRunTime
    $subject = "IPG audit result - $($auditRunTime.ToString('dd/MM/yyyy HH:mm'))"
}
catch {
    $errorMessage = $_.Exception.Message
    $errorType = $_.Exception.GetType().FullName
    $scriptStackTrace = $_.ScriptStackTrace
    $escapedErrorMessage = [System.Net.WebUtility]::HtmlEncode($errorMessage)
    $escapedErrorType = [System.Net.WebUtility]::HtmlEncode($errorType)
    $escapedScriptStackTrace = [System.Net.WebUtility]::HtmlEncode($scriptStackTrace)

    $subject = "IPG audit failed - $($auditRunTime.ToString('dd/MM/yyyy HH:mm'))"

    $htmlBody = @"
<html>
<body>
<h2>IPG audit failed</h2>

<p><strong>Run time:</strong> $($auditRunTime.ToString('dd/MM/yyyy HH:mm:ss'))</p>
<p><strong>Config path:</strong> $configPath</p>

<h3>Error type</h3>
<pre>$escapedErrorType</pre>

<h3>Error message</h3>
<pre>$escapedErrorMessage</pre>

<h3>Script stack trace</h3>
<pre>$escapedScriptStackTrace</pre>
</body>
</html>
"@
}

Connect-MgGraph -Identity -NoWelcome

$message = @{
    message = @{
        subject = $subject
        body = @{
            contentType = 'HTML'
            content     = $htmlBody
        }
        toRecipients = @(
            @{
                emailAddress = @{
                    address = $recipientAddress
                }
            }
        )
    }
    saveToSentItems = $false
}

Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/users/$senderUserPrincipalName/sendMail" -Body ($message | ConvertTo-Json -Depth 20) -ContentType 'application/json'
```

## Repository scope

The repository is responsible for:

```text
Audit logic
Configuration validation
Managed identity capable audit execution
HTML mail body generation
Documenting runtime and permission requirements
```

The repository is not responsible for:

```text
Provisioning the Automation Account
Owning the Azure schedule
Owning the sender mailbox
Owning tenant mail flow policies
Owning Azure Monitor alerting
Owning Exchange Online application access restrictions
```

These operational tasks should be handled by the appropriate automation, cloud platform, or messaging team.

## Validation expectations

Before scheduling the runbook, validate that:

```text
The IPG module imports successfully
The managed identity can connect to Microsoft Graph
The audit completes successfully
The HTML mail body is generated
The email is delivered successfully
The runbook output and failure state are visible in Azure Automation
```

After successful manual validation, the runbook can be linked to a recurring schedule according to the organization's operational requirements.