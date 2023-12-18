

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from [Portfolio Project]..['Covid Deaths$']
where location like '%states%'
order by 1,2

-- Looking at total cases vs population
-- SHows percentage of population got covid

Select location, date, total_cases,population, 
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS PercentPopulationInfected
from [Portfolio Project]..['Covid Deaths$']
where location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select location, MAX(total_cases) AS HighestInfectionCount, population, 
MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 AS PercentPopulationInfected
from [Portfolio Project]..['Covid Deaths$']
Group by location, population
order by PercentPopulationInfected desc

-- Showing the countries with highest death count per population

Select *
From [Portfolio Project]..['Covid Deaths$']
where continent is not null
order by 3,4

-- Shows by continent
Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
from [Portfolio Project]..['Covid Deaths$']
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from [Portfolio Project]..['Covid Deaths$']
where continent is not null
--group by date
order by 1,2

-- Looking at total Population vs Vaccinations
with POPvsVAC (Continent, location, date, population, New_Vaccinations, Rollingpeoplevaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location, dea.date) as Rollingpeoplevaccinated
from [Portfolio Project]..['Covid Deaths$'] dea
join [Portfolio Project]..['Covid Vaccinations$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (Rollingpeoplevaccinated/population)*100 
from POPvsVAC

-- USE CTE

with POPvsVAC (Continent, location, date, population, Rollingpeoplevaccinated)


--Temp Table
DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location, dea.date) as Rollingpeoplevaccinated
from [Portfolio Project]..['Covid Deaths$'] dea
join [Portfolio Project]..['Covid Vaccinations$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated