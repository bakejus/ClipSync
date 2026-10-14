-- Vaizdo irasu lentele
CREATE TABLE videos (
                        id SERIAL PRIMARY KEY,
                        title VARCHAR(255) NOT NULL,
                        description TEXT,
                        url VARCHAR(500) NOT NULL,
                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Komentaru lentele (Priklauso Video -> ON DELETE CASCADE)
CREATE TABLE comments (
                          id SERIAL PRIMARY KEY,
                          video_id INTEGER NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
                          author VARCHAR(100) NOT NULL,
                          content TEXT NOT NULL,
                          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Klipu lentele (priklauso comments)
CREATE TABLE clips (
                       id SERIAL PRIMARY KEY,
                       comment_id INTEGER NOT NULL REFERENCES comments(id) ON DELETE CASCADE,
                       media_type VARCHAR(50) NOT NULL CHECK (media_type IN ('image', 'video_clip')),
                       media_url VARCHAR(500) NOT NULL,
                       timestamp_sec INTEGER DEFAULT 0,
                       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Prad duomenys
INSERT INTO videos (title, description, url) VALUES
                                                 ('Kaip sukurti REST API per 10 min', 'Mokomasis video apie Express ir Node.js', 'https://youtube.com/watch?v=12345'),
                                                 ('Docker pamoka pradedantiesiems', 'Kaip konteinerizuoti PostgreSQL duomenų bazę', 'https://youtube.com/watch?v=67890');

INSERT INTO comments (video_id, author, content) VALUES
                                                     (1, 'Tomas_KTU', 'Puikus video, bet 3 minutėje yra klaida kode! Pridedu ekrano nuotrauką.'),
                                                     (1, 'Jonas_Dev', 'Viskas veikia, štai mano rezultato klipas.'),
                                                     (2, 'Aistė', 'Labai aiškiai paaiškinta apie Docker Compose.');

INSERT INTO clips (comment_id, media_type, media_url, timestamp_sec) VALUES
                                                                         (1, 'image', 'https://imgur.com/example-error-screenshot.png', 180),
                                                                         (2, 'video_clip', 'https://imgur.com/example-working-demo.mp4', 45),
                                                                         (3, 'image', 'https://imgur.com/docker-diagram.png', 120);
