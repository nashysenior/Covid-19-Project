Select *
From CovidVaccinations
Order by 3,4

Select *
From CovidDeaths
Where continent is not null
Order by 3,4


--Select Data that we are going to be using
Select  [location], [date], total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null
Order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country
Select  [location], [date], total_cases, total_deaths , (total_deaths/total_cases)*100 AS DeathPercentage
From CovidDeaths
Where location like '%Zimbabwe%'
and continent is not null
Order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid
Select  [location], [date], [population] ,total_cases , (total_cases/[population])*100 AS PercentagePopulationInfected
From CovidDeaths
--Where location like '%Zimbabwe%'
Where continent is not null
Order by 1,2

--Looking at countries with highest infection rate compared to population
Select  [location], [population], max(total_cases) AS HighestInfectionCount , max((total_cases/[population]))*100 AS PercentagePopulationInfected
From CovidDeaths
--Where location like '%Zimbabwe%'
Where continent is not null
Group by [location], [population]
Order by PercentagePopulationInfected desc

--Showing countries with the highest death count per population 
Select  [location], max(cast(total_deaths as int)) as TotalDeathsCount
From CovidDeaths
--Where location like '%Zimbabwe%'
Where continent is not null
Group by [location]
Order by TotalDeathsCount desc

--Breaking down per continent--
Select  continent, max(cast(total_deaths as int)) as TotalDeathsCount
From CovidDeaths
--Where location like '%Zimbabwe%'
Where continent is not null
Group by continent
Order by TotalDeathsCount desc


--GLOBAL NUMBERS--
Select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death, sum(cast(new_deaths as int))/sum(new_cases)*100 AS DeathPercentage
From CovidDeaths
--Where location like '%Zimbabwe%'
Where continent is not null
--Group by [date]
Order by 1,2

--JOINING THE 2 TABLES TOGETHER--
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by vac.location order by dea.location, dea.date)
as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
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
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.[location] order by dea.[location], dea.[date])
as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea 
Join CovidVaccinations vac
	on dea.[location] = vac.[location]
	and dea.[date] = vac.[date]
Where dea.continent is not null
--order by 2,3
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
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea 
Join CovidVaccinations vac
	on dea.[location] = vac.[location]
	and dea.[date] = vac.[date]
Where dea.continent is not null
--order by 2,3

Select * , (RollingPeopleVaccinated/[population])*100 as RollingPercentage
From #PercentPopulationVaccinated

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS--
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.[location], dea.[date], dea.[population], vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.[location] order by dea.[location], dea.[date])
as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea 
Join CovidVaccinations vac
	on dea.[location] = vac.[location]
	and dea.[date] = vac.[date]
Where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated