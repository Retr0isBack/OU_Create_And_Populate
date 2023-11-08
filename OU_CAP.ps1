# Import active directory module for running AD cmdlets
Import-Module ActiveDirectory

# Create an OU subfolder when transferring userdate from an old OU to a new OU 
$NewOU = #For Example the old OU name + Users so for ex. StuttgartUsers or TimbuktuUsers
#The created OU can be further custimozed with a ton of given parameters . A full list of all currently useable parameters : https://learn.microsoft.com/en-us/powershell/module/activedirectory/new-adorganizationalunit?view=windowsserver2022-ps
# Specify the OU Path for future Usage
$OUPath = 'OU=$NewOU,DC=XYZ,DC=XYZ'
New-ADOrganizationalUnit -Name $NewOU -Path "DC=XYZ,DC=XYZ"
  
# Store the data from NewUsersFinal.csv in the $ADUsers variable
$ADUsers = Import-Csv "XYZ:\xyz\xyz.csv" #-Delimiter ";"
#Delimiter can be necessary. By current knowledge - not needed except for special cases 
# Define UPN
$UPN = "XYZ"

# Loop through each row containing user details in the CSV file
foreach ($User in $ADUsers) {

    # Read user data from each field in each row and assign the data to a variable as below
    $username = $User.username
    $password = $User.password # This line can obviously also be used to give all new users one premade PW
    $firstname = $User.firstname
    $lastname = $User.lastname
    $initials = $User.initials
    $email = $User.email
    $streetaddress = $User.streetaddress
    $city = $User.city
    $zipcode = $User.zipcode
    $state = $User.state
    $country = $User.country
    $telephone = $User.telephone
    $jobtitle = $User.jobtitle
    $company = $User.company
    $department = $User.department

    # Check to see if the user already exists in AD
    if (Get-ADUser -Filter  -SearchBase $OUPath "SamAccountName -eq '$username'") {
        
        # If user does exist, give a warning
        Write-Warning "A user account with username $username already exists in this Organizational Unit."
    }
    else {

        # User does not exist then proceed to create the new user account
        # Account will be created in the OU provided by the $OU variable read from the CSV file
        New-ADUser `
            -SamAccountName $username `
            -UserPrincipalName "$username@$UPN" `
            -Name "$firstname $lastname" `
            -GivenName $firstname `
            -Surname $lastname `
            -Initials $initials `
            -Enabled $True `
            -DisplayName "$firstname $lastname" `
            -Path $NewOU `
            -City $city `
            -PostalCode $zipcode `
            -Country $country `
            -Company $company `
            -State $state `
            -StreetAddress $streetaddress `
            -OfficePhone $telephone `
            -EmailAddress $email `
            -Title $jobtitle `
            -Department $department `
            -AccountPassword (ConvertTo-secureString $password -AsPlainText -Force) -ChangePasswordAtLogon $True

        # If user is created, show message.
        Write-Host "The user account $username is created." -ForegroundColor Cyan
    }
}

pause
