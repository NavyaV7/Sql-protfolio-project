Select * From PortfolioProject..CovidDeaths order by 3,4

Select * From PortfolioProject..CovidVaccinations order by 3,4

-- Select Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
order by 1,2

--Observing deathpercentage of particular country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like 'i%a'
order by 1,2

--what percentage of population got covid (specified country)
Select Location, date, population, total_cases,(total_cases/population)*100 as AffectedPercentage
From PortfolioProject..CovidDeaths
Where location like 'i%a'
order by 1,2

--what percentage of population got covid (overall)
Select Location, date, population, total_cases,(total_cases/population)*100 as InfectedPercentage
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at countries with highest infection rate compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPercentage
From PortfolioProject..CovidDeaths
Group by Location, population
order by InfectedPercentage desc

--Looking at countries with highest death count compared to population
Select Location, population, MAX(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by Location, population
order by HighestDeathCount desc

--Global wise analysis of new cases and deaths by date
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast
(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
Group By date
order by 1,2

--Global wise analysis of new cases and deaths 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast
(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


Select * From PortfolioProject..CovidVaccinations

--Join
Select 
* From PortfolioProject..CovidDeaths Death
  Join PortfolioProject..CovidVaccinations Vaccination
      On Death.location = Vaccination.location
	  and Death.date = Vaccination.date

--Looking at Total Population vs New Vaccination
Select Death.continent, Death.location, Death.date, Death.population, Vaccination.new_vaccinations  
 From PortfolioProject..CovidDeaths Death
  Join PortfolioProject..CovidVaccinations Vaccination
      On Death.location = Vaccination.location
	  and Death.date = Vaccination.date
	  where Death.continent is not null
	  order by 2,3

--Enroll count of vaccinations
Select Death.continent, Death.location, Death.date, Death.population, Vaccination.new_vaccinations
 , SUM(CONVERT(int, Vaccination.new_vaccinations)) OVER (Partition by Death.Location Order by Death.location, Death.date)
   as enroll_countofvaccination
 From PortfolioProject..CovidDeaths Death
  Join PortfolioProject..CovidVaccinations Vaccination
      On Death.location = Vaccination.location
	  and Death.date = Vaccination.date
	  where Death.continent is not null
	  order by 2,3

--
With PopvsVac (Continent, location, date, population, new_vaccinations, enroll_countofvaccination)
as
(
Select Death.continent, Death.location, Death.date, Death.population, Vaccination.new_vaccinations
 , SUM(CONVERT(int, Vaccination.new_vaccinations)) OVER (Partition by Death.Location Order by Death.location, Death.date)
   as enroll_countofvaccination
 From PortfolioProject..CovidDeaths Death
  Join PortfolioProject..CovidVaccinations Vaccination
      On Death.location = Vaccination.location
	  and Death.date = Vaccination.date
	  where Death.continent is not null
)
Select * , (enroll_countofvaccination/population)*100
From PopvsVac


-- Temp table

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
enroll_countofvaccination numeric
)

Insert into #PercentPopulationVaccinated
Select Death.continent, Death.location, Death.date, Death.population, Vaccination.new_vaccinations
 , SUM(CONVERT(int, Vaccination.new_vaccinations)) OVER (Partition by Death.Location Order by Death.location, Death.date)
   as enroll_countofvaccination
 From PortfolioProject..CovidDeaths Death
  Join PortfolioProject..CovidVaccinations Vaccination
      On Death.location = Vaccination.location
	  and Death.date = Vaccination.date
	
Select * , (enroll_countofvaccination/population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
Select Death.continent, Death.location, Death.date, Death.population, Vaccination.new_vaccinations
 , SUM(CONVERT(int, Vaccination.new_vaccinations)) OVER (Partition by Death.Location Order by Death.location, Death.date)
   as enroll_countofvaccination
 From PortfolioProject..CovidDeaths Death
  Join PortfolioProject..CovidVaccinations Vaccination
      On Death.location = Vaccination.location
	  and Death.date = Vaccination.date
where Death.continent is not null

Select * From PercentPopulationVaccinated





