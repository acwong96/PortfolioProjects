SELECT *
FROM CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT *
FROM CovidVaccinations
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

--Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Total Cases vs Population

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Countries with highest deathcount per population

SELECT location, population, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY TotalDeathCount DESC

--Continent with highest deathcount per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Global Numbers

SELECT date, SUM(new_cases) as Total_cases,SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage--total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


-- Total Population vs Vaccinations

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY Dea.location ORDER BY dea.location, dea.Date) as Total_Vacination
FROM CovidDeaths Dea
JOIN CovidVaccinations Vac
	ON Dea.location = Vac.location
	and Dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--CTE

WITH PopVsVac (Continent, location, date, population, new_vaccinations, Total_Vacination)
as
(
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY Dea.location ORDER BY dea.location, dea.Date) as Total_Vacination
FROM CovidDeaths Dea
JOIN CovidVaccinations Vac
	ON Dea.location = Vac.location
	and Dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

Select *, (Total_Vacination/population)*100 AS PercentagePopularionVactinated
FROM PopVsVac

--TEMP TABLE

DROP TABLE IF Exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vactinations numeric,
RollingPeopleVacinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY Dea.location ORDER BY dea.location, dea.Date) as Total_Vacination
FROM CovidDeaths Dea
JOIN CovidVaccinations Vac
	ON Dea.location = Vac.location
	and Dea.date = vac.date
WHERE dea.continent is not null

Select *, (RollingPeopleVacinated/population)*100 AS PercentagePopularionVactinated
FROM #PercentPopulationVaccinated

--Creating View to store data for later visulaization

CREATE VIEW PercentPopulationVaccinated as
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY Dea.location ORDER BY dea.location, dea.Date) as Total_Vacination
FROM CovidDeaths Dea
JOIN CovidVaccinations Vac
	ON Dea.location = Vac.location
	and Dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated