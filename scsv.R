
devnull <- file('/dev/null','w')
sink(devnull,type = 'message')

require(stringr)
require(glue)

require(tools)

require(jsonlite)
require(redux)

# Utility stuff ####################

scriptpath <- ComfyInTurns::myPath()

config <- readLines('stdin')%>%
	fromJSON()%>%
	suppressWarnings()

sink(type = 'message')
close(devnull)

verbose <- (config[['verbose']] == 'y')
rconf <- config[['redis']]
key <- rconf[['listkey']]
chunksize <- config[['chunksize']]

# Redis stuff ######################

r <- hiredis(redis_config(db = rconf[['db']],
                          port = rconf[['port']],
                          host = rconf[['hostname']]))

# Read data ########################
dat <- read.csv(config[['csv file']],stringsAsFactors = FALSE)

if(verbose){
	writeLines(paste('read',nrow(dat),'rows from',config[['csv file']]),
		   stderr())
	}

# Write the data back ######

DBgratia::redisPutData(dat,r,
		       key,chunksize, 
		       verbose = verbose)
		       

