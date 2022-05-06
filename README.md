# Projet de synchronisation de macro-ordinateurs en mer

I -- Introduction
============================

L'objectif de ce projet est de créer []{#anchor-1}le prototype
minimaliste d'un système visant à protéger les ferme ostréicoles des
côtes atlantiques contre les dorades royales en émettant des sons de
leurs prédateurs. Ainsi, on veut synchroniser des nano-ordinateurs
situés à 500m maximum les uns des autres et à 4km maximum des côtes,
pour qu'ils jouent le même son simultanément.

II -- Principe
===========================

1) Architecture de la flotte
-----------------------------------------

Pour ce projet, on dispose d'une flotte de nano-ordinateurs dont l'un
est considéré comme le « maître », et tout les autres sont les
« esclaves ».

Le rôle du maître sera de :

-   générer un emploi du temps, qui décrit le moment auquel les sons
    doivent être joués, et l'identifiant du son à jouer,
-   transmettre l'emploi du temps à l'ensemble des esclaves,
-   jouer cet emploi du temps ?

Le rôle des esclaves sera de :

-   recevoir l'emploi du temps transmis par le maître,
-   jouer l'emploi du temps reçu.

2) Choix techniques
--------------------------------

Étant donné le cahier des charges, on fait le choix d'utiliser le
protocole de communication LoRa, qui permet de communiquer sur des
distances relativement longues (jusqu'à 10km), au prix d'un débits de
donnés faible. De plus, ce protocole est gratuit puisqu'il utilise la
bande de fréquence ISM (Ingénierie Scientifique Médicale : 868 MHz en
Europe).

Par ailleurs, on utilise une carte son externe au nano-ordinateur afin
d'avoir une bonne qualité sonore. Le signal produit doit ensuite être
amplifié et transmis à un haut-parleur, mais ceci sort du cadre du
projet.

Enfin, on utilise les signaux GPS afin de contrecarrer la dérives des
horloges internes des nano-ordinateurs, puisqu'elles doivent fonctionner
en autonomie.

##III -- Matériel
============================

Dans la suite de ce document, le processus d'installation est décrit
pour le matériel suivant :

Pour chaque élément de la flotte :

-   une carte Raspberry PI 3b ou 2b+,
-   une carte micro-SD (minimum 8GB),
-   un HAT Hifiberry DAC+,
-   un HAT Dragino LoRa/GPS v1.4,
-   Un méthode permettant d'accéder à la raspberry Pi, soit :

    -   un ordinateur personnel connecté à internet,
    -   ou un clavier et un écran qui puissent être connectés au
        nano-ordinateur.

-   Un câble Ethernet RJ45

Ces éléments peuvent être substitués par des composants équivalents si
besoin, mais les instructions pour l'installation devront alors être
adaptées.

##IV -- Instructions d'installation
=================================

Les instructions suivantes ont été testées pour des raspberry PI 3b et
3b+, et pour Raspberry PI OS 11 (bullseye). Il peut être nécessaire
d'adapter ces instructions pour d'autres modèles de raspberry ou pour
d'autres versions de l'OS.

###1) Installation de Raspberry PI OS sur la raspberry PI
------------------------------------------------------

Pour commencer, il est nécessaire d'installer un système d'exploitation
(OS : Operating System) sur le nano-ordinateur. On va utiliser Raspberry
PI OS qui est open source, peu coûteux en ressources et très
généraliste. C'est un OS qui est fondé sur Linux.

Connecter la carte micro-SD à l'ordinateur, puis télécharger
l'utilitaire Raspberry PI Imager
([lien](https://www.raspberrypi.com/software/)) et l'installer.

Lancer l'utilitaire et choisir l'OS à installer et la
carte SD sur laquelle l'utilitaire va l'installer. Normalement
l'utilitaire devrait détecter la carte SD connectée à l'ordinateur. Pour
la rédaction de ce document, la version « Raspbian GNU/Linux 11
(bullseye) » a été utilisée. On se contente d'installer la version
« Lite » de l'OS, qui est suffisante pour l'application qu'on en fait.

Lancer l'écriture sur la carte SD. Cette étape peut durer quelques
minutes.

Si on souhaite accéder à la carte depuis un ordinateur personnel,
ajouter un fichier texte vide appelé « ssh » (et non pas « ssh.txt ») au
dossier boot de la carte SD. Ceci active le protocole ssh.

La carte SD est alors prête. On peut la déconnecter de l'ordinateur et
l'introduire dans le port micro-SD de la raspberry PI. Il devrait être
possible d'accéder au terminal de la raspberry Pi après quelques minutes
une fois celle-ci branchée. L'identifiant par défaut est « pi » et le
mot de passe est « raspberry ». **Il est fortement recommandé de changer
ces paramètres lors de la 1ère connexion à la carte.**

###2) Installation du HAT Hifiberry DAC+
--------------------------------------------------

Nous allons maintenant procéder à l'installation du HAT Hifiberry DAC+.
La première étape est de connecter le HAT à la carte en insérant les 40
broches dans les 40 ports de la carte.

On commence par déconnecter le driver son par défaut de la raspberry PI
en retirant les lignes :
```
dtparam=audio=on

dtoverlay=vc4-fkms-v3d
```
du fichier ```/boot/config.txt``` ( en utilisant la commande ```sudo nano
/boot/config.txt``` par exemple).

Ajouter ensuite dans ce même fichier l'une des lignes suivantes en
fonction de la version du HAT hifiberry utilisée, afin d'installer le
driver de la carte Hifiberry.

-   DAC pour Raspberry Pi 1/DAC+ Light/DAC Zero/MiniAmp/Beocreate/DAC+
    DSP/DAC+ RTC

    ```dtoverlay=hifiberry-dac```

-   DAC+ Standard/Pro/Amp2

    ```dtoverlay=hifiberry-dacplus```

-   DAC2 HD

    ```dtoverlay=hifiberry-dacplushd```

-   DAC+ ADC

    ```dtoverlay=hifiberry-dacplusadc```

-   DAC+ ADC Pro

    ```dtoverlay=hifiberry-dacplusadcpro```

-   Digi+

    ```dtoverlay=hifiberry-digi```

-   Digi+ Pro

    ```dtoverlay=hifiberry-digi-pro```

-   Amp+ (not Amp2!)

    ```dtoverlay=hifiberry-amp```

Enfin, ajouter la ligne *force\_eeprom\_read=0 *à ce même fichier. Cette
ligne permet d'éviter certaines incompatibilités entre les dernières
versions de linux et les données enregistrées dans la mémoire interne du
HAT. Sauvegarder et quitter le fichier pour retourner dans la console
(ctrl + s, ctrl + x).

Créer ensuite le fichier ```/etc/asound.conf``` (commande ```sudo nano
/etc/asound.conf``` par exemple) et y copier-coller les lignes suivantes
afin de sélectionner les cartes sons à utiliser. Ici Hifiberry devrait
correspondre au 0.

defaults.pcm.card 0

defaults.pcm.device 0

defaults.ctl.card 0

Sauvegarder et quitter le fichier, puis redémarrer la carte (```sudo
reboot```). Après redémarrage, il devrait être possible de connecter des
hauts-parleurs à la carte et de jouer des sons dessus. Pour tester ceci,
on peut utiliser la commande :

```aplay -l```

Cette commande liste toutes les cartes sons disponibles. La seule entrée
visible devrait être le HAT Hifiberry. Il est ensuite possible de tester
la sortie audio avec la commande ```speaker-test -t wav -c 6```.

###3) Installation du HAT Dragino LoRa/GPS
----------------------------------------------------

Nous allons maintenant installer le HAT Dragino LoRa/GPS. Il faut tout
d'abords connecter le HAT au dessus du HAT Hifiberry. Pour cela, il faut
souder un connecteur 40 ports sur le HAT Hifiberry. Il n'est pas
recommandé d'installer le HATHifiberry au dessus du HAT GPS/LoRa puisque
le GPS a besoin d'être en vue directe du ciel.

Il est à noter qu'une antenne adaptées est nécessaire
pour LoRa (antenne 868,1 MHz), mais pas pour le GPS. En effet, la puce
GPS dispose d'un réseau d'antennes imprimé directement sur le silicium.

Par la suite, l'installation logicielle se fait en deux étapes :

-   l'installation du GPS,
-   l'installation de LoRa.

####3.1 - Installation du GPS

On commence par donner l'instruction à l'OS d'installer les drivers qui
nous intéressent. Pour cela, on écrit les lignes :
```
dtparam=spi=on

dtoverlay=pi3-disable-bt-overlay

core\_freq=250

enable\_uart=1

force\_turbo=1
```
Dans Le fichier ```/boot/config.txt``` (```sudo nano /boot/config.txt```). Puis
éditer le fichier ```/boot/cmdline.txt``` (```sudo nano /boot/cmdline.txt```)
et remplacer l'ensemble de son contenu par :
```
dwc\_otg.lpm\_enable=0 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4
elevator=deadline fsck.repair=yes rootwait
```
Sauver et quitter. Afin de désactiver le système Bluetooth par défaut
qui utilise les ports dont le GPS a besoin pour fonctionner, exécuter
dans la terminal la commande
```
sudo systemctl disable hciuart
```
Puis éditer le fichier de configuration correspondant (```sudo nano
/lib/systemd/system/hciuart.service```) en remplaçant la ligne
*After=dev-serial1.device* par ```After=dev-ttyS0.device```. Sauver et
quitter.

Enfin, mettre-à-jour la raspberry et la redémarrer avec les commandes
suivantes :

```
sudo apt-get update

sudo apt-get upgrade

sudo reboot
```

Le module GPS devrait alors envoyer des données à la carte raspberry PI
sur la liaison série. Il est possible de visualiser les données GPS
brutes envoyées avec la commande ```sudo cat /dev/ttyS0```.

Attention, lors d'une première utilisation, un GPS peut mettre plusieurs
minutes avant de connaître sa position, la communication avec les
satellites est très lente. Il ne faut pas s'inquiéter si les données GPS
n'ont pas l'aspect présenté dans la figure 6 dés le début.

Désactiver le service tty (text only) de la raspberry.

```
sudo systemctl stop serial-getty\@ttyS0.service

sudo systemctl disable serial-getty\@ttyS0.service
```

Nous allons maintenant installer GPSD, un utilitaire qui traite les
information GPS brutes à notre place. Pour cela, utiliser la commande

```
sudo apt-get install gpsd gpsd-clients
```

Durant son installation, GPSD met en place un système automatique de
lecture de données GPS. On veut le désactiver puisqu'il interfère avec
les sessions de GPSD créées manuellement.

```
sudo systemctl stop gpsd.socket

sudo systemctl disable gpsd.socket
```

On peut alors lancer manuellement une session GPSD en utilisant la
commande :

```
sudo gpsd /dev/ttyS0 -F /var/run/gpsd.sock

On peut visualiser les données GPS traitées avec la commande *cgps -s.*
```

Si après quelques minutes **en vu du ciel** cette interface affiche
toujours « NO FIX », cela signifie qu'il y a potentiellement un problème
et que la puce ne parvient pas à obtenir les données des satellites. En
général, déplacer la carte pour que la puce GPS soit directement sous le
ciel suffit à résoudre ce problème après quelques minutes d'attentes. Si
ce n'est pas le cas, il peut être nécessaire de redémarrer une session
gpsd :

```
sudo killall gpsd

sudo gpsd /dev/ttyS0 -F /var/run/gpsd.sock
```

Si cela ne résout toujours pas le problème, modifier le fichier de
configuration de gpsd (sudo nano /etc/default/gpsd) et remplaçant
l'ensemble du fichier par :

```
START\_DAEMON=\"true\"

GPSD\_OPTIONS=\"-n\"

DEVICES=\"/dev/ttyS0\"

USBAUTO=\"false\"

GPSD\_SOCKET=\"/var/run/gpsd.sock\"
```

####3.2 -- Installation de LoRa

Nous allons maintenant installer les drivers pour faire fonctionner LoRa
sur la carte. Pour commencer, installer wiringpi, une librairie écrite
en C qui permet de gérer les entrées/sorties de la raspberry PI. Ce
paquet n'est plus disponible par le gestionnaire de paquets apt depuis
que son créateur a abandonné son développement. Il faut donc l'installer
directement depuis git, où des utilisateurs tiers maintiennent une
version à jour de cette librairie. Il n'est pas possible d'utiliser une
autre librairie sans recoder les drivers nécessaires.

Exécuter les commandes suivantes pour télécharger wiringpi.

```
sudo apt-get install git

cd

git clone https://github.com/WiringPi/WiringPi
```

Il faut maintenant installer cette librairie. Pour cela, on suit les
instructions du fichier INSTALL disponible sur github
([lien](https://github.com/WiringPi/WiringPi/blob/master/INSTALL#L4)).
En bref, les deux commandes suivantes devraient suffire.Ces programmes
utilisent des librairies externes qu'il faut installer. La première
librairie est bc qui permet d'effectuer des opérations mathématiques sur
des nombres à virgule flottante, et la seconde librairie est ffmpeg qui
permet la manipulation

```
cd WiringPi/

./build
```

On peut maintenant télécharger les programmes qu'on va utiliser pour
communiquer avec le protocole LoRa.

```
cd

wget https://codeload.github.com/dragino/rpi-lora-tranceiver/zip/master

unzip master

rm master
```

On peut alors procéder à l'installation de ces programmes.

```
cd rpi-lora-tranceiver-master/dragino\_lora\_app

make
```

\
Enfin, on peut tester le bon fonctionnement de LoRa. En utilisant deux
raspberry PI configurées de la même manière, on peut exécuter sur l'une
le programme obtenu en la configurant en émetteur :

```
cd \~/rpi-lora-tranceiver-master/dragino\_lora\_app

./dragino\_lora\_app sender
```

Cette carte envoi alors toute les 5 secondes le message « HELLO ». On
peut alors configurer l'autre carte en récepteur :

```
cd \~/rpi-lora-tranceiver-master/dragino\_lora\_app

./dragino\_lora\_app receiver
```

La carte réceptrice doit alors recevoir le message « HELLO » envoyé par
l'autre carte. C'est ce programme légèrement modifié qui est utilisé par
la suite pour la partie logicielle de ce projet.

####3.3 -- Installation des logicielles

Cette partie propose de télécharger les programmes développées pour ce
projet. Ils sont rudimentaires et ne doivent être utilisés que comme une
base de travail pour développer des programmes robustes.

Pour télécharger ces programmes, exécuter les commandes suivantes dans
le terminal de chaque raspberry PI. Ces commandes téléchargent les
fichiers nécessaires depuis le répertoire git où je les ai déposés.

```
cd

git clone https://github.com/MrXerios/Sparus

cd sparus/

make
```

Ces programmes utilisent des librairies externes qu'il faut installer.
La première librairie est *bc* qui permet d'effectuer des opérations
mathématiques sur des nombres à virgule flottante, et la seconde
librairie est *ffmpeg* qui permet la manipulation de fichiers audio, et
notamment la conversion entre les différents formats (.mp3, .wav, etc).
C'est cette librairie qui est également utilisée pour lire les fichiers
audio.

```
sudo apt install bc

sudo apt install ffmpeg
```

##V -- Utilisation
================

Une fois l'installation terminée, on peut commencer à utiliser ces
programmes. Pour cela, il faut :

-   Brancher un amplificateur et un haut-parleur adapté à la sortie
    audio du HAT Hifiberry
-   Télécharger les fichiers audios à lire dans le dossier
    ```\~/sparus/audio ``` de chaque raspberry PI
-   Modifier les paramètres de génération de l'emploi du temps dans le
    fichier de paramètres (```nano \~/sparus/param.txt```) de la raspberry
    maître :

    -   silence (2 valeurs) : durées minimale et maximale en seconde
        entre chaque lecture audio
    -   duration : durées en seconde pour laquelle l'emploi du temps est
        généré
    -   timeout : durée maximal d'un son en seconde, au-delà de laquelle
        la lecture en cours est coupée

-   Modifier si besoin la période de la synchronisation de l'heure grâce
    au GPS dans le fichier de paramètres de chaque cartes, si
    nécessaire. Par défaut cette valeur vaut 84600 secondes, soit 24h.

Enfin, on peut lancer les programmes adaptés sur chaque carte. Commencer
par utiliser la commande suivante sur toutes les raspberry PI esclave.

```
sudo \~/sparus/sparus\_slave

Enfin lancer la commande suivante sur la raspberry PI maître.

sudo \~/sparus/sparus\_master
```
