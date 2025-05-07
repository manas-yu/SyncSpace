const meetingHelper = require('./utils/meeting-helper');
const { MeetingPayloadEnum } = require('./utils/meeting-payload.enum');

function parseMessage(message) {
    try {
        return JSON.parse(message);
    } catch (error) {
        return { type: MeetingPayloadEnum.UNKNOWN };
    }
}

function listenMessage(socket, meetingServer) {
    const meetingId = socket.handshake.query.id;
    socket.on("message", (message) => handleMessage(meetingId, socket, meetingServer, message));
}

function handleMessage(meetingId, socket, meetingServer, message) {
    var payload = ""
    if (typeof message === "string") {
        payload = parseMessage(message);
    } else {
        payload = message;
    }
    switch (payload.type) {
        case MeetingPayloadEnum.JOINED_MEETING:
            meetingHelper.joinMeeting(meetingId, socket, payload, meetingServer);
            break;
        case MeetingPayloadEnum.CONNECTION_REQUEST:
            meetingHelper.forwardConnectionRequest(meetingId, meetingServer, socket, payload);
            break;
        case MeetingPayloadEnum.OFFER_SDP:
            meetingHelper.forwardOfferSdp(meetingId, meetingServer, socket, payload);
            break;
        case MeetingPayloadEnum.ANSWER_SDP:
            meetingHelper.forwardAnswerSdp(meetingId, meetingServer, socket, payload);
            break;
        case MeetingPayloadEnum.LEAVE_MEETING:
            meetingHelper.userLeft(meetingId, meetingServer, socket, payload);
            break;
        case MeetingPayloadEnum.END_MEETING:
            meetingHelper.endMeeting(meetingId, meetingServer, socket, payload);
            break;
        case MeetingPayloadEnum.VIDEO_TOGGLE:
        case MeetingPayloadEnum.AUDIO_TOGGLE:
            meetingHelper.forwardEvent(meetingId, meetingServer, socket, payload);
            break;
        case MeetingPayloadEnum.UNKNOWN:
        default:
            console.log("Unknown message type", payload.type);
            break;
    }
}

module.exports = {
    listenMessage
};