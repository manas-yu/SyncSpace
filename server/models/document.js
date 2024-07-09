const mongoose = require('mongoose');

const documentSchema = new mongoose.Schema(
    {
        title: {
            type: String,
            required: true,
            trim: true
        },
        content: {
            type: Array,
            default: []
        },
        uid: {
            type: String,
            required: true
        },
        createdAt: {
            type: Number,
            required: true
        },
        sharedWith: {
            type: Array,
            default: []
        }
    }
)


const Document = mongoose.model('Document', documentSchema);
module.exports = Document;