#region ...

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

function requetePushSQL {
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

function requeteGetSQL {

    param($requeteSQL)

    #region Connexion a la base de données
    $stringConnexion = "Server=$DBServer;Port=$DBPort;Database=$DBName;User=$MariaDBLogin;Password=$MariaDBPassword"

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
        Write-Host "Connexion a la base de donnees reussie";

        $MysqlCmd = New-Object MySql.Data.MySqlClient.MySqlCommand($requeteSQL, $connexionSQL)      # Créer la commande SQL en indiquant la requête et la connexion
        $DataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($MysqlCmd)         # Créer l'adaptateur depuis la commande
        $DataSet = New-Object System.Data.DataSet                                            # Créer le jeu de données

        $DataAdapter.Fill($DataSet, "data")                                                  # Remplir le jeu de données $dataset et le mettre dans un tableau nommé "data"      
    

        try {

            #Les resultats de la requête sont stockés dans un tableau 
            $dataSet.Tables["data"];
           
            #Facultatif : On peut boucler sur ce tableau
            # foreach($societe in $resultat){
            #     Write-Host "La societe $($societe.soc_code) a pour index : $($societe.soc_nom)"
            # }

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
            write-error "le resultat de la requete n'a pas pu etre entierement traite" 
        }
            
    }
    catch {
        Write-Error "Une erreur est survenue lors de l'envoie de la requete SQL";
        exit;
    }
    #endregion
}

function selectAllFrom {

    param($table)

    #region Connexion a la base de données
    $stringConnexion = "Server=$DBServer;Port=$DBPort;Database=$DBName;User=$MariaDBLogin;Password=$MariaDBPassword"

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
        Write-Host "Connexion a la base de donnees reussie";

        $req = "SELECT * FROM $($table)";

        $MysqlCmd = New-Object MySql.Data.MySqlClient.MySqlCommand($req, $connexionSQL)      # Créer la commande SQL en indiquant la requête et la connexion
        $DataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($MysqlCmd)         # Créer l'adaptateur depuis la commande
        $DataSet = New-Object System.Data.DataSet                                            # Créer le jeu de données

        $DataAdapter.Fill($DataSet, "data")                                                  # Remplir le jeu de données $dataset et le mettre dans un tableau nommé "data"      
    

        try {

            #Les resultats de la requête sont stockés dans un tableau 
            $dataSet.Tables["data"];
           
            #Facultatif : On peut boucler sur ce tableau
            # foreach($societe in $resultat){
            #     Write-Host "La societe $($societe.soc_code) a pour index : $($societe.soc_nom)"
            # }

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
            write-error "le resultat de la requete n'a pas pu etre entierement traite" 
        }
            
    }
    catch {
        Write-Error "Une erreur est survenue lors de l'envoie de la requete SQL";
        exit;
    }
    #endregion
}

#endregion 

requeteGetSQL("INSERT INTO ... VALUES ...")

requeteGetSQL("SELECT ... FROM ...")
