#Readme

These scripts were made to take user data exported from HR software (paycom in this case) and update the Job Title and Department attributes for both On-Prem AD/Hybrid users and Azure only users.

The First script, UpdateOnPremUsers.ps1 takes the HR export and finds AD users via their email address which happens to be their UPN in this case, and updates their attributes. This script then spits out a list of users that were updated, and what the old attribute values were and what they were updated to.

It also spits out a file containing the email addresses of users that were not found in the on-prem AD. This file is used as the input for UpdateAzureOnlyUsers.ps1, which does the same thing as the first script, just for Azure only users, and also outputs a list of users that were not found in Azure either. These are likely users that HR has the wrong information for, users that haven't been onboarded yet, or users that were already offboarded and deleted but still exist in the HR system for whatever reason. 

The scripts are easily extendable to update more users attributes by mapping additional columns in the CSV file to specific AD attributes.
