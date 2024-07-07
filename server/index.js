require('dotenv').config();
const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const http = require("http");
const authRouter = require("./routes/auth");
const documentRouter = require("./routes/document");
const fileRouter = require("./routes/file");
const chatRouter = require("./routes/chat");
const Document = require("./models/document");
const app = express();
var server = http.createServer(app);
var io = require("socket.io")(server);

app.use(cors());
app.use(express.json());
app.use(authRouter);
app.use(documentRouter);
app.use(fileRouter);
app.use(chatRouter);
mongoose
  .connect(process.env.DB)
  .then(() => {
    console.log("Connection successful!");
  })
  .catch((err) => {
    console.log(err);
  });

io.on("connection", (socket) => {
  console.log("A user has connected");
  socket.on("join", (documentId) => {
    console.log("A user has joined the document");
    socket.join(documentId);
  });

  socket.on("typing", (data) => {
    socket.broadcast.to(data.room).emit("changes", data);
  });

  socket.on("autosave", (data) => {
    saveData(data);
  });
  socket.on('send-message', (data) => {
    io.to(data.room).emit('receive-message', data);
  });
  socket.on('share-file', (data) => {
    io.to(data.room).emit('receive-file', data);
  })

  socket.on('delete-file', (data) => {
    console.log(data);
    io.to(data.room).emit('file-deleted', data);
  })

});

const saveData = async (data) => {
  let document = await Document.findById(data.room);
  if (document != null) {
    document.content = data.delta;
    document = await document.save();
  }
};

server.listen(process.env.port, "0.0.0.0", () => {
  console.log(`connected at port ${process.env.port}`);
});
