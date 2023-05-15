/*
Covid 19 Data Exploration Project
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views
*/

SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3,4 

--Select data we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2 

--Looking at total cases vs total deaths in your country
--Shows the likelihood of dying if you contract Covid19 in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Kenya' AND continent is not null
ORDER BY 1,2 

--Looking at total cases vs population
--Shows what percentage of population got Covid19

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2 

--Looking at countries with the highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Showing countries with the highest death count

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Breaking things down by continent

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Looking at global numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY date 
ORDER BY 1,2 

--Selecting data from our vaccinations table

SELECT*
FROM PortfolioProject.dbo.[CovidVaccinations ]

-- Using both tables to calculate total population vs vaccination
--Shows percentage of the population that has received at least one Covid vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
ON dea.location = vac.location and 
dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
ON dea.location = vac.location and 
dea.date = vac.date
WHERE dea.continent is not null

)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
ON dea.location = vac.location and 
dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


