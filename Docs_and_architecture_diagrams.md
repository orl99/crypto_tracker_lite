# 🏗️ Arquitectura y Patrones — CryptoTracker Lite

Documentación completa de los patrones de diseño y la arquitectura utilizada en el proyecto.

---

## 1. Estructura de Carpetas (Layered Architecture)

```
lib/
├── api/                  # Capa de Red
│   ├── api_client.dart       # Cliente HTTP + Caché en memoria + Rate Limit
│   └── exceptions.dart       # Excepciones personalizadas (RateLimitException)
├── models/               # Capa de Datos
│   ├── coin.dart             # Modelo de moneda (lista)
│   ├── coin_detail.dart      # Modelo de detalle
│   └── market_chart.dart     # Modelo de gráfica histórica
├── services/             # Capa de Lógica de Negocio
│   ├── crypto_service.dart   # Orquestador de llamadas API → Modelos
│   └── favorites_service.dart# Persistencia local (SharedPreferences)
├── bloc/                 # Capa de Gestión de Estado
│   ├── crypto_list_bloc.dart # BLoC: Lista principal + Rate Limit
│   ├── crypto_detail_bloc.dart # BLoC: Detalle + Gráfica
│   ├── favorites_bloc.dart   # BLoC: Favoritos (toggle/load)
│   └── locale_bloc.dart      # BLoC: Internacionalización (idiomas)
├── l10n/                 # Localización (i18n)
│   ├── app_es.arb            # Traducciones al español
│   ├── app_en.arb            # Traducciones al inglés
│   └── app_localizations.dart# Clase generada + Extensión context.l10n
├── providers/            # Capa de Inyección de Dependencias
│   └── dependency_injection.dart # Widget AppDependencyInjector
├── pages/                # Capa de Presentación (Pantallas)
│   ├── home_page.dart
│   ├── crypto_detail_page.dart
│   ├── favorites_page.dart
│   └── profile_page.dart
├── widgets/              # Capa de Presentación (Componentes reutilizables)
│   ├── coin_list_tile.dart
│   ├── side_menu_drawer.dart
│   ├── rate_limit_banner.dart # Banner global de 429
│   └── error_state_widget.dart# Pantalla de error unificada
├── theme/                # Sistema de Diseño
│   └── app_colors.dart       # Design Tokens (paleta de colores centralizada)
├── app_bloc_observer.dart    # Logging global de errores y transiciones
└── main.dart             # Punto de entrada
```

---

## 2. Diagrama General de Arquitectura

```mermaid
graph TD
    subgraph UI["🎨 Presentación (UI)"]
        HP["HomePage"]
        DP["CryptoDetailPage"]
        FP["FavoritesPage"]
        PP["ProfilePage"]
        CLT["CoinListTile"]
        SMD["SideMenuDrawer"]
        ESW["ErrorStateWidget"]
    end

    subgraph STATE["⚙️ Gestión de Estado (BLoC)"]
        CLB["CryptoListBloc"]
        CDB["CryptoDetailBloc"]
        FB["FavoritesBloc"]
        LB["LocaleBloc"]
    end

    subgraph SERVICES["🔧 Servicios"]
        CS["CryptoService"]
        FS["FavoritesService"]
        OBS["AppBlocObserver (Logger)"]
    end

    subgraph DATA["📦 Datos"]
        AC["ApiClient"]
        SP["SharedPreferences"]
        CACHE["In-Memory Cache"]
        MODELS["Models (Coin, CoinDetail, MarketChart)"]
    end

    subgraph EXTERNAL["🌐 Externo"]
        API["CoinGecko API"]
    end

    HP --> CLB
    HP --> CLT
    DP --> CDB
    DP --> FB
    FP --> CLB
    FP --> FB
    FP --> CLT
    CLT --> FB

    CLB --> CS
    CDB --> CS
    FB --> FS

    CS --> AC
    FS --> SP

    AC --> CACHE
    AC --> API
    AC --> MODELS
```

---

## 3. Patrón BLoC (Business Logic Component)

```mermaid
graph LR
    subgraph EVENTS["📩 Events"]
        E1["FetchCryptoList"]
        E2["DismissRateLimitWarning"]
    end

    subgraph BLOC["⚙️ CryptoListBloc"]
        HANDLER["Event Handlers"]
    end

    subgraph STATES["📤 States"]
        S1["CryptoListInitial"]
        S2["CryptoListLoading"]
        S3["CryptoListLoaded"]
        S4["CryptoListError"]
    end

    E1 --> HANDLER
    E2 --> HANDLER
    HANDLER --> S1
    HANDLER --> S2
    HANDLER --> S3
    HANDLER --> S4

    S3 -.- NOTE1["coins: List&lt;Coin&gt;\nisRateLimitExceeded: bool"]
    S4 -.- NOTE2["message: String\nisRateLimit: bool"]
```

### Todos los BLoCs del proyecto:

| BLoC | Events | States |
|------|--------|--------|
| **CryptoListBloc** | `FetchCryptoList`, `DismissRateLimitWarning` | `Initial`, `Loading`, `Loaded(coins, isRateLimitExceeded)`, `Error(message, isRateLimit)` |
| **CryptoDetailBloc** | `FetchCryptoDetail(id)` | `Initial`, `Loading`, `Loaded(chart, detail)`, `Error(message, isRateLimit)` |
| **FavoritesBloc** | `LoadFavorites`, `ToggleFavorite(coinId)` | `FavoritesLoaded(favoriteIds)` |
| **LocaleBloc** | `ChangeLocale(locale)` | `LocaleState(locale)` |

---

## 4. Inyección de Dependencias (Provider Pattern)

```mermaid
graph TD
    subgraph DI["🔌 AppDependencyInjector (StatelessWidget)"]
        direction TB
        P1["Provider&lt;ApiClient&gt;"]
        P2["ProxyProvider&lt;ApiClient, CryptoService&gt;"]
        P3["Provider&lt;FavoritesService&gt;"]
    end

    subgraph BLOCS["MultiBlocProvider"]
        B1["BlocProvider&lt;CryptoListBloc&gt;"]
        B2["BlocProvider&lt;CryptoDetailBloc&gt;"]
        B3["BlocProvider&lt;FavoritesBloc&gt;"]
        B4["BlocProvider&lt;LocaleBloc&gt;"]
    end

    P1 --> P2
    P2 --> B1
    P2 --> B2
    P3 --> B3

    DI --> BLOCS
    BLOCS --> APP["MaterialApp"]
```

> [!IMPORTANT]
> **Regla estricta del proyecto:** `Provider` se usa **exclusivamente** para inyección de dependencias (servicios). Toda la lógica de estado se maneja con `BLoC`.

---

## 5. Sistema de Caché In-Memory

```mermaid
sequenceDiagram
    participant UI as UI (BLoC)
    participant AC as ApiClient
    participant Cache as In-Memory Cache
    participant API as CoinGecko API

    UI->>AC: get("/coins/markets...")
    AC->>AC: ¿Bloqueado por 429?
    
    alt No bloqueado
        AC->>Cache: ¿Existe en caché y < 15s?
        alt Caché válido
            Cache-->>AC: Datos cacheados
            AC-->>UI: return datos (sin HTTP)
        else Caché expirado o vacío
            AC->>API: HTTP GET
            alt Status 200
                API-->>AC: JSON Response
                AC->>Cache: Guardar con timestamp
                AC-->>UI: return datos
            else Status 429
                AC->>AC: _blockUntil = now + 10s
                AC-->>UI: throw RateLimitException
            end
        end
    else Bloqueado
        AC-->>UI: throw RateLimitException
    end
```

---

## 6. Flujo de Manejo del Error 429 (Rate Limit)

```mermaid
stateDiagram-v2
    [*] --> CryptoListLoaded: Carga exitosa
    
    CryptoListLoaded --> CryptoListLoaded: FetchCryptoList\n(429 + datos previos)\nisRateLimitExceeded=true
    
    CryptoListLoaded --> CryptoListLoaded: DismissRateLimitWarning\nisRateLimitExceeded=false
    
    CryptoListLoaded --> CryptoListLoaded: FetchCryptoList\n(éxito)\nisRateLimitExceeded=false
    
    [*] --> CryptoListError: FetchCryptoList\n(429, sin datos previos)\nisRateLimit=true
```

> [!NOTE]
> **Comportamiento clave:** Si ya tenemos monedas cargadas y llega un 429, **no perdemos los datos**. Simplemente mostramos un banner naranja (`AppColors.warning`) sobre la lista existente, manteniendo la experiencia de usuario intacta.

---

## 7. Manejo Global de Errores (AppBlocObserver)

```mermaid
graph TD
    BLOC["BLoC (Cualquiera)"]
    OBS["AppBlocObserver"]
    LOG["Consola / Logging Service"]
    
    BLOC -->|"onError(error, stackTrace)"| OBS
    OBS -->|"Formatear y Loggear"| LOG
    LOG -->|"Debug: [CryptoListBloc] Error..."| DEV["Desarrollador"]
```

> [!TIP]
> `AppBlocObserver` centraliza todos los fallos del flujo de datos, permitiendo diagnosticar problemas de red o de lógica sin ensuciar los archivos de UI o BLoC con `print()` o `debugPrint()`.

---

## 8. Internacionalización (i18n)

El proyecto utiliza el sistema estándar de Flutter con archivos `.arb` y generación de código personalizada para mayor flexibilidad.

```mermaid
graph LR
    ARB["Archivos .arb (es, en)"]
    GEN["flutter gen-l10n"]
    CODE["lib/l10n/app_localizations.dart"]
    EXT["context.l10n (Extension)"]
    UI["Widgets / Pages"]
    
    ARB --> GEN
    GEN --> CODE
    CODE --> EXT
    EXT --> UI
```

---

## 9. Persistencia Local (Favoritos y Config)

```mermaid
graph LR
    subgraph APP["App"]
        FB["FavoritesBloc"]
        FS["FavoritesService"]
    end

    subgraph STORAGE["💾 Almacenamiento"]
        SP["SharedPreferences"]
    end

    FB -->|"toggle/load"| FS
    FS -->|"getStringList / setStringList"| SP
    SP -->|"List&lt;String&gt; favoriteIds"| FS
    FS -->|"emit FavoritesLoaded"| FB
```

---

## 8. Design Tokens (AppColors)

```mermaid
graph TD
    subgraph THEME["🎨 AppColors (lib/theme/app_colors.dart)"]
        BASE["Base\nbackground: #000000\ncard: #1A1A1A\ngradientStart: #2D2D2D\ngradientEnd: #121212"]
        ACCENT["Accent\ngold: #F9D949\ngoldAlt: #F5C344\nblue: #2F80ED"]
        STATUS["Status\nsuccess: #67AD5B\ndanger: #E15241\ninfo: #4994EC\nwarning: #F2A033"]
    end

    BASE --> PAGES["Todas las páginas"]
    ACCENT --> PAGES
    STATUS --> PAGES
```

---

## 9. Navegación

```mermaid
graph TD
    HOME["🏠 HomePage\n(Lista de criptos)"]
    DETAIL["📊 CryptoDetailPage\n(Gráfica + Info)"]
    FAVS["⭐ FavoritesPage\n(Criptos favoritas)"]
    PROFILE["👤 ProfilePage\n(Info del usuario)"]

    HOME -->|"Tap en CoinListTile"| DETAIL
    HOME -->|"Drawer > Favoritos"| FAVS
    HOME -->|"Drawer > Perfil"| PROFILE
    FAVS -->|"Tap en CoinListTile"| DETAIL
    PROFILE -->|"Cambio de Idioma"| LB["LocaleBloc"]
    LB -->|"Actualizar UI"| HOME
```

---

## Resumen de Patrones Utilizados

| Patrón | Implementación | Archivo(s) Clave |
|--------|---------------|-------------------|
| **BLoC Pattern** | Gestión de estado reactiva con Events y States | `lib/bloc/*.dart` |
| **Repository/Service Pattern** | Abstracción de fuentes de datos | `lib/services/*.dart` |
| **Provider (DI)** | Inyección de dependencias con widget wrapper | `lib/providers/dependency_injection.dart` |
| **In-Memory Cache** | Map con TTL de 15s para evitar llamadas repetidas | `lib/api/api_client.dart` |
| **Design Tokens** | Centralización de colores con constantes estáticas | `lib/theme/app_colors.dart` |
| **Global Logging** | Seguimiento de errores y transiciones con Observer | `lib/app_bloc_observer.dart` |
| **i18n (L10n)** | Soporte multi-idioma (ES/EN) con extensión de context | `lib/l10n/` |
| **Layered Architecture** | Separación estricta: API → Services → BLoC → UI | Toda la estructura `lib/` |
| **Graceful Degradation** | Rate Limit 429: mostrar datos previos + banner | `crypto_list_bloc.dart` + `rate_limit_banner.dart` |
| **Local Persistence** | SharedPreferences para favoritos y locale | `lib/services/favorites_service.dart` + `locale_bloc.dart` |
