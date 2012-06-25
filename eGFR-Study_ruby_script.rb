require 'rubygems'
require 'mysql' 			# for DB Connectivity
require 'date' 				# for date formatting and arithmetic
require 'progressbar' 		# for progress bar

begin
    # connect to the MySQL server
    # con = Mysql.new('DBHost', 'USER', 'Password', 'Database')
    
    con = Mysql.new('localhost', 'root', 'de117gx', 'egfr')
    
    # get server version string and display it and test connectivity
    puts "Server version: " + con.get_server_info

	# create the results DB Table
	create_table_query = "
CREATE TABLE `search_results` (
  `NHSNo` varchar(25) DEFAULT NULL,
  `DOB` date DEFAULT NULL,
  `Sex` varchar(25) DEFAULT NULL,
  `EG` varchar(25) DEFAULT NULL,
  `DR` date DEFAULT NULL,
  `GP` varchar(25) DEFAULT NULL,
  `Postcode` varchar(25) DEFAULT NULL,
  `Sodium` decimal(25,0) DEFAULT NULL,
  `Potassium` decimal(25,1) DEFAULT NULL,
  `Urea` decimal(25,1) DEFAULT NULL,
  `GFRE` decimal(25,0) DEFAULT NULL,
  `Creat` decimal(25,0) DEFAULT NULL,
  `DiffFromIndexDR` decimal(25,0) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;
"
	con.query("DROP TABLE IF EXISTS `search_results`")
	con.query(create_table_query)

    # Get the IDs that will have at least to records in study period 
	rs = con.query("select NHSNo, NumberOfResults FROM (SELECT count(NHSNo) as NumberOfResults , NHSNo  from  egfr_results where GFRE <=15 GROUP by NHSNo) AS t1 where NumberOfResults >2")
	
	# Give an indication of processing load
	printf "Records matching initial criteria and to process: %s \n",rs.num_rows
	pbar = ProgressBar.new("Finding eGFRs and Processing", rs.num_rows)
	
	# Loop through IDs with > 1 Record
	rs.each do |precord| 
	
		# select the eGFR results for a patient and make sure earliest is first in result set
		q2 = "select * from egfr_results where NHSNo ='" + precord[0] +"' order by DR ASC"
		
		if (precord[0].nil? or precord[0] == 0)
			# If the NHS Number is NULL or 0 then move onto next one as this cant be a valid number
		else
		
		# Get eGFR results for NHS Number
		eGFRResults = con.query(q2)
		
		# create a temporary hash to hold resuts
		tmp_hash = Hash.new
		
		# Reset/Set Flag, this is set if record fails study criteria
		flag = 0
		
			# loop through each eGFR result for patient
			eGFRResults.each_hash do |row|
			
			# Try and stop false results getting Through
			
			if row["GFRE"].to_i == 0
				# printf "I've trapped a string thats converting to 0"
			else	
			
				if row["GFRE"].to_i <= 15
					if tmp_hash.size ==0
						
						# Yes it is the 1st result
						# Store the date of this result with key DR
						
						tmp_hash["1stDR"] = row["DR"]
						
						# Some debugging if required : Could add some checking for NIL
						#printf "NHSNo: %s, DOB: %s,Sex: %s, EG: %s,DR: %s, GP: %s, Postcode: %s, Sodium: %s, Potassium: %s, Urea: %s, GFRE: %s,CREAT: %s, \n", row["NHSNo"], row["DOB"], row["Sex"], row["EG"],row["DR"], row["GP"], row["Postcode"], row["Sodium"], row["Potassium"], row["Urea"], row["GFRE"], row["CREAT"]
						
						insert_query ="INSERT INTO search_results (NHSNo, DOB,Sex, EG,DR, GP, Postcode, Sodium, Potassium, Urea, GFRE,CREAT, DiffFromIndexDR) VALUES ('" 
						insert_query << row["NHSNo"] << "','"
						insert_query <<	row["DOB"] << "','"
						insert_query << row["Sex"] << "','"
						insert_query << row["EG"] << "','"
						insert_query << row["DR"] << "','"
						insert_query << row["GP"] << "','"
						insert_query << row["Postcode"] << "','"
						insert_query << row["Sodium"] << "','"
						insert_query << row["Potassium"]<< "','"
						insert_query << row["Urea"]<< "','"
						insert_query << row["GFRE"]<< "','"
						insert_query << row["CREAT"] << "','"
						insert_query << "0')"	
						con.query(insert_query)
						
					else
						# printf "egfr result: %s \n", row["GFRE"].to_i
						# Its not the 1st result < 15
						# Get the comparison Date
						
						comparison_date = tmp_hash["1stDR"]
						
						# ensure correct date format for date arithmetic
						Date.strptime comparison_date , '%Y-%m-%d'
						
						# Is comparison date > 30 days after new date
						diffromIndex = (Date.strptime row["DR"] , '%Y-%m-%d')- (Date.strptime comparison_date , '%Y-%m-%d')
						
						if (diffromIndex > 30)
							
							# Yes it is so store this record into database
							tmp_hash[row["DR"]]= [row["GFRE"]]
							
							insert_query ="INSERT INTO search_results (NHSNo, DOB,Sex, EG,DR, GP, Postcode, Sodium, Potassium, Urea, GFRE,CREAT, DiffFromIndexDR) VALUES ('" 
							insert_query << row["NHSNo"] << "','"
							insert_query <<	row["DOB"] << "','"
							insert_query << row["Sex"] << "','"
							insert_query << row["EG"] << "','"
							insert_query << row["DR"] << "','"
							insert_query << row["GP"] << "','"
							insert_query << row["Postcode"] << "','"
							insert_query << row["Sodium"] << "','"
							insert_query << row["Potassium"]<< "','"
							insert_query << row["Urea"]<< "','"
							insert_query << row["GFRE"]<< "','"
							insert_query << row["CREAT"] << "','"
							insert_query << diffromIndex.to_s << "')"	
							con.query(insert_query)
						end # check if dff > 30
						
						# provide some feedback to user	
						# printf "NHSNo: %s, DR %s, eGFR %s time Diff:%s \n", row["NHSNo"], row["DR"], row["GFRE"], (Date.strptime row["DR"] , '%Y-%m-%d')- (Date.strptime comparison_date , '%Y-%m-%d')
					end # end if tmp_hash size ==0
				else
					# Its not less than 15 so dont Process and delete from results Table
					# Flag criteria not met and break out of loop
					flag =1
					break
						
				end # end if >15
			end # end if GFRE not 0
		
			end # loop for eGFR results for NHSNumber
			pbar.inc
			
			# If not met criteria delete from results table
			if flag == 1
				delete_query = "delete from search_results where NHSNo = '" + precord[0] + "'"
				con.query(delete_query)
			end # end delete records from result if eGFR > 15 at any point
			
			
		end # end NHSNumber loop i.e move to next patient
	end # end begin 
	pbar.finish # stop progress bar
	
	# Clean up results table with further study criteria
	
	only_one_result_query ="delete
FROM search_results 
where NHSNo in ((select NHSNO from (SELECT count(NHSNo) as NumberOfResults , NHSNo  from  search_results GROUP by NHSNo) as t1 where NumberOfResults <2))"
	con.query(only_one_result_query)
   
   # Crude Error Checking for MySQL Errors
   rescue Mysql::Error => e
     puts "Error code: #{e.errno}"
     puts "Error message: #{e.error}"
     puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
   ensure
     # disconnect from server
     con.close if con
   end
