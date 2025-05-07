const mongoose = require('mongoose');
const { Schema } = mongoose;
const meetingUser = mongoose.model(
    "MeetingUser",
    mongoose.Schema({
        socketId: {
            type: String
        },
        meetingId: {
            type: mongoose.Schema.Types.ObjectId,
            required: "Meeting"
        },
        userId: {
            type: String,
            required: true
        },
        joined: {
            type: Boolean,
            default: false
        },
        name: {
            type: String,
            required: true
        },
        isAlive: {
            type: Boolean,
            default: false
        },
    },
        { timestamps: true }
    )
);

module.exports = { meetingUser };