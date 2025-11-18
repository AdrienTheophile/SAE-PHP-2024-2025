<?php
  try {
    $user = 'root'; 
    $pass = ''; 
    $dbName = 'ecommerce_sae'; 
    
    // Connexion PDO
    $conn = new PDO("mysql:host=localhost;dbname=$dbName;charset=UTF8", 
                    $user, $pass, 
                    array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION));
  }
  catch (PDOException $e){
    // En cas d'erreur, on affiche le message
    echo "Erreur de connexion : " . $e->getMessage() . "<br>";
    die();
  }
?>