SELECT*
FROM [covid19 Project]..COVID_DEATHS
where continent is not null
order by 3,4

--SELECT*
--FROM [covid19 Project]..COVID_VACCINATIONS
--order by 3,4

--select the data that we're going to use

--SELECT Location,date,total_cases,new_cases,total_deaths,population
--FROM [covid19 Project]..COVID_DEATHS
--order by 1,2

--LOOKING AT THE TOTAL CASES VS TOTAL DEATHS
--HOW MANY CASES ARE IN THIS COUNTRY?, AND HOW MANY DEATHS THEY HAVE FOR THE ENTIRE SAMPLES
--WHAT'S THE PERCENTAGE OF PEOPLE THAT DIED BECAUSE OF COVID 19 INFECTION
--THIS SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY
--SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
--FROM [covid19 Project]..COVID_DEATHS
--WHERE location like '%Mexico%'
--order by 1,2

--LOOKING AT THE TOTAL CASES VS POPULATION
--show the percentage of population got covid 19
SELECT location,date,population,total_cases, (total_cases/population)*100 as POPULATIONINFECTED
FROM [covid19 Project]..COVID_DEATHS
--WHERE location like '%Mexico'
order by 1,2

--WHAT COUNTRIES, HAS THE HIGHTES INFECTION RATES COMPARED TO POPULATION

select location,population,MAX(total_cases) AS highestinfectioncount, MAX(total_cases/population)*100 as PERCENTPOPULATIONINFECTED
from [covid19 Project]..COVID_DEATHS
group by location,population
order by PERCENTPOPULATIONINFECTED desc

--SHOWING THE COUNTRIES WITH THE HIGHEST DEATHCOUNT PER POPULATION
--SELECT location,MAX(cast(total_deaths as int)) as TotalDeathcount
--FROM [covid19 Project]..COVID_DEATHS
--where continent is not null
--group by Location
--order by TotalDeathcount desc


--LET'S BREAK THINGS DOWN BY CONTINENT
SELECT continent,max(cast(total_deaths as int)) as TotalDeathcount
 from [covid19 Project]..COVID_DEATHS
 where continent is not null
 group by continent
 order by TotalDeathcount desc

---SHOWING CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION
SELECT continent,population,max(cast(total_deaths as int)) as TOTALDEATHCOUNT
FROM [covid19 Project]..COVID_DEATHS
where continent is not null
group by continent,population
order by TOTALDEATHCOUNT desc


--BREAKING GLOBAL NUMBERS TOTAL DEATH PERCENTAGE PER DAY

select date,SUM(new_cases) as total_newcases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DEATH_PERCENTAGE--total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
from [covid19 Project]..COVID_DEATHS
where continent is not null
group by date
order by 1,2

--TOTAL CASES WORLDWIDE
SELECT SUM(new_cases) as total_new_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(New_deaths as int))/SUM(New_cases)*100 as DeathPercentage
from [covid19 Project]..COVID_DEATHS
where continent is not null
order by 1,2


SELECT*
FROM [covid19 Project]..covidvaccinationsGOODFRAME$

--SO WE JOIN THIS TABLES TOGETHER ON LOCATION AND DATE-
--looking at the total population vs vaccinations
--TOTAL AMOUNT OF PEOPLE IN THE WORLD THAT BEEN VACCINATED

--USING CTE



 SELECT TOP 100000000000000 dea_frame.continent,dea_frame.location,dea_frame.date,dea_frame.population,vac_frame.new_vaccinations
 ,SUM(CONVERT(bigint,vac_frame.new_vaccinations )) OVER (PARTITION by dea_frame.location order by dea_frame.location,dea_frame.date)
 as Rollingpeople_vaccinated
 FROM [covid19 Project]..COVID_DEATHS dea_frame
 join [covid19 Project]..covidvaccinationsGOODFRAME$ vac_frame
   on dea_frame.location=vac_frame.location
   and dea_frame.date=vac_frame.date
 where dea_frame.continent is not null
 order by 2,3
 

WITH popvsvac (continent,location,date,population,new_vaccinations,Rollingpeople_vaccinated)
as
(
SELECT TOP 100000000000000 dea_frame.continent,dea_frame.location,dea_frame.date,dea_frame.population,vac_frame.new_vaccinations
 ,SUM(CONVERT(bigint,vac_frame.new_vaccinations )) OVER (PARTITION by dea_frame.location order by dea_frame.location,dea_frame.date)
 as Rollingpeople_vaccinated
 FROM [covid19 Project]..COVID_DEATHS dea_frame
 join [covid19 Project]..covidvaccinationsGOODFRAME$ vac_frame
   on dea_frame.location=vac_frame.location
   and dea_frame.date=vac_frame.date
 where dea_frame.continent is not null
 order by 2,3
 )

 SELECT*,(Rollingpeople_vaccinated/Population)*100 as PERCENTAGEROLEPEOPLE
 FROM popvsvac

 --TEMP TABLE

 DROP TABLE IF exists PERCENTPOPVACCINATED
 CREATE TABLE PERCENTPOPVACCINATED
 (
 Continent nvarchar(300),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 Rollingpeople_vaccinated numeric
 )
 INSERT INTO PERCENTPOPVACCINATED
 SELECT TOP 100000000000000 dea_frame.continent,dea_frame.location,dea_frame.date,dea_frame.population,vac_frame.new_vaccinations
 ,SUM(CONVERT(bigint,vac_frame.new_vaccinations )) OVER (PARTITION by dea_frame.location order by dea_frame.location,dea_frame.date)
 as Rollingpeople_vaccinated
 FROM [covid19 Project]..COVID_DEATHS dea_frame
 join [covid19 Project]..covidvaccinationsGOODFRAME$ vac_frame
   on dea_frame.location=vac_frame.location
   and dea_frame.date=vac_frame.date
 --where dea_frame.continent is not null
 order by 2,3

  SELECT*,(Rollingpeople_vaccinated/Population)*100 as PERCENTAGEROLEPEOPLE
 FROM PERCENTPOPVACCINATED



 --CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

 CREATE VIEW PERCENTPOPVACCINATED_VIEW AS

  SELECT TOP 100000000000000 dea_frame.continent,dea_frame.location,dea_frame.date,dea_frame.population,vac_frame.new_vaccinations
 ,SUM(CONVERT(bigint,vac_frame.new_vaccinations )) OVER (PARTITION by dea_frame.location order by dea_frame.location,dea_frame.date)
 as Rollingpeople_vaccinated
 FROM [covid19 Project]..COVID_DEATHS dea_frame
 join [covid19 Project]..covidvaccinationsGOODFRAME$ vac_frame
   on dea_frame.location=vac_frame.location
   and dea_frame.date=vac_frame.date
 where dea_frame.continent is not null
 --order by 2,3


 SELECT*
 FROM PERCENTPOPVACCINATED_VIEW