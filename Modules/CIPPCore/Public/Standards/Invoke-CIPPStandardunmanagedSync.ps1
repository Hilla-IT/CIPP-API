function Invoke-CIPPStandardunmanagedSync {
    <#
    .FUNCTIONALITY
    Internal
    #>
    param($Tenant, $Settings)
    $CurrentInfo = New-GraphGetRequest -Uri 'https://graph.microsoft.com/beta/admin/sharepoint/settings' -tenantid $Tenant -AsApp $true

    If ($Settings.remediate -eq $true) {

        if ($CurrentInfo.isUnmanagedSyncAppForTenantRestricted -eq $false) {
            try {
                #$body = '{"isUnmanagedSyncAppForTenantRestricted": true}'
                #$null = New-GraphPostRequest -tenantid $tenant -Uri 'https://graph.microsoft.com/beta/admin/sharepoint/settings' -AsApp $true -Type patch -Body $body -ContentType 'application/json'
                Write-LogMessage -API 'Standards' -tenant $tenant -message 'The unmanaged Sync standard has been temporarily disabled.' -sev Info
            } catch {
                Write-LogMessage -API 'Standards' -tenant $tenant -message "Failed to disable Sync for unmanaged devices: $($_.exception.message)" -sev Error
            }
        } else {
            Write-LogMessage -API 'Standards' -tenant $tenant -message 'Sync for unmanaged devices is already disabled' -sev Info
        }
    }

    if ($Settings.alert -eq $true) {

        if ($CurrentInfo.isUnmanagedSyncAppForTenantRestricted -eq $true) {
            Write-LogMessage -API 'Standards' -tenant $tenant -message 'Sync for unmanaged devices is disabled' -sev Info
        } else {
            Write-LogMessage -API 'Standards' -tenant $tenant -message 'Sync for unmanaged devices is not disabled' -sev Alert
        }
    }

    if ($Settings.report -eq $true) {
        Add-CIPPBPAField -FieldName 'unmanagedSync' -FieldValue [bool]$CurrentInfo.isUnmanagedSyncAppForTenantRestricted -StoreAs bool -Tenant $tenant
    }
}
