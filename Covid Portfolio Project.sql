
SELECT *
FROM CovidDeaths
where continent is not null
order by 3,4


--SELECT *
--FROM CovidVactinations
--order by 3,4


-- Select data that are we going to be using

SELECT 	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM CovidDeaths
Order by 1,2


--Looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country

SELECT 	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
Where location like '%states%'
and continent is not null
Order by 1,2


-- looking at total cases vs population
-- show what percentage population got covid

SELECT 	location,
	date,
	population,
	total_cases,
	(total_cases/population)*100 as PercentagePopulationInfected
FROM CovidDeaths
Where location like '%states%'
and continent is not null
Order by 1,2


-- Looking at countries with highest infection rate compared to population

SELECT 	location,
	population,
	MAX(total_cases) HighestInfectionCount,
	MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM CovidDeaths
Group by location, population
Order by PercentagePopulationInfected desc;


-- Showing Countries with highest death count per population

SELECT  location,
	MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc;


-- LET'S BRING THINGS DOWN BY CONTINENT
-- Showing continent with the highest death count per population

SELECT 	continent,
	MAX(Cast(total_deaths as int)) TotalDeathCount 
FROM CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc;


-- GLOBAL NUMBERS

SELECT 	SUM(new_cases) as total_cases,
	SUM(Cast(new_deaths as int)) as total_deaths,
	SUM(Cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM Portfolioproject..CovidDeaths
-- Where location like '%states%'
WHERE continent is not null
--Group by date
Order by 1,2


-- Looking at total population vs total vaccinations

SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations, 
	SUM (Convert(int,vac.new_vaccinations)) 
	OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,
-- (RollingPeopleVaccinated/population)*100
FROM Portfolioproject..CovidDeaths as dea
JOIN Portfolioproject..CovidVactinations as vac
	On dea.location = vac.location
	and dea.date =  vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- USE CTE 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select 	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVactinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as percentageVaccinated
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert 	into #PercentPopulationVaccinated
Select 	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create 	View PercentPopulationVaccinated as
Select 	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
