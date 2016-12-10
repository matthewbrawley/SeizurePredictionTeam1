<?php

 	$user_name = "root";
	$password = "root";
	$database = "seizure_prediction";
	$server = "127.0.0.1";

	$db_handle = mysqli_connect($server, $user_name, $password,$database);
	//$db_found = mysql_select_db($database, $db_handle);
	$db_found = "SELECT * FROM ".$database."";
		
		$uid = $_POST["uid"];	


$sql = "SELECT distinct * FROM patient_details where username='$uid'";
//$result = $conn->query($sql);
 $result = mysqli_query($db_handle,$sql);
if ($result->num_rows > 0) {
   
    // output data of each row
    while($row = $result->fetch_assoc()) {
       echo  $row["patient_id"];
	   //echo "Found";
    }
   
} else {
    echo "Not Found";
}

?>