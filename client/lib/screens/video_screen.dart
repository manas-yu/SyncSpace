import 'package:dodoc/clients/signaling.dart';
import 'package:dodoc/repository/socket_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class VideoScreen extends ConsumerStatefulWidget {
  final String roomId;
  const VideoScreen({super.key, required this.roomId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _VideoScreenState();
}

class _VideoScreenState extends ConsumerState<VideoScreen> {
  MediaStream? stream;
  String? remoteSocketId;
  final localVideoRenderer = RTCVideoRenderer();

  final remoteVideoRenderer = RTCVideoRenderer();
  final SocketRepository socketRepository = SocketRepository();
  final peerService = PeerService();
  @override
  void initState() {
    super.initState();
    makeCall();
    setListeners();
  }

  void setListeners() async {
    final peer = await peerService.getOrCreatePeer();
    socketRepository.callAccepted((data) async {
      try {
        final answerMap = data['answer'];
        final RTCSessionDescription answer =
            RTCSessionDescription(answerMap['sdp'], answerMap['type']);
        await peerService.setRemoteDescription(answer);

        for (final tracks in stream!.getTracks()) {
          print("Adding tracks to peer");
          peer.addTrack(tracks, stream!);
        }
      } catch (e) {
        print(e);
      }
    });
    socketRepository.acceptNeg((data) async {
      final offerMap = data['offer'];
      final RTCSessionDescription offer =
          RTCSessionDescription(offerMap['sdp'], offerMap['type']);
      final RTCSessionDescription ans = await peerService.getAnswer(offer);
      socketRepository.negoDone({
        'answer': {
          'sdp': ans.sdp,
          'type': ans.type,
        },
        'roomId': widget.roomId,
      });
    });
    socketRepository.finalNego((data) async {
      final answerMap = data['answer'];
      final RTCSessionDescription answer =
          RTCSessionDescription(answerMap['sdp'], answerMap['type']);
      await peerService.setRemoteDescription(answer);
    });
    peer.onRenegotiationNeeded = () async {
      final offer = await peer.createOffer();
      socketRepository.makeNego({
        'offer': {
          'sdp': offer.sdp,
          'type': offer.type,
        },
        'roomId': widget.roomId,
      });
    };
    peer.onTrack = (event) {
      remoteVideoRenderer.srcObject = event.streams[0];
      remoteVideoRenderer.initialize();
      print("got Tracks");
      setState(() {});
    };
  }

  void makeCall() async {
    try {
      await localVideoRenderer.initialize();
      stream = await navigator.mediaDevices
          .getUserMedia({'video': true, 'audio': true});
      localVideoRenderer.srcObject = stream;

      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call'),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: RTCVideoView(localVideoRenderer),
            ),
            Expanded(
              child: RTCVideoView(remoteVideoRenderer),
            ),
          ],
        ),
      ),
    );
  }
}
