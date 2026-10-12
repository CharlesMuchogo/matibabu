<img src="https://user-images.githubusercontent.com/58371052/180502503-d715278c-fcb5-4a9a-b8d4-29072f0d3188.jpg" width="230" height="500" />



## Chat between patients and doctors

Patients (this app) and doctors ([daktari](../daktari)) chat through Firestore:

- `Chats/{patientId}_{doctorId}`: conversation summary (names, photos, last message, unread counts per uid)
- `Chats/{chatId}/Messages/{id}`: `senderId`, `text`, `createdAt`
- `Tokens/{uid}`: FCM tokens, split into `patient` and `doctor` arrays

### Push notifications

`functions/` contains `notifyChatMessage`, which sends an FCM notification to the other person when a message is created. Cloud Functions need the Blaze plan.

```sh
cd functions && npm install && cd ..
firebase deploy --only functions --project matibabu-1254d
```

For iOS, upload an APNs auth key under Firebase console → Project settings → Cloud Messaging, and add `GoogleService-Info.plist` to `ios/Runner`.

### Deep links

Tapping a notification opens the chat. Chats can also be opened by link:

- Patient app: `matibabu://chat/{chatId}`
- Doctor app: `daktari://chat/{chatId}`

```sh
adb shell am start -a android.intent.action.VIEW -d "matibabu://chat/<chatId>"
xcrun simctl openurl booted "matibabu://chat/<chatId>"
```

### Firestore rules

Merge these into the project's rules:

```
match /Chats/{chatId} {
  allow read, update: if request.auth != null
    && (request.auth.uid == resource.data.patientId || request.auth.uid == resource.data.doctorId);
  allow create: if request.auth != null
    && (request.auth.uid == request.resource.data.patientId || request.auth.uid == request.resource.data.doctorId)
    && chatId == request.resource.data.patientId + "_" + request.resource.data.doctorId;

  match /Messages/{messageId} {
    function chat() { return get(/databases/$(database)/documents/Chats/$(chatId)).data; }
    allow read: if request.auth != null
      && (request.auth.uid == chat().patientId || request.auth.uid == chat().doctorId);
    allow create: if request.auth != null
      && request.resource.data.senderId == request.auth.uid
      && (request.auth.uid == chat().patientId || request.auth.uid == chat().doctorId);
  }
}

match /Tokens/{uid} {
  allow read, write: if request.auth != null && request.auth.uid == uid;
}
```
