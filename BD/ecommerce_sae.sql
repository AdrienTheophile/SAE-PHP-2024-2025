-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : mar. 18 nov. 2025 à 17:26
-- Version du serveur : 10.4.32-MariaDB
-- Version de PHP : 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `ecommerce_sae`
--

DELIMITER $$
--
-- Procédures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `AjouterPanier` (IN `idC` INT, IN `idP` INT, IN `qte` INT)   BEGIN
    DECLARE qteDisponible INT;
    DECLARE nbProdPanier INT;
    DECLARE qteActuellePanier INT;

    -- Vérification basique
    IF qte < 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erreur : la quantité est nulle !';
    END IF;

    -- Vérification du stock
    SELECT quantiteStock INTO qteDisponible 
    FROM Stock 
    WHERE idProduit = idP;

    IF qteDisponible < qte THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erreur : la quantité du stock est trop faible !';
    END IF;

    -- On regarde si le produit existe déjà dans le panier
    SELECT COUNT(*) INTO nbProdPanier 
    FROM Panier_Client
    WHERE idProduit = idP AND idClient = idC;

    IF nbProdPanier = 0 THEN
        -- Si le produit n'y est pas, on l'ajoute
        INSERT INTO Panier_Client (idClient, idProduit, quantite)
        VALUES (idC, idP, qte);
    ELSE
        -- Sinon, on met à jour la quantité (Ajout de la nouvelle qté à l'ancienne)
        SELECT quantite INTO qteActuellePanier 
        FROM Panier_Client
        WHERE idProduit = idP AND idClient = idC;

        UPDATE Panier_Client
        SET quantite = qteActuellePanier + qte
        WHERE idProduit = idP AND idClient = idC;
    END IF;

    -- Décrémentation du stock (Optionnel mais souvent nécessaire)
    -- UPDATE Stock SET quantiteStock = quantiteStock - qte WHERE idProduit = idP;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GenererProduitsMassifs` ()   BEGIN
    DECLARE i INT DEFAULT 1;
    
    WHILE i <= 80 DO
        -- On insère des "Puzzles" génériques
        INSERT INTO Produit (nomProduit, prix, age, taille, nbJoueurMax, noteGlobale, description, idCategorie) 
        VALUES (
            CONCAT('Puzzle Paysage n°', i), -- Nom : Puzzle Paysage n°1, n°2...
            10.00 + i,                     -- Prix qui change un peu
            '10+', 
            'Standard', 
            1, 
            ROUND(3 + (RAND() * 2), 1),    -- Note aléatoire entre 3.0 et 5.0
            'Un magnifique puzzle de 1000 pièces pour se détendre.', 
            5                              -- Catégorie ENFANT (5)
        );
        SET i = i + 1;
    END WHILE;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `listReduction` ()   BEGIN
    -- On sélectionne quelques produits et on simule une colonne 'reduction' de 0.20 (20%)
    SELECT idProduit, 0.20 as reduction
    FROM Produit
    LIMIT 5;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `recapPanier` (IN `idC` INT, OUT `totalQuantite` INT, OUT `totalPrix` DECIMAL(10,2))   BEGIN
    -- Initialisation
    DECLARE totalQuantiteTemp INT DEFAULT 0;
    DECLARE totalPrixTemp DECIMAL(10,2) DEFAULT 0;

    -- Calcul
    SELECT SUM(pc.quantite), SUM(pc.quantite * p.prix)
    INTO totalQuantiteTemp, totalPrixTemp
    FROM Panier_Client pc
    JOIN Produit p ON pc.idProduit = p.idProduit
    WHERE pc.idClient = idC;

    -- Gestion du cas où le panier est vide (NULL)
    IF totalQuantiteTemp IS NULL THEN
        SET totalQuantiteTemp = 0;
    END IF;
    IF totalPrixTemp IS NULL THEN
        SET totalPrixTemp = 0.00;
    END IF;

    -- Assignation
    SET totalQuantite = totalQuantiteTemp;
    SET totalPrix = totalPrixTemp;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `adresse`
--

CREATE TABLE `adresse` (
  `idAdresse` int(11) NOT NULL,
  `codePostal` varchar(10) NOT NULL,
  `ville` varchar(100) NOT NULL,
  `rue` varchar(255) NOT NULL,
  `pays` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `adresse`
--

INSERT INTO `adresse` (`idAdresse`, `codePostal`, `ville`, `rue`, `pays`) VALUES
(1, '31700', 'Blagnac', '1 Place Georges Brassens', 'France'),
(2, '75000', 'Paris', '10 Rue de la Paix', 'France'),
(3, '33000', 'Bordeaux', '5 Avenue Jean Jaurès', 'France'),
(4, '31234', 'TestVille', '36 rue des etudiants', 'France');

-- --------------------------------------------------------

--
-- Structure de la table `avis`
--

CREATE TABLE `avis` (
  `idClient` int(11) NOT NULL,
  `idProduit` int(11) NOT NULL,
  `contenu` text DEFAULT NULL,
  `note` int(11) DEFAULT NULL,
  `dateAvis` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `avis`
--

INSERT INTO `avis` (`idClient`, `idProduit`, `contenu`, `note`, `dateAvis`) VALUES
(1, 1, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 2, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 3, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 4, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 5, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 6, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 7, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 8, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 9, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 10, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 11, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 12, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 13, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 14, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 15, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 16, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 17, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 18, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 19, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 20, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 21, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 22, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 23, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 24, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 25, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 26, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 27, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 28, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 29, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 30, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 31, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 32, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 33, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 34, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 35, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 36, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 37, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 38, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 39, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 40, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 41, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 42, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 43, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 44, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 45, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 46, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 47, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 48, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 49, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 50, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 51, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 52, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 53, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 54, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 55, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 56, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 57, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 58, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 59, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 60, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 61, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 62, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 63, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 64, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 65, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 66, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 67, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 68, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 69, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 70, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 71, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 72, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 73, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 74, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 75, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 76, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 77, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 78, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 79, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 80, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 81, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 82, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 83, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 84, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 85, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 86, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 87, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 88, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 89, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 90, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 91, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 92, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 93, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 94, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 95, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 96, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 97, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 98, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 99, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 100, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 101, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 102, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 103, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 104, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 105, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 106, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 107, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 108, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 109, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 110, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 111, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 112, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 113, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 114, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 115, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 116, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 117, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 118, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 119, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 120, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 121, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 122, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 123, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 124, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 125, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 126, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 127, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 128, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 129, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 130, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 131, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 132, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 133, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 134, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 135, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 136, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 137, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 138, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 139, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 140, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 141, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 142, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 143, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 144, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 145, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 146, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 147, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 148, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 149, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 150, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 151, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 152, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 153, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 154, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 155, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 156, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 157, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 158, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 159, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 160, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 161, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 162, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 163, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 164, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 165, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 166, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 167, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 168, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 169, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 170, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 171, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 172, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 173, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 174, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 175, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 176, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 177, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 178, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 179, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 180, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 181, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 182, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 183, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 184, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 185, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 186, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 187, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 188, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 189, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 190, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 191, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 192, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 193, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 194, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 195, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 196, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 197, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 198, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 199, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 200, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 201, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 202, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 203, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 204, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 205, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 206, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 207, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 208, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 209, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 210, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 211, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 212, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 213, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 214, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 215, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 216, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 217, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 218, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 219, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 220, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 221, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 222, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 223, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 224, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 225, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 226, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 227, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 228, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 229, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 230, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 231, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 232, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 233, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 234, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 235, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 236, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 237, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 238, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 239, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 240, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 241, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 242, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 243, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 244, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 245, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 246, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 247, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 248, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 249, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 250, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 251, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 252, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 253, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 254, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 255, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 256, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 257, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 258, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 259, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 260, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 261, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 262, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 263, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 264, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 265, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 266, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 267, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 268, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 269, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 270, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 271, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 272, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 273, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 274, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 275, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 276, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 277, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 278, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 279, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 280, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 281, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 282, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 283, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 284, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 285, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 286, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 287, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 288, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 289, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 290, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 291, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 292, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 293, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 294, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 295, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 296, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 297, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 298, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 299, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 300, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 301, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 302, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 303, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 304, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 305, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 306, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(1, 307, 'Vraiment super, livraison rapide !', 5, '2025-11-18'),
(2, 1, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 2, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 3, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 4, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 5, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 6, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 7, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 8, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 9, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 10, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 11, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 12, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 13, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 14, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 15, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 16, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 17, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 18, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 19, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 20, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 21, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 22, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 23, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 24, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 25, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 26, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 27, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 28, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 29, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 30, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 31, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 32, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 33, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 34, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 35, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 36, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 37, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 38, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 39, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 40, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 41, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 42, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 43, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 44, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 45, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 46, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 47, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 48, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 49, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 50, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 51, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 52, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 53, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 54, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 55, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 56, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 57, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 58, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 59, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 60, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 61, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 62, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 63, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 64, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 65, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 66, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 67, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 68, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 69, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 70, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 71, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 72, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 73, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 74, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 75, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 76, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 77, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 78, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 79, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 80, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 81, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 82, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 83, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 84, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 85, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 86, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 87, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 88, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 89, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 90, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 91, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 92, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 93, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 94, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 95, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 96, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 97, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 98, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 99, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 100, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 101, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 102, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 103, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 104, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 105, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 106, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 107, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 108, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 109, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 110, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 111, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 112, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 113, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 114, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 115, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 116, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 117, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 118, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 119, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 120, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 121, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 122, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 123, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 124, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 125, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 126, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 127, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 128, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 129, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 130, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 131, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 132, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 133, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 134, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 135, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 136, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 137, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 138, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 139, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 140, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 141, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 142, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 143, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 144, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 145, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 146, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 147, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 148, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 149, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 150, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 151, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 152, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 153, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 154, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 155, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 156, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 157, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 158, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 159, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 160, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 161, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 162, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 163, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 164, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 165, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 166, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 167, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 168, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 169, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 170, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 171, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 172, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 173, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 174, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 175, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 176, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 177, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 178, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 179, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 180, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 181, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 182, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 183, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 184, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 185, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 186, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 187, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 188, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 189, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 190, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 191, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 192, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 193, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 194, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 195, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 196, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 197, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 198, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 199, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 200, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 201, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 202, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 203, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 204, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 205, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 206, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 207, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 208, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 209, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 210, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 211, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 212, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 213, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 214, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 215, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 216, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 217, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 218, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 219, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 220, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 221, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 222, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 223, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 224, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 225, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 226, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 227, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 228, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 229, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 230, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 231, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 232, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 233, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 234, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 235, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 236, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 237, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 238, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 239, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 240, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 241, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 242, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 243, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 244, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 245, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 246, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 247, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 248, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 249, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 250, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 251, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 252, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 253, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 254, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 255, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 256, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 257, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 258, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 259, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 260, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 261, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 262, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 263, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 264, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 265, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 266, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 267, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 268, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 269, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 270, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 271, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 272, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 273, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 274, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 275, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 276, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 277, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 278, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 279, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 280, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 281, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 282, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 283, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 284, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 285, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 286, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 287, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 288, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 289, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 290, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 291, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 292, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 293, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 294, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 295, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 296, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 297, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 298, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 299, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 300, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 301, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 302, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 303, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 304, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 305, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 306, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(2, 307, 'Bon produit, mais emballage un peu léger.', 4, '2025-11-18'),
(3, 1, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 2, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 3, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 4, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 5, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 6, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 7, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 8, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 9, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 10, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 11, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 12, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 13, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 14, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 15, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 16, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 17, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 18, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 19, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 20, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 21, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 22, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 23, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 24, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 25, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 26, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 27, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 28, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 29, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 30, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 31, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 32, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 33, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 34, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 35, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 36, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 37, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 38, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 39, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 40, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 41, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 42, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 43, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 44, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 45, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 46, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 47, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 48, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 49, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 50, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 51, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 52, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 53, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 54, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 55, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 56, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 57, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 58, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 59, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 60, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 61, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 62, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 63, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 64, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 65, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 66, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 67, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 68, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 69, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 70, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 71, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 72, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 73, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 74, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 75, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 76, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 77, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 78, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 79, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 80, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 81, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 82, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 83, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 84, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 85, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 86, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 87, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 88, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 89, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 90, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 91, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 92, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 93, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 94, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 95, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 96, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 97, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 98, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 99, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 100, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 101, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 102, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 103, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 104, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 105, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 106, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 107, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 108, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 109, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 110, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 111, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 112, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 113, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 114, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 115, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 116, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 117, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 118, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 119, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 120, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 121, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 122, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 123, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 124, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 125, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 126, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 127, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 128, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 129, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 130, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 131, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 132, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 133, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 134, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 135, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 136, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 137, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 138, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 139, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 140, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 141, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 142, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 143, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 144, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 145, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 146, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 147, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 148, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 149, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 150, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 151, 'Incroyable, mes enfants adorent !', 5, '2025-11-18');
INSERT INTO `avis` (`idClient`, `idProduit`, `contenu`, `note`, `dateAvis`) VALUES
(3, 152, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 153, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 154, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 155, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 156, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 157, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 158, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 159, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 160, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 161, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 162, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 163, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 164, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 165, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 166, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 167, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 168, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 169, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 170, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 171, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 172, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 173, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 174, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 175, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 176, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 177, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 178, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 179, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 180, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 181, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 182, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 183, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 184, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 185, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 186, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 187, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 188, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 189, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 190, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 191, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 192, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 193, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 194, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 195, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 196, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 197, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 198, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 199, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 200, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 201, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 202, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 203, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 204, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 205, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 206, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 207, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 208, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 209, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 210, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 211, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 212, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 213, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 214, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 215, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 216, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 217, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 218, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 219, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 220, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 221, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 222, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 223, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 224, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 225, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 226, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 227, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 228, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 229, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 230, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 231, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 232, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 233, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 234, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 235, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 236, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 237, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 238, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 239, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 240, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 241, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 242, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 243, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 244, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 245, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 246, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 247, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 248, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 249, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 250, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 251, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 252, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 253, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 254, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 255, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 256, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 257, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 258, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 259, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 260, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 261, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 262, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 263, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 264, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 265, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 266, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 267, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 268, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 269, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 270, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 271, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 272, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 273, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 274, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 275, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 276, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 277, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 278, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 279, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 280, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 281, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 282, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 283, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 284, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 285, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 286, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 287, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 288, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 289, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 290, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 291, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 292, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 293, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 294, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 295, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 296, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 297, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 298, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 299, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 300, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 301, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 302, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 303, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 304, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 305, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 306, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(3, 307, 'Incroyable, mes enfants adorent !', 5, '2025-11-18'),
(4, 1, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 2, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 3, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 4, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 5, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 6, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 7, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 8, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 9, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 10, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 11, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 12, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 13, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 14, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 15, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 16, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 17, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 18, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 19, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 20, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 21, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 22, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 23, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 24, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 25, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 26, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 27, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 28, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 29, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 30, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 31, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 32, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 33, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 34, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 35, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 36, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 37, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 38, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 39, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 40, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 41, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 42, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 43, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 44, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 45, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 46, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 47, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 48, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 49, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 50, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 51, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 52, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 53, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 54, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 55, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 56, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 57, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 58, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 59, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 60, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 61, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 62, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 63, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 64, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 65, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 66, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 67, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 68, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 69, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 70, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 71, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 72, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 73, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 74, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 75, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 76, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 77, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 78, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 79, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 80, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 81, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 82, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 83, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 84, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 85, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 86, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 87, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 88, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 89, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 90, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 91, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 92, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 93, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 94, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 95, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 96, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 97, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 98, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 99, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 100, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 101, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 102, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 103, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 104, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 105, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 106, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 107, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 108, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 109, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 110, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 111, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 112, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 113, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 114, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 115, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 116, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 117, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 118, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 119, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 120, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 121, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 122, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 123, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 124, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 125, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 126, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 127, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 128, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 129, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 130, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 131, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 132, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 133, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 134, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 135, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 136, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 137, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 138, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 139, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 140, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 141, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 142, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 143, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 144, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 145, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 146, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 147, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 148, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 149, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 150, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 151, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 152, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 153, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 154, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 155, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 156, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 157, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 158, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 159, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 160, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 161, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 162, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 163, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 164, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 165, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 166, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 167, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 168, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 169, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 170, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 171, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 172, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 173, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 174, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 175, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 176, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 177, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 178, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 179, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 180, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 181, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 182, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 183, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 184, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 185, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 186, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 187, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 188, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 189, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 190, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 191, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 192, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 193, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 194, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 195, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 196, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 197, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 198, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 199, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 200, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 201, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 202, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 203, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 204, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 205, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 206, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 207, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 208, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 209, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 210, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 211, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 212, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 213, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 214, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 215, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 216, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 217, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 218, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 219, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 220, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 221, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 222, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 223, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 224, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 225, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 226, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 227, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 228, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 229, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 230, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 231, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 232, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 233, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 234, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 235, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 236, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 237, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 238, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 239, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 240, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 241, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 242, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 243, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 244, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 245, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 246, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 247, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 248, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 249, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 250, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 251, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 252, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 253, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 254, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 255, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 256, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 257, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 258, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 259, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 260, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 261, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 262, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 263, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 264, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 265, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 266, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 267, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 268, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 269, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 270, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 271, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 272, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 273, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 274, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 275, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 276, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 277, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 278, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 279, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 280, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 281, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 282, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 283, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 284, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 285, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 286, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 287, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 288, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 289, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 290, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 291, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 292, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 293, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 294, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 295, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 296, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 297, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 298, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 299, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 300, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 301, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 302, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 303, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 304, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 305, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 306, 'Correct pour le prix, sans plus.', 3, '2025-11-18'),
(4, 307, 'Correct pour le prix, sans plus.', 3, '2025-11-18');

-- --------------------------------------------------------

--
-- Structure de la table `cartebancaire`
--

CREATE TABLE `cartebancaire` (
  `numCarte` char(16) NOT NULL,
  `dateExpiration` date NOT NULL,
  `codeCarte` char(3) NOT NULL,
  `idClient` int(11) NOT NULL,
  `idAdresse` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `cartebancaire`
--

INSERT INTO `cartebancaire` (`numCarte`, `dateExpiration`, `codeCarte`, `idClient`, `idAdresse`) VALUES
('1111222233334444', '2026-12-31', '123', 1, 1);

-- --------------------------------------------------------

--
-- Structure de la table `categorie`
--

CREATE TABLE `categorie` (
  `idCategorie` int(11) NOT NULL,
  `nomCategorie` varchar(100) NOT NULL,
  `valCategorie` varchar(100) DEFAULT NULL,
  `niveau` int(11) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `categorie`
--

INSERT INTO `categorie` (`idCategorie`, `nomCategorie`, `valCategorie`, `niveau`) VALUES
(1, 'JEUX', 'jeux', 1),
(2, 'SOCIETE', 'societe', 2),
(3, 'PLEIN AIR', 'plein-air', 2),
(4, 'STRATEGIE', 'strategie', 3),
(5, 'ENFANT', 'enfant', 3);

-- --------------------------------------------------------

--
-- Structure de la table `client`
--

CREATE TABLE `client` (
  `idClient` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` varchar(50) DEFAULT 'client',
  `nom` varchar(100) DEFAULT NULL,
  `prenom` varchar(100) DEFAULT NULL,
  `numTel` varchar(15) DEFAULT NULL,
  `genreC` varchar(1) DEFAULT NULL,
  `dateNaissance` date DEFAULT NULL,
  `idAdresse` int(11) DEFAULT NULL,
  `pointFidelite` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `client`
--

INSERT INTO `client` (`idClient`, `email`, `password`, `role`, `nom`, `prenom`, `numTel`, `genreC`, `dateNaissance`, `idAdresse`, `pointFidelite`) VALUES
(1, 'test@test.com', '1234', 'client', 'Dupont', 'Jean', '0601020304', 'H', '1990-05-15', 1, 0),
(2, 'marie.curie@science.fr', 'radium', 'client', 'Curie', 'Marie', '0699887766', 'F', '1985-11-07', 2, 0),
(3, 'albert@relatif.fr', '1234', 'client', 'Einstein', 'Albert', NULL, NULL, NULL, 1, 0),
(4, 'thomas@pesquet.fr', '1234', 'client', 'Pesquet', 'Thomas', NULL, NULL, NULL, 1, 0),
(5, 'testclient@gmail.com', '$2y$10$SnzFPQFH0cwLxwh3E6oUlerTrbRk46ktqGlV5lz4xSfbyCOLFXddK', 'client', 'testclient', 'test', '0123456789', 'H', '1996-02-18', 4, 0);

-- --------------------------------------------------------

--
-- Structure de la table `codepromotion`
--

CREATE TABLE `codepromotion` (
  `idPromo` int(11) NOT NULL,
  `NomCodePromo` varchar(100) DEFAULT NULL,
  `CodePromo` varchar(50) NOT NULL,
  `reduction` decimal(3,2) DEFAULT NULL,
  `dateDebut` date DEFAULT NULL,
  `dateFin` date DEFAULT NULL,
  `idClient` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `codepromotion`
--

INSERT INTO `codepromotion` (`idPromo`, `NomCodePromo`, `CodePromo`, `reduction`, `dateDebut`, `dateFin`, `idClient`) VALUES
(1, 'Noël 2024', 'NOEL2024', 0.20, '2023-01-01', '2025-12-31', NULL),
(2, 'Bienvenue', 'WELCOME', 0.10, '2023-01-01', '2030-12-31', NULL),
(3, 'Fidélité', 'MERCI15', 0.15, '2023-01-01', '2025-12-31', 1);

-- --------------------------------------------------------

--
-- Structure de la table `commande`
--

CREATE TABLE `commande` (
  `idCommande` int(11) NOT NULL,
  `typeLivraison` varchar(50) DEFAULT NULL,
  `dateCommande` date NOT NULL,
  `idClient` int(11) NOT NULL,
  `idAdresse` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `commande`
--

INSERT INTO `commande` (`idCommande`, `typeLivraison`, `dateCommande`, `idClient`, `idAdresse`) VALUES
(1, 'Express', '2023-12-01', 1, 1);

-- --------------------------------------------------------

--
-- Structure de la table `composer`
--

CREATE TABLE `composer` (
  `idCommande` int(11) NOT NULL,
  `idProduit` int(11) NOT NULL,
  `quantite` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `composer`
--

INSERT INTO `composer` (`idCommande`, `idProduit`, `quantite`) VALUES
(1, 1, 1),
(1, 2, 2);

-- --------------------------------------------------------

--
-- Structure de la table `panier_client`
--

CREATE TABLE `panier_client` (
  `idClient` int(11) NOT NULL,
  `idProduit` int(11) NOT NULL,
  `quantite` int(11) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `panier_client`
--

INSERT INTO `panier_client` (`idClient`, `idProduit`, `quantite`) VALUES
(5, 2, 1),
(5, 7, 1);

-- --------------------------------------------------------

--
-- Structure de la table `panier_client_promo`
--

CREATE TABLE `panier_client_promo` (
  `idClient` int(11) NOT NULL,
  `idPromo` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `panier_client_promo`
--

INSERT INTO `panier_client_promo` (`idClient`, `idPromo`) VALUES
(1, 1);

-- --------------------------------------------------------

--
-- Structure de la table `produit`
--

CREATE TABLE `produit` (
  `idProduit` int(11) NOT NULL,
  `age` varchar(45) DEFAULT NULL,
  `taille` varchar(10) DEFAULT NULL,
  `nbJoueurMax` int(11) DEFAULT NULL,
  `prix` decimal(10,2) NOT NULL,
  `nomProduit` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `noteGlobale` decimal(3,2) DEFAULT NULL,
  `idCategorie` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `produit`
--

INSERT INTO `produit` (`idProduit`, `age`, `taille`, `nbJoueurMax`, `prix`, `nomProduit`, `description`, `noteGlobale`, `idCategorie`) VALUES
(1, '8+', 'Standard', 6, 29.99, 'Monopoly Classique', 'Le célèbre jeu de transactions immobilières. Achetez, vendez, négociez et gagnez !', 4.50, 2),
(2, '7+', 'Mini', 10, 12.50, 'Uno Deluxe', 'Le jeu de cartes familial n°1. Attention aux cartes +4 ! Boîte métal collector.', 4.80, 5),
(3, '5+', 'T5', 22, 19.99, 'Ballon de Foot', 'Ballon officiel taille 5, résistant sur toutes les surfaces (herbe, bitume).', 4.20, 3),
(4, '10+', 'L', 2, 45.00, 'Echecs en Bois', 'Jeu d échecs traditionnel en bois d érable. Plateau pliable et rangement feutré.', 5.00, 4),
(5, '10+', 'Standard', 4, 35.00, 'Scrabble', 'Le jeu de lettres pour toute la famille. Enrichissez votre vocabulaire en vous amusant.', 4.00, 2),
(6, '6+', 'XXL', 4, 150.00, 'Trampoline 3m', 'Trampoline de jardin diamètre 305cm avec filet de sécurité renforcé.', 4.70, 3),
(7, '6+', 'Standard', 2, 15.00, 'Puissance 4', 'Le jeu de stratégie verticale. Alignez 4 pions pour gagner.', 4.30, 5),
(8, '10+', 'Standard', 4, 39.99, 'Catan', 'Le jeu de stratégie et de commerce incontournable. Colonisez l île !', 4.70, 4),
(9, '8+', 'Standard', 6, 29.90, 'Dixit', 'Un jeu de déduction et d imagination avec des cartes magnifiquement illustrées.', 4.50, 2),
(10, '6+', 'Mini', 8, 14.99, 'Dobble', 'Le jeu d observation et de rapidité qui rend fou !', 4.60, 2),
(11, '6+', 'L', 12, 19.90, 'Mölkky', 'Le jeu de quilles finlandais. Idéal pour l extérieur.', 4.80, 3),
(12, '7+', 'Mini', 10, 18.50, 'Jungle Speed', 'Attrapez le totem le premier ! Attention aux signes trompeurs.', 4.40, 2),
(13, '8+', 'XXL', 5, 42.00, 'Les Aventuriers du Rail', 'Construisez vos lignes de chemin de fer à travers l Europe.', 4.90, 4),
(14, '8+', 'Standard', 6, 24.99, 'Cluedo', 'Qui a tué le Docteur Lenoir ? Menez l enquête.', 4.20, 2),
(15, '6+', 'Standard', 4, 22.00, 'Docteur Maboul', 'Opérez le patient sans trembler sinon ça sonne !', 4.00, 5),
(16, '3+', 'L', 1, 49.99, 'Kapla Baril 200', 'Jeu de construction en pin des Landes. Créativité illimitée.', 5.00, 5),
(17, '8+', 'M', 10, 29.99, 'Nerf Elite 2.0', 'Blaster avec fléchettes en mousse pour des batailles épiques.', 4.50, 3),
(18, '8+', 'Mini', 1, 12.99, 'Rubik s Cube', 'Le casse-tête le plus célèbre du monde.', 4.30, 4),
(19, '10+', 'Mini', 18, 11.90, 'Loup Garou', 'Jeu d ambiance et de bluff. Démasquez les loups parmi les villageois.', 4.60, 2),
(20, '10+', 'Standard', 7, 45.00, '7 Wonders', 'Prenez la tête de l une des sept grandes cités du monde antique.', 4.80, 4),
(21, '12+', 'Standard', 8, 19.50, 'Code Names', 'Jeu d association d idées et de déduction en équipe.', 4.70, 2),
(22, '10+', 'Standard', 6, 28.90, 'Unlock!', 'Un Escape Game inspiré dans une simple boîte de cartes.', 4.40, 4),
(23, '2+', 'M', 1, 15.00, 'Pâte à Modeler Play-Doh', 'Assortiment de 8 pots de couleurs pour créer à l infini.', 4.50, 5),
(24, '6+', 'M', 6, 17.99, 'Jenga', 'Retirez les blocs de bois sans faire tomber la tour !', 4.30, 2),
(25, '6+', 'XXL', 4, 19.99, 'Twister', 'Pied droit sur rouge ! Le jeu qui vous tord de rire.', 4.20, 2),
(26, '5+', 'L', 1, 12.00, 'Cerf-Volant Aigle', 'Cerf-volant géant facile à faire voler.', 4.10, 3),
(27, '6+', 'L', 4, 25.00, 'Set de Badminton', '4 raquettes et volant pour jouer dans le jardin.', 4.00, 3),
(28, '10+', 'Standard', 1, 11.00, 'Puzzle Paysage n°1', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.20, 5),
(29, '10+', 'Standard', 1, 12.00, 'Puzzle Paysage n°2', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.60, 5),
(30, '10+', 'Standard', 1, 13.00, 'Puzzle Paysage n°3', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.40, 5),
(31, '10+', 'Standard', 1, 14.00, 'Puzzle Paysage n°4', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.30, 5),
(32, '10+', 'Standard', 1, 15.00, 'Puzzle Paysage n°5', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.30, 5),
(33, '10+', 'Standard', 1, 16.00, 'Puzzle Paysage n°6', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.60, 5),
(34, '10+', 'Standard', 1, 17.00, 'Puzzle Paysage n°7', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.00, 5),
(35, '10+', 'Standard', 1, 18.00, 'Puzzle Paysage n°8', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.40, 5),
(36, '10+', 'Standard', 1, 19.00, 'Puzzle Paysage n°9', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.10, 5),
(37, '10+', 'Standard', 1, 20.00, 'Puzzle Paysage n°10', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 5.00, 5),
(38, '10+', 'Standard', 1, 21.00, 'Puzzle Paysage n°11', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.70, 5),
(39, '10+', 'Standard', 1, 22.00, 'Puzzle Paysage n°12', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.80, 5),
(40, '10+', 'Standard', 1, 23.00, 'Puzzle Paysage n°13', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.60, 5),
(41, '10+', 'Standard', 1, 24.00, 'Puzzle Paysage n°14', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.50, 5),
(42, '10+', 'Standard', 1, 25.00, 'Puzzle Paysage n°15', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.00, 5),
(43, '10+', 'Standard', 1, 26.00, 'Puzzle Paysage n°16', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.50, 5),
(44, '10+', 'Standard', 1, 27.00, 'Puzzle Paysage n°17', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.40, 5),
(45, '10+', 'Standard', 1, 28.00, 'Puzzle Paysage n°18', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.30, 5),
(46, '10+', 'Standard', 1, 29.00, 'Puzzle Paysage n°19', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.70, 5),
(47, '10+', 'Standard', 1, 30.00, 'Puzzle Paysage n°20', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.30, 5),
(48, '10+', 'Standard', 1, 31.00, 'Puzzle Paysage n°21', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.30, 5),
(49, '10+', 'Standard', 1, 32.00, 'Puzzle Paysage n°22', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.90, 5),
(50, '10+', 'Standard', 1, 33.00, 'Puzzle Paysage n°23', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.30, 5),
(51, '10+', 'Standard', 1, 34.00, 'Puzzle Paysage n°24', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.00, 5),
(52, '10+', 'Standard', 1, 35.00, 'Puzzle Paysage n°25', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.20, 5),
(53, '10+', 'Standard', 1, 36.00, 'Puzzle Paysage n°26', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 5.00, 5),
(54, '10+', 'Standard', 1, 37.00, 'Puzzle Paysage n°27', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.20, 5),
(55, '10+', 'Standard', 1, 38.00, 'Puzzle Paysage n°28', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.90, 5),
(56, '10+', 'Standard', 1, 39.00, 'Puzzle Paysage n°29', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.10, 5),
(57, '10+', 'Standard', 1, 40.00, 'Puzzle Paysage n°30', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.60, 5),
(58, '10+', 'Standard', 1, 41.00, 'Puzzle Paysage n°31', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.70, 5),
(59, '10+', 'Standard', 1, 42.00, 'Puzzle Paysage n°32', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.60, 5),
(60, '10+', 'Standard', 1, 43.00, 'Puzzle Paysage n°33', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.90, 5),
(61, '10+', 'Standard', 1, 44.00, 'Puzzle Paysage n°34', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.00, 5),
(62, '10+', 'Standard', 1, 45.00, 'Puzzle Paysage n°35', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.00, 5),
(63, '10+', 'Standard', 1, 46.00, 'Puzzle Paysage n°36', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.20, 5),
(64, '10+', 'Standard', 1, 47.00, 'Puzzle Paysage n°37', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.80, 5),
(65, '10+', 'Standard', 1, 48.00, 'Puzzle Paysage n°38', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.40, 5),
(66, '10+', 'Standard', 1, 49.00, 'Puzzle Paysage n°39', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.50, 5),
(67, '10+', 'Standard', 1, 50.00, 'Puzzle Paysage n°40', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.40, 5),
(68, '10+', 'Standard', 1, 51.00, 'Puzzle Paysage n°41', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.40, 5),
(69, '10+', 'Standard', 1, 52.00, 'Puzzle Paysage n°42', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.00, 5),
(70, '10+', 'Standard', 1, 53.00, 'Puzzle Paysage n°43', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.90, 5),
(71, '10+', 'Standard', 1, 54.00, 'Puzzle Paysage n°44', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.40, 5),
(72, '10+', 'Standard', 1, 55.00, 'Puzzle Paysage n°45', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.10, 5),
(73, '10+', 'Standard', 1, 56.00, 'Puzzle Paysage n°46', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.40, 5),
(74, '10+', 'Standard', 1, 57.00, 'Puzzle Paysage n°47', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.60, 5),
(75, '10+', 'Standard', 1, 58.00, 'Puzzle Paysage n°48', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.00, 5),
(76, '10+', 'Standard', 1, 59.00, 'Puzzle Paysage n°49', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.30, 5),
(77, '10+', 'Standard', 1, 60.00, 'Puzzle Paysage n°50', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.50, 5),
(78, '10+', 'Standard', 1, 61.00, 'Puzzle Paysage n°51', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.50, 5),
(79, '10+', 'Standard', 1, 62.00, 'Puzzle Paysage n°52', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.90, 5),
(80, '10+', 'Standard', 1, 63.00, 'Puzzle Paysage n°53', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.20, 5),
(81, '10+', 'Standard', 1, 64.00, 'Puzzle Paysage n°54', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.40, 5),
(82, '10+', 'Standard', 1, 65.00, 'Puzzle Paysage n°55', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.20, 5),
(83, '10+', 'Standard', 1, 66.00, 'Puzzle Paysage n°56', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.90, 5),
(84, '10+', 'Standard', 1, 67.00, 'Puzzle Paysage n°57', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.00, 5),
(85, '10+', 'Standard', 1, 68.00, 'Puzzle Paysage n°58', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.00, 5),
(86, '10+', 'Standard', 1, 69.00, 'Puzzle Paysage n°59', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.10, 5),
(87, '10+', 'Standard', 1, 70.00, 'Puzzle Paysage n°60', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.60, 5),
(88, '10+', 'Standard', 1, 71.00, 'Puzzle Paysage n°61', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.80, 5),
(89, '10+', 'Standard', 1, 72.00, 'Puzzle Paysage n°62', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.00, 5),
(90, '10+', 'Standard', 1, 73.00, 'Puzzle Paysage n°63', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.80, 5),
(91, '10+', 'Standard', 1, 74.00, 'Puzzle Paysage n°64', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.80, 5),
(92, '10+', 'Standard', 1, 75.00, 'Puzzle Paysage n°65', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.60, 5),
(93, '10+', 'Standard', 1, 76.00, 'Puzzle Paysage n°66', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.50, 5),
(94, '10+', 'Standard', 1, 77.00, 'Puzzle Paysage n°67', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 5.00, 5),
(95, '10+', 'Standard', 1, 78.00, 'Puzzle Paysage n°68', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.30, 5),
(96, '10+', 'Standard', 1, 79.00, 'Puzzle Paysage n°69', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.60, 5),
(97, '10+', 'Standard', 1, 80.00, 'Puzzle Paysage n°70', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.20, 5),
(98, '10+', 'Standard', 1, 81.00, 'Puzzle Paysage n°71', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.30, 5),
(99, '10+', 'Standard', 1, 82.00, 'Puzzle Paysage n°72', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.60, 5),
(100, '10+', 'Standard', 1, 83.00, 'Puzzle Paysage n°73', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.10, 5),
(101, '10+', 'Standard', 1, 84.00, 'Puzzle Paysage n°74', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.00, 5),
(102, '10+', 'Standard', 1, 85.00, 'Puzzle Paysage n°75', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.40, 5),
(103, '10+', 'Standard', 1, 86.00, 'Puzzle Paysage n°76', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.20, 5),
(104, '10+', 'Standard', 1, 87.00, 'Puzzle Paysage n°77', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.80, 5),
(105, '10+', 'Standard', 1, 88.00, 'Puzzle Paysage n°78', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.30, 5),
(106, '10+', 'Standard', 1, 89.00, 'Puzzle Paysage n°79', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.30, 5),
(107, '10+', 'Standard', 1, 90.00, 'Puzzle Paysage n°80', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.50, 5),
(108, '10+', 'Standard', 4, 39.99, 'Catan', 'Le jeu de stratégie et de commerce incontournable. Colonisez l île !', 4.70, 4),
(109, '8+', 'Standard', 6, 29.90, 'Dixit', 'Un jeu de déduction et d imagination avec des cartes magnifiquement illustrées.', 4.50, 2),
(110, '6+', 'Mini', 8, 14.99, 'Dobble', 'Le jeu d observation et de rapidité qui rend fou !', 4.60, 2),
(111, '6+', 'L', 12, 19.90, 'Mölkky', 'Le jeu de quilles finlandais. Idéal pour l extérieur.', 4.80, 3),
(112, '7+', 'Mini', 10, 18.50, 'Jungle Speed', 'Attrapez le totem le premier ! Attention aux signes trompeurs.', 4.40, 2),
(113, '8+', 'XXL', 5, 42.00, 'Les Aventuriers du Rail', 'Construisez vos lignes de chemin de fer à travers l Europe.', 4.90, 4),
(114, '8+', 'Standard', 6, 24.99, 'Cluedo', 'Qui a tué le Docteur Lenoir ? Menez l enquête.', 4.20, 2),
(115, '6+', 'Standard', 4, 22.00, 'Docteur Maboul', 'Opérez le patient sans trembler sinon ça sonne !', 4.00, 5),
(116, '3+', 'L', 1, 49.99, 'Kapla Baril 200', 'Jeu de construction en pin des Landes. Créativité illimitée.', 5.00, 5),
(117, '8+', 'M', 10, 29.99, 'Nerf Elite 2.0', 'Blaster avec fléchettes en mousse pour des batailles épiques.', 4.50, 3),
(118, '8+', 'Mini', 1, 12.99, 'Rubik s Cube', 'Le casse-tête le plus célèbre du monde.', 4.30, 4),
(119, '10+', 'Mini', 18, 11.90, 'Loup Garou', 'Jeu d ambiance et de bluff. Démasquez les loups parmi les villageois.', 4.60, 2),
(120, '10+', 'Standard', 7, 45.00, '7 Wonders', 'Prenez la tête de l une des sept grandes cités du monde antique.', 4.80, 4),
(121, '12+', 'Standard', 8, 19.50, 'Code Names', 'Jeu d association d idées et de déduction en équipe.', 4.70, 2),
(122, '10+', 'Standard', 6, 28.90, 'Unlock!', 'Un Escape Game inspiré dans une simple boîte de cartes.', 4.40, 4),
(123, '2+', 'M', 1, 15.00, 'Pâte à Modeler Play-Doh', 'Assortiment de 8 pots de couleurs pour créer à l infini.', 4.50, 5),
(124, '6+', 'M', 6, 17.99, 'Jenga', 'Retirez les blocs de bois sans faire tomber la tour !', 4.30, 2),
(125, '6+', 'XXL', 4, 19.99, 'Twister', 'Pied droit sur rouge ! Le jeu qui vous tord de rire.', 4.20, 2),
(126, '5+', 'L', 1, 12.00, 'Cerf-Volant Aigle', 'Cerf-volant géant facile à faire voler.', 4.10, 3),
(127, '6+', 'L', 4, 25.00, 'Set de Badminton', '4 raquettes et volant pour jouer dans le jardin.', 4.00, 3),
(128, '10+', 'Standard', 1, 11.00, 'Puzzle Paysage n°1', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.40, 5),
(129, '10+', 'Standard', 1, 12.00, 'Puzzle Paysage n°2', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.00, 5),
(130, '10+', 'Standard', 1, 13.00, 'Puzzle Paysage n°3', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.70, 5),
(131, '10+', 'Standard', 1, 14.00, 'Puzzle Paysage n°4', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.70, 5),
(132, '10+', 'Standard', 1, 15.00, 'Puzzle Paysage n°5', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.20, 5),
(133, '10+', 'Standard', 1, 16.00, 'Puzzle Paysage n°6', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.10, 5),
(134, '10+', 'Standard', 1, 17.00, 'Puzzle Paysage n°7', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.80, 5),
(135, '10+', 'Standard', 1, 18.00, 'Puzzle Paysage n°8', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.80, 5),
(136, '10+', 'Standard', 1, 19.00, 'Puzzle Paysage n°9', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.70, 5),
(137, '10+', 'Standard', 1, 20.00, 'Puzzle Paysage n°10', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 5.00, 5),
(138, '10+', 'Standard', 1, 21.00, 'Puzzle Paysage n°11', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.90, 5),
(139, '10+', 'Standard', 1, 22.00, 'Puzzle Paysage n°12', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.30, 5),
(140, '10+', 'Standard', 1, 23.00, 'Puzzle Paysage n°13', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.10, 5),
(141, '10+', 'Standard', 1, 24.00, 'Puzzle Paysage n°14', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.40, 5),
(142, '10+', 'Standard', 1, 25.00, 'Puzzle Paysage n°15', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.80, 5),
(143, '10+', 'Standard', 1, 26.00, 'Puzzle Paysage n°16', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.00, 5),
(144, '10+', 'Standard', 1, 27.00, 'Puzzle Paysage n°17', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.20, 5),
(145, '10+', 'Standard', 1, 28.00, 'Puzzle Paysage n°18', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.30, 5),
(146, '10+', 'Standard', 1, 29.00, 'Puzzle Paysage n°19', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.90, 5),
(147, '10+', 'Standard', 1, 30.00, 'Puzzle Paysage n°20', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.50, 5),
(148, '10+', 'Standard', 1, 31.00, 'Puzzle Paysage n°21', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.90, 5),
(149, '10+', 'Standard', 1, 32.00, 'Puzzle Paysage n°22', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.90, 5),
(150, '10+', 'Standard', 1, 33.00, 'Puzzle Paysage n°23', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.90, 5),
(151, '10+', 'Standard', 1, 34.00, 'Puzzle Paysage n°24', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.60, 5),
(152, '10+', 'Standard', 1, 35.00, 'Puzzle Paysage n°25', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.40, 5),
(153, '10+', 'Standard', 1, 36.00, 'Puzzle Paysage n°26', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.00, 5),
(154, '10+', 'Standard', 1, 37.00, 'Puzzle Paysage n°27', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.10, 5),
(155, '10+', 'Standard', 1, 38.00, 'Puzzle Paysage n°28', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.20, 5),
(156, '10+', 'Standard', 1, 39.00, 'Puzzle Paysage n°29', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.00, 5),
(157, '10+', 'Standard', 1, 40.00, 'Puzzle Paysage n°30', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.50, 5),
(158, '10+', 'Standard', 1, 41.00, 'Puzzle Paysage n°31', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.30, 5),
(159, '10+', 'Standard', 1, 42.00, 'Puzzle Paysage n°32', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.80, 5),
(160, '10+', 'Standard', 1, 43.00, 'Puzzle Paysage n°33', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.50, 5),
(161, '10+', 'Standard', 1, 44.00, 'Puzzle Paysage n°34', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.80, 5),
(162, '10+', 'Standard', 1, 45.00, 'Puzzle Paysage n°35', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.50, 5),
(163, '10+', 'Standard', 1, 46.00, 'Puzzle Paysage n°36', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.10, 5),
(164, '10+', 'Standard', 1, 47.00, 'Puzzle Paysage n°37', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.10, 5),
(165, '10+', 'Standard', 1, 48.00, 'Puzzle Paysage n°38', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.20, 5),
(166, '10+', 'Standard', 1, 49.00, 'Puzzle Paysage n°39', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.50, 5),
(167, '10+', 'Standard', 1, 50.00, 'Puzzle Paysage n°40', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.20, 5),
(168, '10+', 'Standard', 1, 51.00, 'Puzzle Paysage n°41', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.30, 5),
(169, '10+', 'Standard', 1, 52.00, 'Puzzle Paysage n°42', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.80, 5),
(170, '10+', 'Standard', 1, 53.00, 'Puzzle Paysage n°43', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.30, 5),
(171, '10+', 'Standard', 1, 54.00, 'Puzzle Paysage n°44', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 5.00, 5),
(172, '10+', 'Standard', 1, 55.00, 'Puzzle Paysage n°45', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.00, 5),
(173, '10+', 'Standard', 1, 56.00, 'Puzzle Paysage n°46', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.00, 5),
(174, '10+', 'Standard', 1, 57.00, 'Puzzle Paysage n°47', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.10, 5),
(175, '10+', 'Standard', 1, 58.00, 'Puzzle Paysage n°48', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.50, 5),
(176, '10+', 'Standard', 1, 59.00, 'Puzzle Paysage n°49', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.30, 5),
(177, '10+', 'Standard', 1, 60.00, 'Puzzle Paysage n°50', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.70, 5),
(178, '10+', 'Standard', 1, 61.00, 'Puzzle Paysage n°51', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.90, 5),
(179, '10+', 'Standard', 1, 62.00, 'Puzzle Paysage n°52', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.30, 5),
(180, '10+', 'Standard', 1, 63.00, 'Puzzle Paysage n°53', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.90, 5),
(181, '10+', 'Standard', 1, 64.00, 'Puzzle Paysage n°54', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.70, 5),
(182, '10+', 'Standard', 1, 65.00, 'Puzzle Paysage n°55', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.60, 5),
(183, '10+', 'Standard', 1, 66.00, 'Puzzle Paysage n°56', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.10, 5),
(184, '10+', 'Standard', 1, 67.00, 'Puzzle Paysage n°57', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.80, 5),
(185, '10+', 'Standard', 1, 68.00, 'Puzzle Paysage n°58', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.60, 5),
(186, '10+', 'Standard', 1, 69.00, 'Puzzle Paysage n°59', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.50, 5),
(187, '10+', 'Standard', 1, 70.00, 'Puzzle Paysage n°60', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.90, 5),
(188, '10+', 'Standard', 1, 71.00, 'Puzzle Paysage n°61', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.70, 5),
(189, '10+', 'Standard', 1, 72.00, 'Puzzle Paysage n°62', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 5.00, 5),
(190, '10+', 'Standard', 1, 73.00, 'Puzzle Paysage n°63', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.80, 5),
(191, '10+', 'Standard', 1, 74.00, 'Puzzle Paysage n°64', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.90, 5),
(192, '10+', 'Standard', 1, 75.00, 'Puzzle Paysage n°65', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.20, 5),
(193, '10+', 'Standard', 1, 76.00, 'Puzzle Paysage n°66', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.40, 5),
(194, '10+', 'Standard', 1, 77.00, 'Puzzle Paysage n°67', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.10, 5),
(195, '10+', 'Standard', 1, 78.00, 'Puzzle Paysage n°68', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.60, 5),
(196, '10+', 'Standard', 1, 79.00, 'Puzzle Paysage n°69', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.80, 5),
(197, '10+', 'Standard', 1, 80.00, 'Puzzle Paysage n°70', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.10, 5),
(198, '10+', 'Standard', 1, 81.00, 'Puzzle Paysage n°71', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.20, 5),
(199, '10+', 'Standard', 1, 82.00, 'Puzzle Paysage n°72', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.40, 5),
(200, '10+', 'Standard', 1, 83.00, 'Puzzle Paysage n°73', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.70, 5),
(201, '10+', 'Standard', 1, 84.00, 'Puzzle Paysage n°74', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.30, 5),
(202, '10+', 'Standard', 1, 85.00, 'Puzzle Paysage n°75', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.30, 5),
(203, '10+', 'Standard', 1, 86.00, 'Puzzle Paysage n°76', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.70, 5),
(204, '10+', 'Standard', 1, 87.00, 'Puzzle Paysage n°77', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.70, 5),
(205, '10+', 'Standard', 1, 88.00, 'Puzzle Paysage n°78', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.30, 5),
(206, '10+', 'Standard', 1, 89.00, 'Puzzle Paysage n°79', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.30, 5),
(207, '10+', 'Standard', 1, 90.00, 'Puzzle Paysage n°80', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.60, 5),
(208, '10+', 'Standard', 4, 39.99, 'Catan', 'Le jeu de stratégie et de commerce incontournable. Colonisez l île !', 4.70, 4),
(209, '8+', 'Standard', 6, 29.90, 'Dixit', 'Un jeu de déduction et d imagination avec des cartes magnifiquement illustrées.', 4.50, 2),
(210, '6+', 'Mini', 8, 14.99, 'Dobble', 'Le jeu d observation et de rapidité qui rend fou !', 4.60, 2),
(211, '6+', 'L', 12, 19.90, 'Mölkky', 'Le jeu de quilles finlandais. Idéal pour l extérieur.', 4.80, 3),
(212, '7+', 'Mini', 10, 18.50, 'Jungle Speed', 'Attrapez le totem le premier ! Attention aux signes trompeurs.', 4.40, 2),
(213, '8+', 'XXL', 5, 42.00, 'Les Aventuriers du Rail', 'Construisez vos lignes de chemin de fer à travers l Europe.', 4.90, 4),
(214, '8+', 'Standard', 6, 24.99, 'Cluedo', 'Qui a tué le Docteur Lenoir ? Menez l enquête.', 4.20, 2),
(215, '6+', 'Standard', 4, 22.00, 'Docteur Maboul', 'Opérez le patient sans trembler sinon ça sonne !', 4.00, 5),
(216, '3+', 'L', 1, 49.99, 'Kapla Baril 200', 'Jeu de construction en pin des Landes. Créativité illimitée.', 5.00, 5),
(217, '8+', 'M', 10, 29.99, 'Nerf Elite 2.0', 'Blaster avec fléchettes en mousse pour des batailles épiques.', 4.50, 3),
(218, '8+', 'Mini', 1, 12.99, 'Rubik s Cube', 'Le casse-tête le plus célèbre du monde.', 4.30, 4),
(219, '10+', 'Mini', 18, 11.90, 'Loup Garou', 'Jeu d ambiance et de bluff. Démasquez les loups parmi les villageois.', 4.60, 2),
(220, '10+', 'Standard', 7, 45.00, '7 Wonders', 'Prenez la tête de l une des sept grandes cités du monde antique.', 4.80, 4),
(221, '12+', 'Standard', 8, 19.50, 'Code Names', 'Jeu d association d idées et de déduction en équipe.', 4.70, 2),
(222, '10+', 'Standard', 6, 28.90, 'Unlock!', 'Un Escape Game inspiré dans une simple boîte de cartes.', 4.40, 4),
(223, '2+', 'M', 1, 15.00, 'Pâte à Modeler Play-Doh', 'Assortiment de 8 pots de couleurs pour créer à l infini.', 4.50, 5),
(224, '6+', 'M', 6, 17.99, 'Jenga', 'Retirez les blocs de bois sans faire tomber la tour !', 4.30, 2),
(225, '6+', 'XXL', 4, 19.99, 'Twister', 'Pied droit sur rouge ! Le jeu qui vous tord de rire.', 4.20, 2),
(226, '5+', 'L', 1, 12.00, 'Cerf-Volant Aigle', 'Cerf-volant géant facile à faire voler.', 4.10, 3),
(227, '6+', 'L', 4, 25.00, 'Set de Badminton', '4 raquettes et volant pour jouer dans le jardin.', 4.00, 3),
(228, '10+', 'Standard', 1, 11.00, 'Puzzle Paysage n°1', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.50, 5),
(229, '10+', 'Standard', 1, 12.00, 'Puzzle Paysage n°2', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.30, 5),
(230, '10+', 'Standard', 1, 13.00, 'Puzzle Paysage n°3', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.90, 5),
(231, '10+', 'Standard', 1, 14.00, 'Puzzle Paysage n°4', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.70, 5),
(232, '10+', 'Standard', 1, 15.00, 'Puzzle Paysage n°5', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.80, 5),
(233, '10+', 'Standard', 1, 16.00, 'Puzzle Paysage n°6', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.70, 5),
(234, '10+', 'Standard', 1, 17.00, 'Puzzle Paysage n°7', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.30, 5),
(235, '10+', 'Standard', 1, 18.00, 'Puzzle Paysage n°8', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.30, 5),
(236, '10+', 'Standard', 1, 19.00, 'Puzzle Paysage n°9', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.70, 5),
(237, '10+', 'Standard', 1, 20.00, 'Puzzle Paysage n°10', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.40, 5),
(238, '10+', 'Standard', 1, 21.00, 'Puzzle Paysage n°11', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.90, 5),
(239, '10+', 'Standard', 1, 22.00, 'Puzzle Paysage n°12', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.20, 5),
(240, '10+', 'Standard', 1, 23.00, 'Puzzle Paysage n°13', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.50, 5),
(241, '10+', 'Standard', 1, 24.00, 'Puzzle Paysage n°14', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.60, 5),
(242, '10+', 'Standard', 1, 25.00, 'Puzzle Paysage n°15', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.80, 5),
(243, '10+', 'Standard', 1, 26.00, 'Puzzle Paysage n°16', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.20, 5),
(244, '10+', 'Standard', 1, 27.00, 'Puzzle Paysage n°17', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.40, 5),
(245, '10+', 'Standard', 1, 28.00, 'Puzzle Paysage n°18', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.30, 5),
(246, '10+', 'Standard', 1, 29.00, 'Puzzle Paysage n°19', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.40, 5),
(247, '10+', 'Standard', 1, 30.00, 'Puzzle Paysage n°20', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.90, 5),
(248, '10+', 'Standard', 1, 31.00, 'Puzzle Paysage n°21', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.60, 5),
(249, '10+', 'Standard', 1, 32.00, 'Puzzle Paysage n°22', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.10, 5),
(250, '10+', 'Standard', 1, 33.00, 'Puzzle Paysage n°23', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.80, 5),
(251, '10+', 'Standard', 1, 34.00, 'Puzzle Paysage n°24', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.60, 5),
(252, '10+', 'Standard', 1, 35.00, 'Puzzle Paysage n°25', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.60, 5),
(253, '10+', 'Standard', 1, 36.00, 'Puzzle Paysage n°26', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.20, 5),
(254, '10+', 'Standard', 1, 37.00, 'Puzzle Paysage n°27', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.10, 5),
(255, '10+', 'Standard', 1, 38.00, 'Puzzle Paysage n°28', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.20, 5),
(256, '10+', 'Standard', 1, 39.00, 'Puzzle Paysage n°29', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.40, 5),
(257, '10+', 'Standard', 1, 40.00, 'Puzzle Paysage n°30', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.50, 5),
(258, '10+', 'Standard', 1, 41.00, 'Puzzle Paysage n°31', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.10, 5),
(259, '10+', 'Standard', 1, 42.00, 'Puzzle Paysage n°32', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.30, 5),
(260, '10+', 'Standard', 1, 43.00, 'Puzzle Paysage n°33', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 5.00, 5),
(261, '10+', 'Standard', 1, 44.00, 'Puzzle Paysage n°34', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.00, 5),
(262, '10+', 'Standard', 1, 45.00, 'Puzzle Paysage n°35', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.10, 5),
(263, '10+', 'Standard', 1, 46.00, 'Puzzle Paysage n°36', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.40, 5),
(264, '10+', 'Standard', 1, 47.00, 'Puzzle Paysage n°37', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.90, 5),
(265, '10+', 'Standard', 1, 48.00, 'Puzzle Paysage n°38', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.10, 5),
(266, '10+', 'Standard', 1, 49.00, 'Puzzle Paysage n°39', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.70, 5),
(267, '10+', 'Standard', 1, 50.00, 'Puzzle Paysage n°40', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.30, 5),
(268, '10+', 'Standard', 1, 51.00, 'Puzzle Paysage n°41', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.50, 5),
(269, '10+', 'Standard', 1, 52.00, 'Puzzle Paysage n°42', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.70, 5),
(270, '10+', 'Standard', 1, 53.00, 'Puzzle Paysage n°43', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.80, 5),
(271, '10+', 'Standard', 1, 54.00, 'Puzzle Paysage n°44', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 5.00, 5),
(272, '10+', 'Standard', 1, 55.00, 'Puzzle Paysage n°45', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.50, 5),
(273, '10+', 'Standard', 1, 56.00, 'Puzzle Paysage n°46', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.40, 5),
(274, '10+', 'Standard', 1, 57.00, 'Puzzle Paysage n°47', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.70, 5),
(275, '10+', 'Standard', 1, 58.00, 'Puzzle Paysage n°48', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.30, 5),
(276, '10+', 'Standard', 1, 59.00, 'Puzzle Paysage n°49', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.30, 5),
(277, '10+', 'Standard', 1, 60.00, 'Puzzle Paysage n°50', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.50, 5),
(278, '10+', 'Standard', 1, 61.00, 'Puzzle Paysage n°51', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.80, 5),
(279, '10+', 'Standard', 1, 62.00, 'Puzzle Paysage n°52', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.60, 5),
(280, '10+', 'Standard', 1, 63.00, 'Puzzle Paysage n°53', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.40, 5),
(281, '10+', 'Standard', 1, 64.00, 'Puzzle Paysage n°54', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.10, 5),
(282, '10+', 'Standard', 1, 65.00, 'Puzzle Paysage n°55', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.50, 5),
(283, '10+', 'Standard', 1, 66.00, 'Puzzle Paysage n°56', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.30, 5),
(284, '10+', 'Standard', 1, 67.00, 'Puzzle Paysage n°57', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.80, 5),
(285, '10+', 'Standard', 1, 68.00, 'Puzzle Paysage n°58', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.00, 5),
(286, '10+', 'Standard', 1, 69.00, 'Puzzle Paysage n°59', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.80, 5),
(287, '10+', 'Standard', 1, 70.00, 'Puzzle Paysage n°60', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.10, 5),
(288, '10+', 'Standard', 1, 71.00, 'Puzzle Paysage n°61', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.00, 5),
(289, '10+', 'Standard', 1, 72.00, 'Puzzle Paysage n°62', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.80, 5),
(290, '10+', 'Standard', 1, 73.00, 'Puzzle Paysage n°63', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.70, 5),
(291, '10+', 'Standard', 1, 74.00, 'Puzzle Paysage n°64', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.40, 5),
(292, '10+', 'Standard', 1, 75.00, 'Puzzle Paysage n°65', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.90, 5),
(293, '10+', 'Standard', 1, 76.00, 'Puzzle Paysage n°66', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.10, 5),
(294, '10+', 'Standard', 1, 77.00, 'Puzzle Paysage n°67', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.90, 5),
(295, '10+', 'Standard', 1, 78.00, 'Puzzle Paysage n°68', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.10, 5),
(296, '10+', 'Standard', 1, 79.00, 'Puzzle Paysage n°69', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.00, 5),
(297, '10+', 'Standard', 1, 80.00, 'Puzzle Paysage n°70', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.70, 5),
(298, '10+', 'Standard', 1, 81.00, 'Puzzle Paysage n°71', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.40, 5),
(299, '10+', 'Standard', 1, 82.00, 'Puzzle Paysage n°72', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.80, 5),
(300, '10+', 'Standard', 1, 83.00, 'Puzzle Paysage n°73', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.90, 5),
(301, '10+', 'Standard', 1, 84.00, 'Puzzle Paysage n°74', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.10, 5),
(302, '10+', 'Standard', 1, 85.00, 'Puzzle Paysage n°75', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.60, 5),
(303, '10+', 'Standard', 1, 86.00, 'Puzzle Paysage n°76', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 5.00, 5),
(304, '10+', 'Standard', 1, 87.00, 'Puzzle Paysage n°77', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.00, 5),
(305, '10+', 'Standard', 1, 88.00, 'Puzzle Paysage n°78', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.00, 5),
(306, '10+', 'Standard', 1, 89.00, 'Puzzle Paysage n°79', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 4.90, 5),
(307, '10+', 'Standard', 1, 90.00, 'Puzzle Paysage n°80', 'Un magnifique puzzle de 1000 pièces pour se détendre.', 3.70, 5);

-- --------------------------------------------------------

--
-- Structure de la table `produit_favoris`
--

CREATE TABLE `produit_favoris` (
  `idClient` int(11) NOT NULL,
  `idProduit` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `produit_regroupement`
--

CREATE TABLE `produit_regroupement` (
  `idProduit` int(11) NOT NULL,
  `idRegroupement` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `produit_regroupement`
--

INSERT INTO `produit_regroupement` (`idProduit`, `idRegroupement`) VALUES
(1, 2),
(2, 1),
(3, 2),
(4, 1),
(5, 4),
(6, 2),
(6, 3),
(7, 2),
(8, 1),
(9, 1);

-- --------------------------------------------------------

--
-- Structure de la table `regroupement`
--

CREATE TABLE `regroupement` (
  `idRegroupement` int(11) NOT NULL,
  `nomRegroupement` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `regroupement`
--

INSERT INTO `regroupement` (`idRegroupement`, `nomRegroupement`) VALUES
(1, 'Best seller'),
(2, 'a la une'),
(3, 'Nouveauté'),
(4, 'Promotion');

-- --------------------------------------------------------

--
-- Structure de la table `souscategorie`
--

CREATE TABLE `souscategorie` (
  `idCategorie` int(11) NOT NULL,
  `idSousCategorie` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `souscategorie`
--

INSERT INTO `souscategorie` (`idCategorie`, `idSousCategorie`) VALUES
(1, 2),
(1, 3),
(2, 4),
(2, 5);

-- --------------------------------------------------------

--
-- Structure de la table `stock`
--

CREATE TABLE `stock` (
  `numStock` int(11) NOT NULL,
  `quantiteStock` int(11) DEFAULT 0,
  `idProduit` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `stock`
--

INSERT INTO `stock` (`numStock`, `quantiteStock`, `idProduit`) VALUES
(6, 100, 1),
(7, 50, 2),
(8, 200, 3),
(9, 10, 4),
(10, 25, 5),
(11, 5, 6),
(12, 60, 7),
(13, 50, 9),
(14, 50, 10),
(15, 50, 12),
(16, 50, 14),
(17, 50, 19),
(18, 50, 21),
(19, 50, 24),
(20, 50, 25),
(21, 50, 11),
(22, 50, 17),
(23, 50, 26),
(24, 50, 27),
(25, 50, 8),
(26, 50, 13),
(27, 50, 18),
(28, 50, 20),
(29, 50, 22),
(30, 50, 15),
(31, 50, 16),
(32, 50, 23),
(33, 50, 28),
(34, 50, 29),
(35, 50, 30),
(36, 50, 31),
(37, 50, 32),
(38, 50, 33),
(39, 50, 34),
(40, 50, 35),
(41, 50, 36),
(42, 50, 37),
(43, 50, 38),
(44, 50, 39),
(45, 50, 40),
(46, 50, 41),
(47, 50, 42),
(48, 50, 43),
(49, 50, 44),
(50, 50, 45),
(51, 50, 46),
(52, 50, 47),
(53, 50, 48),
(54, 50, 49),
(55, 50, 50),
(56, 50, 51),
(57, 50, 52),
(58, 50, 53),
(59, 50, 54),
(60, 50, 55),
(61, 50, 56),
(62, 50, 57),
(63, 50, 58),
(64, 50, 59),
(65, 50, 60),
(66, 50, 61),
(67, 50, 62),
(68, 50, 63),
(69, 50, 64),
(70, 50, 65),
(71, 50, 66),
(72, 50, 67),
(73, 50, 68),
(74, 50, 69),
(75, 50, 70),
(76, 50, 71),
(77, 50, 72),
(78, 50, 73),
(79, 50, 74),
(80, 50, 75),
(81, 50, 76),
(82, 50, 77),
(83, 50, 78),
(84, 50, 79),
(85, 50, 80),
(86, 50, 81),
(87, 50, 82),
(88, 50, 83),
(89, 50, 84),
(90, 50, 85),
(91, 50, 86),
(92, 50, 87),
(93, 50, 88),
(94, 50, 89),
(95, 50, 90),
(96, 50, 91),
(97, 50, 92),
(98, 50, 93),
(99, 50, 94),
(100, 50, 95),
(101, 50, 96),
(102, 50, 97),
(103, 50, 98),
(104, 50, 99),
(105, 50, 100),
(106, 50, 101),
(107, 50, 102),
(108, 50, 103),
(109, 50, 104),
(110, 50, 105),
(111, 50, 106),
(112, 50, 107),
(140, 50, 109),
(141, 50, 110),
(142, 50, 112),
(143, 50, 114),
(144, 50, 119),
(145, 50, 121),
(146, 50, 124),
(147, 50, 125),
(148, 50, 111),
(149, 50, 117),
(150, 50, 126),
(151, 50, 127),
(152, 50, 108),
(153, 50, 113),
(154, 50, 118),
(155, 50, 120),
(156, 50, 122),
(157, 50, 115),
(158, 50, 116),
(159, 50, 123),
(160, 50, 128),
(161, 50, 129),
(162, 50, 130),
(163, 50, 131),
(164, 50, 132),
(165, 50, 133),
(166, 50, 134),
(167, 50, 135),
(168, 50, 136),
(169, 50, 137),
(170, 50, 138),
(171, 50, 139),
(172, 50, 140),
(173, 50, 141),
(174, 50, 142),
(175, 50, 143),
(176, 50, 144),
(177, 50, 145),
(178, 50, 146),
(179, 50, 147),
(180, 50, 148),
(181, 50, 149),
(182, 50, 150),
(183, 50, 151),
(184, 50, 152),
(185, 50, 153),
(186, 50, 154),
(187, 50, 155),
(188, 50, 156),
(189, 50, 157),
(190, 50, 158),
(191, 50, 159),
(192, 50, 160),
(193, 50, 161),
(194, 50, 162),
(195, 50, 163),
(196, 50, 164),
(197, 50, 165),
(198, 50, 166),
(199, 50, 167),
(200, 50, 168),
(201, 50, 169),
(202, 50, 170),
(203, 50, 171),
(204, 50, 172),
(205, 50, 173),
(206, 50, 174),
(207, 50, 175),
(208, 50, 176),
(209, 50, 177),
(210, 50, 178),
(211, 50, 179),
(212, 50, 180),
(213, 50, 181),
(214, 50, 182),
(215, 50, 183),
(216, 50, 184),
(217, 50, 185),
(218, 50, 186),
(219, 50, 187),
(220, 50, 188),
(221, 50, 189),
(222, 50, 190),
(223, 50, 191),
(224, 50, 192),
(225, 50, 193),
(226, 50, 194),
(227, 50, 195),
(228, 50, 196),
(229, 50, 197),
(230, 50, 198),
(231, 50, 199),
(232, 50, 200),
(233, 50, 201),
(234, 50, 202),
(235, 50, 203),
(236, 50, 204),
(237, 50, 205),
(238, 50, 206),
(239, 50, 207),
(267, 50, 209),
(268, 50, 210),
(269, 50, 212),
(270, 50, 214),
(271, 50, 219),
(272, 50, 221),
(273, 50, 224),
(274, 50, 225),
(275, 50, 211),
(276, 50, 217),
(277, 50, 226),
(278, 50, 227),
(279, 50, 208),
(280, 50, 213),
(281, 50, 218),
(282, 50, 220),
(283, 50, 222),
(284, 50, 215),
(285, 50, 216),
(286, 50, 223),
(287, 50, 228),
(288, 50, 229),
(289, 50, 230),
(290, 50, 231),
(291, 50, 232),
(292, 50, 233),
(293, 50, 234),
(294, 50, 235),
(295, 50, 236),
(296, 50, 237),
(297, 50, 238),
(298, 50, 239),
(299, 50, 240),
(300, 50, 241),
(301, 50, 242),
(302, 50, 243),
(303, 50, 244),
(304, 50, 245),
(305, 50, 246),
(306, 50, 247),
(307, 50, 248),
(308, 50, 249),
(309, 50, 250),
(310, 50, 251),
(311, 50, 252),
(312, 50, 253),
(313, 50, 254),
(314, 50, 255),
(315, 50, 256),
(316, 50, 257),
(317, 50, 258),
(318, 50, 259),
(319, 50, 260),
(320, 50, 261),
(321, 50, 262),
(322, 50, 263),
(323, 50, 264),
(324, 50, 265),
(325, 50, 266),
(326, 50, 267),
(327, 50, 268),
(328, 50, 269),
(329, 50, 270),
(330, 50, 271),
(331, 50, 272),
(332, 50, 273),
(333, 50, 274),
(334, 50, 275),
(335, 50, 276),
(336, 50, 277),
(337, 50, 278),
(338, 50, 279),
(339, 50, 280),
(340, 50, 281),
(341, 50, 282),
(342, 50, 283),
(343, 50, 284),
(344, 50, 285),
(345, 50, 286),
(346, 50, 287),
(347, 50, 288),
(348, 50, 289),
(349, 50, 290),
(350, 50, 291),
(351, 50, 292),
(352, 50, 293),
(353, 50, 294),
(354, 50, 295),
(355, 50, 296),
(356, 50, 297),
(357, 50, 298),
(358, 50, 299),
(359, 50, 300),
(360, 50, 301),
(361, 50, 302),
(362, 50, 303),
(363, 50, 304),
(364, 50, 305),
(365, 50, 306),
(366, 50, 307);

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `adresse`
--
ALTER TABLE `adresse`
  ADD PRIMARY KEY (`idAdresse`);

--
-- Index pour la table `avis`
--
ALTER TABLE `avis`
  ADD PRIMARY KEY (`idClient`,`idProduit`),
  ADD KEY `fk_avis_produit` (`idProduit`);

--
-- Index pour la table `cartebancaire`
--
ALTER TABLE `cartebancaire`
  ADD PRIMARY KEY (`numCarte`),
  ADD KEY `fk_cb_client` (`idClient`),
  ADD KEY `fk_cb_adresse` (`idAdresse`);

--
-- Index pour la table `categorie`
--
ALTER TABLE `categorie`
  ADD PRIMARY KEY (`idCategorie`);

--
-- Index pour la table `client`
--
ALTER TABLE `client`
  ADD PRIMARY KEY (`idClient`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `fk_client_adresse` (`idAdresse`);

--
-- Index pour la table `codepromotion`
--
ALTER TABLE `codepromotion`
  ADD PRIMARY KEY (`idPromo`),
  ADD KEY `fk_promo_client_perso` (`idClient`);

--
-- Index pour la table `commande`
--
ALTER TABLE `commande`
  ADD PRIMARY KEY (`idCommande`),
  ADD KEY `fk_commande_client` (`idClient`),
  ADD KEY `fk_commande_adresse` (`idAdresse`);

--
-- Index pour la table `composer`
--
ALTER TABLE `composer`
  ADD PRIMARY KEY (`idCommande`,`idProduit`),
  ADD KEY `fk_composer_produit` (`idProduit`);

--
-- Index pour la table `panier_client`
--
ALTER TABLE `panier_client`
  ADD PRIMARY KEY (`idClient`,`idProduit`),
  ADD KEY `fk_panier_produit` (`idProduit`);

--
-- Index pour la table `panier_client_promo`
--
ALTER TABLE `panier_client_promo`
  ADD PRIMARY KEY (`idClient`,`idPromo`),
  ADD KEY `fk_pcp_promo` (`idPromo`);

--
-- Index pour la table `produit`
--
ALTER TABLE `produit`
  ADD PRIMARY KEY (`idProduit`),
  ADD KEY `fk_produit_categorie` (`idCategorie`);

--
-- Index pour la table `produit_favoris`
--
ALTER TABLE `produit_favoris`
  ADD PRIMARY KEY (`idClient`,`idProduit`),
  ADD KEY `fk_favoris_produit` (`idProduit`);

--
-- Index pour la table `produit_regroupement`
--
ALTER TABLE `produit_regroupement`
  ADD PRIMARY KEY (`idProduit`,`idRegroupement`),
  ADD KEY `fk_pr_reg` (`idRegroupement`);

--
-- Index pour la table `regroupement`
--
ALTER TABLE `regroupement`
  ADD PRIMARY KEY (`idRegroupement`);

--
-- Index pour la table `souscategorie`
--
ALTER TABLE `souscategorie`
  ADD PRIMARY KEY (`idCategorie`,`idSousCategorie`),
  ADD KEY `fk_sc_enfant` (`idSousCategorie`);

--
-- Index pour la table `stock`
--
ALTER TABLE `stock`
  ADD PRIMARY KEY (`numStock`),
  ADD KEY `fk_stock_produit` (`idProduit`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `adresse`
--
ALTER TABLE `adresse`
  MODIFY `idAdresse` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT pour la table `categorie`
--
ALTER TABLE `categorie`
  MODIFY `idCategorie` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT pour la table `client`
--
ALTER TABLE `client`
  MODIFY `idClient` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT pour la table `codepromotion`
--
ALTER TABLE `codepromotion`
  MODIFY `idPromo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT pour la table `commande`
--
ALTER TABLE `commande`
  MODIFY `idCommande` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT pour la table `produit`
--
ALTER TABLE `produit`
  MODIFY `idProduit` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=308;

--
-- AUTO_INCREMENT pour la table `regroupement`
--
ALTER TABLE `regroupement`
  MODIFY `idRegroupement` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT pour la table `stock`
--
ALTER TABLE `stock`
  MODIFY `numStock` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=394;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `avis`
--
ALTER TABLE `avis`
  ADD CONSTRAINT `fk_avis_client` FOREIGN KEY (`idClient`) REFERENCES `client` (`idClient`),
  ADD CONSTRAINT `fk_avis_produit` FOREIGN KEY (`idProduit`) REFERENCES `produit` (`idProduit`);

--
-- Contraintes pour la table `cartebancaire`
--
ALTER TABLE `cartebancaire`
  ADD CONSTRAINT `fk_cb_adresse` FOREIGN KEY (`idAdresse`) REFERENCES `adresse` (`idAdresse`),
  ADD CONSTRAINT `fk_cb_client` FOREIGN KEY (`idClient`) REFERENCES `client` (`idClient`);

--
-- Contraintes pour la table `client`
--
ALTER TABLE `client`
  ADD CONSTRAINT `fk_client_adresse` FOREIGN KEY (`idAdresse`) REFERENCES `adresse` (`idAdresse`);

--
-- Contraintes pour la table `codepromotion`
--
ALTER TABLE `codepromotion`
  ADD CONSTRAINT `fk_promo_client_perso` FOREIGN KEY (`idClient`) REFERENCES `client` (`idClient`);

--
-- Contraintes pour la table `commande`
--
ALTER TABLE `commande`
  ADD CONSTRAINT `fk_commande_adresse` FOREIGN KEY (`idAdresse`) REFERENCES `adresse` (`idAdresse`),
  ADD CONSTRAINT `fk_commande_client` FOREIGN KEY (`idClient`) REFERENCES `client` (`idClient`);

--
-- Contraintes pour la table `composer`
--
ALTER TABLE `composer`
  ADD CONSTRAINT `fk_composer_commande` FOREIGN KEY (`idCommande`) REFERENCES `commande` (`idCommande`),
  ADD CONSTRAINT `fk_composer_produit` FOREIGN KEY (`idProduit`) REFERENCES `produit` (`idProduit`);

--
-- Contraintes pour la table `panier_client`
--
ALTER TABLE `panier_client`
  ADD CONSTRAINT `fk_panier_client` FOREIGN KEY (`idClient`) REFERENCES `client` (`idClient`),
  ADD CONSTRAINT `fk_panier_produit` FOREIGN KEY (`idProduit`) REFERENCES `produit` (`idProduit`);

--
-- Contraintes pour la table `panier_client_promo`
--
ALTER TABLE `panier_client_promo`
  ADD CONSTRAINT `fk_pcp_client` FOREIGN KEY (`idClient`) REFERENCES `client` (`idClient`),
  ADD CONSTRAINT `fk_pcp_promo` FOREIGN KEY (`idPromo`) REFERENCES `codepromotion` (`idPromo`);

--
-- Contraintes pour la table `produit`
--
ALTER TABLE `produit`
  ADD CONSTRAINT `fk_produit_categorie` FOREIGN KEY (`idCategorie`) REFERENCES `categorie` (`idCategorie`);

--
-- Contraintes pour la table `produit_favoris`
--
ALTER TABLE `produit_favoris`
  ADD CONSTRAINT `fk_favoris_client` FOREIGN KEY (`idClient`) REFERENCES `client` (`idClient`),
  ADD CONSTRAINT `fk_favoris_produit` FOREIGN KEY (`idProduit`) REFERENCES `produit` (`idProduit`);

--
-- Contraintes pour la table `produit_regroupement`
--
ALTER TABLE `produit_regroupement`
  ADD CONSTRAINT `fk_pr_prod` FOREIGN KEY (`idProduit`) REFERENCES `produit` (`idProduit`),
  ADD CONSTRAINT `fk_pr_reg` FOREIGN KEY (`idRegroupement`) REFERENCES `regroupement` (`idRegroupement`);

--
-- Contraintes pour la table `souscategorie`
--
ALTER TABLE `souscategorie`
  ADD CONSTRAINT `fk_sc_enfant` FOREIGN KEY (`idSousCategorie`) REFERENCES `categorie` (`idCategorie`),
  ADD CONSTRAINT `fk_sc_parent` FOREIGN KEY (`idCategorie`) REFERENCES `categorie` (`idCategorie`);

--
-- Contraintes pour la table `stock`
--
ALTER TABLE `stock`
  ADD CONSTRAINT `fk_stock_produit` FOREIGN KEY (`idProduit`) REFERENCES `produit` (`idProduit`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
