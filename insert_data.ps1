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

#region Connexion a la base de données
$stringConnexion = "Server=$DBServer;Port=$DBPort;Database=$DBName;User=$MariaDBLogin;Password=$MariaDBPassword"

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

    #region les fonction d'ajout de data
    function addSociete {
        
        $soc_code = Read-Host "Quel est le code de la societe ?"
        $soc_nom = Read-Host "Quel est le nom de la societe ? "

        $req = "INSERT INTO t_societes VALUES ('$($soc_code)', '$($soc_nom)')";
    

        $MysqlCmd = New-Object MySql.Data.MySqlClient.MySqlCommand($req, $connexionSQL)      # Créer la commande SQL en indiquant la requête et la connexion
        $MysqlCmd.CommandText = $req                                                                     # On met la requête dans la propriété CommandText de la commande
        $SqlCmdExecute = $MysqlCmd.ExecuteNonQuery()                                              # On exécute la commande

        #region J'envoie d'envoyer la requete 
        try {
            if ($SqlCmdExecute) {
                $SqlCmdExecute;
                Write-Host "La societe - $($soc_nom) - ayant pour code - $($soc_code) - a bien ete enregistrer dans notre base de donnees"
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
    function addEtablissement {
        
        # Je recupère les données necessaire auprès de mon user 
        $etb_code = Read-Host "Quel est le code de l'etablissement ?"
        $etb_nom  = Read-Host "Quel est le nom de l'etablissement ? "
        $soc_code = Read-Host "A quelle societe appartient l'etablissement ? (entrez le code societe) : "

        # Je créé la requete
        $req = "INSERT INTO t_etablissements VALUES ('$($etb_code)', '$($etb_nom)', '$($soc_code)' )";
    

        $MysqlCmd = New-Object MySql.Data.MySqlClient.MySqlCommand($req, $connexionSQL)      # Créer la commande SQL en indiquant la requête et la connexion
        $MysqlCmd.CommandText = $req                                                         # On met la requête dans la propriété CommandText de la commande
        $SqlCmdExecute = $MysqlCmd.ExecuteNonQuery()                                         # On exécute la commande

        #region J'envoie la requete 
        try {
            if ($SqlCmdExecute) {
                $SqlCmdExecute;
                Write-Host "L'etablissement - $($etb_nom) - ayant pour code - $($etb_code) - et appartenant a la societe $($soc_code) - a bien ete enregistrer dans notre base de donnees"
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
    function addFonction {
        
        # Je recupère les données necessaire auprès de mon user 
        $fct_code = Read-Host "Quel est le code de la fonction ?"
        $fct_nom  = Read-Host "Quel est le nom de la fonction ? "

        # Je créé la requete
        $req = "INSERT INTO t_fonctions VALUES ('$($fct_code)', '$($fct_nom)')";

        $MysqlCmd = New-Object MySql.Data.MySqlClient.MySqlCommand($req, $connexionSQL)      # Créer la commande SQL en indiquant la requête et la connexion
        $MysqlCmd.CommandText = $req                                                         # On met la requête dans la propriété CommandText de la commande
        $SqlCmdExecute = $MysqlCmd.ExecuteNonQuery()                                         # On exécute la commande

        #region J'envoie la requete 
        try {
            if ($SqlCmdExecute) {
                $SqlCmdExecute;
                Write-Host "La fonction de $($fct_nom) - ayant pour code - $($fct_code) - a bien ete enregistrer dans notre base de donnees"
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
    function addUser {
        
        # Je recupère les données necessaire auprès de mon user 
        $user_nom = Read-Host "Quel est son nom ? "
        $user_prenom  = Read-Host "Quel est son prenom ? "
        $user_email  = Read-Host "Quel est son email ? "
        $fct_code  = Read-Host "Quel est le code de sa fonction ? "
        $soc_code  = Read-Host "Quel est le code de sa societe  ? "
        $etb_code  = Read-Host "Quel est le code de son etablissement  ? "

        # Je créé la requete
        $req = "INSERT INTO t_users (user_nom, user_prenom, user_email, fct_code, soc_code, etb_code)
        VALUES ( '$($user_nom)', '$($user_prenom)', '$($user_email)', '$($fct_code)', '$($soc_code)', '$($etb_code)')"
          

        $MysqlCmd = New-Object MySql.Data.MySqlClient.MySqlCommand($req, $connexionSQL)      # Créer la commande SQL en indiquant la requête et la connexion
        $MysqlCmd.CommandText = $req                                                         # On met la requête dans la propriété CommandText de la commande
        $SqlCmdExecute = $MysqlCmd.ExecuteNonQuery()                                         # On exécute la commande

        #region J'envoie la requete 
        try {
            if ($SqlCmdExecute) {
                $SqlCmdExecute;
                Write-Host "L'utilisateur $($user_nom) $($user_prenom) - $($fct_code) chez $($soc_code) - a bien ete enregistrer dans notre base de donnees"
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
    #endregion

    $tableARemplir = Read-Host "Quelle type de donnees voulez-vous ajouter ? (societe, etablissement, fonction, user ?) "

    switch ($tableARemplir) {
        "societe" { addSociete }
        "etablissement" { addEtablissement }
        "fonction" { addFonction }
        "user" { addUser }

        Default { Write-Error "aucune table ne porte le nom t_$($tableARemplir)"}
    }
}
catch {
    Write-Error "Une erreur est survenue lors de la creation de la requete";
    exit;
}
#endregion