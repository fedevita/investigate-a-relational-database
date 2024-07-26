# Investigate a Relational Database

## Udacity - Programming for Data Science with Python - Nanodegree Program

This project marks the initial step in the Programming for Data Science with Python Nanodegree from Udacity. The aim of this exercise was to delve into a movie rental database using SQL to uncover insightful information and answer key questions. Additionally, visual representations were developed to highlight the results obtained from the queries.

### Prerequisites
- Docker
- Power BI

### Instructions

1. **Start Docker Compose:**
   - Run the command:
     ```bash
     docker-compose up
     ```

2. **Access the Database:**
   - Open your web browser and go to [http://localhost:80](http://localhost:80).
   - Log in to pgAdmin using the following credentials:
     - **User:** user@domain.com
     - **Password:** admin

3. **Set Up the Database Connection in pgAdmin:**
   - Use the following parameters to configure the connection:
     - **Host:** my-postgres-db
     - **Port:** 5432
     - **Database:** postgres
     - **Username:** postgres
     - **Password:** mysecretpassword

4. **Querying the Database:**
   - The SQL queries used for the analysis are available in the `final-files/queries.sql` file, with accompanying comments for clarity.
   - To facilitate the analysis, the following views have been created and preloaded into the database dump upon container startup:
     - `q1`
     - `q2`
     - `q3`
     - `q4`

5. **Data Analysis:**
   - The analysis was conducted using Power BI, with a direct connection to the database and leveraging the created views for data retrieval.

6. **Exporting Results:**
   - The final report was exported from Power BI in PDF format.

### Additional Information

- Ensure Docker is installed and running on your machine before executing the `docker-compose up` command.
- Make sure Power BI is installed and configured to connect to the PostgreSQL database for the analysis.
- If you encounter any issues accessing pgAdmin or connecting to the database, check your Docker setup and ensure the container is running properly.