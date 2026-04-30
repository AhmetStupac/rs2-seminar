## 🏋️ FindAPersonalTrainer

FindAPersonalTrainer je informacioni sistem koji omogućava korisnicima pronalaženje i angažovanje personalnih trenera, rezervaciju individualnih i grupnih treninga, praćenje planova ishrane i treninga, te online plaćanje usluga.
Sistem obuhvata desktop aplikaciju za administratore i trenere, mobilnu aplikaciju za korisnike, te backend razvijen u ASP.NET Core.

---

### 🚀 Upute za pokretanje

#### 🔹 Backend setup

1. Klonirati repozitorij.

2. Pozicionirati se u folder `API/eCommerce/`.

3. Kopirati `.env.example` u `.env` i popuniti stvarne vrijednosti (SQL password, SMTP kredencijali, Stripe ključevi, JWT secret, Azure Blob Storage connection string).

4. U terminalu pokrenuti komandu: `docker compose up --build`

5. Sačekati da se backend, baza podataka i RabbitMQ uspješno podignu. ⏳

---

#### 🔹 Desktop aplikacija (admin / trener)

1. Pozicionirati se u folder `UI/personaltrainer_desktop/`.

2. Pokrenuti komandu: `flutter run -d windows`

3. Prijaviti se pomoću admin kredencijala (kredencijali u nastavku...).

- Ukoliko zelite testirati registraciju ili dodavanje teretana, email trebate napisati u formatu xxx.xxx@edu.fit.ba ili xxx.xxx@xxx.com
- Prilikom ulaska u applikacijnu trener ce biti usmjeren na Exercise plan ekran na kojem se dodaje cijena trening plana, vrijeme trajanja i dodatne biljeske.
  Ovaj dio sluzi za dodavanja vjezbi određenom trening planu.
  Prvo sto trebate uraditi je selektovati trening plan iz liste, te dodati vjezbe. Ukoliko ne vidite trening planove, potrebno je otici na ekran 
  Exercise -> Training Plan Management -> Add Training Plan.
- U Sekciji Exercise ima par opcija. Jedna od tih je dodavanje novih vjezba za trening. Prvo sto je potrebno uraditi je upload-ovati sliku,  te nakon toga unjeti ostale podatke.
- Iduca opcija je dodavanje opreme za trening, a nakon toga dolazi dodavanje misicnih grupa.
- Opcija My Dashboard  se moze gledati iz 2 perspektive. Prva je kao trener gdje ce biti prikazana statistika o treneru, a druga je statistika cijele aplikacije.
  Tu se potrebno login-ovati kao superadmin
- Iduca sekcija je Nutrition Plan, gdje trener pravi planove ishrane za klijente
- Za testiranje chat-a najbolje je upaliti ili  2 desktop aplikacije ili poslati poruku sa desktop-a na mobile aplikaciju.

- superadmin ima dodatne privilegije kojim moze ban-ovati korisnika i soft delete ga.

#### 🔹 Mobilna aplikacija (korisnici)

1. Pozicionirati se u folder `UI/personalTrainer_mobile/`.

2. Pokrenuti komandu: `flutter run`

3. Pokrenuti aplikaciju i prijaviti se pomoću testnih kredencijala (username: mobile, password: test).

- Prilikom ulaska na mobilnu aplikaciju korisnik je preusmjern na stranicu za pretragu personalnih trenera. Serach polje ima integrisanu filtraciju po vrsti sporta,
  spolu, ratingu i min. i max. cijeni
- Korisnik kada uđe u profil zeljenog trenera ima opciju kupovine trening plana, plana ishrane i clanarine(30 dana). 
  Ukoliko se korisnik odluci da kupi jedan od planova, taj plan mu se prikazuje u npr. Training Plans sekciji gdje moze vidjeti detalje treninga.
  Vazno je napomenti da klijent moze rezervisati trening kod personalnog trenera tek nakon sto kupi clanarinu.
  Ukoliko je trener zadovoljan trening uslugama moze ocjeniti  trenera i ostaviti komentar.
- U Sekcijama Training Plans i Nutrition Plans korisnik moze da detaljnije vidi kupljene programe.
- U sekciji My Training, korisnik ima uvid u nadolazece treninge. Ukoliko je potrebno trening se moze otkazati ili se moze odabrati drugi termin.
	(korisnik ne mora napisati razlog otkazivanja, dok trener ukoliko otkaze trening mora navesti i razlog)
- Sekcija Group Training Sessions je namjenjena za zajednicke grupne treninge kojim bilo ko moze prisustvovati.
  Bilo koji korisnik moze kreirati grupni trening, a ostali korisnici imaju opciju da se pridruze treningu.
  Kada trening zavrsi potrebno ga je ukloniti sa liste.
- Sekcija Training Statistics je dodana tako da korisnik moze pratiti svoj napredak u treninzima.
- Notifikacije su napravljane za: (refreshuju se pomocu pollinga svakih 5 sec)
	•	uspješnu kupovinu
	•	refund
	•	novu grupnu sesiju
	•	rezervaciju trening sesije
	•	primljenu poruku u chatu

- U sekciji Payments korisnik ima uvid u kupovine, te ukoliko je potrebno moze uraditi refund.

#### 🔐 Kredencijali za prijavu

##### SuperAdmin (desktop aplikacija)

- username: superadmin
- password: test


##### PersonalTrainer (desktop/uloga trener)

- username: desktop
- password: test

##### Korisnik (mobilna aplikacija/ uloga korisnik)

- username: mobile
- password: test

---


#### 💳 Stripe testiranje

Za testiranje plaćanja u mobilnoj aplikaciji koristite sljedeće podatke:

1. Broj kartice: 4242 4242 4242 4242

2. Datum isteka: bilo koji budući datum

3. CVC: bilo koji trocifreni broj

4. ZIP kod: bilo koji petocifreni broj

Ukoliko kupac zeli da kupi trening plan, plan ishrane ili clanarinu kod nekog od trenera. Potrebno je da prvo preko mobilne aplikacije 
kupi npr. Plan ishrane, tek mu se nakon toga prikazuje u određenom screen-u da ima taj trening plan.
Izuzetak je u rezervaciji trening planova,
Ukoliko klijent zeli da uradi filtraciju po cijeni, filtracija ce samo raditi ako određeni trener vec ima zakazane trening sesije sa drugim klijentima.
---

#### 📩 RabbitMQ integracija

FindAPersonalTrainer koristi RabbitMQ mikroservis za automatsko slanje email obavijesti u sljedećim slučajevima:

- Registracija novog korisnika na mobilnoj aplikaciji
- Prijava korisnika na racun
- Resetovanje lozinke korisnika

---

#### 💬 SignalR integracija

Aplikacija koristi SignalR za real-time funkcionalnosti:

- Praćenje online statusa korisnika (PresenceHub)

- Real-time razmjena poruka između korisnika i trenera (MessagesHub)

---

#### 🤖 Recommender sistem (ML.NET)

Aplikacija koristi ML.NET Matrix Factorization algoritam za preporuku personalnih trenera korisnicima na osnovu:

- Historije održanih trening sesija

- Ocjena korisnika (ratinga ≥ 4)

---

#### 📄 PDF izvještaji

Desktop aplikacija omogućava generisanje i preuzimanje PDF izvještaja putem paketa `pdf` i `printing`.

---

#### 🛠️ Tehnologije

- Backend: ASP.NET Core (C#), EF Core

- Frontend: Flutter (desktop i mobilna aplikacija)

- Baza podataka: SQL Server

- Autentifikacija & autorizacija: JWT Bearer tokens

- Message Broker: RabbitMQ

- Real-time komunikacija: SignalR

- Plaćanje: Stripe

- Skladištenje slika: Azure Blob Storage

- Machine Learning: ML.NET (Matrix Factorization)

- Containerization: Docker

---

📌 Projekt razvijen u sklopu predmeta Razvoj softvera 2 na Fakultetu informacijskih tehnologija Mostar.






