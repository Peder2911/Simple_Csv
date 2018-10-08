
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

verbose <- (config[['verbose']] == 'y')
print(verbose)

key <- config[['redis']][['listkey']]%>%
	unlist()

chunksize <- config[['chunksize']]%>%
	unlist()

if(verbose){
	writeLines(paste('working with',key),stderr())
	writeLines(paste('chunksize:',chunksize),stderr())
	}
# Redis stuff ######################

redis_config(host = config$redis$hostname,
	     port = config$redis$port,
	     db = config$redis$db)

r <- hiredis()

# Read data ########################
print(getwd())
dat <- read.csv(config[['csv file']],stringsAsFactors = FALSE)
write.csv(dat,'tee.csv')

if(verbose){
	writeLines(paste('read',nrow(dat),'rows from',config[['csv file']]),
		   stderr())
	}

# Write the data back ######

DBgratia::redisPutData(dat,r,
		       key,chunksize, 
		       verbose = verbose,
		       sanitize = TRUE)

