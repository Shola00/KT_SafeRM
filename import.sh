#!/bin/bash

# show commands being executed, per debug

# define database connectivity
myDataBase="Airline_project"
user="root"
# define directory containing CSV files/Users/shola.emmanuel/Desktop/import.sh
locationOfCsvDir="/$HOME/Desktop"

# go into directory
 cd $locationOfCsvDir
#
#  get a list of CSV files in directory
allCsvFiles=`ls -1 *.csv`

# loop through csv files
 for csvFile in ${allCsvFiles[@]};
 do

  # remove file extension
  csvFileLessExtension=`echo $csvFile | sed 's/\(.*\)\..*/\1/'`

   # remove ".csv" extension to generate table
    tableName="${csvFileLessExtension}"

  # get columns columns from CSV file
  nameOfColumns=`head -1 $locationOfCsvDir/$csvFile | tr ',' '\n' | sed 's/^"//' | sed 's/"$//' | sed 's/ /_/g'`
  #nameOfColumns_string=`head -1 $locationOfCsvDir/$csvFile | sed 's/ /_/g' | sed 's/"//g'`

  #ensure table exists
  /usr/local/mysql/bin/mysql -u $user $myDataBase << eof
    CREATE TABLE IF NOT EXISTS \`$tableName\` (
      id int(11) NOT NULL auto_increment,
      PRIMARY KEY  (id)
    ) ENGINE=MyISAM DEFAULT CHARSET=latin1
eof

#echo $nameOfColumns_string
   # loop through columns columns
  for column in ${nameOfColumns[@]};
   do
       # add column
    column=${column//[$'\t\r\n']}
    /usr/local/mysql/bin/mysql -u $user $myDataBase --execute="alter table \`$tableName\` add column \`$column\` varchar(30);"
    #import
#/usr/local/mysql/bin/mysql -u $user $myDataBase --execute="update passenger set id = replace(id,'street','St');"
  done

  insertToTable="insert INTO $tableName ("
  value=") value "
  done=";"

  tableIds=""
  valueids=""

  count=0
  while IFS=, read -r col1 col2
  do

      col2=${col2//[$'\t\r\n']}

      if [ $count -eq 0 ]; then
        tableIds="${col1},${col2}"
      else
        valueids="${valueids},($count, '${col2//,/','}')"
      fi;

      ((count++))
  done < $tableName.csv

  valueids=$( echo $valueids | sed 's/,*//')

  echo "$insertToTable $tableIds $value $valueids $done" | /usr/local/mysql/bin/mysql -u root Airline_project;

done

/usr/local/mysql/bin/mysql -u $user $myDataBase --execute="
        ALTER TABLE Airline DROP Airline_id;
        ALTER TABLE Country DROP Country_id;
        ALTER TABLE Passenger DROP Passenger_id;
        ALTER TABLE Ticket DROP Ticket_id; "
