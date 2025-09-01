# Submitters:
# 1. Eliyahu Gubman 213662364
# 2. Yair Levi 213200199

# This script will take the data dump from a MySQL DB and will parse it for Sqlite3 DB

# there are 3 files in the BX_MySQL_Inserts folders
# 1. BX-Users_Insert.sql
# 2. BX-Books_Insert.sql
# 3. BX-Book-Ratings_Insert.sql

# This script does the following:
#   Reads the MySQL dump file.
# Defines a function convert_insert that:
#   Replaces 'INSERT IGNORE' with 'INSERT'
# Replaces single quotes with double quotes
# Escapes single quotes within strings
# Removes backticks around table and column names and replace with " (double quotes)"
# Applies the conversion to each line of the dump file.
# Writes the converted statements to a new file.
# Optionally wraps the INSERT statements in a transaction for better performance.

convert_line <- function(line) {
  line <- gsub("INSERT IGNORE", "INSERT", line)
  # Step 1: Replace backticks around table/column names with double quotes
  line <- gsub("`", "\"", line)

  # Step 2: Escape single quotes inside string values (replace ' with '')
  # Only escape single quotes within values and not around NULL or numeric values
  line <- gsub("\\\\'", "''", line)

  return(line)
}


convert_insert <- function(origin_path, output_path) {
  mysql_dump <- readLines(origin_path)

  # check for errors
  if (length(mysql_dump) == 0) {
    stop("The file is empty")
  }

  # apply the conversion to each line of the dump file
  converted_dump <- sapply(mysql_dump, convert_line)

  # write the converted statements to a new file
  writeLines(converted_dump, output_path)

  return(converted_dump)
}

test_convert_line <- function(origin_path) {
  # Open the file
  con <- file(origin_path, "r")

  # Read the first line
  line <- readLines(con, n = 1)

  # Close the file
  close(con)

  # Apply the convert_line function
  converted_line <- convert_line(line)

  print("Original line:")
  print(line)
  # Print the result to the console
  print("Converted line:")
  print(converted_line)
}

# Test
# convert the files

# insert_folder <- file.path("BX_MySQL_Inserts")

# users_origin_path <- file.path(insert_folder, "BX-Users_Insert.sql")
# books_origin_path <- file.path(insert_folder, "BX-Books_Insert.sql")
# ratings_origin_path <- file.path(insert_folder, "BX-Books-Ratings_Insert.sql")

# test_convert_line(users_origin_path)
# test_convert_line(books_origin_path)
# test_convert_line(ratings_origin_path)



# convert the files

insert_folder <- file.path("BX_MySQL_Inserts")
output_folder <- file.path("BX_Sqlite_Inserts")

# users file
print("Converting users file")
users_origin_path <- file.path(insert_folder, "BX-Users_Insert.sql")

users_output_path <- file.path(output_folder, "BX-Users_Insert.sql")

users_converted <- convert_insert(users_origin_path, users_output_path)

# books file
print("Converting books file")
books_origin_path <- file.path(insert_folder, "BX-Books_Insert.sql")

books_output_path <- file.path(output_folder, "BX-Books_Insert.sql")

books_converted <- convert_insert(books_origin_path, books_output_path)

# ratings file
print("Converting ratings file")
ratings_origin_path <- file.path(insert_folder, "BX-Books-Ratings_Insert.sql")

ratings_output_path <- file.path(output_folder, "BX-Books-Ratings_Insert.sql")

ratings_converted <- convert_insert(ratings_origin_path, ratings_output_path)
