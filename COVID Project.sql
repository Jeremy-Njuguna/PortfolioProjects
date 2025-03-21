Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select the data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%States%'
order by 1,2

--Looking at the Total Cases vs Population

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%States%'
Where continent is not null
order by 1,2


--Looking at countries withhighest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%States%'
Where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc

--Showing the Countries with the highest death count per population


Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%States%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Breakin things down by continent
--Showing continents with highest deathcount

Select Continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%States%'
Where continent is not null
Group by Continent
order by TotalDeathCount desc

--Global Numbers

Select SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%States%'
Where continent is not null
--Group by date
order by 1,2

-- Vaccinations
Select *
From PortfolioProject..CovidVaccinations
Where continent is not null
order by 3,4


--Looking at Total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.New_Vaccinations,
SUM(CONVERT(int, vac.New_Vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated --, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


--USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.New_Vaccinations,
SUM(CONVERT(int, vac.New_Vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated --, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3 
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continet nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.New_Vaccinations,
SUM(CONVERT(int, vac.New_Vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated --, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3 

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.New_Vaccinations,
SUM(CONVERT(int, vac.New_Vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated --, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3 


Select*
From PercentPopulationVaccinated

