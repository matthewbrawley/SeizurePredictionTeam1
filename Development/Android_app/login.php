<?php
$servername = "localhost";
$username = "root";
$password = "root";
$dbname = "dmn";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);
// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
} 

$sql = "SELECT distinct * FROM Student";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
   
    // output data of each row
    while($row = $result->fetch_assoc()) {
        echo  $row["name"]. ",";
    }
   
} else {
    echo "0 results";
}
$conn->close();
?>
