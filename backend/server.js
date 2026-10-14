require('dotenv').config({ path: '../.env' });
const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
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

const isValidId = (id) => !isNaN(parseInt(id, 10)) && parseInt(id, 10) > 0;

// ==========================================
// Video su savo 4 CRUD metodais ir vienu papildomu
// ==========================================

app.get('/api/videos', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM videos ORDER BY id ASC');
        res.status(200).json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.get('/api/videos/:id', async (req, res) => {
    if (!isValidId(req.params.id)) return res.status(400).json({ error: 'Neteisingas ID formatas' });
    try {
        const result = await pool.query('SELECT * FROM videos WHERE id = $1', [req.params.id]);
        if (result.rows.length === 0) return res.status(404).json({ error: 'Vaizdo irasas nerastas' });
        res.status(200).json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.post('/api/videos', async (req, res) => {
    const { title, description, url } = req.body;
    if (!title || !url) {
        return res.status(422).json({ error: 'Truksta privalomu lauku: title ir url' });
    }
    try {
        const result = await pool.query(
            'INSERT INTO videos (title, description, url) VALUES ($1, $2, $3) RETURNING *',
            [title, description || '', url]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.put('/api/videos/:id', async (req, res) => {
    if (!isValidId(req.params.id)) return res.status(400).json({ error: 'Neteisingas ID formatas' });
    const { title, description, url } = req.body;
    if (!title || !url) {
        return res.status(422).json({ error: 'Truksta privalomu lauku: title ir url' });
    }
    try {
        const result = await pool.query(
            'UPDATE videos SET title = $1, description = $2, url = $3 WHERE id = $4 RETURNING *',
            [title, description || '', url, req.params.id]
        );
        if (result.rows.length === 0) return res.status(404).json({ error: 'Vaizdo irasas nerastas' });
        res.status(200).json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.delete('/api/videos/:id', async (req, res) => {
    if (!isValidId(req.params.id)) return res.status(400).json({ error: 'Neteisingas ID formatas' });
    try {
        const result = await pool.query('DELETE FROM videos WHERE id = $1 RETURNING *', [req.params.id]);
        if (result.rows.length === 0) return res.status(404).json({ error: 'Vaizdo irasas nerastas' });
        res.status(204).send();
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ==========================================
// Komentarai CRUD ir + 1 papildomas metodas
// ==========================================

app.get('/api/videos/:videoId/comments', async (req, res) => {
    if (!isValidId(req.params.videoId)) return res.status(400).json({ error: 'Neteisingas videoId formatas' });
    try {
        const videoCheck = await pool.query('SELECT id FROM videos WHERE id = $1', [req.params.videoId]);
        if (videoCheck.rows.length === 0) return res.status(404).json({ error: 'Vaizdo irasas nerastas' });

        const result = await pool.query('SELECT * FROM comments WHERE video_id = $1 ORDER BY id ASC', [req.params.videoId]);
        res.status(200).json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.get('/api/comments/:id', async (req, res) => {
    if (!isValidId(req.params.id)) return res.status(400).json({ error: 'Neteisingas ID formatas' });
    try {
        const result = await pool.query('SELECT * FROM comments WHERE id = $1', [req.params.id]);
        if (result.rows.length === 0) return res.status(404).json({ error: 'Komentaras nerastas' });
        res.status(200).json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.post('/api/videos/:videoId/comments', async (req, res) => {
    if (!isValidId(req.params.videoId)) return res.status(400).json({ error: 'Neteisingas videoId formatas' });
    const { author, content } = req.body;
    if (!author || !content) {
        return res.status(422).json({ error: 'Truksta privalomu lauku: author ir content' });
    }
    try {
        const videoCheck = await pool.query('SELECT id FROM videos WHERE id = $1', [req.params.videoId]);
        if (videoCheck.rows.length === 0) return res.status(404).json({ error: 'Vaizdo irasas nerastas' });

        const result = await pool.query(
            'INSERT INTO comments (video_id, author, content) VALUES ($1, $2, $3) RETURNING *',
            [req.params.videoId, author, content]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.put('/api/comments/:id', async (req, res) => {
    if (!isValidId(req.params.id)) return res.status(400).json({ error: 'Neteisingas ID formatas' });
    const { author, content } = req.body;
    if (!author || !content) {
        return res.status(422).json({ error: 'Truksta privalomu lauku: author ir content' });
    }
    try {
        const result = await pool.query(
            'UPDATE comments SET author = $1, content = $2 WHERE id = $3 RETURNING *',
            [author, content, req.params.id]
        );
        if (result.rows.length === 0) return res.status(404).json({ error: 'Komentaras nerastas' });
        res.status(200).json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.delete('/api/comments/:id', async (req, res) => {
    if (!isValidId(req.params.id)) return res.status(400).json({ error: 'Neteisingas ID formatas' });
    try {
        const result = await pool.query('DELETE FROM comments WHERE id = $1 RETURNING *', [req.params.id]);
        if (result.rows.length === 0) return res.status(404).json({ error: 'Komentaras nerastas' });
        res.status(204).send();
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ==========================================
// Klipai CRUD + 1 papildomas metodas
// ==========================================

app.get('/api/comments/:commentId/clips', async (req, res) => {
    if (!isValidId(req.params.commentId)) return res.status(400).json({ error: 'Neteisingas commentId formatas' });
    try {
        const commentCheck = await pool.query('SELECT id FROM comments WHERE id = $1', [req.params.commentId]);
        if (commentCheck.rows.length === 0) return res.status(404).json({ error: 'Komentaras nerastas' });

        const result = await pool.query('SELECT * FROM clips WHERE comment_id = $1 ORDER BY id ASC', [req.params.commentId]);
        res.status(200).json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.get('/api/clips/:id', async (req, res) => {
    if (!isValidId(req.params.id)) return res.status(400).json({ error: 'Neteisingas ID formatas' });
    try {
        const result = await pool.query('SELECT * FROM clips WHERE id = $1', [req.params.id]);
        if (result.rows.length === 0) return res.status(404).json({ error: 'Klipas nerastas' });
        res.status(200).json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.post('/api/comments/:commentId/clips', async (req, res) => {
    if (!isValidId(req.params.commentId)) return res.status(400).json({ error: 'Neteisingas commentId formatas' });
    const { media_type, media_url, timestamp_sec } = req.body;
    if (!media_type || !media_url || !['image', 'video_clip'].includes(media_type)) {
        return res.status(422).json({ error: 'Privalomi: media_url ir media_type (image arba video_clip)' });
    }
    try {
        const commentCheck = await pool.query('SELECT id FROM comments WHERE id = $1', [req.params.commentId]);
        if (commentCheck.rows.length === 0) return res.status(404).json({ error: 'Komentaras nerastas' });

        const result = await pool.query(
            'INSERT INTO clips (comment_id, media_type, media_url, timestamp_sec) VALUES ($1, $2, $3, $4) RETURNING *',
            [req.params.commentId, media_type, media_url, timestamp_sec || 0]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.put('/api/clips/:id', async (req, res) => {
    if (!isValidId(req.params.id)) return res.status(400).json({ error: 'Neteisingas ID formatas' });
    const { media_type, media_url, timestamp_sec } = req.body;
    if (!media_type || !media_url || !['image', 'video_clip'].includes(media_type)) {
        return res.status(422).json({ error: 'Privalomi: media_url ir media_type (image arba video_clip)' });
    }
    try {
        const result = await pool.query(
            'UPDATE clips SET media_type = $1, media_url = $2, timestamp_sec = $3 WHERE id = $4 RETURNING *',
            [media_type, media_url, timestamp_sec || 0, req.params.id]
        );
        if (result.rows.length === 0) return res.status(404).json({ error: 'Klipas nerastas' });
        res.status(200).json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.delete('/api/clips/:id', async (req, res) => {
    if (!isValidId(req.params.id)) return res.status(400).json({ error: 'Neteisingas ID formatas' });
    try {
        const result = await pool.query('DELETE FROM clips WHERE id = $1 RETURNING *', [req.params.id]);
        if (result.rows.length === 0) return res.status(404).json({ error: 'Klipas nerastas' });
        res.status(204).send();
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Serveris sekmingai paleistas: http://localhost:${PORT}/api/videos`);
});
