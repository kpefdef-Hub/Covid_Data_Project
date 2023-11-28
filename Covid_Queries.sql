select *
from PortfolioProject.dbo.CovidDeaths
order by 3,4;

--select *
--from PortfolioProject.dbo.CovidVaccinations
--order by 3,4;

SELECT location, date, total_cases, new_Cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location,date

-- Comparing Total Deaths and Total Cases as likelihood of death
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS [Death %]
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Japan%'
WHERE continent IS NOT NULL
ORDER BY location,date

-- Comparing total cases against the population
SELECT location, date,population, total_cases, (total_cases/population) * 100 AS [Infection Rate]
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Japan%'
WHERE continent IS NOT NULL
ORDER BY location,date

-- Sorting infection rate by country from highest to lowest
SELECT location,population, MAX(total_cases) AS HighestInfectionPerCountry, MAX(total_cases/population) * 100 AS [Population Infection Rate]
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Japan%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY [Population Infection Rate] DESC;

-- Sorting Countries with Highest Deaths per population
SELECT location, MAX(CAST(total_deaths AS INT)) AS [Total Death Count]
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Japan%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY [Total Death Count] DESC;

-- Sorting Continents with Highest Deaths per population
SELECT continent, MAX(CAST(total_deaths AS INT)) AS [Total Death Count]
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Japan%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY [Total Death Count] DESC;


-- Showing the Global Numbers
SELECT date, SUM(new_cases) AS [Total Cases], SUM(CAST(new_deaths AS INT)) AS [Total Deaths], SUM(CAST(new_deaths AS INT)) /SUM(new_cases) AS [Death %]
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Japan%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date, [Total Cases]

SELECT SUM(new_cases) AS [Total Cases], SUM(CAST(new_deaths AS INT)) AS [Total Deaths], SUM(CAST(new_deaths AS INT)) /SUM(new_cases) AS [Death %]
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Japan%'
WHERE continent IS NOT NULL
ORDER BY [Total Cases], [Total Deaths]

-- Comparing Total Populations with the Total Vaccinations
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(CAST(cv.new_vaccinations AS INT)) 
	OVER (PARTITION BY cd.location
			ORDER BY cd.location, cd.date) AS [Cummulated Vaccination Count]
--([Cummulated Vaccination Count]/population)*100
FROM PortfolioProject..CovidDeaths AS CD
JOIN PortfolioProject..CovidVaccinations AS CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3

--Using CTE
WITH PopvsVac (Continent, Location, Date, Population,[New Vaccinations], [Cummulated Vaccination Count])

AS
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(CAST(cv.new_vaccinations AS INT)) 
	OVER (PARTITION BY cd.location
			ORDER BY cd.location, cd.date) AS [Cummulated Vaccination Count]
--([Cummulated Vaccination Count]/population)*100
FROM PortfolioProject..CovidDeaths AS CD
JOIN PortfolioProject..CovidVaccinations AS CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE cd.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *, ([Cummulated Vaccination Count]/Population)*100
FROM PopvsVac

--Using a Temp Table
DROP TABLE IF EXISTS #PopulationVaccinatedPercent
CREATE TABLE #PopulationVaccinatedPercent
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PopulationVaccinatedPercent
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(CAST(cv.new_vaccinations AS INT)) 
	OVER (PARTITION BY cd.location
			ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
--([Cummulated Vaccination Count]/population)*100
FROM PortfolioProject..CovidDeaths AS CD
JOIN PortfolioProject..CovidVaccinations AS CV
	ON CD.location = CV.location
	AND CD.date = CV.date
--WHERE cd.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PopulationVaccinatedPercent


-- Creating view to store visualization data
CREATE VIEW PopulationVaccinatedPercent AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(CAST(cv.new_vaccinations AS INT)) 
	OVER (PARTITION BY cd.location
			ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
--([Cummulated Vaccination Count]/population)*100
FROM PortfolioProject..CovidDeaths AS CD
JOIN PortfolioProject..CovidVaccinations AS CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE cd.continent IS NOT NULL
--ORDER BY 2,3
