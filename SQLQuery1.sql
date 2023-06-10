select * from Sales_Dirty;
-- the columns are in this order, Sales Person, North, East, South and west.
-- Employee ID is also attached to the Employee's Name.

-- Sql do not accept column names with spaces so we need to rename all columns

exec sp_rename 'Sales_Dirty.Sales for: 2018-01-01', 'Sales_Person','COLUMN';
exec sp_rename 'Sales_Dirty.F2', 'North','COLUMN';
exec sp_rename 'Sales_Dirty.F3', 'East','COLUMN';
exec sp_rename 'Sales_Dirty.F4', 'South','COLUMN';
exec sp_rename 'Sales_Dirty.F5', 'West','COLUMN';

select * from Sales_Dirty;
-- Columns have been renamed

go

with First_Step as (select Sales_Person, 
  substring(Sales_Person,1,CHARINDEX(' (',Sales_Person)) -- used a space and ( to get the exact index I needed.
  as Sales_Persons,
  North, East, South, West, 
  Substring(RIGHT(Sales_Person,6),2,4) as Employee_ID,
  case when Sales_Person like '%Sales for%' then RIGHT(Sales_Person,10)
  end as Dates, ROW_NUMBER() over(order by (select Null)) as Row_num
  from Sales_Dirty)
  -- the select Null code in the order by part of the row_Num column is used to maintain the order of the data as it is originally.

-- Now the rows are in order, I need fill the first five rows which I deleted their date when I was renaming columns.
-- the date was 2018-01-01. before I can do this, I will have to put whatever changes I have made into a table so that 
-- the dates generated column can be a real column. This is needed to be done because Update function is a data manipulation function

select Sales_Persons, North, East, West, Employee_ID, Dates, Row_num 
into Sales_Dirty_Cleaned
from First_Step;

go 

select * from Sales_Dirty_Cleaned

--Updating the First 5 Rows

update Sales_Dirty_Cleaned
set Dates = '2018-01-01'
where Row_num between 1 and 5;

select * from Sales_Dirty_Cleaned;

-- Replacing Dates
go


select * from Sales_Dirty_Cleaned
go
with patially_cleaned as 
(select Sales_Persons, North, East, West, Employee_ID, 
max(Dates) over(order by Row_num
rows between unbounded preceding and 1 preceding) as Dates from Sales_Dirty_Cleaned)
--making a new table

select Sales_Persons, North, East, West, Employee_ID, Dates
into successfully_cleaned from patially_cleaned;

select * from successfully_cleaned

-- Now the data looks neat, its time to droop unnecessary columns
go

delete from successfully_cleaned
where Sales_Persons is null and North is Null or North is null
or Trim(Sales_Persons) = '';

select * from successfully_cleaned