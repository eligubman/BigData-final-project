# Big-Data
# Submitters:
# Eliyahu Gubman: 213662364
# Yair Levi: 

# Load the libraries

# connecting to the database (Sqlite3)
library(RSQLite) # connecting to the database
library(sqldf) # transforming sql into R dataframes
library(recommenderlab) # recommender system
library(stringr) # string manipulation
library(ggplot2) # plotting
library(qpcR) # quantile regression

# The sqlite database file is called BX_db.sqlite
# The database contains 3 tables: BX-Books, BX-Users, BX-Book-Ratings

# Connect to the database
con <- dbConnect(SQLite(), dbname="BX_db.sqlite")

tablesNames <- dbListTables(con)


ratings <- dbGetQuery(con, "SELECT * FROM 'BX-Book-Ratings' as b WHERE b.'Book-Rating' > 0 and b.'Book-Rating' <= 10 and 'ISBN' REGEXP '^[A-Za-z0-9]+$'")

detach("package:RSQLite", unload = TRUE)

print(head(ratings))

# test connection
print(dbListTables(con))
