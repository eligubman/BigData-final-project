# Big-Data Week 7

## Requirements


1. Process the `MySQL` dump files and convert into `Sqlite` format
   - (Optional) transform into `.csv` format
2. Create a DB into `Sqlite` and import the data
3. Make some queries to the DB (using `R` and/or `SQL`)
4. Create a Recommendation system based on the data

## Usage

Please note that you need to install `sqlite3` and `mysql` in order to run the scripts.

Once you have installed the required software, you can run the following commands:

```bash
# create the database in sqlite
sqlite3 BX_db.sqlite < "BX_Sqlite_Creates/BX_Creates.sql"
```

Now we will use the `R` script to convert tha data from the `MySQL` dump files into `Sqlite` format:

> [!Note] 
> its possible that the converted files already exist in the repo, but you can run the script to convert them again.

```bash
# convert the data from the MySQL dump files into Sqlite format
Rscript scripts/convert_inserts.R
```

Once you have created the database, you can import the data from the `Insert` files:

```bash
# import the data from the dump files
sqlite3 BX_db.sqlite < "BX_Sqlite_Inserts/BX-Users_Insert.sql"
sqlite3 BX_db.sqlite < "BX_Sqlite_Inserts/BX-Books_Insert.sql"
sqlite3 BX_db.sqlite < "BX_Sqlite_Inserts/BX-Book-Ratings_Insert.sql"
```

or using the csv convertor

```bash
Rscript scripts/convert_csv.R
```

and then import the data

```bash
sqlite3 BX_db.sqlite

sqlite> .mode csv
sqlite> .import "BX_csv/BX-Users.csv" "BX-Users"
sqlite> .import "BX_csv/BX-Books.csv" "BX-Books"
sqlite> .import "BX_csv/BX-Book-Ratings.csv" "BX-Book-Ratings"
```

## DB Schema

### BX-Users

```sql
CREATE TABLE IF NOT EXISTS "BX-Users" (
  "User-ID" INTEGER NOT NULL,
  "Location" TEXT,
  "Age" INTEGER,
  PRIMARY KEY ("User-ID")
);
```

### BX-Books

```sql
CREATE TABLE IF NOT EXISTS "BX-Books" (
  "ISBN" TEXT NOT NULL,
  "Book-Title" TEXT,
  "Book-Author" TEXT,
  "Year-Of-Publication" INTEGER,
  "Publisher" TEXT,
  "Image-URL-S" TEXT,
  "Image-URL-M" TEXT,
  "Image-URL-L" TEXT,
  PRIMARY KEY ("ISBN")
);
```

### BX-Book-Ratings

```sql
CREATE TABLE IF NOT EXISTS "BX-Book-Ratings" (
  "User-ID" INTEGER NOT NULL,
  "ISBN" TEXT NOT NULL,
  "Book-Rating" INTEGER NOT NULL,
  PRIMARY KEY ("User-ID", "ISBN")
);
```

## Queries

```sql
-- a. How many users?
SELECT COUNT(*) FROM BX_Users;

-- b. How many books?
SELECT COUNT(*) FROM BX_Books;

-- c. How many ratings?
SELECT COUNT(*) FROM BX_Book_Ratings;

-- d. Histogram of user-ratings (how many users have rated N times?)
-- delete the view if exists so there is no error
DROP VIEW IF EXISTS temp;

CREATE VIEW temp AS
SELECT COUNT(*) AS num_ratings
FROM BX_Users
NATURAL JOIN BX_Book_Ratings
GROUP BY "User-ID"
ORDER BY COUNT(*);

SELECT num_ratings, COUNT(*) AS bin_size
FROM temp
GROUP BY num_ratings
ORDER BY num_ratings;

-- e. Histogram of book-ratings (how many books have been rated N times?)
DROP VIEW IF EXISTS booksHistogram;

CREATE VIEW booksHistogram AS
SELECT COUNT(*) AS num_ratings
FROM BX_Book_Ratings
GROUP BY "ISBN"
ORDER BY COUNT(*);

SELECT num_ratings, COUNT(*) AS bin_size
FROM booksHistogram
GROUP BY num_ratings
ORDER BY num_ratings;

-- f. Top-10 rated books?
SELECT "Book-Title", COUNT("Book-Rating") AS rating_count
FROM BX_Books
NATURAL JOIN BX_Book_Ratings
GROUP BY "ISBN"
ORDER BY rating_count DESC
LIMIT 10;

-- g. Top-10 active users?
SELECT "User-ID", COUNT("User-ID") AS N
FROM BX_Book_Ratings
GROUP BY "User-ID"
ORDER BY N DESC
LIMIT 10;
```

## Recommendation System

Since the amount of data is very big (hence the name of the course), we need to take into account the amount of available memory. For this reason, we will use a `memory-based` recommendation system. such that any operation that would take too much memory would be performed locally. for example for matrix multiplication we can you matrix tailing to reduce the amount of memory used.
