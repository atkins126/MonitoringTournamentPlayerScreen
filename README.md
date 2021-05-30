# Monitoring Tournament Player Screen

Monitoring d'écran des joueurs d'une salle de jeu en réseau.

Module client et programme serveur pour capturer les flux vidéos de joueurs en réseau (local) et les afficher en mosaïque ou plein écran sur un autre apareil.

Utilisation des composants AppTethering fournis avec Delphi.

## Utilisation du serveur

* lancez le serveur en un ou plusieurs exemplaires sur votre réseau local

## Implémentation de la librairie clients dans un logiciel

* importez l'unité MonitoringImages\lib\uScreenMonitoring.pas dans votre projet

* utlisez la dans les unités qui gèrent un changement d'affichage de l'écran

* mettez à True la propriété AffichageEcranModifie lorsqu'un envoi d'une capture de la fiche active est voulu (ou dans un jeu lorsque l'écran a changé d'affichage).

ScreenMonitoringLib.AffichageEcranModifie := true;

## Problèmes connus

Des problèmes réseau sont possibles selon la configuration de vos antivirus ou firewall.

### ESET NOD32 Antivirus

Activez le "mode joueur" dans la configuration de la protection de l'ordinateur.

## TODO List

* ID du profil distant non tranmis avec la resource (image en stream)
=> cf Embarcadero, contournement effectué

* lors de la déconnexion (fermeture brutale d'un client/jeu) le monitoring ne le détecte pas toujours 
=> faire boucle de test régulière de l'état des différentes connexions (aka manager et profils connectés)

* pertes mémoires potentielles sur les clients dans quelques cas de fermeture

* pertes de trames d'images sur la librairie cliente de temps en temps, donc il doit y avoir un plantage dans la tâche d'envoi de l'image (forcer une réactivation de l'envoi si rien envoyé après X boucles/trames)

-----

Si vous ne connaissez pas Delphi et le langage Pascal, profitez de la version Academic (pour les étudiants, enseignants et établissements d'enseignement) ou Community Edition (gratuite pour une utilisation personnelle) disponibles chez Embarcadero (rubrique "outils gratuits").
En entreprise vous pouvez aussi tester Delphi avec la version d'évaluation.
https://www.embarcadero.com/products/delphi

Cette formation en ligne gratuite vous apprendra les bases de la programmation avec le Pascal et Delphi même si vous n'avez jamais appris à programmer :
https://apprendre-delphi.fr/apprendre-la-programmation-avec-delphi/

Des conférences en ligne et des webinaires (points techniques sur des sujets précis) sont organisés régulièrement. Consultez [le planning de ces webinaires](https://developpeur-pascal.fr/p/_6007-webinaires.html) et regardez les [rediffusions des webinaires Delphi](https://serialstreameur.fr/webinaires-delphi.php).

Des sessions de [live coding sur Twitch](https://www.twitch.tv/patrickpremartin) ou [la chaîne YouTube Developpeur Pascal](https://www.youtube.com/channel/UCk_LmkBB90jdEdmfF77W6qQ) sont également organisées régulièrement. Pour Twitch vous pouvez consulter [le planning hebdomadaire](https://www.twitch.tv/patrickpremartin/schedule). Vous pouvez aussi vous reporter à [cet article](https://developpeur-pascal.fr/p/_600e-livestreams-de-codage-en-direct-avec-delphi.html). Pour les rediffusions de tout ça, rendez-vous simplement dans la [rubrique live coding](https://serialstreameur.fr/live-coding.php) de [Serial Streameur](https://serialstreameur.fr/) où vous trouverez de nombreuses vidéos en français à destination des développeurs de logiciels, applications mobiles, sites web et jeux vidéo.

Enfin, si vous préférez la lecture à la vidéo, vous trouverez tous les livres récents publiés sur Delphi et le langage Pascal sur [Delphi Books](https://delphi-books.com)
