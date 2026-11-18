# FSM Quest

FSM Quest ist ein mit Flutter entwickeltes Lernspiel zu endlichen Automaten und digitaler Technik. Die Anwendung enthält fünf Kapitel mit interaktiven Lektionen und Prüfungsaufgaben sowie einen Editor für endliche Automaten. Sie ist für Android und den Browser vorgesehen.

## Lernpfad

1. Grundlagen endlicher Automaten
2. Digitale Schaltungen als Automaten verstehen
3. Automaten vervollständigen
4. Automaten aus Beschreibungen und Tabellen erstellen
5. Prüfungsaufgaben (fünf Lektionen mit insgesamt 15 Aufgaben)

Das Erstellungskapitel endet mit drei praktischen Aufgaben: 20 Minuten.
Das komplette Durchspielen des Spiels dauert etwa 40 bis 60 Minuten.

## Lokal im Browser starten

Voraussetzung ist eine installierte Flutter-Version, die zur SDK-Anforderung in `pubspec.yaml` passt.

```sh
flutter pub get
flutter run -d chrome
```

## Web-Version bauen

```sh
flutter build web --release
```

Die statischen Dateien für eine spätere Bereitstellung liegen anschließend in `build/web`.

Der Lernfortschritt wird lokal im Browserprofil gespeichert. Er wird nicht automatisch zwischen Browsern oder Geräten synchronisiert.
