# CarPlay mini app opportunities hiding in plain sight

The CarPlay ecosystem has **8 approved categories** but 5 of them are virtually empty. Apple permits Audio, Communication, Navigation, EV Charging, Parking, Quick Food Ordering, Fueling, and Driving Task apps—yet Fueling has just 2 apps, Quick Food Ordering has 4 (no McDonald's, no Starbucks), and Driving Task remains a wasteland. Combined with documented user pain points and free public APIs that nobody uses, several infra-free opportunities emerge.

The best opportunities share three traits: they solve a **single driving moment**, work with **cacheable public data**, and avoid the complexity trap that turns mini apps into platforms.

---

## Apple's restrictions shape what's possible

CarPlay enforces strict constraints that eliminate most app concepts but enable focused utilities. Apps cannot use custom UI—only Apple's templates with **maximum 12-item lists** and **2-5 screen depth limits**. Ads are explicitly prohibited (instant rejection). Apps must work with the iPhone locked, eliminating data protection classes A and B.

These constraints actually favor mini apps: complex, feature-rich designs fail Apple review. The approved categories each require separate entitlements, and apps must be **single-category only**—no hybrid parking-and-charging apps allowed.

| Category | Current Apps | Market State |
|----------|-------------|--------------|
| Navigation | 10+ | Saturated |
| Audio/Music | 15+ | Saturated |
| EV Charging | ~5 | Fragmented by network |
| Parking | 3-4 | Regional, sparse |
| Quick Food Ordering | 4 | Ghost town |
| Fueling | 2 | Nearly empty |
| Driving Task | ~3 | Newest, unexplored |

The Driving Task category (iOS 16+) permits "general driving-related tasks" with the strictest UI limits (2 templates max)—ideal for single-purpose utilities.

---

## User complaints reveal the real gaps

Mining 3-4 star reviews and forum complaints surfaces specific moments of friction rather than general dissatisfaction.

**"Can't find rest stops"** appears repeatedly. Apple Maps doesn't show rest areas on interstate highways. One user noted: "When you hear 'Where's the next rest stop?' it may already be an emergency." Parents, truckers, and road trippers all report this gap. The iExit app exists but buries rest stops among fuel prices and advertising.

**"Apple Weather isn't on CarPlay"** frustrates drivers who must invoke Siri for weather while Weather on the Way charges subscriptions. Weather data is inherently cacheable (forecasts don't change hourly), making this a prime offline opportunity.

**"EV charger apps are subscription nightmares"** generates significant frustration. A Better Route Planner costs $50/year; one user complained: "I would use the app 4 days a year max. No way am I going to pay 50 quid for the privilege." Meanwhile, Open Charge Map offers **200,000+ global charging locations for free** with full caching support—barely used by CarPlay developers.

**"Voice notes while driving are impossible"** since Apple's Voice Memos isn't optimized for CarPlay and Drafts has no CarPlay support. Users describe thoughts occurring while driving that disappear because there's no frictionless capture mechanism.

**"Maps search categories don't match my needs"** appears in Apple Community forums. Default quick-search options show gas, parking, coffee, groceries—but not hotels, rest stops, or fast food by category. Users can't customize these defaults.

---

## Free APIs that CarPlay apps ignore

The most striking finding: **government and open-source APIs with excellent data sit unused** while developers build on expensive commercial platforms.

### Tier 1: Free, cacheable, no user accounts required

| API | Data | CarPlay Usage | Cache Window |
|-----|------|---------------|--------------|
| Open Charge Map | 200K+ EV chargers globally | Rare | 24+ hours |
| NREL Alt Fuel Stations | US EV/CNG/LPG/hydrogen stations | Almost none | 24+ hours |
| Open-Meteo | Weather forecasts (no API key!) | Very rare | 3-6 hours |
| Overpass API (OSM) | Any POI type (rest stops, car washes, etc.) | Very rare | Indefinite |
| State 511 APIs | Traffic cameras, road conditions | Almost none | Locations cacheable |
| EIA Open Data | Regional fuel prices | Analyst-only | Weekly updates |

The NREL Alternative Fuel Stations API provides comprehensive US coverage with **1,000 requests/hour free**—yet appears in almost no consumer CarPlay apps. Open-Meteo requires no API key at all and provides 16-day forecasts.

OpenStreetMap via Overpass enables fully offline POI databases. Query `highway=rest_area` or `amenity=car_wash` and cache entire regions. Perfect for apps that need zero network connectivity during use.

---

## Validated opportunities with kill criteria

Each opportunity below passes the validation filters: single moment, minimal/no APIs, no backend required, clear monetization.

### 1. Rest stop finder with offline database

**The moment**: Driver or passenger needs bathroom, parent hears "how long until we stop?"

**Why existing apps fail**: Apple Maps doesn't show rest areas. iExit exists but focuses on fuel pricing and ads. Navigation apps show exits but not amenity details or distance-off-highway.

**Technical approach**: Pre-load state DOT rest area databases (public data) + OSM `highway=rest_area` tags. Cache entire US rest stop locations (~2MB). No network required during use—just GPS position matching against cached database.

**Public APIs**: Overpass API for bulk OSM extract (one-time download), state DOT open datasets

**Monetization**: $2.99 one-time purchase; premium version adds amenity ratings ($4.99)

**Infra-free feasibility**: ✅ Fully offline. All data static enough to ship with app or update monthly via CloudKit background refresh.

**Kill criteria**: Adding user reviews = needs backend. Adding real-time crowdsourced wait times = platform. Adding fuel prices = scope creep into iExit territory.

---

### 2. Simple EV charger finder (non-routing)

**The moment**: EV driver needs nearby charger matching their connector type, wants availability at a glance, one tap to navigate.

**Why existing apps fail**: ABRP costs $50/year. Apple Maps EV routing only works with ~3 car models. Network-specific apps (ChargePoint, Electrify America) require separate installs. PlugShare has limited CarPlay features.

**Technical approach**: Use Open Charge Map API (free) with 24-hour caching. Filter by connector type (CCS, CHAdeMO, Tesla, J1772) stored in user preferences. List format: distance + charger count + one-tap navigation handoff.

**Public APIs**: Open Charge Map (free, 200K+ locations), NREL Alt Fuel Stations (government backup data)

**Monetization**: Free tier shows locations; $2.99 unlocks real-time availability checks and favorite chargers

**Infra-free feasibility**: ✅ Locations cached daily. Real-time availability optional (API calls only when user requests). No user accounts—preferences stored locally.

**Kill criteria**: Adding route planning = competing with ABRP. Adding payment integration = needs backend. Adding charger network accounts = platform complexity.

---

### 3. Drive weather glance (route-aware forecasts)

**The moment**: Driver wants to know if weather will change during 2+ hour drive without subscribing to Weather on the Way.

**Why existing apps fail**: Apple Weather has no CarPlay interface—only Siri access. MyRadar shows radar but not route context. Weather on the Way requires subscription for CarPlay features.

**Technical approach**: Use Open-Meteo (free, no API key) or NWS API (government, free). Cache 6-hour forecast blocks along current route from Maps. Simple display: current conditions + "rain in 45 min" alerts.

**Public APIs**: Open-Meteo (completely free, no key), WeatherAPI.com (1M calls/month free tier), NWS API (US government)

**Monetization**: $3.99 one-time purchase

**Infra-free feasibility**: ✅ Forecast data cacheable for hours. No user accounts. Route awareness via CoreLocation—no backend needed.

**Kill criteria**: Adding historical data analysis = feature creep. Adding road condition predictions = need premium Xweather API. Adding trip planning = platform territory.

---

### 4. Voice notes with location stamps

**The moment**: Thought, idea, or to-do occurs while driving. Can't write it down. Siri Reminders loses context.

**Why existing apps fail**: Voice Memos not CarPlay-optimized. Drafts has no CarPlay support (users specifically request this). OmniFocus has no CarPlay integration.

**Technical approach**: One-tap recording using AVFoundation. Auto-attach GPS coordinates from CoreLocation. Store locally with iCloud sync (no backend). List of recordings with timestamp + optional location name.

**Public APIs**: None required—pure device capabilities (GPS, microphone, iCloud)

**Monetization**: $4.99 one-time purchase; could add Shortcuts integration for power users

**Infra-free feasibility**: ✅ Fully offline recording. iCloud handles sync without custom backend. No user accounts.

**Kill criteria**: Adding transcription = needs server or expensive on-device ML. Adding task management = building a productivity platform. Adding collaboration = definitely needs backend.

---

### 5. Custom Maps search launcher

**The moment**: User wants quick access to search categories Apple doesn't default (hotels, rest stops, specific fast food, drive-throughs).

**Why existing apps fail**: Apple Maps forces preset categories (gas, parking, coffee, groceries). Can't customize. Users must voice-search or tap through multiple screens.

**Technical approach**: Driving Task category app with configurable buttons (max 12 items per Apple's limit). Each button triggers URL scheme to Apple Maps with pre-configured search term. Zero API calls—pure Maps handoff.

**Public APIs**: None—uses `maps://` URL schemes exclusively

**Monetization**: $1.99-$2.99 one-time purchase

**Infra-free feasibility**: ✅ No network required. No data storage beyond user preferences. Simplest possible architecture.

**Kill criteria**: Adding POI database = duplicating Maps. Adding reviews = needs backend. Adding navigation = competing with Maps itself.

---

### 6. Quick expense capture at stops

**The moment**: Business driver/gig worker leaves gas station, restaurant, or store and needs to log purchase for tax documentation before forgetting amount.

**Why existing apps fail**: YNAB has no CarPlay support. Generic expense trackers require later manual entry. Users forget amounts/details.

**Technical approach**: Geofence detection (leaving known retail locations via CoreLocation). Voice input for amount. Local storage with CSV/PDF export. Categories: fuel, food, tolls, parking, other.

**Public APIs**: None required for core function. Optional: reverse geocoding for store name (MapKit, included in iOS)

**Monetization**: $3.99 one-time; premium export features $1.99 IAP

**Infra-free feasibility**: ✅ Local storage + iCloud. No user accounts. Export to spreadsheet doesn't require backend.

**Kill criteria**: Adding receipt scanning = needs ML/backend. Adding accounting integration = platform. Adding team expense sharing = definitely needs backend.

---

### 7. Mileage tracker with trip classification

**The moment**: Gig worker (Uber, DoorDash, real estate agent) needs IRS-compliant mileage documentation without monthly subscription.

**Why existing apps fail**: MileIQ works but no native CarPlay interface. Most mileage apps run in background with no CarPlay interaction. Classification happens later, not during the drive.

**Technical approach**: Auto-detect trip start/end via CarPlay connection events. One-swipe classification (business/personal) in CarPlay interface. GPS-based mileage calculation. PDF export for tax filing.

**Public APIs**: None—pure CoreLocation + CarPlay lifecycle events

**Monetization**: $9.99/year subscription (justified by tax season value; IRS mileage rate ~$0.67/mile means app pays for itself in 15 business miles)

**Infra-free feasibility**: ✅ Local storage + iCloud backup. No user accounts. Export doesn't require backend.

**Kill criteria**: Adding automatic business detection ML = complexity. Adding team fleet management = platform. Adding accounting software sync = needs backend integrations.

---

## Categories to avoid entirely

Several apparent opportunities fail validation filters:

**Toll calculators**: TollGuru and similar APIs require route-specific real-time calculations. Can't cache effectively. Pricing starts at $99/month for production use. Drifts into routing territory.

**Real-time parking availability**: Requires live integrations with parking systems. SpotHero and regional apps (RingGo, PayByPhone) already own these relationships. No free public APIs for availability—only locations.

**Traffic camera viewers**: While state 511 APIs are free for locations, camera feeds are real-time images requiring constant network. Can't work offline. Limited utility as standalone.

**Fast food ordering**: Apple's Quick Food Ordering category exists but major chains (McDonald's, Starbucks) haven't built CarPlay apps. Ordering requires payment processing and restaurant integrations—full platform territory.

---

## Technical considerations for all concepts

Apple's CarPlay framework enforces consistent patterns that simplify development:

- **UI is template-only**: CPListTemplate, CPGridTemplate, CPPointOfInterestTemplate. No custom views. Maximum 12 items in lists.
- **Depth limits**: Most apps limited to 5 templates deep; Driving Task limited to 2. Forces simplicity.
- **Single category**: Apps can't span EV Charging + Parking. Pick one entitlement.
- **No ads**: Explicitly prohibited. Will fail Apple review.
- **iPhone-locked operation**: App must function when phone is locked. Avoid protected data classes.
- **Entitlement required**: Submit request at developer.apple.com/carplay. Approval takes days to weeks.

The Driving Task category (iOS 16+) offers the most flexibility for utility apps with minimal UI requirements—ideal for concepts like voice notes, expense capture, and custom search launchers.

---

## Summary of highest-conviction opportunities

| Opportunity | Moment | API Cost | Offline? | Monetization | Risk Level |
|-------------|--------|----------|----------|--------------|------------|
| Rest stop finder | Bathroom break urgency | Free (OSM) | ✅ Yes | $2.99 once | Low |
| Simple EV charger | Find charger now | Free (OCM) | ✅ Mostly | Freemium | Low |
| Voice notes | Capture thought | None | ✅ Yes | $4.99 once | Low |
| Maps search launcher | Custom quick access | None | ✅ Yes | $1.99 once | Very low |
| Expense capture | Log purchase at stop | None | ✅ Yes | $3.99 once | Low |
| Drive weather | Route forecast | Free | ✅ Mostly | $3.99 once | Medium |
| Mileage tracker | Tax documentation | None | ✅ Yes | $9.99/year | Low |

The common thread: each solves exactly one moment with data that either ships with the app, caches indefinitely, or requires no external data at all. None need user accounts, server-side processing, or ongoing operational costs beyond Apple's $99/year developer fee.