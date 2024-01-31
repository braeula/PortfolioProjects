/*

Cleaning Data in SQL Queries

*/

select *
from Portfolio_Project.dbo.NashvilleHousing


-- Standardize Date Format


select SaleDateConverted, CONVERT(date,SaleDate)
from Portfolio_Project.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(date,SaleDate)

Alter table NashvilleHousing
add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(date,SaleDate)


-- Populate Property Adress data

select *
from Portfolio_Project.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from Portfolio_Project.dbo.NashvilleHousing a
join Portfolio_Project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Portfolio_Project.dbo.NashvilleHousing a
join Portfolio_Project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)


select PropertyAddress
from Portfolio_Project.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, charindex(',', PropertyAddress)+1, Len(PropertyAddress)) as City

from Portfolio_Project.dbo.NashvilleHousing


Alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)-1)


Alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, charindex(',', PropertyAddress)+1, Len(PropertyAddress))

select *
from Portfolio_Project.dbo.NashvilleHousing

--------

select OwnerAddress
from Portfolio_Project.dbo.NashvilleHousing

select 
parsename(replace(OwnerAddress, ',','.'),3),
parsename(replace(OwnerAddress, ',','.'),2),
parsename(replace(OwnerAddress, ',','.'),1)
from Portfolio_Project.dbo.NashvilleHousing



Alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = parsename(replace(OwnerAddress, ',','.'),3)


Alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = parsename(replace(OwnerAddress, ',','.'),2)

Alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = parsename(replace(OwnerAddress, ',','.'),1)


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from Portfolio_Project.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


Select SoldAsVacant, case when SoldAsVacant = 'Y' then 'Yes'
						  when SoldAsVacant = 'N' then 'No'
						  else SoldAsVacant
						  end
from Portfolio_Project.dbo.NashvilleHousing

Update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
						end


-- Remove Duplicates
-- (Rank ist auch eine Möglichkeit)

with RowNumCTE As(
select *, ROW_NUMBER() over (Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
								 order by UniqueID)
								 row_num
from Portfolio_Project.dbo.NashvilleHousing
--order by ParcelID
)
select *
from RowNumCTE
where row_num >1
--order by PropertyAddress


-- Delete Unused Columns

Select *
from Portfolio_Project.dbo.NashvilleHousing


alter table Portfolio_Project.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table Portfolio_Project.dbo.NashvilleHousing
drop column SaleDate