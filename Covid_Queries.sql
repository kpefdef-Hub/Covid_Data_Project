SELECT *
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT * FROM covidvaccinations;

SELECT *
FROM covidvaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4;

-- select data to be used
SELECT  location,date_, total_cases,new_cases, total_deaths, population 
FROM coviddeaths
--WHERE location like '%Afghanistan'
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Reviewing total cases vs total deaths
-- Estimates likelihood of dying from Covid infection per country
SELECT location, date_,total_cases, total_deaths, ROUND ((total_deaths/total_cases)*100, 3) as DeathPercent
FROM coviddeaths
WHERE location like '%States%'
AND continent IS NOT NULL
ORDER BY 1,2;

SELECT location, date_, population, ROUND ((total_cases/population)*100, 3) AS InfectedPopulation
FROM coviddeaths
-- WHERE location like = '%Nigeria%'
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- calculating the infection rate per country per country
SELECT location, population, MAX (total_cases) as MaxInfectionCount , ROUND(MAX((total_cases/population))*100,3) as MaxInfectionRate
FROM coviddeaths
--WHERE location like '%States%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY MaxInfectionRate DESC;

--  Countries with the highest deaths
SELECT location , MAX (CAST(total_deaths AS INT)) as Total_Deaths
FROM coviddeaths
--WHERE location like '%States%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Deaths DESC;

-- Filtering by Continent

-- Display continents with higest number of deaths 
SELECT continent , MAX (CAST(total_deaths AS INT)) as Total_Deaths
FROM coviddeaths
--WHERE location like '%States%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Deaths DESC;

-- Calculate the Global figures
SELECT SUM(new_cases) as GlobalCases, SUM (new_deaths) as GlobalDeaths, SUM(new_deaths)/SUM(new_deaths) as GlobalDeathPercent
FROM coviddeaths
--WHERE location like '%States%'
WHERE continent IS NOT NULL
--GROUP BY date_
ORDER BY 1,2;

-- Comparing the vaccinations per Total population
SELECT dea.continent, dea.location, dea.date_, dea.population, vacc.new_vaccinations,
SUM(vacc.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date_) AS CummulativeVaccinations 
--(CummulativeVaccinations/population) * 100
FROM coviddeaths  dea
FULL JOIN covidvaccinations  vacc
    ON dea.location = vacc.location
    AND dea.date_ = vacc.date_
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;
    
-- Using CTE
WITH PopvsVacc (Continent, Location, Date_, Population,New_Vaccinations, CummulativeVaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date_, dea.population, vacc.new_vaccinations,
SUM(vacc.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date_) AS CummulativeVaccinations
--(CummulativeVaccinations/population) * 100
FROM coviddeaths  dea
FULL JOIN covidvaccinations  vacc
    ON dea.location = vacc.location
    AND dea.date_ = vacc.date_
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT Continent, Location, Date_, Population,New_Vaccinations, CummulativeVaccinations, (CummulativeVaccinations/Population)* 100
FROM PopvsVacc;



-- Using TempTable
DROP TABLE PopulationVaccinatedPercent
CREATE TABLE PopulationVaccinatedPercent
(
    Continent NVARCHAR2 (255),
    Location NVARCHAR2(255),
    DATE_ datetime,
    Population Numeric,
    New_Vaccinations numeric,
    CummulativeVacccinations numeric
)
INSERT INTO PopulationVaccinatedPercent
(Continent, Location, DATE_, Population, New_Vaccinations, CummulativeVacccinations)
SELECT dea.continent, dea.location, dea.date_, dea.population, vacc.new_vaccinations,
SUM(vacc.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date_) AS CummulativeVaccinations
--(CummulativeVaccinations/population) * 100
FROM coviddeaths  dea
FULL JOIN covidvaccinations  vacc
    ON dea.location = vacc.location
    AND dea.date_ = vacc.date_;
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT Continent, Location, Date_, Population,New_Vaccinations, CummulativeVaccinations, (CummulativeVaccinations/Population)* 100
FROM PopulationVaccinatedPercent;



-- Creating later Data Visualization view
CREATE VIEW PopulationVaccinatedPercent AS
SELECT dea.continent, dea.location, dea.date_, dea.population, vacc.new_vaccinations,
SUM(vacc.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date_) AS CummulativeVaccinations
--(CummulativeVaccinations/population) * 100
FROM coviddeaths  dea
FULL JOIN covidvaccinations  vacc
    ON dea.location = vacc.location
    AND dea.date_ = vacc.date_
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


SELECT *
FROM PopulationVaccinatedPercent;