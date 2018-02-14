# **sql**
_Sql scripts for the day to day stuff and some specific operations_

## _awrMiscOps.sql_
Get awr informations, like the retention time, the snap interval, the dbid's present on your awr and other stuff

## _awrTimeBreakdown.sql_
Get the wait events and present them on the timeline

## _awrTopEvents.sql_
Get the wait events for the whole period

## cleanSchema.sql
Drop all objects from a given schema. Usefull for process where you want to reimport all objects of a schema or just clean it without having to bother about the user privileges or password or tablespace appointment etc...
```
SQL> @cleanSchema.sql <schema_name>
```

## _createUser.sql_
Just a simple plsql to create a user and grant all the basic permission

<small> 
    OBS: this one is still in building phase, with basically no error treatment or flexibility to unpredicted stuff
</small>

## _findObject.sql_
Find all objects wich the name constains the string passed to the script, it returns the owner, object name, object type, creation date and object status 
```
SQL> @findObject.sql <string>
```

## _getAsmDGInfo.sql_
## _getDesyncSequences.sql_

## _getGrants.sql_
## _getInstStatus.sql_
Get the status of the database, it shows the instance name(s), status, if logins are allowed and their hostnames.

## _getKillSessCmd.sql_
## _getUserInfo.sql_
## _selectivity.sql_
Get statistics of the distribution of the values on a column or group of columns to help on the decision making of create/alter/drop indexes
