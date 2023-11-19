select* 
from coviddeaths 
where continent IS NOT NULL 
-- AND TRIM(continent) <> ''
-- Originally empty spaces were not set as null so I used this commant but it was too much of a hasttle in the future so I just amended that
order by 3,4;

UPDATE coviddeaths SET continent = NULL WHERE continent = '';


/* Select* 
from covidvaccinations
order by 3,4 */

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths 
order by 1,2;

-- Looking at total cases vs total deaths 
-- shows change of death after contracting covid 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from coviddeaths 
where location like '%bulgaria%'
order by 1;


-- Looking at total cases vs population
-- population contraction percentage 
select location, date, population, total_cases, (total_cases/population)*100 as Contraction_Percentage
from coviddeaths 
where location like '%bulgaria%'
order by 1;

-- Looking at Countries with highest infection rate compared to population 
select location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Perfcentage_Infected_Population
from coviddeaths 
group by Location, Population
order by Perfcentage_Infected_Population desc;


-- Countries with highest death count per population
select location, max(cast(total_deaths as UNSIGNED)) as Total_Death_Count 
-- had to ammend to intiger due to data type  
from coviddeaths 
where continent IS NOT NULL 
-- AND TRIM(continent) <> ''
-- got rid of continent grouping located in the location section and not the seperate continent section
group by Location, Population
order by Total_Death_Count desc;



-- Calculations by continuent 
select location, max(cast(total_deaths as UNSIGNED)) as Total_Death_Count,
 MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Perfcentage_Infected_Population
from coviddeaths 
where continent IS NULL 
-- Continent tab it seems was not correct so I am using the alredy agregated numbers located in the location tab
group by location
order by Total_Death_Count desc;



-- Global Number
select date, sum(new_cases) as Cases, sum(new_deaths) as Deaths, sum(new_deaths)/sum(new_cases)*100 as Death_Percentage
-- as sum max on total cases would not work we had to be creative so sum(new_cases)
from coviddeaths 
-- where location like '%bulgaria%'
where continent IS not NULL 
group by date
order by 1;


-- Lets start using our other table 
select *
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date;
    
-- Looking at total population vs vaccination 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(vac.new_vaccinations) Over (Partition by dea.location order by dea.location,
dea.date) as Rolling_Vaccinated_people
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3;


With PopvsVac (continent, location, date, population, new_vaccinations, Rolling_Vaccinated_people)
as
( 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(vac.new_vaccinations) Over (Partition by dea.location order by dea.location,
dea.date) as Rolling_Vaccinated_people
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
)
select*, (Rolling_Vaccinated_people/population) as Percent_Vaccinated_Population
from popvsvac;



--
-- Views for visualisations
--


create view Percent_Vaccinated_Population as
With PopvsVac (continent, location, date, population, new_vaccinations, Rolling_Vaccinated_people)
as
( 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(vac.new_vaccinations) Over (Partition by dea.location order by dea.location,
dea.date) as Rolling_Vaccinated_people
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
)
select*, (Rolling_Vaccinated_people/population) as Percent_Vaccinated_Population
from popvsvac;

create view Global_Death_Contraction as
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage, (total_cases/population)*100 as Contraction_Percentage
from coviddeaths 
order by 1;

create view Global_Total_Death as
select location, max(cast(total_deaths as UNSIGNED)) as Total_Death_Count 
from coviddeaths 
where continent IS NOT NULL 
group by Location, Population
order by Total_Death_Count desc;

create view Continent_Total_Death as
select location, max(cast(total_deaths as UNSIGNED)) as Total_Death_Count,
 MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Perfcentage_Infected_Population
from coviddeaths 
where continent IS NULL 
group by location
order by Total_Death_Count desc;

create view View_by_Date as
select date, sum(new_cases) as Cases, sum(new_deaths) as Deaths, sum(new_deaths)/sum(new_cases)*100 as Death_Percentage
from coviddeaths 
where continent IS not NULL 
group by date
order by 1;
