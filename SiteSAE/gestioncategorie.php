<?php

// 1. Initialisation des tableaux (CORRECTION WARNING)
$categorie = [];
$scategorie = []; 

// Requête SQL pour récupérer les catégories
$sql = "SELECT * FROM Categorie";
$stmt = $conn->query($sql);

// Vérification si la requête a réussi
if ($stmt) {
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $categorie[] = $row;
    }
}

// Requête SQL pour récupérer les Sous-catégories
$sql = "SELECT * FROM SousCategorie"; // Assure-toi que cette table existe bien maintenant
$stmt = $conn->query($sql);

if ($stmt) {
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $scategorie[] = $row;
    }
}


// Fonction d'affichage récursive (inchangée, juste mise en forme)
function afficherCategories($tabCategNV1, $tabCategNV2, $tabCategNV3, $listeCategorie) {
    $affichage = '<ul class="menu-categories">';

    foreach ($tabCategNV1 as $idCategorie1) {
        $affichage .= '<li class="menu-item">';
        $affichage .= '<a href="ListeProduit.php?idCategorie=' . $idCategorie1 . '">' 
                    . getNomCategorie($idCategorie1, $listeCategorie) 
                    . '</a>';
        
        $affichage .= '<ul class="submenu">';
        // On vérifie que $tabCategNV2 n'est pas vide
        if (!empty($tabCategNV2)) {
            foreach ($tabCategNV2 as $idCategorie2 => $parent) {
                if ($parent == $idCategorie1) {
                    $affichage .= '<li class="submenu-item">';
                    $affichage .= '<a href="ListeProduit.php?idCategorie=' . $idCategorie2 . '">' 
                                . getNomCategorie($idCategorie2, $listeCategorie) 
                                . '</a>';
                    
                    $affichage .= '<ul class="submenu">';
                    if (!empty($tabCategNV3)) {
                        foreach ($tabCategNV3 as $idCategorie3 => $parent2) {
                            if ($parent2 == $idCategorie2) {
                                $affichage .= '<li class="submenu-item">';
                                $affichage .= '<a href="ListeProduit.php?idCategorie=' . $idCategorie3 . '">' 
                                            . getNomCategorie($idCategorie3, $listeCategorie) 
                                            . '</a>';
                                $affichage .= '</li>';
                            }
                        }
                    }
                    $affichage .= '</ul>'; 
                    $affichage .= '</li>';
                }
            }
        }
        $affichage .= '</ul>'; 
        $affichage .= '</li>';
    }

    $affichage .= '</ul>'; 
    return $affichage;
}

function getNomCategorie($idCategorie, $categorie) {
    foreach ($categorie as $cat) {
        if ($cat['idCategorie'] == $idCategorie) {
            return $cat['nomCategorie'];
        }
    }
    return "Inconnu"; // Sécurité
}

// Fonction Séparateur CORRIGÉE
function separateur($categEnfant, $categParent) {
    $tabCategNV1 = [];
    $tabCategNV2 = [];
    $tabCategNV2b = []; // INITIALISATION AJOUTÉE (CORRECTION WARNING)
    $tabCategNV3 = [];
    $dump = [];

    // Si pas de catégories parentes, on arrête là pour éviter le crash
    if (empty($categParent)) {
        return "";
    }

    foreach ($categParent as $key) { // $key contient la ligne (idCategorie, idSousCategorie)
        
        // Logique de tri originale conservée
        if(!in_array($key['idCategorie'], $tabCategNV1)) {
            $tabCategNV1[] = $key['idCategorie'];
        }
        
        // Gestion du niveau 2
        if(!isset($tabCategNV2[$key['idSousCategorie']])) { // Vérif isset pour éviter warning
            $tabCategNV2[$key['idSousCategorie']] = $key['idSousCategorie'];
            $tabCategNV2b[$key['idSousCategorie']] = $key['idCategorie'];
        }

        if(in_array($key['idCategorie'], $tabCategNV1) && isset($tabCategNV2[$key['idCategorie']])) {
            $dump[] = $key['idCategorie'];
        }
        
        if(in_array($key['idCategorie'], $dump)) {
            $dump[] = $key['idSousCategorie'];
            $tabCategNV3[$key['idSousCategorie']] = $key['idCategorie'];
        }
    }

    // Nettoyage
    $tabCategNV1 = array_diff($tabCategNV1, $dump);
    
    if (!empty($tabCategNV2b)) {
        foreach ($tabCategNV2b as $key => $value) {
            if(in_array($key, $dump) && in_array($value, $dump)) {
                unset($tabCategNV2b[$key]);
            }
        }
    }

    return afficherCategories($tabCategNV1, $tabCategNV2b, $tabCategNV3, $categEnfant);
}
?>