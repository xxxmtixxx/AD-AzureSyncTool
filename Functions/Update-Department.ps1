﻿# Functions\Update-Department.ps1

# Function to update Department from Azure AD to AD
function Update-DepartmentFromAzureADToAD {
    param (
        [PSCustomObject]$currentItem,
        [string]$source = "Button",  # Default source is Button; can also be CSV
        [bool]$SuppressNotifications = $false
    )

    try {
        # Ensure the current item is not null
        Ensure-CurrentItemNotNull -currentItem $currentItem

        # Extract relevant values from the current item based on the source
        $email = $currentItem.AzureAD_EmailAddress
        $desiredDepartment = if ($source -eq "Button") { $currentItem.AzureAD_Department } else { $currentItem.AD_Department }

        Write-Log "Updating Department from Azure AD to AD. Source: $source, Email: $email, Desired Department: $desiredDepartment"
        Write-Host "Updating Department from Azure AD to AD. Source: $source, Email: $email, Desired Department: $desiredDepartment"

        # Get the AD user by email address
        $adUser = Get-ADUser -Filter { EmailAddress -eq $email } -Properties Department -ErrorAction Stop
        if ($adUser) {
            # Update the AD user's Department with the intended value
            Set-ADUser -Identity $adUser -Replace @{Department = $desiredDepartment}
            Write-Log "Updated Department for AD user: $($adUser.Name). New: $desiredDepartment"
            Write-Host "Updated Department for AD user: $($adUser.Name) to $desiredDepartment"

            # Show a notification if not suppressed and source is from Button
            if (-not $SuppressNotifications -and $source -eq "Button") {
                [System.Windows.Forms.MessageBox]::Show("Updated Department for AD user: $($adUser.Name)", "Update Complete", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            }
        } else {
            Write-Log "AD user not found for email: $email"
            Write-Host "AD user not found for email: $email"
        }
    } catch {
        Write-Log "Failed to update Department for AD user. Error: $($_.Exception.Message)"
        Write-Host "Failed to update Department for AD user. Error: $($_.Exception.Message)"
    }
}

# Function to update Department from AD to Azure AD
function Update-DepartmentFromADToAzureAD {
    param (
        [PSCustomObject]$currentItem,
        [string]$source = "Button",  # Default source is Button; can also be CSV
        [bool]$SuppressNotifications = $false
    )

    try {
        # Ensure the current item is not null
        Ensure-CurrentItemNotNull -currentItem $currentItem

        # Extract relevant values from the current item based on the source
        $email = $currentItem.AzureAD_EmailAddress
        $desiredDepartment = if ($source -eq "Button") { $currentItem.AD_Department } else { $currentItem.AzureAD_Department }

        Write-Log "Updating Department from AD to Azure AD. Source: $source, Email: $email, Desired Department: $desiredDepartment"
        Write-Host "Updating Department from AD to Azure AD. Source: $source, Email: $email, Desired Department: $desiredDepartment"

        # Get the Azure AD user by email address
        $azureUser = Get-AzureADUser -Filter "UserPrincipalName eq '$email'" -ErrorAction Stop
        if ($azureUser) {
            # Update the Azure AD user's Department with the intended value
            Set-AzureADUser -ObjectId $azureUser.ObjectId -Department $desiredDepartment
            Write-Log "Updated Department for Azure AD user: $($azureUser.DisplayName). New: $desiredDepartment"
            Write-Host "Updated Department for Azure AD user: $($azureUser.DisplayName) to $desiredDepartment"

            # Show a notification if not suppressed and source is from Button
            if (-not $SuppressNotifications -and $source -eq "Button") {
                [System.Windows.Forms.MessageBox]::Show("Updated Department for Azure AD user: $($azureUser.DisplayName)", "Update Complete", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            }
        } else {
            Write-Log "Azure AD user not found for email: $email"
            Write-Host "Azure AD user not found for email: $email"
        }
    } catch {
        Write-Log "Failed to update Department for Azure AD user. Error: $($_.Exception.Message)"
        Write-Host "Failed to update Department for Azure AD user. Error: $($_.Exception.Message)"
    }
}