USE Portfolio_SQL
GO

/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM dbo.Housing 

--Standarize Date Format
SELECT SaleDate, CONVERT(DATE, SaleDate)
FROM Housing 

ALTER TABLE Housing ALTER COLUMN SaleDate DATE

--Populate Property Addres data
SELECT *
FROM Housing
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Housing a
JOIN Housing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Housing a
JOIN Housing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

-- Breaking out Address Into Individual Colums (Address, City, State)
 SELECT	PropertyAddress
 FROM Housing

 SELECT 
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
 , SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS AddressCity 
 FROM Housing

 ALTER TABLE Housing
 Add PropertySplitAddress NVARCHAR(255)

 UPDATE Housing
 SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

 ALTER TABLE Housing
 Add PropertyCityAddress NVARCHAR(255)

 UPDATE Housing
 SET PropertyCityAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

 SELECT *
 FROM Housing

 -- Saparate OwnerAddress Column using PARSENAME statement
 SELECT OwnerAddress
 FROM Housing

 SELECT 
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
 FROM Housing

 ALTER TABLE Housing
 Add OwnerSplitAddress NVARCHAR(255)

 UPDATE Housing
 SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

 
 ALTER TABLE Housing
 Add OwnerSplitCity NVARCHAR(255)

 UPDATE Housing
 SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

 
 ALTER TABLE Housing
 Add OwnerSplitState NVARCHAR(255)

 UPDATE Housing
 SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

 --double check
 SELECT OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState  
 FROM Housing

 -- Change Y and N to 'Yes' and 'No' in 'SoldAsVacant' field

 SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
 FROM Housing
 GROUP BY SoldAsVacant
 ORDER BY 2

SELECT SoldAsVacant
 , CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM Housing

UPDATE Housing
SET SoldAsVacant =
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

-- Identify Duplicates 

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM Housing
)
--Delete duplicates
DELETE
FROM RowNumCTE
WHERE row_num > 1

-- Delete Unused Columns

SELECT *
From Housing


ALTER TABLE Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


