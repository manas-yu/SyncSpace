
const mongoose = require('mongoose');

const fileSchema = new mongoose.Schema({
    uid: {
        type: String,
        required: true
    },
    roomId: {
        type: String,
        required: true
    },
    filename: {
        type: String,
        required: true
    },
    originalname: {
        type: String,
        required: true
    },
    mimetype: {
        type: String,
        required: true
    },
    size: {
        type: Number,
        required: true
    },
    path: {
        type: String,
        required: true
    },
    createdAt: {
        type: Number,
        required: true
    }

});

const File = mongoose.model('File', fileSchema);
module.exports = File;