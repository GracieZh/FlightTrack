# FlightTrack
FlightTrack is a data analytics platform for JFK International Airport, tracking flight arrivals, departures, and delays using real datasets. Designed for airport management, airlines, as well as travelers, it offers insights for optimized scheduling and operational efficiency. Features include graphical analysis of delay-causing flights, predictive taxi-out times, weather integration, and comparative carrier performance.

## Table of Contents
- [Setup](#setup)
    - [Prerequisites](#prerequisites)
    - [PSQL Setup and Backend Configs](#psql-setup-and-backend-configs)
    - [Getting Started](#getting-started)
- [Contributors](#contributors)

## Setup
### Prerequisites
- Install PostgreSQL 
- Install Python (the app was built with version 3.11.4)
- Set up ssh on your laptop/pc (or download a zip)
- Have the required raw data csv files

### Install Python Packages
```bash
python.exe -m pip install --upgrade pip
pip install flask
pip install psycopg2
pip install matplotlib
```

### PSQL Setup and Backend Configs
Make sure you have the correct database information in `frontend/conn.py`.

### Getting Started
Clone the repository

```bash
C:
mkdir C:/projects/cs338-proj/
cd C:/projects/cs338-proj/
git clone git@github.com:GracieZh/dbproj.git
rename FlightTrack dbproj
cd dbproj
```

Open a psql shell. Create a database called `appdb` by running:

```
CREATE DATABASE appdb;
\c appdb
```

Set up your local Postgres database using the scripts from `setup.sql`. You can run it by using the following command in a psql shell:

```
\i C:/projects/cs338-proj/dbproj/setup.sql
```
Go back to your Windows Powershell or Command Prompt.

Run the application script:
```
cd frontend
python fe.py
```

Open a browser and visit http://localhost:8080/ to access the app

## Contributors
- Nolan Carroll
- Arkend Hyseni
- Shayne Twiss
- Ricky Khaing 
- Gracie Zhang