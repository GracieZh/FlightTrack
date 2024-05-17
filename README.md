# { Proj name }
{ proj description }

## Table of Contents
- [Features](#features)
- [Setup](#setup)
- [Contributors](#contributors)

## Features


## Setup
### Prerequisites
- Install PostgreSQL 
- Install Python (the app was built with version 3.11.4)
- Set up ssh on your laptop/pc (or download a zip)

### PostgreSQL DB Setup and Backend Configuration
Make sure you have the correct database information in lines 11-15 of the `backend/bk.py` script to match what you have on your device. As of now, use the script below to set up your local database. Open you Psql shell and enter your psql credentials. Then, type the following:

```sql
CREATE DATABASE appdb;
\c appdb

CREATE TABLE users (
  id integer PRIMARY KEY,
  fullname VARCHAR(255),
  username VARCHAR(255),
  password VARCHAR(255)
); 
\dt

INSERT INTO users VALUES (23485, 'Goose1', 'mr.goose', 'imapw-willhashlater');
INSERT INTO users VALUES (472983, 'Babygoose1', 'gosling1', 'pw2');
```
Note: passwords will be stored as hashes instead of how they're currently stored in the initial version of the application

### Getting Started
Clone the repository

```bash
git clone git@github.com:GracieZh/dbproj.git
cd dbproj-master
```

Make sure you are in the correct directory<br />
Run the backend script
```
python backend/bk.py
```

Open another terminal window or tab<br />
Run the frontend script
```
python frontend/fe.py
```
Open a browser and visit http://localhost:8080/ to access the app

If you are having trouble with setting up, please reach out to Gracie at g85zhang@uwaterloo.ca

## Contributors
- Nolan Carroll
- Arkend Hyseni
- Shayne Twiss
- Ricky Khaing 
- Gracie Zhang