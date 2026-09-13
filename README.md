# gorzow.biz iOS

Natywna aplikacja iPhone dla https://gorzow.biz oparta na WKWebView.

## Wymagania
- Xcode 16 lub nowszy
- iOS 16+
- konto Apple Developer

## Uruchomienie na iPhonie
1. Otwórz `GorzowBiz.xcodeproj` w Xcode.
2. Zaznacz target **GorzowBiz** → **Signing & Capabilities**.
3. Włącz **Automatically manage signing**.
4. Wybierz swoje **Team** z Apple Developer.
5. Bundle Identifier domyślnie: `biz.gorzow.mobile`. Jeśli identyfikator jest już zajęty na Twoim koncie, zmień go na unikalny, np. `pl.netstar.gorzowbiz`.
6. Podłącz iPhone i wybierz go jako urządzenie docelowe.
7. Kliknij **Run**.

## GitHub Actions
- `Verify iOS build` — automatycznie sprawdza kompilację po każdym pushu do `main`.
- `Upload iOS to TestFlight` — uruchamiany ręcznie i wysyła build do App Store Connect/TestFlight.
- Ikony aplikacji są generowane automatycznie przed buildem przez `Scripts/generate_icons.swift`.

## Sekrety GitHub wymagane do TestFlight
W repozytorium wejdź w **Settings → Secrets and variables → Actions → New repository secret** i dodaj:

- `APPLE_TEAM_ID` — identyfikator Twojego Apple Developer Team.
- `ASC_KEY_ID` — Key ID klucza App Store Connect API.
- `ASC_ISSUER_ID` — Issuer ID z App Store Connect API.
- `ASC_PRIVATE_KEY` — pełna zawartość pliku `AuthKey_XXXXXXXXXX.p8`, łącznie z liniami BEGIN/END PRIVATE KEY.

Nie zapisuj pliku `.p8`, certyfikatów ani haseł bezpośrednio w repozytorium.

## TestFlight
Po dodaniu sekretów:
1. Otwórz zakładkę **Actions** w GitHub.
2. Wybierz `Upload iOS to TestFlight`.
3. Kliknij **Run workflow**.
4. Workflow utworzy archiwum Release i spróbuje przesłać aplikację do App Store Connect.

Przed pierwszym uploadem upewnij się, że identyfikator aplikacji `biz.gorzow.mobile` istnieje na Twoim koncie Apple Developer/App Store Connect oraz że aplikacja została utworzona w App Store Connect.
