#Initialize default properties
$p = $person | ConvertFrom-Json
Write-Verbose -verbose $person
$success = $False
$auditMessage = "Account for person " + $p.DisplayName + " not disabled succesfully"

#Initialize SQL properties
$config = $configuration | ConvertFrom-Json 
$sqlInstance = $config.connection.server
$sqlDatabase = $config.connection.database

$sqlConnectionString = "Server=$sqlInstance;Database=$sqlDatabase;Trusted_Connection=True;"

try {
    #Change mapping here
    $account = @{
        Personeelsnummer                        = $p.ExternalId
        Burgerservicenummer                     = $p.ExternalId
        Achternaam_geboortenaam                 = $p.Name.FamilyName    
        Voorvoegsel_geboortenaam                = $p.Name.FamilyNamePrefix
        Voorletters                             = $p.Name.Initials
        Roepnaam                                = $p.Name.NickName
        Achternaam_partnernaam                  = $p.Name.FamilyNamePartner
        Voorvoegsel_partnernaam                 = $p.Name.FamilyNamePartnerPrefix
        Gebruik_naam                            = $p.Custom.PlanCareGebruikNaam
        Naam_volledig                           = $p.Custom.PlanCareNaamVolledig
        Achternaam                              = $p.Custom.PlanCareAchternaam
        Voorvoegsel                             = $p.Custom.PlanCareVoorvoegsel
        Achternaam_init_voorvoegsel             = $p.Custom.PlanCareNaamVolledig
        Achternaam_init_voorvoegsel_voornaam    = $p.Custom.PlanCareAchternaamInitVoorvoegselVoornaam
        Achternaam_init_voorvoegsel_roepnaam    = $p.Custom.PlanCareAchternaamInitVoorvoegselVoornaam
        Geslacht                                = $p.Details.Gender
        Email                                   = $p.Accounts.MicrosoftActiveDirectory.mail
        Geboortedatum                           = $null
        Straat                                  = $null
        Toev_voor_straat                        = $null
        Huisnummer                              = $null
        Toev_aan_huisnr                         = $null
        Postcode                                = $null
        Woonplaats                              = $null
        Burgerlijke_staat                       = $null
        Telefoonnr_werk                         = $p.Contact.Business.Phone.Fixed
        Telefoonnr_prive                        = $null
        Mobiel_werk                             = $p.Contact.Business.Phone.Mobile
        Mobiel_prive                            = $null
        Datum_in_dienst                         = $p.PrimaryContract.Custom.PlanCareContractStartDate
        Datum_uit_dienst                        = $p.PrimaryContract.Custom.PlanCareContractEndDate
        SSOUsername                             = $p.Accounts.MicrosoftActiveDirectory.SamAccountName
    }

    # Remove employments older than 180 days
    $activePost = 180
    $now = (get-date).Date
    $planCareContracts = New-Object System.Collections.Generic.List[System.Object]
    foreach ($contract in $p.contracts)
    {
        if ([string]::IsNullOrEmpty($contract.Custom.PlanCareContractEndDate) -or ([datetime]$($contract.Custom.PlanCareContractEndDate)).addDays($activePost) -gt $now)
        {
            $planCareContract = @{
                Personeelsnummer                 = $p.ExternalId
                DV                               = $contract.Details.Sequence
                Functiecode                      = $contract.Custom.PlanCareFunctionId
                Functienaam                      = $contract.Custom.PlanCareFunctionName
                Kostenplaatscode                 = $contract.CostCenter.Code
                Kostenplaatsomschrijving         = $contract.CostCenter.Name
                Percentage_verdeling             = $contract.Custom.PlanCareFte
                #Begindatum_contract              = $contract.Custom.PlanCareContractStartDate
                #Einddatum_contract               = $contract.Custom.PlanCareContractEndDate
                Begindatum_contract              = $contract.Custom.PlanCarePositionStartDate
                Einddatum_contract               = $contract.Custom.PlanCarePositionEndDate
                Begindatum_functieregel          = $contract.Custom.PlanCarePositionStartDate
                Einddatum_functieregel           = $contract.Custom.PlanCarePositionEndDate
                Parttime_percentage              = 0
                OEcode                           = $contract.Team.Code
                OEomschrijving                   = $contract.Team.Name
                Uitsluiten_Plancare              = 0
            }
        
            $planCareContracts.Add($planCareContract)
        }
    }


    #Sanity check
    if ($planCareContracts.count -eq 0) { 
        throw "PlanCare contracts cannot be 0 for ($aRef)"
    }

    $queryPersonLookup = "SELECT Personeelsnummer FROM [$sqlDatabase].[implementation].[HRM_Import_Medewerker] WHERE Personeelsnummer = @Personeelsnummer"

    $queryPersonCreate = "INSERT INTO [$sqlDatabase].[implementation].[HRM_Import_Medewerker] (
                        [Personeelsnummer],
                        [Burgerservicenummer],
                        [Achternaam_geboortenaam],
                        [Voorletters],
                        [Roepnaam],
                        [Achternaam_partnernaam],
                        [Voorvoegsel_partnernaam],
                        [Gebruik_naam],
                        [Naam_volledig],
                        [Achternaam],
                        [Voorvoegsel],
                        [Achternaam_init_voorvoegsel],
                        [Achternaam_init_voorvoegsel_voornaam],
                        [Achternaam_init_voorvoegsel_roepnaam],
                        [Geslacht],
                        [Email],
                        [Geboortedatum],
                        [Straat],
                        [Toev_voor_straat],
                        [Huisnummer],
                        [Toev_aan_huisnr],
                        [Postcode],
                        [Woonplaats],
                        [Burgerlijke_staat],
                        [Telefoonnr_werk],
                        [Telefoonnr_prive],
                        [Mobiel_werk],
                        [Mobiel_prive],
                        [Datum_in_dienst],
                        [Datum_uit_dienst],
                        [SSOUsername]
                    ) 
                    VALUES (
                        @Personeelsnummer,
                        @Burgerservicenummer,
                        @Achternaam_geboortenaam,
                        @Voorletters,
                        @Roepnaam,
                        @Achternaam_partnernaam,
                        @Voorvoegsel_partnernaam,
                        @Gebruik_naam,
                        @Naam_volledig,
                        @Achternaam,
                        @Voorvoegsel,
                        @Achternaam_init_voorvoegsel,
                        @Achternaam_init_voorvoegsel_voornaam,
                        @Achternaam_init_voorvoegsel_roepnaam,
                        @Geslacht,
                        @Email,
                        @Geboortedatum,
                        @Straat,
                        @Toev_voor_straat,
                        @Huisnummer,
                        @Toev_aan_huisnr,
                        @Postcode,
                        @Woonplaats,
                        @Burgerlijke_staat,
                        @Telefoonnr_werk,
                        @Telefoonnr_prive,
                        @Mobiel_werk,
                        @Mobiel_prive,
                        @Datum_in_dienst,
                        @Datum_uit_dienst,
                        @SSOUsername
                    );"
                
    $queryPersonUpdate = "UPDATE [$sqlDatabase].[implementation].[HRM_Import_Medewerker] 
                            SET               
                                [Personeelsnummer] = @Personeelsnummer,
                                [Burgerservicenummer] = @Burgerservicenummer,
                                [Achternaam_geboortenaam] = @Achternaam_geboortenaam,
                                [Voorletters] = @Voorletters,
                                [Roepnaam] = @Roepnaam,
                                [Achternaam_partnernaam] = @Achternaam_partnernaam,
                                [Voorvoegsel_partnernaam] = @Voorvoegsel_partnernaam,
                                [Gebruik_naam] = @Gebruik_naam,
                                [Naam_volledig] = @Naam_volledig,
                                [Achternaam] = @Achternaam,
                                [Voorvoegsel] = @Voorvoegsel,
                                [Achternaam_init_voorvoegsel] = @Achternaam_init_voorvoegsel,
                                [Achternaam_init_voorvoegsel_voornaam] = @Achternaam_init_voorvoegsel_voornaam,
                                [Achternaam_init_voorvoegsel_roepnaam] = @Achternaam_init_voorvoegsel_roepnaam,
                                [Geslacht] = @Geslacht,
                                [Email] = @Email,
                                [Geboortedatum] = @Geboortedatum,
                                [Straat] = @Straat,
                                [Toev_voor_straat] = @Toev_voor_straat,
                                [Huisnummer] = @Huisnummer,
                                [Toev_aan_huisnr] = @Toev_aan_huisnr,
                                [Postcode] = @Postcode,
                                [Woonplaats] = @Woonplaats,
                                [Burgerlijke_staat] = @Burgerlijke_staat,
                                [Telefoonnr_werk] = @Telefoonnr_werk,
                                [Telefoonnr_prive] = @Telefoonnr_prive,
                                [Mobiel_werk] = @Mobiel_werk,
                                [Mobiel_prive] = @Mobiel_prive,
                                [Datum_in_dienst] = @Datum_in_dienst,
                                [Datum_uit_dienst] = @Datum_uit_dienst,
                                [SSOUsername] = @SSOUsername
                            WHERE Personeelsnummer = @Personeelsnummer;"


    $queryContractsDelete = "DELETE FROM [$sqlDatabase].[implementation].[HRM_Import_Dienstverband] WHERE Personeelsnummer = @Personeelsnummer"

    $queryContractCreate = "INSERT INTO [$sqlDatabase].[implementation].[HRM_Import_Dienstverband] (
                                [Personeelsnummer],
                                [DV],
                                [Functiecode],
                                [Functienaam],
                                [Kostenplaatscode],
                                [Kostenplaatsomschrijving],
                                [Percentage_verdeling],
                                [Begindatum_contract],
                                [Einddatum_contract],
                                [Begindatum_functieregel],
                                [Einddatum_functieregel],
                                [Parttime_percentage],
                                [OEcode],
                                [OEomschrijving],
                                [Uitsluiten_Plancare]
                            ) 
                            VALUES (
                                @Personeelsnummer,
                                @DV,
                                @Functiecode,
                                @Functienaam,
                                @Kostenplaatscode,
                                @Kostenplaatsomschrijving,
                                @Percentage_verdeling,
                                @Begindatum_contract,
                                @Einddatum_contract,
                                @Begindatum_functieregel,
                                @Einddatum_functieregel,
                                @Parttime_percentage,
                                @OEcode,
                                @OEomschrijving,
                                @Uitsluiten_Plancare
                            );"

    # Connect to the SQL server
    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $sqlConnection.ConnectionString = $sqlConnectionString
    $sqlConnection.Open()
       
    #Lookup record
    $sqlCmd = New-Object System.Data.SqlClient.SqlCommand
    $sqlCmd.Connection = $sqlConnection
    $sqlCmd.CommandText = $queryPersonLookup
    $account.Keys | Foreach-Object { $null = $sqlCmd.Parameters.Add("@" + $_, "$($account.Item($_))") }
       
    # Execute the command against the database without returning results (NonQuery). 
    $personExists = $SqlCmd.ExecuteReader()
    $lookupResult = @()
    while ($personExists.Read()) {
        $lookupResult += $personExists["Personeelsnummer"]
    }
    $personExists.Close()

    # Check if an create or update should be executed
    if ($lookupResult.count -eq 0) {
        $queryPerson = $queryPersonCreate
        Write-Verbose -Verbose "Person record does not exist. Creating person record for employeeId '$($p.externalId)'"
    } else {
        # detect if there's one record, or more. if one record, then update, if more records, then throw error
        if ($lookupResult.count -eq 1)  {
            $queryPerson = $queryPersonUpdate
            Write-Verbose -Verbose "Person record exists. Updating person record for employeeId '$($p.externalId)'" 
        } else {
            throw "Multiple ($($lookupResult.count) person records found with employeeId '$($p.externalId)'"
        }
    }
    
    #Do not execute when running preview
    if (-Not($dryRun -eq $True)) {

        # Run person query
        $sqlCmd = New-Object System.Data.SqlClient.SqlCommand;
        $sqlCmd.Connection = $sqlConnection;
        $sqlCmd.CommandText = $queryPerson;
        $account.Keys | Foreach-Object { $null = $sqlCmd.Parameters.Add("@" + $_, "$($account.Item($_))") }
        $null = $SqlCmd.ExecuteNonQuery()

        # Run delete contracts query
        $sqlCmd = New-Object System.Data.SqlClient.SqlCommand;
        $sqlCmd.Connection = $sqlConnection;
        $sqlCmd.CommandText = $queryContractsDelete;
        $planCarecontract.Keys | Foreach-Object { $null = $sqlCmd.Parameters.Add("@" + $_, "$($planCarecontract.Item($_))") }
        $null = $SqlCmd.ExecuteNonQuery()
        
        # Loop through and insert a row for each contract
        foreach ($planCareContract in $planCareContracts) {
            $sqlCmd = New-Object System.Data.SqlClient.SqlCommand
            $sqlCmd.Connection = $sqlConnection
            $sqlCmd.CommandText = $queryContractCreate
            $planCarecontract.Keys | Foreach-Object { $null = $sqlCmd.Parameters.Add("@" + $_, "$($planCarecontract.Item($_))") }
            $null = $SqlCmd.ExecuteNonQuery()
        }
        Write-Verbose -Verbose "Written $($planCareContracts.count) contracts for employeeId '$($p.externalId)'"
        $accountReference = $p.ExternalId # correlation id = externalId
        $success = $True
        $auditMessage = " succesfully"
        Write-Verbose -Verbose "Updated person record for employeeId '$($p.externalId)' succesfully"
    }
} catch {
    $auditMessage = " not updated succesfully: General error";
    if (![string]::IsNullOrEmpty($_.ErrorDetails.Message)) {
        Write-Verbose -Verbose "Something went wrong $($_.ScriptStackTrace). Error message: '$($_.ErrorDetails.Message)'" 
        $auditMessage = " not updated succesfully: '$($_.ErrorDetails.Message)'"
    } else {
        Write-Verbose -Verbose "Something went wrong $($_.ScriptStackTrace). Error message: '$($_)'" 
        $auditMessage = " not updated succesfully: '$($_)'" 
    }        
} finally {
    $sqlConnection.Close()
}

#build up result
$result = [PSCustomObject]@{ 
    Success          = $success;
    AccountReference = $accountReference;
    AuditDetails     = $auditMessage;
    Account          = $account;
    
    # Optionally return data for use in other systems
    ExportData = [PSCustomObject]@{};
};

Write-Output $result | ConvertTo-Json -Depth 10