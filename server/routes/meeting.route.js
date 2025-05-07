const meetingController = require('../controllers/meeting.controller');
const express = require('express');
const meetingRouter = express.Router();
const auth = require('../middleware/auth');

meetingRouter.post('/meeting/start', auth, meetingController.startMeeting);
meetingRouter.get('/meeting/join', auth, meetingController.checkMeetingExists);
meetingRouter.get('/meeting/get', auth, meetingController.getAllMeetingUsers);

module.exports = meetingRouter;