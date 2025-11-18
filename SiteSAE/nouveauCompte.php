<?php
ob_start();

include "header.php";
include "Connect.inc.php";

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Validation des entrées utilisateur
    $prenom = htmlspecialchars(trim($_POST['prenom']));
    $nom = htmlspecialchars(trim($_POST['nom']));
    $date_naissance = htmlspecialchars(trim($_POST['date-naissance']));

    $num_telephone = htmlspecialchars(trim($_POST['num-telephone']));
    $num_telephone = htmlspecialchars(trim($_POST['num-telephone']));
    $numTel = str_replace(' ', '', $num_telephone); // Retirer les espaces
    if (strlen($numTel) != 10 || !ctype_digit($numTel)) {
        echo "Le numéro de téléphone doit contenir exactement 10 chiffres.";
        exit;
    }
    // Formatage pour l'affichage (par exemple : 06 12 34 56 78)
    $numTelAffiche = implode(' ', str_split($numTel, 2));

    $genre = htmlspecialchars(trim($_POST['genre']));
    $email = filter_var(trim($_POST['email']), FILTER_SANITIZE_EMAIL);
    $password = $_POST['password'];
    $confirm_password = $_POST['confirm-password'];

    // Hachage du mot de passe
    $hashed_password = password_hash($password, PASSWORD_DEFAULT);

    // Conversion du genre pour la BD (H ou F)
    if ($genre === "homme") {
        $genre = "H";
    } elseif ($genre === "femme") {
        $genre = "F";
    }

    try {
        // Requête préparée pour éviter les injections SQL
        $client = $conn->prepare("INSERT INTO Client (email, password, prenom, nom, numTel, genreC, dateNaissance ,pointFidelite) VALUES (:email, :password, :prenom, :nom, :num_telephone, :genre, :date_naissance ,0)");
        $client->bindParam(':prenom', $prenom);
        $client->bindParam(':nom', $nom);
        $client->bindParam(':date_naissance', $date_naissance);
        $client->bindParam(':num_telephone', $numTel);
        $client->bindParam(':genre', $genre);
        $client->bindParam(':email', $email);
        $client->bindParam(':password', $hashed_password);
        $client->execute();
        echo "Compte créé avec succès!";
        header("Location: connexionCompte.php");
    } catch (PDOException $e) {
        echo "<div class='alert alert-danger' role='alert'>Erreur SQL : " . $e->getMessage() . "</div>";    
    }
}
?>

<main class="d-flex justify-content-center align-items-center"
    style="margin-top: 5%;height: 150vh; background-color: white;">
    <div class="card p-4 shadow" style="width: 350px;">
        <h2 class="text-center mb-4" style="color: #FF1F11;">Créer compte</h2>
        <form method="post">
            <div class="mb-3">
                <label for="prenom" class="form-label">Prénom</label>
                <input type="text" class="form-control" id="prenom" name="prenom" placeholder="Entrez votre prénom" required>
            </div>
            <div class="mb-3">
                <label for="nom" class="form-label">Nom</label>
                <input type="text" class="form-control" id="nom" name="nom" placeholder="Entrez votre nom" required>
            </div>
            <div class="mb-3">
                <label for="date-naissance" class="form-label">Date de naissance</label>
                <input type="date" class="form-control" id="date-naissance" name="date-naissance" required>
            </div>
            <div class="mb-3">
                <label for="num-telephone" class="form-label">Numéro de téléphone</label>
                <input type="tel" class="form-control" id="num-telephone" value="0" name="num-telephone" placeholder="Entrez votre numéro de téléphone" required oninput="numTelrespect()">
                <div id="numTel-respect-message" style="color: red;"></div>
            </div>
            <div class="mb-3">
                <label for="genre" class="form-label">Genre</label>
                <select id="genre" name="genre" class="form-select" required>
                    <option value="" disabled selected>Choisissez votre genre</option>
                    <option value="homme">Homme</option>
                    <option value="femme">Femme</option>
                </select>
            </div>
            <div class="mb-3">
                <label for="email" class="form-label">Adresse e-mail</label>
                <input type="email" class="form-control" id="email" name="email" placeholder="Entrez votre email" required>
            </div>
            <div class="mb-3">
                <label for="password" class="form-label">Mot de passe</label>
                <input type="password" class="form-control" id="password" name="password" placeholder="Saisir votre mot de passe" required>
            </div>
            <div class="mb-3">
                <label for="confirm-password" class="form-label">Confirmez votre mot de passe</label>
                <input type="password" class="form-control" id="confirm-password" name="confirm-password" placeholder="Ressaisir votre mot de passe" required oninput="passwordPareil()">
                <div id="password-match-message" style="color: red;"></div>
            </div>
            <button type="submit" class="btn btn-danger w-100" style="background-color: #FF1F11;">Créer Compte</button>
            <div class="mt-3 text-center">
                <a href="connexionCompte.php" class="text-muted" style="font-size: 14px;">Se connecter</a>
            </div>
        </form>
    </div>
</main>
<?php
include "footer.php";
?>
<script>
function passwordPareil() {
    var password = document.getElementById("password").value;
    var confirmPassword = document.getElementById("confirm-password").value;
    var message = document.getElementById("password-match-message");

    if (password === "" || confirmPassword === "") {
        message.textContent = "";
    } else if (password !== confirmPassword) {
        message.textContent = "Les mots de passe ne correspondent pas.";
    } else {
        message.textContent = "";
    }
}

function formatNumTel(numTel) {
    // Supprimer tous les espaces existants
    numTel = numTel.replace(/\s+/g, '');

    // Ajouter un espace après chaque deux chiffres
    return numTel.replace(/(\d{2})(?=\d)/g, '$1 ');
}

function numTelrespect() {
    var numTelInput = document.getElementById("num-telephone");
    var numTel = numTelInput.value.replace(/\s+/g, ''); // Supprimer les espaces pour la validation
    var message = document.getElementById("numTel-respect-message");

    if (numTel === "") {
        message.textContent = "";
    } else if (!/^0\d{9}$/.test(numTel)) {
        message.textContent = "Le numéro de téléphone doit contenir exactement 10 chiffres et doit commencer par 0.";
    } else {
        message.textContent = "";
        numTelInput.value = formatNumTel(numTel); // Formater le numéro de téléphone
    }
}
</script>
</body>
<?php
ob_end_flush();
?>
</html>