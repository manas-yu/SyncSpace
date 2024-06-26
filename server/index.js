const express = require('express');
const cors = require('cors');
const app = express();
const port = process.env.PORT || 3001;
const mongoose = require('mongoose');
const authRouter = require('./routes/auth');
const documentRouter = require('./routes/document');
const http = require('http');
var server = http.createServer(app);
var io = require('socket.io')(server);
const DB = "mongodb+srv://manas:1195@cluster0.rqzcak8.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"
app.use(cors());
app.use(express.json())
app.use(authRouter)
app.use(documentRouter)
mongoose.connect(DB).then(() => {
    console.log("Connection to DB successful");
}).catch((err) => console.log(err));
io.on('connection', (socket) => {
    console.log('a user connected : ' + socket.id);
    socket.on('join', (documentId) => {
        socket.join(documentId);
        console.log('a user joined room: ' + documentId);
    });
});
server.listen(port, "0.0.0.0", () => {
    console.log(`Server is running on port ${port}`);
    console.log(`http://localhost:${port}`);
});