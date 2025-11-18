<?php
ob_start();
require_once 'Connect.inc.php';
require_once "gestioncategorie.php";
if (session_status() === PHP_SESSION_NONE) {
		session_start();
}
    $affiche = separateur($categorie, $scategorie);
?>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lutin & Co.</title>
    <!-- logo arrondi-->
     <link rel="icon" href="images/logo-entreprise-mini.png " style="border-radius: 50%;">
    <link rel="stylesheet" href="style1.css">
    <link rel="stylesheet" href="commande.css">
    <link href="https://fonts.googleapis.com/css2?family=Fredoka+One&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<header> 
<div class="header">
    <!-- Logo -->
    <div class="logo">
        <a href="index.php">
            <img src="images/logo-entreprise.png" alt="Logo">
        </a>
    </div>

    <!-- Barre de recherche -->
    <div class="recherche">
        <form class="search-bar" action="ListeProduit.php" method="GET">
            <input 
                type="text" 
                name="search" 
                placeholder="Entrez un mot-clé..." 
                value="<?php echo isset($_GET['search']) ? $_GET['search'] : null; ?>"
            >
            <button type="submit">
                <img src="images/loupe.png" alt="recherche">
            </button>
        </form>
    </div>

    <!-- Icons -->
    <div class="icons">
        <!-- Espace Admin -->
        <div>
            
            <?php
            if (isset($_SESSION['client_email'])) {
                // On récupère l'email
                $email = isset($_SESSION['client_email']) ? $_SESSION['client_email'] : (isset($_COOKIE['CidClient']) ? $_COOKIE['CidClient'] : '');
                
                if($email) {
                    $query = $conn->prepare("SELECT role FROM Client WHERE email = :email");
                    $query->bindParam(':email', $email);
                    $query->execute();
                    $result = $query->fetch(PDO::FETCH_ASSOC);

                    // CORRECTION ICI : On vérifie si le rôle est strictement égal à 'admin'
                    if ($result && $result['role'] == 'admin') {
                        echo "<a href='menuAdmin.php'><button class='espaceAdmin'>Espace Admin</button></a>";
                    }
                }
            }
            ?>
      
        </div>

        <!-- Icônes favorites, panier et utilisateur -->
        <div class="icons">
            <a href="favoris.php"><img src="images/coeur.jpg" alt="Favoris"></a>
            <a href="panier.php">
                <img src="images/cart.jpg" alt="Cart">
            </a>
            <?php
            if (isset($_SESSION['client_email'])) {
                echo '<a href="detailCompte.php"><img src="images/user.jpg" alt="User"></a>';
            } else {
                echo '<a href="connexionCompte.php"><img src="images/user.jpg" alt="User"></a>';
            }
            ?>
        </div>

        <!-- Sélection de la langue -->
        <div class="langue">
            <div>
                <img src="images/france.png" alt="Langue">
            </div>
            <div>
                <span>Langue </span>
            </div>
        </div>
    </div>
</div>

    <section class="menu">

        <div class="menu-age">
            <button class="deroulant">Âge</button> 
            <div class="liste-deroulant">
            <a href="ListeProduit.php?age=0" >Tout âge</a>

                <a href="ListeProduit.php?age=3">3 ans et +</a>
                <a href="ListeProduit.php?age=5">5 ans et +</a>
                <a href="ListeProduit.php?age=8">8 ans et +</a>
                <a href="ListeProduit.php?age=12">12 ans et +</a>
            </div> 
        </div>

        <div class="menu-type">
            <button class="deroulant">Type</button> 
            <div class="liste-deroulant">
            <?php
            print_r($affiche);
            ?>
            </div>
        </div>

        <div class="menu-promo">
            <a href="ListeProduit.php?promo=1" style="text-decoration: none;">Promotions</a>
        </div>

        <div class="menu-meilleur-ventes">
            <a href="ListeProduit.php?bestsell=1"style="text-decoration: none;">Nos Meilleures ventes</a>
        </div>

    </section> 

</header>
<?php
ob_end_flush();
?>