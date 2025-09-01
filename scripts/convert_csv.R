# there are 3 files in the BX_MySQL_Inserts folders
# 1. BX-Users_Insert.sql
# 2. BX-Books_Insert.sql
# 3. BX-Book-Ratings_Insert.sql


# Function to convert a single line from MySQL dump to CSV format
convert_line <- function(line) {
  # Remove the INSERT IGNORE INTO `table_name` VALUES ( and the trailing );
  line <- gsub("^INSERT IGNORE INTO `[^`]+` VALUES \\(", "", line)
  line <- gsub("\\);$", "", line)

  # Replace single quotes with double quotes to ensure CSV formatting
  line <- gsub("'", "\"", line)

  return (line)
}

convert_insert_csv <- function(origin_path, output_path) {
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

input_files <- list.files("BX_MySQL_Inserts", full.names = TRUE)

output_files_names <- c("BX-Users.csv", "BX-Books.csv", "BX-Book-Ratings.csv")
output_folder <- "BX_csv"
output_files <- file.path(output_folder, output_files_names)

test_convert_line <- function(file_path) {
    # Open the file
    con <- file(file_path, "r")

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

# for ( i in 1:length(input_files)) {
#     print(paste("Starting conversion of file", input_files[i]))
#     test_convert_line(input_files[i])
# }

for (i in 1:length(input_files)) {
    # print starting conversion of file x
    print(paste("Starting conversion of file", input_files[i]))
    convert_insert_csv(input_files[i], output_files[i])
    # print conversion of file x completed
    print(paste("Conversion of file", input_files[i], "completed"))
}
