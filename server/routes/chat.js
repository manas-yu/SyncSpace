const express = require('express');
const chatRouter = express.Router();
const chat = require('../models/chat');
const auth = require('../middleware/auth');

chatRouter.get(
    '/chat/:roomId',
    auth,
    async (req, res) => {
        try {
            const messages = await chat.find({ roomId: req.params.roomId });
            res.json(messages);
        } catch (e) {
            res.status(500).json({ error: e.message });
        }
    }
)
chatRouter.post(
    '/chat/newMessage', auth,
    async (req, res) => {
        try {
            const { roomId, content, createdAt, username, profilePic } = req.body;
            let message = new chat(
                {
                    roomId,
                    uid: req.user,
                    content,
                    createdAt,
                    username,
                    profilePic
                }
            );
            message = await message.save();
            res.json(message);
        } catch (e) {
            res.status(500).json({ error: e.message })
        }
    }
)

module.exports = chatRouter;