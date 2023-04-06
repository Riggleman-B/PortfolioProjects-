SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

SELECT location, DATE, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1,2

--LOOKING AT TOTAL CASES VS TOTAL DEATHS

SELECT location, DATE, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%' 
ORDER BY 1,2

--looking at total cases vs population 
--Percentage of population that contracted covid

SELECT Location, DATE, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2

--Looking at countries with highest rates of infection compared to population 


SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected 
FROM PortfolioProject..CovidDeaths
Group by location, population 
order by PercentPopulationInfected desc 

--Showing countries with highest death rate per population 

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHere continent is not null
group by continent
order by TotalDeathCount DESC 


--Global Numbers 

SELECt SUM(new_cases) as total_cases, SUM(cast(NEW_DEATHS as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%' 
Where continent is not null
--group by date
ORDER BY 1,2

--looking at total population cvs vaccinations 
--Use CTE

With popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert( int,vac.new_vaccinations))
over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3
)
Select *, (rollingpeoplevaccinated/population)*100 
From popvsvac

--Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric, 
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert( int,vac.new_vaccinations))
over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location 
and dea.date = vac.date 
--where dea.continent is not null 
--order by 2,3

Select *, (rollingpeoplevaccinated/population)*100 
From #PercentPopulationVaccinated

--creating view to store data for later visualizations
USE PortfolioProject
GO
Create view PercentPopulationVaccinated as  
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert( int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3

Select *
From PercentPopulationVaccinated







