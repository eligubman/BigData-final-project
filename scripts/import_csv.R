library(DBI)
library(RSQLite)

# Connect to SQLite database
con <- dbConnect(RSQLite::SQLite(), "BX_db.sqlite")

# Import CSV files into corresponding tables
dbWriteTable(con, "BX-Users", read.csv("BX_csv/BX-Users.csv"), row.names = FALSE, append = TRUE)
dbWriteTable(con, "BX-Books", read.csv("BX_csv/BX-Books.csv"), row.names = FALSE, append = TRUE)
dbWriteTable(con, "BX-Book-Ratings", read.csv("BX_csv/BX-Book-Ratings.csv"), row.names = FALSE, append = TRUE)

# Check the number of records in each table
dbGetQuery(con, "SELECT COUNT(*) FROM 'BX-Users'")
dbGetQuery(con, "SELECT COUNT(*) FROM 'BX-Books'")
dbGetQuery(con, "SELECT COUNT(*) FROM 'BX-Book-Ratings'")

# Disconnect when done
dbDisconnect(con)
