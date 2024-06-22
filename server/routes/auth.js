const express = require('express');
const jwt = require('jsonwebtoken');
const User = require('../models/user');
const auth = require('../middleware/auth');
const authRouter = express.Router();
authRouter.post(
    "/api/signup",
    async (req, res) => {
        try {
            const { name, email, profilePic } = req.body;
            let user = await User.findOne({ email })
            if (!user) {
                user = new User(
                    {
                        name,
                        email,
                        profilePic
                    }
                )
                user = await user.save()
            }
            const token = jwt.sign({ id: user._id }, 'passwordKey')
            res.json({ user, token })
            console.log(user)

        } catch (e) {
            res.status(500).json({ error: e.message });
            console.log(e);
        }

    }
)
authRouter.get(
    '/', auth, async (req, res) => {
        try {
            const user = await User.findById(req.user)
            if (!user) {
                return res.status(401).send({ error: "User not found" })

            }
            res.json({ user, token: req.token })
        } catch (e) {
            res.status(500).json({ error: e.message });
            console.log(e);
        }
    }
)
module.exports = authRouter;