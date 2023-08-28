select *
from [covid-19].dbo.[Covid deaths];

alter table [covid-19].[dbo].[Covid deaths]
alter column population bigint;


--Data TYpe Changing and Table formation of "Covid deaths"

alter table [covid-19].[dbo].[Covid deaths]
alter column population bigint;

alter table [covid-19].[dbo].[Covid deaths]
alter column new_cases bigint;

alter table [covid-19].[dbo].[Covid deaths]
alter column total_deaths bigint;

alter table [covid-19].[dbo].[Covid deaths]
alter column new_deaths bigint;

USE [covid-19]
EXEC sp_columns 'Covid deaths'

--DATA UPLODINGTRANSORMATION OF TABLE "COVID VACCINATIONS"

USE [covid-19]
EXEC sp_COLUMNS 'Covid Vaccinations'

--@@@ DATA ANALYSIS @@@
Select location,date,population,total_cases,total_deaths
From [covid-19]..[Covid deaths]
Order by 1,2


-- TOTAL DEATH PERCENTAGE
Select location,date,population,total_cases,total_deaths,(total_deaths*100.0/total_cases) as Deathpercentage
From [covid-19]..[Covid deaths]
Where location like '%Pak%'
Order by 1,2

-- TOTAL CASES VS POPULATION
Select location,date,population,total_cases,total_deaths,(total_cases*100.0/population) as AffectiesPercentage
From [covid-19]..[Covid deaths]
Where location like '%Pak%'
Order by 1,2

-- Total cases of covid by population
Select location,date,population,total_cases,(total_cases*100.0/population) as AffectiesPercentage
From [covid-19]..[Covid deaths]
--Where location like '%Pak%'
Order by 1,2

-- Countries with highest infection rates comapred to population
Select continent,location,population,MAX(total_cases) as highestInfectionCount,MAX((total_cases*100.0/population)) as PopulationAffectedPercentage
From [covid-19]..[Covid deaths]
--Where location like '%Pak%'
Group by location,population,continent
Order by PopulationAffectedPercentage desc  

--Countries with Highest death counts per population
Select location,population,MAX(total_deaths) as TotalDeathsCount
From [covid-19]..[Covid deaths]
Where continent is not null
Group by location,population,continent
Order by TotalDeathsCount desc    


 --LET"S BREAK IT NBY CONTINENT


--Showing the continents with higher death count per population
Select location,MAX(total_deaths) as TotalDeathsCount
From [covid-19]..[Covid deaths]
Where continent is  null
Group by location
Order by TotalDeathsCount desc

-- GLOBAL NUMBERS
--Ratio of new deaths per new cases

Select location,date,SUM(new_cases)as NewCases,
SUM(new_deaths) AS NewDeaths,
(CAST(SUM(new_deaths) AS decimal(10, 2)) / NULLIF(CAST(SUM(new_cases) AS decimal(10, 2)), 0)) AS DeathPercentage
From [covid-19]..[Covid deaths]
--Where location like '%Pak%'
Where continent is not null
Group by location,date
Order by DeathPercentage desc

--USING TABLE COVID VACCINATIONS
--Total population vs total vaccination
-- Commulative date vise sum of New Vaccination
Select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date) as RunningSumOfVaccinations
 From [covid-19]..[Covid deaths] as cd
Join [covid-19]..[Covid Vaccinations] as cv
 on cd.location=cv.location AND
	cd.date=cv.date
Where cd.continent is not null
order by 2,3

--USING CTE 

WITH PopVsVacc (continent,location,date,population,new_vaccinations,CommulativeVaccinations) AS
(
Select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
SUM(CONVERT(float,cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date) as CommulativeVaccinations
 From [covid-19]..[Covid deaths] as cd
Join [covid-19]..[Covid Vaccinations] as cv
 on cd.location=cv.location AND
	cd.date=cv.date
Where cd.continent is not null
--order by 2,3
)
Select *,(CommulativeVaccinations/population)*100 as CommulativeVaccinationPercentage
From PopVsVacc

-- Finding Min and Max Percentage of Coomulative vaccination Percentage of countries
-- Temp table

Drop table if exists #PercentageofCoomulativeVaccinationPercentageofcountries 
Create  table #PercentageofCoomulativeVaccinationPercentageofcountries  
(
location nvarchar(50),
date date,
population numeric,
newvaccination numeric,
CommulativeVaccinations numeric,
CommulativeVaccinationPercentage float )

--Inserting data into Temp Table
Insert Into #PercentageofCoomulativeVaccinationPercentageofcountries 
Select cd.location,cd.date,cd.population,cv.new_vaccinations,
SUM(CONVERT(float,cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.date ) as CommulativeVaccinations,
100.0 * SUM(CONVERT(float,cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.date ) / cd.population as CommulativeVaccinationPercentage
From [covid-19]..[Covid deaths] as cd
Join [covid-19]..[Covid Vaccinations] as cv
 on cd.location=cv.location AND
	cd.date=cv.date
Where cd.continent is not null
--Group By cd.location, cd.date, cd.population, cv.new_vaccinations;

SELECT * FROM #PercentageofCoomulativeVaccinationPercentageofcountries;


--To identify Total percentage of Vaccination for each location
Select pc.location,pc.population,sum(newvaccination) AS Total_vacc,100*(SUM(newvaccination)/population) As "TotalPopulationVaccination %"
From #PercentageofCoomulativeVaccinationPercentageofcountries as pc
GROUP BY pc.location, pc.population;

--Creating Views!!!:)

CREATE TABLE PercentageVaccinationData (
    location nvarchar(50),
    population numeric,
    Total_vacc numeric,
    [Vacc %] float
);
INSERT INTO PercentageVaccinationData (location, population, Total_vacc, [Vacc %])
SELECT location, population, SUM(newvaccination), 100 * (SUM(newvaccination) / population)
FROM #PercentageofCoomulativeVaccinationPercentageofcountries
GROUP BY location, population;

CREATE VIEW PopulationVaccinationPercentage AS
SELECT location, population, Total_vacc, [Vacc %]
FROM PercentageVaccinationData;


Select* FROM PopulationVaccinationPercentage



