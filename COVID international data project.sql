-- Overall international COVID database
select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

-- Shows percentage liklihood of dying from COVID if tested positive
select location, date, total_cases, total_deaths,(total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- Shows percentage of population in United States that got COVID
select location, date, total_cases, population, (total_cases/population) * 100 as CasePercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- Highest infection rate event for each country
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as CasePercentage
from PortfolioProject..CovidDeaths
-- where location like '%states%'
group by location, population
order by CasePercentage desc

-- Highest Death count per continent
select continent, MAX(cast(total_deaths as int)) as highestDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by highestDeathCount desc

-- Global numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2 

-- total population vs total vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null
order by 2,3


with PopvsVac (Continent, location, date, population, new_vaccinations, rollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null
)
select*, (rollingPeopleVaccinated/population) * 100 as vaccinatedPercent
from PopvsVac


-- Temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255), location nvarchar(255), date datetime, population numeric, new_vaccinations numeric, rollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null

select*, (rollingPeopleVaccinated/population) * 100 as vaccinatedPercent
from #PercentPopulationVaccinated


-- visualizations

drop view if exists PercentPopulationVaccinated;
go
create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.location, dea.date) as rollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null
-- order by 2,3
