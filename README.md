# sql
*Sql scripts for the day to day stuff and some specific operations*

## getInstStatus.sql
Get the status of the database, it shows the instance name(s), status, if logins are allowed and their hostnames.

## selectivity.sql
Get statistics of the distribution of the values on a column or group of columns to help on the decision making of create/alter/drop indexes

## getDesyncSequences.sql
PL/SQL block created to find sequences of an database that have their curr value lower than the column where they are used for

## awrMiscOps.sql
Get awr informations, like the retention time, the snap interval, the dbid's present on your awr and other stuff

## awrTimeBreakdown.sql
Get the wait events and present them on the timeline

## awrTopEvents.sql
Get the wait events for the whole period