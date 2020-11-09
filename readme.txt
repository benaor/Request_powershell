Pour executer le script : 

Editez le fichier "config.xml" pour permettre la connexion avec la base de données, choisir un DBName qui n'est pas déjà utilisé

Placez-vous dans le répertoire "PowershellSQL" depuis votre invite de commande Powershell

Executer "./create_and_fill_database.ps1" pour créer et remplir la base de données avec des données pré-configuré

Executer "./insert_data.ps1" pour ajouter des données dans les tables (Ajouts actuellement disponible : Etablissement, fonction et sociétés)

Executer "./database_to_csv.ps1" Pour récupérer les données de toutes les tables dans un fichier .csv (un fichier par table). Les fichiers se trouveront dans "./csv/"