
###Usage###
## .\Parse-Netstat.ps1 -inputFile "C:\path\to\file.txt" ##
## https://github.com/jmpinney ##




param (
    [string]$inputFile
)

# Check if input file is provided
if (-not $inputFile) {
    Write-Error "Please provide the input filename as an argument."
    exit 1
}

# Define the output file path
$outputFile = [System.IO.Path]::ChangeExtension($inputFile, ".csv")

# Read the lines from the input file
$lines = Get-Content $inputFile

# Define a regex pattern to match the connection lines
$pattern = "^\s*(TCP|UDP)\s+(\S+)\s+(\S+)\s+(\S+)"

# Initialize an array to hold the parsed data
$data = @()

# Process each line
foreach ($line in $lines) {
    if ($line -match $pattern) {
        $proto = $matches[1]
        $localAddress = $matches[2]
        $foreignAddress = $matches[3]
        $state = $matches[4]

        # Create an object for each connection
        $obj = [PSCustomObject]@{
            Protocol        = $proto
            LocalAddress    = $localAddress
            ForeignAddress  = $foreignAddress
            State           = $state
        }

        # Add the object to the data array
        $data += $obj
    }
}

# Export the data to a CSV file
$data | Export-Csv -Path $outputFile -NoTypeInformation

Write-Output "CSV file created at: $outputFile"
