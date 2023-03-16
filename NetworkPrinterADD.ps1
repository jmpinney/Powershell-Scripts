<#  // Script to add predefined network printers to a Win10 PC. Different parts of my office use different printers and they have to be added manually. This helps it suck less.
   // The only lines that will have to be edited to work are the write-host menu items and the network paths to your printers.
  // Could be modified to iterate through a CSV/TXT containing a list of printers if you have a bunch to add
 // Author:JM Pinney (jp[at]7u.vc)

#>

#Create menu w/ options
function Show-Menu
{
    param (
        
        [string]$Title = 'Printers'
        )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Option 1."
    Write-Host "2: Option 2"
    Write-Host "3: Option 3"
    Write-Host "4: Option 4"
    Write-Host "5: Option 5"
    Write-Host "Q: Press 'Q' to quit."
}
#Get list of printers already on computer
$CurrentPrinters = Get-Printer

#Assigning menu choices to printer names
Show-Menu –Title 'Printers'
 $selection = Read-Host "Choose a printer to add"
 switch ($selection)
 {
       '1' {
        $Printer =  '\\server\printer1'
     } '2' {
        $Printer = '\server\printer2'
     } '3' {
        $Printer = '\server\printer3'
     } '4' {
        $Printer = '\server\printer4'
     } '5' {
        $Printer = '\server\printer5'

     } 'q' {
         return
     }
        default { 
        write-host "Unknown Option. Please try again and select an option from the list." -Foregroundcolor Red
         return }
    
 }
 
 #checks if printers are added already and skips adding if they are
 #If not, maps printer, then gets a list of printers on the computer, compares it to the original list and prints success if the difference matches the printer name
function AddPrinter {
    
    if ($Printer -in $CurrentPrinters.Name) 
        {
        Write-Host "$Printer already mapped!" -ForegroundColor Yellow
            #continue
        }
    else{
        Write-Host "Mapping printer $Printer" -ForegroundColor Magenta
        Add-Printer -ConnectionName $Printer

        $AddedPrinter = Compare-object -ReferenceObject $CurrentPrinters -DifferenceObject $UpdatedPrinters -PassThru | Select-Object Name

        if ($AddedPrinter = $Printer)
            {Write-Host "$Printer has been added successfully!" -ForegroundColor Green}
        else { Write-Host "Couldn't map $Printer. Time to do it manually."-ForegroundColor Red}
        }
        }

AddPrinter
