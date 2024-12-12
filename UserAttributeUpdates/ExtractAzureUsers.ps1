##### RUN UpdateOnPremUsers.ps1 first #####
# Paths to input CSV files

##### UPDATE THESE PATHS BEFORE SCRIPT IS RAN ######
$emailsCsvPath = "C:\temp\OnPremUserAttributeUpdate_2024-12-12\UsersNotOnPrem.csv" #UsersNotOnPrem.csv export from UpdateOnPremUsers.ps1
$dataCsvPath = "C:\temp\file.csv" # HR Paycom Export CSV used in previous script

# Path to output CSV
$outputCsvPath = "C:\temp\ExtractedAzureUsers.csv"

# Import CSVs
if (-Not (Test-Path $emailsCsvPath)) {
    Write-Host "Emails CSV not found at $emailsCsvPath" -ForegroundColor Red
    exit
}
if (-Not (Test-Path $dataCsvPath)) {
    Write-Host "Data CSV not found at $dataCsvPath" -ForegroundColor Red
    exit
}

$emailsToMatch = Import-Csv -Path $emailsCsvPath
$dataCsv = Import-Csv -Path $dataCsvPath

# Get the list of emails from the first CSV
$emailsList = $emailsToMatch.email # Adjusted for the "email" column in EmailsToMatch.csv

# Filter rows from the second CSV where the work_email matches
$matchedRows = $dataCsv | Where-Object { $emailsList -contains $_.work_email } # Adjusted for the "work_email" column in Data.csv

# Export matched rows to output CSV
if ($matchedRows.Count -gt 0) {
    $matchedRows | Export-Csv -Path $outputCsvPath -NoTypeInformation -Force
    Write-Host "Matched rows exported to $outputCsvPath use this as input for UpdateAzureUsers.ps1." -ForegroundColor Green
} else {
    Write-Host "No matches found between the CSVs" -ForegroundColor Yellow
}
