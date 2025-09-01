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

# ******************************** 4. Top-10 Books and Users *********************************

# Top-10 rated books
top_books <- sqldf("SELECT ISBN, COUNT(*) AS num_ratings FROM ratings GROUP BY ISBN ORDER BY num_ratings DESC LIMIT 10")
top_books <- merge(top_books, books, by = "ISBN")
print(top_books[, c("Book-Title", "num_ratings")])

# Top-10 active users
top_users <- sqldf("SELECT \"User-ID\", COUNT(*) AS num_ratings FROM ratings GROUP BY \"User-ID\" ORDER BY num_ratings DESC LIMIT 10")
print(top_users)

# *********************** 5.  Build a Recommender System *************************

# Convert the ratings data into a matrix for the recommender system
rating_matrix <- as(ratings, "realRatingMatrix")

# Filter users with at least 3 ratings
valid_users <- rowCounts(rating_matrix) >= 1
rating_matrix <- rating_matrix[valid_users, ]

# Create 5-fold cross-validation evaluation sets
# The `given` parameter is used to specify how many ratings per user to use for evaluation.
# Setting `given = -1` means use all available ratings for evaluation
eval_sets <- evaluationScheme(rating_matrix, method = "cross-validation", train = 0.8, given = 1, k = 5)


# Train a UBCF (User-based collaborative filtering) model
ubcf_model <- Recommender(getData(eval_sets, "train"), method = "UBCF")

# Generate recommendations for the test set
predictions <- predict(ubcf_model, getData(eval_sets, "known"), type = "ratings")

# ************************************ 6. Evaluate the Recommender System ************************************

# Calculate prediction accuracy
accuracy <- calcPredictionAccuracy(predictions, getData(eval_sets, "unknown"))
print(accuracy)

# RMSE for the model
print(paste("RMSE:", accuracy["RMSE"]))

# ************************************ 7. Save Results to CSV ************************************

# Save predictions to a CSV file
top_n_predictions <- predict(ubcf_model, getData(eval_sets, "known"), n = 10)
predictions_list <- as(top_n_predictions, "list")

# Ensure all predictions are in the correct format (list of vectors)
filtered_predictions <- lapply(predictions_list, function(x) {
  if (length(x) > 0 && is.vector(x)) return(x) else return(NULL)
})

# Remove empty or NULL predictions
filtered_predictions <- Filter(Negate(is.null), filtered_predictions)

# Check if there are any valid predictions left
if (length(filtered_predictions) > 0) {
  # Convert the list to a data frame by row-binding the elements
  predictions_df <- do.call(rbind, lapply(filtered_predictions, function(x) {
    # Ensure that each user's predictions are converted to a data frame
    data.frame(t(x), stringsAsFactors = FALSE)
  }))
  
  # Add meaningful column names (e.g., Recommendation_1, Recommendation_2, etc.)
  colnames(predictions_df) <- paste0('Recommendation_', 1:ncol(predictions_df))

  # at this point the dataframe is like so:
  # Recommendation_1 Recommendation_2 Recommendation_3 Recommendation_4 Recommendation_5 Recommendation_6 Recommendation_7 Recommendation_8 Recommendation_9 Recommendation_10
  # "0345339703","0375727345","0380727501","0553274295","0553296981","0062502182","0375703861","039592720X","044022165X","0679446486"
  # ...
  # and the ISBNs are in the format "0345339703" which is not very human-readable
  # so we will join the ISBNs with the book titles to make it more readable
  predictions_df <- merge(predictions_df, books, by.x = "Recommendation_1", by.y = "ISBN", all.x = TRUE)
  
  # Write the predictions to a CSV file
  write.csv(predictions_df, "recommendations.csv", row.names = FALSE)
  
  cat("Predictions saved successfully to recommendations.csv\n")
} else {
  cat("No valid recommendations to save.\n")
}
