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
- Have the raw data csv files: `jfk_airport.csv` and `airlines_with_iata.csv`

### PSQL Setup and Backend Configs
Make sure you have the correct database information in `frontend/conn.py`.

### Getting Started
Clone the repository

```bash
git clone git@github.com:GracieZh/dbproj.git
cd dbproj-master
```

Make sure you are in the correct directory<br />

Set up your local Postgres database using the scripts from `setup.sql`
Please update the path to the csv files based on where they are on your device

Run the application script
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