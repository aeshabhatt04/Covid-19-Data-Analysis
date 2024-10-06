select *
from [dbo].[CovidDeaths]
where continent is not null
order by 3,4

--select * 
--from [dbo].[CovidVaccination]
--order by 3,4

select location,
       date,
       total_cases,
       new_cases,
       total_deaths,
       population
from [dbo].[CovidDeaths]
where continent is not null
order by 1,
         2

--Total cases vs deaths
select location,
       date,
       total_cases,
       total_deaths,
       (total_deaths / total_cases) * 100 as DeathPercentage
from [dbo].[CovidDeaths]
--where location='India'
where continent is not null
order by 1,
         2

--total cases vs population, it shows what percentage of population got infected
select location,
       date,
       Population,
       total_cases,
       (total_deaths / total_cases) * 100 as InfectedPopulationPercentage
from [dbo].[CovidDeaths]
--where location='India'
where continent is not null
order by 1,2

--Country that has highest infected rates
select location,
       Population,
       max(total_cases) as HighestInfectedCount,
       max((total_cases / population) * 100) as InfectedPopulationPercentage
from [dbo].[CovidDeaths]
--where location='India'
where continent is not null
group by location,
         population
order by InfectedPopulationPercentage desc
--countries with highest death counts per population
select location,
       max(cast(total_deaths as int)) as TotalDeaths
from [dbo].[CovidDeaths]
--where location='India'
where continent is not null
group by location
order by TotalDeaths desc

--shows the continents with highest death counts per population
select continent,
       max(cast(total_deaths as int)) as TotalDeathCount
from [dbo].[CovidDeaths]
--where location='India'
where continent is not null
group by continent
order by TotalDeathCount desc

--sum of new cases per date and new deaths
select date,
       sum(new_cases) as TotalNewCases,
       sum(cast(new_deaths as int)) as TotalNewDeaths,
       sum(cast(new_deaths as int)) / sum(new_cases) * 100 as DeathPercent
from [dbo].[CovidDeaths]
--where location='India'
where continent is not null
group by date
order by 1,2

--total population vs vaccinations


--Using CTE

with PopulationVSVaccination (Continent, location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as (select cd.continent,
           cd.location,
           cd.date,
           cd.population,
           cv.new_vaccinations,
           sum(cast(new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
    from [dbo].[CovidDeaths] cd
        Join [dbo].[CovidVaccination] cv
            on cd.location = cv.location
               and cd.date = cv.date
    where cd.continent is not null
   --order by 2,3
   )
select *,
       (RollingPeopleVaccinated / Population) * 100
from PopulationVSVaccination

--temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    New_vaccinations numeric,
    RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select cd.continent,
       cd.location,
       cd.date,
       cd.population,
       cv.new_vaccinations,
       sum(cast(new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from [dbo].[CovidDeaths] cd
    Join [dbo].[CovidVaccination] cv
        on cd.location = cv.location
           and cd.date = cv.date
--where cd.continent is not null
--order by 2,3

select *,
       (RollingPeopleVaccinated / Population) * 100
from #PercentPopulationVaccinated

--creating view to check the highest death due to covid per continent
create view highestdeath
as(
select continent,
       max(cast(total_deaths as int)) as TotalDeathCount
from [dbo].[CovidDeaths]
--where location='India'
where continent is not null
group by continent)
--order by TotalDeathCount desc

select *
from highestdeath
