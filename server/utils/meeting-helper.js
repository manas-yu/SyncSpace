const meetingServices = require("../services/meeting.service");
const { MeetingPayloadEnum } = require("../utils/meeting-payload.enum");

async function joinMeeting(meetingId, socket, payload, meetingServer) {
    const { userId, name } = payload.data;
    meetingServices.isMeetingPresent(meetingId, async (error, results) => {
        if (error && !results) {
            sendMessage(socket, {
                type: MeetingPayloadEnum.NOT_FOUND,
            });
        }
        if (results) {
            addUser(socket, { meetingId, userId, name }).then((result) => {
                if (result) {
                    sendMessage(socket, {
                        type: MeetingPayloadEnum.JOINED_MEETING, data: {
                            userId
                        }
                    });
                    broadCastUsers(meetingId, socket, meetingServer, {
                        type: MeetingPayloadEnum.USER_JOINED,
                        data: {
                            userId,
                            name,
                            ...payload.data
                        }
                    });
                }
            }, (error) => { console.log(error) });
        }
    });
}
function forwardConnectionRequest(meetingId, meetingServer, socket, payload) {
    const { userId, otherUserId, name } = payload.data;
    var model = {
        meetingId: meetingId,
        userId: otherUserId,
        name: name,
    }
    meetingServices.getMeetingUser(model, (error, results) => {
        if (results) {
            var sendPayload = JSON.stringify({
                type: MeetingPayloadEnum.CONNECTION_REQUEST,
                data: {
                    userId: userId,
                    name: name,
                    ...payload.data
                }
            });
            meetingServer.to(results.socketId).emit("message", sendPayload);
        } else {

        }
    })
}
function forwardOfferSdp(meetingId, meetingServer, socket, payload) {
    const { userId, otherUserId, sdp } = payload.data;
    var model = {
        meetingId: meetingId,
        userId: otherUserId,
        name: name,
    }
    meetingServices.getMeetingUser(model, (error, results) => {
        if (results) {
            var sendPayload = JSON.stringify({
                type: MeetingPayloadEnum.OFFER_SDP,
                data: {
                    userId: userId,
                    sdp
                }
            });
            meetingServer.to(results.socketId).emit("message", sendPayload);
        } else {

        }
    })
}
function forwardAnswerSdp(meetingId, meetingServer, socket, payload) {
    const { userId, otherUserId, sdp } = payload.data;
    var model = {
        meetingId: meetingId,
        userId: otherUserId,
        name: name,
    }
    meetingServices.getMeetingUser(model, (error, results) => {
        if (results) {
            var sendPayload = JSON.stringify({
                type: MeetingPayloadEnum.ANSWER_SDP,
                data: {
                    userId: userId,
                    sdp
                }
            });
            meetingServer.to(results.socketId).emit("message", sendPayload);
        } else {

        }
    })
}
function userLeft(meetingId, meetingServer, socket, payload) {
    const { userId, otherUserId, sdp } = payload.data;
    broadCastUsers(meetingId, socket, meetingServer, {
        type: MeetingPayloadEnum.USER_LEFT,
        data: {
            userId: userId,
        }
    })
}
function endMeeting(meetingId, meetingServer, socket, payload) {
    const { userId } = payload.data;
    broadCastUsers(meetingId, socket, meetingServer, {
        type: MeetingPayloadEnum.MEETING_ENDED,
        data: {
            userId: userId,
        }
    });
    meetingServices.getAllMeetingUsers(meetingId, (error, results) => {
        for (let i = 0; i < results.length; i++) {
            meetingServer.sockets.connected[results[i].socketId].disconnect();
        }
    })
}
function forwardEvent(meetingId, meetingServer, socket, payload) {
    const { userId } = payload.data;
    broadCastUsers(meetingId, socket, meetingServer, {
        type: payload.type,
        data: {
            userId: userId,
            ...payload.data
        }
    });
}
function forwardIceCandidate(meetingId, meetingServer, socket, payload) {
    const { userId, otherUserId, candidate } = payload.data;
    var model = {
        meetingId: meetingId,
        userId: otherUserId,
        name: name,
    }
    meetingServices.getMeetingUser(model, (error, results) => {
        if (results) {
            var sendPayload = JSON.stringify({
                type: MeetingPayloadEnum.ICECANDIDATE,
                data: {
                    userId: userId,
                    candidate
                }
            });
            meetingServer.to(results.socketId).emit("message", sendPayload);
        } else {

        }
    })
}
function addUser(socket, { meetingId, userId, name }) {
    let promise = new Promise(function (resolve, reject) {
        meetingServices.getMeetingUser({ meetingId, userId }, (error, result) => {
            if (!result) {
                var model = {
                    socketId: socket.id,
                    meetingId: meetingId,
                    userId: userId,
                    name: name,
                    joined: true,
                    isAlive: true,
                };
                meetingServices.joinMeeting(model, (error, result) => {
                    if (error) {
                        reject(error);
                    } else {
                        resolve(true);
                    }
                });
            } else {
                meetingServices.updateMeetingUser({ userId: userId, socketId: socket.id }, (error, result) => {
                    if (error) {
                        reject(error);
                    } else {
                        resolve(true);
                    }
                });
            }
        })
    });
    return promise;
}
function sendMessage(socket, payload) {
    socket.send(JSON.stringify(payload));
}
function broadCastUsers(meetingId, socket, meetingServer, payload) {
    socket.broadcast.emit("message", JSON.stringify(payload));
}


module.exports = {
    joinMeeting,
    forwardConnectionRequest,
    forwardOfferSdp,
    forwardAnswerSdp,
    userLeft,
    endMeeting,
    forwardEvent,
    forwardIceCandidate
};