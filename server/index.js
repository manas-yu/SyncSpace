const express = require('express');
const cors = require('cors');
const app = express();
const port = process.env.PORT || 3001;
const mongoose = require('mongoose');
const authRouter = require('./routes/auth');

const DB = "mongodb+srv://manas:1195@cluster0.rqzcak8.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"
app.use(cors());
app.use(express.json())
app.use(authRouter)

mongoose.connect(DB).then(() => {
    console.log("Connection to DB successful");
}).catch((err) => console.log(err));
app.listen(port, "0.0.0.0", () => {
    console.log(`Server is running on port ${port}`);
    console.log(`http://localhost:${port}`);
});