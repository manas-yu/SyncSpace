const jwt = require('jsonwebtoken');

const auth = async (req, res, next) => {
    try {
        const token = req.header('x-auth-token');
        if (token == null) {
            return res.status(401).send({ error: 'No auth Token ' });
        }
        const verified = jwt.verify(token, 'passwordKey');
        if (!verified) {
            return res.status(401).send({ error: 'Token verification failed, authorization denied' });
        }
        req.user = verified.id;
        req.token = token;
        next();
    } catch (e) {
        res.status(401).send({ error: 'Please authenticate' });
    }
}
module.exports = auth;