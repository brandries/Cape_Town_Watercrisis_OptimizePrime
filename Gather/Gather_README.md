# This is the readme file for the gather phase of the water crisis project for team *Optimize Prime*
___
All the SQL code is available within the [SQL Code](https://github.com/brandries/Cape_Town_Watercrisis_OptimizePrime/tree/master/Gather/SQL_code) folder

+ With the data provided to us, we firstly created the [Dam Levels Tables](https://github.com/brandries/Cape_Town_Watercrisis_OptimizePrime/blob/master/Gather/Gather_dam_levels.md), 
containing the dam levels, statistics for all the dams, and tables containing the dates at which the readings were taken.

*These date tables will be used throughout the database to link datasets together.*

+ Next we created the [Suburbs](https://github.com/brandries/Cape_Town_Watercrisis_OptimizePrime/blob/master/Gather/Gather_new_suburbs.md)
table. This table is a collection of all the suburbs sampled for the population, consumption and rain datasets, and will
serve as links between these datasets. During the creation of this table, suburbs were manually edited, the complete edited 
file can be found [here](https://github.com/brandries/Cape_Town_Watercrisis_OptimizePrime/blob/master/Gather/suburbs_organized_with_rain_population_consumption%20-%20final_incomplete_suburbs.tsv).

+ Following this, we created the [Consumption Tables](https://github.com/brandries/Cape_Town_Watercrisis_OptimizePrime/blob/master/Gather/consumption_manipulation.md), 
which contains data on the consumption of residents, businesses, farms and other plots. 

+ Next, we created the [Population Tables](https://github.com/brandries/Cape_Town_Watercrisis_OptimizePrime/blob/master/Gather/population_manipulation.md), 
which contains data on the number of people in areas all around the greater City of Cape Town, subdivided into other demogrephics.

+ Finally, we created the [Rainfall and Environmental Data Tables](https://github.com/brandries/Cape_Town_Watercrisis_OptimizePrime/blob/master/Gather/rain_manipulation.md),
containing data on rainfall, temperature and windspeed at four locations across the greater Western Cape. 

**Views for the database can be found [here](https://github.com/brandries/Cape_Town_Watercrisis_OptimizePrime/blob/master/Gather/Create_views.md)**

## Here we include a picture of the ER diagram

![alt text](https://github.com/brandries/Cape_Town_Watercrisis_OptimizePrime/blob/master/Gather/FINAL_FINAL_FINAL_FINAL_ERD.jpg "
ER Diagram")

