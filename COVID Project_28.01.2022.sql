SELECT *
FROM covid..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


--SELECT *
--FROM covid..CovidVaccination
--ORDER BY 3,4

--Select the data that we are going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid..CovidDeaths
ORDER BY 1, 2

--Looking at Total Cases VS Total Deaths
--Risk of death from COVID in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM covid..CovidDeaths
WHERE location like '%greece%'
ORDER BY 1,2

--Looking at Total Cases VS Population
--Shows what percentage of population got COVID

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentagePopulationInfected
FROM covid..CovidDeaths
WHERE location like '%russia%'
ORDER BY 1,2

--Looking at Countries with the Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM covid..CovidDeaths
--WHERE location like '%russia%'
GROUP BY Population, Location
ORDER BY PercentagePopulationInfected DESC

--Looking at the Countries with the Highest DEath Count per Population

SELECT Location, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM covid..CovidDeaths
--WHERE location like '%russia%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Looking at the Continents with the highest death count per population

SELECT Continent, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM covid..CovidDeaths
--WHERE location like '%russia%'
WHERE continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC

--Global Numbers

SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths,
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS Death_Percentage
FROM covid..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

--Looking at Total Population VS Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
--or SUM(CONVERT(int,vac.new_vaccinations OVER (Partition by dea.location)
FROM covid..CovidDeaths dea
JOIN covid..CovidVaccination vac
  ON dea.location = vac.location AND
  dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--USE CTE

With PopVSVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
--or SUM(CONVERT(int,vac.new_vaccinations OVER (Partition by dea.location)
FROM covid..CovidDeaths dea
Join covid..CovidVaccination vac
  ON dea.location = vac.location AND
  dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS VaccinationRate
FROM PopVSVac

--Tempt Table

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
--or SUM(CONVERT(int,vac.new_vaccinations OVER (Partition by dea.location)
FROM covid..CovidDeaths dea
Join covid..CovidVaccination vac
  ON dea.location = vac.location AND
  dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 AS VaccinationRate
FROM #PercentPopulationVaccinated


--Creating a View to store the data for later visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
--or SUM(CONVERT(int,vac.new_vaccinations OVER (Partition by dea.location)
FROM covid..CovidDeaths dea
Join covid..CovidVaccination vac
  ON dea.location = vac.location AND
  dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated