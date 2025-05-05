CREATE TABLE Agency (
    agency_code SMALLINT PRIMARY KEY,
    agency_name VARCHAR(100),
    agency_abbr VARCHAR(20)
);

CREATE TABLE LoanType (
    loan_type SMALLINT PRIMARY KEY,
    loan_type_name VARCHAR(100)
);

CREATE TABLE PropertyType (
    property_type SMALLINT PRIMARY KEY,
    property_type_name VARCHAR(100)
);

CREATE TABLE LoanPurpose (
    loan_purpose SMALLINT PRIMARY KEY,
    loan_purpose_name VARCHAR(100)
);

CREATE TABLE OwnerOccupancy (
    owner_occupancy SMALLINT PRIMARY KEY,
    owner_occupancy_name VARCHAR(100)
);

CREATE TABLE Preapproval (
    preapproval SMALLINT PRIMARY KEY,
    preapproval_name VARCHAR(100)
);

CREATE TABLE ActionTaken (
    action_taken SMALLINT PRIMARY KEY,
    action_taken_name VARCHAR(100)
);

CREATE TABLE MSAMD (
    msamd VARCHAR(10) PRIMARY KEY,
    msamd_name VARCHAR(100)
);

CREATE TABLE State (
    state_code CHAR(2) PRIMARY KEY,
    state_name VARCHAR(50),
    state_abbr VARCHAR(10)
);

CREATE TABLE County (
    county_code CHAR(5) PRIMARY KEY,
    county_name VARCHAR(100)
);

CREATE TABLE Ethnicity (
    ethnicity_code SMALLINT PRIMARY KEY,
    ethnicity_name VARCHAR(100)
);

CREATE TABLE Race (
    race_code SMALLINT PRIMARY KEY,
    race_name VARCHAR(100)
);

CREATE TABLE Sex (
    sex_code SMALLINT PRIMARY KEY,
    sex_name VARCHAR(100)
);

CREATE TABLE PurchaserType (
    purchaser_type SMALLINT PRIMARY KEY,
    purchaser_type_name VARCHAR(100)
);

CREATE TABLE HOEPA (
    hoepa_status SMALLINT PRIMARY KEY,
    hoepa_status_name VARCHAR(100)
);

CREATE TABLE LienStatus (
    lien_status SMALLINT PRIMARY KEY,
    lien_status_name VARCHAR(100)
);

CREATE TABLE EditStatus (
    edit_status VARCHAR(20) PRIMARY KEY,
    edit_status_name VARCHAR(100)
);

CREATE TABLE ApplicationDateIndicator (
    application_date_indicator SMALLINT PRIMARY KEY,
    application_date_indicator_name VARCHAR(100)
);

CREATE TABLE DenialReason (
    denial_reason_code SMALLINT PRIMARY KEY,
    denial_reason_name VARCHAR(100)
);

CREATE TABLE Location (
    location_id SERIAL PRIMARY KEY,
    county_code CHAR(5) REFERENCES County(county_code),
    msamd VARCHAR(10) REFERENCES MSAMD(msamd),
    state_code CHAR(2) REFERENCES State(state_code),
    census_tract_number VARCHAR(20),
    population INTEGER,
    minority_population NUMERIC(10,4),
    hud_median_family_income INTEGER,
    tract_to_msamd_income NUMERIC(5,2),
    number_of_owner_occupied_units INTEGER,
    number_of_1_to_4_family_units INTEGER
);

CREATE TABLE Application (
    id SERIAL PRIMARY KEY,
    as_of_year SMALLINT,
    respondent_id VARCHAR(20),
    agency_code SMALLINT REFERENCES Agency(agency_code),
    loan_type SMALLINT REFERENCES LoanType(loan_type),
    property_type SMALLINT REFERENCES PropertyType(property_type),
    loan_purpose SMALLINT REFERENCES LoanPurpose(loan_purpose),
    owner_occupancy SMALLINT REFERENCES OwnerOccupancy(owner_occupancy),
    loan_amount_000s INTEGER,
    preapproval SMALLINT REFERENCES Preapproval(preapproval),
    action_taken SMALLINT REFERENCES ActionTaken(action_taken),
    applicant_ethnicity SMALLINT REFERENCES Ethnicity(ethnicity_code),
    co_applicant_ethnicity SMALLINT REFERENCES Ethnicity(ethnicity_code),
    applicant_sex SMALLINT REFERENCES Sex(sex_code),
    co_applicant_sex SMALLINT REFERENCES Sex(sex_code),
    applicant_income_000s NUMERIC(10,2),
    purchaser_type SMALLINT REFERENCES PurchaserType(purchaser_type),
    rate_spread VARCHAR(20),
    hoepa_status SMALLINT REFERENCES HOEPA(hoepa_status),
    lien_status SMALLINT REFERENCES LienStatus(lien_status),
    edit_status VARCHAR(20) REFERENCES EditStatus(edit_status),
    application_date_indicator SMALLINT REFERENCES ApplicationDateIndicator(application_date_indicator),
    location_id INTEGER REFERENCES Location(location_id)
);


CREATE TABLE ApplicantRace (
    application_id INTEGER REFERENCES Application(id),
    race_code SMALLINT REFERENCES Race(race_code),
    race_number SMALLINT CHECK (race_number BETWEEN 1 AND 5)
);

CREATE TABLE CoApplicantRace (
    application_id INTEGER REFERENCES Application(id),
    race_code SMALLINT REFERENCES Race(race_code),
    race_number SMALLINT CHECK (race_number BETWEEN 1 AND 5)
);

CREATE TABLE ApplicationDenialReason (
    application_id INTEGER REFERENCES Application(id),
    denial_reason_code SMALLINT REFERENCES DenialReason(denial_reason_code),
    denial_number SMALLINT CHECK (denial_number BETWEEN 1 AND 3)
);