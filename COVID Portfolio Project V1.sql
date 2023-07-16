SELECT *
FROM [Portfolio Project]..CovidDeaths2
WHERE continent is not null
ORDER by 3,4;

SELECT *
FROM [Portfolio Project]..CovidVaccinations2
ORDER by 3,4;

--Select Data that we are going to be using

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths2
ORDER by 1,2;

-- Change Data Type 

ALTER TABLE dbo.CovidDeaths2
	ALTER COLUMN total_deaths int;

ALTER TABLE dbo.CovidDeaths2
	ALTER COLUMN total_cases int;

-- Looking at Total Cases vs Total Deaths
	-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases,total_deaths, (CAST(total_deaths AS float)/CAST(total_cases AS float))*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
Where location like '%states%'
ORDER by 1,2;


--Looking at Total Cases Vs Population
	--Show % of populaiton that got Covid


SELECT Location, date, total_cases, Population, (CAST(total_cases AS float)/CAST(Population AS float))*100 AS Percent_Population_Infected
FROM [Portfolio Project]..CovidDeaths
Where location like '%states%'
ORDER by 1,2;

--Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, MAX(total_cases) AS HighestInfectionCount, Population, 
	MAX((CAST(total_cases AS float))/CAST(Population AS float))*100  AS Percent_Population_Infected
FROM dbo.CovidDeaths
--Where location like '%states%'
Group by location, Population
ORDER by Percent_Population_Infected desc;

-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(CAST(total_deaths as int)) AS TotalDeathCount--, MAX((CAST(total_deaths AS float)/CAST(Population AS float) * 100 AS Pecent_Dead
FROM dbo.CovidDeaths
--Where location like '%states%'
WHERE continent is not null
Group by location, Population
Order by TotalDeathCount desc
;

--Let's Break Things Down By Continent
--Showing Continents with highest death counts


SELECT Location, MAX(CAST(total_deaths as int)) AS TotalDeathCount--, MAX((CAST(total_deaths AS float)/CAST(Population AS float) * 100 AS Pecent_Dead
FROM dbo.CovidDeaths
--This filters by continent because the data shows continents as seperate line
WHERE continent is null
Group by location 
Order by TotalDeathCount desc
;

--This one for the sake of this project
SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount--, MAX((CAST(total_deaths AS float)/CAST(Population AS float) * 100 AS Pecent_Dead
FROM dbo.CovidDeaths
WHERE continent is not null
Group by continent 
Order by TotalDeathCount desc
;

-- Global Numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as float))/SUM(New_Cases)*100 as Deathpercentage
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
Group By date
ORDER by 1,2;


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER by dea.location, dea.Date) AS RunningTotalVaccinated

FROM [Portfolio Project]..covidDeaths dea
JOIN [Portfolio Project]..covidvaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3;


--USE CTE

With PopvsVac (Continent, Location, Date, Popluation, new_vaccinations, RunningTotalVaccinated)
AS
(

SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER by dea.location, dea.Date) AS RunningTotalVaccinated

FROM [Portfolio Project]..covidDeaths dea
JOIN [Portfolio Project]..covidvaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3;
)

SELECT*, (Cast(RunningTotalVaccinated AS float)/Popluation) * 100 AS VaccinationbyPopulation
FROM PopvsVac

-- Temp Table
DROP Table if exists #PerecntPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Data datetime,
Population numeric,
new_vaccinations numeric,
RunningTotalVaccinated numeric
)


Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER by dea.location, dea.Date) AS RunningTotalVaccinated

FROM [Portfolio Project]..covidDeaths dea
JOIN [Portfolio Project]..covidvaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
;

SELECT *
FROM #PercentPopulationVaccinated;


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated AS

SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER by dea.location, dea.Date) AS RunningTotalVaccinated

FROM [Portfolio Project]..covidDeaths dea
JOIN [Portfolio Project]..covidvaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
;

