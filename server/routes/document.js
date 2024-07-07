const express = require('express');
const documentRouter = express.Router();
const Document = require('../models/document');
const File = require('../models/file');
const Chat = require('../models/chat');
const auth = require('../middleware/auth');
const fs = require('fs').promises;
const path = require('path');

documentRouter.post(
    '/doc/create',
    auth,
    async (req, res) => {
        try {
            const { createdAt } = req.body;
            let document = new Document(
                {
                    createdAt,
                    uid: req.user,
                    title: 'Untitled Document',
                }
            );
            document = await document.save();
            res.json(document);
        } catch (e) {
            res.status(500).json({ error: e.message })
        }
    }
)
documentRouter.get(
    '/doc/me',
    auth,
    async (req, res) => {
        try {
            const documents = await Document.find({ uid: req.user });
            res.json(documents);
        } catch (e) {
            res.status(500).json({ error: e.message });
        }
    }
)
documentRouter.post(
    '/doc/title',
    auth,
    async (req, res) => {
        try {
            const { id, title } = req.body;
            const document = await Document.findByIdAndUpdate(id, { title });
            res.json(document);
        } catch (e) {
            res.status(500).json({ error: e.message })
        }
    }
)
documentRouter.get(
    '/doc/:id',
    auth,
    async (req, res) => {
        try {
            const documents = await Document.findById(req.params.id);
            res.json(documents);
        } catch (e) {
            res.status(500).json({ error: e.message });
        }
    }
);
documentRouter.delete('/doc/:id', auth, async (req, res) => {
    const roomId = req.params.id;
    try {
        const document = await Document.findByIdAndDelete(roomId);
        if (!document) {
            return res.status(404).json({ error: "Document not found" });
        }
        const fileDocs = await File.find({ roomId: roomId });
        if (fileDocs.length > 0) {
            const fileNames = fileDocs.filter(doc => doc.filename).map(doc => doc.filename);

            const uploadsDir = path.join(__dirname, '..', 'uploads');
            await Promise.all(fileNames.map(fileName => {
                const filePath = path.join(uploadsDir, fileName);

                return fs.unlink(filePath);

            }));
        }
        const deleteFiles = File.deleteMany({ roomId: roomId });
        const deleteChats = Chat.deleteMany({ roomId: roomId });
        await Promise.all([deleteFiles, deleteChats]);

        res.json({ message: "Document, associated files, and chats deleted successfully" });
    } catch (e) {
        console.log(e);
        res.status(500).json({ error: e.message });
    }
});
module.exports = documentRouter;