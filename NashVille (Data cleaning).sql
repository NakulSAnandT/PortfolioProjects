-- DATA CLEANING 

    select * from Project104..[Nashville ]

-- 1) Formatting Date 

    select SaleDate,CONVERT(Date,SaleDate)
    from Project104..[Nashville ] 

    UPDATE Project104..[Nashville ]
    set SaleDate = CONVERT(Date,SaleDate)

    ALTER table Nashville
    add SaleDateNew date

-- Creating a new column and using convert to change format into date and inserting from salesdate

    UPDATE Project104..[Nashville ]
    set SaleDateNew = CONVERT(Date,SaleDate)

---------------------------------------------------------------------------------------------------------------------------------------------------------
-- 2) Formatting Property by Populating
 
    Select PropertyAddress from
    Project104..[Nashville ]
    where PropertyAddress is null
--  Populating

    select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
    from Project104..[Nashville ] a
    join Project104..[Nashville ] b
    on a.ParcelID=b.ParcelID
    and a.[UniqueID ]<>b.[UniqueID ]
    where a.PropertyAddress is null

-- populating Null rows 

    UPDATE a
    set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
    from Project104..[Nashville ] a
    join Project104..[Nashville ] b
    on a.ParcelID=b.ParcelID
    and a.[UniqueID ]<>b.[UniqueID ]
    where a.PropertyAddress is null
--------------------------------------------------------------------------------------------------------------------------------------------------------
--  3) SPLITTING A COLUMN

    select SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as addresss
    ,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) as city
	  from Project104..[Nashville ]

-- Adding a new column and Updating 

    Alter Table Nashville
    add PSAddress nvarchar(255);

    Update [Nashville ]
    set PSAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress))

    Alter table Nashville
    add PSCity nvarchar(255);

    Update [Nashville ]
    set PSCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 4) SPLITTING COLUMN 'OWNERADRRESS' INTO 

    select
    PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
    ,PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
     ,PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
    from Project104..Nashville

-- Using parsename

    Alter table Nashville
    add OSAddress nvarchar(255)

    UPDATE [Nashville ]
    set OSAddress =  PARSENAME(REPLACE(OwnerAddress,',','.'),3)

    Alter table Nashville
    add OSCity nvarchar(255);

    UPDATE [Nashville ]
    set OSCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

     Alter table Nashville
     add OSState nvarchar(255);

    UPDATE [Nashville ]
    set OSState = PARSENAME(REPLACE(OwnerAddress,',','.'),3)
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 5) CHANGING Y/N TO YES/NO

    SELECT DISTINCT(SoldAsVacant),Count(SoldAsVacant)
    from Project104..[Nashville ]
    group by SoldAsVacant
    order by 2

    SELECT SoldAsVacant
    , CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
           WHEN SoldAsVacant = 'N' THEN 'NO'
	      ELSE SoldAsVacant
	      END
    AS NewSoldAsVacant
    from Project104..[Nashville ]

-- Using case statement 

    UPDATE [Nashville ]
    set SoldAsVacant= CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
           WHEN SoldAsVacant = 'N' THEN 'NO'
	      ELSE SoldAsVacant
	      END
	    from Project104..[Nashville ]

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 6) REMOVING DUPLICATES

WITH ROWNUMCTE AS (
                     select *,ROW_NUMBER() over (
					          partition by ParcelID,
							               PropertyAddress,
										   SalePrice,
										   SaleDate,
                                           LegalReference
										   ORDER BY
										   UniqueID
										   ) as ROW_NUM
						FROM Project104..[Nashville ]
					)
DELETE from ROWNUMCTE 
WHERE ROW_NUM > 1
--ORDER BY PropertyAddress
--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Checking for more duplicate

WITH ROWNUMCTE AS (
                     select *,ROW_NUMBER() over (
					          partition by ParcelID,
							               PropertyAddress,
										   SalePrice,
										   SaleDate,
                                           LegalReference
										   ORDER BY
										   UniqueID
										   ) as ROW_NUM
						FROM Project104..[Nashville ]
					)
Select * from ROWNUMCTE 
WHERE ROW_NUM > 1
ORDER BY PropertyAddress
--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 7) DELETING IRRELEVANT DATA

    ALTER TABLE Nashville
    DROP COLUMN TaxDistrict

    ALTER TABLE Nashville
    DROP COLUMN PropertyAddress, OwnerAddress,SaleDate

    Select * from Project104..[Nashville ]







