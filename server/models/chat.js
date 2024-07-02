const mongoose = require('mongoose');


const chatSchema = new mongoose.Schema(
    {
        roomId: {
            type: String,
            required: true
        },
        uid: {
            type: String,
            required: true
        },
        content: {
            type: String,
            required: true,
            trim: true
        },
        createdAt: {
            type: Number,
            required: true
        },
        username: {
            type: String,
            required: true
        },
        profilePic: {
            type: String,
            required: true
        }
    }
)

const Chat = mongoose.model('Chat', chatSchema);
module.exports = Chat;