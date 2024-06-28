require('dotenv').config();
const express = require('express');
const cors = require('cors');
const app = express();
const mongoose = require('mongoose');
const authRouter = require('./routes/auth');
const documentRouter = require('./routes/document');
const Document = require('./models/document');
const http = require('http');
var server = http.createServer(app);
var io = require('socket.io')(server);
app.use(cors());
app.use(express.json())
app.use(authRouter)
app.use(documentRouter)
mongoose.connect(process.env.DB).then(() => {
    console.log("Connection to DB successful");
}).catch((err) => console.log(err));
io.on('connection', (socket) => {
    console.log('a user connected : ' + socket.id);
    socket.on('join', (documentId) => {
        socket.join(documentId);
        console.log('a user joined room: ' + documentId);
    });
    socket.on('typing', (data) => {
        socket.broadcast.to(data.room).emit('changes', data);
    });
    socket.on('autosave', (data) => {
        autoSave(data)
    });

});
const autoSave = async (data) => {
    let document = await Document.findById(data.room);
    document.content = data.delta;
    document = await document.save();
};
server.listen(process.env.port, "0.0.0.0", () => {
    console.log(`Server is running on port ${process.env.port}`);
    console.log(`http://localhost:${process.env.port}`);
});