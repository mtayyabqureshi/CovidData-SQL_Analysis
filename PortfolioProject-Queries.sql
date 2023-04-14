-- Data that is to be used

Select continent,location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
Order By 1,2

-- Total Cases vs Total Deaths
-- Shows the likehood of dying if someone contracts covid
Select continent, location, date, total_cases, total_deaths, ((total_deaths  /CAST (total_cases AS float)) * 100) AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
Order By 1,2


-- Total Cases vs Population
-- Population percantage that got covid
Select continent,location, date,population, total_cases, total_cases / population *100  AS PercentPopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
Order By 1,2


-- Country with highest infection rate compared to population

Select  continent, location ,population,MAX(total_cases) AS HighestInfectionCount,MAX(total_cases / population *100)  AS PercentPopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent,location,population
Order By PercentPopulationInfected DESC


-- Countries with highest death count 

Select continent, location ,MAX(CAST(total_deaths AS int)) AS TotalDeathCount 
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent,location
Order By TotalDeathCount desc


-- Continent with higest death count

Select continent ,MAX(CAST(total_deaths AS int)) AS TotalDeathCount 
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
Order By TotalDeathCount desc


--- Global Numbers

Select date,SUM(new_cases), SUM (new_deaths), 
Case When SUM(new_cases) = 0 THEN NULL
ELSE (SUM(new_deaths) /SUM (new_cases) * 100)  
END AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
Group By date
Order By 1,2


Select SUM(new_cases), SUM (new_deaths), 
Case When SUM(new_cases) = 0 THEN NULL
ELSE (SUM(new_deaths) /SUM (new_cases) * 100)  
END AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
Order By 1,2


-- Yearly total cases and total deaths
Select Year(date) AS CovidYear,MaX(total_cases) AS TotalCases, MAX(CAST(total_deaths AS int)) AS TotalDeathCount 
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Year(date)


-- Total population vs vaccination

Select dea.continent, dea.location, dea.population, vac.new_vaccinations
FROM CovidDeaths AS dea
Join CovidVaccinations AS vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
Order by 1,2,3


Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition By dea.location Order By dea.location, dea.date) AS RollingPeoleVaccinated
FROM CovidDeaths AS dea
Join CovidVaccinations AS vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
Order by 2,3

-- CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccination,RollingPeoleVaccinated) 
AS 
(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition By dea.location Order By dea.location, dea.date ) AS RollingPeoleVaccinated
	FROM CovidDeaths AS dea
	Join CovidVaccinations AS vac
		On dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
)
Select *, (RollingPeoleVaccinated/Population) *100
FROM PopVsVac
Order by 2,3


-- Temp Table

DROP Table if exists #PercentPopulationCaccinated
Create Table #PercentPopulationCaccinated
(Continent nvarchar(255), Location nvarchar(255), Date datetime, 
	Population numeric, New_Vaccination numeric,RollingPeoleVaccinated numeric
)

Insert into #PercentPopulationCaccinated
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition By dea.location Order By dea.location, dea.date ) AS RollingPeoleVaccinated
	FROM CovidDeaths AS dea
	Join CovidVaccinations AS vac
		On dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL

Select *, (RollingPeoleVaccinated/Population) *100
FROM #PercentPopulationCaccinated
Order by 2,3


-- Creating Views to store data

