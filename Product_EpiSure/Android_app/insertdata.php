<?php

 	$user_name = "root";
	$password = "root";
	$database = "seizure_prediction";
	$server = "127.0.0.1";

	$db_handle = mysqli_connect($server, $user_name, $password);
	//$db_found = mysql_select_db($database, $db_handle);
	$db_found = "SELECT * FROM ".$database."";
		
		$nm = $_POST["nm"];
		$no = $_POST["no"];	
		$ad = $_POST["ad"];
		$uid = $_POST["uid"];
		$psd = $_POST["psd"];	
		


   $query = "INSERT INTO patient_details (patient_name,contact_no,address,username,passwd) VALUES('$nm','$no','$ad','$uid','$psd')";
      //  $result = mysql_query($query) or die(mysql_error());
	  
       $result = mysqli_query($db_handle,$query);
        if ($result) {
            $response["error"] = false;
            $response["message"] = "Record added successfully!";
            echo "Record added successfully!";
        } else {
            $response["error"] = true;
            $response["message"] = "Failed to add prediction!";
             echo "Network Failed";
        }
        
?>