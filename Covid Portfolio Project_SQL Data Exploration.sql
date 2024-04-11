-- Data Exploration 
-- Data exploration using Covid Deaths and Covid Vaccination data from https://ourworldindata.org/covid-deaths starting from 2020-2021

-- Skill Used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types


-- OBJECTIVE 1:

-- Use CovidDeath dataset to:
-- Find out the likelihood of dying by covid in Indonesia from 2020-2021 using the CovidDeath dataset
-- Look at how many population of Indonesia that contracted with covid from 2020-2021 
-- Find out the global numbers of total cases, total deaths and death percentage from 2020-2021


-- DATA PREPARATION

-- Step one:
-- Open the CSV file that we download from ourworldindata.org/covid-deaths

-- Step two: Create two different datasets by doing these steps
-- First Dataset:
-- --> Find the 'Population' column, select the column and cut and move to the E column and right-click on it and select 'Insert Cut Cells'.
-- --> Delete the columns AA all the way to the last columns and save it as Covid Death.

-- Second Dataset:
-- --> Press 'Ctrl' + 'Z' and then delete the column Z all the way to the E column, right-clik and click/select 'Delete'
-- --> Save it as Covid Vaccination

-- Importing the data to SQL Server Management Studio
-- Step one:
-- Create a database by right-right on the 'Databases' in the 'Object Explorer' and select 'New Database'

-- Step two:
-- Import the first dataset (Covid Death) by right-click on the database and select 'Tasks' => 'Import Data..' =>
-- When the 'SQL Server Import and Export Wizard' popped up, click 'Next>' and on the menu dropdown of 'Data Source:' click the drop down and find 'Microsoft Excel' and select it.
-- On the 'Excel Connection Setting' menu click 'Browse' and find the Covid Death excel file/Dataset and then click 'Next>'.
-- On the 'Destination:' dropdown menu select 'Microsoft OLE DB Provider for SQL Server'.
-- Make sure the Server name is the right server and the database name is also the right database.
-- Click 'Next>'; 'Next>'; 'Next>' and 'Finish' let the process finish and then click 'Close'.
-- The data that have been imported won't show up on the 'Object Explorer' immediately, right-click on the database and select 'Refresh'.


-- CovidDeath data exploration: 

SELECT *
FROM SQLDataExplorationPortfolio.dbo.CovidDeaths
ORDER BY 3,4

SELECT *
FROM SQLDataExplorationPortfolio.dbo.CovidVaccinations
ORDER BY 3,4

-- Lets look at the data but excluding the NULL value on the column Continent

SELECT *
FROM SQLDataExplorationPortfolio.dbo.CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT *
FROM SQLDataExplorationPortfolio.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Select the data (Location, Date, Total Cases, New Cases, Total Deaths and Population) from CovidDeaths dataset

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM SQLDataExplorationPortfolio.dbo.CovidDeaths
ORDER BY 1,2

-- Comparing Total Cases vs Total Deaths to find out the likelihood (percentage) of dying if one's contracted with covid in every country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM SQLDataExplorationPortfolio.dbo.CovidDeaths
ORDER BY 1,2

-- Now lets make it specific and lets check the likelihood of dying in Indonesia if you contracted with covid.

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM SQLDataExplorationPortfolio.dbo.CovidDeaths
WHERE location LIKE '%Indonesia%'
AND continent IS NOT NULL
ORDER BY 1,2

-- Lets look at the Total Cases vs Population to see what percentage of Indonesian population that contracted with covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 as Infected
FROM SQLDataExplorationPortfolio.dbo.CovidDeaths
WHERE location LIKE '%Indonesia%'
ORDER BY 1,2

-- Now, lets look at the Total Cases vs Population to see what percentage of every country around the world that contracted with covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 as Population_Infected
FROM SQLDataExplorationPortfolio.dbo.CovidDeaths
ORDER BY 1,2

-- Move on. Lets look at the Countries with highest infection rate (Total Cases) compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as Population_Infected
FROM SQLDataExplorationPortfolio.dbo.CovidDeaths
GROUP BY Location, population
ORDER BY Population_Infected DESC

-- Lets break things down by Countries with highest total death cases
-- Because some of the column contains NVARCHAR data type, including the total_deaths column, therefore, it has to be change into integer (INT) by using CAST

SELECT Location, MAX(CAST(total_deaths AS INT)) as Total_Death_Count
FROM SQLDataExplorationPortfolio.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY Total_Death_Count DESC

-- Lets break things down by Continent with highest total death count per population

SELECT continent, MAX(CAST(total_deaths AS INT)) as Total_Death_Count
FROM SQLDataExplorationPortfolio.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC

-- Next, lets look at the global numbers of Total Cases, Total Deaths and Death Percentage per day and the total overall (2020-2021).
-- As mentioned before, some of the columns within this dataset are contains VARCHAR value. Therefore, we'll have change it into INT by using CAST and AS INT.

-- 1. The Global numbers of Total Cases, Total Death and Death Percentage per day:
SELECT date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, SUM(CAST(New_deaths AS INT))/SUM(New_Cases)*100 AS Death_Percentage
FROM SQLDataExplorationPortfolio.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- 2. The Global numbers of Total Cases, Total Death and Death Percentage from 2020-2021:

SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, SUM(CAST(New_deaths AS INT))/SUM(New_Cases)*100 AS Death_Percentage
FROM SQLDataExplorationPortfolio.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- The result (1) shows that on 23rd, January, 2020 there are 98 new cases of covid, 1 cases of death caused by covid, and the death percentage is 1.02%.
-- and then the number keep increasing. And the total cases, total deaths and death percentage from 2020-2021 is; 
-- 1. 150.574.977 for the total cases.
-- 2. 3.180.206 for the total deaths.
-- 3. 2.11% as death percentage. 




-- CovidVaccinations DATASET EXPLORATION

-- OBJECTIVE 2:

-- Use CovidVaccination dataset to:
-- Find out how many people that have been vaccinated



-- Looking at Total Population vs Vaccination

-- First, lets join two tables into one (side-by-side)

SELECT *
FROM SQLDataExplorationPortfolio.dbo.CovidDeaths AS Dea
JOIN SQLDataExplorationPortfolio.dbo.CovidVaccinations AS Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date

-- Let's make it easier to look at and add one more column, which will give us an information of how many people vaccinated per day
-- To do that, I will PARTITION BY the column location first because I'm breaking it up by column location and column date. 
-- Therefore, I'll be using aggregate function and other function such as SUM, CONVERT/CAST, PARTITION BY, OVER, etc.
-- In order to do that, I dont want the SUM function keep running and ruin the other number.
-- So, every time it gets to a new location/country the counts will start over

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM SQLDataExplorationPortfolio.dbo.CovidDeaths AS Dea
JOIN SQLDataExplorationPortfolio.dbo.CovidVaccinations AS Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
ORDER BY 2,3


-- Next, use the total number of the last row of every country to find out the percentage of people in that country are vaccinated.
-- Using CTE or TEMP TABLE.

-- 1. CTE.

WITH PopullationvsVaccinated (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
AS
(SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM SQLDataExplorationPortfolio.dbo.CovidDeaths AS Dea
JOIN SQLDataExplorationPortfolio.dbo.CovidVaccinations AS Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL)
SELECT *, (RollingPeopleVaccinated/population)*100 AS Vaccination_Percentage
FROM PopullationvsVaccinated

-- 2. TEMP TABLE

--DROP TABLE IF EXIST #Percentage_of_Population_Vaccinated
CREATE TABLE #Percentage_of_Population_Vaccinated
(continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_Vaccination NUMERIC,
RollingPeopleVaccinated NUMERIC)

INSERT INTO #Percentage_of_Population_Vaccinated
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM SQLDataExplorationPortfolio.dbo.CovidDeaths AS Dea
JOIN SQLDataExplorationPortfolio.dbo.CovidVaccinations AS Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
SELECT *, (RollingPeopleVaccinated/population)*100 AS Vaccination_Percentage
FROM #Percentage_of_Population_Vaccinated


-- Lastly, create View to store data for visualization

CREATE VIEW PercentageofPopulationVaccinated AS
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM SQLDataExplorationPortfolio.dbo.CovidDeaths AS Dea
JOIN SQLDataExplorationPortfolio.dbo.CovidVaccinations AS Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL