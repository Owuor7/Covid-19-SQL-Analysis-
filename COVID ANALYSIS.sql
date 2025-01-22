-- Switching to the relevant database
USE [Potfolio project]

-- Querying all data from the CovidDeaths table where continent information is present, sorted by columns 3 and 4
select * from CovidDeaths
WHERE continent is not null
order by 3,4

--select * from CovidVaccinations 
--order by 3,4

-- Selecting key fields from the CovidDeaths table to use in analysis, sorted by location and date

select location, date, total_cases, new_cases,total_deaths,population
from CovidDeaths
WHERE continent is not null
order by 1,2

-- Analyzing the total cases vs. total deaths to determine the likelihood of dying 

select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from CovidDeaths
where location like 'Kenya'
order by 1,2

--total cases vs population(percentage of people who got covid)
select location, date, population, total_cases,(total_cases/population)*100 as victimpercentage 
from CovidDeaths
--where location like 'Kenya'
order by 1,2

-- Analyzing new cases vs. new deaths to determine daily mortality rates
select location,population,max (total_cases) as highestinfectioncount,max((total_cases/population))*100 as percentpopulationinfected

from CovidDeaths
--where location like 'Kenya'
group by location,population
order by percentpopulationinfected desc 


-- Global population analysis by continent

select continent,max(total_deaths) as Totaldeathcount
from CovidDeaths
--where location like 'Kenya'
WHERE continent is not null
group by Continent 
order by Totaldeathcount desc 



---continent  with the highest deaths count per population
select Location,max(total_deaths) as Totaldeathcount
from CovidDeaths
--where location like 'Kenya'
WHERE continent is null
group by Location
order by Totaldeathcount desc 

---global numbers 
select date, sum(new_cases) as  total_cases,sum(new_deaths) as total_deaths, sum(new_deaths)/ sum(new_cases)*100 as deathpercentage
from CovidDeaths
--where location like 'Kenya'
where continent is not null
group by date 
order by 1,2


---global numbers 
select sum(new_cases) as  total_cases,sum(new_deaths) as total_deaths, sum(new_deaths)/ sum(new_cases)*100 as deathpercentage
from CovidDeaths
--where location like 'Kenya'
where continent is not null
order by 1,2

---merge tables 

Select *
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date

---looking at total population vs vaccination

Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations 
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 
order by 2,3

--partition by location
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 
order by 2,3

--USE CTE(COMMON TABLE EXPRESSIONS)
with popvsvac (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as
(
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 
---order by 2,3
)
select * ,(rollingpeoplevaccinated/population)*100
from popvsvac


---TEMP TABLE 
drop table if exists #percentpopulationvaccinated 

create table #percentpopulationvaccinated 
(
continent nvarchar(255),
location  nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
insert into #percentpopulationvaccinated
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 
---order by 2,3

select * ,(rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated



----create view to store data fro later visualizations 
create view percentpopulationvacinated as 
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 
---order by 2,3

select * from percentpopulationvacinated


