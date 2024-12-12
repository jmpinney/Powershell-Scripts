#Readme

These scripts were made to take user data exported from HR software (paycom in this case) and update the Job Title and Department attributes in On-Prem AD/Hybrid users and Azure only users.

The First script, UpdateOnPremUsers.ps1 takes the HR export and finds AD users via their email address which happens to be their UPN in this case, and updates their attributes. This script then spits out a list of users that were updated, and what the old attribute values were and what they were updated to.
It also spits out a file containing the email addresses of users that were not found in AD.
