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

  void sendMessages(Map<String, dynamic> data) {
    _socketClient.emit('send-message', data);
  }

  void receiveMessageListener(Function(Map<String, dynamic>) func) {
    _socketClient.on('receive-message', (data) {
      func(data);
    });
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
}
