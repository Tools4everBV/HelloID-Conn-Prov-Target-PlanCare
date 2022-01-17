# HelloID-Conn-Prov-Target-PlanCare

| :information_source: Information |
|:---------------------------|
| This repository contains the connector and configuration code only. The implementer is responsible to acquire the connection details such as username, password, certificate, etc. You might even need to sign a contract or agreement with the supplier before implementing this connector. Please contact the client's application manager to coordinate the connector requirements.       |

<br />

## PlanCare SQL Dump connector

The powershell actions this script executes are resource intensive. Please make sure you configure the server accordingly.

## Plancare

The Plancare connector is a full export connector to two database tables: &#39;Implementation.HRM\_Import\_Medewerker&#39; and &#39;Implementation.HRM\_Import\_Dienstverband&#39;. 

It can also be used to export the data to the staging and test environments, which perform the same actions, but on different databases.

## Getting started

### Connector settings

The following custom connector settings are available and required:

| Setting     | Description |
| ------------ | ----------- |
| SQL Server/Instance | The server / instance where the plancare database resides |
| Database | The PlanCare database name |

### Prerequisites

- This connector requires an On-Premise HelloID Agent
- Using the HelloID On-Premises agent, Windows PowerShell 5.1 must be installed.
- Additional configuration is required in PlanCare. This is usually done by a PlanCare consultant.

### Supported PowerShell versions

The connector is created for Windows PowerShell 5.1. This means that the connector can not be executed in the cloud and requires an On-Premises installation of the HelloID Agent.

> Older versions of Windows PowerShell are not supported.

## Business Logic
The following business logic is configured in the default connector

### HR Data
- All persons with an employment contract that starts in 31 days are included in the report.
- All persons with active employment are included.
- All persons who have been inactive for a maximum of 30 days are included.
- The functions and departments are linked to the employment contracts.

### AD Data

- Only the AD accounts with a entered email address are included.
- Only the attributes sAMAccountName, mail and employeeId are retrieved.
- This data is based on the value in the 'employeeId' linked to the HR data. Only the linked data (common) is used.

### Database and export

- The databases are exported before each export.
- An addition or removal of a person or an employment will be audited.

## Custom source fields used in this connector

### Person.Custom.PlanCareAchternaam
```javascript
function getDisplayName() {
 
    let initials = source.voorletters_P00303;
    let firstName = source.roepnaam_P01003;
    let middleName = source.voorvoegsels_P00302;
    let lastName = source.geboortenaam_P00301;
    let middleNamePartner = source.voorvoegsels_P00391;
    let lastNamePartner = source.geboortenaam_P00390;
	let nameFormatted = "";
	
    switch(source.gebruikAchternaam_P00304) {
        case "E":
			nameFormatted = lastName;
			if (typeof middleName !== 'undefined' && middleName) { nameFormatted = nameFormatted + ' ' + middleName }
			break;
		case "P":
			nameFormatted = lastNamePartner;
			if (typeof middleNamePartner !== 'undefined' && middleNamePartner) { nameFormatted = nameFormatted + ' ' + middleNamePartner }
			break;
        case "C":
			nameFormatted = lastName + '-';
			if (typeof middleNamePartner !== 'undefined' && middleNamePartner) { nameFormatted = nameFormatted + middleNamePartner + ' ' }
			nameFormatted = nameFormatted + lastNamePartner;
			if (typeof middleName !== 'undefined' && middleName) { nameFormatted = nameFormatted + ' ' + middleName }
			break;
        case "B":
			nameFormatted = lastNamePartner + '-';
			if (typeof middleName !== 'undefined' && middleName) { nameFormatted = nameFormatted + middleName + ' ' }
			nameFormatted = nameFormatted + lastName;
			if (typeof middleNamePartner !== 'undefined' && middleNamePartner) { nameFormatted = nameFormatted + ' ' + middleNamePartner }
			break;
		default:
			nameFormatted = lastName;
			if (typeof middleName !== 'undefined' && middleName) { nameFormatted = nameFormatted + ' ' + middleName }
			break;
    }
    const displayName = nameFormatted.trim();
    
	return displayName;
}

getDisplayName();
```
### Person.Custom.PlanCareAchternaamInitVoorvoegselVoornaam
```javascript
function getDisplayName() {
 
    let initials = source.voorletters_P00303;
    let firstName = source.roepnaam_P01003;
    let middleName = source.voorvoegsels_P00302;
    let lastName = source.geboortenaam_P00301;
    let middleNamePartner = source.voorvoegsels_P00391;
    let lastNamePartner = source.geboortenaam_P00390;
    let nameFormatted = "";
	
    switch(source.gebruikAchternaam_P00304) {
        case "E":
			nameFormatted = lastName;
			nameFormatted = nameFormatted + ' ' + initials;
			if (typeof middleName !== 'undefined' && middleName) { nameFormatted = nameFormatted + ' ' + middleName }
			break;
		case "P":
			nameFormatted = lastNamePartner;
			nameFormatted = nameFormatted + ' ' + initials;
			if (typeof middleNamePartner !== 'undefined' && middleNamePartner) { nameFormatted = nameFormatted + ' ' + middleNamePartner }
			break;
        case "C":
			nameFormatted = lastName + '-';
			if (typeof middleNamePartner !== 'undefined' && middleNamePartner) { nameFormatted = nameFormatted + middleNamePartner + ' ' }
			nameFormatted = nameFormatted + lastNamePartner;
			nameFormatted = nameFormatted + ' ' + initials;
			if (typeof middleName !== 'undefined' && middleName) { nameFormatted = nameFormatted + ' ' + middleName }
			break;
        case "B":
			nameFormatted = lastNamePartner + '-';
			if (typeof middleName !== 'undefined' && middleName) { nameFormatted = nameFormatted + middleName + ' ' }
			nameFormatted = nameFormatted + lastName;
			nameFormatted = nameFormatted + ' ' + initials;
			if (typeof middleNamePartner !== 'undefined' && middleNamePartner) { nameFormatted = nameFormatted + ' ' + middleNamePartner }
			break;
		default:
			nameFormatted = lastName;
			nameFormatted = nameFormatted + ' ' + initials;
			if (typeof middleName !== 'undefined' && middleName) { nameFormatted = nameFormatted + ' ' + middleName }
			break;
    }
    nameFormatted = nameFormatted + ' ' + firstName;
    const displayName = nameFormatted.trim();
    
	return displayName;
}

getDisplayName();
```
### Person.Custom.PlanCareGebruikNaam
```javascript
function getValue() {
    if(source.gebruikAchternaam_P00304 == "P") {
        return "Geb. naam partner";
    }
    if(source.gebruikAchternaam_P00304 == "E") {
        return "Geboortenaam";
    }
    if(source.gebruikAchternaam_P00304 == "B") {
        return "Geb. naam partner + Geboortenaam";
    }
    if(source.gebruikAchternaam_P00304 == "C") {
        return "Geboortenaam + Geb. naam partner", "Geboortenaam";
    }
}

getValue();
```

### Person.Custom.PlanCareNaamVolledig
```javascript
function getDisplayName() {
 
    let initials = source.voorletters_P00303;
    let firstName = source.roepnaam_P01003;
    let middleName = source.voorvoegsels_P00302;
    let lastName = source.geboortenaam_P00301;
    let middleNamePartner = source.voorvoegsels_P00391;
    let lastNamePartner = source.geboortenaam_P00390;
    let nameFormatted = "";
	
    switch(source.gebruikAchternaam_P00304) {
        case "E":
			nameFormatted = lastName;
			nameFormatted = nameFormatted + ' ' + initials;
			if (typeof middleName !== 'undefined' && middleName) { nameFormatted = nameFormatted + ' ' + middleName }
			break;
		case "P":
			nameFormatted = lastNamePartner;
			nameFormatted = nameFormatted + ' ' + initials;
			if (typeof middleNamePartner !== 'undefined' && middleNamePartner) { nameFormatted = nameFormatted + ' ' + middleNamePartner }
			break;
        case "C":
			nameFormatted = lastName + '-';
			if (typeof middleNamePartner !== 'undefined' && middleNamePartner) { nameFormatted = nameFormatted + middleNamePartner + ' ' }
			nameFormatted = nameFormatted + lastNamePartner;
			nameFormatted = nameFormatted + ' ' + initials;
			if (typeof middleName !== 'undefined' && middleName) { nameFormatted = nameFormatted + ' ' + middleName }
			break;
        case "B":
			nameFormatted = lastNamePartner + '-';
			if (typeof middleName !== 'undefined' && middleName) { nameFormatted = nameFormatted + middleName + ' ' }
			nameFormatted = nameFormatted + lastName;
			nameFormatted = nameFormatted + ' ' + initials;
			if (typeof middleNamePartner !== 'undefined' && middleNamePartner) { nameFormatted = nameFormatted + ' ' + middleNamePartner }
			break;
		default:
			nameFormatted = lastName;
			nameFormatted = nameFormatted + ' ' + initials;
			if (typeof middleName !== 'undefined' && middleName) { nameFormatted = nameFormatted + ' ' + middleName }
			break;
    }
    nameFormatted = nameFormatted;
    const displayName = nameFormatted.trim();
    
	return displayName;
}

getDisplayName();
```
### Contract.Custom.PlanCareContractStartDate
Use the employement start date here (and not the position start date)
To parse a date use:
```Powershell
        Datum_in_dienst                         = [datetime]::parseexact($p.PrimaryContract.Custom.PlanCareContractStartDate, 'yyyy-MM-dd', $null)
```

### Contract.Custom.PlanCareContractEndDate
Use the employment end date here (and not the position start date)
To parse a date use:
```Powershell
        Datum_uit_dienst                         = [datetime]::parseexact($p.PrimaryContract.Custom.PlanCareContractEndDate, 'yyyy-MM-dd', $null)
```

# HelloID Docs
The official HelloID documentation can be found at: https://docs.helloid.com/
