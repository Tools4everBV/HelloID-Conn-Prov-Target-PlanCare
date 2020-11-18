 #Initialize default properties
 $p = $person | ConvertFrom-Json
 $accountReference = $accountReference | ConvertFrom-Json
 
 $success = $False;
 $auditMessage = "Account for person " + $p.DisplayName + " not deleted succesfully"
 $verbose = $False
 
 #Initialize SQL properties
 $sqlInstance = "Plancare-sql-ota\plancare"
 $sqlDatabase = "t4plancare_2"
 
 $queryPersonDelete = "DELETE FROM [$sqlDatabase].[implementation].[HRM_Import_Medewerker] WHERE Personeelsnummer = @Personeelsnummer"
 $queryContractsDelete = "DELETE FROM [$sqlDatabase].[implementation].[HRM_Import_Dienstverband] WHERE Personeelsnummer = @Personeelsnummer"
 
 $account = @{ 
                Personeelsnummer = $accountReference 
             }
 
 Try {    
     #Import external module
     Import-Module dbatools #https://dbatools.io/
 
     #Do not execute when running preview
     if (-Not($dryRun -eq $True)) {
 
         # Run delete person query
         $null = Invoke-DbaQuery -SqlInstance $sqlInstance -Query $queryPersonDelete -SqlParameters $account -WarningAction Stop -ErrorAction Stop
 
         # Run delete contracts query
         $null = Invoke-DbaQuery -SqlInstance $sqlInstance -Query $queryContractsDelete -SqlParameters $account -WarningAction Stop -ErrorAction Stop
         
         $success      = $True
         $auditMessage = " succesfully"
         Write-Verbose -Verbose "Deleted person and contract records for employeeId '$($p.externalId)' succesfully"
     }
 }
 catch {
     $auditMessage = " not deleted succesfully: General error";
     $_
     if ($verbose) {
         $_
     }
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