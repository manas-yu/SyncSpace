# SyncSpace

**SyncSpace** is a real-time collaborative platform enabling document editing, file sharing, and video conferencing. Built using Flutter (frontend), Node.js (backend), MongoDB (database), and WebRTC with SFU architecture for scalable video calling. It leverages Socket.IO for real-time communication and JWT-based authentication for secure access.

---

## 🚀 Features

- 📄 **Real-time Document Editing**  
  Collaborate with multiple users on the same document with live updates.

- 📁 **File Sharing**  
  Share files instantly with other participants in a session.

- 🎥 **Video Conferencing**  
  Seamless group video calls powered by WebRTC using SFU (Selective Forwarding Unit) architecture.

- 🔄 **Live Synchronization**  
  Utilizes Socket.IO to synchronize data instantly between clients.

- 🔐 **Secure Sessions**  
  JWT-based authentication and authorization ensure user identity and session integrity.

---

## 🛠️ Tech Stack

| Layer        | Technology                         |
|--------------|------------------------------------|
| Frontend     | Flutter                            |
| Backend      | Node.js, Express.js                |
| Database     | MongoDB                            |
| Realtime     | WebRTC (SFU), Socket.IO            |
| Auth         | JWT (JSON Web Tokens)              |

---
## Backend Architecture Overview

### WebRTC (SFU Model)
- Designed to scale video conferencing by routing media through a central SFU server.
- Reduces peer-to-peer overhead and ensures consistent performance.

### Socket.IO
- Used for all real-time interactions, including document edits, file transfers, and call signaling.

---
