# Car Maintenance

**car_maintenance** est une application mobile développée avec **Flutter (Dart)** pour la gestion de l'entretien automobile. Elle utilise une base de données **SQLite** pour stocker localement les informations relatives aux véhicules et à leurs entretiens.

---

## Fonctionnalités :

- **Ajouter un ou plusieurs véhicules** avec les détails suivants :
  - Marque.
  - Modèle.
  - Année.

- **Visualiser la liste** des véhicules existants.
- **Sélectionner un véhicule** pour afficher ses entretiens.
- **Ajouter un nouvel entretien pour un véhicule :**
  - Type d'entretien (ex : vidange, révision, etc.)
  - Description.
  - Date de début.
  - Date d'expiration (facultative).
  - Prix.
  - Kilométrage actuel.
  - Prochain kilométrage prévu pour la vidange.

---

## Expérience utilisateur :
Lors du **premier lancement de l'application**, l'utilisateur peut :
-Sélectionner un véhicule existant.
-Ou en créer un nouveau s'il n'existe pas encore.

Une fois un véhicule sélectionné, l'utilisateur accède à une page listant tous les entretiens liés à ce véhicule.
Un bouton flottant en bas à droite permet d’ajouter un nouvel entretien.

---

## Technologies utilisées : 
-**Flutter / Dart** pour le développement mobile.
-**SQLite** pour la gestion locale des données.

---

## Lancement du projet : 
1. Cloner ce dépôt :

git clone https://github.com/Rayen-CHAOUI/car-maintenance.git

2. Ouvrir le projet avec Android Studio ou Visual Studio Code.

3. Exécuter l'application sur un simulateur ou un appareil physique :
flutter run

---

## Auteur : 
**CHAOUI Rayen.**

N'hésitez pas à contribuer, signaler des bugs ou proposer des améliorations !