<?php
// Especificar el nombre del usuario
$nombre_usuario = filter_input(INPUT_GET, 'nombre_usuario', FILTER_SANITIZE_STRING);
$nombre_usuario = $nombre_usuario ? $nombre_usuario : "hossam"; 
// Si no se proporciona nombre de usuario, se establece uno por defecto

//$nombre_usuario = isset($_GET['nombre_usuario']) ? $_GET['nombre_usuario'] : "hossam";

// Obtener la dirección IP del servidor Apache
$ip_servidor = $_SERVER['SERVER_ADDR'];

// Mostrar la información
echo "SWAP - " . htmlspecialchars($nombre_usuario) . "<br>";
echo "Dirección IP del servidor Apache: " . htmlspecialchars($ip_servidor);

//echo "SWAP - $nombre_usuario<br>";
//echo "Dirección IP del servidor Apache: $ip_servidor";
?>
