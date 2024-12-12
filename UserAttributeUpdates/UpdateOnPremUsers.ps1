# Import required module
Import-Module ActiveDirectory

# Path to the HR export CSV file
$inputCsvPath = "C:\temp\file.csv"

# Generate output folder with script name and date
$scriptName = "OnPremUserAttributeUpdate"
$dateStamp = (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")
$outputFolder = "C:\temp\$scriptName`_$dateStamp"

# Create the output folder
if (-Not (Test-Path $outputFolder)) {
    New-Item -ItemType Directory -Path $outputFolder | Out-Null
}

# Define output file paths
$outputCsvPath = "$outputFolder\OnPremUserUpdates.csv"
$notFoundCsvPath = "$outputFolder\UsersNotOnPrem.csv"

# Import the CSV file
if (-Not (Test-Path $inputCsvPath)) {
    Write-Host "Input CSV file not found at $inputCsvPath" -ForegroundColor Red
    exit
}

$users = Import-Csv -Path $inputCsvPath

# Initialize arrays to store results
$results = @()
$notFoundUsers = @()

# Loop through each email in the CSV
foreach ($user in $users) {
    $email = $user.Work_Email

    if (-not $email) {
        Write-Host "Skipping entry with missing Work_Email." -ForegroundColor Yellow
        continue
    }

    # Check if the user exists in Active Directory
    try {
        $adUser = Get-ADUser -Filter { (UserPrincipalName -eq $email)} -Properties GivenName, Surname, Title, Department, EmployeeID -ErrorAction Stop

        # Capture original values
        $originalTitle = $adUser.Title
        $originalDepartment = $adUser.Department
        $originalEmployeeID = $adUser.EmployeeID

        # Collect the updates to apply
        $updates = @{}

        # Overwrite Title even if it contains data
        $updates["Title"] = $user.Position

        # Overwrite Department even if it contains data
        $updates["Department"] = $user.Department_Desc

        # Overwrite EmployeeID even if it contains data
        $updates["EmployeeID"] = $user.Employee_Code

        # Apply updates if there are changes
        if ($updates.Count -gt 0) {
            Set-ADUser -Identity $adUser.DistinguishedName @updates
            $results += [PSCustomObject]@{
                Email             = $email
                GivenName         = $adUser.GivenName
                Surname           = $adUser.Surname
                OriginalTitle     = $originalTitle
                UpdatedTitle      = $user.Position
                OriginalDepartment= $originalDepartment
                UpdatedDepartment = $user.Department_Desc
                OriginalEmployeeID= $originalEmployeeID
                UpdatedEmployeeID = $user.Employee_Code
                Status            = "Updated"
                Changes           = ($updates.Keys -join ", ")
            }
            Write-Host "Updated user: $email" -ForegroundColor Green
        } else {
            $results += [PSCustomObject]@{
                Email             = $email
                GivenName         = $adUser.GivenName
                Surname           = $adUser.Surname
                OriginalTitle     = $originalTitle
                UpdatedTitle      = $originalTitle
                OriginalDepartment= $originalDepartment
                UpdatedDepartment = $originalDepartment
                OriginalEmployeeID= $originalEmployeeID
                UpdatedEmployeeID = $originalEmployeeID
                Status            = "No changes needed"
                Changes           = "None"
            }
        }

    } catch {
        # User does not exist, log the result
        $notFoundUsers += [PSCustomObject]@{
            Email = $email
        }
        Write-Host "User not found: $email" -ForegroundColor Red
    }
}

# Check if results contain data before exporting
if ($results.Count -gt 0) {
    # Export results to a CSV file
    $results | Export-Csv -Path $outputCsvPath -NoTypeInformation -Force
    Write-Host "Processing complete. Results exported to $outputCsvPath." -ForegroundColor Green
} else {
    Write-Host "No results to export." -ForegroundColor Yellow
}

# Export not found users to a separate CSV file
if ($notFoundUsers.Count -gt 0) {
    $notFoundUsers | Export-Csv -Path $notFoundCsvPath -NoTypeInformation -Force
    Write-Host "Users not found exported to $notFoundCsvPath. Use this file as unput for ExtractAzureUsers.ps1" -ForegroundColor Yellow
} else {
    Write-Host "No users were not found." -ForegroundColor Green
}
