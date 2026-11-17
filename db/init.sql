DROP TABLE IF EXISTS clips CASCADE;
DROP TABLE IF EXISTS comments CASCADE;
DROP TABLE IF EXISTS videos CASCADE;

-- Video
CREATE TABLE videos (
                        id SERIAL PRIMARY KEY,
                        title VARCHAR(255) NOT NULL,
                        description TEXT,
                        url VARCHAR(500) NOT NULL,
                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Komentarai
CREATE TABLE comments (
                          id SERIAL PRIMARY KEY,
                          video_id INTEGER NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
                          author VARCHAR(100) NOT NULL,
                          content TEXT NOT NULL,
                          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Klipai
CREATE TABLE clips (
                       id SERIAL PRIMARY KEY,
                       comment_id INTEGER NOT NULL REFERENCES comments(id) ON DELETE CASCADE,
                       media_type VARCHAR(50) NOT NULL CHECK (media_type IN ('image', 'video_clip')),
                       media_url VARCHAR(500) NOT NULL,
                       timestamp_sec INTEGER DEFAULT 0,
                       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 17 video
-- ============================================================================
INSERT INTO videos (title, description, url) VALUES
                                                 ('Kaip sukurti REST API per 10 min', 'Mokomasis video apie Express ir Node.js', 'https://youtube.com/watch?v=vid01'),
                                                 ('Docker pamoka pradedantiesiems', 'Kaip konteinerizuoti PostgreSQL duomenų bazę', 'https://youtube.com/watch?v=vid02'),
                                                 ('PostgreSQL indeksai ir optimizavimas', 'Kaip pagreitinti SQL užklausas didelėse duomenų bazėse', 'https://youtube.com/watch?v=vid03'),
                                                 ('JWT Autentifikacija nuo A iki Z', 'Access ir Refresh žetonų veikimo principai Node.js aplinkoje', 'https://youtube.com/watch?v=vid04'),
                                                 ('React ir Vite greitas startas', 'Modernios vartotojo sąsajos (SPA) kūrimas per 15 minučių', 'https://youtube.com/watch?v=vid05'),
                                                 ('OpenAPI 3.0 ir Swagger dokumentacija', 'Kaip tvarkingai aprašyti REST API metodus ir schemas', 'https://youtube.com/watch?v=vid06'),
                                                 ('Git ir GitHub komandinis darbas', 'Šakos (branches), Pull Requests ir konfliktų sprendimas', 'https://youtube.com/watch?v=vid07'),
                                                 ('Postman automatizuoti testai', 'Collection Runner naudojimas greitam API testavimui', 'https://youtube.com/watch?v=vid08'),
                                                 ('Node.js Event Loop paaiškinimas', 'Kaip veikia asinchroninis programavimas JavaScript kalboje', 'https://youtube.com/watch?v=vid09'),
                                                 ('CSS Grid prieš Flexbox', 'Kada kurį išdėstymo būdą pasirinkti kuriant dizainą', 'https://youtube.com/watch?v=vid10'),
                                                 ('TypeScript pagrindai programuotojams', 'Griežtas tipizavimas ir sąsajos (Interfaces) praktiškai', 'https://youtube.com/watch?v=vid11'),
                                                 ('Linux komandinės eilutės triukai', 'Naudingiausios Bash komandos serverių administravimui', 'https://youtube.com/watch?v=vid12'),
                                                 ('Tinklų saugumas: HTTPS, TLS ir CORS', 'Kaip apsaugoti saityno aplikacijas nuo dažniausių atakų', 'https://youtube.com/watch?v=vid13'),
                                                 ('Mikroservisų architektūra prieš Monolitą', 'Architektūrinių sprendimų palyginimas ir pavyzdžiai', 'https://youtube.com/watch?v=vid14'),
                                                 ('Redis kešavimas (Caching) praktikoje', 'Kaip sumažinti duomenų bazės apkrovą naudojant Redis', 'https://youtube.com/watch?v=vid15'),
                                                 ('CI/CD konvejeriai su GitHub Actions', 'Automatinis testavimas ir diegimas į debesų platformas', 'https://youtube.com/watch?v=vid16'),
                                                 ('WebSockets ir realaus laiko aplikacijos', 'Susirašinėjimo ir tiesioginių pranešimų sistemos kūrimas', 'https://youtube.com/watch?v=vid17');

-- ============================================================================
-- 34 komentarai
-- ============================================================================
INSERT INTO comments (video_id, author, content) VALUES
-- Video 1 (2 komentarai -> ID: 1, 2)
(1, 'Tomas_KTU', 'Puikus video, bet 3 minutėje yra klaida kode! Pridedu ekrano nuotrauką.'),
(1, 'Jonas_Dev', 'Viskas veikia, štai mano rezultato klipas.'),
-- Video 2 (2 komentarai -> ID: 3, 4)
(2, 'Aistė', 'Labai aiškiai paaiškinta apie Docker Compose.'),
(2, 'Mantas_IT', 'Man meta port 5432 klaidą, prisegu terminalo vaizdą.'),
-- Video 3 (3 komentarai -> ID: 5, 6, 7)
(3, 'Lukas_SQL', 'B-Tree indekso paaiškinimas tiesiog super!'),
(3, 'Greta', 'Štai kaip pas mane pagreitėjo EXPLAIN ANALYZE užklausa.'),
(3, 'Paulius', 'Ar galite padaryti video ir apie sudėtinius indeksus?'),
-- Video 4 (1 komentaras -> ID: 8)
(4, 'Kipras', 'Pagaliau supratau, kam reikalingas Refresh Token!'),
-- Video 5 (2 komentarai -> ID: 9, 10)
(5, 'Eglė_UI', 'Vite sukasi nepalyginamai greičiau nei senas Create React App.'),
(5, 'Deividas', 'Pridedu savo sukurto pirmojo komponento vaizdą.'),
-- Video 6 (2 komentarai -> ID: 11, 12)
(6, 'Rokas', 'Swagger UI labai padėjo per laboratorinio darbo gynimą.'),
(6, 'Simona', '4:20 minutėje YAML faile trūksta dvitaškio, štai kur tiksliai.'),
-- Video 7 (3 komentarai -> ID: 13, 14, 15)
(7, 'Dominykas', 'Git rebase visada atrodė baisiai, bet šis klipas viską paaiškino.'),
(7, 'Ugnė', 'Štai mano šakų (branch) medis po šios pamokos.'),
(7, 'Karolis', 'Ačiū! Išsisprendžiau merge conflict per 2 minutes.'),
-- Video 8 (2 komentarai -> ID: 16, 17)
(8, 'Augustas', 'Visi 18 testų sužaliavo per vieną sekundę!'),
(8, 'Viktorija', 'Labai patogu išsaugoti sukurtą ID į collectionVariables.'),
-- Video 9 (1 komentaras -> ID: 18)
(9, 'Žygimantas', 'Call stack ir Callback queue animacija labai aiški.'),
-- Video 10 (2 komentarai -> ID: 19, 20)
(10, 'Laura_Design', 'Grid dvimačiams tinkleliams, Flexbox – vienai krypčiai. Paprasta!'),
(10, 'Tadas', 'Štai kaip pritaikiau Grid savo kurso projektui.'),
-- Video 11 (2 komentarai -> ID: 21, 22)
(11, 'Ignas_TS', 'Pradžioje sunku su tipais, bet WebStorm podėliai (autocomplete) viską atperka.'),
(11, 'Monika', 'Prisegu palyginimą tarp JS ir TS klaidų gaudymo.'),
-- Video 12 (1 komentaras -> ID: 23)
(12, 'Vytautas_Sys', 'grep ir awk komandos sutaupo valandų valandas darbe.'),
-- Video 13 (3 komentarai -> ID: 24, 25, 26)
(13, 'Andrius', 'CORS klaida naršyklėje mane kankino visą vakarą! Ačiū už sprendimą.'),
(13, 'Gabrielė', 'Labai gerai parodyta TLS handshake schema.'),
(13, 'Nojus', 'Pridedu pavyzdį, kaip atrodo saugūs HTTP antraščių (headers) nustatymai.'),
-- Video 14 (2 komentarai -> ID: 27, 28)
(14, 'Martynas', 'Mažiems projektams monolitas vis dar yra geriausias pasirinkimas.'),
(14, 'Kotryna', 'Štai mūsų komandos mikroservisų architektūros brėžinys.'),
-- Video 15 (2 komentarai -> ID: 29, 30)
(15, 'Darius', 'Su Redis atsako laikas nukrito nuo 400ms iki 5ms!'),
(15, 'Sandra', 'Prisegu Postman laiko matavimo rezultatus prieš ir po Redis.'),
-- Video 16 (2 komentarai -> ID: 31, 32)
(16, 'Laurynas', 'GitHub Actions failo pavyzdys labai pravertė.'),
(16, 'Justė', 'Žalias varnelės ženklas prie commit visada pradžiugina!'),
-- Video 17 (2 komentarai -> ID: 33, 34)
(17, 'Arnas', 'Socket.io biblioteka labai palengvina darbą su WebSockets.'),
(17, 'Kamilė', 'Štai mano veikiančio pokalbių kambario (chat) demonstracija.');

-- ============================================================================
-- 45 klipai
-- ============================================================================
INSERT INTO clips (comment_id, media_type, media_url, timestamp_sec) VALUES
-- Komentarui 1 (2 klipai)
(1, 'image', 'https://imgur.com/clipsync/err_screenshot_1.png', 180),
(1, 'video_clip', 'https://imgur.com/clipsync/bug_repro_1.mp4', 185),
-- Komentarui 2 (1 klipas)
(2, 'video_clip', 'https://imgur.com/clipsync/working_demo_2.mp4', 45),
-- Komentarui 3 (1 klipas)
(3, 'image', 'https://imgur.com/clipsync/docker_diagram_3.png', 120),
-- Komentarui 4 (2 klipai)
(4, 'image', 'https://imgur.com/clipsync/port_error_4.png', 310),
(4, 'video_clip', 'https://imgur.com/clipsync/terminal_log_4.mp4', 315),
-- Komentarui 5 (1 klipas)
(5, 'image', 'https://imgur.com/clipsync/btree_graph_5.png', 95),
-- Komentarui 6 (2 klipai)
(6, 'image', 'https://imgur.com/clipsync/explain_before_6.png', 210),
(6, 'image', 'https://imgur.com/clipsync/explain_after_6.png', 215),
-- Komentarui 7 (1 klipas)
(7, 'video_clip', 'https://imgur.com/clipsync/multi_index_7.mp4', 400),
-- Komentarui 8 (2 klipai)
(8, 'image', 'https://imgur.com/clipsync/jwt_flow_8.png', 150),
(8, 'video_clip', 'https://imgur.com/clipsync/token_refresh_8.mp4', 280),
-- Komentarui 9 (1 klipas)
(9, 'video_clip', 'https://imgur.com/clipsync/vite_speed_9.mp4', 30),
-- Komentarui 10 (1 klipas)
(10, 'image', 'https://imgur.com/clipsync/react_comp_10.png', 420),
-- Komentarui 11 (1 klipas)
(11, 'image', 'https://imgur.com/clipsync/swagger_ui_11.png', 60),
-- Komentarui 12 (2 klipai)
(12, 'image', 'https://imgur.com/clipsync/yaml_typo_12.png', 260),
(12, 'image', 'https://imgur.com/clipsync/yaml_fixed_12.png', 265),
-- Komentarui 13 (1 klipas)
(13, 'video_clip', 'https://imgur.com/clipsync/git_rebase_13.mp4', 190),
-- Komentarui 14 (1 klipas)
(14, 'image', 'https://imgur.com/clipsync/git_tree_14.png', 300),
-- Komentarui 15 (2 klipai)
(15, 'video_clip', 'https://imgur.com/clipsync/conflict_solve_15.mp4', 410),
(15, 'image', 'https://imgur.com/clipsync/clean_merge_15.png', 430),
-- Komentarui 16 (2 klipai)
(16, 'image', 'https://imgur.com/clipsync/postman_18_pass_16.png', 15),
(16, 'video_clip', 'https://imgur.com/clipsync/runner_demo_16.mp4', 20),
-- Komentarui 17 (1 klipas)
(17, 'image', 'https://imgur.com/clipsync/pm_variables_17.png', 140),
-- Komentarui 18 (1 klipas)
(18, 'video_clip', 'https://imgur.com/clipsync/event_loop_anim_18.mp4', 220),
-- Komentarui 19 (1 klipas)
(19, 'image', 'https://imgur.com/clipsync/grid_vs_flex_19.png', 85),
-- Komentarui 20 (2 klipai)
(20, 'image', 'https://imgur.com/clipsync/my_grid_layout_20.png', 340),
(20, 'video_clip', 'https://imgur.com/clipsync/responsive_test_20.mp4', 355),
-- Komentarui 21 (1 klipas)
(21, 'video_clip', 'https://imgur.com/clipsync/webstorm_ts_21.mp4', 110),
-- Komentarui 22 (1 klipas)
(22, 'image', 'https://imgur.com/clipsync/ts_type_check_22.png', 275),
-- Komentarui 23 (1 klipas)
(23, 'image', 'https://imgur.com/clipsync/bash_cheatsheet_23.png', 50),
-- Komentarui 24 (2 klipai)
(24, 'image', 'https://imgur.com/clipsync/cors_blocked_24.png', 130),
(24, 'image', 'https://imgur.com/clipsync/cors_fixed_24.png', 145),
-- Komentarui 25 (1 klipas)
(25, 'image', 'https://imgur.com/clipsync/tls_handshake_25.png', 195),
-- Komentarui 26 (1 klipas)
(26, 'image', 'https://imgur.com/clipsync/helmet_headers_26.png', 380),
-- Komentarui 27 (1 klipas)
(27, 'image', 'https://imgur.com/clipsync/monolith_pros_27.png', 70),
-- Komentarui 28 (2 klipai)
(28, 'image', 'https://imgur.com/clipsync/microservices_arch_28.png', 240),
(28, 'video_clip', 'https://imgur.com/clipsync/docker_swarm_28.mp4', 290),
-- Komentarui 29 (1 klipas)
(29, 'video_clip', 'https://imgur.com/clipsync/redis_benchmark_29.mp4', 160),
-- Komentarui 30 (2 klipai)
(30, 'image', 'https://imgur.com/clipsync/postman_400ms_30.png', 170),
(30, 'image', 'https://imgur.com/clipsync/postman_5ms_30.png', 175),
-- Komentarui 31 (1 klipas)
(31, 'image', 'https://imgur.com/clipsync/gh_actions_yaml_31.png', 205),
-- Komentarui 32 (1 klipas)
(32, 'image', 'https://imgur.com/clipsync/ci_pipeline_green_32.png', 330),
-- Komentarui 33 (1 klipas)
(33, 'image', 'https://imgur.com/clipsync/ws_frames_33.png', 100),
-- Komentarui 34 (2 klipai)
(34, 'video_clip', 'https://imgur.com/clipsync/live_chat_demo_34.mp4', 250),
(34, 'image', 'https://imgur.com/clipsync/chat_ui_34.png', 260);
