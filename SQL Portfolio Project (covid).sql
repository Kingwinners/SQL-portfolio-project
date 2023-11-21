select * from PortfolioProject..CovidDeaths
where continent is not null
--order by 3,4


--select * from PortfolioProject..CovidVaccinations
--order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2


--TEMP TABLE
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
New_vaccination numeric,
rollingpeoplevaccinated numeric
) insert into #percentpopulationvaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
,sum(cONVERT(INT,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,
dea.date) as rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths dea
join
PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *, (rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated


--Total cases vs total deaths 
--SHOWS THE LIKLYHOOD OF DYING IF YOU CONTACT COVID IN THIS COUNTRY
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--looking at the totalcases vs population
--SHOWS WHAT PERCENTAGE OF THE POPULATUION HAS GOTTEN COVID
select location,date,population,total_cases,(total_cases/population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2

--LOOKING COUNTRIES WIYH HIGHEST INFECTION RATE COMPARED TO POPULATION

Select location,population,MAX(total_cases) AS Highestinfectioncount, max((total_cases/population))*100 as
 percentpopulationinfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
GROUP BY location,population
order by percentpopulationinfected DESC

--letd break things doen by continnet

---Showing countries with the highest death count per population
Select continent,max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%states%'
GROUP BY continent
order by totaldeathcount DESC

--GLOBAL NUMBERS
select date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%states%' 
ORDER BY 1,2
--LETS JOIN OUR TABLES
SELECT * 
FROM PortfolioProject..CovidDeaths dea
join
PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date

--looking at total population vs vaccination
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
,sum(cONVERT(INT,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,
dea.date) as rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths dea
join
PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE
with popvsvac (continent, location, date,population,New_vaccination,rollingpeoplevaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
,sum(cONVERT(INT,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,
dea.date) as rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths dea
join
PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select * 
from popvsvac


--creating view to store data for later vizualization 1
create view percentpopulationvaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
,sum(cONVERT(INT,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,
dea.date) as rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths dea
join
PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

-- VIEW 2
create view deathpollinthestates as
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
--order by 1,2

--VIEW 3
create view continentwithhighestdeathcount as
Select continent,max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%states%'
GROUP BY continent
--order by totaldeathcount DESC 