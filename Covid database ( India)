-- death database (India)
select  location,date,population,sum(cast(total_deaths as int)) as HighestDeathCount,(total_deaths/population)*100 as DeathcountPercentage
 from Project101..CovidDeaths
 where continent is not null and location = 'india'
 group by location,population,total_deaths,date
 order by 1 desc

 --Infection database India (timeline)
 select location,date,population,total_cases as CasesCount,(total_cases/population)*100 as InfectionCountPercdentage
 from Project101..CovidDeaths
 where location = 'india'
 order by 1

 --Vaccinated in india (timeline)
 select dea.location,dea.date,dea.population,vac.total_vaccinations
 from Project101..CovidDeaths dea
 join Project101..CovidVaccination vac
 on dea.location=vac.location and
 dea.date=vac.date
 where dea.location = 'india' 

 --total cases,deaths,percentage in india
 select SUM(new_cases) as total_cases, 
SUM(cast(new_deaths as bigint)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 Deathpercentage
from Project101..CovidDeaths
where continent is not null and location='india'
order by 1,2
