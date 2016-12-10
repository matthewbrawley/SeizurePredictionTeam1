<?php

 	$user_name = "root";
	$password = "root";
	$database = "seizure_prediction";
	$server = "127.0.0.1";

	$db_handle = mysqli_connect($server, $user_name, $password,$database);
	//$db_found = mysql_select_db($database, $db_handle);
	$db_found = "SELECT * FROM ".$database."";
		
		$pid = $_POST["pid"];
		$ename = $_POST["ename"];
		$emobile = $_POST["emobile"];	
		

		$query = "insert into emergency_contact (patient_id,contact_name,contact_number) values ('$pid','$ename','$emobile')";
   
       $result = mysqli_query($db_handle,$query);
        if ($result) {
            $response["error"] = false;
            $response["message"] = "Record Updated successfully!";
            echo "Record added successfully!";
        } else {
            $response["error"] = true;
            $response["message"] = "Failed to add prediction!";
             echo "Network Failed";
        }
        
?>