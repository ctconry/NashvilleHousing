-- Data cleaning project

-- View data set 

Select *
From PortfolioProject.dbo.NashvilleHousing

-- Change data data type from date time to date

Alter table PortfolioProject.dbo.NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProject.dbo.NashvilleHousing 
Set SaleDateConverted = Convert(Date, SaleDate)

-- Populate Property Address data

Select one.ParcelID, one.PropertyAddress, two.ParcelID, two.PropertyAddress, Isnull(one.PropertyAddress, two.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing as one
Join PortfolioProject.dbo.NashvilleHousing as two
	on one.ParcelID = two.ParcelID 
	and one.[UniqueID] <> two.[UniqueID]
Where one.PropertyAddress is null

Update one
Set PropertyAddress = Isnull(one.PropertyAddress, two.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing as one
Join PortfolioProject.dbo.NashvilleHousing as two
	on one.ParcelID = two.ParcelID 
	and one.UniqueID <> two.UniqueID
Where one.PropertyAddress is null

-- Breaking out the Property Address

Select 
Substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1) as Address,
Substring(PropertyAddress, charindex(',', PropertyAddress) +1, Len(PropertyAddress)) as City
From PortfolioProject.dbo.NashvilleHousing

Alter table PortfolioProject.dbo.NashvilleHousing
Add SplitPropertyAddress nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing 
Set SplitPropertyAddress = Substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1)

Alter table PortfolioProject.dbo.NashvilleHousing
Add SplitPropertyCity nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing 
Set SplitPropertyCity = Substring(PropertyAddress, charindex(',', PropertyAddress) +1, Len(PropertyAddress))

-- Breakout the Owner Address

Select 
Parsename(Replace(OwnerAddress, ',', '.'), 3),
Parsename(Replace(OwnerAddress, ',', '.'), 2),
Parsename(Replace(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.NashvilleHousing

Alter table PortfolioProject.dbo.NashvilleHousing
Add SplitOwnerAddress nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing 
Set SplitOwnerAddress = Parsename(Replace(OwnerAddress, ',', '.'), 3)

Alter table PortfolioProject.dbo.NashvilleHousing
Add SplitOwnerCity nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing 
Set SplitOwnerCity = Parsename(Replace(OwnerAddress, ',', '.'), 2)

Alter table PortfolioProject.dbo.NashvilleHousing
Add SplitOwnerState nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing 
Set SplitOwnerState = Parsename(Replace(OwnerAddress, ',', '.'), 1)

-- Standardize Sold as Vacant column values
-- Replace 'Y' with 'Yes' and 'N' with 'No'

Select SoldAsVacant
, Case When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End
From PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End

-- Remove duplicates

With RowNumCTE as(
Select *,
	Row_Number() OVER (
	Partition by ParcelID,
				 PropertyAddress,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) as row_num

From PortfolioProject.dbo.NashvilleHousing
)
Delete
From RowNumCTE
Where row_num > 1




