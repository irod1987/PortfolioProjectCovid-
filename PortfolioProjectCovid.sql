select * 
from CovidDeaths
where continent is not null

select [location], [date], [total_deaths], [total_cases], (total_deaths/total_cases)*100
from [dbo].[CovidDeaths]
order by 1, 2

--Death Percentage
select [location], [date], [total_deaths], [total_cases], ([total_deaths]/nullif([total_cases], 0))*100 as DeathPercentage
from PortfolioProjectCovid..CovidDeaths
where location = 'United States'
order by total_cases

--looking at Total Cases vs Population
--Shows what percentage of population got Covid
select [location], [date], [total_deaths], [total_cases], population, ([total_cases]/ [population])*100 as PercentPopulationInfected
from PortfolioProjectCovid..CovidDeaths
where location = 'United States'
order by total_cases
go

--Looking at countries with highest Infection Rate compared to population
select  [location], max([total_cases]) as HighestInfectionCount, population, max(([total_cases]/ nullif([population], 0)))*100 as PercentPopulationInfected
from PortfolioProjectCovid..CovidDeaths
--where location = 'United States'
group by [location], [date], [total_deaths], population, [total_cases]
order by PercentPopulationInfected desc



--Showing the continents with the highest death count
select  [continent], MAX([total_deaths]) as TotalDeathCount 
from PortfolioProjectCovid..CovidDeaths
where continent is not null
--where location = 'United States'
group by [continent]
order by TotalDeathCount desc

--GLOBAL NUMBERS

select cast(date as datetime), sum(cast(new_cases as float)) as total_cases, sum (cast(new_deaths as float)) as total_deaths,
sum(cast(new_deaths as float))/ nullif(sum(cast(new_cases as float)), 0)*100 as DeathPercentage
from PortfolioProjectCovid..CovidDeaths
where continent is not null
group by date 
order by 1, 2


--Looking at Total Population Vs Vaccinations 


--USE CTE
with PopVsVac (Continent, location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as float)) 
OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProjectCovid..CovidDeaths as dea
join PortfolioProjectCovid..Covidvaccinations as vac
	on dea.location = vac.location 
	and dea.date = vac.date 
where dea.location NOT IN  ('Africa', 'Asia', 'Europe', 'European Union', 'High Income', 'International', 'Low Income', 'Lower middle income', 'North America',
'Oceania', 'South America', 'Upper middle income', 'World')
--order by 1, 2, 3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopVsVac


--TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime, 
Population float,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as float)) 
OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProjectCovid..CovidDeaths as dea
join PortfolioProjectCovid..Covidvaccinations as vac
	on dea.location = vac.location 
	and dea.date = vac.date 
where dea.location NOT IN  ('Africa', 'Asia', 'Europe', 'European Union', 'High Income', 'International', 'Low Income', 'Lower middle income', 'North America',
'Oceania', 'South America', 'Upper middle income', 'World')
--order by 1, 2, 3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--Creating View to store data for later visulaizations
create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as float)) 
OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProjectCovid..CovidDeaths as dea
join PortfolioProjectCovid..Covidvaccinations as vac
	on dea.location = vac.location 
	and dea.date = vac.date 
where dea.location NOT IN  ('Africa', 'Asia', 'Europe', 'European Union', 'High Income', 'International', 'Low Income', 'Lower middle income', 'North America',
'Oceania', 'South America', 'Upper middle income', 'World')
--order by 1, 2, 3

select * 
from PercentPopulationVaccinated