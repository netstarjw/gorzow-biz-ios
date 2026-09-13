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

## TestFlight / App Store
Projekt zawiera workflow GitHub Actions do weryfikacji kompilacji oraz przygotowanie pod automatyczny upload do TestFlight po dodaniu sekretów Apple.
