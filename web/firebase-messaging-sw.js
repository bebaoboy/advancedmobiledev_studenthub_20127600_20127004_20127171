importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js");

firebase.initializeApp({
    apiKey: 'AIzaSyDyFechc2lEQWG6WrzG99GZAfPArIWZK0A',
    appId: '1:600076744637:web:649fe753793d10a36c44d4',
    messagingSenderId: '600076744637',
    projectId: 'advmobiledev-studenthub-clc20',
    authDomain: 'advmobiledev-studenthub-clc20.firebaseapp.com',
    storageBucket: 'advmobiledev-studenthub-clc20.appspot.com',
    measurementId: 'G-X7PPC5YLY5',
});
// Necessary to receive background messages:
const messaging = firebase.messaging();
const channel = new BroadcastChannel('sw-messages');

// Optional:
messaging.onBackgroundMessage((m) => {
  console.log("onBackgroundMessageWEBB", m);
  // channel.postMessage(
  //   m
  // );
});

// messaging.setBackgroundMessageHandler(function (payload) {
//   const promiseChain = clients
//       .matchAll({
//           type: "window",
//           includeUncontrolled: true
//       })
//       .then(windowClients => {
//           for (let i = 0; i < windowClients.length; i++) {
//               const windowClient = windowClients[i];
//               windowClient.postMessage(payload);
//           }
//       })
//       .then(() => {
//           const title = payload.notification.title;
//           const options = {
//               body: payload.notification.score
//             };
//           return registration.showNotification(title, options);
//       });
//   return promiseChain;
// });

self.addEventListener('notificationclick', function (event) {
  console.log('notification clicked: ', event);
  // if('FCM_MSG' in event.notification.data)
  // {
  //   console.log("onNotificationClickevent", {'fcm_data': event.notification.data.FCM_MSG, 'clicked' : 'true'});
  //   channel.postMessage(
  //     {'fcm_data': event.notification.data.FCM_MSG, 'clicked' : 'true'}
  //   );
  // }
});
