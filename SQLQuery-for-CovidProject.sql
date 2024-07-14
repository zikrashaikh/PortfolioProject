select * from Covid19Project..CovidDeaths
order by 3,4

 --select * from Covid19Project..CovidVaccinations order by 3,4

 select location, date, total_cases,new_cases, total_deaths, population from CovidDeaths order by 1,2

 -- looking at total cases vs. total deaths
 -- likelihood of contracting covid in ur country
  select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100  as DeathsPercentage from CovidDeaths 
  where location like '%states%'
  order by 1,2

  -- looking at total cases vs. population
  --shows what percentage of population got covid
   select location, date, total_cases,population, (total_cases/population)*100  as DeathsPercentageByPopulation from CovidDeaths 
  where location like '%states%'
  order by 1,2

  --looking at countries with highest infection rate compared to population
  select location,population,max(total_cases) as HighestInfectedCount , max((total_cases/population))*100 
  as PercentPopulationInfected
  from Covid19Project..CovidDeaths
  group by location, population
  order by PercentPopulationInfected desc

  --showing countries with highest death count as per population
    select location, max(cast(total_deaths as int)) as TotalDeathCount
  from Covid19Project..CovidDeaths
  where continent is not null
  group by location
  order by TotalDeathCount desc

  
  --showing continents with highest death count per population

     select continent, max(cast(total_deaths as int)) as TotalDeathCount
  from Covid19Project..CovidDeaths
  where continent is  not null
  group by continent
  order by TotalDeathCount desc

  -- global numbers
select  date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths , sum(cast(new_deaths as int))/ SUM(new_cases)* 100  as DeathPercentage from CovidDeaths 
 -- where location like '%states%'
 where continent is not null
 group by date
  order by 1,2 

  -- Total Population vs Vaccinations
  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
  SUM(CONVERT(int,vac.new_vaccinations))  over (partition by dea.location  Order by dea.location, dea.Date) as RollingPeopleVaccinated
  from Covid19Project..CovidDeaths dea
  join
  Covid19Project..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
  SUM(CONVERT(int,vac.new_vaccinations))  over (partition by dea.location  Order by dea.location, dea.Date) as RollingPeopleVaccinated
  from Covid19Project..CovidDeaths dea
  join
  Covid19Project..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

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
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
  SUM(CONVERT(int,vac.new_vaccinations))  over (partition by dea.location  Order by dea.location, dea.Date) as RollingPeopleVaccinated
  from Covid19Project..CovidDeaths dea
  join
  Covid19Project..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
 -- where dea.continent is not null

 Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
Create View 
PercentPopulationVaccinated 
as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid19Project..CovidDeaths dea
Join Covid19Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 