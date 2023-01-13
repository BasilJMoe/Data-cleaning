
SELECT *
FROM DataCleaning.dbo.NashvilleHousing

/*Make salesdate easier to read. Apparently it is in a time format, so we convert it to just a date.*/
SELECT SaleDate, CONVERT(Date,SaleDate) AS 'Date'
FROM DataCleaning.dbo.NashvilleHousing

--This Adds a new column
ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

--This updates that column
UPDATE DataCleaning.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

/*
--For future, this deletes column
ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate
*/
-------------------------------------------------------------------------------------------------------------------------------------

/*Add things to Property Address*/

/*There are some null values and it comes from values which have the same ParcelID as the one below it, thus making the one below it NULL.
We need to fix that by populating that value.*/
SELECT NV1.ParcelID, NV1.PropertyAddress, NV2.ParcelID, NV2.PropertyAddress, ISNULL(NV1.PropertyAddress,NV2.PropertyAddress) 
FROM NashvilleHousing NV1
INNER JOIN NashvilleHousing NV2
	ON NV1.ParcelID = NV2.ParcelID
	AND NV1.[UniqueID ] <> NV2.[UniqueID ] /*This line is important. We need to have a clear distinction between a row with a NULL and the one above it.*/
WHERE NV1.PropertyAddress IS NULL

/*This actually Updates the table*/
UPDATE NV1
SET PropertyAddress = ISNULL(NV1.PropertyAddress,NV2.PropertyAddress)
FROM NashvilleHousing NV1
INNER JOIN NashvilleHousing NV2
	ON NV1.ParcelID = NV2.ParcelID
	AND NV1.[UniqueID ] <> NV2.[UniqueID ]

/*Why did we join the table into itself? This is because INNER JOINING the tables will show us the rows with the SAME parcelID,thus we can use the second or 
first table's propertyaddress to populate the others' NULL value*/

/*ISNULL(x,y) checks if x is NULL then populate it with y.*/

-------------------------------------------------------------------------------------------------------------------------------------

/*Seperate Address into 3 different columns (Address, City, State) */
SELECT PropertyAddress
FROM NashvilleHousing

/*SUBSTRING parameters SUBSTRING(string, start, end)*/
/*Two ways of doing this. Here's the long way*/
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 ) AS 'Address' , 
	   SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(propertyAddress) ) AS 'City'
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SplitAddress Nvarchar(255);

ALTER TABLE NashvilleHousing
ADD City Nvarchar(255);

UPDATE NashvilleHousing
SET SplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 )

UPDATE NashvilleHousing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(propertyAddress) )

/*Here is an easier way to do this*/
SELECT OwnerAddress
FROM NashvilleHousing

--Parsename seperates by periods. So, we need to replace our commas with periods. It does the removal in the opposite order which is so weird. We 
--need to reverse order 1,2,3->3,2,1.
SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),1), --State
	   PARSENAME(REPLACE(OwnerAddress,',','.'),2), --City
	   PARSENAME(REPLACE(OwnerAddress,',','.'),3)  --Address
FROM NashvilleHousing
--Now to update the table

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)  --Address

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2) --City

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1) --State

-------------------------------------------------------------------------------------------------------------------------------------

/*Change Y and N to Yes and No in the SoldAsVacant Column*/
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant --Do not change it
END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant =
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant --Do not change it
END
-------------------------------------------------------------------------------------------------------------------------------------

/*Remove duplicates. Going to skip this part since i deleted the SaleDate. NOTE: i need to learn what a CTE is*/

-------------------------------------------------------------------------------------------------------------------------------------
/*Remove Unused Columns*/

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,
			taxdistrict,
			PropertyAddress
