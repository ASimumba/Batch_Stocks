#############################################################################################
#   Analysing fund returns
#--------------------------------------------------------------------------------------------
## Packages to load
require(quantmod)
require(ggplot2) 
require(xts)
require(plotly)
require(highcharter)
library(PerformanceAnalytics)
library(dygraphs)
library(plotly)
#--------------------------------------------------------------------------------------------

#loading the data
fundreturn <- read.csv("fundreturns.csv", header = T)

# quick peep  of the data
head(fundreturn, 3)
str(fundreturn)
## Dates have been loaded as a factor instead of as dates. There is need to convert this variable to the date class and covert the rest of the variables to xts(Extensible Time Series)

temp <- xts(x =fundreturn[,-1], order.by = as.Date(fundreturn[,1])) 
# all the variables except data are coerced to xts using date as the index.
# Overwriting the fundreturn object with the xts temp object
fundreturn <- temp
str(fundreturn)
rm(temp) # gettting rid of temp object
## Next I, stack variables of the same unique class within the same column. That is the returns of all the stocks in one column and the tickers in another column, indexed by the date variable.

# make use of a temporary object.
temp <- data.frame(index(fundreturn), stack(as.data.frame(coredata(fundreturn))))
fundreturn_final <- temp

# Give the variables more descriptive names 
    names(fundreturn_final)[1] <-  "Year"
    names(fundreturn_final)[2] <-  "PercentageReturn"
    names(fundreturn_final)[3] <-  "Stockticker"
    names(fundreturn_final)
  rm(temp) # removing the temp. object
  # we coerce the data frame back to xts to be able to use quantmod and highcharter
  
#fundreturn_final <- xts(x=fundreturn_final[-1], order.by = as.Date(fundreturn_final[,1]))
  
ggplot(data = fundreturn_final, aes(x=Year, y=PercentageReturn, color=Stockticker)) +geom_line()
  ggplotly() 
################################################################################
  
# Google stock Performance
# GOOG
GOOG <- subset(fundreturn_final, Stockticker=="GOOG")
g <- ggplot(data = GOOG, aes(x=Year, y=PercentageReturn)) +geom_line()
g
# add features
? theme
g <- g + ggtitle("Google Monthly Return", subtitle = "For the Period between June 2007 - Nov. 2016") + 
      theme(panel.background = element_rect(fill = "white", colour = "grey50"),
            axis.text = element_text(colour = "blue"),
            axis.title.y = element_text(size = rel(1.0), angle = 90),
            axis.title.x = element_text(size = rel(1.0), angle = 360))

g <- g + labs(x = "Year",
        y ="Percentage return") 

g + annotate("text",x=as.Date("2009-09-01"),y=0.3245,label="HR",fontface="bold",size=3, colour = "forestgreen") +
annotate("text",x=as.Date("2010-04-01"),y=-0.1900,label="LR",fontface="bold",size=3,colour ="red") 
?legend

################################################################################

# Portfolio Performance Appraisal
#-------------------------------------------------------------------------------

# Having the following portfolio

# Google = GOOG, Amazon = AZMN,Apple = AAPL JP Morgans = JPM, Microsoft = MSFT, General Electric = GE, and Hewlett Packard = HPQ
#, "GE", "HPQ"

?subset
p1 <- subset(fundreturn_final, Stockticker =="AMZN")
p2 <- subset(fundreturn_final, Stockticker =="MSFT")
p3 <- subset(fundreturn_final, Stockticker =="AAPL")
p4 <- subset(fundreturn_final, Stockticker =="GOOG")

portfolio <- rbind(p1,p2,p3,p4) # binding the returns into one returns variable
rm("p1","p2", "p3","p4") # Removal of the temp. subsets 
 
# quick visual representation of the data
p <- ggplot(data = portfolio, aes(x = Year, y =PercentageReturn, colour = Stockticker))+geom_line()
p + labs(
        x = " Year",
        y = "Percentage return",
        colour = "Stock ticker") +
    ggtitle(" Apple, Amazon and Google Stock Returns",subtitle =" For the period June 2007 - Nov. 2016")

ggplotly()

################################################################################

#Dygraphing

p1 <- subset(fundreturn_final, Stockticker =="AMZN")
p2 <- subset(fundreturn_final, Stockticker =="MSFT")
p3 <- subset(fundreturn_final, Stockticker =="AAPL")
p4 <- subset(fundreturn_final, Stockticker =="GOOG")


# Converting to xts before graphing
AMZN <- xts(x = p1[,c(-1,-3)], order.by = p1[,1])
MSFT <- xts(x = p2[,c(-1,-3)], order.by = p2[,1])
AAPL <- xts(x = p3[,c(-1,-3)], order.by = p3[,1])
GOOG_ <- xts(x = p4[,c(-1,-3)], order.by = p4[,1])

rm("p1","p2", "p3","p4") # Removal of the temp. subsets 

merged_returns <- merge.xts(AMZN,MSFT,AAPL,GOOG_) # merging the separate share returns into one xts object.

dygraph(merged_returns, main = "Amazon v Microsoft v Apple v Google") %>% # Using pipes to connect the codes
  dyAxis("y", label ="%") %>%
  dyAxis("x", label ="Year") %>%
  dyOptions(colors = RColorBrewer::brewer.pal(4, "Set2")) 

################################################################################

# Let's now evaluate the portfolio

# We assume an equally weighted portfolio. Allocating 25% to all the stocks in our portfolio
w <- c(.25,.25,.25,.25)

# We use the performanceAnalytics built infuction Return.porftolio to calculate portfolio monthly returns

monthly_P_return <-  Return.portfolio(R = merged_returns, weights = w)

# Use dygraphs to chart the portfolio monthly returns.
dygraph(monthly_P_return, main = "Portfolio Monthly Return") %>% 
  dyAxis("y", label = "%")

################################################################################

# Add the wealth.index = TRUE argument and, instead of returning monthly returns,
# the function will return the growth of $1 invested in the portfolio.
dollar_growth <- Return.portfolio(merged_returns, weights = w, wealth.index = TRUE)

# Use dygraphs to chart the growth of $1 in the portfolio.
dygraph(dollar_growth, main = "Growth of $1 Invested in Portfolio") %>% 
  dyAxis("y", label = "$")

###############################################################################

# Calculating the Sharpe Ratio

# Method 1: use the Return.excess function from Performance Analytics package, 
# then calculate the Sharpe Ratio manually.
portfolio_excess_returns <- Return.excess(monthly_P_return, Rf = .0003)
print(sharpe_ratio_manual <- round(mean(portfolio_excess_returns)/StdDev(portfolio_excess_returns), 4))

# If we wanted to use the original, 1966 formulation of the Sharpe Ratio, there is one small 
# change to the code in Method 1.
print(sharpe_ratio_manual_1966 <- round(mean(portfolio_excess_returns)/StdDev(monthly_P_return), 4))

# Method 2: use the built in SharpeRatio function in Performance Analytics package.
print(sharpe_ratio <- round(SharpeRatio(monthly_P_return, Rf = .0003), 4))

################################################################################

