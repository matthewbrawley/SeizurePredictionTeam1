<?php

 	$user_name = "root";
	$password = "root";
	$database = "seizure_prediction";
	$server = "127.0.0.1";

	$db_handle = mysqli_connect($server, $user_name, $password,$database);
	//$db_found = mysql_select_db($database, $db_handle);
	$db_found = "SELECT * FROM ".$database."";
		
		$pid = $_POST["pid"];	


$sql = "SELECT distinct * FROM seizure_data where patient_id='$pid' and class='1'";
//$result = $conn->query($sql);
 $result = mysqli_query($db_handle,$sql);
if ($result->num_rows > 0) {
   
    // output data of each row
    while($row = $result->fetch_assoc()) {
       //echo  $row["patient_id"];
	   echo "Seizure Found";
    }
   
} else {
    echo "Seizure Not Found";
}

?>