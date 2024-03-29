-- Data Exploration on COVID 19 dataset

Select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

/*Select * from PortfolioProject..CovidVaccinations
order by 3,4*/

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Total cases vs total deaths
-- Shows likelyhood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Total cases vs Population
-- Shows what percentage of population got covid
Select Location, date, total_cases,population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Country that has Highest Infection rate compared to Population

Select Location, Population,  max(total_cases) as HighestInfectioncount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
group by Location, population
order by PercentPopulationInfected desc


--By continent Highest Death count
Select continent, max(cast(total_deaths as int)) as Totaldeathcount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by Totaldeathcount desc


--Showing countries with highest death count per population

Select Location, max(cast(total_deaths as int)) as Totaldeathcount
from PortfolioProject..CovidDeaths
where continent is not null
group by Location
order by Totaldeathcount desc

--Taking a look at Global numbers

Select SUM(new_cases) as totalcases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

-- Compare total Population vs Vaccinations
--Using CTE
 With PopvsVac (Continent, Location,Date, Population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
--add every consecutive values as rolling count
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location= vac.location
and dea.date = vac.date
where dea.continent is not null
)
select * , (RollingPeopleVaccinated/Population)*100
from PopvsVac

-- Temp tables
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE table #PercentPopulationVaccinated
(
Continent nvarchar(255) 
,Location nvarchar(255)
,Date datetime
,Population numeric
,new_vaccinations numeric
,RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
--add every consecutive values as rolling count
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location= vac.location
and dea.date = vac.date
--where dea.continent is not null

select * , (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--VIEW to store data for later , work table
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select * 
from PercentPopulationVaccinated