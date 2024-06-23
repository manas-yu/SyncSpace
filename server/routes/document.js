const express = require('express');
const documentRouter = express.Router();
const Document = require('../models/document');
const auth = require('../middleware/auth');
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
module.exports = documentRouter;