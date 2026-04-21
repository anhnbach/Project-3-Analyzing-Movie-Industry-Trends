library(shiny)
library(plotly)
library(tidyverse)

# load the data
#setwd("/Users/anhbach/Desktop/DS2003")
movies <- read_csv("IMDB TMDB Movie Metadata Big Dataset (1M).csv", show_col_types = FALSE)

# pull all unique genres from the genres_list column
all_genres <- movies$genres_list %>%
  str_extract_all("'([^']+)'") %>%
  unlist() %>%
  str_remove_all("'") %>%
  unique() %>%
  sort()

# take the first genre listed for each movie
movies$primary_genre <- str_extract(movies$genres_list, "(?<=')[^']+(?=')")

# make release year numeric
movies$release_year <- as.numeric(movies$release_year)

# clean revenue and budget
movies$revenue[movies$revenue < 0] <- NA
movies$budget[movies$budget < 0] <- NA

# create a decade label like "1990s", "2000s"
movies$decade <- paste0(floor(movies$release_year / 10) * 10, "s")

# uniform color palette for genres across all plots
genre_colors <- c(
  "Action"           = "#E74C3C",
  "Adventure"        = "#E67E22",
  "Animation"        = "#F1C40F",
  "Comedy"           = "#2ECC71",
  "Crime"            = "#1ABC9C",
  "Documentary"      = "#3498DB",
  "Drama"            = "#2980B9",
  "Family"           = "#9B59B6",
  "Fantasy"          = "#8E44AD",
  "History"          = "#D35400",
  "Horror"           = "#C0392B",
  "Music"            = "#16A085",
  "Mystery"          = "#2C3E50",
  "Romance"          = "#E91E63",
  "Science Fiction"  = "#00BCD4",
  "Thriller"         = "#607D8B",
  "TV Movie"         = "#795548",
  "Unknown"          = "#9E9E9E",
  "War"              = "#455A64",
  "Western"          = "#BF360C"
)


ui <- fluidPage(
  
  tags$head(tags$style(HTML("
    .container-fluid { max-width: 100%; padding-left: 30px; padding-right: 30px; }
    .narrative {font-size: 16px; line-height: 1.7; max-width: 900px; margin: auto; background-color: #f5f5f5; padding: 20px; border-radius: 10px; }
    .narrative p { margin-bottom: 14px; }
    .note { color: gray; font-size: 13px; font-style: italic; margin-top: 10px; }
  "))),
  
  titlePanel(div("What Determines a Movie's Success?",
                 style = "text-align: center; font-weight: 600;")),
  
  # shared filters across all plots
  fluidRow(
    column(6,
           selectInput("genre", "Filter by Genre:",
                       choices = c("All", all_genres), width = "100%")
    ),
    column(6,
           sliderInput("year_range", "Release Year Range:",
                       min = 1970, max = 2023, value = c(1970, 2023), sep = "", width = "100%")
    )
  ),
  
  hr(),
  
  tabsetPanel(
    
    #Tab 1: Introduction
    tabPanel("Introduction",
             br(),
             div(class = "narrative",
                 
                 h3("Introduction"),
                 p("What is the most recent movie you've seen? Which one do you rewatch the
      most? Which one has left the greatest impact? Movies have significant
      cultural and economic significance, making them a fascinating topic for
      analysis. From when they were first developed to now, many changes have
      occurred in the process of plotlines and storytelling, filming techniques,
      production scale, evolving genres, etc. Still, they remain a primary form
      of entertainment and media, acting as a tool for storytelling, reflecting
      cultural beliefs and values, advocating political and social change, setting
      trends and influencing fashion, and more. Film allows people to visualize
      the world through a different perspective, fostering empathy and understanding.
      Thus, different people are drawn to different movies, but why are some movies
      so much more successful than others? This leads us to the question: are there
      certain factors that can predict a movie's success?"),
                 
                 br(),
                 
                 h4("Dataset Info"),
                 p("To delve into this question, we are investigating the IMDb & TMDb Movie
      Metadata Dataset. IMDb and TMDb are online databases for information
      regarding movies, including details such as cast, plot summary, and reviews,
      and the dataset extracts metadata from these websites for around 1 million
      movies. It contains 42 variables, such as IMDb ratings, TMDb ratings,
      metascore/critic reviews, revenue, budget, genre, and more, that can be
      used for analysis, providing a multi-dimensional view of trends and the
      opportunity to explore relationships and better understand patterns in what
      makes a movie successful. Movie success can be defined in different ways
      and cannot be captured by just one measure, so we aim to investigate how
      audience ratings, number of votes, critic scores, genre, and revenue
      interact to reveal different forms of success."),
                 
                 br(),
                 
                 p("Knowing that success is such a strong term, our investigation is broken
      down into four key perspectives. Before you read the final conclusions
      below, we encourage you to explore the interactive tabs at the top of this
      page to follow along with our dashboard. Each tab serves as a different
      lens through which to view the film industry, and all of them have shared
      filters for genre and year range. Once you have explored the data, scroll
      down to read our final thoughts on what makes a movie successful."),
                 
                 br(),
                 
                 h4("Conclusion"),
                 p("Overall, our goal of defining a successful movie has revealed that
      success is not a single destination, but a multifaceted spectrum. Through
      our analysis of nearly a million titles, it is clear that no one variable,
      either a large budget, prolific director, or specific genre, acts as a
      guaranteed formula for a hit. Instead, success is created from a complex
      interaction of artistic merit, financial backing, and cultural timing and
      impact. Our journey through the data helped us learn various lessons."),
                 
                 p("Considering genre and history, while certain genres have dominated
      specific eras in terms of popularity and ratings, the standard for a good
      story has evolved alongside filming techniques and audience sensibilities.
      In terms of the people involved, high-rated directors and star-studded casts
      can drive immense revenue, but critical acclaim doesn't always translate to
      becoming a box office hit. The presence of a strong, well-known director
      definitely raises a movie's ability to generate revenue, but neither has
      strong associations with popularity."),
                 
                 p("Considering budget, a larger budget increases a film's potential for
      revenue and high-end production value, but data has shown that some of the
      most beloved films by audiences and critics emerged from lower budgets,
      proving that a compelling story can outperform one with a higher financial
      capacity. Finally, the persistent gap between critic and audience scores
      reminds us that movies are experienced differently by everyone, as a movie
      can be a technical masterpiece to a critic but fail to entertain the
      public."),
                 
                 p("Ultimately, success is determined by an individual themselves;
      whether measured by a record-breaking opening weekend, a high rating, or
      the number of times a fan decides to watch the movie, the true success of
      a movie lies in its ability to connect with an audience. As the industry
      continues to shift, these patterns will keep evolving, but the core of
      cinema, which is the power of a well-told story, remains the ultimate
      predictor of a movie's lasting impact.")
             )
    ),
    
    #Tab 2: Ratings Over Time
    tabPanel("Ratings Over Time",
             br(),
             div(class = "narrative",
                 p("Starting off, how have audience ratings for different genres changed over
          time? There are many genres we all know and love, whether it be action,
          rom-com, sci-fi, or superheroes, but have these categories of movies always
          been well-rated? Film genres have undergone significant shifts in popularity
          over the past century, and this plot shows which genres were popular over
          the years, with popularity being determined by the average rating.")
             ),
             br(),
             plotlyOutput("plot1", width = "100%", height = "650px"),
             tags$p(textOutput("count1"), style = "color: gray; text-align: center;"),
             br(),
             div(class = "narrative",
                 p("A line chart is used here because it makes it easier to see how ratings change over time and compare different genres at the same time. Looking at the graph, most genres stay within a pretty similar range, which shows that ratings don’t really swing that much over time. Even though trends and preferences change, what people consider a 'good' movie seems to stay fairly consistent."),
                 p("At the same time, there are still some noticeable differences. Certain genres, like drama, tend to stay a little higher, while others move around more depending on the time period. When you filter by genre, you can see these patterns more clearly and how audience opinions shift depending on what kinds of movies are popular at the time. Overall, this shows that ratings are pretty stable, but they still play an important role in how we think about success.")
             )
    ),
    
    #Tab 3: Director vs. Revenue
    tabPanel("Director vs. Revenue",
             br(),
             div(class = "narrative",
                 p("While on the topic of genres, don't there always seem to be certain
          directors and actors who only work within specific genres? For example,
          Adam Sandler is known for comedy, Tom Cruise is known for action, and
          Jordan Peele is known for social horror. In the case of directors, many
          find a unique style that resonates with audiences and gain success through
          mastery, while actors become strongly identified with a role and become
          typecast. However, are there specific directors or cast members that are
          associated with higher revenue and popularity? This plot focuses on the
          relationship between the top 10 directors, determined by the highest-rated
          movies, and the revenue they generate, with the tooltip displaying the
          rating and the top-paid stars, and the color of the bars displaying the
          popularity score.")
             ),
             br(),
             fluidRow(
               column(12,
                      numericInput("top_n", "Top N Movies by Rating:",
                                   value = 10, min = 5, max = 50, width = "200px")
               )
             ),
             plotlyOutput("director_bar", width = "100%", height = "650px"),
             tags$p(textOutput("count2"), style = "color: gray; text-align: center;"),
             br(),
             div(class = "narrative",
                 p("A bar graph is used here because it provides a clear side-by-side
          comparison of how much financial value different directors generate. On
          first glance, it becomes clear that critical acclaim and commercial success
          aren't necessarily related. While the directors on this list have mastered
          the art of creating a highly-rated film, their total revenue and popularity
          vary significantly. Some directors achieve massive box office numbers often
          supported by high popularity scores, such as Christopher Nolan, suggesting
          that they have found the perfect balance between critical respect and
          mass-market appeal. Whereas, other directors have high ratings but a smaller
          revenue bracket, indicating a focus on niche prestige cinema rather than
          global blockbusters."),
                 p("When filtering by genre, you can see how specific star-director pairings
          tend to dominate certain categories. For instance, in Action or Sci-Fi,
          the revenue bars end up towering higher, reflecting the high-earning
          potential of these genres when led by a trusted director. Conversely, in
          genres like Drama or documentary, success is often more measured by rating
          and popularity rather than money. Ultimately, this visualization shows that
          while a high rating is a mark of quality, it is the combination of genre,
          star power, and popularity that drives a movie's revenue."),
                 p(class = "note", "Note: Only movies that received >10,000 votes on IMDb or
          TMDb are displayed to ensure the rating system isn't skewed by movies that
          don't have many votes.")
             )
    ),
    
    #Tab 4: Audience vs. Critics
    tabPanel("Audience vs. Critics",
             br(),
             div(class = "narrative",
                 p("Though we've talked about genres, directors, actors, and budget, there
          seems to be one key piece of information missing. Have you ever watched a
          movie, loved it, but then realized the critics hated it? One of the most
          interesting aspects of a movie is how critical opinion differs from public
          opinion, as critics focus on technical analysis, artistic merit, and craft,
          while the public is likely to focus on personal enjoyment, entertainment
          value, and emotional engagement. Let's determine how they are both related
          to success. This plot compares audience ratings, either through IMDb or
          TMDb ratings, with critic scores, denoted by metascore, across different
          genres and years.")
             ),
             br(),
             fluidRow(
               column(6,
                      radioButtons("rating_source", "Audience Rating:",
                                   choices = c("IMDb Rating" = "IMDB_Rating",
                                               "TMDB Rating" = "vote_average"),
                                   inline = TRUE)
               ),
               column(6,
                      selectInput("sort_by", "Sort Genres By:",
                                  choices = c("Audience Rating"     = "audience",
                                              "Critic Score"         = "critic",
                                              "Biggest Disagreement" = "gap"))
               )
             ),
             plotlyOutput("bars", width = "100%", height = "650px"),
             tags$p(textOutput("count4"), style = "color: gray; text-align: center;"),
             br(),
             div(class = "narrative",
                 p("A grouped bar chart is used to make it easier to directly compare
          average audience and critic ratings across genres. At a glance, most
          genres fall within a similar range, showing that critics and audiences
          often agree on the general level of quality. However, small but consistent
          differences appear across genres. In many cases, audience ratings are
          slightly higher than critic scores, suggesting that viewers are generally
          more forgiving or place more value on entertainment. In other cases,
          critics rate certain genres a bit higher, highlighting differences in how
          each group evaluates films."),
                 p("While these differences are not extreme, they are noticeable enough to
          show that success can be viewed differently depending on perspective. Some
          genres show larger gaps than others, and the ability to sort by
          disagreement makes these differences easier to identify, revealing which
          types of movies are more polarizing between critics and audiences.
          Together, this suggests that success is not defined by a single measure,
          but by a balance between critical evaluation and audience reception."),
                 p(class = "note", "Note: This chart only includes movies that have both
          audience and critic scores. Since many movies in the dataset are missing
          Metascore values, the analysis is based on a smaller subset of the data.")
             )
    ),
    
    #Tab 5: Budget vs. Success
    tabPanel("Budget vs. Success",
             br(),
             div(class = "narrative",
                 p("Considering revenue, let's think about other monetary metrics, especially
          the budget. When we first think about movie production, we think about
          budget \u2013 it determines what types of actors are hired, the type of sets
          available, the quality of the equipment, and more. A common belief is that
          low-budget films are less successful, while high-budget films are more
          successful, but let's find out if that's true. This plot compares the
          budget of a movie to different success metrics, such as revenue, IMDb
          rating, TMDB rating, and Metascore.")
             ),
             br(),
             fluidRow(
               column(6,
                      selectInput("metric", "Success Metric (Y-axis):",
                                  choices = c("Revenue"     = "revenue",
                                              "IMDb Rating" = "IMDB_Rating",
                                              "TMDB Rating" = "vote_average",
                                              "Metascore"   = "Meta_score"))
               ),
               column(6,
                      radioButtons("scale", "Budget Scale:",
                                   choices = c("Log", "Linear"), inline = TRUE)
               )
             ),
             plotlyOutput("scatter", width = "100%", height = "650px"),
             tags$p(textOutput("count3"), style = "color: gray; text-align: center;"),
             br(),
             div(class = "narrative",
                 p("A scatterplot is used here because it allows us to see how individual
          movies are spread across budget levels and how much variation exists
          within each range. Looking at revenue, there is a clear upward trend.
          Higher-budget films generally bring in more money, but it is not
          guaranteed. Some lower-budget films still perform well, while some
          big-budget movies perform worse. Budget helps, but it does not determine
          everything."),
                 p("When we look at ratings like IMDb and TMDB, the pattern becomes much
          less clear. Movies at all budget levels receive a wide range of scores,
          suggesting that audience reception depends more on factors such as story,
          genre, and overall experience rather than the amount spent on production.
          You can also see a noticeable cluster of higher-budget films in more
          recent decades, showing how large productions have become more common
          over time."),
                 p("For Metascore, the pattern is harder to interpret. There are fewer
          movies available, so it is more difficult to draw strong conclusions,
          but the overall trend still does not show a clear connection between
          budget and critical success. The ability to switch between different
          success metrics and filter by genre allows users to explore how these
          relationships change and see that success can take different forms
          depending on how it is measured. Overall, a higher budget increases the
          potential for success, but it does not guarantee winning audiences over."),
                 p(class = "note", "Note: Movies are filtered based on available budget and
          selected success metric, so the number of points varies depending on the
          metric chosen.")
             )
    )
  )
)


server <- function(input, output) {
  
  # Tab 2: Ratings Over Time
  output$plot1 <- renderPlotly({
    df <- movies
    df <- df[!is.na(df$vote_average), ]
    
    # shared filters
    df <- df[df$release_year >= input$year_range[1] &
               df$release_year <= input$year_range[2], ]
    if (input$genre != "All") {
      df <- df[grepl(input$genre, df$genres_list, fixed = TRUE), ]
    }
    
    plot_data <- df %>%
      group_by(release_year, primary_genre) %>%
      summarise(avg_rating = mean(vote_average), .groups = "drop")
    
    top_genres <- df %>%
      group_by(primary_genre) %>%
      summarise(count = n()) %>%
      arrange(desc(count)) %>%
      head(6)
    
    plot_data <- plot_data[plot_data$primary_genre %in% top_genres$primary_genre, ]
    
    used_genres <- unique(plot_data$primary_genre)
    colors_used <- genre_colors[used_genres]
    
    plot_ly(plot_data,
            x = ~release_year, y = ~avg_rating,
            color = ~primary_genre, colors = colors_used,
            type = "scatter", mode = "lines") %>%
      layout(
        title = "Average Rating Over Time (Top Genres)",
        xaxis = list(title = "Year"),
        yaxis = list(title = "Rating"),
        legend = list(orientation = "h", y = -0.15)
      )
  })
  
  output$count1 <- renderText({
    paste("Showing ratings from", input$year_range[1], "to", input$year_range[2])
  })
  
  #Tab 3: Director vs. Revenue
  get_data2 <- reactive({
    df <- movies
    df <- df[!is.na(df$release_year), ]
    df <- df[!is.na(df$vote_average) & !is.na(df$revenue), ]
    df <- df[df$revenue > 0, ]
    df <- df[!is.na(df$Director), ]
    df <- df[df$vote_count >= 10000, ]
    
    # shared filters
    df <- df[df$release_year >= input$year_range[1] &
               df$release_year <= input$year_range[2], ]
    if (input$genre != "All") {
      df <- df[grepl(input$genre, df$genres_list, fixed = TRUE), ]
    }
    
    df %>%
      arrange(desc(vote_average)) %>%
      slice_head(n = input$top_n)
  })
  
  output$director_bar <- renderPlotly({
    df <- get_data2()
    
    validate(
      need(nrow(df) > 0, "No movies found for this selection. Please adjust your filters.")
    )
    
    agg <- df %>%
      group_by(Director) %>%
      summarise(
        total_revenue = sum(revenue, na.rm = TRUE),
        avg_popularity = mean(popularity, na.rm = TRUE),
        rating = mean(vote_average, na.rm = TRUE),
        stars = paste(unique(c(first(Star1), first(Star2), first(Star3), first(Star4))), collapse = ", "),
        .groups = "drop"
      )
    
    agg$hover <- paste(
      "Director:", agg$Director,
      "<br>Revenue: $", format(agg$total_revenue, big.mark = ","),
      "<br>Avg Rating:", round(agg$rating, 1),
      "<br>Stars:", agg$stars
    )
    
    title_text <- if (input$genre == "All") {
      "Top Rated Movies: Director vs Revenue (All Genres)"
    } else {
      paste("Top Rated", input$genre, "Movies: Director vs Revenue")
    }
    
    plot_ly(
      data = agg,
      x = ~reorder(Director, -rating),
      y = ~total_revenue,
      type = "bar",
      textposition = "none",
      marker = list(color = ~avg_popularity,
                    colorscale = list(c(0, "#3498DB"), c(1, "#E74C3C")),
                    showscale = TRUE,
                    colorbar = list(title = "Popularity")),
      text = ~hover,
      hoverinfo = "text"
    ) %>%
      layout(
        title = title_text,
        xaxis = list(title = "Director"),
        yaxis = list(title = "Total Revenue ($)")
      )
  })
  
  output$count2 <- renderText({
    paste("Showing top", input$top_n, "movies",
          ifelse(input$genre == "All", "(all genres)", paste("in", input$genre)))
  })
  
  #Tab 4: Audience vs. Critics
  get_data4 <- reactive({
    df <- movies
    df <- df[!is.na(df$Meta_score), ]
    if (input$rating_source == "IMDB_Rating") {
      df <- df[!is.na(df$IMDB_Rating), ]
    } else {
      df <- df[!is.na(df$vote_average), ]
    }
    
    # shared year filter
    df <- df[df$release_year >= input$year_range[1] &
               df$release_year <= input$year_range[2], ]
    
    # shared genre filter - filters the data but still groups by primary_genre
    if (input$genre != "All") {
      df <- df[grepl(input$genre, df$genres_list, fixed = TRUE), ]
    }
    
    df
  })
  
  output$bars <- renderPlotly({
    df <- get_data4()
    
    if (input$rating_source == "IMDB_Rating") {
      by_decade <- df %>%
        group_by(primary_genre, decade) %>%
        summarise(audience = mean(IMDB_Rating, na.rm = TRUE),
                  critic = mean(Meta_score, na.rm = TRUE) / 10,
                  n = n(), .groups = "drop")
      by_all <- df %>%
        group_by(primary_genre) %>%
        summarise(audience = mean(IMDB_Rating, na.rm = TRUE),
                  critic = mean(Meta_score, na.rm = TRUE) / 10,
                  n = n(), .groups = "drop") %>%
        mutate(decade = "All")
      aud_label <- "Avg IMDb Rating"
    } else {
      by_decade <- df %>%
        group_by(primary_genre, decade) %>%
        summarise(audience = mean(vote_average, na.rm = TRUE),
                  critic = mean(Meta_score, na.rm = TRUE) / 10,
                  n = n(), .groups = "drop")
      by_all <- df %>%
        group_by(primary_genre) %>%
        summarise(audience = mean(vote_average, na.rm = TRUE),
                  critic = mean(Meta_score, na.rm = TRUE) / 10,
                  n = n(), .groups = "drop") %>%
        mutate(decade = "All")
      aud_label <- "Avg TMDB Rating"
    }
    
    genre_data <- bind_rows(by_all, by_decade)
    genre_data$decade <- factor(genre_data$decade,
                                levels = c("All", sort(unique(by_decade$decade))))
    
    if (input$sort_by == "audience") {
      sort_order <- by_all %>% arrange(desc(audience)) %>% pull(primary_genre)
    } else if (input$sort_by == "critic") {
      sort_order <- by_all %>% arrange(desc(critic)) %>% pull(primary_genre)
    } else {
      sort_order <- by_all %>% mutate(gap = abs(audience - critic)) %>%
        arrange(desc(gap)) %>% pull(primary_genre)
    }
    
    long <- genre_data %>%
      pivot_longer(cols = c(audience, critic),
                   names_to = "type", values_to = "rating") %>%
      mutate(type = ifelse(type == "audience", aud_label,
                           "Avg Metascore (scaled 1-10)"))
    
    plot_ly(data = long, x = ~primary_genre, y = ~rating,
            color = ~type, frame = ~decade, type = "bar",
            text = ~paste("Movies:", n), hoverinfo = "text+y",
            colors = c("#3498DB", "#E74C3C")) %>%
      layout(barmode = "group",
             xaxis = list(title = "Genre", categoryorder = "array",
                          categoryarray = sort_order),
             yaxis = list(title = "Average Rating (1-10)", range = c(0, 10)),
             legend = list(orientation = "h", y = 1.05, x = 0.5,
                           xanchor = "center"),
             margin = list(b = 120)) %>%
      animation_opts(frame = 1000, transition = 500, redraw = TRUE) %>%
      animation_slider(currentvalue = list(prefix = "Decade: ")) %>%
      animation_button(label = "Play")
  })
  
  output$count4 <- renderText({
    paste("Showing", nrow(get_data4()), "movies with both audience and critic ratings")
  })
  
  # Tab 5: Budget vs. Success
  get_data3 <- reactive({
    df <- movies
    df <- df[!is.na(df$budget) & df$budget > 0, ]
    
    # shared filters
    df <- df[df$release_year >= input$year_range[1] &
               df$release_year <= input$year_range[2], ]
    if (input$genre != "All") {
      df <- df[grepl(input$genre, df$genres_list, fixed = TRUE), ]
    }
    
    if (input$metric == "revenue") {
      df <- df[!is.na(df$revenue) & df$revenue > 0, ]
    } else {
      df <- df[!is.na(df[[input$metric]]), ]
    }
    df
  })
  
  output$scatter <- renderPlotly({
    df <- get_data3()
    y_vals <- df[[input$metric]]
    
    y_label <- switch(input$metric,
                      "revenue"      = "Revenue ($)",
                      "IMDB_Rating"  = "IMDb Rating",
                      "vote_average" = "TMDB Rating",
                      "Meta_score"   = "Metascore")
    
    x_type <- if (input$scale == "Log") "log" else "linear"
    y_type <- if (input$scale == "Log" & input$metric == "revenue") "log" else "linear"
    
    hover <- paste(df$title,
                   "\nBudget: $", format(df$budget, big.mark = ","),
                   "\n", y_label, ":", round(y_vals, 1),
                   "\nDirector:", df$Director)
    
    df_all <- df
    df_all$decade <- "All"
    df_combined <- bind_rows(df_all, df)
    df_combined$decade <- factor(df_combined$decade,
                                 levels = c("All", sort(unique(df$decade))))
    
    y_all <- df_combined[[input$metric]]
    hover_all <- paste(df_combined$title,
                       "\nBudget: $", format(df_combined$budget, big.mark = ","),
                       "\n", y_label, ":", round(y_all, 1),
                       "\nDirector:", df_combined$Director)
    
    used_genres <- unique(df_combined$primary_genre)
    colors_used <- genre_colors[used_genres]
    
    if (input$genre == "All") {
      plot_ly(data = df_combined, x = ~budget, y = y_all,
              color = ~primary_genre, colors = colors_used,
              frame = ~decade,
              text = hover_all, hoverinfo = "text",
              type = "scatter", mode = "markers",
              marker = list(opacity = 0.6, size = 7)) %>%
        layout(xaxis = list(title = "Budget ($)", type = x_type),
               yaxis = list(title = y_label, type = y_type),
               legend = list(title = list(text = "Genre"),
                             orientation = "v", x = 1.02, y = 1)) %>%
        animation_opts(frame = 1000, transition = 500) %>%
        animation_slider(currentvalue = list(prefix = "Decade: ")) %>%
        animation_button(label = "Play")
    } else {
      plot_ly(data = df_combined, x = ~budget, y = y_all,
              frame = ~decade,
              text = hover_all, hoverinfo = "text",
              type = "scatter", mode = "markers",
              marker = list(opacity = 0.6, size = 7, color = "#3498DB")) %>%
        layout(xaxis = list(title = "Budget ($)", type = x_type),
               yaxis = list(title = y_label, type = y_type)) %>%
        animation_opts(frame = 1000, transition = 500) %>%
        animation_slider(currentvalue = list(prefix = "Decade: ")) %>%
        animation_button(label = "Play")
    }
  })
  
  output$count3 <- renderText({
    paste("Showing", nrow(get_data3()), "movies")
  })
}

shinyApp(ui, server)
