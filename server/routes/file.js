const express = require('express');
const fileRouter = express.Router();
const File = require('../models/file');
const auth = require('../middleware/auth');

const fs = require('fs');
const path = require('path');
const multer = require('multer');

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, 'uploads/')
    },
    filename: function (req, file, cb) {
        cb(null, Date.now() + '-' + file.originalname)
    }
});

const upload = multer({ storage: storage });

fileRouter.post('/file/upload', auth, upload.single('file'), async (req, res) => {
    try {
        if (!fs.existsSync('uploads')) {
            fs.mkdirSync('uploads');
        }

        const { createdAt, roomId } = req.body;
        let file = new File({
            uid: req.user,
            createdAt,
            roomId,
            filename: req.file.filename,
            originalname: req.file.originalname,
            mimetype: req.file.mimetype,
            size: req.file.size,
            path: req.file.path
        });

        file = await file.save()
        res.json(file);


    } catch (e) {
        res.status(500).json({ error: e.message })
    }

});


fileRouter.get('/file/download/:filename', async (req, res) => {
    const filename = req.params.filename;

    try {
        const file = await File.findOne({ filename: filename }).exec();
        if (!file) {
            return res.status(404).send('File not found');
        }

        res.download(file.path, file.originalname);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

fileRouter.get('/file/:roomId', async (req, res) => {
    try {
        const files = await File.find({ roomId: req.params.roomId });
        res.json(files);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});
module.exports = fileRouter;