					/*CLEANING DATA IN SQL*/

--DATABASE CREATION
CREATE DATABASE sqlproject2

--SELECTING THE TABLE
SELECT * 
FROM sqlproject2.dbo.NashvilleHousing

-- STANDARDIZE DATE FORMAT
SELECT saleDate, CONVERT(DATE, SaleDate) AS SaleDateConverted
FROM sqlproject2.dbo.NashvilleHousing

UPDATE sqlproject2.dbo.NashvilleHousing
SET SaleDate = CONVERT(DATE, SaleDate)

-- Populate Property Address data
SELECT *
FROM sqlproject2.dbo.NashvilleHousing
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM sqlproject2.dbo.NashvilleHousing a
JOIN sqlproject2.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM sqlproject2.dbo.NashvilleHousing a
JOIN sqlproject2.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) AS Address
FROM sqlproject2.dbo.NashvilleHousing

ALTER TABLE sqlproject2.dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE sqlproject2.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE sqlproject2.dbo.NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE sqlproject2.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

SELECT OwnerAddress
FROM sqlproject2.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM sqlproject2.dbo.NashvilleHousing

ALTER TABLE sqlproject2.dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

Update sqlproject2.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE sqlproject2.dbo.NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE sqlproject2.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE sqlproject2.dbo.NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE sqlproject2.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT *
FROM sqlproject2.dbo.NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM sqlproject2.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM sqlproject2.dbo.NashvilleHousing

Update sqlproject2.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- Remove Duplicates
WITH RowNumCTE AS(
	SELECT *,
		ROW_NUMBER() OVER (
			PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
			ORDER BY UniqueID
		)AS row_num
	FROM sqlproject2.dbo.NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

SELECT *
FROM sqlproject2.dbo.NashvilleHousing

-- Delete Unused Columns
ALTER TABLE sqlproject2.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
