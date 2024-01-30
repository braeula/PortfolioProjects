select *
from Portfolio_Project..CovidDeaths
order by 3,4

--select *
--from Portfolio_Project..CovidVaccinations
--order by 3,4

-- Select Data

Select Location, date, total_cases, new_cases, total_deaths, population
from Portfolio_Project..CovidDeaths
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (convert(decimal,total_deaths)/convert(decimal,total_cases))*100 as DeathPercentage
from Portfolio_Project..CovidDeaths
where location like '%states%'
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, total_cases, population, 
(convert(decimal,total_cases)/convert(decimal,population))*100 as PercentPopulationInfected
from Portfolio_Project..CovidDeaths
--where location = 'Germany'
order by 1,2


-- Countries with highest infection rate compared to population

Select Location, population, max(total_cases) as HighestInfectionCount,  
max((convert(decimal,total_cases)/convert(decimal,population)))*100 as PercentPopulationInfected
from Portfolio_Project..CovidDeaths
--where location = 'Germany'
group by Location, population
order by PercentPopulationInfected desc


-- Countries with highest Death Count per Population

Select location,  max(cast(total_deaths as int)) as TotalDeathCount  
--max((convert(decimal,total_cases)/convert(decimal,population)))*100 as PercentPopulationInfected
from Portfolio_Project..CovidDeaths
--where location = 'Germany'
group by location
order by TotalDeathCount desc


-- Break things down by continent

Select continent,  max(cast(total_deaths as int)) as TotalDeathCount  
--max((convert(decimal,total_cases)/convert(decimal,population)))*100 as PercentPopulationInfected
from Portfolio_Project..CovidDeaths
--where location = 'Germany'
where continent != ' '
group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

Select  sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(New_deaths)/Sum(New_cases)*100 as DeathPercentage
from Portfolio_Project..CovidDeaths
--where location like '%states%'
where continent != ' ' --and new_cases !=0
--group by date
order by 1,2


-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
 as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated)*100
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent !=' '
--dea.location ='Germany'
order by 2,3


-- Use CTE

with PopvsVac (Contintent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
 as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated)*100
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent !=' '
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac
where location = 'Germany'


-- Temp Table

drop table if exists #PercentPopulationVaccinated

create table #PercentPopulationVaccinated
(Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations nvarchar(255),
RollingPeopleVaccinated numeric)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
 as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated)*100
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent !=' '
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated
where location = 'Germany'


--Create View to  store data for later visualizations

create view GlobalNumbers as
Select  sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(New_deaths)/Sum(New_cases)*100 as DeathPercentage
from Portfolio_Project..CovidDeaths
--where location like '%states%'
where continent != ' ' --and new_cases !=0
--group by date
--order by 1,2

select *
from GlobalNumbers