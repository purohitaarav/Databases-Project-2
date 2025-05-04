CREATE TABLE hmda.preliminary (
    as_of_year TEXT,
    respondent_id TEXT,
    agency_name TEXT,
    agency_abbr TEXT,
    agency_code TEXT,
    loan_type_name TEXT,
    loan_type TEXT,
    property_type_name TEXT,
    property_type TEXT,
    loan_purpose_name TEXT,
    loan_purpose TEXT,
    owner_occupancy_name TEXT,
    owner_occupancy TEXT,
    loan_amount_000s TEXT,
    preapproval_name TEXT,
    preapproval TEXT,
    action_taken_name TEXT,
    action_taken TEXT,
    msamd_name TEXT,
    msamd TEXT,
    state_name TEXT,
    state_abbr TEXT,
    state_code TEXT,
    country_name TEXT,
    county_code TEXT,
    census_tract_number TEXT,
    applicant_ethnicity_name TEXT,
    applicant_ethnicity TEXT,
    co_applicant_ethnicity_name TEXT,
    co_applicant_ethnicity TEXT,
    applicant_race_name_1 TEXT,
    applicant_race_1 TEXT,
    applicant_race_name_2 TEXT,
    applicant_race_2 TEXT,
    applicant_race_name_3 TEXT,
    applicant_race_3 TEXT,
    applicant_race_name_4 TEXT,
    applicant_race_4 TEXT,
    applicant_race_name_5 TEXT,
    applicant_race_5 TEXT,
    co_applicant_race_name_1 TEXT,
    co_applicant_race_1 TEXT,
    co_applicant_race_name_2 TEXT,
    co_applicant_race_2 TEXT,
    co_applicant_race_name_3 TEXT,
    co_applicant_race_3 TEXT,
    co_applicant_race_name_4 TEXT,
    co_applicant_race_4 TEXT,
    co_applicant_race_name_5 TEXT,
    co_applicant_race_5 TEXT,
    applicant_sex_name TEXT,
    applicant_sex TEXT,
    co_applicant_sex_name TEXT,
    co_applicant_sex TEXT,
    applicant_income_000s TEXT,
    purchaser_type_name TEXT,
    purchaser_type TEXT,
    denial_reason_name_1 TEXT,
    denial_reason_1 TEXT,
    denial_reason_name_2 TEXT,
    denial_reason_2 TEXT,
    denial_reason_name_3 TEXT,
    denial_reason_3 TEXT,
    rate_spread TEXT,
    hoepa_status_name TEXT,
    hoepa_status TEXT,
    lien_status_name TEXT,
    lien_status TEXT,
    edit_status_name TEXT,
    edit_status TEXT,
    sequence_number TEXT,
    population TEXT,
    minority_population TEXT,
    hud_median_family_income TEXT,
    tract_to_msamd_income TEXT,
    number_of_owner_occupied_units TEXT,
    number_of_1_to_4_family_units TEXT,
    application_date_indicator TEXT
);

CREATE TABLE Agency (
    agency_code INTEGER PRIMARY KEY,
    agency_name TEXT NOT NULL,
    agency_abbr VARCHAR(4) NOT NULL
);

CREATE TABLE LoanType (
    loan_type INTEGER PRIMARY KEY,
    loan_type_name TEXT NOT NULL
);

CREATE TABLE PurchaserType (
    purchaser_type INTEGER PRIMARY KEY,
    purchaser_type_name TEXT NOT NULL
);

CREATE TABLE PropertyType (
    property_type INTEGER PRIMARY KEY,
    property_type_name TEXT NOT NULL
);

CREATE TABLE Purpose (
    loan_purpose INTEGER PRIMARY KEY,
    loan_purpose_name TEXT NOT NULL
);

CREATE TABLE Preapproved (
    preapproval INTEGER PRIMARY KEY,
    preapproval_name TEXT NOT NULL
);

CREATE TABLE ActionTaken (
    action_taken INTEGER PRIMARY KEY,
    action_taken_name TEXT NOT NULL
);

CREATE TABLE MSAMD (
    msamd INTEGER PRIMARY KEY,
    msamd_name TEXT NOT NULL
);

CREATE TABLE HOEPA (
    hoepa_status INTEGER PRIMARY KEY,
    hoepa_status_name TEXT NOT NULL
);

CREATE TABLE Lien (
    lien_status INTEGER PRIMARY KEY,
    lien_status_name TEXT NOT NULL
);

CREATE TABLE County (
    county_code INTEGER PRIMARY KEY,
    county_name TEXT NOT NULL
);

CREATE TABLE OwnerOccupancy (
    owner_occupancy INTEGER PRIMARY KEY,
    owner_occupancy_name TEXT NOT NULL
);

CREATE TABLE Denial (
    denial_reason INTEGER PRIMARY KEY,
    denial_reason_name TEXT NOT NULL
);

CREATE TABLE States (
    state_code INTEGER PRIMARY KEY,
    state_name TEXT NOT NULL,
    state_abbr VARCHAR(2) NOT NULL
);

CREATE TABLE Ethnicity (
    applicant_ethnicity INTEGER PRIMARY KEY,
    applicant_ethnicity_name TEXT NOT NULL
);

CREATE TABLE Race (
    applicant_race INTEGER PRIMARY KEY,
    applicant_race_name TEXT NOT NULL
);

CREATE TABLE Sex (
    applicant_sex INTEGER PRIMARY KEY,
    applicant_sex_name TEXT NOT NULL
);

CREATE TABLE Nullables (
    edit_status INTEGER NULL,
    edit_status_name INTEGER NULL,
    sequence_number INTEGER NULL,
    application_date_indicator INTEGER NULL
);

-- Main Tables
CREATE TABLE locations (
    location_id SERIAL PRIMARY KEY,
    county_code INTEGER REFERENCES County(county_code),
    msamd INTEGER REFERENCES MSAMD(msamd),
    state_code INTEGER REFERENCES States(state_code),
    census_tract_number VARCHAR(7),
    population INTEGER,
    minority_population NUMERIC(5,2),
    hud_median_family_income INTEGER,
    tract_to_msamd_income NUMERIC(5,2),
    number_of_owner_occupied_units INTEGER,
    number_of_1_to_4_family_units INTEGER,
    UNIQUE (county_code, msamd, state_code, census_tract_number,
            population, minority_population, hud_median_family_income,
            tract_to_msamd_income, number_of_owner_occupied_units,
            number_of_1_to_4_family_units)
);

CREATE TABLE Applicant (
    applicant_id SERIAL PRIMARY KEY,
    applicant_ethnicity INTEGER REFERENCES Ethnicity(applicant_ethnicity),
    applicant_sex INTEGER REFERENCES Sex(applicant_sex)
);

CREATE TABLE CoApplicant (
    co_applicant_id SERIAL PRIMARY KEY,
    co_applicant_ethnicity INTEGER REFERENCES Ethnicity(applicant_ethnicity),
    co_applicant_sex INTEGER REFERENCES Sex(applicant_sex)
);

-- Junction tables for race
CREATE TABLE ApplicantRace (
    applicant_id INTEGER REFERENCES Applicant(applicant_id),
    applicant_race INTEGER REFERENCES Race(applicant_race),
    race_number INTEGER,
    PRIMARY KEY (applicant_id, applicant_race, race_number)
);

CREATE TABLE CoApplicantRace (
    co_applicant_id INTEGER REFERENCES CoApplicant(co_applicant_id),
    co_applicant_race INTEGER REFERENCES Race(applicant_race),
    race_number INTEGER,
    PRIMARY KEY (co_applicant_id, co_applicant_race, race_number)
);

-- Main Loan table
CREATE TABLE Loan (
    loan_id SERIAL PRIMARY KEY,
    applicant_id INTEGER REFERENCES Applicant(applicant_id),
    agency_code INTEGER REFERENCES Agency(agency_code),
    loan_type INTEGER REFERENCES LoanType(loan_type),
    preapproval INTEGER REFERENCES Preapproved(preapproval),
    action_taken INTEGER REFERENCES ActionTaken(action_taken),
    msamd INTEGER REFERENCES MSAMD(msamd),
    county_code INTEGER REFERENCES County(county_code),
    lien_status INTEGER REFERENCES Lien(lien_status),
    hoepa_status INTEGER REFERENCES HOEPA(hoepa_status),
    purchaser_type INTEGER REFERENCES PurchaserType(purchaser_type),
    loan_purpose INTEGER REFERENCES Purpose(loan_purpose),
    loan_amount_000s NUMERIC(12,2),
    applicant_income_000s NUMERIC(10,2),
    interest_rate_spread NUMERIC(5,3),
    respondent_id VARCHAR(10),
    location_id INTEGER REFERENCES locations(location_id)
);

CREATE TABLE LoanDenial (
    loan_id INTEGER REFERENCES Loan(loan_id),
    denial_reason INTEGER REFERENCES Denial(denial_reason),
    denial_number INTEGER,
    PRIMARY KEY (loan_id, denial_reason, denial_number)
);

INSERT INTO Agency (agency_code, agency_name, agency_abbr) VALUES
(1, 'Office of the Comptroller of the Currency', 'OCC'),
(2, 'Federal Reserve System', 'FRS'),
(3, 'Federal Deposit Insurance Corporation', 'FDIC'),
(5, 'National Credit Union Administration', 'NCUA'),
(7, 'Department of Housing and Urban Development', 'HUD'),
(9, 'Consumer Financial Protection Bureau', 'CFPB');

INSERT INTO LoanType (loan_type, loan_type_name) VALUES
(1, 'Conventional'),
(2, 'FHA-insured'),
(3, 'VA-guaranteed'),
(4, 'FSA/RHS');

INSERT INTO PropertyType (property_type, property_type_name) VALUES
(1, 'One to four-family'),
(2, 'Manufactured housing'),
(3, 'Multifamily');

INSERT INTO Purpose (loan_purpose, loan_purpose_name) VALUES
(1, 'Home purchase'),
(2, 'Home improvement'),
(3, 'Refinancing');