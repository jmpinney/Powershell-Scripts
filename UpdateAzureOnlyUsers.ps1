###### RUN EXTRACTAZUREUSERS.ps1 FIRST #####



# Import Microsoft Graph module
Import-Module Microsoft.Graph.Users



###### UPDATE THIS PATH BEFORE SCRIPT IS RAN #####
$inputCsvPath = "C:\temp\ExtractedAzureUsers.csv" # Path to the input CSV file from ExtractAzureUsers.ps1

# Generate output folder with script name and date
$scriptName = "GraphAPIUserAttributeUpdate"
$dateStamp = (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")
$outputFolder = "C:\temp\$scriptName`_$dateStamp"

# Create the output folder
if (-Not (Test-Path $outputFolder)) {
    New-Item -ItemType Directory -Path $outputFolder | Out-Null
}

# Define output file paths
$outputCsvPath = "$outputFolder\UpdatedAzureUsers.csv"
$notFoundCsvPath = "$outputFolder\UsersNotInAzureAD.csv"

# Import the CSV file
if (-Not (Test-Path $inputCsvPath)) {
    Write-Host "Input CSV file not found at $inputCsvPath" -ForegroundColor Red
    exit
}

$users = Import-Csv -Path $inputCsvPath

# Initialize arrays to store results
$results = @()
$notFoundUsers = @()

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.ReadWrite.All" -ErrorAction Stop

# Loop through each email in the CSV
foreach ($user in $users) {
    $email = $user.Work_Email

    if (-not $email) {
        Write-Host "Skipping entry with missing Work_Email." -ForegroundColor Yellow
        continue
    }

    # Check if the user exists in Microsoft Graph
    try {
        $graphUser = Get-MgUser -Filter "userPrincipalName eq '$email'" -ErrorAction Stop

        # Capture original values
        $originalTitle = $graphUser.JobTitle
        $originalDepartment = $graphUser.Department

        # Update Job Title if needed
        if ($graphUser.JobTitle -ne $user.Position) {
            Update-MgUser -UserId $graphUser.Id -JobTitle $user.Position
        }

        # Update Department if needed
        if ($graphUser.Department -ne $user.Department_Desc) {
            Update-MgUser -UserId $graphUser.Id -Department $user.Department_Desc
        }

        $results += [PSCustomObject]@{
            Email             = $email
            DisplayName       = $graphUser.DisplayName
            OriginalTitle     = $originalTitle
            UpdatedTitle      = $user.Position
            OriginalDepartment= $originalDepartment
            UpdatedDepartment = $user.Department_Desc
            Status            = "Updated"
        }
        Write-Host "Updated user: $email" -ForegroundColor Green

    } catch {
        # User does not exist, log the result
        $notFoundUsers += [PSCustomObject]@{
            Email = $email
        }
        Write-Host "User not found in Microsoft Graph: $email" -ForegroundColor Red
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
    Write-Host "Users not found on prem or in azure exported to $notFoundCsvPath." -ForegroundColor Yellow
} else {
    Write-Host "No users were not found." -ForegroundColor Green
}
