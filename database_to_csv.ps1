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

function tableToCsv {

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
            $resultat = $dataSet.Tables["data"];

            #Affichage des resultats dans la console.
            # $resulat 

            # Je l'export en CSV 
            $resultat | Export-Csv -path ./csv/$table.csv -NoTypeInformation -Delimiter ";"
           
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

tableToCsv("t_etablissements")
tableToCsv("t_fonctions")
tableToCsv("t_societes")
tableToCsv("t_users")
tableToCsv("v_all_users")