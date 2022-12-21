-- COVID 19 EXPLORATION

  	select * from Project101..CovidDeaths
	where continent is not null


-- selecting data we need:

	select location,date, total_cases,new_cases,total_deaths,population
	from Project101..CovidDeaths
	where continent is not null
	order by 1,2
 
--Exploring total cases vs total deaths:

	select location,date, total_cases,total_deaths
	from Project101..CovidDeaths
	where continent is not null and location='india'
	order by 1,2

-- Exploring chances of death if you're infected in a specific country

	select location,date, total_cases,total_deaths,
	(total_deaths/total_cases)*100 as deathpercentage
	from Project101..CovidDeaths
	where location='india' and continent is not null
	order by 1,2 
-----------------------------------------------------------------------------------------------------------------------------
--Exploring total cases vs popolation

-- Analyzing what percentage of population gets covid in a specific country

	select location,date, total_cases,population,(total_cases/population)*100 as infectionpercentage
	from Project101..CovidDeaths
	where location='india' and continent is not null
	order by 1,2

-- Checking for highest infection rate

	select location,Max(total_cases) as HighestInfection,population,MAX((total_cases/population))*100 
	as HighestInfectionpercentage from 
	Project101..CovidDeaths
	where continent is not null
	group by location,population
	order by HighestInfectionpercentage desc

-- Highest infection date in a specific country (india)

	select location,date,MAX(total_cases) HighestInfection,MAX((total_cases/population))*100 
	as HighestInfectionpercentage from Project101..CovidDeaths
	where location='india' and continent is not null
	group by location,date,population
	order by HighestInfectionpercentage desc

-- Countries with highest death count per population

	select location,Max(cast(total_deaths as bigint)) as highestdeath
	from Project101..CovidDeaths
	where continent is not null
	group by location
	order by highestdeath desc
--------------------------------------------------------------------------------------------------------------------------------------------------------
-- EXPLORING DATASET ON THE BASIS OF CONTINENTS 

-- Countries with highest death count per population

	select continent,Max(cast(total_deaths as bigint)) as highestdeath	
	from Project101..CovidDeaths
	where continent is not null
	group by continent
	order by highestdeath desc
------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL NUMBERS

-- Total cases,deaths and percentage of the world
	select SUM(new_cases) as total_cases, 
	SUM(cast(new_deaths as bigint)) as total_deaths,
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 Deathpercentage
	from Project101..CovidDeaths
	where continent is not null
	order by 1,2 

-- Date by date analyzation of total cases,deaths and percentage

	select date,SUM(new_cases) as total_cases, 
	SUM(cast(new_deaths as bigint)) as total_deaths,
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 Deathpercentage
	from Project101..CovidDeaths
	where continent is not null
	group by date
	order by 1,2 
---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- JOINING TWO TABLES ( COVID REPORT TABLE AND VACCINATION REPORT TABLE)

	select * 
	from Project101..CovidDeaths dea
	join Project101..CovidVaccination vac
	on dea.location=vac.location and
	dea.date=vac.date

-- Total population who did vaccinations (A new column is created where day by day reports of the number of people who did vaccination is recorded)

	select dea.continent,dea.location,dea.date,dea.population,
	vac.new_vaccinations,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as UpdatingPeopleVaccinated
	from Project101..CovidDeaths dea
	join Project101..CovidVaccination vac
	on dea.location=vac.location and
	dea.date=vac.date
	where dea.continent is not null
	order by 2,3

-- Total population who did vaccination Using CTE

		with popvsvac (continent, location, date, population,new_vaccinations, UpdatingPeopleVaccinated)
		as
		(
		select dea.continent,dea.location,dea.date,dea.population,
	vac.new_vaccinations,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as UpdatingPeopleVaccinated
	from Project101..CovidDeaths dea
	join Project101..CovidVaccination vac
	on dea.location=vac.location and
	dea.date=vac.date
	where dea.continent is not null
	)
	select *,(UpdatingPeopleVaccinated/population)*100 
	from popvsvac

-- Total population who did vaccination Using temporary table

	drop table if exists #Percentpopulationvaccinated103
	Create table #Percentpopulationvaccinated103
	(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccination numeric,
	UpdatingPeopleVaccinated numeric
	)
	insert into #Percentpopulationvaccinated103
	select dea.continent,dea.location,dea.date,dea.population,
	vac.new_vaccinations,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as UpdatingPeopleVaccinated
	from Project101..CovidDeaths dea
	join Project101..CovidVaccination vac
	on dea.location=vac.location and
	dea.date=vac.date
	where dea.continent is not null
	select *,(UpdatingPeopleVaccinated/population)*100  as updatingpeoplevaccinatedpercentile
	from #Percentpopulationvaccinated103

-- Total population died because of covid (rolling number)

	select dea.continent,dea.location,dea.date,dea.population,
	vac.new_vaccinations,dea.new_deaths,
	SUM(convert(int, dea.new_deaths )) over (partition by dea.location order by dea.location,dea.date) as updatingtotaldeaths
	 from CovidDeaths dea
	 join CovidVaccination vac
	 on dea.location=vac.location and
	  dea.date=vac.date
	where dea.continent is not null
  

  
  -- Total population who died in percentage (rolling number) using cte

	  with popvsdea1 (continent,location,date,population,new_vaccinations,new_deaths,updatingtotaldeaths)
	  as
	  (
	  select dea.continent,dea.location,dea.date,dea.population,
	vac.new_vaccinations,dea.new_deaths,
	SUM(convert(int, dea.new_deaths )) over (partition by dea.location order by dea.location,dea.date) as updatingtotaldeaths
	 from CovidDeaths dea
	 join CovidVaccination vac
	 on dea.location=vac.location and
	  dea.date=vac.date
	where dea.continent is not null
	)
	select *,(updatingtotaldeaths/population)*100 as Updatingtotaldeathsperncentage
	from popvsdea1

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--Creating view for later ( visualisation)

	create view Percentpopulationvaccinated103 as
	select dea.continent,dea.location,dea.date,dea.population,
	vac.new_vaccinations,dea.new_deaths,
	SUM(convert(int, dea.new_deaths )) over (partition by dea.location order by dea.location,dea.date) as updatingtotaldeaths
	 from CovidDeaths dea
	 join CovidVaccination vac
	 on dea.location=vac.location and
	  dea.date=vac.date
	where dea.continent is not null


	create view Datebydateoftotalcasesdeath as
	select date,SUM(new_cases) as total_cases, 
	SUM(cast(new_deaths as bigint)) as total_deaths,
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 Deathpercentage
	from Project101..CovidDeaths
	where continent is not null
	group by date

	create view Highestdeathbycountry as
	select continent,Max(cast(total_deaths as bigint)) as highestdeath
	from Project101..CovidDeaths
	where continent is not null
	group by continent

	create view Highestdeathbycontinent as
	select continent,Max(cast(total_deaths as bigint)) as highestdeath
	from Project101..CovidDeaths
	where continent is not null
	group by continent

	create view HighestinfectionIndia as
	select location,date,MAX(total_cases) HighestInfection,MAX((total_cases/population))*100 
	as HighestInfectionpercentage from Project101..CovidDeaths
	where location='india' and continent is not null
	group by location,date,population

	create view Highestinfectionbycountry as
	select location,Max(total_cases) as HighestInfection,population,MAX((total_cases/population))*100 
	as HighestInfectionpercentage from 
	Project101..CovidDeaths
	where continent is not null
	group by location,population

	create view Percentagepopulationwhogetscovidindia as
	select location,date, total_cases,population,(total_cases/population)*100 as infectionpercentage
	from Project101..CovidDeaths
	where location='india' and continent is not null

	create view Chancesofdeathifinfectedindia as
	select location,date, total_cases,total_deaths,
	(total_deaths/total_cases)*100 as deathpercentage
	from Project101..CovidDeaths
	where location='india' and continent is not null




