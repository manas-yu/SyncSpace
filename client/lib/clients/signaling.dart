import 'package:flutter_webrtc/flutter_webrtc.dart';

class PeerService {
  RTCPeerConnection? _peer;

  Future<void> _initializePeer() async {
    if (_peer == null) {
      final configuration = {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
          {'urls': 'stun:global.stun.twilio.com:3478'},
        ],
      };
      _peer = await createPeerConnection(configuration);
    }
  }

  Future<RTCPeerConnection> getOrCreatePeer() async {
    if (_peer == null) {
      final configuration = {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
          {'urls': 'stun:global.stun.twilio.com:3478'},
        ],
      };
      _peer = await createPeerConnection(configuration);
    }
    return _peer!;
  }

  Future<RTCSessionDescription> getAnswer(RTCSessionDescription offer) async {
    await _initializePeer();
    if (_peer != null) {
      await _peer!.setRemoteDescription(offer);
      final RTCSessionDescription answer = await _peer!.createAnswer();
      await _peer!.setLocalDescription(answer);
      return answer;
    }
    throw Exception('Peer connection is not initialized');
  }

  Future<void> setRemoteDescription(RTCSessionDescription answer) async {
    await _initializePeer();
    if (_peer != null) {
      await _peer!.setRemoteDescription(answer);
    } else {
      throw Exception('Peer connection is not initialized');
    }
  }

  Future<RTCSessionDescription> getOffer() async {
    await _initializePeer();
    if (_peer != null) {
      final RTCSessionDescription offer = await _peer!.createOffer();
      await _peer!.setLocalDescription(offer);
      return offer;
    }
    throw Exception('Peer connection is not initialized');
  }
}
