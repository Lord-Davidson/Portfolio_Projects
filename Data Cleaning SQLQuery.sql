Select *
From sqlportfolioproject..NashvilleHousingData;

-- Standardize date format

Select SaleDateConverted, CONVERT(date, SaleDate)
From sqlportfolioproject..[NashvilleHousingData];

UPDATE [SqlPortfolioProject]..[NashvilleHousingData]
SET SaleDate = CONVERT(date,SaleDate);

ALTER TABLE [SqlPortfolioProject]..[NashvilleHousingData]
ADD SaleDateConverted DATE;

UPDATE [SqlPortfolioProject]..[NashvilleHousingData]
SET SaleDateConverted = CONVERT(date,SaleDate);

-- Populate Property Address Data

Select *
From sqlportfolioproject..[NashvilleHousingData]
where PropertyAddress is null
order by ParcelID;

Select a.ParcelID, a.PropertyAddress, a.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From sqlportfolioproject..[NashvilleHousingData] a
join SqlPortfolioProject..NashvilleHousingData b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

UPDATE a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From sqlportfolioproject..[NashvilleHousingData] a
join SqlPortfolioProject..NashvilleHousingData b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

-- Breaking out Address into individual columns (Address, City, State)

Select PropertyAddress
From sqlportfolioproject..[NashvilleHousingData];

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM NashvilleHousingData;

ALTER TABLE [SqlPortfolioProject]..[NashvilleHousingData]
ADD PropertySplitAddress nvarchar(255);

UPDATE [SqlPortfolioProject]..[NashvilleHousingData]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE [SqlPortfolioProject]..[NashvilleHousingData]
ADD PropertySplitCity nvarchar(255);

UPDATE [SqlPortfolioProject]..[NashvilleHousingData]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

SELECT *
FROM NashvilleHousingData;

SELECT OwnerAddress
FROM NashvilleHousingData;

SELECT
PARSENAME(REPLACE(OwnerAddress,',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress,',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)
FROM NashvilleHousingData;

ALTER TABLE [SqlPortfolioProject]..[NashvilleHousingData]
ADD OwnerSplitAddress nvarchar(255);

UPDATE [SqlPortfolioProject]..[NashvilleHousingData]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3);

ALTER TABLE [SqlPortfolioProject]..[NashvilleHousingData]
ADD OwnerSplitCity nvarchar(255);

UPDATE [SqlPortfolioProject]..[NashvilleHousingData]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2);

ALTER TABLE [SqlPortfolioProject]..[NashvilleHousingData]
ADD OwnerSplitState nvarchar(255);

UPDATE [SqlPortfolioProject]..[NashvilleHousingData]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1);

SELECT *
FROM NashvilleHousingData;

-- Change Y and N to Yes and No in "SoldAsVacant" field

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM NashvilleHousingData
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END
FROM NashvilleHousingData;

UPDATE NashvilleHousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END;

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (
    PARTITION BY parcelid,
                 propertyaddress,
                 saleprice,
                 saledate,
                 legalreference
                 ORDER BY
                    UniqueID
                    ) row_num
FROM NashvilleHousingData
)
DELETE
FROM RowNumCTE
WHERE row_num > 1;

-- Delete unused columns

SELECT *
FROM NashvilleHousingData;

ALTER TABLE sqlportfolioproject..NashvilleHousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

ALTER TABLE sqlportfolioproject..NashvilleHousingData
DROP COLUMN SaleDate;
