## INTRODUCTION
This is a data cleaning task of a sales data using SQL


![Alt Text]()

### VIEWING THE DATASET

`select * from Sales_Dirty;`

![Alt Text](https://github.com/Mario-Gozie/Data-Cleaning-SQL/blob/main/Images/Screenshot%20(347).png)

### RENAMING COLUMNS

Because SQL do not accept column names with spaces except if they are in hard brackets, I had to rename the column and because the columns are not in the right format.

`exec sp_rename 'Sales_Dirty.Sales for: 2018-01-01', 'Sales_Person','COLUMN';`
`exec sp_rename 'Sales_Dirty.F2', 'North','COLUMN';`
`exec sp_rename 'Sales_Dirty.F3', 'East','COLUMN';`
`exec sp_rename 'Sales_Dirty.F4', 'South','COLUMN';`
`exec sp_rename 'Sales_Dirty.F5', 'West','COLUMN';`


![Alt TexT](https://github.com/Mario-Gozie/Data-Cleaning-SQL/blob/main/Images/Screenshot%20(348).png)


### EXTRACTING IMPORTANT DETAILS FROM THE DATA

I used the code below to extract Names of sales persons sales they made per region theire Eployee ID, I also added a row number to make sure the data doesn't change its order which may affect the order of the dates in the date column yet to be addressed.


`select Sales_Person, 
  substring(Sales_Person,1,CHARINDEX(' (',Sales_Person)) 
  as Sales_Persons,
  North, East, South, West, 
  Substring(RIGHT(Sales_Person,6),2,4) as Employee_ID,
  case when Sales_Person like '%Sales for%' then RIGHT(Sales_Person,10)
  end as Dates, ROW_NUMBER() over(order by (select Null)) as Row_num
  from Sales_Dirty;`
![Alt Text](https://github.com/Mario-Gozie/Data-Cleaning-SQL/blob/main/Images/Screenshot%20(350).png)


### ADDING TO NEW TABLE

in order to use some data manipulation language(DML) such as delete, update etc, I needed to put these data into a table so i had to put them into Sales_Dirty_Cleaned


`with First_Step as (select Sales_Person, 
  substring(Sales_Person,1,CHARINDEX(' (',Sales_Person)) 
  as Sales_Persons,
  North, East, South, West, 
  Substring(RIGHT(Sales_Person,6),2,4) as Employee_ID,
  case when Sales_Person like '%Sales for%' then RIGHT(Sales_Person,10)
  end as Dates, ROW_NUMBER() over(order by (select Null)) as Row_num
  from Sales_Dirty)`



select Sales_Persons, North, East, West, Employee_ID, Dates, Row_num 
into Sales_Dirty_Cleaned
from First_Step;`


![Alt Text](https://github.com/Mario-Gozie/Data-Cleaning-SQL/blob/main/Images/Screenshot%20(351).png)

### CHECKING IF TABLE WAS CREATED

`select * from Sales_Dirty_Cleaned`


![Alt Text](https://github.com/Mario-Gozie/Data-Cleaning-SQL/blob/main/Images/Screenshot%20(352).png)

### PARTIALLY UPDATING DATE

I removed the first date "2018-01-01" while renaming the columns in my my second query so I had to updaate that information.


`update Sales_Dirty_Cleaned
set Dates = '2018-01-01'
where Row_num between 1 and 5;`


![Alt Text](https://github.com/Mario-Gozie/Data-Cleaning-SQL/blob/main/Images/Screenshot%20(353).png)


### VIEWING THE DATA FOR UPDATE

select * from Sales_Dirty_Cleaned;


![Alt Text](https://github.com/Mario-Gozie/Data-Cleaning-SQL/blob/main/Images/Screenshot%20(354).png)


### UPDATING ALL DATES

Here I had to update all rows with the right transaction date. this made me create a new table which I called successfully cleaned but the cleaning process was still on just that I was hopefull that I was almost done.

`with patially_cleaned as 
(select Sales_Persons, North, East, West, Employee_ID, 
max(Dates) over(order by Row_num
rows between unbounded preceding and 1 preceding) as Dates from Sales_Dirty_Cleaned)

select Sales_Persons, North, East, West, Employee_ID, Dates
into successfully_cleaned from patially_cleaned;`


![Alt Text](https://github.com/Mario-Gozie/Data-Cleaning-SQL/blob/main/Images/Screenshot%20(361).png)



### VIEWING FOR RECENT UPDATE

`select * from successfully_cleaned`


![Alt Text](https://github.com/Mario-Gozie/Data-Cleaning-SQL/blob/main/Images/Screenshot%20(362).png)


### DELETING ALL ROWS WITH UNNECESSARY SPACES AND NULL

`delete from successfully_cleaned
where Sales_Persons is null and North is Null or North is null
or Trim(Sales_Persons) = '';`


![Alt Text](https://github.com/Mario-Gozie/Data-Cleaning-SQL/blob/main/Images/Screenshot%20(364).png) 


### VIEWING THE CLEAN DATA


`select * from successfully_cleaned`


![Alt Text](https://github.com/Mario-Gozie/Data-Cleaning-SQL/blob/main/Images/Screenshot%20(366).png)
