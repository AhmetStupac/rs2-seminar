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

Ukoliko zelite testirati registraciju ili dodavanje teretana, email trebate napisati u formatu xxx.xxx@edu.fit.ba ili xxx.xxx@xxx.com

---

#### 🔹 Mobilna aplikacija (korisnici)

1. Pozicionirati se u folder `UI/personalTrainer_mobile/`.

2. Pokrenuti komandu: `flutter run`

3. Pokrenuti aplikaciju i prijaviti se pomoću testnih kredencijala (kredencijali u nastavku...).

---

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
