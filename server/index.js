const express = require('express');
const app = express();
const port = process.env.PORT | 3001;
const mongoose = require('mongoose');


app.listen(port, "0.0.0.0", () => {
    console.log(`Server is running on port ${port}`);
    console.log(`http://localhost:${port}`);
});