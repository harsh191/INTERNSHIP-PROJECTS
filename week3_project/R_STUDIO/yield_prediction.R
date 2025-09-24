#load libraries 


library(DBI)
library(RMySQL)
library(dplyr)
library(tidyr)
library(ggplot2)
library(Metrics)

# --- SQL Connection ---
con <- dbConnect(RMySQL::MySQL(),
                 dbname = "cropdb",
                 host = "localhost",
                 user = "root",
                 password = "Harsh@123")

# --- Get Data from SQL ---
data <- dbGetQuery(con, "SELECT * FROM crop_yield")

# --- Clean & Prepare Data ---
data_clean <- data %>%
  filter(!is.na(Yield)) %>%
  mutate(
    AnnualRainfall = as.numeric(Annual_Rainfall),
    Fertilizer = as.numeric(Fertilizer),
    Area = as.numeric(Area),
    Yield = as.numeric(Yield),
    CropYear = as.numeric(Crop_Year),
    Fertilizer_Tons = Fertilizer / 1000
  ) %>%
  drop_na(AnnualRainfall, Fertilizer, Area, Yield, CropYear)

# --- Plot 1: Average Annual Yield by State ---
ggplot(data_clean, aes(x = State, y = Yield)) +
  stat_summary(fun = mean, geom = "bar", fill = "orange") +
  labs(title = "Average Annual Yield by State", x = "State", y = "Mean Yield") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# --- Plot 2: Yield vs Rainfall ---
ggplot(data_clean, aes(x = AnnualRainfall, y = Yield)) +
  geom_point(alpha = 0.7) +
  geom_smooth(method = "lm", se = FALSE, color = "blue") +
  labs(title = "Yield vs Annual Rainfall", x = "Annual Rainfall", y = "Yield")


# --- Plot 3: Fertilizer (in tons) vs Yield ---
ggplot(data_clean, aes(x = Fertilizer_Tons, y = Yield)) +
  geom_point(alpha = 0.7, color = "darkgreen") +
  geom_smooth(method = "lm", se = FALSE, color = "black") +
  labs(title = "Fertilizer (tons) vs Yield", x = "Fertilizer (Tons)", y = "Yield")

# --- Plot 4: State vs Annual Rainfall (bar plot) ---
ggplot(data_clean, aes(x = State, y = AnnualRainfall)) +
  stat_summary(fun = mean, geom = "bar", fill = "dodgerblue") +
  labs(title = "Average Annual Rainfall by State", x = "State", y = "Mean Rainfall (mm)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# --- Predictive Modeling ---

model <- lm(log(Yield + 1) ~ AnnualRainfall + Fertilizer_Tons + Area, data = data_clean)
data_clean$predicted_yield <- exp(predict(model, newdata = data_clean)) - 1
summary(model)
data_clean$predicted_yield <- predict(model, newdata = data_clean)

# --- Model Evaluation ---
mae_val <- mae(data_clean$Yield, data_clean$predicted_yield)
rmse_val <- rmse(data_clean$Yield, data_clean$predicted_yield)
cat("MAE:", mae_val, "
RMSE:", rmse_val, "
")


# --- Export Results to Desired Location ---

write.csv(data_clean, "C:/Users/harsh/OneDrive/Desktop/week3_project/crop_yield_with_predictions.csv", row.names = FALSE)


# --- Disconnect ---
dbDisconnect(con)