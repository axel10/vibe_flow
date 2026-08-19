// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Vynody';

  @override
  String get alwaysOnTop => 'Siempre visible';

  @override
  String get systemMediaLibrary => 'Biblioteca multimedia del sistema';

  @override
  String get scanningDirectory => 'Escaneando directorio...';

  @override
  String filesPreprocessed(Object count) {
    return 'Preprocesados $count';
  }

  @override
  String filesDiscovered(Object count) {
    return 'Descubiertos $count';
  }

  @override
  String filesFullyProcessed(Object count) {
    return 'Procesados completamente $count';
  }

  @override
  String get directoryAddedSuccess => 'Directorio agregado exitosamente';

  @override
  String get directoryAddedNoMusic =>
      'Directorio agregado, pero no se encontraron archivos de audio reproducibles';

  @override
  String get scanDirectory => 'Escanear directorio';

  @override
  String get sort => 'Ordenar';

  @override
  String get addRootDirectory => 'Agregar directorio raíz';

  @override
  String get goBack => 'Volver';

  @override
  String get noMediaLibraryPermission =>
      'Sin permiso de acceso a la biblioteca multimedia';

  @override
  String get grantPermission => 'Conceder permiso';

  @override
  String get needPermissionToScan =>
      'Se necesita permiso para escanear música local';

  @override
  String get rebuildTagDatabase => 'Reconstruir base de datos de etiquetas';

  @override
  String get rebuildDatabase => 'Reconstruir base de datos';

  @override
  String get confirmRebuildDatabase =>
      '¿Estás seguro de que deseas actualizar toda la información de etiquetas de canciones? Esto puede tomar tiempo para recargar carátulas y metadatos.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get rebuildingDatabase =>
      'Reconstruyendo base de datos de etiquetas de canciones...';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get sortScope => 'Ámbito';

  @override
  String get sortOrder => 'Orden de clasificación';

  @override
  String get title => 'Título';

  @override
  String get fileName => 'Nombre de archivo';

  @override
  String get trackNumber => 'Número de pista';

  @override
  String get ascending => 'Ascendente';

  @override
  String get descending => 'Descendente';

  @override
  String get currentFolderScope => 'Carpeta actual';

  @override
  String get globalScope => 'Global';

  @override
  String get visualizerSettings => 'Configuración de la página de reproducción';

  @override
  String get algorithm => 'Espectro';

  @override
  String get appearance => 'Apariencia';

  @override
  String get spectrumAppearanceGroup => 'Apariencia del espectro';

  @override
  String get spectrumAdvancedOptions => 'Opciones avanzadas del espectro';

  @override
  String get resetAlgorithm => 'Restablecer algoritmo';

  @override
  String get resetAppearance => 'Restablecer apariencia';

  @override
  String get smoothing => 'Suavizado';

  @override
  String get gravity => 'Gravedad';

  @override
  String get logScale => 'Escala logarítmica';

  @override
  String get contrast => 'Contraste';

  @override
  String get normalization => 'Normalización';

  @override
  String get multiplier => 'Multiplicador';

  @override
  String get skipHighFrequency => 'Omitir alta frecuencia';

  @override
  String get frequencyGroups => 'Grupos de frecuencia';

  @override
  String get aggregationMode => 'Modo de agregación';

  @override
  String get opacity => 'Opacidad';

  @override
  String get enableGradient => 'Activar degradado';

  @override
  String get startColor => 'Color inicial';

  @override
  String get endColor => 'Color final';

  @override
  String get gradientRangeStop1 => 'Punto de parada 1 del degradado';

  @override
  String get gradientRangeStop2 => 'Punto de parada 2 del degradado';

  @override
  String get gradientRepeatMode => 'Modo de repetición del degradado';

  @override
  String get color => 'Color';

  @override
  String get followCoverColor => 'Seguir color de carátula';

  @override
  String get selectColor => 'Seleccionar color';

  @override
  String get volume => 'Volumen';

  @override
  String get clearQueue => 'Vaciar cola';

  @override
  String get confirmClearQueue =>
      '¿Estás seguro de que deseas vaciar la cola actual?';

  @override
  String get queueCleared => 'Cola vaciada';

  @override
  String get locateCurrentSong => 'Localizar canción actual';

  @override
  String get songNotInScannedFolders =>
      'La canción actual no está en los directorios escaneados';

  @override
  String get queue => 'Cola';

  @override
  String get queueEmpty => 'La cola está vacía';

  @override
  String selectedSongs(int count) {
    return '$count canciones seleccionadas';
  }

  @override
  String get unknownArtist => 'Artista desconocido';

  @override
  String deletedSongs(int count) {
    return '$count canciones eliminadas';
  }

  @override
  String get delete => 'Eliminar';

  @override
  String get createPlaylist => 'Crear lista de reproducción';

  @override
  String get playlistName => 'Nombre de la lista';

  @override
  String get enterPlaylistName => 'Ingresa el nombre de la lista';

  @override
  String get playlistNameExists => 'El nombre de la lista ya existe';

  @override
  String get renamePlaylist => 'Renombrar lista';

  @override
  String get deletePlaylist => 'Eliminar lista de reproducción';

  @override
  String confirmDeletePlaylist(String name) {
    return '¿Estás seguro de que deseas eliminar la lista \"$name\"?';
  }

  @override
  String get addToPlaylist => 'Agregar a lista de reproducción';

  @override
  String get selectAll => 'Seleccionar todo';

  @override
  String get addToQueue => 'Agregar a la cola';

  @override
  String get addedToQueue => 'Agregado a la cola';

  @override
  String songCount(int count) {
    return '$count canciones';
  }

  @override
  String addedToPlaylist(int count, String playlist) {
    return 'Agregadas $count canciones a $playlist';
  }

  @override
  String get createNewList => 'Crear nueva lista';

  @override
  String createdPlaylist(String name, int count) {
    return 'Lista \"$name\" creada con $count canciones agregadas';
  }

  @override
  String get rename => 'Renombrar';

  @override
  String get playlist => 'Lista de reproducción';

  @override
  String get mostPlayed => 'Más reproducidas';

  @override
  String get recentlyPlayed => 'Reproducido recientemente';

  @override
  String get recentlyAdded => 'Agregadas recientemente';

  @override
  String get albums => 'Álbumes';

  @override
  String get artists => 'Artistas';

  @override
  String get mostPlayedDescription =>
      'Ordenadas por reproducciones completadas';

  @override
  String get recentlyPlayedDescription =>
      'Ordenado por tiempo de reproducción, incluyendo archivos externos';

  @override
  String get recentlyAddedDescription =>
      'Ordenadas por fecha de ingreso a la biblioteca';

  @override
  String get allTime => 'Todo el tiempo';

  @override
  String get pastWeek => 'Última semana';

  @override
  String get pastMonth => 'Último mes';

  @override
  String get past90Days => 'Últimos 90 días';

  @override
  String get noPlayHistory => 'Aún no hay historial de reproducción';

  @override
  String get noPlayHistoryInRange =>
      'No hay historial de reproducción en este período';

  @override
  String get noRecentlyPlayedSongs => 'Sin historial de reproducción';

  @override
  String get noRecentlyPlayedInRange =>
      'Sin historial de reproducción en este rango de tiempo';

  @override
  String get noRecentlyAddedSongs => 'Aún no hay canciones en tu biblioteca';

  @override
  String get noRecentlyAddedInRange =>
      'No se agregaron canciones nuevas en este período';

  @override
  String get addedOn => 'Agregado el';

  @override
  String get externalSourceTag => 'Externo';

  @override
  String get lastPlayed => 'Última reproducción';

  @override
  String playCountLabel(int count) {
    return '$count reproducciones';
  }

  @override
  String get playAll => 'Reproducir todo';

  @override
  String get shufflePlay => 'Reproducción aleatoria';

  @override
  String get noAlbums => 'Aún no hay álbumes disponibles para mostrar';

  @override
  String get noArtists => 'Aún no hay artistas disponibles para mostrar';

  @override
  String get searchAlbums => 'Buscar álbumes o artistas';

  @override
  String get searchArtists => 'Buscar artistas';

  @override
  String get albumSort => 'Ordenar';

  @override
  String get sortArtistAsc => 'Artista A-Z';

  @override
  String get sortTitleAsc => 'Título de álbum A-Z';

  @override
  String get sortTrackCount => 'Cantidad de canciones';

  @override
  String get sortDuration => 'Duración total';

  @override
  String get sortRecentAdded => 'Agregados recientemente';

  @override
  String get sortAscending => 'Ascendente';

  @override
  String get sortDescending => 'Descendente';

  @override
  String get playNext => 'Reproducir siguiente';

  @override
  String get addToFavorites => 'Agregar a favoritos';

  @override
  String get removeFromFavorites => 'Eliminar de favoritos';

  @override
  String get viewAlbumDetails => 'Ver detalles del álbum';

  @override
  String get viewArtistDetails => 'Ver detalles del artista';

  @override
  String get openFileLocation => 'Abrir ubicación del archivo';

  @override
  String get copyAlbumTitle => 'Copiar título del álbum';

  @override
  String get copyArtistName => 'Copiar nombre del artista';

  @override
  String albumCount(int count) {
    return '$count álbumes';
  }

  @override
  String get emptyList => 'La lista está vacía';

  @override
  String get dragToAddMusic =>
      'Arrastra archivos o carpetas para agregar música';

  @override
  String get unknownAlbum => 'Álbum desconocido';

  @override
  String get managePlaylists => 'Gestionar listas de reproducción';

  @override
  String get createNewPlaylist => 'Crear nueva lista de reproducción';

  @override
  String get defaultList => 'Lista predeterminada';

  @override
  String get playbackMode => 'Modo de reproducción';

  @override
  String get playbackOptions => 'Opciones de reproducción';

  @override
  String get setVisualizerDisplay => 'Configurar visualización del espectro';

  @override
  String get noPlaybackContent => 'Sin contenido de reproducción actual';

  @override
  String get file => 'Archivo';

  @override
  String get play => 'Reproducir';

  @override
  String get list => 'Biblioteca';

  @override
  String get queueTab => 'Cola';

  @override
  String get more => 'Más';

  @override
  String get settings => 'Configuración';

  @override
  String get themeMode => 'Tema';

  @override
  String get themeModeSystem => 'Seguir sistema';

  @override
  String get themeModeLight => 'Claro';

  @override
  String get themeModeDark => 'Oscuro';

  @override
  String get themeColor => 'Color del tema';

  @override
  String get customThemeColor => 'Color de tema personalizado';

  @override
  String get themeColorMikuTeal => 'Verde Miku';

  @override
  String get themeColorClassicBlue => 'Azul clásico';

  @override
  String get themeColorIrisPurple => 'Púrpura iris';

  @override
  String get themeColorViolet => 'Violeta';

  @override
  String get themeColorSakuraPink => 'Rosa sakura';

  @override
  String get themeColorCoralOrange => 'Naranja coral';

  @override
  String get themeColorAmberGold => 'Oro ámbar';

  @override
  String get themeColorForestGreen => 'Verde bosque';

  @override
  String get themeColorAuroraCyan => 'Cian aurora';

  @override
  String get themeColorCrimsonRed => 'Rojo carmesí';

  @override
  String get themeColorSlateGrey => 'Gris pizarra';

  @override
  String get immersiveTabBar => 'Barra de pestañas inmersiva';

  @override
  String get immersiveTabBarDescription =>
      'Muestra la barra de navegación al mover el mouse, la oculta tras 3 segundos sin actividad';

  @override
  String get collapseButtonsInLandscapeLyrics =>
      'Colapsar botones en modo letras horizontal';

  @override
  String get collapseButtonsInLandscapeLyricsDescription =>
      'Colapsa la fila de 7 botones, alinea el título a la izquierda y añade botones de acción a la derecha en modo letras horizontal';

  @override
  String get sampleStride => 'Paso de muestreo';

  @override
  String get sampleStrideDescription =>
      'Valores más grandes escanean más rápido pero con menor precisión de forma de onda (predeterminado: 4)';

  @override
  String get waveformSegments => 'Segmentos de forma de onda';

  @override
  String get waveformSegmentsDescription =>
      'Número de barras de forma de onda a mostrar (predeterminado: 80)';

  @override
  String get showDeveloperOptions => 'Mostrar opciones de desarrollador';

  @override
  String get playbackBackground => 'Fondo de reproducción';

  @override
  String get playbackRadialGradient => 'Degradado radial oscuro central';

  @override
  String get blurIntensity => 'Intensidad de desenfoque';

  @override
  String get blurredArtwork => 'Carátula borrosa (predeterminado)';

  @override
  String get dynamicMesh => 'Malla dinámica';

  @override
  String get solidColor => 'Color sólido';

  @override
  String get customImage => 'Imagen personalizada';

  @override
  String get presetColors => 'Colores preestablecidos';

  @override
  String get customColor => 'Color personalizado';

  @override
  String get uploadImage => 'Seleccionar imagen';

  @override
  String get normalOpacity => 'Opacidad de capa oscura normal';

  @override
  String get lyricsOpacity => 'Opacidad de capa oscura de letras';

  @override
  String get chooseImageError => 'Error al seleccionar imagen';

  @override
  String get noImageSelected => 'Ninguna imagen seleccionada';

  @override
  String get unknown => 'Desconocido';

  @override
  String get playlistModeSingle => 'Una canción';

  @override
  String get playlistModeSingleLoop => 'Una canción en bucle';

  @override
  String get playlistModeQueue => 'Lista de reproducción';

  @override
  String get playlistModeQueueLoop => 'Lista en bucle';

  @override
  String get playlistModeAutoQueueLoop => 'Lista automática en bucle';

  @override
  String get visualizer => 'Visualizador';

  @override
  String get previous => 'Anterior';

  @override
  String get next => 'Siguiente';

  @override
  String get pause => 'Pausa';

  @override
  String get autoMode => 'Modo automático';

  @override
  String get advancedOptions => 'Opciones avanzadas';

  @override
  String get spectrumQuantity => 'Cantidad de espectro';

  @override
  String get speed => 'Velocidad';

  @override
  String get quantityHigh => 'Alta';

  @override
  String get quantityMedium => 'Media';

  @override
  String get quantityLow => 'Baja';

  @override
  String get speedFast => 'Rápida';

  @override
  String get speedMedium => 'Media';

  @override
  String get speedSlow => 'Lenta';

  @override
  String get portraitFrequencyGroups => 'Cantidad de espectro vertical';

  @override
  String get landscapeFrequencyGroups => 'Cantidad de espectro horizontal';

  @override
  String get portraitGap => 'Espaciado vertical del espectro';

  @override
  String get landscapeGap => 'Espaciado horizontal del espectro';

  @override
  String get enableWaveformProgressBar =>
      'Activar barra de progreso de forma de onda';

  @override
  String get enableWaveformProgressBarDescription =>
      'Usar la forma de onda completa de la canción en lugar del control deslizante estándar';

  @override
  String get waveformLongPressSeekSpeed =>
      'Velocidad de avance con pulsación larga';

  @override
  String get waveformLongPressSeekSpeedDescription =>
      'Velocidad de reproducción al mantener pulsado el lado derecho de la barra de onda (×)';

  @override
  String get enableWaveformLongPressSeek =>
      'Activar avance con pulsación larga en onda';

  @override
  String get enableWaveformLongPressSeekDescription =>
      'Mantén pulsado el lado derecho de la barra de onda para avanzar rápido';

  @override
  String get randomMode => 'Modo aleatorio';

  @override
  String get randomHistory => 'Historial aleatorio';

  @override
  String get randomRange => 'Rango aleatorio';

  @override
  String get randomMethod => 'Método aleatorio';

  @override
  String get currentQueue => 'Cola actual';

  @override
  String get globalRange => 'Global (incluye todas las listas)';

  @override
  String get completeRandom => 'Completamente aleatorio';

  @override
  String get shuffleRandom => 'Aleatorio con barajar';

  @override
  String get randomQueue => 'Cola aleatoria';

  @override
  String get notSelected => 'Ninguna música seleccionada';

  @override
  String get saveTagsToFile => 'Guardar etiquetas en archivo';

  @override
  String get saveCurrentTagsToFile =>
      'Guardar etiquetas de la canción actual en archivo';

  @override
  String get saveQueueTagsToFile =>
      'Guardar todas las etiquetas de la cola en archivo';

  @override
  String get tagsSaved => 'Etiquetas guardadas exitosamente';

  @override
  String tagsSavedCount(Object count) {
    return 'Etiquetas guardadas ($count canciones)';
  }

  @override
  String get tagsSaveFailed => 'Error al guardar etiquetas';

  @override
  String tagsSaveFailedCount(Object count) {
    return 'Error al guardar $count canciones';
  }

  @override
  String unsupportedFormat(Object count) {
    return '$count canciones tienen formato no compatible (OGG/Opus no permite guardar etiquetas)';
  }

  @override
  String get unsupportedFormatSingle =>
      'Este formato (OGG/Opus) no admite guardar etiquetas';

  @override
  String get savingTags => 'Guardando etiquetas...';

  @override
  String get noModifiedTagsToSave =>
      'No hay etiquetas modificadas para guardar';

  @override
  String get clearPlaylist => 'Vaciar lista';

  @override
  String get copyTitle => 'Copiar título';

  @override
  String get transcodeAction => 'Transcodificar';

  @override
  String get transcodeSectionTitle => 'Transcodificación de audio';

  @override
  String get transcodeSectionDescription =>
      'Configurar el formato de salida predeterminado y la calidad preestablecida.';

  @override
  String get transcodeDefaultFormat => 'Formato de salida predeterminado';

  @override
  String get transcodeDefaultQuality => 'Calidad preestablecida predeterminada';

  @override
  String get transcodeTitle => 'Transcodificación de audio';

  @override
  String transcodeSongCount(int count) {
    return '$count canciones';
  }

  @override
  String transcodeCompletedCount(int count) {
    return 'Transcodificadas $count tareas completadas';
  }

  @override
  String transcodeCompletedWithFailures(int success, int total, int failed) {
    return 'Transcodificadas $success/$total tareas, $failed fallaron';
  }

  @override
  String get transcodeFailedGeneric => 'Transcodificación fallida';

  @override
  String get transcodePreparing => 'Preparando transcodificación...';

  @override
  String transcodeProgress(int current, int total) {
    return 'Transcodificando $current/$total';
  }

  @override
  String get transcoding => 'Transcodificando...';

  @override
  String get startTranscode => 'Iniciar transcodificación';

  @override
  String transcodeEngine(Object engine) {
    return 'Motor: $engine';
  }

  @override
  String get transcodeUsingSystemFfmpeg =>
      'Usando ffmpeg del PATH del sistema.';

  @override
  String transcodeUsingCustomFfmpeg(Object path) {
    return 'Usando ffmpeg personalizado: $path';
  }

  @override
  String get transcodeFormat => 'Formato de salida';

  @override
  String get transcodeQualityPreset => 'Calidad preestablecida';

  @override
  String get transcodeQualityLow => 'Baja';

  @override
  String get transcodeQualityMedium => 'Media';

  @override
  String get transcodeQualityHigh => 'Alta';

  @override
  String get transcodeQualityExtreme => 'Máxima';

  @override
  String get transcodeLosslessPresetHint =>
      'Este formato sin pérdida no usa niveles de calidad ni modo de control de bitrate.';

  @override
  String get transcodeAdvancedOptions => 'Opciones avanzadas';

  @override
  String get transcodeAdvancedCustomized =>
      'Los parámetros avanzados han sido modificados manualmente';

  @override
  String get transcodeAdvancedFollowingPreset =>
      'Los parámetros avanzados siguen la configuración actual';

  @override
  String get transcodeLosslessAdvancedHint =>
      'Este formato sin pérdida solo conserva las opciones avanzadas relacionadas con la fuente.';

  @override
  String get transcodeBitRateInvalid => 'Ingresa un bitrate válido';

  @override
  String get transcodeBitRate => 'Bitrate';

  @override
  String get transcodeBitRateMode => 'Modo de control de bitrate';

  @override
  String get transcodeEncodingEngine => 'Motor de codificación';

  @override
  String get transcodeSystemEncoder => 'Media3 (sistema)';

  @override
  String get transcodeFfmpegRustEncoder => 'FFmpeg (Rust)';

  @override
  String get transcodeAacEncoder => 'Codificador AAC';

  @override
  String get transcodeSampleRate => 'Frecuencia de muestreo';

  @override
  String get transcodeChannels => 'Canales';

  @override
  String get transcodeResetToPreset => 'Restablecer a la configuración actual';

  @override
  String get transcodeResetLosslessOptions =>
      'Restablecer opciones sin pérdida';

  @override
  String get transcodeOutputDirectory => 'Directorio de salida';

  @override
  String get transcodeOutputPreview => 'Vista previa';

  @override
  String get transcodeChooseDirectory => 'Seleccionar directorio';

  @override
  String get transcodeUseSourceDirectory => 'Usar directorio de origen';

  @override
  String get transcodeKeepSource => 'Conservar archivo fuente';

  @override
  String get transcodeMono => 'Mono';

  @override
  String get transcodeStereo => 'Estéreo';

  @override
  String get openFolderLocation => 'Abrir ubicación de la carpeta';

  @override
  String get songTagsSavedToSourceFileAndApp =>
      'Etiquetas de la canción guardadas en el archivo fuente y la app';

  @override
  String get songTagsSavedToApp =>
      'Etiquetas de la canción guardadas en la app';

  @override
  String get durationZero => '0:00';

  @override
  String get generateLyrics => 'Generar letras';

  @override
  String get generateTimeline => 'Generar línea de tiempo';

  @override
  String get queueGenerateLyrics => 'Poner en cola de generación';

  @override
  String get pauseAutoScroll => 'Pausar desplazamiento automático';

  @override
  String get resumeAutoScroll => 'Reanudar desplazamiento automático';

  @override
  String get translateLyrics => 'Traducir letras';

  @override
  String get clearLyricsCache => 'Limpiar caché de letras actual';

  @override
  String get clearTranslationCache => 'Limpiar caché de traducción actual';

  @override
  String get requery => 'Reconsultar';

  @override
  String get sleepTimerTitle => 'Temporizador de sueño';

  @override
  String get sleepTimerDescription =>
      'Elige una cuenta regresiva. Al terminar, la reproducción se pausará.';

  @override
  String get sleepTimerRunningTitle => 'Temporizador de sueño activo';

  @override
  String get sleepTimerRunningDescription =>
      'La reproducción se pausará automáticamente cuando termine la cuenta regresiva.';

  @override
  String get sleepTimerStopAfterCurrentSong =>
      'Detener después de la última canción';

  @override
  String get remainingTime => 'Tiempo restante';

  @override
  String get startCountdown => 'Iniciar cuenta regresiva';

  @override
  String get end => 'Fin';

  @override
  String get equalizer => 'Ecualizador';

  @override
  String get equalizerEnabledStatus => 'Ajuste de alta fidelidad activado';

  @override
  String get equalizerDisabledStatus => 'Desactivado';

  @override
  String get effects => 'Efectos';

  @override
  String get playbackSpeed => 'Velocidad de reproducción';

  @override
  String get normal => 'Normal';

  @override
  String get bassBoost => 'Refuerzo de graves';

  @override
  String get preampGain => 'Ganancia de previo';

  @override
  String get reset => 'Restablecer';

  @override
  String get close => 'Cerrar';

  @override
  String get timelineAdjustmentTitle => 'Ajustar línea de tiempo manualmente';

  @override
  String get timelineAdjustmentDescription =>
      'Arrastrar a la derecha retrasa las letras, arrastrar a la izquierda las adelanta.';

  @override
  String timelineOffsetEarlier(Object seconds) {
    return '${seconds}s adelantado';
  }

  @override
  String timelineOffsetLater(Object seconds) {
    return '${seconds}s retrasado';
  }

  @override
  String get timelineOffsetCurrent => 'Desplazamiento actual: 0.0 s';

  @override
  String get enterAcoustidApiKeyTitle => 'Ingresar clave API de AcoustID';

  @override
  String get acoustidApiKeyDescription =>
      'Se usa para identificación por huella de audio. Si se deja vacío, se restaurará la clave integrada.';

  @override
  String get acoustidApiKeyHint => 'Pega tu clave API de AcoustID';

  @override
  String get apiKey => 'Clave API';

  @override
  String get save => 'Guardar';

  @override
  String get enterLyricsTitle => 'Ingresar letras';

  @override
  String get lyricsInputHint =>
      'Pega o escribe letras aquí. Se admite texto multilínea.';

  @override
  String get enterGoogleAiStudioApiKeyTitle =>
      'Ingresar clave API de Google AI Studio';

  @override
  String get googleAiStudioApiKeyDescription =>
      'Se usa para generación de letras, generación de línea de tiempo y traducción en Google AI Studio.';

  @override
  String get pasteGoogleAiStudioApiKey => 'Pegar clave API de Google AI Studio';

  @override
  String get enterOpenRouterApiKeyTitle => 'Ingresar clave API de OpenRouter';

  @override
  String get openRouterApiKeyDescription =>
      'Se usa para generación de letras y línea de tiempo en OpenRouter. La traducción siempre usa Gemini.';

  @override
  String get pasteOpenRouterApiKey => 'Pegar clave API de OpenRouter';

  @override
  String get enterGeminiApiKeyTitle => 'Ingresar clave API de Gemini';

  @override
  String get geminiApiKeyDescription => 'Se usa para traducción de letras.';

  @override
  String get pasteGeminiApiKey => 'Pegar clave API de Gemini';

  @override
  String get testConnection => 'Probar conexión';

  @override
  String get enterApiKey => 'Por favor, ingresa una clave API.';

  @override
  String get testingConnection => 'Probando conexión...';

  @override
  String get getKey => 'Obtener clave';

  @override
  String get editSongTagsTitle => 'Editar etiquetas de la canción';

  @override
  String get changeArtwork => 'Cambiar carátula';

  @override
  String get clearArtwork => 'Limpiar carátula';

  @override
  String get editSongTagsDescription =>
      'Puedes guardar los cambios solo en la app o también escribirlos en el archivo fuente.';

  @override
  String get artistLabel => 'Artista';

  @override
  String get albumLabel => 'Álbum';

  @override
  String get trackNumberLabel => 'Número de pista';

  @override
  String get trackNumberMustBeInteger =>
      'El número de pista debe ser un entero';

  @override
  String get leaveBlankKeepsCurrentValue =>
      'Dejar en blanco para limpiar este campo';

  @override
  String get currentFileFormatCannotWriteBack =>
      'El formato de archivo actual no permite escribir en el archivo fuente. Solo se puede guardar en la app.';

  @override
  String get leaveBlankDoesNotClearOriginalValue =>
      'Consejo: dejar un campo en blanco limpiará su valor.';

  @override
  String get saveToApp => 'Guardar en la app';

  @override
  String get saveToSourceFileAndApp => 'Guardar en archivo fuente y app';

  @override
  String get saveToSourceFileFailed =>
      'Error al guardar en el archivo fuente. Asegúrate de que el formato admita escritura y el archivo no esté en uso.';

  @override
  String get fileOccupiedByOtherApp =>
      'El archivo está siendo usado por otra app, no se puede escribir';

  @override
  String get saveFailed => 'Error al guardar. Intenta de nuevo más tarde.';

  @override
  String apiKeySaved(Object provider) {
    return 'Clave API de $provider guardada';
  }

  @override
  String get apiKeySavedAcoustid => 'Clave API de AcoustID guardada';

  @override
  String get generalSectionTitle => 'Interfaz y comportamiento';

  @override
  String get generalSectionDescription =>
      'Configura la apariencia, las interacciones de reproducción y el comportamiento del sistema de ventanas.';

  @override
  String get uiAppearanceGroup => 'Apariencia y pantalla';

  @override
  String get playbackBehaviorGroup => 'Reproducción e interacción';

  @override
  String get systemWindowBehaviorGroup => 'Comportamiento de ventana y sistema';

  @override
  String get interfaceLanguage => 'Idioma de interfaz';

  @override
  String get interfaceLanguageDescription =>
      'Selecciona el idioma de visualización de la aplicación.';

  @override
  String get scanSectionTitle => 'Escaneo';

  @override
  String get scanSectionDescription =>
      'Estas opciones controlan cómo el escaneo de la biblioteca procesa los archivos de audio.';

  @override
  String get skipShortAudioDuringScan =>
      'Omitir audio corto durante el escaneo';

  @override
  String get skipShortAudioDuringScanDescription =>
      'El audio más corto que el umbral no se agregará a la biblioteca.';

  @override
  String get shortAudioScanThreshold => 'Umbral de audio corto';

  @override
  String get shortAudioScanThresholdDescription =>
      'Los archivos más cortos que esta duración serán omitidos.';

  @override
  String shortAudioScanThresholdValue(Object seconds) {
    return '$seconds s';
  }

  @override
  String get shortcutSettingsTitle => 'Atajos personalizados';

  @override
  String get shortcutSettingsDescription =>
      'Haz clic para volver a asignar y guardar atajos para las acciones del reproductor.';

  @override
  String get edit => 'Editar';

  @override
  String get lyricsSectionTitle => 'Letras';

  @override
  String get lyricsSectionDescription =>
      'Esta configuración solo afecta la generación de letras y línea de tiempo.';

  @override
  String get lyricsTranslationTargetLanguageLabel =>
      'Idioma de destino de traducción';

  @override
  String get lyricsTranslationTargetLanguageDescription =>
      'Por defecto sigue el idioma del sistema, o elige uno manualmente.';

  @override
  String get lyricsSaveMethodLabel => 'Ubicación de guardado de letras';

  @override
  String get lyricsSaveMethodDescription =>
      'Selecciona dónde se guardan las letras al escribir en el archivo.';

  @override
  String get lyricsSaveMethodOriginal => 'Como fuente';

  @override
  String get lyricsSaveMethodEmbedded => 'Incrustado';

  @override
  String get lyricsSaveMethodLrcFile => 'Archivo LRC';

  @override
  String get lyricsStyleLabel => 'Estilo de panel de letras';

  @override
  String get lyricsStyleDescription =>
      'Elija el estilo de visualización para el panel de letras.';

  @override
  String get lyricsStyleTraditional => 'Tradicional';

  @override
  String get lyricsStyleApple => 'Enfoque línea por línea';

  @override
  String get resumeLyricsSync => 'Reanudar sincronización';

  @override
  String get followSystemLanguage => 'Seguir sistema';

  @override
  String get autoSwitchLyricsProvider =>
      'Cambio automático de proveedor de letras';

  @override
  String get autoSwitchLyricsProviderEnabledDesc =>
      'Primero se solicita a Google AI Studio. Si falla, cambia automáticamente a OpenRouter.';

  @override
  String get autoSwitchLyricsProviderDisabledDesc =>
      'Necesitas claves API de Google AI Studio y OpenRouter para activar el cambio automático.';

  @override
  String get lyricsAiProviderTitle => 'Proveedor de IA para letras';

  @override
  String get lyricsAiProviderDescription =>
      'Esto solo afecta la generación de letras y línea de tiempo. La traducción siempre usa Google AI Studio.';

  @override
  String get googleAiStudioApiKeySaved =>
      'Clave API de Google AI Studio guardada';

  @override
  String get googleAiStudioApiKeyMissing =>
      'No hay clave API de Google AI Studio guardada. La generación de letras y línea de tiempo te lo notificarán.';

  @override
  String get openRouterApiKeySaved => 'Clave API de OpenRouter guardada';

  @override
  String get openRouterApiKeyMissing =>
      'No hay clave API de OpenRouter guardada. La generación de letras y línea de tiempo te lo notificarán.';

  @override
  String get apiKeySavedStatus => 'Guardada';

  @override
  String get apiKeyMissingStatus => 'Sin completar';

  @override
  String get platformApiKeysSectionTitle => 'Claves API de plataforma';

  @override
  String get fill => 'Completar';

  @override
  String get modify => 'Modificar';

  @override
  String get geminiModelsSectionTitle => 'Seleccionar modelo';

  @override
  String get geminiModelsSectionDescription =>
      'Estos modelos se usan para generación de letras, línea de tiempo y traducción en Google AI Studio.';

  @override
  String get primaryModelLabel => 'Modelo principal';

  @override
  String get backupModelLabel => 'Modelo de respaldo';

  @override
  String get translationModelLabel => 'Modelo de traducción';

  @override
  String get fetching => 'Obteniendo...';

  @override
  String get fetchModelList => 'Obtener lista de modelos';

  @override
  String get restoreDefault => 'Restaurar predeterminado';

  @override
  String get acoustidSectionTitle => 'Identificación por huella de audio';

  @override
  String get acoustidApiKeyTitle => 'Clave API de AcoustID';

  @override
  String get acoustidApiKeyHelp =>
      'AcoustID se usa para identificación por huella de audio. Recomendamos usar tu propia clave API.';

  @override
  String get acoustidApiKeySaved => 'Clave API de AcoustID guardada';

  @override
  String get acoustidApiKeyDefault =>
      'Actualmente se usa la clave integrada. Recomendamos solicitar tu propia clave.';

  @override
  String get applyForApiKey =>
      'Solicitar clave API: https://acoustid.org/new-application';

  @override
  String get queueTabBarFavoriteAdded => 'Agregado a favoritos';

  @override
  String get queueTabBarFavoriteRemoved => 'Eliminado de favoritos';

  @override
  String get tagCompletion => 'Complemento de etiquetas';

  @override
  String get tagCompletionDescription =>
      'Coincidir etiquetas con resultados de AcoustID y MusicBrainz';

  @override
  String get goToSettings => 'Ir a configuración';

  @override
  String get searchReleaseTitles => 'Buscar títulos de lanzamiento';

  @override
  String get closeSearch => 'Cerrar búsqueda';

  @override
  String get refreshResults => 'Actualizar resultados';

  @override
  String get filterMusicBrainzReleaseTitle =>
      'Filtrar títulos de lanzamiento de MusicBrainz';

  @override
  String get clearSearch => 'Limpiar búsqueda';

  @override
  String get localTitle => 'Título local';

  @override
  String get queryConditions => 'Condiciones de consulta';

  @override
  String get musicBrainzLoading => 'Consultando MusicBrainz';

  @override
  String get musicBrainzLoadingWithResults =>
      'Los resultados existentes se mantendrán en el panel';

  @override
  String get musicBrainzLoadingHint => 'Por favor espera';

  @override
  String get musicBrainzQueryFailed => 'Error en consulta a MusicBrainz';

  @override
  String get musicBrainzNetworkErrorHint =>
      'La solicitud a MusicBrainz falló, generalmente por conexión de red inestable, tiempo de espera o rechazo del servidor. Puedes intentar de nuevo más tarde.';

  @override
  String get musicBrainzFilteredEmptyHint =>
      'No hay títulos de lanzamiento que contengan esta palabra clave bajo los filtros actuales.';

  @override
  String get musicBrainzEmptyHint =>
      'MusicBrainz no devolvió resultados utilizables. Puedes intentar relajar los filtros de título, artista o álbum.';

  @override
  String get musicBrainzEmptyMoreCompleteHint =>
      'Puedes intentar de nuevo más tarde, o confirmar que la información del título/artista sea más completa.';

  @override
  String get retry => 'Reintentar';

  @override
  String get noMatchingRelease => 'No se encontró un lanzamiento coincidente';

  @override
  String get noMatchingResults => 'No se encontraron resultados coincidentes';

  @override
  String get networkConnectionFailed => 'Conexión de red fallida';

  @override
  String get searchAgain => 'Buscar de nuevo';

  @override
  String get acoustidRecognitionRecords =>
      'Registros de reconocimiento de AcoustID';

  @override
  String get musicBrainzRecordings => 'Grabaciones de MusicBrainz';

  @override
  String get noExpandableReleaseGroups =>
      'No hay grupos de lanzamiento expandibles';

  @override
  String get noExpandableReleases => 'No hay lanzamientos expandibles';

  @override
  String get noMatchingResultHint =>
      'Puedes intentar de nuevo más tarde, o confirmar que la información del título/artista sea más completa.';

  @override
  String releaseCountLabel(int count) {
    return '$count versiones de lanzamiento';
  }

  @override
  String recordingCountLabel(int count) {
    return '$count grabaciones';
  }

  @override
  String trackCountShort(int count) {
    return '$count pistas';
  }

  @override
  String scoreLabel(int score) {
    return 'Puntuación $score';
  }

  @override
  String matchScoreLabel(int score) {
    return 'Coincidencia $score%';
  }

  @override
  String get editQueryCondition => 'Editar condición de consulta';

  @override
  String get enterNewQueryText => 'Ingresa nuevo texto de consulta';

  @override
  String get durationLabel => 'Duración';

  @override
  String get customShortcuts => 'Atajos personalizados';

  @override
  String get pressShortcutCombo => 'Presiona la combinación de teclas';

  @override
  String get clickToRecord => 'Haz clic para configurar';

  @override
  String get searchingLyrics => 'Buscando letras';

  @override
  String get noLyrics => 'Sin letras aún';

  @override
  String get providerLabel => 'Proveedor';

  @override
  String get modelLabel => 'Modelo';

  @override
  String get unspecified => 'No especificado';

  @override
  String targetTimeLabel(String duration) {
    return 'Tiempo objetivo $duration';
  }

  @override
  String get songDeletedSkipped => 'Canción eliminada, saltada';

  @override
  String get songDeleted => 'Canción eliminada';

  @override
  String get lyricsTaskUploading => 'Subiendo';

  @override
  String get lyricsTaskWaiting => 'Esperando';

  @override
  String get lyricsTaskRequesting => 'Solicitando';

  @override
  String get lyricsTaskGenerating => 'Generando';

  @override
  String get lyricsTaskRetrying => 'Reintentando';

  @override
  String get lyricsTaskProcessing => 'Procesando';

  @override
  String get unknownModel => 'Modelo desconocido';

  @override
  String selectedFolders(int count) {
    return '$count carpetas seleccionadas';
  }

  @override
  String foldersDeleted(int count) {
    return '$count carpetas eliminadas';
  }

  @override
  String get persistentAccessDenied =>
      'No se pudo guardar el acceso a esa carpeta. Por favor, selecciónala de nuevo.';

  @override
  String get folderAddFailed => 'Error al agregar la carpeta';

  @override
  String get sleepTimer => 'Temporizador de sueño';

  @override
  String sleepTimerRemaining(Object duration) {
    return 'Temporizador de sueño $duration';
  }

  @override
  String get unknownArtistOrAlbum => 'Desconocido';

  @override
  String get pressAgainToExit =>
      'Presiona de nuevo para salir de la aplicación';

  @override
  String get tagCompletionSuccessWithCover =>
      'Etiquetas completadas y guardadas, carátula descargada al directorio temporal';

  @override
  String get tagCompletionSuccess => 'Etiquetas completadas y guardadas';

  @override
  String get selectOnlineLyrics => 'Seleccionar letras en línea';

  @override
  String get increaseLyricsFont => 'Aumentar tamaño de letra';

  @override
  String get decreaseLyricsFont => 'Reducir tamaño de letra';

  @override
  String get restoreDefaultSize => 'Restaurar tamaño predeterminado';

  @override
  String get adjustLyricsFont => 'Ajustar tamaño de texto';

  @override
  String get searchingOnlineLyrics => 'Buscando letras en línea';

  @override
  String get onlineLyricsResults => 'Resultados de letras en línea';

  @override
  String get untitledLyrics => 'Letras sin título';

  @override
  String get hasTimeline => 'Con línea de tiempo';

  @override
  String get viewLyricsDetails => 'Ver detalles de letras';

  @override
  String get lyricsDetails => 'Detalles de letras';

  @override
  String get lyricsContent => 'Contenido de letras';

  @override
  String get noLyricsContent => 'Sin contenido de letras';

  @override
  String get queryContentLabel => 'Contenido';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String dropAddedSongs(int addedCount) {
    return 'Agregadas $addedCount canciones';
  }

  @override
  String dropAddedSongsWithExisting(int addedCount, int existingCount) {
    return 'Agregadas $addedCount canciones, $existingCount ya existían';
  }

  @override
  String get copyCover => 'Copiar carátula al portapapeles';

  @override
  String get copyCoverSuccess =>
      'Carátula copiada al portapapeles exitosamente';

  @override
  String get searchLyricsPlaceholder =>
      'Ingresa el nombre de la canción, artista o letra para buscar';

  @override
  String get share => 'Compartir';

  @override
  String get windowsSettingsTitle => 'Configuración de Windows';

  @override
  String get fileAssociationTitle => 'Asociación de apertura de archivos';

  @override
  String get fileAssociationDescription =>
      'Asociar formatos de música comunes (mp3, flac, wav, etc.) con esta app para abrir con doble clic.';

  @override
  String get associateButton => 'Asociar';

  @override
  String get disassociateButton => 'Cancelar asociación';

  @override
  String get associationSuccess =>
      '¡Asociación exitosa! Si el doble clic no funciona, selecciona Vynody en Aplicaciones predeterminadas de Windows.';

  @override
  String get disassociationSuccess =>
      'Asociación de archivos eliminada exitosamente.';

  @override
  String associationFailed(Object error) {
    return 'Error al asociar: $error';
  }

  @override
  String get onboardingTitle => 'Bienvenido a Vynody';

  @override
  String get onboardingSubtitle =>
      'Solo unos simples pasos para comenzar tu viaje musical.';

  @override
  String get onboardingStepFileAssociation => 'Asociar tipos de archivo';

  @override
  String get onboardingFileAssociationDesc =>
      'Asocia formatos de música comunes (mp3, flac, wav, etc.) con Vynody para reproducir al hacer doble clic.';

  @override
  String get onboardingFileAssociationTip =>
      'Después de asociar, el sistema puede mostrar un menú de selección. Asegúrate de elegir \'Vynody\' y seleccionar \'Usar siempre\'.';

  @override
  String get onboardingStepRootDirectory => 'Añadir directorio de música';

  @override
  String get onboardingRootDirectoryDesc =>
      'Selecciona la carpeta donde están tus archivos de música. Vynody escaneará y creará tu biblioteca automáticamente.';

  @override
  String get onboardingAndroidPermissionTip =>
      'Nota: En Android, la importación y escaneo de música local requiere conceder permiso de acceso a la biblioteca multimedia. Al pulsar [Seleccionar carpeta] se solicitará el permiso, por favor permítalo.';

  @override
  String get onboardingSelectDirectory => 'Seleccionar carpeta';

  @override
  String get onboardingSuccessTitle => '¡Todo listo!';

  @override
  String get onboardingSuccessDesc =>
      'Biblioteca agregada exitosamente. ¡Disfruta de la música!';

  @override
  String get onboardingStartButton => 'Entrar a Vynody';

  @override
  String get onboardingSkip => 'Configurar después';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingBack => 'Anterior';

  @override
  String get resetOnboarding => 'Restablecer guía de inicio';

  @override
  String get resetOnboardingDesc =>
      'Limpiar el estado de la guía de inicio. Se volverá a mostrar al reiniciar la aplicación.';

  @override
  String get songProperties => 'Propiedades de la canción';

  @override
  String get failedToLoadDetails => 'No se pudieron cargar los detalles';

  @override
  String get noPropertiesAvailable =>
      'No hay propiedades detalladas disponibles';

  @override
  String get detailFilePath => 'Ruta del archivo';

  @override
  String get detailFormat => 'Formato';

  @override
  String get detailCodec => 'Códec';

  @override
  String get detailDuration => 'Duración';

  @override
  String get detailFileSize => 'Tamaño del archivo';

  @override
  String get detailBitrate => 'Bitrate';

  @override
  String get detailSampleRate => 'Frecuencia de muestreo';

  @override
  String get detailChannels => 'Canales';

  @override
  String get detailBitDepth => 'Profundidad de bits';

  @override
  String get detailMono => 'Mono';

  @override
  String get detailStereo => 'Estéreo';

  @override
  String detailChannelsCount(int count) {
    return '$count canales';
  }

  @override
  String get localNetworkPermissionDeniedTitle =>
      'Acceso a red local restringido';

  @override
  String get localNetworkPermissionDeniedMessage =>
      'No se detectó una dirección IP de red local disponible, o se denegó el permiso de red local.\n\nSigue estos pasos:\n1. Asegúrate de que el dispositivo esté conectado a Wi-Fi o red local.\n2. Asegúrate de permitir el acceso a la red local en Configuración > Privacidad y seguridad > Red local, activando Vynody.';

  @override
  String get localNetworkPermissionWindowsMessage =>
      'No se detectó una dirección IP de red local disponible.\n\nSigue estos pasos:\n1. Conéctate a una red local (Wi-Fi o Ethernet).\n2. Si sigue apareciendo el error, revisa el Firewall de Windows para permitir Vynody.';

  @override
  String get openSettingsButton => 'Ir a configuración';

  @override
  String get closeButton => 'Cerrar';

  @override
  String get copyTranslationResults => 'Copiar resultados de traducción';

  @override
  String get writeLyricsToFile => 'Escribir letras en archivo';

  @override
  String get selectLyricSource => 'Seleccionar origen de letras';

  @override
  String get regenerateLyrics => 'Regenerar letras';

  @override
  String get regenerateLyricsConfirmation =>
      'Se borrarán las letras actuales y se regenerarán. ¿Continuar?';

  @override
  String get regenerateTimeline => 'Regenerar línea de tiempo';

  @override
  String get regenerateTimelineConfirmation =>
      'Se borrará la línea de tiempo actual y se regenerará. ¿Continuar?';

  @override
  String get retranslateLyrics => 'Retraducir letras';

  @override
  String get retranslateLyricsConfirmation =>
      'Se borrará la traducción actual y se retraducirá. ¿Continuar?';

  @override
  String get translationCopiedToClipboard =>
      'Resultados de traducción copiados al portapapeles';

  @override
  String get writingLyrics => 'Escribiendo letras...';

  @override
  String get lyricsWrittenToFile =>
      'Letras escritas en el archivo exitosamente';

  @override
  String get writeLyricsFailed => 'Error al escribir letras';

  @override
  String get externalLrcFile => 'Archivo LRC externo con el mismo nombre';

  @override
  String get embeddedLyrics => 'Letras incrustadas en audio';

  @override
  String get manuallyAdjustedLyrics => 'Letras ajustadas manualmente';

  @override
  String get lrclibOnlineLyrics => 'Letras en línea de LrcLib';

  @override
  String get aiGeneratedLyrics => 'Letras generadas por IA';

  @override
  String get matchScore => 'Coincidencia';

  @override
  String get untitledRelease => 'Lanzamiento sin título';

  @override
  String get localSongFileNotFoundForGeneration =>
      'El archivo de la canción local no existe. No se pueden generar letras.';

  @override
  String get localSongFileNotFoundForTimeline =>
      'El archivo de la canción local no existe. No se puede generar línea de tiempo.';

  @override
  String get noLyricsForTimelineGeneration =>
      'No hay letras disponibles para generar línea de tiempo.';

  @override
  String get noLyricsAvailableForTranslation =>
      'No hay letras disponibles para traducir.';

  @override
  String get noCurrentSongAvailable => 'No hay una canción actual disponible.';

  @override
  String get invalidTargetLanguage => 'Idioma de destino no válido.';

  @override
  String get songAlreadyQueuedForTranslation =>
      'La canción actual ya está en cola para traducción o traduciéndose.';

  @override
  String get songAlreadyQueuedForGeneration =>
      'La canción actual ya está en cola para generación o generándose.';

  @override
  String get songNoLongerExistsForTranslation =>
      'La canción actual ya no existe. No se pueden traducir las letras.';

  @override
  String get generationFailed => 'Generación fallida.';

  @override
  String get generatingLyrics => 'Generando letras';

  @override
  String get generatingTimeline => 'Generando línea de tiempo';

  @override
  String get regeneratingLyrics => 'Regenerando letras';

  @override
  String get translatingLyrics => 'Traduciendo letras';

  @override
  String get transcodingSongFile => 'Transcodificando archivo de canción';

  @override
  String get uploadingSongFile => 'Subiendo archivo de canción';

  @override
  String get fileUploadedWaitingForReadiness =>
      'Archivo subido, esperando que esté listo';

  @override
  String get waitingForFileReadiness => 'Esperando que el archivo esté listo';

  @override
  String get requestingModelResponse => 'Solicitando respuesta del modelo';

  @override
  String retryingTaskKindGeneration(Object taskKind) {
    return 'Reintentando generación de $taskKind';
  }

  @override
  String get retrying => 'Reintentando';

  @override
  String get processing => 'Procesando';

  @override
  String get timeline => 'línea de tiempo';

  @override
  String get lyrics => 'letras';

  @override
  String lyricGenerationError(Object error) {
    return 'Error al generar letras: $error';
  }

  @override
  String timelineGenerationError(Object error) {
    return 'Error al generar línea de tiempo: $error';
  }

  @override
  String get unknownGenerationError => 'Error desconocido al generar letras.';

  @override
  String get unknownTimelineGenerationError =>
      'Error desconocido al generar línea de tiempo.';

  @override
  String get unknownTranslationError => 'Error desconocido al traducir letras.';

  @override
  String get unknownError => 'Error desconocido';

  @override
  String get modelRefusedToGenerateLyrics =>
      'El modelo se negó a generar letras.';

  @override
  String get modelRefusedToGenerateTimeline =>
      'El modelo se negó a generar la línea de tiempo.';

  @override
  String get doubaoPreUploadTranscodingFailed =>
      'Error de transcodificación de audio antes de la subida a Doubao.';

  @override
  String get doubaoTempTranscodeNotInTempDir =>
      'El archivo de transcodificación temporal de Doubao no se generó en el directorio temporal.';

  @override
  String get doubaoEmptyStreamingResponse =>
      'Doubao devolvió una respuesta de flujo vacía.';

  @override
  String get doubaoEmptyResponse => 'Doubao devolvió una respuesta vacía.';

  @override
  String get geminiEmptyStreamingResponse =>
      'Gemini devolvió una respuesta de flujo vacía.';

  @override
  String get geminiEmptyResponse => 'Gemini devolvió una respuesta vacía.';

  @override
  String get openRouterEmptyStreamingResponse =>
      'OpenRouter devolvió una respuesta de flujo vacía.';

  @override
  String get openRouterEmptyResponse =>
      'OpenRouter devolvió una respuesta vacía.';

  @override
  String get deepseekEmptyStreamingResponse =>
      'DeepSeek devolvió una respuesta de flujo vacía.';

  @override
  String get deepseekEmptyResponse => 'DeepSeek devolvió una respuesta vacía.';

  @override
  String get customProviderEmptyStreamingResponse =>
      'El proveedor personalizado devolvió una respuesta de flujo vacía.';

  @override
  String get customProviderEmptyResponse =>
      'El proveedor personalizado devolvió una respuesta vacía.';

  @override
  String get fileUploadFailed => 'Error al subir archivo. Intenta de nuevo.';

  @override
  String get uploadedFileNotReady =>
      'El archivo subido no pudo estar listo. Intenta de nuevo más tarde.';

  @override
  String get audioTranscodingFailed => 'Error de transcodificación de audio.';

  @override
  String get tempTranscodeNotInTempDir =>
      'El archivo de transcodificación temporal no se generó en el directorio temporal.';

  @override
  String get networkRequestFailedCheckProxy =>
      'Error de solicitud de red. Verifica tu conexión y configuración de proxy.';

  @override
  String get quotaExhaustedToday =>
      'La cuota de hoy se ha agotado. Espera a que se restablezca mañana.';

  @override
  String get googleAiHeavyLoad =>
      'Google AI está bajo gran carga y temporalmente no disponible.';

  @override
  String lyricsGenerationFailedWithError(Object error) {
    return 'Error al generar letras: $error';
  }

  @override
  String missingApiKeyForAction(Object action, Object providerName) {
    return 'No se encontró clave API de $providerName. No se puede $action.';
  }

  @override
  String get googleServerFlaky =>
      'Google está teniendo problemas. Intenta de nuevo y podría funcionar.';

  @override
  String get translateLyricsAction => 'traducir letras';

  @override
  String get generateLyricsAction => 'generar letras';

  @override
  String get generateTimelineAction => 'generar línea de tiempo';

  @override
  String get deepseekOnlyTranslation =>
      'DeepSeek solo admite traducción de letras.';

  @override
  String get customProviderOnlyTranslation =>
      'El proveedor personalizado solo admite traducción de letras.';

  @override
  String get customProviderNoBaseUrl =>
      'No se configuró la URL base del proveedor personalizado.';

  @override
  String get pleaseEnterApiKey => 'Por favor, ingresa una clave API.';

  @override
  String get connectionSuccessVerificationPassed =>
      'Conexión exitosa, verificación aprobada.';

  @override
  String connectionSuccessDetectedModels(Object count) {
    return 'Conexión exitosa, detectados $count modelos.';
  }

  @override
  String testFailedWithStatus(Object message, Object statusCode) {
    return 'Prueba fallida ($statusCode): $message';
  }

  @override
  String get testFailedCheckNetworkOrApiKey =>
      'Prueba fallida. Verifica tu red o clave API.';

  @override
  String testFailedStatusCheckApiKey(Object statusCode) {
    return 'Prueba fallida ($statusCode). Verifica si la clave API es válida.';
  }

  @override
  String get enterGoogleAiStudioApiKeyFirst =>
      'Primero ingresa una clave API de Google AI Studio.';

  @override
  String get enterDoubaoApiKeyFirst =>
      'Primero ingresa una clave API de Doubao.';

  @override
  String get enterDeepseekApiKeyFirst =>
      'Primero ingresa una clave API de DeepSeek.';

  @override
  String get enterCustomApiKeyAndBaseUrl =>
      'Primero ingresa la clave API personalizada y la URL base.';

  @override
  String fetchedCountModels(Object count) {
    return 'Obtenidos $count modelos.';
  }

  @override
  String requestFailedWithStatus(Object message, Object statusCode) {
    return 'Solicitud fallida ($statusCode): $message';
  }

  @override
  String get requestFailedCheckNetwork => 'Solicitud fallida. Verifica tu red.';

  @override
  String requestFailedStatus(Object statusCode) {
    return 'Solicitud fallida ($statusCode).';
  }

  @override
  String get doubao => 'Doubao';

  @override
  String get custom => 'Personalizado';

  @override
  String get noModelSelected => 'Ningún modelo seleccionado';

  @override
  String get acoustidRequestFailed => 'Solicitud a AcoustID fallida';

  @override
  String acoustidRequestReturnedStatus(Object statusCode) {
    return 'La solicitud a AcoustID devolvió $statusCode. Solicita tu propia clave API de AcoustID e ingrésala en configuración.';
  }

  @override
  String get writeTagDatabaseFailed =>
      'Error al escribir en la base de datos de etiquetas';

  @override
  String get playPause => 'Reproducir / Pausar';

  @override
  String get nextTrack => 'Siguiente';

  @override
  String get previousTrack => 'Anterior';

  @override
  String get volumeUp => 'Subir volumen';

  @override
  String get volumeDown => 'Bajar volumen';

  @override
  String get toggleMute => 'Activar/desactivar silencio';

  @override
  String get seekForward5s => 'Avanzar 5 segundos';

  @override
  String get seekBackward5s => 'Retroceder 5 segundos';

  @override
  String get toggleFullScreen => 'Activar/desactivar pantalla completa';

  @override
  String get playPauseDescription =>
      'Controla el estado de reproducción actual.';

  @override
  String get nextDescription => 'Cambia a la siguiente canción.';

  @override
  String get previousDescription => 'Cambia a la canción anterior.';

  @override
  String get volumeUpDescription => 'Aumenta el volumen un 5% cada vez.';

  @override
  String get volumeDownDescription => 'Reduce el volumen un 5% cada vez.';

  @override
  String get toggleMuteDescription => 'Activa o desactiva el silencio.';

  @override
  String get seekForward5sDescription => 'Avanza 5 segundos.';

  @override
  String get seekBackward5sDescription => 'Retrocede 5 segundos.';

  @override
  String get toggleFullScreenDescription =>
      'Alterna entre modo ventana y pantalla completa.';

  @override
  String get unknownKey => 'Tecla desconocida';

  @override
  String get removeFromQueue => 'Eliminar de la cola';

  @override
  String get removeFromPlaylist => 'Eliminar de la lista de reproducción';

  @override
  String get alreadyLatestVersion => 'Ya tienes la versión más reciente.';

  @override
  String get updateAvailable => 'Nueva versión disponible';

  @override
  String newVersionAvailable(Object version) {
    return 'Nueva versión v$version disponible. Ve a la página de GitHub Release para descargar.';
  }

  @override
  String get openRelease => 'Ir a Release';

  @override
  String get checkUpdateFailedNetwork =>
      'Error al buscar actualizaciones. Puede ser un problema de red o límite de GitHub.';

  @override
  String get tags => 'Etiquetas';

  @override
  String get about => 'Acerca de';

  @override
  String get rebuildIndex => 'Reconstruir índice';

  @override
  String get rebuildIndexDescription =>
      'Borrar todos los registros de canciones (excepto fuentes externas) y reescanear todos los directorios raíz.';

  @override
  String get rebuildIndexConfirmation =>
      '¿Confirmas que deseas borrar todos los registros de canciones y reescanear todos los directorios raíz? Esta operación tomará tiempo.';

  @override
  String get rebuildIndexStarted => 'Reconstrucción de índice iniciada';

  @override
  String get rebuild => 'Reconstruir';

  @override
  String get advanced => 'Avanzado';

  @override
  String get advancedOptionsDescription =>
      'Opciones más orientadas a depuración y control de comportamiento.';

  @override
  String get showDeveloperOptionsDescription =>
      'Muestra más opciones avanzadas para depuración.';

  @override
  String get onboardingReset =>
      'Guía de inicio restablecida. Se aplicará al reiniciar.';

  @override
  String get tagsSectionDescription =>
      'Configuración sobre metadatos de archivos de audio y autocompletado.';

  @override
  String get autoSaveToSourceFile => 'Guardado automático en archivo fuente';

  @override
  String get autoSaveToSourceFileDescription =>
      'Al completar o actualizar etiquetas de canciones, se escribe automáticamente en el archivo de audio físico.';

  @override
  String get aboutSectionDescription =>
      'Información de versión, enlaces del proyecto y materiales relacionados.';

  @override
  String get checkForUpdates => 'Verificar actualizaciones';

  @override
  String get storeUpdateNotice =>
      'Las actualizaciones de esta aplicación son administradas por Microsoft Store. Puede buscar la versión más reciente en Microsoft Store.';

  @override
  String get openMicrosoftStore => 'Ir a Microsoft Store';

  @override
  String get appStoreUpdateNotice =>
      'Las actualizaciones de esta app las gestiona App Store. Puedes consultar o descargar la última versión en App Store.';

  @override
  String get openAppStore => 'Ir a App Store';

  @override
  String get lyricsGenerationModel => 'Modelo de generación de letras';

  @override
  String get lyricsGenerationModelDescription =>
      'Para que la IA genere letras a partir de la canción y genere/corrija la línea de tiempo de letras existentes.';

  @override
  String get lyricsTranslationModel => 'Modelo de traducción de letras';

  @override
  String get lyricsTranslationModelDescription =>
      'Para traducir letras al idioma de destino.';

  @override
  String get onlyForLyricTranslation => 'Solo para traducción de letras';

  @override
  String get fillApiKeyFirstEnablesModels =>
      'Primero completa al menos una clave API para habilitar la selección de modelos.';

  @override
  String get customApiProvider => 'Proveedor de API personalizado';

  @override
  String get clearedGoogleAiStudioApiKey =>
      'Clave API de Google AI Studio borrada';

  @override
  String get clearedOpenRouterApiKey => 'Clave API de OpenRouter borrada';

  @override
  String get clearedDoubaoApiKey => 'Clave API de Doubao borrada';

  @override
  String get clearedDeepseekApiKey => 'Clave API de DeepSeek borrada';

  @override
  String get clearedCustomProviderConfig =>
      'Configuración de proveedor personalizado borrada';

  @override
  String get savedDoubaoApiKey => 'Clave API de Doubao guardada';

  @override
  String get savedDeepseekApiKey => 'Clave API de DeepSeek guardada';

  @override
  String get savedCustomProviderConfig =>
      'Configuración de proveedor personalizado guardada';

  @override
  String get noMatchingFoldersOrSongs =>
      'No se encontraron carpetas o canciones que coincidan';

  @override
  String get searching => 'Buscando...';

  @override
  String get listView => 'Vista de lista';

  @override
  String get gridView => 'Vista de cuadrícula';

  @override
  String get hybridView => 'Vista híbrida';

  @override
  String songsCountFormat(Object count) {
    return '$count canciones';
  }

  @override
  String get searchInFolderAndSubfolders =>
      'Buscar en el directorio actual y subdirectorios...';

  @override
  String get shuffle => 'Aleatorio';

  @override
  String get search => 'Buscar';

  @override
  String get selectFolders => 'Seleccionar directorios';

  @override
  String get removeDirectory => 'Eliminar directorio';

  @override
  String removeRootDirectoryConfirmation(Object name) {
    return '¿Estás seguro de que deseas eliminar el directorio raíz \"$name\"? Esta operación no eliminará los archivos físicos del disco.';
  }

  @override
  String get deselectAll => 'Deseleccionar todo';

  @override
  String get favorites => 'Favoritos';

  @override
  String get aggregationPeak => 'Pico';

  @override
  String get aggregationMean => 'Media';

  @override
  String get aggregationRms => 'RMS';

  @override
  String get filesToTranscode => 'Archivos para transcodificar';

  @override
  String get chooseAndroidOutputDirectoryFirst =>
      'Primero selecciona un directorio de salida de Android.';

  @override
  String currentSongProgressPercent(Object percent) {
    return 'Canción actual $percent%';
  }

  @override
  String overallProgressPercent(Object percent) {
    return 'General $percent%';
  }

  @override
  String get pleaseChooseOutputDirectory =>
      'Primero selecciona un directorio de salida.';

  @override
  String selectedArtistsCount(Object count) {
    return '$count artistas seleccionados';
  }

  @override
  String selectedAlbumsCount(Object count) {
    return '$count álbumes seleccionados';
  }

  @override
  String get simplifiedChinese => 'Chino simplificado';

  @override
  String get traditionalChinese => 'Chino tradicional';

  @override
  String get chineseLanguage => 'Chino';

  @override
  String get englishLanguage => 'Inglés';

  @override
  String get japaneseLanguage => 'Japonés';

  @override
  String get koreanLanguage => 'Coreano';

  @override
  String get frenchLanguage => 'Francés';

  @override
  String get germanLanguage => 'Alemán';

  @override
  String get spanishLanguage => 'Español';

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
  String get nativeLanguageEs => 'Español';

  @override
  String get portugueseLanguage => 'Portugués';

  @override
  String get russianLanguage => 'Ruso';

  @override
  String get systemLanguage => 'Idioma del sistema';

  @override
  String get targetLanguage => 'Idioma de destino';

  @override
  String get whatAreAiLyrics => '¿Qué son las letras con IA?';

  @override
  String get whatIsAiLyricTranslation =>
      '¿Qué es la traducción de letras con IA?';

  @override
  String get aiLyricsIntroGeneration =>
      'La IA puede generar letras basadas en la canción y alinearlas automáticamente con la línea de tiempo.';

  @override
  String get aiLyricsIntroTranslation =>
      'La IA puede traducir las letras a tu idioma preferido para facilitar la comprensión.';

  @override
  String get whyNeedApiKey => '¿Por qué necesito una clave API?';

  @override
  String get apiKeyExplanation =>
      'La clave API es tu credencial de acceso al proveedor de IA. La app la usa para solicitar generación de letras, ajuste de línea de tiempo o traducción.';

  @override
  String get apiKeyLocalOnly =>
      'La clave API solo se guarda en tu dispositivo local y nunca se envía a los servidores de Vynody.';

  @override
  String get chooseAnAiProvider => 'Elige un proveedor de IA:';

  @override
  String get googleProviderPros =>
      'Canal oficial de Google, modelos Gemini potentes y cuotas gratuitas generosas.';

  @override
  String get googleProviderCons =>
      'La conexión directa desde China continental está restringida y requiere una VPN/proxy estable. El tráfico alto puede causar errores 429; cambia a otro proveedor si esto ocurre.';

  @override
  String get openRouterProviderPros =>
      'Plataforma agregadora de modelos del extranjero, con acceso a múltiples modelos y algunos gratuitos.';

  @override
  String get openRouterProviderCons =>
      'Las recargas tienen comisiones y el sitio web solo está en inglés.';

  @override
  String get doubaoProviderPros =>
      'De ByteDance, acceso rápido desde China, buenos resultados en chino. Nuevos usuarios tienen 500k tokens gratis por modelo.';

  @override
  String get doubaoProviderCons =>
      'El registro es relativamente complicado y requiere verificación de identidad.';

  @override
  String get deepseekProviderPros =>
      'Buena comprensión de chino, precio económico, ideal para traducción de letras.';

  @override
  String get deepseekProviderCons =>
      'Solo admite entrada de texto. Para generar letras o ajustar línea de tiempo, se necesita otro proveedor.';

  @override
  String get highlights => 'Características';

  @override
  String get notes => 'Notas';

  @override
  String enterProviderApiKey(Object provider) {
    return 'Ingresa tu clave API de $provider:';
  }

  @override
  String get pasteYourApiKey => 'Pega tu clave API aquí';

  @override
  String get getApiKey => 'Obtener clave API';

  @override
  String get testConnectionButton => 'Probar conexión';

  @override
  String get enableAiLyricGeneration => 'Activar generación de letras con IA';

  @override
  String get enableAiLyricTranslation => 'Activar traducción de letras con IA';

  @override
  String get notNow => 'Ahora no';

  @override
  String get startSetup => 'Comenzar configuración';

  @override
  String get chooseAiProvider => 'Elegir proveedor de IA';

  @override
  String get backStep => 'Anterior';

  @override
  String get continueAction => 'Continuar';

  @override
  String get nextStep => 'Siguiente';

  @override
  String get configureApiKey => 'Configurar clave API';

  @override
  String get saveAndFinish => 'Guardar y finalizar';

  @override
  String get testing => 'Probando...';

  @override
  String get noteTitle => 'Nota';

  @override
  String get deepseekTextInputOnlyNote =>
      'DeepSeek solo admite entrada de texto. Para generar letras o ajustar línea de tiempo, se necesita otro proveedor.';

  @override
  String retryAttemptOfMax(Object attempt, Object maxRetry) {
    return 'Intento $attempt de $maxRetry';
  }

  @override
  String generatingTaskKind(Object taskKind) {
    return 'Generando $taskKind';
  }

  @override
  String connectionTestException(Object error) {
    return 'Error de prueba de conexión: $error';
  }

  @override
  String get testingConnectionProgress => 'Probando conexión...';

  @override
  String get clear => 'Limpiar';

  @override
  String get enterDoubaoApiKey => 'Ingresar clave API de Doubao';

  @override
  String get doubaoApiKeyDescription =>
      'Ingresa tu clave API de Volcano/Doubao para generación y traducción de letras.';

  @override
  String get enterDeepseekApiKey => 'Ingresar clave API de DeepSeek';

  @override
  String get deepseekApiKeyDescription =>
      'Ingresa tu clave API de DeepSeek solo para traducción de letras.';

  @override
  String get pleaseEnterApiKeyHint => 'Por favor, ingresa la clave API';

  @override
  String get platform => 'Plataforma';

  @override
  String get showRecommendedOnly => 'Mostrar solo modelos recomendados';

  @override
  String get noAvailableChannels => 'No hay canales disponibles';

  @override
  String get noMatchingModels => 'No se encontraron modelos coincidentes';

  @override
  String get leaveEmpty => 'Dejar vacío';

  @override
  String get leaveEmptyFallbackDescription =>
      'Selecciona esto para no establecer un modelo de respaldo.';

  @override
  String get modelSearchHint => 'Ingresa nombre o ID del modelo';

  @override
  String sendFilesFailed(Object error) {
    return 'Error al enviar archivos: $error';
  }

  @override
  String get scanningFolderMusic =>
      'Escaneando la carpeta en busca de archivos de música...';

  @override
  String scanFolderFailed(Object error) {
    return 'Error al escanear la carpeta: $error';
  }

  @override
  String get noMusicFilesFound =>
      'No se encontraron archivos de música compatibles en esta carpeta';

  @override
  String sendFolderFailed(Object error) {
    return 'Error al enviar la carpeta: $error';
  }

  @override
  String get lanSharingStartFailed =>
      'Error al iniciar el uso compartido en LAN. Verifica que los permisos de red local estén habilitados.';

  @override
  String syncingLyricsToDevice(Object deviceName) {
    return 'Sincronizando letras con $deviceName...';
  }

  @override
  String syncLyricsSuccess(Object matched, Object overwritten, Object skipped) {
    return 'Sincronización exitosa: $matched coincidieron, $overwritten actualizadas, $skipped omitidas';
  }

  @override
  String syncLyricsFailed(Object error) {
    return 'Error al sincronizar letras: $error';
  }

  @override
  String syncingLyricsFromDevice(Object deviceName) {
    return 'Recibiendo letras de $deviceName...';
  }

  @override
  String get transferInProgressDoNotLeave =>
      'Transferencia en curso. No salgas de la página de uso compartido.';

  @override
  String get lanSharingTitle => 'Conexión LAN';

  @override
  String get lanSharingEnabledStatus => 'Uso compartido en LAN activado';

  @override
  String get lanSharingDisabledStatus => 'Uso compartido en LAN desactivado';

  @override
  String lanSharingRunningStatus(Object ip, Object port) {
    return 'IP local: $ip (Puerto: $port)';
  }

  @override
  String get lanSharingDefaultOffHint =>
      'Desactivado por defecto. Al activarlo se solicitará permiso de LAN.';

  @override
  String get receiveDirectoryNotSetWarning =>
      'No se ha establecido un directorio de recepción. Se recomienda configurarlo.';

  @override
  String receiveDirectoryUpdated(Object path) {
    return 'Directorio de recepción actualizado a: $path';
  }

  @override
  String get receiveDirectoryTitle => 'Directorio de recepción de archivos';

  @override
  String get linkCopiedToClipboard => 'Enlace copiado al portapapeles';

  @override
  String get nearbyDevices => 'Dispositivos cercanos';

  @override
  String get searchingDevices => 'Buscando otros dispositivos en la LAN...';

  @override
  String get startSharingToFindDevices =>
      'Activa el uso compartido para comenzar a buscar dispositivos';

  @override
  String get deviceOnline => 'En línea';

  @override
  String get deviceOffline => 'Desconectado';

  @override
  String get sendMusicFiles => 'Enviar archivos de música';

  @override
  String get sendFolder => 'Enviar carpeta';

  @override
  String get syncLyricsToDeviceAction =>
      'Sincronizar letras a este dispositivo';

  @override
  String get syncLyricsFromDeviceAction =>
      'Sincronizar letras desde este dispositivo';

  @override
  String loadDevicesError(Object error) {
    return 'Error al cargar dispositivos: $error';
  }

  @override
  String incomingFilesFormat(Object name1, Object name2, Object count) {
    return '$name1, $name2 y otros $count archivos';
  }

  @override
  String get incomingTransferRequestTitle =>
      'Solicitud de transferencia de archivos entrante';

  @override
  String incomingTransferFrom(Object senderName) {
    return 'Solicitud de \"$senderName\":';
  }

  @override
  String fileSizeMb(Object sizeMb) {
    return 'Tamaño del archivo: $sizeMb MB';
  }

  @override
  String get receiveFileHint =>
      'Los archivos recibidos se guardarán automáticamente en la carpeta de música local y se agregarán a la biblioteca.';

  @override
  String get reject => 'Rechazar';

  @override
  String get accept => 'Aceptar';

  @override
  String get incomingLyricsExportTitle => 'Solicitud de exportación de letras';

  @override
  String incomingLyricsExportFrom(Object senderName) {
    return 'El dispositivo \"$senderName\" solicitó leer y exportar la biblioteca de letras.';
  }

  @override
  String get incomingLyricsImportTitle => 'Solicitud de importación de letras';

  @override
  String incomingLyricsImportFrom(Object senderName, Object count) {
    return 'El dispositivo \"$senderName\" solicitó importar letras para $count canciones.';
  }

  @override
  String get lyricsRequestRejected =>
      'El dispositivo remoto rechazó la solicitud de sincronización de letras.';

  @override
  String sendCompleted(Object fileName) {
    return '\"$fileName\" enviado';
  }

  @override
  String receiveCompleted(int count) {
    return '$count canciones recibidas exitosamente';
  }

  @override
  String transferCancelledWithReason(Object direction, Object reason) {
    return '$direction cancelada ($reason)';
  }

  @override
  String transferFailedFormat(Object direction, Object fileName) {
    return '$direction \"$fileName\" falló';
  }

  @override
  String sendingToDevice(Object deviceName) {
    return 'Enviando a $deviceName';
  }

  @override
  String receivingFromDevice(Object deviceName) {
    return 'Recibiendo de $deviceName';
  }

  @override
  String progressFormat(Object percent) {
    return 'Progreso: $percent%';
  }

  @override
  String get currentlyTransferring => 'Transfiriendo actualmente';

  @override
  String get fileConflictTitle => 'Conflicto de archivos';

  @override
  String get fileConflictMessage =>
      'El dispositivo de destino ya tiene un archivo con el mismo nombre:';

  @override
  String get fileConflictChooseAction => 'Selecciona la acción a realizar:';

  @override
  String get skipAction => 'Saltar';

  @override
  String get overwriteAction => 'Sobrescribir';

  @override
  String get skipAllAction => 'Saltar todo';

  @override
  String get overwriteAllAction => 'Sobrescribir todo';

  @override
  String get sendDirection => 'Enviar';

  @override
  String get receiveDirection => 'Recibir';

  @override
  String get fileAssociationEnabled => 'Asociación activada';

  @override
  String get fileAssociationDisabled => 'Asociación desactivada';

  @override
  String get windowsAutoRepairShortcut =>
      'Reparar acceso directo del menú Inicio automáticamente';

  @override
  String get windowsAutoRepairShortcutDescription =>
      'Verificar y crear el acceso directo del menú Inicio en cada inicio para mostrar el nombre e icono correctos del control multimedia';

  @override
  String get confirmDisableShortcutRepair => '¿Deshabilitar esta función?';

  @override
  String get confirmDisableShortcutRepairContent =>
      'Sin el acceso directo del menú Inicio, los controles multimedia de Windows pueden mostrar la app como \"Desconocida\" y sin icono. ¿Está seguro de que desea deshabilitar esto?';

  @override
  String get confirmDisable => 'Deshabilitar';

  @override
  String get enableSystemTray => 'Habilitar bandeja del sistema';

  @override
  String get enableSystemTrayDescription =>
      'Mostrar icono en la bandeja del sistema para control rápido de reproducción';

  @override
  String get closeToTray => 'Minimizar a la bandeja al cerrar';

  @override
  String get closeToTrayDescription =>
      'Mantener la reproducción en segundo plano al cerrar la ventana principal sin salir de la aplicación';

  @override
  String get closeWindowActionTitle => 'Al cerrar la ventana';

  @override
  String get closeWindowActionDescription =>
      'Elegir qué hacer al hacer clic en el botón de cerrar la ventana principal';

  @override
  String get closeWindowActionAsk => 'Preguntar siempre';

  @override
  String get closeWindowActionMinimize => 'Minimizar a la bandeja del sistema';

  @override
  String get closeWindowActionExit => 'Salir de la aplicación';

  @override
  String get closeWindowActionRemember =>
      'Recordar mi elección y no volver a preguntar';

  @override
  String get closeWindowActionTrayDisabledTip =>
      '(Debe habilitar la bandeja del sistema primero)';

  @override
  String get closeWindowDialogTitle => 'Confirmación de cierre';

  @override
  String get closeWindowDialogContent =>
      'Por favor seleccione la acción al hacer clic en el botón cerrar:';

  @override
  String get googleAiStudioApiKey => 'Google AI Studio API Key';

  @override
  String get openRouterApiKey => 'OpenRouter API Key';

  @override
  String get doubaoApiKey => 'Doubao API Key';

  @override
  String get deepseekApiKey => 'DeepSeek API Key';

  @override
  String get unexpectedResponseFormat => 'Formato de respuesta inesperado.';

  @override
  String get baseUrl => 'Base URL';

  @override
  String get openaiCompatibleEndpoint =>
      'Punto de conexión de API compatible con OpenAI';

  @override
  String onboardingAddedDirectoriesCount(Object count) {
    return 'Directorios añadidos ($count):';
  }

  @override
  String get gnomeDisksOpenFailed =>
      'No se pudo abrir la Utilidad de Discos automáticamente. Abra \"Discos\" manualmente desde el menú de aplicaciones.';

  @override
  String get gnomeDisksNotInstalled =>
      'gnome-disks no está instalado. Abra la utilidad de discos de su sistema para configurar.';

  @override
  String get linuxMountGuideTitle => 'Configurar montaje automático de disco';

  @override
  String get linuxMountGuideDescription =>
      'Por defecto, Linux no monta automáticamente las particiones externas. Si no configura el montaje al inicio, la ruta de las particiones externas puede cambiar tras cada reinicio, impidiendo que el reproductor acceda al directorio de música. Para evitarlo, configure la partición que contiene su música para que se monte automáticamente al inicio.';

  @override
  String get linuxMountGuideWarning =>
      'Advertencia: Si su música se encuentra en una partición de disco externa o interna que requiere montaje, DEBE configurarla para \"montarse automáticamente al inicio del sistema\". De lo contrario, es posible que no se encuentre el directorio de música después de reiniciar o que se le solicite ingresar una contraseña para acceder a él.';

  @override
  String get linuxMountGuideStep1 =>
      '1. Abra la utilidad \"Discos\" del sistema';

  @override
  String get linuxMountGuideStep2 =>
      '2. Seleccione la partición de música, haga clic en el icono de engranaje ⚙️ (Opciones adicionales de partición)';

  @override
  String get linuxMountGuideStep3 =>
      '3. Seleccione \"Editar opciones de montaje\", desactive \"Valores predeterminados de sesión de usuario\" y marque \"Montar al inicio del sistema\"';

  @override
  String get linuxMountGuideOpenButton =>
      'Abrir Administrador de discos (Disks)';

  @override
  String get unmute => 'Activar sonido';

  @override
  String get mute => 'Silenciar';

  @override
  String get disableSystemTray => 'Deshabilitar bandeja del sistema';

  @override
  String get restoreWindow => 'Restaurar ventana';

  @override
  String get hideWindow => 'Ocultar ventana';

  @override
  String get onboardingAndroidBatteryTitle =>
      'Protección de reproducción en segundo plano';

  @override
  String get onboardingAndroidBatteryDescription =>
      'Debido a las estrictas políticas de optimización de batería de Android, para evitar que la reproducción de música se detenga en segundo plano, recomendamos configurar la restricción de batería de Vynody a «Sin restricciones» (Unrestricted).';

  @override
  String get onboardingAndroidBatteryStep1 =>
      '1. Toque el botón «Ir a Ajustes» a continuación.';

  @override
  String get onboardingAndroidBatteryStep2 =>
      '2. Permita omitir las optimizaciones de batería en el cuadro de diálogo del sistema o vaya a los ajustes de batería.';

  @override
  String get onboardingAndroidBatteryStep3 =>
      '3. Si es redirigido a los ajustes, seleccione «Sin restricciones».';

  @override
  String get onboardingAndroidBatteryButton => 'Ir a Ajustes';

  @override
  String get onboardingAndroidBatteryStatusOptimized =>
      'Estado: Restringido (la reproducción puede detenerse en segundo plano)';

  @override
  String get onboardingAndroidBatteryStatusUnrestricted =>
      'Estado: Sin restricciones (recomendado, reproducción protegida)';

  @override
  String get onboardingAndroidMediaTitle => 'Acceder a la biblioteca de música';

  @override
  String get onboardingAndroidMediaDescription =>
      'Una vez concedido el permiso, Vynody podrá leer directamente toda la música de la biblioteca del sistema sin seleccionar carpetas manualmente. También puede importar carpetas manualmente sin conceder el permiso.';

  @override
  String get onboardingAndroidMediaStep1 =>
      '1. Listo para usar: Muestra instantáneamente toda la música de tu teléfono';

  @override
  String get onboardingAndroidMediaStep2 =>
      '2. Detección automática: La música nueva aparece automáticamente en la biblioteca';

  @override
  String get onboardingAndroidMediaStep3 =>
      '3. Privacidad garantizada: Solo lee archivos de audio locales y no sube automáticamente tu biblioteca (excepto al usar servicios en la nube como letras IA)';

  @override
  String get onboardingAndroidMediaButton =>
      'Conceder acceso a la biblioteca de música';

  @override
  String get onboardingAndroidMediaStatusGranted =>
      'Estado: Concedido (Recomendado)';

  @override
  String get onboardingAndroidMediaStatusNotGranted =>
      'Estado: No concedido (puede importar carpetas manualmente más tarde)';

  @override
  String get exitApp => 'Salir';

  @override
  String get showScanProgressToastSetting =>
      'Mostrar toast de estado de escaneo';

  @override
  String get showScanProgressToastSettingDescription =>
      'Muestra el progreso de escaneo en tiempo real en la parte superior de la pantalla al escanear carpetas.';

  @override
  String get openPlaybackOnDirectorySongTap =>
      'Ir a la página de reproducción al tocar una canción';

  @override
  String get openPlaybackOnDirectorySongTapDescription =>
      'Abre automáticamente la página de reproducción al tocar una canción en la vista de carpetas.';

  @override
  String get defaultToLyricsModeOnPlaybackOpen =>
      'Modo de letras por defecto en la página de reproducción';

  @override
  String get defaultToLyricsModeOnPlaybackOpenDescription =>
      'Muestra automáticamente el modo de letras al abrir la página de reproducción.';

  @override
  String get tapCoverToEnterLyricsMode =>
      'Toca la portada para entrar en modo letras';

  @override
  String get longPressLyricsPanelToOpenMenu =>
      'Mantén presionado el panel de letras para abrir el menú';

  @override
  String get gotIt => 'Entendido';

  @override
  String get scanToastHiddenHint =>
      'Toast de estado de escaneo oculto. Puede volver a habilitarlo en Ajustes - Interfaz.';

  @override
  String get doubleSpeedPlayingSwipeUpToLock =>
      'Avance rápido... Desliza hacia arriba para bloquear';

  @override
  String get doubleSpeedLockedSwipeDownToUnlock =>
      'Avance rápido bloqueado. Mantén presionado y desliza hacia abajo para desbloquear';

  @override
  String get doubleSpeedUnlocked => 'Avance rápido desbloqueado';

  @override
  String get lyricsImportExportHeader => 'Importar y exportar';

  @override
  String get exportAction => 'Exportar';

  @override
  String get importAction => 'Importar';

  @override
  String get exportLyricsLabel => 'Exportar copia de letras';

  @override
  String get exportLyricsDescription =>
      'Exportar todas las letras en caché y ajustadas a un archivo JSON';

  @override
  String get importLyricsLabel => 'Importar copia de letras';

  @override
  String get importLyricsDescription =>
      'Importar caché de letras desde un archivo JSON exportado';

  @override
  String exportSuccess(int count) {
    return '$count letras exportadas exitosamente.';
  }

  @override
  String exportFailed(String error) {
    return 'Error al exportar: $error';
  }

  @override
  String importSuccess(int count) {
    return '¡Importación completa! $count letras importadas exitosamente.';
  }

  @override
  String importFailed(String error) {
    return 'Error al importar: $error';
  }

  @override
  String get importConflictsTitle => 'Conflictos de importación';

  @override
  String importConflictsMessage(int conflictCount) {
    return 'Se encontraron $conflictCount letras conflictivas en la copia de seguridad (existen localmente pero son diferentes). Selecciona cómo proceder:';
  }

  @override
  String get overwriteAll => 'Sobrescribir todo';

  @override
  String get skipAllConflicts => 'Omitir conflictos';

  @override
  String get decideOneByOne => 'Decidir uno por uno';

  @override
  String conflictResolutionTitle(int current, int total) {
    return 'Resolver conflicto ($current/$total)';
  }

  @override
  String get conflictExistingLabel => 'Letras existentes';

  @override
  String get conflictImportedLabel => 'Letras importadas';

  @override
  String conflictSourceLabel(String source) {
    return 'Origen: $source';
  }

  @override
  String conflictTimeLabel(String time) {
    return 'Tiempo: $time';
  }

  @override
  String get overwriteThis => 'Sobrescribir';

  @override
  String get skipThis => 'Omitir';

  @override
  String get overwriteRemaining => 'Sobrescribir restantes';

  @override
  String get skipRemaining => 'Omitir restantes';

  @override
  String get invalidBackupFile => 'Archivo de respaldo no válido';

  @override
  String get exportLogs => 'Exportar registros';

  @override
  String get exportLogsSuccess => 'Registros exportados con éxito';

  @override
  String get exportLogsFailed => 'Error al exportar registros';

  @override
  String get noLogFileFound => 'No se encontró el archivo de registro';

  @override
  String get uiDisplayScale => 'Escala de la interfaz';

  @override
  String get uiDisplayScaleDescription =>
      'Ajustar globalmente el tamaño de los elementos y texto de la interfaz, adaptado a pantallas de vehículos';

  @override
  String get uiDisplayScaleDialogTitle => 'Escala de interfaz / Modo vehículo';

  @override
  String uiDisplayScaleCurrent(int percent) {
    return 'Escala actual: $percent%';
  }

  @override
  String get audioSettings => 'Ajustes de audio';

  @override
  String get audioSettingsDescription =>
      'Administrar reproducción de audio, bandas de ecualizador y velocidad de reproducción';

  @override
  String get equalizerBandCount => 'Cantidad de bandas del ecualizador';

  @override
  String get equalizerBandCountDescription =>
      'Configurar la cantidad de bandas mostradas en el ecualizador. Los modos con muchas bandas activarán desplazamiento horizontal suave.';

  @override
  String bandsCountOption(int count) {
    return '$count bandas';
  }

  @override
  String get enableFadeEffect => 'Efecto de desvanecimiento de audio';

  @override
  String get enableFadeEffectDescription =>
      'Activar transiciones suaves de desvanecimiento y fundido cruzado al cambiar de canción, reproducir y pausar';

  @override
  String get buttonLayoutSettings => 'Diseño de botones';

  @override
  String get playbackButtonLayoutTitle =>
      'Diseño de controles de la página de reproducción';

  @override
  String get playbackButtonLayoutDescription =>
      'Personaliza el orden y la visualización de los botones en las filas de 7 y 5 botones';

  @override
  String get topButtonsRowTitle => 'Orden de la fila de 7 botones';

  @override
  String get mainButtonsRowTitle =>
      'Botones izquierdo y derecho de la fila de 5 botones';

  @override
  String get mainControlsLeftButton => 'Botón izquierdo';

  @override
  String get mainControlsRightButton => 'Botón derecho';

  @override
  String get lyricsHeaderRightButtonTitle =>
      'Botón derecho cuando la barra de título de letras está contraída';

  @override
  String get resetButtonOrder => 'Restablecer diseño predeterminado';

  @override
  String get btnMore => 'Menú más';

  @override
  String get btnFavorite => 'Favorito';

  @override
  String get btnPlaylistMode => 'Modo de reproducción';

  @override
  String get btnShuffle => 'Reproducción aleatoria';

  @override
  String get btnTagCompletion => 'Completado de etiquetas';

  @override
  String get btnSleepTimer => 'Temporizador';

  @override
  String get btnEqualizer => 'Ecualizador';

  @override
  String get btnVisualizer => 'Visualizador';

  @override
  String get btnVolume => 'Volumen';

  @override
  String get remoteControlAction => 'Control remoto';

  @override
  String get remoteControlRequestTitle => 'Solicitud de control remoto';

  @override
  String remoteControlRequestFrom(String name) {
    return 'El dispositivo \"$name\" solicita controlar la reproducción';
  }

  @override
  String get remotePinPairHint =>
      'Introduce el siguiente código PIN de emparejamiento en el dispositivo de control:';

  @override
  String get remotePinExpiresIn => 'El PIN expira en:';

  @override
  String get allowDirectly => 'Permitir directamente';

  @override
  String get enterRemotePinTitle => 'Emparejamiento de dispositivos';

  @override
  String enterRemotePinPrompt(String name) {
    return 'Introduce el código PIN de 4 dígitos que se muestra en \"$name\":';
  }

  @override
  String get remotePinInvalid =>
      'PIN no válido o caducado. Inténtalo de nuevo.';

  @override
  String remotePinCooldown(int seconds) {
    return 'PIN incorrecto, reintentar en $seconds s';
  }

  @override
  String remotePinAttemptsRemaining(int count) {
    return '($count intentos restantes)';
  }

  @override
  String get remotePinTooManyAttempts =>
      'Demasiados intentos fallidos. Sesión de emparejamiento expirada.';

  @override
  String get remoteConnected => 'Conectado';

  @override
  String get remoteConnecting => 'Conectando...';

  @override
  String get remoteDisconnect => 'Desconectar';

  @override
  String get remoteConnectFailed => 'Error al conectar de forma remota';

  @override
  String controlledByRemoteDevices(String devices) {
    return 'Controlado por los siguientes dispositivos remotos: $devices';
  }

  @override
  String get trustedDevicesTitle => 'Dispositivos remotos de confianza';

  @override
  String get manageTrustedDevicesTitle =>
      'Gestionar dispositivos remotos de confianza';

  @override
  String get removeTrustedDevice => 'Eliminar confianza';

  @override
  String get noMusicPlaying => 'No hay música reproduciéndose';

  @override
  String get previousSong => 'Canción anterior';

  @override
  String get nextSong => 'Siguiente canción';

  @override
  String get shufflePlayback => 'Reproducción aleatoria';

  @override
  String get allowRemoteControlTitle => 'Permitir control remoto';

  @override
  String get allowRemoteControlSubtitle =>
      'Permitir que otros dispositivos LAN controlen la reproducción tras el emparejamiento';

  @override
  String get remoteControlDisabledOnHost =>
      'El control remoto está desactivado en el dispositivo de destino';

  @override
  String get trustThisDevice =>
      'Confiar en este dispositivo y permitirlo automáticamente en el futuro';

  @override
  String get remoteRequestRejected =>
      'La solicitud de conexión fue rechazada por el dispositivo de destino.';

  @override
  String get turkishLanguage => 'Turco';

  @override
  String get nativeLanguageTr => 'Türkçe';

  @override
  String trustedDevicesCount(int count) {
    return '$count dispositivos de confianza';
  }

  @override
  String get noTrustedDevices => 'No hay dispositivos de confianza';

  @override
  String get noTrustedDevicesHint =>
      'Los dispositivos aparecerán aquí tras marcar «Confiar en este dispositivo» al vincular';

  @override
  String pairedAtFormat(String time) {
    return 'Vinculado el: $time';
  }

  @override
  String transferCancelled(String direction) {
    return '$direction cancelada';
  }

  @override
  String get audioFiles => 'Archivos de audio';

  @override
  String get remotePairCancelledByClient =>
      'La solicitud de vinculación fue cancelada por el dispositivo de destino.';

  @override
  String get proFeatureAiLyricsTitle => 'Letras IA & Traducción';

  @override
  String get proFeatureAiLyricsDesc =>
      'Generación de letras por IA, alineación de tiempo y traducción';

  @override
  String get proFeatureTagCompletionTitle => 'Autocompletado de metadatos';

  @override
  String get proFeatureTagCompletionDesc =>
      'Completado automático de etiquetas y metadatos de álbumes mediante MusicBrainz';

  @override
  String get proFeatureEqualizerTitle =>
      'Ecualizador multibanda y velocidad (EQ)';

  @override
  String get proFeatureEqualizerDesc =>
      'Ajuste de frecuencia profesional, velocidad de reproducción 0.5x–5.0x, ganancia y estilos personalizados';

  @override
  String get proFeatureCustomThemeColorTitle =>
      'Temas de espectro completo y colores avanzados';

  @override
  String get proFeatureCustomThemeColorDesc =>
      'Desbloquea la paleta de selección de color libre y colores de tema preestablecidos premium exclusivos';

  @override
  String get proFeatureFftVisualizerTitle =>
      'Espectro de audio FFT en tiempo real';

  @override
  String get proFeatureFftVisualizerDesc =>
      '6 estilos de espectro (Barras clásicas, Onda suave, Tapas flotantes, Halo radial, Matriz de neón, Onda espejada) y modo ambiente a pantalla completa';

  @override
  String get proFeatureWaveformBarTitle => 'Barra de progreso de forma de onda';

  @override
  String get proFeatureWaveformBarDesc =>
      'Extracción de forma de onda en tiempo real con navegación interactiva fluida';

  @override
  String get proFeatureLanSharingTitle => 'Compartir música por LAN';

  @override
  String get proFeatureLanSharingDesc =>
      'Transferencia y uso compartido ultrarrápido de música en la red local';

  @override
  String get proFeatureRemoteControlTitle => 'Control remoto multidispositivo';

  @override
  String get proFeatureRemoteControlDesc =>
      'Conexión fluida y control de reproducción inalámbrico entre dispositivos';

  @override
  String get proFeatureTranscoderTitle => 'Conversor de audio por lotes';

  @override
  String get proFeatureTranscoderDesc =>
      'Conversión rápida de formatos sin pérdida y exportación por lotes para portátiles';

  @override
  String get proCommunityUnlocked =>
      'Edición comunitaria: todas las funciones Pro desbloqueadas permanentemente';

  @override
  String proTrialActive(int days) {
    return 'Prueba gratuita activa (quedan $days días)';
  }

  @override
  String get proTrialExpired =>
      'Prueba gratuita finalizada. Actualice a Pro para desbloquear';

  @override
  String get proPermanentlyActivated =>
      'Todas las funciones Pro activadas permanentemente';

  @override
  String proStatusTrialTitle(int days) {
    return 'Estado de licencia: prueba gratuita de $days días activa';
  }

  @override
  String get proStatusTrialExpiredTitle =>
      'Estado de licencia: prueba finalizada (funciones limitadas)';

  @override
  String get proStatusActivatedTitle =>
      'Estado de licencia: Vynody Pro activado';

  @override
  String proSettingsTrialRemaining(int days) {
    return 'Quedan $days días de prueba';
  }

  @override
  String get proSettingsUpgradePrompt =>
      'Actualice para desbloquear letras IA, espectro FFT y funciones Pro';

  @override
  String get proSettingsLifetimeNotice =>
      'Incluye todas las funciones Pro y futuras actualizaciones';

  @override
  String get proSettingsUpgrade => 'Actualizar';

  @override
  String get proSettingsView => 'Ver';

  @override
  String get connectingToStore => 'Conectando con la tienda...';

  @override
  String get buyFullVersionWindowsTrial =>
      'Comprar versión completa en Microsoft Store';

  @override
  String get buyFullVersionWindows =>
      'Comprar versión completa en Microsoft Store';

  @override
  String unlockProLifetimeWithPrice(String price) {
    return '$price Desbloqueo permanente de Pro';
  }

  @override
  String get buyProTrialEarly => 'Comprar licencia Pro permanente';

  @override
  String get upgradeToProNow => 'Actualizar a Pro ahora';

  @override
  String get iUnderstand => 'Entendido';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get restoringPurchases => 'Restaurando compras...';

  @override
  String get sharingProDescription =>
      'La interconexión LAN es una función exclusiva de Vynody Pro. Desbloquéela para disfrutar de transferencia ultrarrápida, sincronización de biblioteca y control remoto inalámbrico en red local.';

  @override
  String get sharingHighlightSpeedTitle => 'Transferencia LAN ultrarrápida';

  @override
  String get sharingHighlightSpeedDesc =>
      'Transferencia directa P2P de música sin pérdida y listas por Wi-Fi sin consumo de datos ni compresión.';

  @override
  String get sharingHighlightSyncTitle =>
      'Sincronización de biblioteca y letras';

  @override
  String get sharingHighlightSyncDesc =>
      'Envío con un clic de letras y canciones descargadas para mantener sincronizados sus dispositivos.';

  @override
  String get sharingHighlightRemoteTitle => 'Control remoto inalámbrico';

  @override
  String get sharingHighlightRemoteDesc =>
      'Conexión multidispositivo para controlar reproducción, cambiar de pista y ajustar volumen sin cables.';

  @override
  String get sharingHighlightSecurityTitle =>
      'Cifrado TLS de extremo a extremo';

  @override
  String get sharingHighlightSecurityDesc =>
      'Cifrado completo mediante certificados TLS y emparejamiento seguro de dispositivos.';

  @override
  String get upgradeToProToUnlock => 'Actualizar a Vynody Pro';

  @override
  String get proOneTimePurchaseNotice =>
      'Compra única, desbloquea permanentemente todas las funciones Pro en esta plataforma';

  @override
  String get proOneTimePurchaseNoticeApple =>
      'Compra única, desbloquea permanentemente todas las funciones Pro en plataformas Apple (iPhone / iPad / Mac)';

  @override
  String get proUniversalPurchaseNoticeApple =>
      'Una sola compra, compatible con iPhone, iPad y Mac';

  @override
  String get iapPurchaseSuccess =>
      '¡Vynody Pro comprado con éxito! ¡Gracias por su apoyo!';

  @override
  String get iapRestoreSuccess =>
      '¡Compras de Vynody Pro restauradas con éxito!';

  @override
  String iapPurchaseCancelledOrFailed(String message) {
    return 'Compra no completada o cancelada: $message';
  }
}
