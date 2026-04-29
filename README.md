# What Determines a Movie's Success?

## Project Overview
This project explores what really makes a movie "successful" using a large dataset from IMDb and TMDb. Instead of focusing on just one definition of success, we look at several different factors, including audience ratings, critic scores, revenue, budget, and genre.

The goal of this dashboard is to show that success in the film industry isn't based on a single variable, but is created from a complex interaction of artistic merit, financial backing, and cultural timing and impact.

## Dataset
The analysis uses the IMDb & TMDb Movie Metadata Dataset. Both files are available in our shared Google Drive folder:

https://drive.google.com/drive/folders/17K70lm-jYk5GDaM3gnBTBGpNGSu6W8e4?dmr=1&ec=wgc-drive-%5Bmodule%5D-goto

The folder contains two files:

* **`IMDB TMDB Movie Metadata Big Dataset (1M).csv`** – The original full dataset with ~1 million movies and 42 columns, including variables such as cast lists, production companies, keywords, plot overviews, and more.
* **`movies_database.csv`** – A smaller, streamlined version of the dataset with unused columns removed to improve performance. This is the file used by the dashboard. It keeps only the 17 columns needed for the app: title, vote_average, vote_count, release_date, revenue, runtime, budget, popularity, release_year, Director, IMDB_Rating, Meta_score, Star1, Star2, Star3, Star4, and genres_list.

Users are welcome to explore both files. The full dataset offers additional variables for further analysis beyond what the dashboard covers.

## Application Overview
The dashboard is built using R Shiny and Plotly, and allows users to interactively explore different perspectives on movie success.

### Shared Filters
* Genre selection
* Release year range

These filters apply to all plots, so users can focus on specific time periods or types of movies.

### Visualizations

#### 1. Ratings Over Time
Shows how average audience ratings change over time across different genres.

#### 2. Director vs. Revenue
Looks at top directors based on highly rated movies and compares how much revenue their films generate.

#### 3. Audience vs. Critics
Compares audience ratings with critic scores to highlight where they agree and where they differ.

#### 4. Budget vs. Success
Explores how a movie's budget relates to different success measures like revenue and ratings.

## Insights
* Ratings tend to stay fairly consistent over time across most genres
* High ratings don't always mean high revenue
* Audience and critic opinions can differ depending on the genre
* Bigger budgets can help with revenue, but don't guarantee success

## How to Run the Application
1. Clone or download this repository
2. Download `movies_database.csv` from the Google Drive folder linked above and place it in the same folder as `app.R`
3. Open the project in RStudio
4. Run:
```r
runApp()
```

## Project Structure
* `app.R` – main application
* `README.md` – project description
* `movies_database.csv` – cleaned dataset (download from Google Drive)

## Conclusion
This project shows that movie success isn't one-dimensional. A film can be successful in different ways, whether that's through revenue, strong ratings, or audience appeal. In conclusion, success comes down to how well a movie connects with people, along with the choices made during its production and release.
