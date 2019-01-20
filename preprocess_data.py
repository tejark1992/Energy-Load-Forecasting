# -*- coding: utf-8 -*-
"""
Created on Sat Apr  7 22:47:22 2018

@author: Puneeth
Team : Ankit Jaiswal, Puneeth Gandla, Teja, Ranadheer V​   
#################### RTSM Term Project ###############
Energy Load Forecasting using Timeseries forecasting methods 
and Deep learning​
# Objective of the code : Preprocessing
"""

########## Data Pre-processing ##########

# Import required libraries
import pandas as pd # import pandas

# Load data
# set filename and filepath before running the code
filepath = 'D:/DA/PGDBA/IIT/MA60056_REGRESSION_AND_TIME_SERIES_MODELS/project/data/'
filename = 'household_power_consumption.txt'
data = pd.read_csv(filepath + filename, sep = ";")


# convert columns into relavent format
# errors had to be corerced due to missing values in the data
data['Global_active_power'] = pd.to_numeric(data['Global_active_power'],  errors = 'coerce')
data['Global_reactive_power'] = pd.to_numeric(data['Global_reactive_power'],  errors = 'coerce')
data['Voltage'] = pd.to_numeric(data['Voltage'], errors = 'coerce')
data['Global_intensity'] = pd.to_numeric(data['Global_intensity'], errors = 'coerce')
data['Sub_metering_1'] = pd.to_numeric(data['Sub_metering_1'], errors = 'coerce')
data['Sub_metering_2'] = pd.to_numeric(data['Sub_metering_2'], errors = 'coerce')
data['Sub_metering_3'] = pd.to_numeric(data['Sub_metering_3'], errors = 'coerce')



# Create variable 'Timestamp' using 'date' and 'Time'
data['Timestamp'] = data['Date'] + str(" ") + data['Time'] 
data['Timestamp'] = pd.to_datetime(data['Timestamp'], format = '%d/%m/%Y %H:%M:%S')   

# Add readings from all submeters - Total Submeter reading
#data['Sub_metering_tot'] = pd.to_numeric(data['Sub_metering_1'] + data['Sub_metering_2'] + 
#    data['Sub_metering_3'])

# create new column 'Global_total_power' using 'Global_active_power' and 
# 'Global_reactive_power'
data['Global_total_power'] = (data['Global_active_power']**2 + 
    data['Global_reactive_power']**2)**0.5

# calculate ratios of active power and reactive power wrt total power
data['ratio_active_power'] = data['Global_active_power'] / data['Global_total_power']
data['ratio_reactive_power'] = data['Global_reactive_power'] / data['Global_total_power']

#data['GTP_from_Volt'] = data['Voltage'] * data['Global_intensity'] / 1000
#data['error'] = data.Global_total_power - data.temp
#data.error.plot()


# create date and time variables using 'Timestamp'
#data['hour'] = pd.DatetimeIndex(data.Timestamp).hour
data['day'] = pd.DatetimeIndex(data.Timestamp).day
data['month'] = pd.DatetimeIndex(data.Timestamp).month
data['year'] = pd.DatetimeIndex(data.Timestamp).year


# Dealing with missing values
#data.isnull().sum() # number of missing values in Global_total_power
# 25,979 rows with NA values, drop these rows for now
data = data.dropna(how = 'any')    #to drop if any value in the row has a nan
#data.isnull().sum() # number of missing values in Global_total_power are 0 now

## Take mean of minutes to get hourly data
# Take mean of days to get daily data
data = data.drop(['Global_active_power', 'Global_reactive_power'], axis = 1)
data = data.groupby(['day', 'month', 'year']).mean().reset_index()
#data = data.groupby(['hour', 'day', 'month', 'year']).mean().reset_index()

# Calculate Global active and reactive powers from global total power
data['Global_active_power'] = data['Global_total_power'] * data['ratio_active_power']
data['Global_reactive_power'] = data['Global_total_power'] * data['ratio_reactive_power']

# create the lost timestamp using the datetime information
data['Timestamp'] = pd.to_datetime(data[['year', 'month', 'day']])
# data['Timestamp'] = pd.to_datetime(data[['year', 'month', 'day', 'hour']])

data = data.sort_values('Timestamp').reset_index() # sort dataframe based on timestamp

# drop unnecessary columns
data = data.drop(['day', 'month', 'year', 'ratio_active_power', 
                  'ratio_reactive_power' ], axis = 1)

#data = data.drop(['hour', 'day', 'month', 'year', 'ratio_active_power', 
#                  'ratio_reactive_power' ], axis = 1)
# reorder columns
data = data[['Timestamp', 'Global_active_power', 'Global_reactive_power',
             'Voltage', 'Global_intensity', 'Sub_metering_1', 
             'Sub_metering_2', 'Sub_metering_3', 'Global_total_power']]
# write data to csv file
data.to_csv(filepath + 'household_power_consumption.csv', sep = ',')



