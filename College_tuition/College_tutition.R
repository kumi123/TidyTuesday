##############################
## Tidy tuesday tuition data
##
## Matt Brachmann (PhDMattyB)
##
## 2020-03-13
##
##############################
dir.create('~/PhD/GitHub/TidyTuesday/College_tuition')

setwd('~/PhD/GitHub/TidyTuesday/College_tuition/')

library(patchwork)
library(janitor)
library(devtools)
library(skimr)
library(rsed)
library(data.table)
library(sjPlot)
library(tidyverse)

## Read in the data

tuition_cost = read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-10/tuition_cost.csv')

tuition_income = read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-10/tuition_income.csv') 

salary_potential = read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-10/salary_potential.csv') %>% 
  rename(state = state_name)

historical_tuition = read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-10/historical_tuition.csv')

diversity_school = read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-10/diversity_school.csv')

## View a dataset
View(tuition_cost)
 

# tuition cost per state --------------------------------------------------

## create a data set for cost per state
state_cost = tuition_cost %>% 
  group_by(state) %>% 
  summarise(avg_in_tuition = mean(in_state_total),
            avg_out_tuition = mean(out_of_state_total))

map_states = map_data('state') %>% 
  as_tibble() %>% 
  rename(state = region) %>% 
  select(-order)

## state names in the map data is lower case, 
## change the state names in the dataframe to lower case
state_cost$state = str_to_lower(sate_cost$state, locale = 'en')

plot_date = inner_join(state_cost, 
                       map_states) %>% 
  distinct() 

plot1 = ggplot(data = plot_date) +
  geom_polygon(aes(x = long, 
                   y = lat, group = state, 
                   fill = avg_out_tuition), 
               col = 'black') +
  scale_fill_gradient2(name = 'Average tuition',
                       low = '#155229',
                       mid = '#30B85D',
                       high = '#3ADE70',
                       midpoint = 30000) +
  labs(title = 'Average out of state tuition')+
  theme_minimal()+
  theme(panel.grid = element_blank(),
        axis.title = element_blank(),
        axis.text = element_blank(), 
        axis.line = element_blank(), 
        plot.title = element_text(face = 'bold', 
                                  size = 18,
                                  hjust = 0.5),
        legend.text = element_text(size = 12), 
        legend.title = element_text(size = 14))
  

# tuition cost and career pay ---------------------------------------------

## create a dataset for tuition cost and pay in career
cost_pay = left_join(tuition_cost, 
                     salary_potential, 
                     by = c('name', 
                            'state')) %>% 
  select(name, 
         state, 
         in_state_total, 
         out_of_state_total, 
         early_career_pay, 
         mid_career_pay, 
         type) %>% 
  na.omit() 

View(cost_pay)

plot2 = ggplot(data = cost_pay)+
  geom_line(aes(x = out_of_state_total, 
            y = early_career_pay), 
            col = '#1283B8')+
  geom_line(aes(x = out_of_state_total, 
                y = mid_career_pay),
            col = '#E00211') +
  labs(title = 'Relationship between tuition and projected pay',
       # subtitle = 'Early career pay in blue \n mid career pay in red',
       x = 'Amount of tuition',
       y = 'Amount of pay')+
  theme_classic()+
  theme(panel.grid = element_blank(),
        axis.title = element_text(size = 14),
        axis.text = element_text(size = 12),
        plot.title = element_text(face = 'bold', 
                                  size = 18,
                                  hjust = 0.5),
        legend.text = element_text(size = 12), 
        legend.title = element_text(size = 14))

plot1/plot2
