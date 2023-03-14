select * from coviddeaths
order by 3,4 asc
limit 10

select * from covidvaccinations
order by 3,4 asc
limit 10

-- select data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
order by 1,2

-- looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths,
(total_deaths::numeric/total_cases::numeric)*100 as Deaths_Percentage
from coviddeaths
where location like 'Indonesia'
and continent is not null
order by 1,2

-- looking at total cases vs population
-- shows what percentage of population infected by covid
select location, date, total_cases, population, 
(total_deaths::numeric/population::numeric)*100 as infection_rate
from coviddeaths
where location like 'Indonesia'
order by 1,2

-- looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestinfectionCount, 
	max((total_cases::numeric/population::numeric))*100 as Percent_Population_infected
from coviddeaths
where continent is not null 
group by location, population
having max(total_cases) is not null
order by Percent_Population_infected desc

-- Showing the countries with the highest death count per population
select location, max(total_deaths) as Total_Death_Count
from coviddeaths
where continent is not null
group by location
having max(total_deaths) is not null
order by Total_Death_Count desc

-- Break things down by continent
-- Showing continents with the highest death count per population
select continent, max(total_deaths) as Total_Death_Count
from coviddeaths
where continent is not null
group by continent
order by Total_Death_Count desc

-- Global Numbers
select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
where continent is not null
order by 1,2

-- Total cases, total deaths, and deaths percentage in the world
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, 
	(sum(new_deaths)::numeric/sum(new_cases)::numeric)*100 as death_percentage
from coviddeaths
where continent is not null

-- percentage of daily deaths by covid in the world
select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, 
	(sum(new_deaths)::numeric/sum(new_cases)::numeric)*100 as deathpercentage
from coviddeaths
where continent is not null
group by date
order by 1,2

-- Join
select *
from coviddeaths dea join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date

-- Looking at Total Population vs Total Vaccinations
select dea.continent, dea.location, dea.date, vac.new_vaccinations, 
	sum(vac.new_vaccinations) over 
	(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths dea join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- Use CTE
with PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(vac.new_vaccinations) over 
	(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths dea join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3
)
select *, (rollingpeoplevaccinated::numeric/population::numeric)*100 as percentpeoplevaccinated
from PopvsVac

-- Create Temporary Table

create table percentpeoplevaccinated
(
continent varchar(255),
location varchar(255),
date date,
population bigint,
new_vaccinations int,
rollingpeoplevaccinated int
)

insert into percentpeoplevaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(vac.new_vaccinations) over 
	(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths dea join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *
from percentpeoplevaccinated


create view percentpeoplevaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(vac.new_vaccinations) over 
	(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths dea join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *
from percentpeoplevaccinated

