
setwd(dir = "D:/Academic/IIT KGP/Time Series/project/EDA")

data <- read.csv("household_power_consumption_hourly.csv", header = TRUE)
#data <- read.csv("household_power_consumption_daily.csv", header = TRUE)

str(data)

data$Timestamp <- as.POSIXct(as.character(data$Timestamp), format = "%Y-%m-%d%H:%M:%S")

library(lubridate)

data$Hour = format(data$Timestamp, format = "%H")

data$Month= format(data$Timestamp, format = "%m")

data$Day = weekdays(data$Timestamp)

data$Day_month= format(data$Timestamp, format = "%d")

data$Year= format(data$Timestamp, format = "%Y")

library(ggplot2)
library(dplyr)

#Hour wise
group = data %>%
          group_by(Hour) %>%
          summarise_at(vars(Global_active_power), 
                       funs(mean(., na.rm=TRUE)))
ggplot(group, aes(x = Hour, y = Global_active_power, fill = Hour)) + 
  geom_bar(stat = "identity")+
  labs(x = 'Hour'
       , y = 'Load Demand'
       , title = "Hourly Demand")+
  theme(text = element_text(family = 'Gill Sans', color = "#444444")
        ,plot.title = element_text(size = 35,hjust = 0.5)
        ,axis.title = element_text(size = 22, color = '#555555')
        ,axis.title.y = element_text(vjust = 1, angle = 90)
        ,axis.title.x = element_text(hjust = 0.5)
  )




#Month wise
group = data %>%
  group_by(Month) %>%
  summarise_at(vars(Global_active_power), 
               funs(mean(., na.rm=TRUE)))

ggplot(group, aes(x = Month, y = Global_active_power, fill = Month)) + 
  geom_bar(stat = "identity")+
  labs(x = 'Month'
       , y = 'Load Demand'
       , title = "Monthly Demand")+
  theme(text = element_text(family = 'Gill Sans', color = "#444444")
        ,plot.title = element_text(size = 35,hjust = 0.5)
        ,axis.title = element_text(size = 22, color = '#555555')
        ,axis.title.y = element_text(vjust = 1, angle = 90)
        ,axis.title.x = element_text(hjust = 0.5)
  )


#Day wise
group = data %>%
  group_by(Day) %>%
  summarise_at(vars(Global_active_power), 
               funs(mean(., na.rm=TRUE)))

ggplot(group, aes(x =Day, y = Global_active_power, fill = Day)) + 
  geom_bar(stat = "identity")+
  labs(x = 'Day'
       , y = 'Load Demand'
       , title = "Load versus Day")+
  theme(text = element_text(family = 'Gill Sans', color = "#444444")
        ,plot.title = element_text(size = 35,hjust = 0.5)
        ,axis.title = element_text(size = 22, color = '#555555')
        ,axis.title.y = element_text(vjust = 1, angle = 90)
        ,axis.title.x = element_text(hjust = 0.5)
  )



library(ggplot2)
library(plotly)

# Lineplot for "day_week" vs. "Count"
ggplot(data = data, aes(x = Timestamp, y = Global_active_power)) +
  # Set plot type to Bar plot and adjust width of bars
  geom_line() +
  # Set title for plot and lables for x & y axes
  labs(title = "Load versus Day ",
       x = "Time in day",
       y = "Load") +
  # Set text for Title, x & y axes labels
  theme(plot.title = element_text(size = 20, hjust = 0.5), 
        axis.text = element_text(face = "bold", size = 12),
        axis.title = element_text(face = "bold", size = 16),
        axis.title.y = element_text(vjust = 1.5),
        # legend position
        legend.position = "none") +
  scale_x_discrete(limits = c("2007","2008","2009","2010","2011"))
# Clear effect of this varaible "day_week" can be seen on response variable


ggplot(data = data, aes(x = Timestamp, y = Global_active_power)) +
  geom_line(color = 'red', alpha = 0.7) +
  geom_area(fill = 'green', alpha = .1) +
  labs(x = 'Day'
       , y = 'Load Demand'
       , title = "Load versus Day") +
  theme(text = element_text(family = 'Gill Sans', color = "#444444")
        #,panel.background = element_rect(fill = '#444B5A')
        #,panel.grid.minor = element_line(color = '#6a6a6a')
        #,panel.grid.major = element_line(color = '#6a6a6a')
        ,plot.title = element_text(size = 35,hjust = 0.5)
        ,axis.title = element_text(size = 22, color = '#555555')
        ,axis.title.y = element_text(vjust = 1, angle = 90)
        ,axis.title.x = element_text(hjust = 0.5)
  )


data1 = data[which(data$Year == '2009'),]

ggplot(data = data1, aes(x = Timestamp, y = Global_active_power)) +
  geom_line(color = 'red', alpha = 0.7) +
  geom_area(fill = 'green', alpha = .1) +
  labs(x = 'Day'
       , y = 'Load Demand'
       , title = "Load versus Day for year '2009' ") +
  theme(text = element_text(family = 'Gill Sans', color = "#444444")
        #,panel.background = element_rect(fill = '#444B5A')
        #,panel.grid.minor = element_line(color = '#6a6a6a')
        #,panel.grid.major = element_line(color = '#6a6a6a')
        ,plot.title = element_text(size = 35,hjust = 0.5)
        ,axis.title = element_text(size = 22, color = '#555555')
        ,axis.title.y = element_text(vjust = 1, angle = 90)
        ,axis.title.x = element_text(hjust = 0.5)
  )
