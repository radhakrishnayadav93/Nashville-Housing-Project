/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfolioProject].[dbo].[Nashville Housing]

  select * from [Nashville Housing]

  -- Change date format of SaleDate field

  select SaleDate, CONVERT(date,SaleDate)
  from [Nashville Housing]

  update [Nashville Housing]
  set SaleDate = CONVERT(Date,SaleDate)

alter table [Nashville Housing]
alter column SaleDate Date

select SaleDate from [Nashville Housing]

-- Fixing null values in PropertyAddress column

select *
from [Nashville Housing]
where PropertyAddress is null

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Nashville Housing] a
join [Nashville Housing] b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Nashville Housing] a
join [Nashville Housing] b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Separating out Address,City and State from PropertyAddress field and OwnerAddress

select substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,charindex(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
from [Nashville Housing]

alter table [Nashville Housing]
add PropertySplitAddress nvarchar(255)

alter table [Nashville Housing]
add PropertySplitCity nvarchar(255)


update [Nashville Housing]
set PropertySplitAddress = substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


update [Nashville Housing]
set PropertySplitCity = SUBSTRING(PropertyAddress,charindex(',',PropertyAddress)+1,LEN(PropertyAddress))

select OwnerAddress from [Nashville Housing]

select PARSENAME(replace(OwnerAddress,',','.'),3) as OwnerSplitAddress,
PARSENAME(replace(OwnerAddress,',','.'),2) as OwnerSplitCity,
PARSENAME(replace(OwnerAddress,',','.'),1) as OwnerSplitState
from [Nashville Housing]

alter table [Nashville Housing]
add OwnerSplitAddress nvarchar(255)


alter table [Nashville Housing]
add OwnerSplitCity nvarchar(255)


alter table [Nashville Housing]
add OwnerSplitState nvarchar(255)

update [Nashville Housing]
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3) 
from [Nashville Housing]

update [Nashville Housing]
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2) 
from [Nashville Housing]

update [Nashville Housing]
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1) 
from [Nashville Housing]

select * from [Nashville Housing]

--Converting values 'Y','N' into 'Yes,'No' resp.

select SoldAsVacant,
case when SoldAsVacant = 'N' then 'No' 
     when SoldAsVacant = 'Y' then 'Yes'	
	 else SoldAsVacant
	 end as SoldAsVac
from [Nashville Housing]

update [Nashville Housing]
set SoldAsVacant = case when SoldAsVacant = 'N' then 'No' 
     when SoldAsVacant = 'Y' then 'Yes'	
	 else SoldAsVacant
	 end


-- Removing Duplicate rows

WITH rownumCTE as(
select *, 
	ROW_NUMBER() over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
					UniqueID
					) row_num
from [Nashville Housing]
)
select *
from rownumCTE
where row_num >1
--order by PropertyAddress

-- delete unused column

select * from [Nashville Housing]

alter table [Nashville Housing]
drop column OwnerAddress, TaxDistrict, PropertyAddress