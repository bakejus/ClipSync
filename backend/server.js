require('dotenv').config({ path: '../.env' });
const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const swaggerUi = require('swagger-ui-express');
const YAML = require('yamljs');
const swaggerDocument = YAML.load('./openapi.yaml');

const app = express();
app.use(cors());
app.use(express.json());
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));

const pool = new Pool({
    user: process.env.POSTGRES_USER || 'postgres',
    host: 'localhost',
    database: process.env.POSTGRES_DB || 'clipsync',
    password: process.env.POSTGRES_PASSWORD || 'postgres',
    port: process.env.POSTGRES_PORT || 5432,
});

// JWT raktai
const ACCESS_TOKEN_SECRET = process.env.ACCESS_TOKEN_SECRET;
const REFRESH_TOKEN_SECRET = process.env.REFRESH_TOKEN_SECRET;
const ACCESS_TOKEN_EXPIRES_IN = '15m';
const REFRESH_TOKEN_EXPIRES_IN = '7d';

const isValidId = (id) => !isNaN(parseInt(id, 10)) && parseInt(id, 10) > 0;

(async () => {
    try {
        const defaultHash = await bcrypt.hash('slaptazodis123', 10);
        await pool.query('UPDATE users SET password_hash = $1 WHERE id IN (1, 2, 3)', [defaultHash]);
    } catch (err) {
        console.error('Seed slaptažodžių iniciavimo pastaba:', err.message);
    }
})();

// ==========================================
// JWT funkcijos
// ==========================================

const generateAccessToken = (user) => {
    // Zetonas - ID, username ir role
    return jwt.sign(
        { id: user.id, username: user.username, role: user.role },
        ACCESS_TOKEN_SECRET,
        { expiresIn: ACCESS_TOKEN_EXPIRES_IN }
    );
};

const generateRefreshToken = (user) => {
    return jwt.sign(
        { id: user.id, username: user.username, role: user.role },
        REFRESH_TOKEN_SECRET,
        { expiresIn: REFRESH_TOKEN_EXPIRES_IN }
    );
};

// Middleware: tikrina ar prisijunges
const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
        return res.status(401).json({ error: 'Prieiga uždrausta: trūksta autentifikacijos žetono (401 Unauthorized)' });
    }

    jwt.verify(token, ACCESS_TOKEN_SECRET, (err, decodedUser) => {
        if (err) {
            return res.status(401).json({ error: 'Neteisingas arba pasibaigęs žetonas (401 Unauthorized)' });
        }
        req.user = decodedUser;
        next();
    });
};

const authorizeRoles = (...allowedRoles) => {
    return (req, res, next) => {
        if (!req.user || !allowedRoles.includes(req.user.role)) {
            return res.status(403).json({ error: 'Nepakanka teisių šiam veiksmui atlikti (403 Forbidden)' });
        }
        next();
    };
};

// ==========================================
// Hypermedia funkc
// ==========================================
const getBaseUrl = (req) => `${req.protocol}://${req.get('host')}`;

const formatVideo = (video, req) => {
    const base = getBaseUrl(req);
    return {
        ...video,
        _links: {
            self: { href: `${base}/api/videos/${video.id}`, method: 'GET' },
            dashboard: { href: `${base}/api/videos/${video.id}/dashboard`, method: 'GET' },
            update: { href: `${base}/api/videos/${video.id}`, method: 'PUT' },
            delete: { href: `${base}/api/videos/${video.id}`, method: 'DELETE' },
            comments: { href: `${base}/api/videos/${video.id}/comments`, method: 'GET' },
            collection: { href: `${base}/api/videos`, method: 'GET' }
        }
    };
};

const formatComment = (comment, req) => {
    const base = getBaseUrl(req);
    return {
        ...comment,
        _links: {
            self: { href: `${base}/api/comments/${comment.id}`, method: 'GET' },
            video: { href: `${base}/api/videos/${comment.video_id}`, method: 'GET' },
            clips: { href: `${base}/api/comments/${comment.id}/clips`, method: 'GET' }
        }
    };
};

const formatClip = (clip, req) => {
    const base = getBaseUrl(req);
    return {
        ...clip,
        _links: {
            self: { href: `${base}/api/clips/${clip.id}`, method: 'GET' },
            comment: { href: `${base}/api/comments/${clip.comment_id}`, method: 'GET' }
        }
    };
};

// ==========================================
// Autentifikacija ir autorizacija
// ==========================================

// register
app.post('/api/auth/register', async (req, res) => {
    const { username, email, password, role } = req.body;
    if (!username || !email || !password) {
        return res.status(422).json({ error: 'Privalomi laukai: username, email ir password' });
    }

    const assignedRole = role && ['member', 'admin'].includes(role) ? role : 'member';

    try {
        const existingUser = await pool.query(
            'SELECT id FROM users WHERE username = $1 OR email = $2',
            [username, email]
        );
        if (existingUser.rows.length > 0) {
            return res.status(409).json({ error: 'Naudotojas su tokiu vardu arba el. paštu jau egzistuoja' });
        }

        const passwordHash = await bcrypt.hash(password, 10);
        const result = await pool.query(
            'INSERT INTO users (username, email, password_hash, role) VALUES ($1, $2, $3, $4) RETURNING id, username, email, role, created_at',
            [username, email, passwordHash, assignedRole]
        );

        res.status(201).json({
            message: 'Naudotojas sėkmingai užregistruotas',
            user: result.rows[0]
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// prisijungimas
app.post('/api/auth/login', async (req, res) => {
    const { username, password } = req.body;
    if (!username || !password) {
        return res.status(422).json({ error: 'Privalomi laukai: username ir password' });
    }

    try {
        const result = await pool.query('SELECT * FROM users WHERE username = $1', [username]);
        if (result.rows.length === 0) {
            return res.status(401).json({ error: 'Neteisingas prisijungimo vardas arba slaptažodis' });
        }

        const user = result.rows[0];
        const validPassword = await bcrypt.compare(password, user.password_hash);
        if (!validPassword) {
            return res.status(401).json({ error: 'Neteisingas prisijungimo vardas arba slaptažodis' });
        }

        const accessToken = generateAccessToken(user);
        const refreshToken = generateRefreshToken(user);

        await pool.query('UPDATE users SET refresh_token = $1 WHERE id = $2', [refreshToken, user.id]);

        res.status(200).json({
            message: 'Sėkmingai prisijungta',
            accessToken,
            refreshToken,
            user: {
                id: user.id,
                username: user.username,
                email: user.email,
                role: user.role
            }
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// zetono atnaujinimas
app.post('/api/auth/refresh', async (req, res) => {
    const { refreshToken } = req.body;
    if (!refreshToken) {
        return res.status(401).json({ error: 'Trūksta refreshToken parametro' });
    }

    try {
        const result = await pool.query('SELECT * FROM users WHERE refresh_token = $1', [refreshToken]);
        if (result.rows.length === 0) {
            return res.status(403).json({ error: 'Refresh žetonas nebegalioja arba nerastas (403 Forbidden)' });
        }

        const user = result.rows[0];

        jwt.verify(refreshToken, REFRESH_TOKEN_SECRET, (err) => {
            if (err) {
                return res.status(403).json({ error: 'Refresh žetono galiojimo laikas pasibaigęs' });
            }
            const newAccessToken = generateAccessToken(user);
            res.status(200).json({
                accessToken: newAccessToken
            });
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// atsijungimas
app.post('/api/auth/logout', authenticateToken, async (req, res) => {
    try {
        await pool.query('UPDATE users SET refresh_token = NULL WHERE id = $1', [req.user.id]);
        res.status(200).json({ message: 'Sėkmingai atsijungta, žetonai panaikinti' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// tik admin sarasas
app.get('/api/users', authenticateToken, authorizeRoles('admin'), async (req, res) => {
    try {
        const result = await pool.query('SELECT id, username, email, role, created_at FROM users ORDER BY id ASC');
        res.status(200).json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ==========================================
// Video CRUD + Puslapiavimas + Dashboard
// ==========================================

app.get('/api/videos', async (req, res) => {
    const page = parseInt(req.query.page, 10) || 1;
    const limit = parseInt(req.query.limit, 10) || 10;

    if (page < 1 || limit < 1) {
        return res.status(400).json({ error: 'Puslapis (page) ir limitas (limit) turi buti teigiami skaiciai' });
    }

    const offset = (page - 1) * limit;

    try {
        const result = await pool.query(
            'SELECT * FROM videos ORDER BY id ASC LIMIT $1 OFFSET $2',
            [limit, offset]
        );
        res.status(200).json(result.rows.map(v => formatVideo(v, req)));
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.get('/api/videos/:id', async (req, res) => {
    if (!isValidId(req.params.id)) return res.status(400).json({ error: 'Neteisingas ID formatas' });
    try {
        const result = await pool.query('SELECT * FROM videos WHERE id = $1', [req.params.id]);
        if (result.rows.length === 0) return res.status(404).json({ error: 'Vaizdo irasas nerastas' });
        res.status(200).json(formatVideo(result.rows[0], req));
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.post('/api/videos', authenticateToken, authorizeRoles('member', 'admin'), async (req, res) => {
    const { title, description, url } = req.body;
    if (!title || !url) {
        return res.status(422).json({ error: 'Truksta privalomu lauku: title ir url' });
    }
    try {
        const result = await pool.query(
            'INSERT INTO videos (user_id, title, description, url) VALUES ($1, $2, $3, $4) RETURNING *',
            [req.user.id, title, description || '', url]
        );
        res.status(201).json(formatVideo(result.rows[0], req));
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.put('/api/videos/:id', authenticateToken, authorizeRoles('member', 'admin'), async (req, res) => {
    if (!isValidId(req.params.id)) return res.status(400).json({ error: 'Neteisingas ID formatas' });
    const { title, description, url } = req.body;
    if (!title || !url) {
        return res.status(422).json({ error: 'Truksta privalomu lauku: title ir url' });
    }
    try {
        const existing = await pool.query('SELECT * FROM videos WHERE id = $1', [req.params.id]);
        if (existing.rows.length === 0) return res.status(404).json({ error: 'Vaizdo irasas nerastas' });

        // Autorizacija pagal ID ir rolę: Member negali redaguoti kito naudotojo video
        if (req.user.role !== 'admin' && existing.rows[0].user_id !== req.user.id) {
            return res.status(403).json({ error: 'Neturite teisių redaguoti kito naudotojo vaizdo įrašo (403 Forbidden)' });
        }

        const result = await pool.query(
            'UPDATE videos SET title = $1, description = $2, url = $3 WHERE id = $4 RETURNING *',
            [title, description || '', url, req.params.id]
        );
        res.status(200).json(formatVideo(result.rows[0], req));
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.delete('/api/videos/:id', authenticateToken, authorizeRoles('member', 'admin'), async (req, res) => {
    if (!isValidId(req.params.id)) return res.status(400).json({ error: 'Neteisingas ID formatas' });
    try {
        const existing = await pool.query('SELECT * FROM videos WHERE id = $1', [req.params.id]);
        if (existing.rows.length === 0) return res.status(404).json({ error: 'Vaizdo irasas nerastas' });

        if (req.user.role !== 'admin' && existing.rows[0].user_id !== req.user.id) {
            return res.status(403).json({ error: 'Neturite teisių ištrinti kito naudotojo vaizdo įrašo (403 Forbidden)' });
        }

        await pool.query('DELETE FROM videos WHERE id = $1', [req.params.id]);
        res.status(204).send();
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// dashboard
app.get('/api/videos/:id/dashboard', async (req, res) => {
    if (!isValidId(req.params.id)) return res.status(400).json({ error: 'Neteisingas ID formatas' });

    try {
        const videoResult = await pool.query('SELECT * FROM videos WHERE id = $1', [req.params.id]);
        if (videoResult.rows.length === 0) {
            return res.status(404).json({ error: 'Vaizdo įrašas nerastas (404 Not Found)' });
        }
        const video = videoResult.rows[0];

        const commentsResult = await pool.query('SELECT * FROM comments WHERE video_id = $1 ORDER BY id ASC', [video.id]);
        const comments = commentsResult.rows;

        let allClips = [];
        if (comments.length > 0) {
            const commentIds = comments.map(c => c.id);
            const clipsResult = await pool.query(
                'SELECT * FROM clips WHERE comment_id = ANY($1::int[]) ORDER BY id ASC',
                [commentIds]
            );
            allClips = clipsResult.rows;
        }

        const dashboardObject = {
            video: {
                id: video.id,
                user_id: video.user_id,
                title: video.title,
                description: video.description,
                url: video.url,
                created_at: video.created_at
            },
            comments_summary: {
                total_count: comments.length,
                items: comments
            },
            clips_summary: {
                total_count: allClips.length,
                items: allClips
            },
            _links: {
                self: { href: `${getBaseUrl(req)}/api/videos/${video.id}/dashboard`, method: 'GET' },
                video_details: { href: `${getBaseUrl(req)}/api/videos/${video.id}`, method: 'GET' },
                collection: { href: `${getBaseUrl(req)}/api/videos`, method: 'GET' }
            }
        };

        res.status(200).json(dashboardObject);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});


app.get('/api/videos/:videoId/comments', async (req, res) => {
    if (!isValidId(req.params.videoId)) return res.status(400).json({ error: 'Neteisingas videoId formatas' });
    try {
        const videoCheck = await pool.query('SELECT id FROM videos WHERE id = $1', [req.params.videoId]);
        if (videoCheck.rows.length === 0) return res.status(404).json({ error: 'Vaizdo irasas nerastas' });

        const result = await pool.query('SELECT * FROM comments WHERE video_id = $1 ORDER BY id ASC', [req.params.videoId]);
        res.status(200).json(result.rows.map(c => formatComment(c, req)));
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.get('/api/comments/:id', async (req, res) => {
    if (!isValidId(req.params.id)) return res.status(400).json({ error: 'Neteisingas ID formatas' });
    try {
        const result = await pool.query('SELECT * FROM comments WHERE id = $1', [req.params.id]);
        if (result.rows.length === 0) return res.status(404).json({ error: 'Komentaras nerastas' });
        res.status(200).json(formatComment(result.rows[0], req));
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.post('/api/videos/:videoId/comments', authenticateToken, authorizeRoles('member', 'admin'), async (req, res) => {
    if (!isValidId(req.params.videoId)) return res.status(400).json({ error: 'Neteisingas videoId formatas' });
    const { content } = req.body;
    const author = req.body.author || req.user.username;

    if (!content) {
        return res.status(422).json({ error: 'Truksta privalomo lauko: content' });
    }
    try {
        const videoCheck = await pool.query('SELECT id FROM videos WHERE id = $1', [req.params.videoId]);
        if (videoCheck.rows.length === 0) return res.status(404).json({ error: 'Vaizdo irasas nerastas' });

        const result = await pool.query(
            'INSERT INTO comments (video_id, user_id, author, content) VALUES ($1, $2, $3, $4) RETURNING *',
            [req.params.videoId, req.user.id, author, content]
        );
        res.status(201).json(formatComment(result.rows[0], req));
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.put('/api/comments/:id', authenticateToken, authorizeRoles('member', 'admin'), async (req, res) => {
    if (!isValidId(req.params.id)) return res.status(400).json({ error: 'Neteisingas ID formatas' });
    const { content } = req.body;
    const author = req.body.author || req.user.username;

    if (!content) {
        return res.status(422).json({ error: 'Truksta privalomo lauko: content' });
    }
    try {
        const existing = await pool.query('SELECT * FROM comments WHERE id = $1', [req.params.id]);
        if (existing.rows.length === 0) return res.status(404).json({ error: 'Komentaras nerastas' });

        // Paprastas naudotojas negali redaguoti kito naudotojo komentaro
        if (req.user.role !== 'admin' && existing.rows[0].user_id !== req.user.id) {
            return res.status(403).json({ error: 'Neturite teisių redaguoti kito naudotojo komentaro (403 Forbidden)' });
        }

        const result = await pool.query(
            'UPDATE comments SET author = $1, content = $2 WHERE id = $3 RETURNING *',
            [author, content, req.params.id]
        );
        res.status(200).json(formatComment(result.rows[0], req));
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.delete('/api/comments/:id', authenticateToken, authorizeRoles('member', 'admin'), async (req, res) => {
    if (!isValidId(req.params.id)) return res.status(400).json({ error: 'Neteisingas ID formatas' });
    try {
        const existing = await pool.query('SELECT * FROM comments WHERE id = $1', [req.params.id]);
        if (existing.rows.length === 0) return res.status(404).json({ error: 'Komentaras nerastas' });

        if (req.user.role !== 'admin' && existing.rows[0].user_id !== req.user.id) {
            return res.status(403).json({ error: 'Neturite teisių ištrinti kito naudotojo komentaro (403 Forbidden)' });
        }

        await pool.query('DELETE FROM comments WHERE id = $1', [req.params.id]);
        res.status(204).send();
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ==========================================
// Klipai CRUD + Filtravimas
// ==========================================

app.get('/api/comments/:commentId/clips', async (req, res) => {
    if (!isValidId(req.params.commentId)) return res.status(400).json({ error: 'Neteisingas commentId formatas' });

    const { media_type } = req.query;

    if (media_type && !['image', 'video_clip'].includes(media_type)) {
        return res.status(400).json({ error: 'Neteisingas media_type filtras. Galimos reiksmes: image, video_clip' });
    }

    try {
        const commentCheck = await pool.query('SELECT id FROM comments WHERE id = $1', [req.params.commentId]);
        if (commentCheck.rows.length === 0) return res.status(404).json({ error: 'Komentaras nerastas' });

        let query = 'SELECT * FROM clips WHERE comment_id = $1';
        const params = [req.params.commentId];

        if (media_type) {
            params.push(media_type);
            query += ` AND media_type = $2`;
        }

        query += ' ORDER BY id ASC';

        const result = await pool.query(query, params);
        res.status(200).json(result.rows.map(cl => formatClip(cl, req)));
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.get('/api/clips/:id', async (req, res) => {
    if (!isValidId(req.params.id)) return res.status(400).json({ error: 'Neteisingas ID formatas' });
    try {
        const result = await pool.query('SELECT * FROM clips WHERE id = $1', [req.params.id]);
        if (result.rows.length === 0) return res.status(404).json({ error: 'Klipas nerastas' });
        res.status(200).json(formatClip(result.rows[0], req));
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.post('/api/comments/:commentId/clips', authenticateToken, authorizeRoles('member', 'admin'), async (req, res) => {
    if (!isValidId(req.params.commentId)) return res.status(400).json({ error: 'Neteisingas commentId formatas' });
    const { media_type, media_url, timestamp_sec } = req.body;
    if (!media_type || !media_url || !['image', 'video_clip'].includes(media_type)) {
        return res.status(422).json({ error: 'Privalomi: media_url ir media_type (image arba video_clip)' });
    }
    try {
        const commentCheck = await pool.query('SELECT id FROM comments WHERE id = $1', [req.params.commentId]);
        if (commentCheck.rows.length === 0) return res.status(404).json({ error: 'Komentaras nerastas' });

        const result = await pool.query(
            'INSERT INTO clips (comment_id, user_id, media_type, media_url, timestamp_sec) VALUES ($1, $2, $3, $4, $5) RETURNING *',
            [req.params.commentId, req.user.id, media_type, media_url, timestamp_sec || 0]
        );
        res.status(201).json(formatClip(result.rows[0], req));
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.put('/api/clips/:id', authenticateToken, authorizeRoles('member', 'admin'), async (req, res) => {
    if (!isValidId(req.params.id)) return res.status(400).json({ error: 'Neteisingas ID formatas' });
    const { media_type, media_url, timestamp_sec } = req.body;
    if (!media_type || !media_url || !['image', 'video_clip'].includes(media_type)) {
        return res.status(422).json({ error: 'Privalomi: media_url ir media_type (image arba video_clip)' });
    }
    try {
        const existing = await pool.query('SELECT * FROM clips WHERE id = $1', [req.params.id]);
        if (existing.rows.length === 0) return res.status(404).json({ error: 'Klipas nerastas' });

        if (req.user.role !== 'admin' && existing.rows[0].user_id !== req.user.id) {
            return res.status(403).json({ error: 'Neturite teisių redaguoti kito naudotojo klipo (403 Forbidden)' });
        }

        const result = await pool.query(
            'UPDATE clips SET media_type = $1, media_url = $2, timestamp_sec = $3 WHERE id = $4 RETURNING *',
            [media_type, media_url, timestamp_sec || 0, req.params.id]
        );
        res.status(200).json(formatClip(result.rows[0], req));
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.delete('/api/clips/:id', authenticateToken, authorizeRoles('member', 'admin'), async (req, res) => {
    if (!isValidId(req.params.id)) return res.status(400).json({ error: 'Neteisingas ID formatas' });
    try {
        const existing = await pool.query('SELECT * FROM clips WHERE id = $1', [req.params.id]);
        if (existing.rows.length === 0) return res.status(404).json({ error: 'Klipas nerastas' });

        if (req.user.role !== 'admin' && existing.rows[0].user_id !== req.user.id) {
            return res.status(403).json({ error: 'Neturite teisių ištrinti kito naudotojo klipo (403 Forbidden)' });
        }

        await pool.query('DELETE FROM clips WHERE id = $1', [req.params.id]);
        res.status(204).send();
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Serveris sekmingai paleistas: http://localhost:${PORT}/api/videos`);
});
