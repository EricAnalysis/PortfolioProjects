

Select *
From CovidDeaths
Where continent is not null 
order by 3,4 

--Select * 
--From CovidVaccinations
--order by 3,4 

-- Select Data that we are going to be using 

Select Location, date, total_cases, new_cases,total_deaths, population
From CovidDeaths
Where continent is not null 
order by 1,2

-- Looking at Total Cases vs Total Deaths 
-- Shows likelihood of dying if you contract Covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%states%' and continent is not null 
order by 1,2


-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From CovidDeaths
-- Where location like '%states%'
Where continent is not null 
order by 1,2



-- Looking at Countries with Highest Infection Rate Compared to Population 
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
From CovidDeaths
-- Where location like '%states%'
Where continent is not null 
Group by Location, Population
order by PercentagePopulationInfected desc



-- Showing Countries with the Highest Death Count per Population 

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
-- Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc


-- Breaking things out by Continent

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is null 
Group by location
order by TotalDeathCount desc

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- Showing Continents with the Highest Death Count per Population
Select Continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
-- Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- Looking at Continnents with Highest Infection Rate Compared to Population 
Select continent, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
From CovidDeaths
-- Where location like '%states%'
Where continent is not null 
Group by continent, Population
order by PercentagePopulationInfected desc


-- Global Numbers 
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths
-- Where location like '%states%' 

Where continent is not null 
Group By date
order by 1,2

-- Global Death Percentage 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths
Where continent is not null 
order by 1,2


-- Looking at Total Population vs Vaccinations 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.Location Order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
order by 2,3

-- USE CTE 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinted)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.Location Order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
-- order by 2,3
)
Select *, (RollingPeopleVaccinted/Population)*100
From PopvsVac

-- Temp Table 

DROP Table if exists #PercentPopulationVaccined
Create Table #PercentPopulationVaccined
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime, 
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccined
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.Location Order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
-- order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccined


-- Creating View to store date for late visulizations

Create View #PercentPopulationVaccined as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.Location Order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
-- order by 2,3
