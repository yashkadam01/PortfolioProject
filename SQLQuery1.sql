select *
from Portfolioproject..CovidDeaths
where continent is not Null
order by 1,2


select location, date, total_cases, new_cases, total_deaths, population
from Portfolioproject..CovidDeaths
where continent is not Null
order by 1,2

--looking at Total Cases Vs Toatal Deaths

select  location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from Portfolioproject..CovidDeaths
where location like '%india%'
and continent is not Null
order by 1,2

--looking at Total Cases Vs Population
--shows what percentage of population got covid

select  location, date, total_cases, population, (total_deaths/population)*100 percentapopulationinfected
from Portfolioproject..CovidDeaths
where location like '%india%'
and continent is not Null
order by 1,2

--Looking at countries with highest Infection Rate Compared to Popuation

select  location, population, max(total_cases) as Higestinfectioncount, max((total_cases/nullif(population,0)))*100 as percentpopulationinfected
from Portfolioproject..CovidDeaths
group by location, population
where loacation '%states%'
and continent is not Null
order by 1,2

--Showing countries with highest death count per population
--adding is not null coz it shows only countries and not continent.
select location, max(cast(total_deaths as int)) as ToatalDeathcount
from Portfolioproject..CovidDeaths
where continent is not Null
group by location
order by ToatalDeathcount desc

-- LETS BREAK THINGS DOWN BY CONTINENT

select continent, max(cast(total_deaths as int)) as ToatalDeathcount
from Portfolioproject..CovidDeaths
where continent is not Null
group by continent
order by ToatalDeathcount desc

-- GLOBAL NUMBERS
select date, sum(new_cases), sum(cast(new_deaths as int)), sum(cast(new_deaths as int))/sum(new_cases)*100 as  DeathPercentage
from Portfolioproject..CovidDeaths
where continent is not Null
group by date
order by 1,2

select *
from Portfolioproject..CovidVaccinations

-- Test VS Positive Rate

select location, sum(cast(new_tests as int)) as totaltest, max(positive_rate) as positiverate
from Portfolioproject..CovidVaccinations
where continent is not null
group by location
order by positiverate desc

--looking at toatal population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3



select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100
from Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Second line of previous code we new coloum created(rollingpeoplevaccinated) could not be used again on next line for code again so we need to create CTE or temp table

--USE CTE
with PopvsVac (Cointinent, Location, Date, Population,New_vaccination, Rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from PopvsVac

--      OR 

--TEMP TABLE 
drop table if exists #percentagepopulationvaccinated    --this drop syntax helps use when we do altertion after running below code for second time(try running code without 'drop' )
CREATE TABLE #percentagepopulationvaccinated
(
cointinent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccination numeric,
rollingpeoplevaccinated numeric
)
insert into #percentagepopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinated/population)*100
from #percentagepopulationvaccinated

--creating view to store data for later visulatizations

create view percentagepopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
