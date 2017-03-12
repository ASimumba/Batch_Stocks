#Batch of closing returns on 19 stocks
# read in data
fund <- read.delim(file = "fundreturns.txt", header = T)
dim(fund.returns)
str(fund)
str(fund.returns$Dates)
head(fund.returns$Dates, 131)

date <- as.factor(fund.returns$Dates)
as.character(date)
# converting the variable Dates from a factor to a date format.
as.Date(fund$Dates, "%Y%m%d")
names(fund.returns)[1:19]
attach(fund.returns)
plot(x=date,y=GOOG)
require(quantmod)
require(ggplot2)
qplot(x=Dates, y=GOOG, data = fund.returns) + geom_line()
returns_subset <- select(fund.returns,Dates:MSFT)
head(returns_subset)
?select
two_stocks <- select(fund.returns,Dates,SPY,IJS)
plot(two_stocks)
head(two_stocks)
?plot
