// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Vynody';

  @override
  String get alwaysOnTop => 'Toujours au premier plan';

  @override
  String get systemMediaLibrary => 'Bibliothèque multimédia système';

  @override
  String get scanningDirectory => 'Analyse du répertoire...';

  @override
  String filesPreprocessed(Object count) {
    return '$count prétraités';
  }

  @override
  String filesDiscovered(Object count) {
    return '$count découverts';
  }

  @override
  String filesFullyProcessed(Object count) {
    return '$count entièrement traités';
  }

  @override
  String get directoryAddedSuccess => 'Répertoire ajouté avec succès';

  @override
  String get directoryAddedNoMusic =>
      'Répertoire ajouté, mais aucun fichier audio trouvé';

  @override
  String get scanDirectory => 'Analyser le répertoire';

  @override
  String get sort => 'Trier';

  @override
  String get addRootDirectory => 'Ajouter un répertoire racine';

  @override
  String get goBack => 'Retour';

  @override
  String get noMediaLibraryPermission =>
      'Pas d\'accès à la bibliothèque multimédia';

  @override
  String get grantPermission => 'Accorder la permission';

  @override
  String get needPermissionToScan =>
      'Permission requise pour analyser la musique locale';

  @override
  String get rebuildTagDatabase => 'Reconstruire la base d\'étiquettes';

  @override
  String get rebuildDatabase => 'Reconstruire la base de données';

  @override
  String get confirmRebuildDatabase =>
      'Voulez-vous vraiment reconstruire toutes les étiquettes des chansons ? Cela peut prendre du temps.';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get rebuildingDatabase =>
      'Reconstruction de la base d\'étiquettes des chansons...';

  @override
  String get sortBy => 'Trier par';

  @override
  String get sortScope => 'Portée';

  @override
  String get sortOrder => 'Ordre de tri';

  @override
  String get title => 'Titre';

  @override
  String get fileName => 'Nom du fichier';

  @override
  String get trackNumber => 'Numéro de piste';

  @override
  String get ascending => 'Croissant';

  @override
  String get descending => 'Décroissant';

  @override
  String get currentFolderScope => 'Dossier actuel';

  @override
  String get globalScope => 'Global';

  @override
  String get visualizerSettings => 'Paramètres de la page de lecture';

  @override
  String get algorithm => 'Spectre';

  @override
  String get appearance => 'Apparence';

  @override
  String get spectrumAppearanceGroup => 'Apparence du spectre';

  @override
  String get spectrumAdvancedOptions => 'Options avancées du spectre';

  @override
  String get resetAlgorithm => 'Réinitialiser l\'algorithme';

  @override
  String get resetAppearance => 'Réinitialiser l\'apparence';

  @override
  String get smoothing => 'Lissage';

  @override
  String get gravity => 'Gravité';

  @override
  String get logScale => 'Échelle logarithmique';

  @override
  String get contrast => 'Contraste';

  @override
  String get normalization => 'Normalisation';

  @override
  String get multiplier => 'Multiplicateur';

  @override
  String get skipHighFrequency => 'Ignorer les hautes fréquences';

  @override
  String get frequencyGroups => 'Groupes de fréquences';

  @override
  String get aggregationMode => 'Mode d\'agrégation';

  @override
  String get opacity => 'Opacité';

  @override
  String get enableGradient => 'Activer le dégradé';

  @override
  String get startColor => 'Couleur de début';

  @override
  String get endColor => 'Couleur de fin';

  @override
  String get gradientRangeStop1 => 'Arrêt de dégradé 1';

  @override
  String get gradientRangeStop2 => 'Arrêt de dégradé 2';

  @override
  String get gradientRepeatMode => 'Mode de répétition du dégradé';

  @override
  String get color => 'Couleur';

  @override
  String get followCoverColor => 'Suivre la couleur de la pochette';

  @override
  String get selectColor => 'Choisir une couleur';

  @override
  String get volume => 'Volume';

  @override
  String get clearQueue => 'Vider la file d\'attente';

  @override
  String get confirmClearQueue =>
      'Voulez-vous vraiment vider la file d\'attente actuelle ?';

  @override
  String get queueCleared => 'File d\'attente vidée';

  @override
  String get locateCurrentSong => 'Localiser la chanson actuelle';

  @override
  String get songNotInScannedFolders =>
      'La chanson actuelle n\'est pas dans les répertoires analysés';

  @override
  String get queue => 'File d\'attente';

  @override
  String get queueEmpty => 'La file d\'attente est vide';

  @override
  String selectedSongs(int count) {
    return '$count chansons sélectionnées';
  }

  @override
  String get unknownArtist => 'Artiste inconnu';

  @override
  String deletedSongs(int count) {
    return '$count chansons supprimées';
  }

  @override
  String get delete => 'Supprimer';

  @override
  String get createPlaylist => 'Créer une liste de lecture';

  @override
  String get playlistName => 'Nom de la liste';

  @override
  String get enterPlaylistName => 'Entrez le nom de la liste';

  @override
  String get playlistNameExists => 'Ce nom de liste existe déjà';

  @override
  String get renamePlaylist => 'Renommer la liste';

  @override
  String get deletePlaylist => 'Supprimer la liste';

  @override
  String confirmDeletePlaylist(String name) {
    return 'Voulez-vous vraiment supprimer la liste \"$name\" ?';
  }

  @override
  String get deletePlaylists => 'Supprimer les listes de lecture';

  @override
  String confirmDeletePlaylists(int count) {
    return 'Voulez-vous vraiment supprimer les $count listes sélectionnées ?';
  }

  @override
  String playlistsDeleted(int count) {
    return '$count listes supprimées';
  }

  @override
  String selectedPlaylistsCount(int count) {
    return '$count listes sélectionnées';
  }

  @override
  String get batchDelete => 'Suppression par lot';

  @override
  String get addToPlaylist => 'Ajouter à la liste';

  @override
  String get selectAll => 'Tout sélectionner';

  @override
  String get addToQueue => 'Ajouter à la file';

  @override
  String get addedToQueue => 'Ajouté à la file';

  @override
  String songCount(int count) {
    return '$count chansons';
  }

  @override
  String addedToPlaylist(int count, String playlist) {
    return '$count chansons ajoutées à $playlist';
  }

  @override
  String get createNewList => 'Nouvelle liste';

  @override
  String createdPlaylist(String name, int count) {
    return 'Liste \"$name\" créée avec $count chansons';
  }

  @override
  String get rename => 'Renommer';

  @override
  String get playlist => 'Liste de lecture';

  @override
  String get mostPlayed => 'Les plus écoutées';

  @override
  String get recentlyPlayed => 'Écoutés récemment';

  @override
  String get recentlyAdded => 'Ajoutées récemment';

  @override
  String get albums => 'Albums';

  @override
  String get artists => 'Artistes';

  @override
  String get mostPlayedDescription =>
      'Classées par nombre d\'écoutes complètes';

  @override
  String get recentlyPlayedDescription =>
      'Trier par heure de lecture, y compris les fichiers externes';

  @override
  String get recentlyAddedDescription =>
      'Triées par date d\'ajout à la bibliothèque';

  @override
  String get allTime => 'Tout le temps';

  @override
  String get pastWeek => 'Semaine dernière';

  @override
  String get pastMonth => 'Mois dernier';

  @override
  String get past90Days => '90 derniers jours';

  @override
  String get noPlayHistory => 'Aucun historique d\'écoute';

  @override
  String get noPlayHistoryInRange => 'Aucun historique dans cette période';

  @override
  String get noRecentlyPlayedSongs => 'Aucun historique de lecture';

  @override
  String get noRecentlyPlayedInRange =>
      'Aucun historique de lecture dans cette plage horaire';

  @override
  String get noRecentlyAddedSongs => 'Aucune chanson dans votre bibliothèque';

  @override
  String get noRecentlyAddedInRange =>
      'Aucune chanson ajoutée dans cette période';

  @override
  String get addedOn => 'Ajoutée le';

  @override
  String get externalSourceTag => 'Externe';

  @override
  String get lastPlayed => 'Dernière écoute';

  @override
  String playCountLabel(int count) {
    return '$count écoutes';
  }

  @override
  String get playAll => 'Tout lire';

  @override
  String get shufflePlay => 'Lecture aléatoire';

  @override
  String get noAlbums => 'Aucun album disponible';

  @override
  String get noArtists => 'Aucun artiste disponible';

  @override
  String get searchAlbums => 'Rechercher des albums ou artistes';

  @override
  String get searchArtists => 'Rechercher des artistes';

  @override
  String get albumSort => 'Trier';

  @override
  String get sortArtistAsc => 'Artiste A-Z';

  @override
  String get sortTitleAsc => 'Titre d\'album A-Z';

  @override
  String get sortTrackCount => 'Nombre de chansons';

  @override
  String get sortDuration => 'Durée totale';

  @override
  String get sortRecentAdded => 'Ajout récent';

  @override
  String get sortAscending => 'Croissant';

  @override
  String get sortDescending => 'Décroissant';

  @override
  String get playNext => 'Lire ensuite';

  @override
  String get addToFavorites => 'Ajouter aux favoris';

  @override
  String get removeFromFavorites => 'Retirer des favoris';

  @override
  String get viewAlbumDetails => 'Voir les détails de l\'album';

  @override
  String get viewArtistDetails => 'Voir les détails de l\'artiste';

  @override
  String get openFileLocation => 'Ouvrir l\'emplacement du fichier';

  @override
  String get copyAlbumTitle => 'Copier le titre de l\'album';

  @override
  String get copyArtistName => 'Copier le nom de l\'artiste';

  @override
  String albumCount(int count) {
    return '$count albums';
  }

  @override
  String get emptyList => 'La liste est vide';

  @override
  String get dragToAddMusic =>
      'Glissez des fichiers ou dossiers pour ajouter de la musique';

  @override
  String get unknownAlbum => 'Album inconnu';

  @override
  String get managePlaylists => 'Gérer les listes de lecture';

  @override
  String get createNewPlaylist => 'Créer une nouvelle liste';

  @override
  String get defaultList => 'Liste par défaut';

  @override
  String get playbackMode => 'Mode de lecture';

  @override
  String get playbackOptions => 'Options de lecture';

  @override
  String get setVisualizerDisplay => 'Configurer l\'affichage du visualiseur';

  @override
  String get noPlaybackContent => 'Aucun contenu en cours de lecture';

  @override
  String get file => 'Fichier';

  @override
  String get play => 'Lecture';

  @override
  String get list => 'Bibliothèque';

  @override
  String get queueTab => 'File';

  @override
  String get more => 'Plus';

  @override
  String get settings => 'Paramètres';

  @override
  String get themeMode => 'Thème';

  @override
  String get themeModeSystem => 'Suivre le système';

  @override
  String get themeModeLight => 'Clair';

  @override
  String get themeModeDark => 'Sombre';

  @override
  String get themeColor => 'Couleur du thème';

  @override
  String get customThemeColor => 'Couleur de thème personnalisée';

  @override
  String get themeColorMikuTeal => 'Vert Miku';

  @override
  String get themeColorClassicBlue => 'Bleu classique';

  @override
  String get themeColorIrisPurple => 'Pourpre iris';

  @override
  String get themeColorViolet => 'Violet';

  @override
  String get themeColorSakuraPink => 'Rose sakura';

  @override
  String get themeColorCoralOrange => 'Orange corail';

  @override
  String get themeColorAmberGold => 'Or ambré';

  @override
  String get themeColorForestGreen => 'Vert forêt';

  @override
  String get themeColorAuroraCyan => 'Cyan aurore';

  @override
  String get themeColorCrimsonRed => 'Rouge cramoisi';

  @override
  String get themeColorSlateGrey => 'Gris ardoise';

  @override
  String get immersiveTabBar => 'Barre d\'onglets immersive';

  @override
  String get immersiveTabBarDescription =>
      'Affiche la barre au mouvement de la souris, la cache après 3 secondes d\'inactivité';

  @override
  String get collapseButtonsInLandscapeLyrics =>
      'Réduire les boutons en mode paroles paysage';

  @override
  String get collapseButtonsInLandscapeLyricsDescription =>
      'Réduit les 7 boutons, aligne le titre à gauche et ajoute des boutons à droite en mode paroles paysage';

  @override
  String get sampleStride => 'Pas d\'échantillonnage';

  @override
  String get sampleStrideDescription =>
      'Plus la valeur est grande, plus l\'analyse est rapide mais moins précise (défaut: 4)';

  @override
  String get waveformSegments => 'Segments de forme d\'onde';

  @override
  String get waveformSegmentsDescription =>
      'Nombre de barres de forme d\'onde à afficher (défaut: 80)';

  @override
  String get showDeveloperOptions => 'Afficher les options développeur';

  @override
  String get playbackBackground => 'Arrière-plan de lecture';

  @override
  String get playbackRadialGradient => 'Dégradé radial sombre central';

  @override
  String get blurIntensity => 'Intensité du flou';

  @override
  String get blurredArtwork => 'Pochette floutée (défaut)';

  @override
  String get dynamicMesh => 'Maillage dynamique';

  @override
  String get solidColor => 'Couleur unie';

  @override
  String get customImage => 'Image personnalisée';

  @override
  String get presetColors => 'Couleurs prédéfinies';

  @override
  String get customColor => 'Couleur personnalisée';

  @override
  String get uploadImage => 'Sélectionner une image';

  @override
  String get normalOpacity => 'Opacité de la couche sombre normale';

  @override
  String get lyricsOpacity => 'Opacité de la couche sombre des paroles';

  @override
  String get chooseImageError => 'Échec de la sélection de l\'image';

  @override
  String get noImageSelected => 'Aucune image sélectionnée';

  @override
  String get unknown => 'Inconnu';

  @override
  String get playlistModeSingle => 'Piste unique';

  @override
  String get playlistModeSingleLoop => 'Piste unique en boucle';

  @override
  String get playlistModeQueue => 'Liste de lecture';

  @override
  String get playlistModeQueueLoop => 'Liste en boucle';

  @override
  String get playlistModeAutoQueueLoop => 'Liste automatique en boucle';

  @override
  String get visualizer => 'Visualiseur';

  @override
  String get previous => 'Précédent';

  @override
  String get next => 'Suivant';

  @override
  String get pause => 'Pause';

  @override
  String get autoMode => 'Mode automatique';

  @override
  String get advancedOptions => 'Options avancées';

  @override
  String get spectrumQuantity => 'Quantité de spectre';

  @override
  String get speed => 'Vitesse';

  @override
  String get quantityHigh => 'Élevée';

  @override
  String get quantityMedium => 'Moyenne';

  @override
  String get quantityLow => 'Faible';

  @override
  String get speedFast => 'Rapide';

  @override
  String get speedMedium => 'Moyenne';

  @override
  String get speedSlow => 'Lente';

  @override
  String get portraitFrequencyGroups => 'Quantité de spectre portrait';

  @override
  String get landscapeFrequencyGroups => 'Quantité de spectre paysage';

  @override
  String get portraitGap => 'Espacement portrait';

  @override
  String get landscapeGap => 'Espacement paysage';

  @override
  String get enableWaveformProgressBar =>
      'Activer la barre de progression ondulée';

  @override
  String get enableWaveformProgressBarDescription =>
      'Utiliser la forme d\'onde complète au lieu du curseur standard';

  @override
  String get waveformLongPressSeekSpeed => 'Vitesse d\'avance appui long';

  @override
  String get waveformLongPressSeekSpeedDescription =>
      'Vitesse de lecture en maintenant le côté droit de la barre d\'onde (×)';

  @override
  String get enableWaveformLongPressSeek =>
      'Activer l\'avance rapide par appui long';

  @override
  String get enableWaveformLongPressSeekDescription =>
      'Maintenez le côté droit de la barre d\'onde pour une lecture accélérée';

  @override
  String get clearWaveformCache => 'Vider le cache des formes d\'onde';

  @override
  String get clearWaveformCacheDescription =>
      'Effacer les données de forme d\'onde en cache de la base de données et recalculer';

  @override
  String get waveformCacheCleared => 'Cache des formes d\'onde effacé';

  @override
  String get storageAndCache => 'Stockage et cache';

  @override
  String get remoteAudioCache => 'Cache audio distant';

  @override
  String get remoteAudioCacheDescription =>
      'Cache local pour le streaming et le préchargement Navidrome et WebDAV';

  @override
  String get remoteCacheLimit => 'Limite du cache distant';

  @override
  String get remotePrefetchCount => 'Nombre de pistes distantes préchargées';

  @override
  String get remotePrefetchCountDescription =>
      'Télécharger à l\'avance les pistes distantes de la file d\'attente pour une lecture fluide';

  @override
  String get clearRemoteCache => 'Vider le cache distant';

  @override
  String get remoteCacheCleared => 'Cache audio distant vidé';

  @override
  String get unlimited => 'Illimité';

  @override
  String get off => 'Désactivé';

  @override
  String get randomMode => 'Mode aléatoire';

  @override
  String get randomHistory => 'Historique aléatoire';

  @override
  String get randomRange => 'Plage aléatoire';

  @override
  String get randomMethod => 'Méthode aléatoire';

  @override
  String get currentQueue => 'File actuelle';

  @override
  String get globalRange => 'Global (toutes les listes)';

  @override
  String get completeRandom => 'Aléatoire complet';

  @override
  String get shuffleRandom => 'Mélange aléatoire';

  @override
  String get randomQueue => 'File aléatoire';

  @override
  String get notSelected => 'Aucune musique sélectionnée';

  @override
  String get saveTagsToFile => 'Sauvegarder les étiquettes dans le fichier';

  @override
  String get saveCurrentTagsToFile =>
      'Sauvegarder les étiquettes de la chanson actuelle';

  @override
  String get saveQueueTagsToFile =>
      'Sauvegarder toutes les étiquettes de la file';

  @override
  String get tagsSaved => 'Étiquettes sauvegardées avec succès';

  @override
  String tagsSavedCount(Object count) {
    return 'Étiquettes sauvegardées ($count chansons)';
  }

  @override
  String get tagsSaveFailed => 'Échec de la sauvegarde des étiquettes';

  @override
  String tagsSaveFailedCount(Object count) {
    return 'Échec de la sauvegarde de $count chansons';
  }

  @override
  String unsupportedFormat(Object count) {
    return '$count chansons ont un format non pris en charge (OGG/Opus)';
  }

  @override
  String get unsupportedFormatSingle =>
      'Ce format (OGG/Opus) ne prend pas en charge la sauvegarde des étiquettes';

  @override
  String get savingTags => 'Sauvegarde des étiquettes...';

  @override
  String get noModifiedTagsToSave => 'Aucune étiquette modifiée à sauvegarder';

  @override
  String get clearPlaylist => 'Vider la liste';

  @override
  String get copyTitle => 'Copier le titre';

  @override
  String get transcodeAction => 'Transcoder';

  @override
  String get transcodeSectionTitle => 'Transcodage audio';

  @override
  String get transcodeSectionDescription =>
      'Définir le format de sortie par défaut et la qualité prédéfinie.';

  @override
  String get transcodeDefaultFormat => 'Format de sortie par défaut';

  @override
  String get transcodeDefaultQuality => 'Qualité prédéfinie par défaut';

  @override
  String get transcodeTitle => 'Transcodage audio';

  @override
  String transcodeSongCount(int count) {
    return '$count chansons';
  }

  @override
  String transcodeCompletedCount(int count) {
    return '$count tâches de transcodage terminées';
  }

  @override
  String transcodeCompletedWithFailures(int success, int total, int failed) {
    return '$success/$total tâches terminées, $failed échouées';
  }

  @override
  String get transcodeFailedGeneric => 'Échec du transcodage';

  @override
  String get transcodePreparing => 'Préparation du transcodage...';

  @override
  String transcodeProgress(int current, int total) {
    return 'Transcodage $current/$total';
  }

  @override
  String get transcoding => 'Transcodage en cours...';

  @override
  String get startTranscode => 'Démarrer le transcodage';

  @override
  String transcodeEngine(Object engine) {
    return 'Moteur : $engine';
  }

  @override
  String get transcodeUsingSystemFfmpeg =>
      'Utilisation de ffmpeg depuis le PATH système.';

  @override
  String transcodeUsingCustomFfmpeg(Object path) {
    return 'Utilisation de ffmpeg personnalisé : $path';
  }

  @override
  String get transcodeFormat => 'Format de sortie';

  @override
  String get transcodeQualityPreset => 'Préréglage de qualité';

  @override
  String get transcodeQualityLow => 'Faible';

  @override
  String get transcodeQualityMedium => 'Moyenne';

  @override
  String get transcodeQualityHigh => 'Élevée';

  @override
  String get transcodeQualityExtreme => 'Maximale';

  @override
  String get transcodeLosslessPresetHint =>
      'Ce format sans perte n\'utilise pas de niveaux de qualité ni de mode de débit.';

  @override
  String get transcodeAdvancedOptions => 'Options avancées';

  @override
  String get transcodeAdvancedCustomized =>
      'Paramètres avancés modifiés manuellement';

  @override
  String get transcodeAdvancedFollowingPreset =>
      'Les paramètres avancés suivent le préréglage actuel';

  @override
  String get transcodeLosslessAdvancedHint =>
      'Ce format sans perte ne conserve que les options liées à la source.';

  @override
  String get transcodeBitRateInvalid =>
      'Veuillez entrer un débit binaire valide';

  @override
  String get transcodeBitRate => 'Débit binaire';

  @override
  String get transcodeBitRateMode => 'Mode de contrôle du débit';

  @override
  String get transcodeEncodingEngine => 'Moteur d\'encodage';

  @override
  String get transcodeSystemEncoder => 'Media3 (système)';

  @override
  String get transcodeFfmpegRustEncoder => 'FFmpeg (Rust)';

  @override
  String get transcodeAacEncoder => 'Encodeur AAC';

  @override
  String get transcodeSampleRate => 'Fréquence d\'échantillonnage';

  @override
  String get transcodeChannels => 'Canaux';

  @override
  String get transcodeResetToPreset => 'Réinitialiser au préréglage actuel';

  @override
  String get transcodeResetLosslessOptions =>
      'Réinitialiser les options sans perte';

  @override
  String get transcodeOutputDirectory => 'Répertoire de sortie';

  @override
  String get transcodeOutputPreview => 'Aperçu';

  @override
  String get transcodeChooseDirectory => 'Choisir un répertoire';

  @override
  String get transcodeUseSourceDirectory => 'Utiliser le répertoire source';

  @override
  String get transcodeKeepSource => 'Conserver le fichier source';

  @override
  String get transcodeMono => 'Mono';

  @override
  String get transcodeStereo => 'Stéréo';

  @override
  String get openFolderLocation => 'Ouvrir l\'emplacement du dossier';

  @override
  String get songTagsSavedToSourceFileAndApp =>
      'Étiquettes sauvegardées dans le fichier source et l\'application';

  @override
  String get songTagsSavedToApp =>
      'Étiquettes sauvegardées dans l\'application';

  @override
  String get durationZero => '0:00';

  @override
  String get generateLyrics => 'Générer les paroles';

  @override
  String get generateTimeline => 'Générer la chronologie';

  @override
  String get queueGenerateLyrics => 'Mettre en file de génération';

  @override
  String get pauseAutoScroll => 'Pause du défilement automatique';

  @override
  String get resumeAutoScroll => 'Reprendre le défilement automatique';

  @override
  String get translateLyrics => 'Traduire les paroles';

  @override
  String get clearLyricsCache => 'Vider le cache des paroles actuelles';

  @override
  String get clearTranslationCache => 'Vider le cache de traduction actuel';

  @override
  String get requery => 'Requêter à nouveau';

  @override
  String get sleepTimerTitle => 'Minuteur de sommeil';

  @override
  String get sleepTimerDescription =>
      'Choisissez un compte à rebours. La lecture se mettra en pause à la fin.';

  @override
  String get sleepTimerRunningTitle => 'Minuteur de sommeil en cours';

  @override
  String get sleepTimerRunningDescription =>
      'La lecture se mettra automatiquement en pause à la fin du compte à rebours.';

  @override
  String get sleepTimerStopAfterCurrentSong =>
      'Arrêter après la dernière chanson';

  @override
  String get remainingTime => 'Temps restant';

  @override
  String get startCountdown => 'Démarrer le compte à rebours';

  @override
  String get end => 'Fin';

  @override
  String get equalizer => 'Égaliseur';

  @override
  String get equalizerEnabledStatus => 'Réglage haute fidélité activé';

  @override
  String get equalizerDisabledStatus => 'Désactivé';

  @override
  String get eqPresetFlat => 'Plat';

  @override
  String get eqPresetPop => 'Pop';

  @override
  String get eqPresetRock => 'Rock';

  @override
  String get eqPresetVocal => 'Voix';

  @override
  String get eqPresetBassBoost => 'Amplification des basses';

  @override
  String get eqPresetElectronic => 'Électronique';

  @override
  String get eqPresetJazz => 'Jazz';

  @override
  String get eqPresetClassical => 'Classique';

  @override
  String get eqPresetAcoustic => 'Acoustique';

  @override
  String get eqPresetDance => 'Dance';

  @override
  String get eqPresetHifi => 'Hi-Fi';

  @override
  String get eqPresets => 'Préréglages d\'égaliseur';

  @override
  String get customPresets => 'Préréglages personnalisés';

  @override
  String get builtInPresets => 'Préréglages intégrés';

  @override
  String get saveAsPreset => 'Enregistrer comme préréglage';

  @override
  String get saveCurrentAsPreset =>
      'Enregistrer le réglage actuel comme nouveau préréglage';

  @override
  String get enterPresetName => 'Entrez le nom du préréglage';

  @override
  String get presetName => 'Nom du préréglage';

  @override
  String get presetNameAlreadyExists => 'Le nom du préréglage existe déjà';

  @override
  String get presetNameCannotBeEmpty =>
      'Le nom du préréglage ne peut pas être vide';

  @override
  String get presetSaved => 'Préréglage enregistré';

  @override
  String get updatePreset => 'Mettre à jour le préréglage';

  @override
  String get presetUpdated => 'Préréglage mis à jour';

  @override
  String get renamePreset => 'Renommer le préréglage';

  @override
  String get presetRenamed => 'Préréglage renommé';

  @override
  String get saveAsNewPreset => 'Enregistrer sous un nouveau préréglage';

  @override
  String get updateWithCurrentSettings => 'Écraser avec les réglages actuels';

  @override
  String get modified => 'Modifié';

  @override
  String get deletePreset => 'Supprimer le préréglage';

  @override
  String get deletePresetConfirm =>
      'Voulez-vous vraiment supprimer ce préréglage ?';

  @override
  String get custom => 'Personnalisé';

  @override
  String get noCustomPresets => 'Aucun préréglage personnalisé pour le moment';

  @override
  String get savePresetPrompt =>
      'Enregistrer les gains de bande EQ actuels, l\'amplification des basses et le gain du préampli';

  @override
  String get effects => 'Effets';

  @override
  String get playbackSpeed => 'Vitesse de lecture';

  @override
  String get playbackSpeedLimit5x => 'Limite de vitesse 5x';

  @override
  String get normal => 'Normal';

  @override
  String get bassBoost => 'Amplification des basses';

  @override
  String get preampGain => 'Gain du préampli';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get close => 'Fermer';

  @override
  String get timelineAdjustmentTitle => 'Ajuster la chronologie manuellement';

  @override
  String get timelineAdjustmentDescription =>
      'Glisser vers la droite retarde les paroles, vers la gauche les avance.';

  @override
  String timelineOffsetEarlier(Object seconds) {
    return '${seconds}s en avance';
  }

  @override
  String timelineOffsetLater(Object seconds) {
    return '${seconds}s en retard';
  }

  @override
  String get timelineOffsetCurrent => 'Décalage actuel : 0,0 s';

  @override
  String get enterAcoustidApiKeyTitle => 'Saisir la clé API AcoustID';

  @override
  String get acoustidApiKeyDescription =>
      'Utilisé pour l\'empreinte audio. Laisser vide pour restaurer la clé intégrée.';

  @override
  String get acoustidApiKeyHint => 'Collez votre clé API AcoustID';

  @override
  String get apiKey => 'Clé API';

  @override
  String get save => 'Sauvegarder';

  @override
  String get enterLyricsTitle => 'Saisir les paroles';

  @override
  String get lyricsInputHint =>
      'Collez ou tapez les paroles ici. Le texte multiligne est pris en charge.';

  @override
  String get enterGoogleAiStudioApiKeyTitle =>
      'Saisir la clé API Google AI Studio';

  @override
  String get googleAiStudioApiKeyDescription =>
      'Utilisé pour la génération de paroles, la chronologie et la traduction.';

  @override
  String get pasteGoogleAiStudioApiKey => 'Coller la clé API Google AI Studio';

  @override
  String get enterOpenRouterApiKeyTitle => 'Saisir la clé API OpenRouter';

  @override
  String get openRouterApiKeyDescription =>
      'Utilisé pour la génération de paroles, de chronologie et la traduction de paroles dans OpenRouter.';

  @override
  String get pasteOpenRouterApiKey => 'Coller la clé API OpenRouter';

  @override
  String get enterGeminiApiKeyTitle => 'Saisir la clé API Gemini';

  @override
  String get geminiApiKeyDescription =>
      'Utilisé pour la traduction des paroles.';

  @override
  String get pasteGeminiApiKey => 'Coller la clé API Gemini';

  @override
  String get testConnection => 'Tester la connexion';

  @override
  String get enterApiKey => 'Veuillez saisir une clé API.';

  @override
  String get testingConnection => 'Test de connexion...';

  @override
  String get getKey => 'Obtenir une clé';

  @override
  String get editSongTagsTitle => 'Modifier les étiquettes de la chanson';

  @override
  String get changeArtwork => 'Changer la pochette';

  @override
  String get clearArtwork => 'Effacer la pochette';

  @override
  String get editSongTagsDescription =>
      'Vous pouvez sauvegarder les modifications uniquement dans l\'application ou les écrire dans le fichier source.';

  @override
  String get artistLabel => 'Artiste';

  @override
  String get albumArtistLabel => 'Artiste de l\'album';

  @override
  String get albumLabel => 'Album';

  @override
  String get trackNumberLabel => 'Numéro de piste';

  @override
  String get trackNumberMustBeInteger =>
      'Le numéro de piste doit être un entier';

  @override
  String get leaveBlankKeepsCurrentValue =>
      'Laisser vide pour effacer ce champ';

  @override
  String get currentFileFormatCannotWriteBack =>
      'Ce format de fichier ne permet pas d\'écrire dans le fichier source.';

  @override
  String get leaveBlankDoesNotClearOriginalValue =>
      'Astuce : laisser un champ vide effacera sa valeur.';

  @override
  String get saveToApp => 'Sauvegarder dans l\'application';

  @override
  String get saveToSourceFileAndApp =>
      'Sauvegarder dans le fichier source et l\'application';

  @override
  String get saveToSourceFileFailed =>
      'Échec de la sauvegarde dans le fichier source. Vérifiez que le format prend en charge l\'écriture.';

  @override
  String get fileOccupiedByOtherApp =>
      'Le fichier est utilisé par une autre application';

  @override
  String get saveFailed =>
      'Échec de la sauvegarde. Veuillez réessayer plus tard.';

  @override
  String apiKeySaved(Object provider) {
    return 'Clé API $provider sauvegardée';
  }

  @override
  String get apiKeySavedAcoustid => 'Clé API AcoustID sauvegardée';

  @override
  String get generalSectionTitle => 'Interface et comportement';

  @override
  String get generalSectionDescription =>
      'Configurez l\'apparence, les interactions de lecture et le comportement des fenêtres système.';

  @override
  String get uiAppearanceGroup => 'Apparence et affichage';

  @override
  String get playbackBehaviorGroup => 'Lecture et interaction';

  @override
  String get systemWindowBehaviorGroup =>
      'Comportement de la fenêtre et du système';

  @override
  String get interfaceLanguage => 'Langue de l\'interface';

  @override
  String get interfaceLanguageDescription =>
      'Sélectionnez la langue d\'affichage de l\'application.';

  @override
  String get scanSectionTitle => 'Analyse';

  @override
  String get scanSectionDescription =>
      'Ces options contrôlent la façon dont l\'analyse de la bibliothèque traite les fichiers audio.';

  @override
  String get skipShortAudioDuringScan =>
      'Ignorer l\'audio court lors de l\'analyse';

  @override
  String get skipShortAudioDuringScanDescription =>
      'L\'audio plus court que le seuil ne sera pas ajouté à la bibliothèque.';

  @override
  String get shortAudioScanThreshold => 'Seuil d\'audio court';

  @override
  String get shortAudioScanThresholdDescription =>
      'Les fichiers plus courts que cette durée seront ignorés.';

  @override
  String shortAudioScanThresholdValue(Object seconds) {
    return '$seconds s';
  }

  @override
  String get shortcutSettingsTitle => 'Raccourcis personnalisés';

  @override
  String get shortcutSettingsDescription =>
      'Cliquez pour redéfinir et enregistrer les raccourcis des actions du lecteur.';

  @override
  String get edit => 'Modifier';

  @override
  String get lyricsSectionTitle => 'Paroles';

  @override
  String get lyricsSectionDescription =>
      'Ces réglages n\'affectent que la génération de paroles et de chronologie.';

  @override
  String get lyricsTranslationTargetLanguageLabel =>
      'Langue cible de traduction';

  @override
  String get lyricsTranslationTargetLanguageDescription =>
      'Par défaut, suit la langue du système, ou choisissez manuellement.';

  @override
  String get lyricsSaveMethodLabel => 'Lieu de sauvegarde des paroles';

  @override
  String get lyricsSaveMethodDescription =>
      'Choisissez où les paroles sont sauvegardées lors de l\'écriture.';

  @override
  String get lyricsSaveMethodOriginal => 'Comme la source';

  @override
  String get lyricsSaveMethodEmbedded => 'Incrusté';

  @override
  String get lyricsSaveMethodLrcFile => 'Fichier LRC';

  @override
  String get lyricsStyleLabel => 'Style de panneau de paroles';

  @override
  String get lyricsStyleDescription =>
      'Choisissez le style d\'affichage pour le panneau de paroles.';

  @override
  String get lyricsStyleTraditional => 'Traditionnel';

  @override
  String get lyricsStyleApple => 'Focus ligne par ligne';

  @override
  String get resumeLyricsSync => 'Reprendre la synchronisation';

  @override
  String get followSystemLanguage => 'Suivre le système';

  @override
  String get autoSwitchLyricsProvider =>
      'Changement automatique de fournisseur';

  @override
  String get autoSwitchLyricsProviderEnabledDesc =>
      'Google AI Studio est essayé en premier. Si le modèle principal et le modèle de secours échouent tous deux avec des erreurs 429 ou 5xx, l\'application bascule automatiquement vers OpenRouter et continue d\'essayer.';

  @override
  String get autoSwitchLyricsProviderDisabledDesc =>
      'Vous avez besoin des clés API Google AI Studio et OpenRouter pour activer le changement automatique.';

  @override
  String get lyricsAiProviderTitle => 'Fournisseur IA de paroles';

  @override
  String get lyricsAiProviderDescription =>
      'Cela n\'affecte que la génération de paroles et de chronologie. La traduction utilise toujours Google AI Studio.';

  @override
  String get googleAiStudioApiKeySaved =>
      'Clé API Google AI Studio sauvegardée';

  @override
  String get googleAiStudioApiKeyMissing =>
      'Aucune clé API Google AI Studio sauvegardée. La génération vous le rappellera.';

  @override
  String get openRouterApiKeySaved => 'Clé API OpenRouter sauvegardée';

  @override
  String get openRouterApiKeyMissing =>
      'Aucune clé API OpenRouter sauvegardée. La génération vous le rappellera.';

  @override
  String get apiKeySavedStatus => 'Sauvegardée';

  @override
  String get apiKeyMissingStatus => 'Non renseignée';

  @override
  String get platformApiKeysSectionTitle => 'Clés API de plateforme';

  @override
  String get fill => 'Remplir';

  @override
  String get modify => 'Modifier';

  @override
  String get geminiModelsSectionTitle => 'Sélectionner un modèle';

  @override
  String get geminiModelsSectionDescription =>
      'Ces modèles sont utilisés pour la génération de paroles, la chronologie et la traduction.';

  @override
  String get primaryModelLabel => 'Modèle principal';

  @override
  String get backupModelLabel => 'Modèle de secours';

  @override
  String get translationModelLabel => 'Modèle de traduction';

  @override
  String get fetching => 'Récupération...';

  @override
  String get fetchModelList => 'Récupérer la liste des modèles';

  @override
  String get restoreDefault => 'Restaurer les valeurs par défaut';

  @override
  String get acoustidSectionTitle => 'Empreinte audio';

  @override
  String get acoustidApiKeyTitle => 'Clé API AcoustID';

  @override
  String get acoustidApiKeyHelp =>
      'AcoustID est utilisé pour l\'empreinte audio. Utilisez votre propre clé API.';

  @override
  String get acoustidApiKeySaved => 'Clé API AcoustID sauvegardée';

  @override
  String get acoustidApiKeyDefault =>
      'La clé intégrée est actuellement utilisée. Remplacez-la par votre propre clé.';

  @override
  String get applyForApiKey =>
      'Obtenir une clé API : https://acoustid.org/new-application';

  @override
  String get queueTabBarFavoriteAdded => 'Ajouté aux favoris';

  @override
  String get queueTabBarFavoriteRemoved => 'Retiré des favoris';

  @override
  String get tagCompletion => 'Complétion des étiquettes';

  @override
  String get tagCompletionDescription =>
      'Faire correspondre les étiquettes avec les résultats AcoustID et MusicBrainz';

  @override
  String get goToSettings => 'Aller aux paramètres';

  @override
  String get searchReleaseTitles => 'Rechercher des titres de sortie';

  @override
  String get closeSearch => 'Fermer la recherche';

  @override
  String get refreshResults => 'Actualiser les résultats';

  @override
  String get filterMusicBrainzReleaseTitle =>
      'Filtrer les titres de sortie MusicBrainz';

  @override
  String get clearSearch => 'Effacer la recherche';

  @override
  String get localTitle => 'Titre local';

  @override
  String get queryConditions => 'Conditions de requête';

  @override
  String get musicBrainzLoading => 'Chargement de MusicBrainz';

  @override
  String get musicBrainzLoadingWithResults =>
      'Les résultats existants resteront dans le panneau';

  @override
  String get musicBrainzLoadingHint => 'Veuillez patienter';

  @override
  String get musicBrainzQueryFailed => 'Échec de la requête MusicBrainz';

  @override
  String get musicBrainzNetworkErrorHint =>
      'La requête a échoué, généralement en raison d\'un réseau instable ou d\'un délai d\'attente.';

  @override
  String get musicBrainzFilteredEmptyHint =>
      'Aucun titre de sortie contenant ce mot-clé sous les filtres actuels.';

  @override
  String get musicBrainzEmptyHint =>
      'MusicBrainz n\'a retourné aucun résultat. Essayez d\'assouplir les filtres.';

  @override
  String get musicBrainzEmptyMoreCompleteHint =>
      'Réessayez plus tard ou vérifiez les informations du titre/artiste.';

  @override
  String get retry => 'Réessayer';

  @override
  String get noMatchingRelease => 'Aucune sortie correspondante trouvée';

  @override
  String get noMatchingResults => 'Aucun résultat correspondant';

  @override
  String get networkConnectionFailed => 'Échec de la connexion réseau';

  @override
  String get searchAgain => 'Rechercher à nouveau';

  @override
  String get acoustidRecognitionRecords =>
      'Enregistrements de reconnaissance AcoustID';

  @override
  String get musicBrainzRecordings => 'Enregistrements MusicBrainz';

  @override
  String get noExpandableReleaseGroups => 'Aucun groupe de sorties extensible';

  @override
  String get noExpandableReleases => 'Aucune sortie extensible';

  @override
  String get noMatchingResultHint =>
      'Réessayez plus tard ou vérifiez les informations du titre/artiste.';

  @override
  String releaseCountLabel(int count) {
    return '$count versions de sortie';
  }

  @override
  String recordingCountLabel(int count) {
    return '$count enregistrements';
  }

  @override
  String trackCountShort(int count) {
    return '$count pistes';
  }

  @override
  String scoreLabel(int score) {
    return 'Score $score';
  }

  @override
  String matchScoreLabel(int score) {
    return 'Correspondance $score%';
  }

  @override
  String get editQueryCondition => 'Modifier la condition de requête';

  @override
  String get enterNewQueryText => 'Entrez un nouveau texte de requête';

  @override
  String get durationLabel => 'Durée';

  @override
  String get customShortcuts => 'Raccourcis personnalisés';

  @override
  String get pressShortcutCombo => 'Appuyez sur la combinaison de touches';

  @override
  String get clickToRecord => 'Cliquez pour définir';

  @override
  String get searchingLyrics => 'Recherche de paroles';

  @override
  String get noLyrics => 'Pas encore de paroles';

  @override
  String get providerLabel => 'Fournisseur';

  @override
  String get modelLabel => 'Modèle';

  @override
  String get unspecified => 'Non spécifié';

  @override
  String targetTimeLabel(String duration) {
    return 'Temps cible $duration';
  }

  @override
  String get songDeletedSkipped => 'Chanson supprimée, ignorée';

  @override
  String get songDeleted => 'Chanson supprimée';

  @override
  String get lyricsTaskUploading => 'Téléversement';

  @override
  String get lyricsTaskWaiting => 'En attente';

  @override
  String get lyricsTaskRequesting => 'Requête en cours';

  @override
  String get lyricsTaskGenerating => 'Génération en cours';

  @override
  String get lyricsTaskRetrying => 'Nouvelle tentative';

  @override
  String get lyricsTaskProcessing => 'Traitement en cours';

  @override
  String get unknownModel => 'Modèle inconnu';

  @override
  String selectedFolders(int count) {
    return '$count dossiers sélectionnés';
  }

  @override
  String foldersDeleted(int count) {
    return '$count dossiers supprimés';
  }

  @override
  String get persistentAccessDenied =>
      'Impossible de sauvegarder l\'accès à ce dossier. Veuillez le sélectionner à nouveau.';

  @override
  String get folderAddFailed => 'Échec de l\'ajout du dossier';

  @override
  String get sleepTimer => 'Minuteur de sommeil';

  @override
  String sleepTimerRemaining(Object duration) {
    return 'Minuteur de sommeil $duration';
  }

  @override
  String get unknownArtistOrAlbum => 'Inconnu';

  @override
  String get pressAgainToExit =>
      'Appuyez à nouveau pour quitter l\'application';

  @override
  String get tagCompletionSuccessWithCover =>
      'Étiquettes complétées et sauvegardées, pochette téléchargée';

  @override
  String get tagCompletionSuccess => 'Étiquettes complétées et sauvegardées';

  @override
  String get selectOnlineLyrics => 'Sélectionner des paroles en ligne';

  @override
  String get increaseLyricsFont => 'Augmenter la police des paroles';

  @override
  String get decreaseLyricsFont => 'Diminuer la police des paroles';

  @override
  String get restoreDefaultSize => 'Restaurer la taille par défaut';

  @override
  String get adjustLyricsFont => 'Ajuster la taille du texte';

  @override
  String get searchingOnlineLyrics => 'Recherche de paroles en ligne';

  @override
  String get onlineLyricsResults => 'Résultats de paroles en ligne';

  @override
  String get untitledLyrics => 'Paroles sans titre';

  @override
  String get hasTimeline => 'Avec chronologie';

  @override
  String get viewLyricsDetails => 'Voir les détails des paroles';

  @override
  String get lyricsDetails => 'Détails des paroles';

  @override
  String get lyricsContent => 'Contenu des paroles';

  @override
  String get noLyricsContent => 'Aucun contenu de paroles';

  @override
  String get queryContentLabel => 'Contenu';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String dropAddedSongs(int addedCount) {
    return '$addedCount chansons ajoutées';
  }

  @override
  String dropAddedSongsWithExisting(int addedCount, int existingCount) {
    return '$addedCount chansons ajoutées, $existingCount existaient déjà';
  }

  @override
  String get copyCover => 'Copier la pochette dans le presse-papier';

  @override
  String get copyCoverSuccess => 'Pochette copiée dans le presse-papier';

  @override
  String get searchLyricsPlaceholder =>
      'Entrez le titre, l\'artiste ou les paroles pour rechercher';

  @override
  String get share => 'Partager';

  @override
  String get windowsSettingsTitle => 'Paramètres Windows';

  @override
  String get fileAssociationTitle => 'Association de fichiers';

  @override
  String get fileAssociationDescription =>
      'Associer les formats musicaux courants (mp3, flac, wav...) à cette application.';

  @override
  String get associateButton => 'Associer';

  @override
  String get disassociateButton => 'Dissocier';

  @override
  String get associationSuccess =>
      'Association réussie ! Si le double-clic ne fonctionne pas, sélectionnez Vynody dans les applications par défaut.';

  @override
  String get disassociationSuccess =>
      'Association de fichiers supprimée avec succès.';

  @override
  String associationFailed(Object error) {
    return 'Échec de l\'association : $error';
  }

  @override
  String get onboardingTitle => 'Bienvenue sur Vynody';

  @override
  String get onboardingSubtitle =>
      'Quelques étapes simples pour commencer votre voyage musical.';

  @override
  String get onboardingStepFileAssociation => 'Associer les types de fichiers';

  @override
  String get onboardingFileAssociationDesc =>
      'Associez les formats musicaux à Vynody pour une lecture en double-clic.';

  @override
  String get onboardingFileAssociationTip =>
      'Après l\'association, le système peut afficher un menu. Choisissez \'Vynody\' et \'Toujours utiliser\'.';

  @override
  String get onboardingStepRootDirectory => 'Ajouter un dossier de musique';

  @override
  String get onboardingRootDirectoryDesc =>
      'Sélectionnez le dossier contenant votre musique. Vynody construira votre bibliothèque automatiquement.';

  @override
  String get onboardingAndroidPermissionTip =>
      'Remarque : Sur Android, l\'importation et l\'analyse de la musique locale nécessitent d\'accorder l\'autorisation d\'accès à la bibliothèque multimédia. Appuyer sur [Sélectionner le dossier] demandera l\'autorisation, veuillez l\'autoriser.';

  @override
  String get onboardingSelectDirectory => 'Sélectionner un dossier';

  @override
  String get onboardingSuccessTitle => 'Tout est prêt !';

  @override
  String get onboardingSuccessDesc =>
      'Bibliothèque ajoutée avec succès. Profitez de votre musique !';

  @override
  String get onboardingStartButton => 'Entrer dans Vynody';

  @override
  String get onboardingSkip => 'Configurer plus tard';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingBack => 'Retour';

  @override
  String get resetOnboarding => 'Réinitialiser le guide de bienvenue';

  @override
  String get resetOnboardingDesc =>
      'Le guide de bienvenue sera réaffiché au prochain démarrage.';

  @override
  String get songProperties => 'Propriétés de la chanson';

  @override
  String get failedToLoadDetails => 'Impossible de charger les détails';

  @override
  String get remoteAudioNotCachedHint =>
      'Ce morceau est dans le cloud et n\'est pas mis en cache localement. Écoutez-le ou téléchargez-le pour afficher les propriétés audio complètes.';

  @override
  String get noPropertiesAvailable => 'Aucune propriété disponible';

  @override
  String get detailFilePath => 'Chemin du fichier';

  @override
  String get detailFormat => 'Format';

  @override
  String get detailCodec => 'Codec';

  @override
  String get detailDuration => 'Durée';

  @override
  String get detailFileSize => 'Taille du fichier';

  @override
  String get detailBitrate => 'Débit binaire';

  @override
  String get detailSampleRate => 'Fréquence d\'échantillonnage';

  @override
  String get detailChannels => 'Canaux';

  @override
  String get detailBitDepth => 'Profondeur de bits';

  @override
  String get detailMono => 'Mono';

  @override
  String get detailStereo => 'Stéréo';

  @override
  String detailChannelsCount(int count) {
    return '$count canaux';
  }

  @override
  String get localNetworkPermissionDeniedTitle =>
      'Accès au réseau local restreint';

  @override
  String get localNetworkPermissionDeniedMessage =>
      'Aucune adresse IP locale disponible ou l\'accès au réseau local a été refusé.\n\nVeuillez vérifier les points suivants :\n1. Assurez-vous que votre appareil est connecté à un réseau Wi-Fi ou local.\n2. Assurez-vous que l\'application est autorisée à accéder au réseau local dans les paramètres système :\n   - iOS/macOS : Allez dans Réglages > Confidentialité et sécurité > Réseau local, et activez Vynody.\n   - Windows : Assurez-vous d\'être connecté et vérifiez que le pare-feu Windows autorise l\'accès à Vynody.';

  @override
  String get localNetworkPermissionWindowsMessage =>
      'Aucune adresse IP locale détectée.\n\nVérifiez :\n1. Connexion au réseau local.\n2. Vérifiez le pare-feu Windows pour autoriser Vynody.';

  @override
  String get openSettingsButton => 'Ouvrir les paramètres';

  @override
  String get closeButton => 'Fermer';

  @override
  String get copyTranslationResults => 'Copier les résultats de traduction';

  @override
  String get writeLyricsToFile => 'Écrire les paroles dans le fichier';

  @override
  String get selectLyricSource => 'Choisir la source des paroles';

  @override
  String get regenerateLyrics => 'Régénérer les paroles';

  @override
  String get regenerateLyricsConfirmation =>
      'Les paroles actuelles seront effacées et régénérées. Continuer ?';

  @override
  String get regenerateTimeline => 'Régénérer la chronologie';

  @override
  String get regenerateTimelineConfirmation =>
      'La chronologie actuelle sera effacée et régénérée. Continuer ?';

  @override
  String get retranslateLyrics => 'Retraduire les paroles';

  @override
  String get retranslateLyricsConfirmation =>
      'La traduction actuelle sera effacée et retraduite. Continuer ?';

  @override
  String get translationCopiedToClipboard =>
      'Résultats de traduction copiés dans le presse-papier';

  @override
  String get writingLyrics => 'Écriture des paroles...';

  @override
  String get lyricsWrittenToFile =>
      'Paroles écrites dans le fichier avec succès';

  @override
  String get writeLyricsFailed => 'Échec de l\'écriture des paroles';

  @override
  String get externalLrcFile => 'Fichier LRC externe';

  @override
  String get embeddedLyrics => 'Paroles intégrées';

  @override
  String get manuallyAdjustedLyrics => 'Paroles ajustées manuellement';

  @override
  String get lrclibOnlineLyrics => 'Paroles en ligne LrcLib';

  @override
  String get aiGeneratedLyrics => 'Paroles générées par IA';

  @override
  String get matchScore => 'Correspondance';

  @override
  String get untitledRelease => 'Sortie sans titre';

  @override
  String get localSongFileNotFoundForGeneration =>
      'Le fichier local n\'existe pas. Impossible de générer les paroles.';

  @override
  String get localSongFileNotFoundForTimeline =>
      'Le fichier local n\'existe pas. Impossible de générer la chronologie.';

  @override
  String get noLyricsForTimelineGeneration =>
      'Aucune parole disponible pour générer la chronologie.';

  @override
  String get noLyricsAvailableForTranslation =>
      'Aucune parole disponible pour la traduction.';

  @override
  String get noCurrentSongAvailable => 'Aucune chanson en cours.';

  @override
  String get invalidTargetLanguage => 'Langue cible invalide.';

  @override
  String get songAlreadyQueuedForTranslation =>
      'La chanson est déjà en file d\'attente pour la traduction.';

  @override
  String get songAlreadyQueuedForGeneration =>
      'La chanson est déjà en file d\'attente pour la génération.';

  @override
  String get songNoLongerExistsForTranslation =>
      'La chanson n\'existe plus. Impossible de traduire.';

  @override
  String get generationFailed => 'Échec de la génération.';

  @override
  String get generatingLyrics => 'Génération des paroles';

  @override
  String get generatingTimeline => 'Génération de la chronologie';

  @override
  String get regeneratingLyrics => 'Régénération des paroles';

  @override
  String get translatingLyrics => 'Traduction des paroles';

  @override
  String get transcodingSongFile => 'Transcodage du fichier audio';

  @override
  String get uploadingSongFile => 'Téléversement du fichier audio';

  @override
  String get fileUploadedWaitingForReadiness =>
      'Fichier téléversé, en attente de disponibilité';

  @override
  String get waitingForFileReadiness =>
      'En attente de disponibilité du fichier';

  @override
  String get requestingModelResponse => 'Demande de réponse du modèle';

  @override
  String retryingTaskKindGeneration(Object taskKind) {
    return 'Nouvelle tentative de génération $taskKind';
  }

  @override
  String get retrying => 'Nouvelle tentative';

  @override
  String get processing => 'Traitement';

  @override
  String get timeline => 'chronologie';

  @override
  String get lyrics => 'paroles';

  @override
  String lyricGenerationError(Object error) {
    return 'Erreur lors de la génération des paroles : $error';
  }

  @override
  String timelineGenerationError(Object error) {
    return 'Erreur lors de la génération de la chronologie : $error';
  }

  @override
  String get unknownGenerationError =>
      'Erreur inconnue lors de la génération des paroles.';

  @override
  String get unknownTimelineGenerationError =>
      'Erreur inconnue lors de la génération de la chronologie.';

  @override
  String get unknownTranslationError =>
      'Erreur inconnue lors de la traduction des paroles.';

  @override
  String get unknownError => 'Erreur inconnue';

  @override
  String get modelRefusedToGenerateLyrics =>
      'Le modèle a refusé de générer les paroles.';

  @override
  String get modelRefusedToGenerateTimeline =>
      'Le modèle a refusé de générer la chronologie.';

  @override
  String get doubaoPreUploadTranscodingFailed =>
      'Échec du transcodage audio avant le téléversement Doubao.';

  @override
  String get doubaoTempTranscodeNotInTempDir =>
      'Le fichier temporaire Doubao n\'est pas dans le dossier temp.';

  @override
  String get doubaoEmptyStreamingResponse =>
      'Doubao a retourné une réponse de flux vide.';

  @override
  String get doubaoEmptyResponse => 'Doubao a retourné une réponse vide.';

  @override
  String get geminiEmptyStreamingResponse =>
      'Gemini a retourné une réponse de flux vide.';

  @override
  String get geminiEmptyResponse => 'Gemini a retourné une réponse vide.';

  @override
  String get openRouterEmptyStreamingResponse =>
      'OpenRouter a retourné une réponse de flux vide.';

  @override
  String get openRouterEmptyResponse =>
      'OpenRouter a retourné une réponse vide.';

  @override
  String get deepseekEmptyStreamingResponse =>
      'DeepSeek a retourné une réponse de flux vide.';

  @override
  String get deepseekEmptyResponse => 'DeepSeek a retourné une réponse vide.';

  @override
  String get customProviderEmptyStreamingResponse =>
      'Le fournisseur personnalisé a retourné une réponse de flux vide.';

  @override
  String get customProviderEmptyResponse =>
      'Le fournisseur personnalisé a retourné une réponse vide.';

  @override
  String get fileUploadFailed => 'Échec du téléversement. Veuillez réessayer.';

  @override
  String get uploadedFileNotReady =>
      'Le fichier téléversé n\'est pas prêt. Réessayez plus tard.';

  @override
  String get audioTranscodingFailed => 'Échec du transcodage audio.';

  @override
  String get tempTranscodeNotInTempDir =>
      'Le fichier temporaire n\'est pas dans le dossier temp.';

  @override
  String get networkRequestFailedCheckProxy =>
      'Échec de la requête réseau. Vérifiez votre connexion et proxy.';

  @override
  String get quotaExhaustedToday =>
      'Le quota d\'aujourd\'hui est épuisé. Réessayez demain.';

  @override
  String get googleAiHeavyLoad =>
      'Google AI est surchargé et temporairement indisponible.';

  @override
  String lyricsGenerationFailedWithError(Object error) {
    return 'Échec de la génération des paroles : $error';
  }

  @override
  String missingApiKeyForAction(Object action, Object providerName) {
    return 'Clé API pour $providerName introuvable. Impossible de $action.';
  }

  @override
  String locationNotSupportedForModel(String modelName) {
    return 'L\'emplacement n\'est pas pris en charge pour $modelName';
  }

  @override
  String get googleServerFlaky =>
      'Google a des difficultés. Réessayez, cela pourrait fonctionner.';

  @override
  String get translateLyricsAction => 'traduire les paroles';

  @override
  String get generateLyricsAction => 'générer les paroles';

  @override
  String get generateTimelineAction => 'générer la chronologie';

  @override
  String get deepseekOnlyTranslation =>
      'DeepSeek est uniquement disponible pour la traduction de paroles.';

  @override
  String get customProviderOnlyTranslation =>
      'Le fournisseur personnalisé est uniquement disponible pour la traduction.';

  @override
  String get customProviderNoBaseUrl =>
      'L\'URL de base du fournisseur personnalisé n\'est pas configurée.';

  @override
  String get pleaseEnterApiKey => 'Veuillez entrer une clé API.';

  @override
  String get connectionSuccessVerificationPassed =>
      'Connexion réussie, vérification passée.';

  @override
  String connectionSuccessDetectedModels(Object count) {
    return 'Connexion réussie, $count modèles détectés.';
  }

  @override
  String testFailedWithStatus(Object message, Object statusCode) {
    return 'Échec du test ($statusCode) : $message';
  }

  @override
  String get testFailedCheckNetworkOrApiKey =>
      'Échec du test. Vérifiez le réseau ou la clé API.';

  @override
  String testFailedStatusCheckApiKey(Object statusCode) {
    return 'Échec du test ($statusCode). Vérifiez la validité de la clé API.';
  }

  @override
  String get enterGoogleAiStudioApiKeyFirst =>
      'Veuillez d\'abord entrer une clé API Google AI Studio.';

  @override
  String get enterDoubaoApiKeyFirst =>
      'Veuillez d\'abord entrer une clé API Doubao.';

  @override
  String get enterDeepseekApiKeyFirst =>
      'Veuillez d\'abord entrer une clé API DeepSeek.';

  @override
  String get enterCustomApiKeyAndBaseUrl =>
      'Veuillez d\'abord entrer la clé API personnalisée et l\'URL de base.';

  @override
  String fetchedCountModels(Object count) {
    return '$count modèles récupérés.';
  }

  @override
  String requestFailedWithStatus(Object message, Object statusCode) {
    return 'Requête échouée ($statusCode) : $message';
  }

  @override
  String get requestFailedCheckNetwork =>
      'Requête échouée. Vérifiez le réseau.';

  @override
  String requestFailedStatus(Object statusCode) {
    return 'Requête échouée ($statusCode).';
  }

  @override
  String get doubao => 'Doubao';

  @override
  String get noModelSelected => 'Aucun modèle sélectionné';

  @override
  String get acoustidRequestFailed => 'Requête AcoustID échouée';

  @override
  String acoustidRequestReturnedStatus(Object statusCode) {
    return 'La requête AcoustID a retourné $statusCode. Demandez votre propre clé API.';
  }

  @override
  String get writeTagDatabaseFailed =>
      'Échec d\'écriture de la base de données d\'étiquettes';

  @override
  String get playPause => 'Lecture / Pause';

  @override
  String get nextTrack => 'Suivant';

  @override
  String get previousTrack => 'Précédent';

  @override
  String get volumeUp => 'Augmenter le volume';

  @override
  String get volumeDown => 'Baisser le volume';

  @override
  String get toggleMute => 'Activer/Désactiver le son';

  @override
  String get seekForward5s => 'Avancer de 5 s';

  @override
  String get seekBackward5s => 'Reculer de 5 s';

  @override
  String get toggleFullScreen => 'Plein écran';

  @override
  String get playPauseDescription => 'Contrôler l\'état de lecture actuel.';

  @override
  String get nextDescription => 'Passer à la chanson suivante.';

  @override
  String get previousDescription => 'Revenir à la chanson précédente.';

  @override
  String get volumeUpDescription => 'Augmenter le volume de 5% à chaque fois.';

  @override
  String get volumeDownDescription => 'Baisser le volume de 5% à chaque fois.';

  @override
  String get toggleMuteDescription => 'Activer ou désactiver le son.';

  @override
  String get seekForward5sDescription => 'Avancer de 5 secondes.';

  @override
  String get seekBackward5sDescription => 'Reculer de 5 secondes.';

  @override
  String get toggleFullScreenDescription =>
      'Basculer entre le mode fenêtré et le plein écran.';

  @override
  String get unknownKey => 'Touche inconnue';

  @override
  String get removeFromQueue => 'Retirer de la file';

  @override
  String get removeFromPlaylist => 'Retirer de la liste de lecture';

  @override
  String get alreadyLatestVersion =>
      'Vous avez déjà la version la plus récente.';

  @override
  String get updateAvailable => 'Mise à jour disponible';

  @override
  String newVersionAvailable(Object version) {
    return 'Nouvelle version v$version disponible. Téléchargez depuis GitHub Releases.';
  }

  @override
  String get openRelease => 'Voir la version';

  @override
  String get checkUpdateFailedNetwork =>
      'Échec de la vérification des mises à jour. Problème réseau ou limite GitHub.';

  @override
  String get tags => 'Étiquettes';

  @override
  String get about => 'À propos';

  @override
  String get rebuildIndex => 'Reconstruire l\'index';

  @override
  String get rebuildIndexDescription =>
      'Effacer tous les enregistrements (sauf sources externes) et réanalyser tous les répertoires racine.';

  @override
  String get rebuildIndexConfirmation =>
      'Confirmez-vous l\'effacement de tous les enregistrements et la réanalyse ? Cela peut prendre du temps.';

  @override
  String get rebuildIndexStarted => 'Reconstruction de l\'index démarrée';

  @override
  String get rebuild => 'Reconstruire';

  @override
  String get advanced => 'Avancé';

  @override
  String get advancedOptionsDescription =>
      'Options de débogage et de réglage du comportement.';

  @override
  String get showDeveloperOptionsDescription =>
      'Afficher plus d\'options avancées pour le débogage.';

  @override
  String get onboardingReset =>
      'Guide de bienvenue réinitialisé. Effet au prochain démarrage.';

  @override
  String get tagsSectionDescription =>
      'Configurer les métadonnées audio et la complétion automatique.';

  @override
  String get autoSaveToSourceFile =>
      'Sauvegarde automatique dans le fichier source';

  @override
  String get autoSaveToSourceFileDescription =>
      'Écrire automatiquement les étiquettes dans le fichier audio physique.';

  @override
  String get aboutSectionDescription =>
      'Informations de version, liens du projet et ressources.';

  @override
  String get checkForUpdates => 'Vérifier les mises à jour';

  @override
  String get storeUpdateNotice =>
      'Les mises à jour de cette application sont gérées par le Microsoft Store. Vous pouvez vérifier la dernière version dans le Microsoft Store.';

  @override
  String get openMicrosoftStore => 'Ouvrir le Microsoft Store';

  @override
  String get appStoreUpdateNotice =>
      'Les mises à jour de cette application sont gérées par l\'App Store. Vous pouvez consulter ou télécharger la dernière version sur l\'App Store.';

  @override
  String get openAppStore => 'Ouvrir l\'App Store';

  @override
  String get lyricsGenerationModel => 'Modèle de génération de paroles';

  @override
  String get lyricsGenerationModelDescription =>
      'Pour la génération de paroles par IA et la correction de chronologie.';

  @override
  String get lyricsTranslationModel => 'Modèle de traduction de paroles';

  @override
  String get lyricsTranslationModelDescription =>
      'Pour traduire les paroles dans la langue cible.';

  @override
  String get onlyForLyricTranslation => 'Traduction uniquement';

  @override
  String get fillApiKeyFirstEnablesModels =>
      'Remplissez au moins une clé API pour activer la sélection de modèles.';

  @override
  String get customApiProvider => 'Fournisseur d\'API personnalisé';

  @override
  String get clearedGoogleAiStudioApiKey => 'Clé API Google AI Studio effacée';

  @override
  String get clearedOpenRouterApiKey => 'Clé API OpenRouter effacée';

  @override
  String get clearedDoubaoApiKey => 'Clé API Doubao effacée';

  @override
  String get clearedDeepseekApiKey => 'Clé API DeepSeek effacée';

  @override
  String get clearedCustomProviderConfig =>
      'Configuration personnalisée effacée';

  @override
  String get savedDoubaoApiKey => 'Clé API Doubao sauvegardée';

  @override
  String get savedDeepseekApiKey => 'Clé API DeepSeek sauvegardée';

  @override
  String get savedCustomProviderConfig =>
      'Configuration personnalisée sauvegardée';

  @override
  String get noMatchingFoldersOrSongs =>
      'Aucun dossier ou chanson correspondant trouvé';

  @override
  String get searching => 'Recherche...';

  @override
  String get listView => 'Vue en liste';

  @override
  String get gridView => 'Vue en grille';

  @override
  String get hybridView => 'Vue hybride';

  @override
  String songsCountFormat(Object count) {
    return '$count chansons';
  }

  @override
  String get searchInFolderAndSubfolders =>
      'Rechercher dans le dossier et les sous-dossiers...';

  @override
  String get shuffle => 'Aléatoire';

  @override
  String get search => 'Rechercher';

  @override
  String get selectFolders => 'Sélectionner des dossiers';

  @override
  String get removeDirectory => 'Supprimer le répertoire';

  @override
  String removeRootDirectoryConfirmation(Object name) {
    return 'Supprimer le répertoire racine \"$name\" ? Les fichiers physiques ne seront pas effacés.';
  }

  @override
  String get deselectAll => 'Tout désélectionner';

  @override
  String get favorites => 'Favoris';

  @override
  String get aggregationPeak => 'Crête';

  @override
  String get aggregationMean => 'Moyenne';

  @override
  String get aggregationRms => 'RMS';

  @override
  String get filesToTranscode => 'Fichiers à transcoder';

  @override
  String get chooseAndroidOutputDirectoryFirst =>
      'Choisissez d\'abord un répertoire de sortie Android.';

  @override
  String currentSongProgressPercent(Object percent) {
    return 'Chanson actuelle $percent%';
  }

  @override
  String overallProgressPercent(Object percent) {
    return 'Global $percent%';
  }

  @override
  String get pleaseChooseOutputDirectory =>
      'Veuillez d\'abord choisir un répertoire de sortie.';

  @override
  String selectedArtistsCount(Object count) {
    return '$count artistes sélectionnés';
  }

  @override
  String selectedAlbumsCount(Object count) {
    return '$count albums sélectionnés';
  }

  @override
  String get simplifiedChinese => 'Chinois simplifié';

  @override
  String get traditionalChinese => 'Chinois traditionnel';

  @override
  String get chineseLanguage => 'Chinois';

  @override
  String get englishLanguage => 'Anglais';

  @override
  String get japaneseLanguage => 'Japonais';

  @override
  String get koreanLanguage => 'Coréen';

  @override
  String get frenchLanguage => 'Français';

  @override
  String get germanLanguage => 'Allemand';

  @override
  String get spanishLanguage => 'Espagnol';

  @override
  String get nativeLanguageZh => '简体中文';

  @override
  String get nativeLanguageZhHant => '繁體中文';

  @override
  String get nativeLanguageEn => 'English';

  @override
  String get nativeLanguageJa => '日本語';

  @override
  String get nativeLanguageKo => '한국어';

  @override
  String get nativeLanguageFr => 'Français';

  @override
  String get nativeLanguageDe => 'Deutsch';

  @override
  String get nativeLanguageEs => 'Espagnol';

  @override
  String get portugueseLanguage => 'Portugais';

  @override
  String get russianLanguage => 'Russe';

  @override
  String get systemLanguage => 'Langue du système';

  @override
  String get targetLanguage => 'Langue cible';

  @override
  String get whatAreAiLyrics => 'Que sont les paroles IA ?';

  @override
  String get whatIsAiLyricTranslation =>
      'Qu\'est-ce que la traduction de paroles IA ?';

  @override
  String get aiLyricsIntroGeneration =>
      'L\'IA peut générer des paroles à partir de la chanson et les aligner temporellement.';

  @override
  String get aiLyricsIntroTranslation =>
      'L\'IA peut traduire les paroles dans votre langue préférée.';

  @override
  String get whyNeedApiKey => 'Pourquoi ai-je besoin d\'une clé API ?';

  @override
  String get apiKeyExplanation =>
      'Une clé API est votre identifiant d\'accès pour un fournisseur IA. L\'application l\'utilise pour envoyer des demandes directes de génération de paroles, d\'ajustement de chronologie ou de traduction.';

  @override
  String get apiKeyLocalOnly =>
      'Votre clé API est stockée localement et n\'est jamais envoyée aux serveurs Vynody.';

  @override
  String get chooseAnAiProvider => 'Choisissez un fournisseur IA :';

  @override
  String get googleProviderPros =>
      'Chaîne officielle Google, modèles Gemini puissants et quotas gratuits généreux.';

  @override
  String get googleProviderCons =>
      'Peut occasionner des erreurs 429. Changez de fournisseur si nécessaire.';

  @override
  String get openRouterProviderPros =>
      'Agrégateur de modèles avec accès à plusieurs fournisseurs.';

  @override
  String get openRouterProviderCons =>
      'Les rechargements peuvent inclure des frais. Site en anglais uniquement.';

  @override
  String get doubaoProviderPros =>
      'De ByteDance, performant en chinois. 500k tokens gratuits par modèle pour les nouveaux.';

  @override
  String get doubaoProviderCons =>
      'Inscription nécessite une vérification d\'identité réelle.';

  @override
  String get deepseekProviderPros =>
      'Bonne compréhension du chinois, prix bas, idéal pour la traduction.';

  @override
  String get deepseekProviderCons =>
      'Texte uniquement. Pour générer des paroles, un autre fournisseur est nécessaire.';

  @override
  String get highlights => 'Points forts';

  @override
  String get notes => 'Notes';

  @override
  String enterProviderApiKey(Object provider) {
    return 'Entrez votre clé API $provider :';
  }

  @override
  String get pasteYourApiKey => 'Collez votre clé API ici';

  @override
  String get getApiKey => 'Obtenir une clé API';

  @override
  String get testConnectionButton => 'Tester la connexion';

  @override
  String get enableAiLyricGeneration => 'Activer la génération IA de paroles';

  @override
  String get enableAiLyricTranslation => 'Activer la traduction IA de paroles';

  @override
  String get notNow => 'Pas maintenant';

  @override
  String get startSetup => 'Commencer la configuration';

  @override
  String get chooseAiProvider => 'Choisir un fournisseur IA';

  @override
  String get backStep => 'Retour';

  @override
  String get continueAction => 'Continuer';

  @override
  String get nextStep => 'Suivant';

  @override
  String get configureApiKey => 'Configurer la clé API';

  @override
  String get saveAndFinish => 'Sauvegarder et terminer';

  @override
  String get testing => 'Test...';

  @override
  String get noteTitle => 'Note';

  @override
  String get deepseekTextInputOnlyNote =>
      'DeepSeek ne supporte que le texte. Pour générer des paroles, utilisez un autre fournisseur.';

  @override
  String retryAttemptOfMax(Object attempt, Object maxRetry) {
    return 'Tentative $attempt/$maxRetry';
  }

  @override
  String generatingTaskKind(Object taskKind) {
    return 'Génération de $taskKind';
  }

  @override
  String connectionTestException(Object error) {
    return 'Erreur de test de connexion : $error';
  }

  @override
  String get testingConnectionProgress => 'Test de connexion...';

  @override
  String get clear => 'Effacer';

  @override
  String get enterDoubaoApiKey => 'Entrer la clé API Doubao';

  @override
  String get doubaoApiKeyDescription =>
      'Entrez votre clé API Volcano/Doubao pour la génération et la traduction.';

  @override
  String get enterDeepseekApiKey => 'Entrer la clé API DeepSeek';

  @override
  String get deepseekApiKeyDescription =>
      'Entrez votre clé API DeepSeek pour la traduction uniquement.';

  @override
  String get pleaseEnterApiKeyHint => 'Veuillez entrer la clé API';

  @override
  String get platform => 'Plateforme';

  @override
  String get showRecommendedOnly => 'Afficher uniquement les recommandés';

  @override
  String get noAvailableChannels => 'Aucun canal disponible';

  @override
  String get noMatchingModels => 'Aucun modèle correspondant trouvé';

  @override
  String get leaveEmpty => 'Laisser vide';

  @override
  String get leaveEmptyFallbackDescription =>
      'Sélectionnez ceci pour ne pas définir de modèle de secours.';

  @override
  String get modelSearchHint => 'Entrez le nom ou l\'ID du modèle';

  @override
  String sendFilesFailed(Object error) {
    return 'Échec de l\'envoi des fichiers : $error';
  }

  @override
  String get scanningFolderMusic => 'Analyse du dossier pour la musique...';

  @override
  String scanFolderFailed(Object error) {
    return 'Échec de l\'analyse du dossier : $error';
  }

  @override
  String get noMusicFilesFound => 'Aucun fichier musical pris en charge trouvé';

  @override
  String sendFolderFailed(Object error) {
    return 'Échec de l\'envoi du dossier : $error';
  }

  @override
  String get lanSharingStartFailed =>
      'Échec du démarrage du partage LAN. Vérifiez les permissions réseau.';

  @override
  String syncingLyricsToDevice(Object deviceName) {
    return 'Synchronisation des paroles vers $deviceName...';
  }

  @override
  String syncLyricsSuccess(Object matched, Object overwritten, Object skipped) {
    return 'Synchronisation réussie : $matched correspondantes, $overwritten mises à jour, $skipped ignorées';
  }

  @override
  String syncLyricsFailed(Object error) {
    return 'Échec de la synchronisation des paroles : $error';
  }

  @override
  String syncingLyricsFromDevice(Object deviceName) {
    return 'Réception des paroles de $deviceName...';
  }

  @override
  String get transferInProgressDoNotLeave =>
      'Transfert en cours. Ne quittez pas la page de partage.';

  @override
  String get lanSharingTitle => 'Connexion LAN';

  @override
  String get lanSharingEnabledStatus => 'Partage LAN activé';

  @override
  String get lanSharingDisabledStatus => 'Partage LAN désactivé';

  @override
  String lanSharingRunningStatus(Object ip, Object port) {
    return 'IP locale : $ip (Port : $port)';
  }

  @override
  String get lanSharingDefaultOffHint =>
      'Désactivé par défaut. L\'activation demandera la permission LAN.';

  @override
  String get receiveDirectoryNotSetWarning =>
      'Aucun répertoire de réception défini. Veuillez en configurer un.';

  @override
  String get receiveDirectoryNoWritePermission =>
      'Le répertoire actuel n\'a pas de permission d\'écriture. Veuillez le modifier.';

  @override
  String get restoreDefaultDirectory => 'Restaurer le répertoire par défaut';

  @override
  String get chooseOtherDirectory => 'Choisir un autre répertoire';

  @override
  String get receiveDirectoryRestoredDefault =>
      'Répertoire de réception par défaut restauré';

  @override
  String receiveDirectoryUpdated(Object path) {
    return 'Répertoire de réception mis à jour : $path';
  }

  @override
  String get receiveDirectoryTitle => 'Répertoire de réception';

  @override
  String get linkCopiedToClipboard => 'Lien copié dans le presse-papier';

  @override
  String get nearbyDevices => 'Appareils à proximité';

  @override
  String get searchingDevices => 'Recherche d\'autres appareils sur le LAN...';

  @override
  String get startSharingToFindDevices =>
      'Activez le partage pour découvrir les appareils';

  @override
  String get deviceOnline => 'En ligne';

  @override
  String get deviceOffline => 'Déconnecté';

  @override
  String get sendMusicFiles => 'Envoyer des fichiers musicaux';

  @override
  String get sendFolder => 'Envoyer un dossier';

  @override
  String get syncLyricsToDeviceAction =>
      'Synchroniser les paroles vers l\'appareil';

  @override
  String get syncLyricsFromDeviceAction =>
      'Synchroniser les paroles depuis l\'appareil';

  @override
  String loadDevicesError(Object error) {
    return 'Erreur de chargement des appareils : $error';
  }

  @override
  String incomingFilesFormat(Object name1, Object name2, Object count) {
    return '$name1, $name2 et $count autres fichiers';
  }

  @override
  String get incomingTransferRequestTitle => 'Demande de transfert entrant';

  @override
  String incomingTransferFrom(Object senderName) {
    return 'Demande de \"$senderName\" :';
  }

  @override
  String fileSizeMb(Object sizeMb) {
    return 'Taille du fichier : $sizeMb Mo';
  }

  @override
  String get receiveFileHint =>
      'Les fichiers reçus seront sauvegardés dans le dossier musical et ajoutés à la bibliothèque.';

  @override
  String get reject => 'Refuser';

  @override
  String get accept => 'Accepter';

  @override
  String get incomingLyricsExportTitle => 'Demande d\'exportation de paroles';

  @override
  String incomingLyricsExportFrom(Object senderName) {
    return 'L\'appareil \"$senderName\" demande à lire et exporter la bibliothèque de paroles.';
  }

  @override
  String get incomingLyricsImportTitle => 'Demande d\'importation de paroles';

  @override
  String incomingLyricsImportFrom(Object senderName, Object count) {
    return 'L\'appareil \"$senderName\" demande à importer des paroles pour $count chansons.';
  }

  @override
  String get lyricsRequestRejected =>
      'L\'appareil distant a refusé la demande de synchronisation des paroles.';

  @override
  String sendCompleted(Object fileName) {
    return '\"$fileName\" envoyé';
  }

  @override
  String receiveCompleted(int count) {
    return '$count chansons reçues avec succès';
  }

  @override
  String transferCancelledWithReason(Object direction, Object reason) {
    return '$direction annulée ($reason)';
  }

  @override
  String transferFailedFormat(Object direction, Object fileName) {
    return '$direction \"$fileName\" échoué';
  }

  @override
  String sendingToDevice(Object deviceName) {
    return 'Envoi vers $deviceName';
  }

  @override
  String receivingFromDevice(Object deviceName) {
    return 'Réception de $deviceName';
  }

  @override
  String progressFormat(Object percent) {
    return 'Progression : $percent%';
  }

  @override
  String get currentlyTransferring => 'Transfert en cours';

  @override
  String get fileConflictTitle => 'Conflit de fichiers';

  @override
  String get fileConflictMessage =>
      'Un fichier du même nom existe déjà sur l\'appareil de destination :';

  @override
  String get fileConflictChooseAction => 'Choisissez une action :';

  @override
  String get skipAction => 'Ignorer';

  @override
  String get overwriteAction => 'Écraser';

  @override
  String get skipAllAction => 'Tout ignorer';

  @override
  String get overwriteAllAction => 'Tout écraser';

  @override
  String get sendDirection => 'Envoi';

  @override
  String get receiveDirection => 'Réception';

  @override
  String get fileAssociationEnabled => 'Association activée';

  @override
  String get fileAssociationDisabled => 'Association désactivée';

  @override
  String get windowsAutoRepairShortcut =>
      'Réparer automatiquement le raccourci du menu Démarrer';

  @override
  String get windowsAutoRepairShortcutDescription =>
      'Vérifier et créer le raccourci du menu Démarrer à chaque démarrage pour afficher le nom et l\'icône corrects du contrôle multimédia';

  @override
  String get confirmDisableShortcutRepair => 'Désactiver cette fonction ?';

  @override
  String get confirmDisableShortcutRepairContent =>
      'Sans le raccourci du menu Démarrer, les contrôles multimédias Windows peuvent afficher l\'application comme \"Inconnue\" et sans icône. Voulez-vous vraiment désactiver cela ?';

  @override
  String get confirmDisable => 'Désactiver';

  @override
  String get enableSystemTray => 'Activer la barre d\'état système';

  @override
  String get enableSystemTrayDescription =>
      'Afficher l\'icône dans la barre d\'état système pour un contrôle rapide de la lecture';

  @override
  String get closeToTray =>
      'Réduire dans la zone de notification à la fermeture';

  @override
  String get closeToTrayDescription =>
      'Poursuivre la lecture en arrière-plan à la fermeture de la fenêtre principale sans quitter l’application';

  @override
  String get closeWindowActionTitle => 'Lors de la fermeture de la fenêtre';

  @override
  String get closeWindowActionDescription =>
      'Choisir l’action lors du clic sur le bouton de fermeture de la fenêtre principale';

  @override
  String get closeWindowActionAsk => 'Toujours demander';

  @override
  String get closeWindowActionMinimize =>
      'Réduire dans la zone de notification';

  @override
  String get closeWindowActionExit => 'Quitter l’application';

  @override
  String get closeWindowActionRemember =>
      'Mémoriser mon choix et ne plus demander';

  @override
  String get closeWindowActionTrayDisabledTip =>
      '(La zone de notification doit être activée au préalable)';

  @override
  String get closeWindowDialogTitle => 'Confirmation de fermeture';

  @override
  String get closeWindowDialogContent =>
      'Veuillez sélectionner l’action à effectuer lors du clic sur le bouton de fermeture :';

  @override
  String get googleAiStudioApiKey => 'Google AI Studio API Key';

  @override
  String get openRouterApiKey => 'OpenRouter API Key';

  @override
  String get doubaoApiKey => 'Doubao API Key';

  @override
  String get deepseekApiKey => 'DeepSeek API Key';

  @override
  String get unexpectedResponseFormat => 'Format de réponse inattendu.';

  @override
  String get baseUrl => 'Base URL';

  @override
  String get openaiCompatibleEndpoint =>
      'Point de terminaison d\'API compatible OpenAI';

  @override
  String onboardingAddedDirectoriesCount(Object count) {
    return 'Répertoires ajoutés ($count) :';
  }

  @override
  String get gnomeDisksOpenFailed =>
      'Impossible d\'ouvrir l\'utilitaire de disque automatiquement. Veuillez ouvrir \"Disques\" manuellement depuis le menu des applications.';

  @override
  String get gnomeDisksNotInstalled =>
      'gnome-disks n\'est pas installé. Veuillez ouvrir l\'utilitaire de disque de votre système pour configurer.';

  @override
  String get linuxMountGuideTitle =>
      'Configurer le montage automatique du disque';

  @override
  String get linuxMountGuideDescription =>
      'Par défaut, Linux ne monte pas automatiquement les partitions externes. Si vous ne configurez pas le montage au démarrage, le chemin des partitions externes peut changer à chaque redémarrage, empêchant le lecteur d\'accéder au répertoire musical. Pour éviter cela, veuillez configurer le montage automatique au démarrage de la partition contenant votre musique.';

  @override
  String get linuxMountGuideWarning =>
      'Attention : Si votre musique est située sur une partition de disque externe ou interne qui nécessite un montage, vous DEVEZ la configurer sur \"montage automatique au démarrage du système\". Sinon, le répertoire de musique risque de ne pas être trouvé après un redémarrage, ou vous devez saisir un mot de passe pour y accéder.';

  @override
  String get linuxMountGuideStep1 =>
      '1. Ouvrez l\'utilitaire \"Disques\" du système';

  @override
  String get linuxMountGuideStep2 =>
      '2. Sélectionnez la partition musicale, cliquez sur l\'icône d\'engrenage ⚙️ (Options supplémentaires de partition)';

  @override
  String get linuxMountGuideStep3 =>
      '3. Sélectionnez \"Modifier les options de montage\", désactivez \"Valeurs par défaut de la session utilisateur\" et cochez \"Monter au démarrage du système\"';

  @override
  String get linuxMountGuideOpenButton =>
      'Ouvrir le gestionnaire de disques (Disks)';

  @override
  String get unmute => 'Réactiver le son';

  @override
  String get mute => 'Muet';

  @override
  String get disableSystemTray => 'Désactiver la barre d\'état système';

  @override
  String get restoreWindow => 'Restaurer la fenêtre';

  @override
  String get hideWindow => 'Masquer la fenêtre';

  @override
  String get onboardingAndroidBatteryTitle =>
      'Protection de lecture en arrière-plan';

  @override
  String get onboardingAndroidBatteryDescription =>
      'En raison des règles strictes d\'optimisation de la batterie d\'Android, pour éviter que la lecture de musique ne soit interrompue en arrière-plan, nous vous recommandons de définir la restriction de batterie de Vynody sur « Non restreinte » (Unrestricted).';

  @override
  String get onboardingAndroidBatteryStep1 =>
      '1. Appuyez sur le bouton « Aller aux paramètres » ci-dessous.';

  @override
  String get onboardingAndroidBatteryStep2 =>
      '2. Autorisez l\'ignorance des optimisations de batterie dans l\'invite système, ou accédez aux paramètres de la batterie.';

  @override
  String get onboardingAndroidBatteryStep3 =>
      '3. Si vous êtes redirigé vers les paramètres, sélectionnez « Non restreinte » ou « Aucune restriction ».';

  @override
  String get onboardingAndroidBatteryButton => 'Aller aux paramètres';

  @override
  String get onboardingAndroidBatteryStatusOptimized =>
      'Statut : Restreint (la lecture peut s\'arrêter en arrière-plan)';

  @override
  String get onboardingAndroidBatteryStatusUnrestricted =>
      'Statut : Non restreinte (recommandé, lecture protégée)';

  @override
  String get onboardingAndroidMediaTitle =>
      'Accéder à la bibliothèque musicale';

  @override
  String get onboardingAndroidMediaDescription =>
      'Une fois l’autorisation accordée, Vynody peut lire directement toute la musique de la bibliothèque système sans sélectionner de dossiers manuellement. Vous pouvez toujours importer des dossiers manuellement sans cette autorisation.';

  @override
  String get onboardingAndroidMediaStep1 =>
      '1. Prêt à l’emploi : Affiche instantanément toute la musique déjà présente sur votre téléphone';

  @override
  String get onboardingAndroidMediaStep2 =>
      '2. Découverte automatique : Les nouveaux morceaux ajoutés apparaissent automatiquement';

  @override
  String get onboardingAndroidMediaStep3 =>
      '3. Respect de la vie privée : Lit uniquement les fichiers audio locaux et n\'envoie pas automatiquement votre bibliothèque (sauf utilisation de services cloud comme les paroles IA)';

  @override
  String get onboardingAndroidMediaButton =>
      'Autoriser l’accès à la bibliothèque musicale';

  @override
  String get onboardingAndroidMediaStatusGranted =>
      'Statut : Accordé (Recommandé)';

  @override
  String get onboardingAndroidMediaStatusNotGranted =>
      'Statut : Non accordé (vous pourrez importer des dossiers manuellement plus tard)';

  @override
  String get exitApp => 'Quitter';

  @override
  String get showScanProgressToastSetting =>
      'Afficher le toast d\'état du scan';

  @override
  String get showScanProgressToastSettingDescription =>
      'Affiche la progression du scan en temps réel en haut de l\'écran lors du scan des dossiers.';

  @override
  String get openPlaybackOnDirectorySongTap =>
      'Ouvrir la page de lecture lors d\'un appui sur un morceau';

  @override
  String get openPlaybackOnDirectorySongTapDescription =>
      'Ouvre automatiquement la page de lecture lors d\'un appui sur un morceau dans la vue des dossiers.';

  @override
  String get defaultToLyricsModeOnPlaybackOpen =>
      'Mode paroles par défaut sur la page de lecture';

  @override
  String get defaultToLyricsModeOnPlaybackOpenDescription =>
      'Passe automatiquement en mode paroles lors de l\'ouverture de la page de lecture.';

  @override
  String get tapCoverToEnterLyricsMode =>
      'Appuyez sur la pochette pour passer en mode paroles';

  @override
  String get longPressLyricsPanelToOpenMenu =>
      'Appuie longuement sur le panneau de paroles pour ouvrir le menu';

  @override
  String get gotIt => 'J\'ai compris';

  @override
  String get scanToastHiddenHint =>
      'Le toast d\'état du scan a été masqué. Vous pouvez le réactiver dans Paramètres - Interface.';

  @override
  String get doubleSpeedPlayingSwipeUpToLock =>
      'Avance rapide... Balayez vers le haut pour verrouiller';

  @override
  String get doubleSpeedLockedSwipeDownToUnlock =>
      'Avance rapide verrouillée. Maintenez et balayez vers le bas pour déverrouiller';

  @override
  String get doubleSpeedUnlocked => 'Avance rapide déverrouillée';

  @override
  String get lyricsImportExportHeader => 'Importer et exporter';

  @override
  String get exportAction => 'Exporter';

  @override
  String get importAction => 'Importer';

  @override
  String get exportLyricsLabel => 'Exporter la sauvegarde des paroles';

  @override
  String get exportLyricsDescription =>
      'Exporter toutes les paroles mises en cache et ajustées dans un fichier JSON';

  @override
  String get importLyricsLabel => 'Importer la sauvegarde des paroles';

  @override
  String get importLyricsDescription =>
      'Importer le cache de paroles depuis un fichier JSON exporté';

  @override
  String exportSuccess(int count) {
    return '$count paroles exportées avec succès.';
  }

  @override
  String exportFailed(String error) {
    return 'Échec de l\'exportation : $error';
  }

  @override
  String importSuccess(int count) {
    return 'Importation terminée ! $count paroles importées avec succès.';
  }

  @override
  String importFailed(String error) {
    return 'Échec de l\'importation : $error';
  }

  @override
  String get importConflictsTitle => 'Conflits d\'importation';

  @override
  String importConflictsMessage(int conflictCount) {
    return '$conflictCount paroles conflictuelles trouvées dans la sauvegarde (existent localement mais sont différentes). Veuillez choisir comment procéder :';
  }

  @override
  String get overwriteAll => 'Tout remplacer';

  @override
  String get skipAllConflicts => 'Ignorer les conflits';

  @override
  String get decideOneByOne => 'Décider un par un';

  @override
  String conflictResolutionTitle(int current, int total) {
    return 'Résoudre le conflit ($current/$total)';
  }

  @override
  String get conflictExistingLabel => 'Paroles existantes';

  @override
  String get conflictImportedLabel => 'Paroles importées';

  @override
  String conflictSourceLabel(String source) {
    return 'Source : $source';
  }

  @override
  String conflictTimeLabel(String time) {
    return 'Temps : $time';
  }

  @override
  String get overwriteThis => 'Remplacer';

  @override
  String get skipThis => 'Ignorer';

  @override
  String get overwriteRemaining => 'Remplacer tous les restants';

  @override
  String get skipRemaining => 'Ignorer tous les restants';

  @override
  String get invalidBackupFile => 'Fichier de sauvegarde invalide';

  @override
  String get exportLogs => 'Exporter les journaux';

  @override
  String get exportLogsSuccess => 'Journaux exportés avec succès';

  @override
  String get exportLogsFailed => 'Échec de l\'exportation des journaux';

  @override
  String get noLogFileFound => 'Aucun fichier journal trouvé';

  @override
  String get uiDisplayScale => 'Échelle d’affichage de l’interface';

  @override
  String get uiDisplayScaleDescription =>
      'Ajuster globalement la taille des composants et du texte de l’interface, adapté aux écrans embarqués';

  @override
  String get uiDisplayScaleDialogTitle => 'Échelle d’affichage / Mode véhicule';

  @override
  String uiDisplayScaleCurrent(int percent) {
    return 'Échelle actuelle : $percent%';
  }

  @override
  String get audioSettings => 'Paramètres audio';

  @override
  String get audioSettingsDescription =>
      'Gérer la lecture audio, les bandes de l’égaliseur et la vitesse de lecture';

  @override
  String get equalizerBandCount => 'Nombre de bandes de l’égaliseur';

  @override
  String get equalizerBandCountDescription =>
      'Configurer le nombre de bandes affichées dans l’égaliseur. Les modes à nombreuses bandes activeront le défilement horizontal fluide.';

  @override
  String bandsCountOption(int count) {
    return '$count bandes';
  }

  @override
  String get enableFadeEffect => 'Effet de fondu audio';

  @override
  String get enableFadeEffectDescription =>
      'Activer des transitions fluides en fondu et fondu enchaîné lors du changement de morceau, de la lecture et de la pause';

  @override
  String get buttonLayoutSettings => 'Disposition des boutons';

  @override
  String get playbackButtonLayoutTitle =>
      'Disposition des commandes de la page de lecture';

  @override
  String get playbackButtonLayoutDescription =>
      'Personnalisez l\'ordre et l\'affichage des boutons dans les rangées de 7 et 5 boutons';

  @override
  String get topButtonsRowTitle => 'Ordre de la rangée de 7 boutons';

  @override
  String get mainButtonsRowTitle =>
      'Boutons gauche et droit de la rangée de 5 boutons';

  @override
  String get mainControlsLeftButton => 'Bouton gauche';

  @override
  String get mainControlsRightButton => 'Bouton droit';

  @override
  String get lyricsHeaderRightButtonTitle =>
      'Bouton droit lorsque la barre de titre des paroles est réduite';

  @override
  String get resetButtonOrder => 'Rétablir la disposition par défaut';

  @override
  String get btnMore => 'Plus de menu';

  @override
  String get btnFavorite => 'Favori';

  @override
  String get btnPlaylistMode => 'Mode de lecture';

  @override
  String get btnShuffle => 'Lecture aléatoire';

  @override
  String get btnTagCompletion => 'Complétion des tags';

  @override
  String get btnSleepTimer => 'Minuteur de mise en veille';

  @override
  String get btnEqualizer => 'Égaliseur';

  @override
  String get btnVisualizer => 'Visualiseur';

  @override
  String get btnVolume => 'Volume';

  @override
  String get remoteControlAction => 'Contrôle à distance';

  @override
  String get remoteControlRequestTitle => 'Demande de contrôle à distance';

  @override
  String remoteControlRequestFrom(String name) {
    return 'L\'appareil \"$name\" demande à contrôler la lecture';
  }

  @override
  String get remotePinPairHint =>
      'Veuillez saisir le code PIN d\'appairage suivant sur l\'appareil de contrôle :';

  @override
  String get remotePinExpiresIn => 'Le code PIN expire dans :';

  @override
  String get allowDirectly => 'Autoriser directement';

  @override
  String get enterRemotePinTitle => 'Appairage d\'appareils';

  @override
  String enterRemotePinPrompt(String name) {
    return 'Saisissez le code PIN à 4 chiffres affiché sur « $name » :';
  }

  @override
  String get remotePinInvalid =>
      'Code PIN non valide ou expiré. Veuillez réessayer.';

  @override
  String remotePinCooldown(int seconds) {
    return 'Code PIN incorrect, réessayez dans $seconds s';
  }

  @override
  String remotePinAttemptsRemaining(int count) {
    return '($count tentatives restantes)';
  }

  @override
  String get remotePinTooManyAttempts =>
      'Trop de tentatives échouées. Session d\'appairage expirée.';

  @override
  String get remoteConnected => 'Connecté';

  @override
  String get remoteConnecting => 'Connexion en cours...';

  @override
  String get remoteDisconnect => 'Déconnecter';

  @override
  String get remoteConnectFailed => 'Échec de la connexion à distance';

  @override
  String controlledByRemoteDevices(String devices) {
    return 'Contrôlé par le ou les appareils distants suivants : $devices';
  }

  @override
  String get trustedDevicesTitle =>
      'Appareils de contrôle à distance de confiance';

  @override
  String get manageTrustedDevicesTitle =>
      'Gérer les appareils de contrôle à distance de confiance';

  @override
  String get removeTrustedDevice => 'Supprimer la confiance';

  @override
  String get noMusicPlaying => 'Aucune musique en cours de lecture';

  @override
  String get previousSong => 'Piste précédente';

  @override
  String get nextSong => 'Piste suivante';

  @override
  String get shufflePlayback => 'Lecture aléatoire';

  @override
  String get allowRemoteControlTitle => 'Autoriser le contrôle à distance';

  @override
  String get allowRemoteControlSubtitle =>
      'Permet aux autres appareils du réseau de contrôler la lecture après l\'appairage';

  @override
  String get remoteControlDisabledOnHost =>
      'Le contrôle à distance est désactivé sur l\'appareil cible';

  @override
  String get trustThisDevice =>
      'Faire confiance à cet appareil et l\'autoriser automatiquement à l\'avenir';

  @override
  String get remoteRequestRejected =>
      'La demande de connexion a été refusée par l\'appareil cible.';

  @override
  String get turkishLanguage => 'Turc';

  @override
  String get nativeLanguageTr => 'Türkçe';

  @override
  String trustedDevicesCount(int count) {
    return '$count appareils de confiance';
  }

  @override
  String get noTrustedDevices => 'Aucun appareil de confiance';

  @override
  String get noTrustedDevicesHint =>
      'Les appareils apparaîtront ici après avoir coché « Faire confiance à cet appareil » lors de l\'association';

  @override
  String pairedAtFormat(String time) {
    return 'Associé le : $time';
  }

  @override
  String transferCancelled(String direction) {
    return '$direction annulée';
  }

  @override
  String get audioFiles => 'Fichiers audio';

  @override
  String get remotePairCancelledByClient =>
      'La demande de jumelage a été annulée par l\'appareil cible.';

  @override
  String get proFeatureAiLyricsTitle => 'Paroles IA & Traduction';

  @override
  String get proFeatureAiLyricsDesc =>
      'Génération de paroles par IA, alignement temporel et traduction';

  @override
  String get proFeatureTagCompletionTitle => 'Autocomplétion des métadonnées';

  @override
  String get proFeatureTagCompletionDesc =>
      'Complétion automatique des tags et métadonnées d\'albums via MusicBrainz';

  @override
  String get proFeatureEqualizerTitle => 'Égaliseur multibande et vitesse (EQ)';

  @override
  String get proFeatureEqualizerDesc =>
      'Réglage de fréquence professionnel, vitesse de lecture 0.5x–5.0x, gain et styles personnalisés';

  @override
  String get proFeatureCustomThemeColorTitle =>
      'Thèmes à spectre complet et couleurs avancées';

  @override
  String get proFeatureCustomThemeColorDesc =>
      'Débloquez la palette de sélection de couleurs libre et les couleurs de thème prédéfinies premium exclusives';

  @override
  String get proFeatureFftVisualizerTitle => 'Spectre audio FFT en temps réel';

  @override
  String get proFeatureFftVisualizerDesc =>
      '6 styles de spectre (Barres classiques, Onde fluide, Chapeaux flottants, Halo radial, Matrice néon, Onde miroir) et mode ambiant plein écran';

  @override
  String get proFeatureWaveformBarTitle =>
      'Barre de progression à forme d\'onde';

  @override
  String get proFeatureWaveformBarDesc =>
      'Extraction de forme d\'onde en temps réel avec navigation interactive fluide';

  @override
  String get proFeatureLanSharingTitle => 'Partage de musique via LAN';

  @override
  String get proFeatureLanSharingDesc =>
      'Partage et transfert rapide de musique entre appareils sur le réseau local';

  @override
  String get proFeatureRemoteControlTitle =>
      'Contrôle à distance multi-appareils';

  @override
  String get proFeatureRemoteControlDesc =>
      'Connexion fluide et contrôle sans fil de la lecture entre appareils';

  @override
  String get proFeatureTranscoderTitle => 'Convertisseur audio par lot';

  @override
  String get proFeatureTranscoderDesc =>
      'Conversion rapide de formats sans perte et export par lot pour appareils portables';

  @override
  String get proFeatureDynamicMeshBackgroundTitle =>
      'Arrière-plan maillage dynamique';

  @override
  String get proFeatureDynamicMeshBackgroundDesc =>
      'Animation de dégradé fluide basée sur les couleurs de la pochette avec vitesse réglable';

  @override
  String get proFeatureCustomImageBackgroundTitle =>
      'Fond de lecture personnalisé';

  @override
  String get proFeatureCustomImageBackgroundDesc =>
      'Importez vos propres photos et fonds d\'écran comme arrière-plan immersif';

  @override
  String get proCommunityUnlocked =>
      'Édition communautaire : toutes les fonctionnalités Pro débloquées à vie';

  @override
  String proTrialActive(int days) {
    return 'Période d\'essai gratuite active ($days jours restants)';
  }

  @override
  String get proTrialExpired =>
      'Période d\'essai terminée. Passez à Pro pour débloquer les fonctionnalités';

  @override
  String get proPermanentlyActivated =>
      'Toutes les fonctionnalités Pro sont activées de façon permanente';

  @override
  String proStatusTrialTitle(int days) {
    return 'Statut de licence : $days jours d\'essai gratuit actif';
  }

  @override
  String get proStatusTrialExpiredTitle =>
      'Statut de licence : Essai expiré (fonctionnalités limitées)';

  @override
  String get proStatusActivatedTitle => 'Statut de licence : Vynody Pro activé';

  @override
  String proSettingsTrialRemaining(int days) {
    return '$days jours d\'essai restants';
  }

  @override
  String get proSettingsUpgradePrompt =>
      'Mettre à niveau pour débloquer les paroles IA, le spectre FFT et les fonctionnalités Pro';

  @override
  String get proSettingsLifetimeNotice =>
      'Toutes les fonctionnalités Pro et futures mises à jour incluses';

  @override
  String get proSettingsUpgrade => 'Mettre à niveau';

  @override
  String get proSettingsView => 'Voir';

  @override
  String get connectingToStore => 'Connexion au store en cours...';

  @override
  String get buyFullVersionWindowsTrial =>
      'Acheter la version complète sur le Microsoft Store';

  @override
  String get buyFullVersionWindows =>
      'Acheter la version complète sur le Microsoft Store';

  @override
  String unlockProLifetimeWithPrice(String price) {
    return '$price Débloquer Pro à vie';
  }

  @override
  String get buyProTrialEarly => 'Acheter la licence Pro à vie';

  @override
  String get upgradeToProNow => 'Passer à Pro maintenant';

  @override
  String get iUnderstand => 'Compris';

  @override
  String get restorePurchases => 'Restaurer les achats';

  @override
  String get restoringPurchases => 'Restauration des achats en cours...';

  @override
  String get sharingProDescription =>
      'L\'interconnexion LAN est une fonctionnalité exclusive de Vynody Pro. Débloquez-la pour profiter du transfert ultra-rapide de morceaux, de la synchronisation de bibliothèque et du contrôle à distance sur votre réseau local.';

  @override
  String get sharingHighlightSpeedTitle => 'Transfert LAN ultra-rapide';

  @override
  String get sharingHighlightSpeedDesc =>
      'Transfert direct P2P de musique sans perte et de listes de lecture en Wi-Fi, sans compression ni conso de données.';

  @override
  String get sharingHighlightSyncTitle => 'Synchro de bibliothèque & paroles';

  @override
  String get sharingHighlightSyncDesc =>
      'Envoi en un clic des paroles et morceaux téléchargés pour synchroniser vos différents appareils.';

  @override
  String get sharingHighlightRemoteTitle => 'Contrôle à distance sans fil';

  @override
  String get sharingHighlightRemoteDesc =>
      'Connexion fluide entre smartphones, tablettes et PC pour contrôler la lecture, changer de piste et régler le volume.';

  @override
  String get sharingHighlightSecurityTitle => 'Chiffrement TLS de bout en bout';

  @override
  String get sharingHighlightSecurityDesc =>
      'Chiffrement complet TLS et appairage de confiance pour des transferts privés et sécurisés.';

  @override
  String get upgradeToProToUnlock => 'Passer à Vynody Pro';

  @override
  String get proOneTimePurchaseNotice =>
      'Achat unique, débloque à vie toutes les fonctionnalités Pro sur cette plateforme';

  @override
  String get proOneTimePurchaseNoticeApple =>
      'Achat unique, débloque à vie toutes les fonctionnalités Pro sur les plateformes Apple (iPhone / iPad / Mac)';

  @override
  String get proUniversalPurchaseNoticeApple =>
      'Un seul achat, utilisable sur iPhone, iPad et Mac';

  @override
  String get iapPurchaseSuccess =>
      'Achat de Vynody Pro réussi ! Merci pour votre soutien !';

  @override
  String get iapRestoreSuccess => 'Achats Vynody Pro restaurés avec succès !';

  @override
  String iapPurchaseCancelledOrFailed(String message) {
    return 'Achat non finalisé ou annulé : $message';
  }

  @override
  String get tabLanSharing => 'Partage LAN & Télécommande';

  @override
  String get tabCloudServers => 'Serveurs multimédias cloud';

  @override
  String get addRemoteServer => 'Ajouter un serveur multimédia';

  @override
  String get editRemoteServer => 'Modifier le serveur multimédia';

  @override
  String get serverName => 'Nom du serveur';

  @override
  String get serverNameAlreadyExists =>
      'Le nom du serveur existe déjà. Veuillez en choisir un autre.';

  @override
  String get serverType => 'Type de serveur';

  @override
  String get serverUrl => 'URL du serveur';

  @override
  String get serverUsername => 'Nom d\'utilisateur';

  @override
  String get serverPassword => 'Mot de passe / Jeton';

  @override
  String get customPath => 'Chemin personnalisé (optionnel)';

  @override
  String get maxBitRate => 'Débit binaire max de transcodage (kbps)';

  @override
  String get ignoreSsl => 'Ignorer les erreurs de certificat SSL';

  @override
  String get connectionSuccess => 'Connecté avec succès';

  @override
  String get connectionFailed => 'Échec de la connexion';

  @override
  String get noRemoteServers => 'Aucun serveur multimédia ajouté';

  @override
  String get noRemoteServersDesc =>
      'Ajoutez des serveurs Navidrome (Subsonic) ou WebDAV pour écouter votre musique hébergée';

  @override
  String get browseServer => 'Parcourir';

  @override
  String get manageServer => 'Gérer';

  @override
  String get deleteServerConfirm =>
      'Voulez-vous vraiment supprimer cette connexion au serveur ?';

  @override
  String get remoteSongCannotEditTags =>
      'Impossible de modifier les tags des morceaux distants';

  @override
  String get addToServerPlaylist => 'Ajouter à la playlist du serveur';

  @override
  String get addToLocalPlaylist => 'Ajouter à la playlist locale';

  @override
  String get serverPlaylists => 'Playlists du serveur';

  @override
  String get localPlaylists => 'Playlists locales';

  @override
  String get createNewServerPlaylist => 'Créer une playlist sur le serveur';

  @override
  String get downloadSong => 'Télécharger le morceau';

  @override
  String get downloadAlbum => 'Télécharger l\'album complet';

  @override
  String get downloadArtist => 'Télécharger tous les morceaux de l\'artiste';

  @override
  String downloadStarted(Object title) {
    return 'Téléchargement en cours : $title';
  }

  @override
  String downloadCompleted(Object title) {
    return 'Enregistré dans la bibliothèque locale : $title';
  }

  @override
  String downloadFailed(Object error) {
    return 'Échec du téléchargement : $error';
  }

  @override
  String get alreadyDownloaded =>
      'Ce morceau existe déjà dans la bibliothèque locale';

  @override
  String get starItem => 'Ajouter aux favoris du serveur';

  @override
  String get unstarItem => 'Retirer des favoris du serveur';

  @override
  String get starredSuccess => 'Ajouté aux favoris sur le serveur';

  @override
  String get unstarredSuccess => 'Retiré des favoris sur le serveur';

  @override
  String batchDownloadStarted(Object count) {
    return 'Téléchargement en arrière-plan de $count morceaux...';
  }

  @override
  String batchDownloadCompleted(Object count) {
    return '$count morceaux téléchargés dans la bibliothèque locale';
  }

  @override
  String get viewAlbum => 'Voir l\'album';

  @override
  String get viewArtist => 'Voir l\'artiste';

  @override
  String get downloadManager => 'Gestionnaire de téléchargements';

  @override
  String get downloadingTab => 'En cours';

  @override
  String get completedTab => 'Terminé';

  @override
  String get pauseAll => 'Tout mettre en pause';

  @override
  String get resumeAll => 'Tout reprendre';

  @override
  String get cancelAll => 'Tout annuler';

  @override
  String get clearCompleted => 'Effacer l\'historique';

  @override
  String get noActiveDownloads => 'Aucun téléchargement en cours';

  @override
  String get noCompletedDownloads => 'Aucun téléchargement terminé';

  @override
  String get viewDownloadProgress => 'Voir la progression';

  @override
  String get addedToDownloadQueue => 'Ajouté à la file de téléchargement';

  @override
  String batchAddedToDownloadQueue(Object count) {
    return '$count morceaux ajoutés à la file de téléchargement';
  }

  @override
  String get downloadFolder => 'Emplacement de téléchargement';

  @override
  String get downloadAllAudio =>
      'Télécharger tous les fichiers audio du dossier';

  @override
  String get starredSongs => 'Morceaux favoris';

  @override
  String get starredSongsDesc => 'Morceaux favoris sur le serveur Navidrome';

  @override
  String get starredArtists => 'Artistes favoris';

  @override
  String get shuffleAlbumOrder => 'Mélanger l\'ordre des albums';

  @override
  String get threeDView => 'Vue 3D';

  @override
  String receiveFailed(Object fileName) {
    return 'Échec de la réception de « $fileName »';
  }

  @override
  String get quickPresets => 'Préréglages rapides';

  @override
  String get presetStandard => '100% Standard';

  @override
  String get presetModerate => '125% Modéré';

  @override
  String get presetCarRecommended => '135% Recommandé pour voiture';

  @override
  String get presetLarge => '150% Grand';

  @override
  String get safFallbackScanningNotice =>
      '(Autorisation multimédia non accordée, analyse de secours SAF activée, cela peut être plus lent)';

  @override
  String get justNow => 'À l\'instant';

  @override
  String minutesAgo(Object minutes) {
    return 'Il y a $minutes min';
  }

  @override
  String todayTime(Object time) {
    return 'Aujourd\'hui $time';
  }

  @override
  String yesterdayTime(Object time) {
    return 'Hier $time';
  }

  @override
  String get playlists => 'Playlists';

  @override
  String get songs => 'Morceaux';

  @override
  String createdPlaylistSuccess(String name) {
    return 'Playlist créée : $name';
  }

  @override
  String get loadingAlbumTracks => 'Chargement des pistes de l\'album...';

  @override
  String get loadingArtistTracks => 'Chargement des pistes de l\'artiste...';

  @override
  String get loadingFolderAudio => 'Chargement de l\'audio du dossier...';

  @override
  String get noAudioFilesInFolder => 'Aucun fichier audio dans ce dossier';

  @override
  String failedToLoadFolder(String error) {
    return 'Échec du chargement du dossier : $error';
  }

  @override
  String get starFailed => 'Échec de l\'ajout aux favoris';

  @override
  String playAlbumFailed(String error) {
    return 'Échec de la lecture de l\'album : $error';
  }

  @override
  String get sortAllAZ => 'Tous (A-Z)';

  @override
  String get sortRecentlyPlayed => 'Récemment écoutés';

  @override
  String get sortMostPlayed => 'Les plus écoutés';

  @override
  String get sortStarred => 'Favoris';

  @override
  String get sortRandom => 'Aléatoire';

  @override
  String get filterAlbums => 'Filtrer les albums...';

  @override
  String get filterArtists => 'Filtrer les artistes...';

  @override
  String get searchPlaylists => 'Rechercher des playlists...';

  @override
  String get searchRemoteHint => 'Rechercher des titres, albums, artistes...';

  @override
  String errorLoadingAlbums(String error) {
    return 'Erreur lors du chargement des albums : $error';
  }

  @override
  String get noAlbumsOnServer => 'Aucun album trouvé sur le serveur';

  @override
  String get noMatchingAlbums => 'Aucun album correspondant';

  @override
  String get playAlbum => 'Lire l\'album';

  @override
  String get shuffleAlbum => 'Lecture aléatoire de l\'album';

  @override
  String errorLoadingArtists(String error) {
    return 'Erreur lors du chargement des artistes : $error';
  }

  @override
  String get noArtistsFound => 'Aucun artiste trouvé';

  @override
  String get noMatchingArtists => 'Aucun artiste correspondant';

  @override
  String get noArtistSelected => 'Aucun artiste sélectionné';

  @override
  String errorLoadingPlaylists(String error) {
    return 'Erreur lors du chargement des playlists : $error';
  }

  @override
  String get noPlaylistsFound => 'Aucune playlist trouvée';

  @override
  String get noMatchingPlaylists => 'Aucune playlist correspondante';

  @override
  String get noPlaylistSelected => 'Aucune playlist sélectionnée';

  @override
  String get typeToSearch => 'Tapez quelque chose pour rechercher';

  @override
  String get albumNotFound => 'Détails de l\'album introuvables';

  @override
  String playingTracksCount(int count) {
    return 'Lecture de $count morceaux';
  }

  @override
  String get artistNotFound =>
      'Détails de l\'artiste introuvables sur le serveur';

  @override
  String get noTracksForArtist => 'Aucun morceau trouvé pour cet artiste';

  @override
  String get noAlbumsForArtist => 'Aucun album trouvé pour cet artiste';

  @override
  String get playlistNotFound =>
      'Détails de la playlist introuvables sur le serveur';

  @override
  String removedFromPlaylistSuccess(String title) {
    return '« $title » retiré de la playlist';
  }

  @override
  String get removeTrackFailed => 'Échec de la suppression du morceau';

  @override
  String get playlistDeleted => 'Playlist supprimée';

  @override
  String get deletePlaylistFailed => 'Échec de la suppression de la playlist';

  @override
  String byAuthor(String author) {
    return 'par $author';
  }

  @override
  String get downloadAllTracks => 'Tout télécharger';

  @override
  String get downloadFailedGeneric => 'Échec du téléchargement';

  @override
  String downloadPaused(String progress) {
    return 'En pause ($progress %)';
  }

  @override
  String get waitingInQueue => 'En file d\'attente...';

  @override
  String get downloadCancelled => 'Annulé';

  @override
  String fileNotFoundAtPath(String path) {
    return 'Fichier introuvable à $path';
  }

  @override
  String addedTracksToPlaylistSuccess(int count, String name) {
    return '$count morceau(x) ajouté(s) à « $name »';
  }

  @override
  String get addToPlaylistFailed => 'Échec de l\'ajout à la playlist';

  @override
  String errorAddingToPlaylist(String error) {
    return 'Erreur lors de l\'ajout à la playlist : $error';
  }

  @override
  String createdPlaylistWithTracksSuccess(String name, int count) {
    return 'Playlist « $name » créée avec $count morceau(x)';
  }

  @override
  String get createServerPlaylistFailed =>
      'Échec de la création de la playlist sur le serveur';

  @override
  String errorCreatingPlaylist(String error) {
    return 'Erreur lors de la création de la playlist : $error';
  }

  @override
  String get noServerPlaylistsFound => 'Aucune playlist de serveur trouvée';

  @override
  String get download => 'Télécharger';

  @override
  String get resume => 'Reprendre';

  @override
  String get remove => 'Supprimer';

  @override
  String get refresh => 'Actualiser';

  @override
  String get copyFilePath => 'Copier le chemin du fichier';

  @override
  String get openFolder => 'Ouvrir le dossier';

  @override
  String get copyFolderName => 'Copier le nom du dossier';

  @override
  String get copyFolderPath => 'Copier le chemin du dossier';

  @override
  String errorWithMessage(String error) {
    return 'Erreur : $error';
  }

  @override
  String get importPlaylist => 'Importer une liste de lecture';

  @override
  String get exportPlaylist => 'Exporter la liste de lecture';

  @override
  String get exportPlaylistAsM3u => 'Exporter en M3U';

  @override
  String importPlaylistSuccess(String name, int count) {
    return 'Liste de lecture \"$name\" importée avec succès ($count morceaux)';
  }

  @override
  String get exportPlaylistSuccess => 'Liste de lecture exportée avec succès';

  @override
  String importPlaylistFailed(String error) {
    return 'Échec de l\'importation de la liste: $error';
  }

  @override
  String exportPlaylistFailed(String error) {
    return 'Échec de l\'exportation de la liste: $error';
  }

  @override
  String get noSongsInPlaylist => 'Aucun morceau dans la liste de lecture';

  @override
  String get sendPlaylistsToDeviceAction => 'Envoyer des listes à l\'appareil';

  @override
  String get pullPlaylistsFromDeviceAction =>
      'Obtenir des listes de cet appareil';

  @override
  String get selectPlaylistsToSend => 'Sélectionner les listes à envoyer';

  @override
  String sendPlaylistsSuccess(int count) {
    return '$count liste(s) envoyée(s) avec succès';
  }

  @override
  String receivePlaylistsSuccess(int count) {
    return '$count liste(s) reçue(s) avec succès';
  }

  @override
  String pullPlaylistsSuccess(int count) {
    return '$count liste(s) importée(s) avec succès';
  }

  @override
  String sendPlaylistsFailed(String error) {
    return 'Échec de l\'envoi des listes : $error';
  }

  @override
  String pullPlaylistsFailed(String error) {
    return 'Échec de l\'obtention des listes : $error';
  }

  @override
  String syncingPlaylistsToDevice(String device) {
    return 'Envoi des listes à « $device »...';
  }

  @override
  String syncingPlaylistsFromDevice(String device) {
    return 'Obtention des listes de « $device »...';
  }

  @override
  String get incomingPlaylistImportTitle =>
      'Demande de partage de listes de lecture';

  @override
  String get incomingPlaylistExportTitle =>
      'Demande d\'exportation de listes de lecture';

  @override
  String incomingPlaylistImportFrom(
    String senderName,
    int count,
    int songsCount,
  ) {
    return 'L\'appareil « $senderName » souhaite vous envoyer $count listes ($songsCount morceaux).';
  }

  @override
  String incomingPlaylistExportFrom(String senderName) {
    return 'L\'appareil « $senderName » a demandé à lire et synchroniser vos listes.';
  }

  @override
  String get noPlaylistsAvailable => 'Aucune liste disponible';

  @override
  String get playlistRequestRejected => 'La demande de listes a été refusée';
}
