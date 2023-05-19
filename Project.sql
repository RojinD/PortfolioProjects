Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4


--Select Data that we are going to be using

Select location, date, 
total_cases, new_cases , total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths

Select location, date,
total_cases, total_deaths, (total_deaths/total_cases) *100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%belgium%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

Select location, date, Population,
total_cases, (total_cases/population) *100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%belgium%' and continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select location, Population,
MAX(total_cases) As HighestInfectionCount, 
MAX((total_cases/population)) *100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%belgium%' 
Where continent is not null
GROUP BY location, Population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

Select location, MAX(CAST(Total_deaths AS INT)) As TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%belgium%'
Where continent is not null
GROUP BY location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

--Calculate DeathCount per continent

Select continent, MAX(CAST(Total_deaths AS INT)) As TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%belgium%'
Where continent is not null
GROUP BY continent
order by TotalDeathCount desc


--Calculate TotalDeathCount per location

Select location, MAX(CAST(Total_deaths AS INT)) As TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%belgium%'
Where continent is null
GROUP BY location
order by TotalDeathCount desc

--Showing contintents with the highest death count per population

Select location, MAX(CAST(Total_deaths AS INT)) As TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%belgium%'
Where continent is not null
GROUP BY location
order by TotalDeathCount desc

-- Global numbers

Select  date, SUM(New_Cases) as total_cases, SUM(cast(New_Deaths as int)) as total_deaths, 
 SUM(cast(New_Deaths as int))/SUM(New_Cases)*100 as deathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%belgium%'
Where continent is not null And new_cases <> 0
GROUP BY date
order by 1,2

-- Total cases

Select  SUM(New_Cases) as total_cases, SUM(cast(New_Deaths as int)) as total_deaths, 
 SUM(cast(New_Deaths as int))/SUM(New_Cases)*100 as deathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%belgium%'
Where continent is not null And new_cases <> 0
--GROUP BY date
order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null And dea.location like '%canada%'
and dea.date > '2023-01-01'
order by 2,3


--Looking at Total New Vaccinations per day with partitio by

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null And dea.location like '%canada%'
and dea.date > '2023-01-01'
order by 2,3

--Looking at Total New Vaccinations per day with convert

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations))
OVER (Partition by dea.location order by dea.location, dea.Date) 
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and dea.location like '%canada%'
and dea.date > '2023-01-01'
order by 2,3

-- USE CTE Ratio of Vaccination Vrs Population

With PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations))
OVER (Partition by dea.location order by dea.location, dea.Date) 
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and dea.location like '%canada%'
and dea.date > '2023-01-01'
--order by 2,3
)
Select * , (RollingPeopleVaccinated/Population) * 100 as VaccinatedRatio
From PopvsVac

-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations))
OVER (Partition by dea.location order by dea.location, dea.Date) 
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and dea.location like '%canada%'
and dea.date > '2023-01-01'

Select * , (RollingPeopleVaccinated/Population) * 100 as VaccinatedRatio
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations))
OVER (Partition by dea.location order by dea.location, dea.Date) 
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and dea.location like '%canada%'
and dea.date > '2023-01-01'

Select *
From PercentPopulationVaccinated