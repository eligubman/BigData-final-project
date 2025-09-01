# in the output folder of the project there is a file called recommendations.csv
# the propuse of this script is to convert the ISBNs in the recommendations.csv file to book titles

# import libraries
library(RSQLite)

# Load the data
# get the books from the database "BX_db.sqlite"
con <- dbConnect(SQLite(), dbname = "BX_db.sqlite")

# Load the books table
books <- dbGetQuery(con, "SELECT ISBN, \"Book-Title\" FROM 'BX-Books'")


# disconnect from the database

dbDisconnect(con)

# Load the recommendations
recommendations <- read.csv("outputs/recommendations.csv")

# the format of the file is:
# "Recommendation_1","Recommendation_2","Recommendation_3","Recommendation_4","Recommendation_5","Recommendation_6","Recommendation_7","Recommendation_8","Recommendation_9","Recommendation_10"
# "0345339703","0375727345","0380727501","0553274295","0553296981","0062502182","0375703861","039592720X","044022165X","0679446486"
# ...

# create a new df from the recommendations df with the same columns

recommendations_titles <- data.frame(
    Recommendation_1 = character(nrow(recommendations)),
    Recommendation_2 = character(nrow(recommendations)),
    Recommendation_3 = character(nrow(recommendations)),
    Recommendation_4 = character(nrow(recommendations)),
    Recommendation_5 = character(nrow(recommendations)),
    Recommendation_6 = character(nrow(recommendations)),
    Recommendation_7 = character(nrow(recommendations)),
    Recommendation_8 = character(nrow(recommendations)),
    Recommendation_9 = character(nrow(recommendations)),
    Recommendation_10 = character(nrow(recommendations))
)

# convert the ISBNs to book titles
for (i in 1:nrow(recommendations)) {
    for (j in 1:10) {
        isbn <- recommendations[i, j]
        book_title <- books[books$ISBN == isbn, "Book-Title"]
        if (length(book_title) > 0) {
            recommendations_titles[i, j] <- book_title
        } else {
            recommendations_titles[i, j] <- NA # or some default value
        }
    }
}


# # Save the converted recommendations
write.csv(recommendations_titles, "outputs/final200_recommendation.csv", row.names = FALSE)
