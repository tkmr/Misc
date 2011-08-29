library(RMySQL)

connect_local <- function(name)
{
  mysql <- dbDriver("MySQL")
  db <- dbConnect(mysql, dbname=name, user="tonchidev", password="tonchi2321", default.file="/opt/local/etc/mysql5/my.cnf")
  return(db)
}

#HAU
sql <- "select hr as hour, count(*) as users
from (
  select DATE_FORMAT(time, '%Y-%m-%d') dt, hour(time) as hr, user_id
  from session_game_logs
  where game_id = 'majuu_wars'
  group by user_id
) tmp
group by dt, hr;"
table <- fetch(dbSendQuery(db, sql))

png("~/hau_majuu.png", width=800, height=800)
plot(table[, c(1,2)], type="l", xlim=c(0, 24), lab=c(10,5,5))
dev.off()

