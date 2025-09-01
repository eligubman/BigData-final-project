# ******************************** 1. Load the Data into R  ********************************


# Load necessary libraries
library(RSQLite)
library(sqldf)
library(recommenderlab)
library(ggplot2)

# Connect to the SQLite database
con <- dbConnect(SQLite(), dbname = "BX_db.sqlite")

# Load tables into R
users <- dbGetQuery(con, "SELECT * FROM 'BX-Users'")
books <- dbGetQuery(con, "SELECT * FROM 'BX-Books'")
ratings <- dbGetQuery(con, "SELECT * FROM 'BX-Book-Ratings'")

# Number of users, books, and ratings
print(cat("Number of users:", nrow(users)))
print(cat("Number of books:", nrow(books)))
print(cat("Number of ratings:", nrow(ratings)))

# disconnect from the database

dbDisconnect(con)

# ***************************** 2. Data Exploration and Preprocessing  **************************


# Filter ratings to only include valid entries
ratings <- sqldf("SELECT * FROM ratings WHERE \"Book-Rating\" > 0 AND \"Book-Rating\" <= 10")

# Filter users and books with at least 30 ratings
books_with_ratings <- sqldf("SELECT ISBN FROM ratings GROUP BY ISBN HAVING COUNT(*) > 30")
users_with_ratings <- sqldf("SELECT \"User-ID\" FROM ratings GROUP BY \"User-ID\" HAVING COUNT(*) > 30 AND COUNT(*) < 300")


# Keep only these ratings
ratings <- sqldf("SELECT * FROM ratings WHERE \"User-ID\" IN users_with_ratings AND ISBN IN books_with_ratings")


# ******************************** 3. Statistics and Histograms  *******************************

pdf("outputs/ratings_histograms.pdf")

# Histogram of ratings by user
user_ratings_hist <- sqldf("SELECT COUNT(\"User-ID\") AS ratings_per_user FROM ratings GROUP BY \"User-ID\"")
ggplot(user_ratings_hist, aes(x = ratings_per_user)) +
    geom_histogram(binwidth = 5, fill = "blue") +
    ggtitle("Histogram of Ratings by Users")

# Histogram of ratings by book
book_ratings_hist <- sqldf("SELECT COUNT(ISBN) AS ratings_per_book FROM ratings GROUP BY ISBN")
ggplot(book_ratings_hist, aes(x = ratings_per_book)) +
    geom_histogram(binwidth = 5, fill = "green") +
    ggtitle("Histogram of Ratings by Books")

dev.off()