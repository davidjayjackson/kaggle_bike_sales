library(tidyverse)
library(scales)
library(readxl)
library(DBI)
library(odbc)
library(lubridate)
library(janitor)
  

rm(list=ls())
## https://db.rstudio.com/databases/microsoft-sql-server/
con <- DBI::dbConnect(odbc::odbc(), 
                      Driver = "SQL Server", 
                      Server = "localhost\\SQLEXPRESS", 
                      Database = "bikeshop", 
                      Trusted_Connection = "True")

# dbListTables(con)



## Read in Excel files.
 
address <- read_xlsx("./bikesales/Addresses.xlsx",
                     col_types = c("text")) %>% clean_names() %>% 
  remove_empty(which =c("rows","cols"))

address$validity_startdate <- ymd(address$validity_startdate)


dbWriteTable(con, "address",address ,overwrite=TRUE)
dbListFields(con,"address")

##
partners <- read_xlsx("./bikesales/BusinessPartners.xlsx",
                     col_types = c("text")) %>% clean_names() %>% 
                      remove_empty(which =c("rows","cols"))

partners$createdat <- ymd(partners$createdat)
partners$changedat <- ymd(partners$changedat)

business <- partners %>% inner_join(address)  %>% clean_names()

dbWriteTable(con, "partners",partners ,overwrite=TRUE)
dbWriteTable(con, "business",business ,overwrite=TRUE)
dbListFields(con,"partners")



##
employees <- read_xlsx("./bikesales/Employees.xlsx",
                      col_types = c("text")) %>% clean_names() %>% 
                      remove_empty(which =c("rows","cols"))

employees$validity_startdate <- ymd(employees$validity_startdate)
employees$fullname <-  paste(
                    employees$name_first, 
                    employees$name_middle,
                    employees$name_last, sep = " ")

employee_detail <-employees %>% inner_join(address,by=c("addressid"))  %>% clean_names()
dbWriteTable(con, "employees",employees ,overwrite=TRUE)
dbWriteTable(con, "employee_detail",employee_detail,overwrite=TRUE)
dbListFields(con,"employees")


##

category <- read_xlsx("./bikesales/ProductCategories.xlsx",
                       col_types = c("text")) %>% clean_names() %>% 
                        remove_empty(which =c("rows","cols"))

category$createdat <- ymd(category$createdat)

##

category_text <- read_xlsx("./bikesales/ProductCategoryText.xlsx",
                       col_types = c("text")) %>% 
                        clean_names() %>% remove_empty(which =c("rows","cols"))
category_detail <- category %>% inner_join(category_text)  %>% clean_names()
dbWriteTable(con, "category_text",category_text ,overwrite=TRUE)
dbWriteTable(con, "category_detail",category_detail ,overwrite=TRUE)



dbListFields(con,"category_detail")

##

products <- read_xlsx("./bikesales/Products.xlsx",
                           col_types = c("text")) %>% 
  clean_names() %>% remove_empty(which =c("rows","cols"))

products$createdat <- ymd(products$createdat)
products$changedat <- ymd(products$changedat)
products$price <- as.numeric(products$price)
products$weightmeasure <- as.numeric(products$weightmeasure)

dbWriteTable(con, "products",products ,overwrite=TRUE)
dbListFields(con,"products")

##

product_text <- read_xlsx("./bikesales/ProductTexts.xlsx",
                          col_types = c("text")) %>% 
  clean_names() %>% remove_empty(which =c("rows","cols"))

product_detail <- products %>% inner_join(product_text)  %>% clean_names()

dbWriteTable(con, "product_text",product_text ,overwrite=TRUE)
dbWriteTable(con, "product_detail",product_detail ,overwrite=TRUE)
dbListFields(con,"product_detail")
##

order_item <- read_xlsx("./bikesales/SalesOrderItems.xlsx",
                           col_types = c("text")) %>% 
  clean_names() %>% remove_empty(which =c("rows","cols"))

order_item$grossamount <- as.numeric(order_item$grossamount)
order_item$netamount <- as.numeric(order_item$netamount)
order_item$taxamount <- as.numeric(order_item$taxamount)
order_item$quantity <- as.numeric(order_item$quantity)
order_item$deliverydate <- ymd(order_item$deliverydate)


dbWriteTable(con, "order_item",order_item ,overwrite=TRUE)
dbListFields(con,"order_item")

##
orders <- read_xlsx("./bikesales/SalesOrders.xlsx",
                    col_types = c("text")) %>% 
  clean_names() %>% remove_empty(which =c("rows","cols"))

orders$grossamount <- as.numeric(orders$grossamount)
orders$netamount <- as.numeric(orders$netamount)
orders$taxamount <- as.numeric(orders$taxamount)
orders$createdat <- ymd(orders$createdat)
orders$changedat <- ymd(orders$changedat)


dbWriteTable(con, "orders",orders ,overwrite=TRUE)
dbListFields(con,"orders")


full_orders <- orders %>% 
    inner_join(order_item,by=c("salesorderid")) %>% clean_names()

dbWriteTable(con, "full_orders",full_orders ,overwrite=TRUE)
