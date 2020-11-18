# HelloID-Conn-Prov-Target-PlanCare
PlanCare SQL Dump connector

Pla- This connector uses a lot of CPU. please make sure the server is assigned at least four virtual cpus.

Custom source fields used in this connector:
- Person.Custom.PlanCareAchternaam
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

- Person.Custom.PlanCareAchternaamInitVoorvoegselVoornaam
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
- Person.Custom.PlanCareGebruikNaam
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
- Person.Custom.PlanCareNaamVolledig
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

- Contract.Custom.PlanCareContractStartDate
Use the employement start date here (and not the position start date)

- Contract.Custom.PlanCareContractEndDate
Use the employement end date here (and not the position start date)

