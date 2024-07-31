import 'package:dodoc/clients/socket_client.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketRepository {
  final _socketClient = SocketClient.instance.socket!;

  Socket get socketClient => _socketClient;

  void joinRoom(String documentId) {
    _socketClient.emit('join', documentId);
  }

  void typing(Map<String, dynamic> data) {
    _socketClient.emit('typing', data);
  }

  void autoSave(Map<String, dynamic> data) {
    _socketClient.emit('autosave', data);
  }

  void changeListener(Function(Map<String, dynamic>) func) {
    _socketClient.on('changes', (data) => func(data));
  }

  void disposeChangeListener() {
    _socketClient.off('changes');
  }

  void sendMessages(Map<String, dynamic> data) {
    _socketClient.emit('send-message', data);
  }

  void receiveMessageListener(Function(Map<String, dynamic>) func) {
    _socketClient.on('receive-message', (data) {
      func(data);
    });
  }

  void disposeReceiveMessageListener() {
    _socketClient.off('receive-message');
  }

  void shareFile(Map<String, dynamic> data) {
    _socketClient.emit('share-file', data);
  }

  void receiveFileListener(Function(Map<String, dynamic>) func) {
    _socketClient.on('receive-file', (data) {
      print('file received on socket');
      func(data);
    });
  }

  void disposeReceiveFileListener() {
    _socketClient.off('receive-file');
  }

  void deleteFile(Map<String, dynamic> data) {
    _socketClient.emit('delete-file', data);
  }

  void fileDeletedListener(Function(Map<String, dynamic>) func) {
    _socketClient.on('file-deleted', (data) {
      func(data);
    });
  }

  void disposeFileDeletedListener() {
    _socketClient.off('file-deleted');
  }

  void call(Map<String, dynamic> data) {
    _socketClient.emit('user:call', data);
  }

  void incomingCall(Function(Map<String, dynamic>) func) {
    _socketClient.on('incoming:call', (data) {
      func(data);
    });
  }

  void sendAnswer(Map<String, dynamic> data) {
    _socketClient.emit('call:accepted', data);
  }

  void callAccepted(Function(Map<String, dynamic>) func) {
    _socketClient.on('call:accepted', (data) {
      func(data);
    });
  }

  void makeNego(Map<String, dynamic> data) {
    _socketClient.emit('peer:nego:needed', data);
  }

  void acceptNeg(Function(Map<String, dynamic>) func) {
    _socketClient.on('peer:nego:needed', (data) {
      func(data);
    });
  }

  void negoDone(Map<String, dynamic> data) {
    _socketClient.emit('peer:nego:done', data);
  }

  void finalNego(Function(Map<String, dynamic>) func) {
    _socketClient.on('peer:nego:final', (data) {
      func(data);
    });
  }
}
