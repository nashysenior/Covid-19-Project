Select *
From CovidVaccinations
Where continent is not null
Order by 3,4

Select *
From CovidDeaths
Where continent is not null
Order by 3,4


--SELECTING DATA THAT WE ARE GOING TO BE USING--
Select  [location], [date], total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null
Order by 1,2


--LOOKING AT TOTAL CASES vs TOTAL DEATHS--
--Shows the likelihood of dying if you contract covid in your country
Select  [location], [date], total_cases, total_deaths , (total_deaths/total_cases)*100 AS DeathPercentage
From CovidDeaths
Where location like '%Zimbabwe%'
and continent is not null
Order by 1,2


--LOOKING AT TOTAL CASES vs POPULATION--
--Shows what percentage of population got covid
Select  [location], [date], [population] ,total_cases , (total_cases/[population])*100 AS PercentagePopulationInfected
From CovidDeaths
--Where location like '%Zimbabwe%'
Where continent is not null
Order by 1,2


--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION--
Select  [location], [population], max(total_cases) AS HighestInfectionCount , max((total_cases/[population]))*100 AS PercentagePopulationInfected
From CovidDeaths
--Where location like '%Zimbabwe%'
Where continent is not null
Group by [location], [population]
Order by PercentagePopulationInfected desc


--SHOWING COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION--
Select  [location], max(cast(total_deaths as int)) as TotalDeathsCount
From CovidDeaths
--Where location like '%Zimbabwe%'
Where continent is not null
Group by [location]
Order by TotalDeathsCount desc


--BREAKING DOWN DEATHS PER CONTINENT PER LOCATION--
Select  continent, [location], max(cast(total_deaths as int)) as TotalDeathsCount
From CovidDeaths
Where continent is not null
Group by continent, [location]
Order by continent


--GLOBAL NUMBERS--
Select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death, sum(cast(new_deaths as int))/sum(new_cases)*100 AS DeathPercentage
From CovidDeaths
--Where location like '%Zimbabwe%'
Where continent is not null
--Group by [date]
Order by 1,2


--JOINING THE 2 TABLES TOGETHER--
--CALCULATING ROLLING VACCINATED PEOPLE--
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(numeric, vac.new_vaccinations )) over (partition by vac.location order by dea.location, dea.date)
as RollingPeopleVaccinated 
From CovidDeaths dea 
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = dea.date
Where dea.continent is not null
order by 2,3


-- USE CTE ( COLUMN TABLE EXPRESSION )--
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) --Population vs Vaccination-- 
as
(
Select dea.continent, dea.[location], dea.[date], dea.[population], vac.new_vaccinations
, sum(cast(vac.new_vaccinations as numeric)) over (partition by dea.[location] order by dea.[location], dea.[date]) as RollingPeopleVaccinated 
From CovidDeaths dea 
Join CovidVaccinations vac
	on dea.[location] = vac.[location]
	and dea.[date] = vac.[date]
Where dea.continent is not null
)
Select * , (RollingPeopleVaccinated/[population])*100 as RollingPercentage
From PopvsVac


--TEMP TABLE--
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
[Location] nvarchar (255),
[Date] datetime,
[Population] numeric,
Vew_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.[location], dea.[date], dea.[population], vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.[location] order by dea.[location], dea.[date])
as RollingPeopleVaccinated 
From CovidDeaths dea 
Join CovidVaccinations vac
	on dea.[location] = vac.[location]
	and dea.[date] = vac.[date]
Where dea.continent is not null
--order by 2,3

Select * , (RollingPeopleVaccinated/[population])*100 as RollingPercentage
From #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS--PercentPopulationVaccinated--
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.[location], dea.[date], dea.[population], vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.[location] order by dea.[location], dea.[date])
as RollingPeopleVaccinated 
From CovidDeaths dea 
Join CovidVaccinations vac
	on dea.[location] = vac.[location]
	and dea.[date] = vac.[date]
Where dea.continent is not null

Select *
From PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS--RollingPeopleVaccinated--
Create View RollingPeopleVaccinated as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(numeric, vac.new_vaccinations )) over (partition by vac.location order by dea.location, dea.date)
as RollingPeopleVaccinated 
From CovidDeaths dea 
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = dea.date
Where dea.continent is not null
)

Select *
From RollingPeopleVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS--DeathsPerContinentPerLocation--
Create View DeathsPerContinentPerLocation as 
(
Select  continent, [location], max(cast(total_deaths as int)) as TotalDeathsCount
From CovidDeaths
Where continent is not null
Group by continent, [location]
)

Select *
From DeathsPerContinentPerLocation
Order by continent


Create View HighestInfectionPerCountry as 
Select  [location], [population], max(total_cases) AS HighestInfectionCount , max((total_cases/[population]))*100 AS PercentagePopulationInfected
From CovidDeaths
--Where location like '%Zimbabwe%'
Where continent is not null
Group by [location], [population]

Select *
From HighestInfectionPerCountry
Order by location
