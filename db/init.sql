DROP TABLE IF EXISTS clips CASCADE;
DROP TABLE IF EXISTS comments CASCADE;
DROP TABLE IF EXISTS videos CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Naudootoju lentele
CREATE TABLE users (
                       id SERIAL PRIMARY KEY,
                       username VARCHAR(100) UNIQUE NOT NULL,
                       email VARCHAR(255) UNIQUE NOT NULL,
                       password_hash VARCHAR(255) NOT NULL,
                       role VARCHAR(50) NOT NULL DEFAULT 'member' CHECK (role IN ('guest', 'member', 'admin')),
                       refresh_token TEXT,
                       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Video
CREATE TABLE videos (
                        id SERIAL PRIMARY KEY,
                        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                        title VARCHAR(255) NOT NULL,
                        description TEXT,
                        url VARCHAR(500) NOT NULL,
                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Komentarai
CREATE TABLE comments (
                          id SERIAL PRIMARY KEY,
                          video_id INTEGER NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
                          user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                          author VARCHAR(100) NOT NULL,
                          content TEXT NOT NULL,
                          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Klipai
CREATE TABLE clips (
                       id SERIAL PRIMARY KEY,
                       comment_id INTEGER NOT NULL REFERENCES comments(id) ON DELETE CASCADE,
                       user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                       media_type VARCHAR(50) NOT NULL CHECK (media_type IN ('image', 'video_clip')),
                       media_url VARCHAR(500) NOT NULL,
                       timestamp_sec INTEGER DEFAULT 0,
                       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- PRadiniai naudotojai (slaptazodis123)
INSERT INTO users (username, email, password_hash, role) VALUES
                                                             ('Admin', 'admin@clipsync.lt', '$2a$10$X7G.2c3E8n9kL1p5Q6r8uO9vW0xY1zA2bC3dE4fG5hI6jK7lM8nO.', 'admin'),
                                                             ('Tomas_KTU', 'tomas@ktu.lt', '$2a$10$X7G.2c3E8n9kL1p5Q6r8uO9vW0xY1zA2bC3dE4fG5hI6jK7lM8nO.', 'member'),
                                                             ('Jonas_Dev', 'jonas@dev.lt', '$2a$10$X7G.2c3E8n9kL1p5Q6r8uO9vW0xY1zA2bC3dE4fG5hI6jK7lM8nO.', 'member');

-- ============================================================================
-- 17 video
-- ============================================================================
INSERT INTO videos (user_id, title, description, url) VALUES
                                                          (1, 'Kaip sukurti REST API per 10 min', 'Mokomasis video apie Express ir Node.js', 'https://youtube.com/watch?v=vid01'),
                                                          (2, 'Docker pamoka pradedantiesiems', 'Kaip konteinerizuoti PostgreSQL duomenų bazę', 'https://youtube.com/watch?v=vid02'),
                                                          (3, 'PostgreSQL indeksai ir optimizavimas', 'Kaip pagreitinti SQL užklausas didelėse duomenų bazėse', 'https://youtube.com/watch?v=vid03'),
                                                          (1, 'JWT Autentifikacija nuo A iki Z', 'Access ir Refresh žetonų veikimo principai Node.js aplinkoje', 'https://youtube.com/watch?v=vid04'),
                                                          (2, 'React ir Vite greitas startas', 'Modernios vartotojo sąsajos (SPA) kūrimas per 15 minučių', 'https://youtube.com/watch?v=vid05'),
                                                          (3, 'OpenAPI 3.0 ir Swagger dokumentacija', 'Kaip tvarkingai aprašyti REST API metodus ir schemas', 'https://youtube.com/watch?v=vid06'),
                                                          (1, 'Git ir GitHub komandinis darbas', 'Šakos (branches), Pull Requests ir konfliktų sprendimas', 'https://youtube.com/watch?v=vid07'),
                                                          (2, 'Postman automatizuoti testai', 'Collection Runner naudojimas greitam API testavimui', 'https://youtube.com/watch?v=vid08'),
                                                          (3, 'Node.js Event Loop paaiškinimas', 'Kaip veikia asinchroninis programavimas JavaScript kalboje', 'https://youtube.com/watch?v=vid09'),
                                                          (1, 'CSS Grid prieš Flexbox', 'Kada kurį išdėstymo būdą pasirinkti kuriant dizainą', 'https://youtube.com/watch?v=vid10'),
                                                          (2, 'TypeScript pagrindai programuotojams', 'Griežtas tipizavimas ir sąsajos (Interfaces) praktiškai', 'https://youtube.com/watch?v=vid11'),
                                                          (3, 'Linux komandinės eilutės triukai', 'Naudingiausios Bash komandos serverių administravimui', 'https://youtube.com/watch?v=vid12'),
                                                          (1, 'Tinklų saugumas: HTTPS, TLS ir CORS', 'Kaip apsaugoti saityno aplikacijas nuo dažniausių atakų', 'https://youtube.com/watch?v=vid13'),
                                                          (2, 'Mikroservisų architektūra prieš Monolitą', 'Architektūrinių sprendimų palyginimas ir pavyzdžiai', 'https://youtube.com/watch?v=vid14'),
                                                          (3, 'Redis kešavimas (Caching) praktikoje', 'Kaip sumažinti duomenų bazės apkrovą naudojant Redis', 'https://youtube.com/watch?v=vid15'),
                                                          (1, 'CI/CD konvejeriai su GitHub Actions', 'Automatinis testavimas ir diegimas į debesų platformas', 'https://youtube.com/watch?v=vid16'),
                                                          (2, 'WebSockets ir realaus laiko aplikacijos', 'Susirašinėjimo ir tiesioginių pranešimų sistemos kūrimas', 'https://youtube.com/watch?v=vid17');

-- ============================================================================
-- 34 komentarai
-- ============================================================================
INSERT INTO comments (video_id, user_id, author, content) VALUES
                                                              (1, 2, 'Tomas_KTU', 'Puikus video, bet 3 minutėje yra klaida kode! Pridedu ekrano nuotrauką.'),
                                                              (1, 3, 'Jonas_Dev', 'Viskas veikia, štai mano rezultato klipas.'),
                                                              (2, 2, 'Tomas_KTU', 'Labai aiškiai paaiškinta apie Docker Compose.'),
                                                              (2, 3, 'Jonas_Dev', 'Man meta port 5432 klaidą, prisegu terminalo vaizdą.'),
                                                              (3, 2, 'Tomas_KTU', 'B-Tree indekso paaiškinimas tiesiog super!'),
                                                              (3, 3, 'Jonas_Dev', 'Štai kaip pas mane pagreitėjo EXPLAIN ANALYZE užklausa.'),
                                                              (3, 1, 'Admin', 'Ar galite padaryti video ir apie sudėtinius indeksus?'),
                                                              (4, 2, 'Tomas_KTU', 'Pagaliau supratau, kam reikalingas Refresh Token!'),
                                                              (5, 3, 'Jonas_Dev', 'Vite sukasi nepalyginamai greičiau nei senas Create React App.'),
                                                              (5, 2, 'Tomas_KTU', 'Pridedu savo sukurto pirmojo komponento vaizdą.'),
                                                              (6, 3, 'Jonas_Dev', 'Swagger UI labai padėjo per laboratorinio darbo gynimą.'),
                                                              (6, 2, 'Tomas_KTU', '4:20 minutėje YAML faile trūksta dvitaškio, štai kur tiksliai.'),
                                                              (7, 3, 'Jonas_Dev', 'Git rebase visada atrodė baisiai, bet šis klipas viską paaiškino.'),
                                                              (7, 2, 'Tomas_KTU', 'Štai mano šakų (branch) medis po šios pamokos.'),
                                                              (7, 1, 'Admin', 'Ačiū! Išsisprendžiau merge conflict per 2 minutes.'),
                                                              (8, 1, 'Admin', 'Visi testai sužaliavo per vieną sekundę!'),
                                                              (8, 2, 'Tomas_KTU', 'Labai patogu išsaugoti sukurtą ID į collectionVariables.'),
                                                              (9, 3, 'Jonas_Dev', 'Call stack ir Callback queue animacija labai aiški.'),
                                                              (10, 2, 'Tomas_KTU', 'Grid dvimačiams tinkleliams, Flexbox – vienai krypčiai. Paprasta!'),
                                                              (10, 3, 'Jonas_Dev', 'Štai kaip pritaikiau Grid savo kurso projektui.'),
                                                              (11, 2, 'Tomas_KTU', 'Pradžioje sunku su tipais, bet WebStorm podėliai (autocomplete) viską atperka.'),
                                                              (11, 3, 'Jonas_Dev', 'Prisegu palyginimą tarp JS ir TS klaidų gaudymo.'),
                                                              (12, 2, 'Tomas_KTU', 'grep ir awk komandos sutaupo valandų valandas darbe.'),
                                                              (13, 3, 'Jonas_Dev', 'CORS klaida naršyklėje mane kankino visą vakarą! Ačiū už sprendimą.'),
                                                              (13, 2, 'Tomas_KTU', 'Labai gerai parodyta TLS handshake schema.'),
                                                              (13, 1, 'Admin', 'Pridedu pavyzdį, kaip atrodo saugūs HTTP antraščių (headers) nustatymai.'),
                                                              (14, 2, 'Tomas_KTU', 'Mažiems projektams monolitas vis dar yra geriausias pasirinkimas.'),
                                                              (14, 3, 'Jonas_Dev', 'Štai mūsų komandos mikroservisų architektūros brėžinys.'),
                                                              (15, 2, 'Tomas_KTU', 'Su Redis atsako laikas nukrito nuo 400ms iki 5ms!'),
                                                              (15, 3, 'Jonas_Dev', 'Prisegu Postman laiko matavimo rezultatus prieš ir po Redis.'),
                                                              (16, 2, 'Tomas_KTU', 'GitHub Actions failo pavyzdys labai pravertė.'),
                                                              (16, 3, 'Jonas_Dev', 'Žalias varnelės ženklas prie commit visada pradžiugina!'),
                                                              (17, 2, 'Tomas_KTU', 'Socket.io biblioteka labai palengvina darbą su WebSockets.'),
                                                              (17, 3, 'Jonas_Dev', 'Štai mano veikiančio pokalbių kambario (chat) demonstracija.');

-- ============================================================================
-- 45 klipai
-- ============================================================================
INSERT INTO clips (comment_id, user_id, media_type, media_url, timestamp_sec) VALUES
                                                                                  (1, 2, 'image', 'https://imgur.com/clipsync/err_screenshot_1.png', 180),
                                                                                  (1, 2, 'video_clip', 'https://imgur.com/clipsync/bug_repro_1.mp4', 185),
                                                                                  (2, 3, 'video_clip', 'https://imgur.com/clipsync/working_demo_2.mp4', 45),
                                                                                  (3, 2, 'image', 'https://imgur.com/clipsync/docker_diagram_3.png', 120),
                                                                                  (4, 3, 'image', 'https://imgur.com/clipsync/port_error_4.png', 310),
                                                                                  (4, 3, 'video_clip', 'https://imgur.com/clipsync/terminal_log_4.mp4', 315),
                                                                                  (5, 2, 'image', 'https://imgur.com/clipsync/btree_graph_5.png', 95),
                                                                                  (6, 3, 'image', 'https://imgur.com/clipsync/explain_before_6.png', 210),
                                                                                  (6, 3, 'image', 'https://imgur.com/clipsync/explain_after_6.png', 215),
                                                                                  (7, 1, 'video_clip', 'https://imgur.com/clipsync/multi_index_7.mp4', 400),
                                                                                  (8, 2, 'image', 'https://imgur.com/clipsync/jwt_flow_8.png', 150),
                                                                                  (8, 2, 'video_clip', 'https://imgur.com/clipsync/token_refresh_8.mp4', 280),
                                                                                  (9, 3, 'video_clip', 'https://imgur.com/clipsync/vite_speed_9.mp4', 30),
                                                                                  (10, 2, 'image', 'https://imgur.com/clipsync/react_comp_10.png', 420),
                                                                                  (11, 3, 'image', 'https://imgur.com/clipsync/swagger_ui_11.png', 60),
                                                                                  (12, 2, 'image', 'https://imgur.com/clipsync/yaml_typo_12.png', 260),
                                                                                  (12, 2, 'image', 'https://imgur.com/clipsync/yaml_fixed_12.png', 265),
                                                                                  (13, 3, 'video_clip', 'https://imgur.com/clipsync/git_rebase_13.mp4', 190),
                                                                                  (14, 2, 'image', 'https://imgur.com/clipsync/git_tree_14.png', 300),
                                                                                  (15, 1, 'video_clip', 'https://imgur.com/clipsync/conflict_solve_15.mp4', 410),
                                                                                  (15, 1, 'image', 'https://imgur.com/clipsync/clean_merge_15.png', 430),
                                                                                  (16, 1, 'image', 'https://imgur.com/clipsync/postman_18_pass_16.png', 15),
                                                                                  (16, 1, 'video_clip', 'https://imgur.com/clipsync/runner_demo_16.mp4', 20),
                                                                                  (17, 2, 'image', 'https://imgur.com/clipsync/pm_variables_17.png', 140),
                                                                                  (18, 3, 'video_clip', 'https://imgur.com/clipsync/event_loop_anim_18.mp4', 220),
                                                                                  (19, 2, 'image', 'https://imgur.com/clipsync/grid_vs_flex_19.png', 85),
                                                                                  (20, 3, 'image', 'https://imgur.com/clipsync/my_grid_layout_20.png', 340),
                                                                                  (20, 3, 'video_clip', 'https://imgur.com/clipsync/responsive_test_20.mp4', 355),
                                                                                  (21, 2, 'video_clip', 'https://imgur.com/clipsync/webstorm_ts_21.mp4', 110),
                                                                                  (22, 3, 'image', 'https://imgur.com/clipsync/ts_type_check_22.png', 275),
                                                                                  (23, 2, 'image', 'https://imgur.com/clipsync/bash_cheatsheet_23.png', 50),
                                                                                  (24, 3, 'image', 'https://imgur.com/clipsync/cors_blocked_24.png', 130),
                                                                                  (24, 3, 'image', 'https://imgur.com/clipsync/cors_fixed_24.png', 145),
                                                                                  (25, 2, 'image', 'https://imgur.com/clipsync/tls_handshake_25.png', 195),
                                                                                  (26, 1, 'image', 'https://imgur.com/clipsync/helmet_headers_26.png', 380),
                                                                                  (27, 2, 'image', 'https://imgur.com/clipsync/monolith_pros_27.png', 70),
                                                                                  (28, 3, 'image', 'https://imgur.com/clipsync/microservices_arch_28.png', 240),
                                                                                  (28, 3, 'video_clip', 'https://imgur.com/clipsync/docker_swarm_28.mp4', 290),
                                                                                  (29, 2, 'video_clip', 'https://imgur.com/clipsync/redis_benchmark_29.mp4', 160),
                                                                                  (30, 3, 'image', 'https://imgur.com/clipsync/postman_400ms_30.png', 170),
                                                                                  (30, 3, 'image', 'https://imgur.com/clipsync/postman_5ms_30.png', 175),
                                                                                  (31, 2, 'image', 'https://imgur.com/clipsync/gh_actions_yaml_31.png', 205),
                                                                                  (32, 3, 'image', 'https://imgur.com/clipsync/ci_pipeline_green_32.png', 330),
                                                                                  (33, 2, 'image', 'https://imgur.com/clipsync/ws_frames_33.png', 100),
                                                                                  (34, 3, 'video_clip', 'https://imgur.com/clipsync/live_chat_demo_34.mp4', 250),
                                                                                  (34, 3, 'image', 'https://imgur.com/clipsync/chat_ui_34.png', 260);
