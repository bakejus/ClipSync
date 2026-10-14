# ClipSync – Interaktyvi vaizdo įrašų ir medijos komentarų platforma

## 1. Sprendžiamo uždavinio aprašymas

### 1.1. Sistemos paskirtis
Sukurti šiuolaikišką saityno taikomąją programą, kuri leidžia vartotojams talpinti vaizdo įrašus, juos komentuoti bei prie komentarų pridėti savo nuotraukas arba trumpus vaizdo klipus. Sistema užtikrina duomenų bazės integraciją, saugią autentifikaciją, hierarchinį duomenų filtravimą bei patogią grafinę vartotojo sąsają, pasiekiamą per naršyklę.

### 1.2. Funkciniai reikalavimai ir taikomosios srities objektai
Sistemoje realizuoti trys tarpusavyje prasminiu ir hierarchiniu ryšiu susieti objektai (`Video -> Comment -> Clip`):
1. **Vaizdo įrašas (`Video`)** – pagrindinis sistemos objektas.
2. **Komentaras (`Comment`)** – priklauso konkrečiam vaizdo įrašui.
3. **Klipas / medijos priedas (`Clip`)** – priklauso konkrečiam komentarui (`image` arba `video_clip`).

**Rolės:**
* **Svečias (Guest)** – gali naršyti ir peržiūrėti vaizdo įrašus, komentarus bei klipus.
* **Narys (Member)** – gali įkelti vaizdo įrašus, rašyti komentarus, pridėti klipus bei valdyti savo sukurtą turinį.
* **Administratorius (Admin)** – turi visišką prieigą prie sistemos, gali keisti, šalinti bet kokį netinkamą turinį.

---

## 2. Pasirinktos technologijos
* **Backend:** Node.js, Express.js (REST API)
* **Duomenų bazė:** PostgreSQL 16 (konteinerizuota su Docker)
* **Dokumentacija:** OpenAPI 3.0 (Swagger UI)
* **Testavimas:** Postman (automatizuoti Collection Runner testai)

---

## 3. Realizuoti REST API metodai (15 metodų)

### Videos (Vaizdo įrašai)
1. `GET /api/videos` – Grąžina visų vaizdo įrašų sąrašą (`200 OK`)
2. `GET /api/videos/{id}` – Grąžina vieną vaizdo įrašą pagal ID (`200 OK`, `400`, `404`)
3. `POST /api/videos` – Sukuria naują vaizdo įrašą (`201 Created`, `422`)
4. `PUT /api/videos/{id}` – Atnaujina vaizdo įrašą (`200 OK`, `400`, `404`, `422`)
5. `DELETE /api/videos/{id}` – Ištrina vaizdo įrašą (`204 No Content`, `400`, `404`)

### Comments (Komentarai – hierarchiniai ryšiai su Video)
6. `GET /api/videos/{videoId}/comments` – Grąžina visus konkretaus video komentarus (`200 OK`, `400`, `404`)
7. `GET /api/comments/{id}` – Grąžina konkretų komentarą pagal ID (`200 OK`, `400`, `404`)
8. `POST /api/videos/{videoId}/comments` – Sukuria komentarą konkrečiam video (`201 Created`, `400`, `404`, `422`)
9. `PUT /api/comments/{id}` – Atnaujina komentarą (`200 OK`, `400`, `404`, `422`)
10. `DELETE /api/comments/{id}` – Ištrina komentarą (`204 No Content`, `400`, `404`)

### Clips (Medijos klipai – hierarchiniai ryšiai su Comment)
11. `GET /api/comments/{commentId}/clips` – Grąžina visus konkretaus komentaro klipus (`200 OK`, `400`, `404`)
12. `GET /api/clips/{id}` – Grąžina konkretų klipą pagal ID (`200 OK`, `400`, `404`)
13. `POST /api/comments/{commentId}/clips` – Prideda klipą prie konkretaus komentaro (`201 Created`, `400`, `404`, `422`)
14. `PUT /api/clips/{id}` – Atnaujina klipą (`200 OK`, `400`, `404`, `422`)
15. `DELETE /api/clips/{id}` – Ištrina klipą (`204 No Content`, `400`, `404`)

---

## 4. Projekto paleidimo instrukcija

1. **Paleiskite PostgreSQL duomenų bazę su Docker:**
   ```bash
   docker compose up -d
   ```
2. **Įdiekite Backend priklausomybes ir paleiskite serverį:**
	```bash
	cd backend
	npm install
	node server.js
	```
3. **OpenAPI (Swagger) dokumentacija pasiekiama adresu:**
	```bash
	http://localhost:3000/api-docs
	```
4. **Testavimas:**
	Importuokite
	```bash 
	ClipSync_Postman_Collection.json
	```
	į Postman ir paleiskite per Collection Runner