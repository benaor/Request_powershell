#region initialisation
[xml]$ConfigFile = Get-Content "config.xml"      #Importer le fichier de configuration
$error.Clear()
[void][System.Reflection.Assembly]::LoadWithPartialName("MySql.Data")
#endregion

#region Déclaration des variables
[string]$DBServer = $ConfigFile.Configuration.DBServer
[string]$DBPort = $ConfigFile.Configuration.DBPort
[string]$MariaDBLogin = $ConfigFile.Configuration.DBLogin
[string]$MariaDBPassword = $ConfigFile.Configuration.DBPassword
[string]$DBName = $ConfigFile.Configuration.DBName
#endregion

#region Déclaration des fonctions

# fonction pour créer la base de données
function createDatabase {

    #region initialisation
    $error.Clear()
    [void][System.Reflection.Assembly]::LoadWithPartialName("MySql.Data")
    #endregion

    #region Connexion a la base de données
    $stringConnexion = "Server=$DBServer;Port=$DBport;User=$MariaDBLogin;Password=$MariaDBPassword"

    $connexionSQL = New-Object MySql.Data.MySqlClient.MySqlConnection($stringConnexion)
    $connexionSQL.Open()

    #endregion

    #region Si la connexion a échoué : 
    if ($connexionSQL.State -ne [Data.ConnectionState]::Open) {
        Write-Host "Impossible de se connecter"
        Exit
    }
    #endregion

    #region Manipulation de la base de données
    try {
        Write-Host "Connexion a mariaDB reussi";

        $req = "CREATE DATABASE IF NOT EXISTS $($DBName) CHARACTER SET 'utf8'";
    
        $MysqlCmd = New-Object MySql.Data.MySqlClient.MySqlCommand($req, $connexionSQL)    # Créer la commande SQL en indiquant la requête et la connexion
        $MysqlCmd.CommandText = $req                                                       # On met la requête dans la propriété CommandText de la commande
        $SqlCmdExecute = $MysqlCmd.ExecuteNonQuery()                                       # On exécute la commande

        #region J'envoie d'envoyer la requete 
        try {
            if ($SqlCmdExecute) {
                $SqlCmdExecute;
                Write-Host "La base de donnees a bien ete cree dans notre base de donnees"
            }

        }
        catch {
            Write-Host "L'ajout des donnees n'a pas pu aboutir..."
        }
        #endregion

    }
    catch {
        Write-Error "Une erreur est survenue";
        exit;
    }
    #endregion
}

# Fonction pour envoyer une requete SQL
function requeteSQL {
    param (
        [string]$requeteSQL
    )
    #region initialisation
    $error.Clear()
    [void][System.Reflection.Assembly]::LoadWithPartialName("MySql.Data")
    #endregion

    #region Connexion a la base de données
    $stringConnexion = "Server=$DBServer;Port=$DBport;Database=$DBName;User=$MariaDBLogin;Password=$MariaDBPassword"

    $connexionSQL = New-Object MySql.Data.MySqlClient.MySqlConnection($stringConnexion)
    $connexionSQL.Open()
    #endregion

    #region Si la connexion a échoué : 
    if ($connexionSQL.State -ne [Data.ConnectionState]::Open) {
        Write-Error "Impossible de se connecter a la base de donnees"
        Exit
    }
    #endregion

    #region Manipulation de la base de données
    try {
        Write-Host "Connexion a la base de donnees reussie";

        $MysqlCmd = New-Object MySql.Data.MySqlClient.MySqlCommand($requeteSQL, $connexionSQL)      # Créer la commande SQL en indiquant la requête et la connexion
        $MysqlCmd.CommandText = $requeteSQL                                                       # On met la requête dans la propriété CommandText de la commande
        $SqlCmdExecute = $MysqlCmd.ExecuteNonQuery()                                                # On exécute la commande

        #region apres l'envoi de la requete 
        try {
            if ($SqlCmdExecute) {
                $SqlCmdExecute;
                Write-Host "La requete a bien ete execute"
            }

            #region fermer la connexion
            try {
                $MysqlCmd.Dispose();
                $connexionSQL.Close();
                Write-Host "La connexion avec la base de donnees s'est correctement arreter apres l'execution du script"
            }
            catch {
                Write-Error "La connexion avec la base de donnees n'a pas pu etre ferme"
            }
            #endregion
        }
        catch {
            Write-Error "Erreur lors de l'execution de la requete"
        }
        #endregion

    }
    catch {
        Write-Error "Une erreur est survenue lors de la creation de la requete";
        exit;
    }
    #endregion
}
#endregion

#region Execution du script 

# Créer la base de données 
createDatabase

# Crée la table t_societes
requeteSQL(
    "CREATE TABLE IF NOT EXISTS t_societes (
        soc_code VARCHAR(10) NOT NULL PRIMARY KEY,
        soc_nom VARCHAR(255) NOT NULL
        )
        ENGINE=InnoDB;"
)
        
# Crée la table t_etablissements
requeteSQL(
    "CREATE TABLE IF NOT EXISTS t_etablissements (
        etb_code VARCHAR(10) NOT NULL PRIMARY KEY,
        etb_nom VARCHAR(255) NOT NULL,
        soc_code VARCHAR(10) NOT NULL,
        INDEX IDX_soc_etb (soc_code)
        )
        ENGINE=InnoDB;"
)

requeteSQL(
    "ALTER TABLE t_etablissements 
    ADD CONSTRAINT FK_soc_etb 
    FOREIGN KEY (soc_code) 
    REFERENCES t_societes (soc_code)"
)
   
# Crée la table t_fonctions
requeteSQL(
    "CREATE TABLE IF NOT EXISTS t_fonctions (
        fct_code VARCHAR(10) NOT NULL PRIMARY KEY,
        fct_nom VARCHAR(255) NOT NULL
        )
        ENGINE=InnoDB;"
)

# Créé la table Users
requeteSQL(
    "CREATE TABLE IF NOT EXISTS t_users (
    user_matricule INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    user_nom VARCHAR(255) NOT NULL,
    user_prenom VARCHAR(255) NOT NULL,
    user_email VARCHAR(255) NOT NULL,
    fct_code VARCHAR(10),
    soc_code VARCHAR(10),
    etb_code VARCHAR(10),
    INDEX IDX_fct_user (fct_code),
    INDEX IDX_soc_user (soc_code),
    INDEX IDX_etb_user (etb_code)
    )
    ENGINE=InnoDB;"
)
requeteSQL(
    "ALTER TABLE t_users 
    ADD CONSTRAINT FK_fct_user 
    FOREIGN KEY (fct_code) 
    REFERENCES t_fonctions (fct_code)"
)
requeteSQL(
    "ALTER TABLE t_users 
    ADD CONSTRAINT FK_soc_user 
    FOREIGN KEY (soc_code) 
    REFERENCES t_societes (soc_code)"
)
requeteSQL(
    "ALTER TABLE t_users 
    ADD CONSTRAINT FK_etb_user 
    FOREIGN KEY (etb_code) 
    REFERENCES t_etablissements (etb_code)"
)

# Remplir la table t_societe 
requeteSQL(
    "INSERT INTO t_societes VALUES
        ('ECL','ECL developpement'),
        ('MB', 'pole mercedes-benz'),
        ('PSA', 'pole PSA')"
)
            
# remplir la table t_etablissement
requeteSQL(
    "INSERT INTO t_etablissements VALUES 
        ('TRIGONE', 'trigone siege social','ECL'),
        ('INNO', 'Innotech 25','ECL'),
        ('SIAB','Societe industrielle automobile Bisontine', 'PSA'),
        ('ETL58', 'Mercedes-benz Nevers', 'MB'),
        ('ETL25', 'Mercedes-benz Besancon', 'MB'),
        ('ETL70', 'Mercedes-benz Vesoul', 'MB')"
) 
            
# remplir la table t_fonction 
requeteSQL(
    "INSERT INTO t_fonctions VALUES 
        ('PDG', 'president directeur general'),
        ('DRH', 'Directeur des ressources humaines'), 
        ('DSI', 'Directeur des systemes d\'informations')"
)
    
#endregion