
SELECT * FROM PortfolioProject..NashvilleHousing

-- Standardizing Date Format

SELECT Saledate
FROM PortfolioProject..NashvilleHousing

SELECT CONVERT(DATE,Saledate)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ALTER COLUMN saledate Date;


-- Populate property address data

SELECT a.ParcelID, a.PropertyAddress , b.ParcelID, b.PropertyAddress
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON  a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ] 
WHERE a.PropertyAddress IS NULL;


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON  a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ] 
WHERE a.PropertyAddress IS NULL;


-- Splitting PropertyAddress into Address and City

SELECT PropertyAddress, 
		SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1) AS Address,
		SUBSTRING(  PropertyAddress, 
                    CHARINDEX(',',PropertyAddress) + 1, 
                    LEN(PropertyAddress) ) AS City
FROM PortfolioProject..NashvilleHousing 

-- Adding Address and city columns for splitted Property Address
ALTER TABLE PortfolioProject..NashvilleHousing 
ADD PropertySplitAddress Nvarchar(255),
    PropertySplitCity Nvarchar(255);


Update PortfolioProject..NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

Update PortfolioProject..NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress) )



-- Splitting OwnerAddress into Address and City, State
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject..NashvilleHousing 


ALTER TABLE PortfolioProject..NashvilleHousing 
ADD OwnerSplitAddress Nvarchar(255),
	OwnerSplitCity Nvarchar(255),
	OwnerSplitState Nvarchar(255);


Update PortfolioProject..NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
    OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
    OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


SELECT OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM PortfolioProject..NashvilleHousing


-- Making Y, N to Yes, No in SoldAsVacant

-- Finding the majority
SELECT SoldAsVacant, COUNT(*)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 DESC

-- updating 
UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant END 
FROM PortfolioProject..NashvilleHousing


-- Removing Duplicates

-- finding duplicates
WITH row_num_cte AS(
        Select *,
            ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
                        PropertyAddress,
                        SalePrice,
                        SaleDate,
                        LegalReference
                        ORDER BY
                            UniqueID
                            ) row_num

        From PortfolioProject.dbo.NashvilleHousing
    ),
    duplicates  AS (SELECT * FROM row_num_cte WHERE row_num > 1)

Select *
--DELETE
From duplicates