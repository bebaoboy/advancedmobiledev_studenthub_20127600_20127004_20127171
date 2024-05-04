importScripts(
  "https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js"
);
importScripts(
  "https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js"
);

firebase.initializeApp({
  apiKey: "AIzaSyDyFechc2lEQWG6WrzG99GZAfPArIWZK0A",
  appId: "1:600076744637:web:649fe753793d10a36c44d4",
  messagingSenderId: "600076744637",
  projectId: "advmobiledev-studenthub-clc20",
  authDomain: "advmobiledev-studenthub-clc20.firebaseapp.com",
  storageBucket: "advmobiledev-studenthub-clc20.appspot.com",
  measurementId: "G-X7PPC5YLY5",
});
// Necessary to receive background messages:
const messaging = firebase.messaging();
const channel = new BroadcastChannel("sw-messages");

messaging.onMessage((payload) => {
  console.log("Web Received  onMessage ", payload);
  const promiseChain = clients
    .matchAll({
      type: "window",
      includeUncontrolled: true,
    })
    .then((windowClients) => {
      for (let i = 0; i < windowClients.length; i++) {
        const windowClient = windowClients[i];
        windowClient.postMessage(payload);
      }
    })
    .then(() => {
      const title = payload.notification.title;
      var click_action = payload.data.ui_route; //ui route is ur route

      const options = {
        body: payload.notification.body,
        data: {
          click_action,
        },
      };
      return registration.showNotification(title, options);
    });
  return promiseChain;
});
// Optional:
messaging.onBackgroundMessage((payload) => {
  console.log("web Received background onMessage ", payload);

  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
  channel.postMessage(m);

  const promiseChain = clients
    .matchAll({
      type: "window",
      includeUncontrolled: true,
    })
    .then((windowClients) => {
      for (let i = 0; i < windowClients.length; i++) {
        const windowClient = windowClients[i];
        windowClient.postMessage(payload);
      }
    })
    .then(() => {
      const title = payload.notification.title;
      var click_action = payload.data.ui_route; //ui route is ur route

      const options = {
        body: payload.notification.body,
        data: {
          click_action,
        },
      };
      return registration.showNotification(title, options);
    });
  return promiseChain;
});

self.addEventListener("notificationclick", (e) => {
  console.log("notification clicked: ", event);
  if ("FCM_MSG" in event.notification.data) {
    console.log("onNotificationClickevent", {
      fcm_data: event.notification.data.FCM_MSG,
      clicked: "true",
    });
    channel.postMessage({
      fcm_data: event.notification.data.FCM_MSG,
      clicked: "true",
    });
  }
  data = e.notification.data.obj;
  // Close the notification popout
  e.notification.close();
  // Get all the Window clients
  e.waitUntil(
    clients.matchAll({ type: "window" }).then((clientsArr) => {
      // If a Window tab matching the targeted URL already exists, focus that;
      const hadWindowToFocus = clientsArr.some((windowClient) =>
        windowClient.url === e.notification.data.click_action
          ? (windowClient.focus(), true)
          : false
      );
      // Otherwise, open a new tab to the applicable URL and focus it.
      if (!hadWindowToFocus)
        clients
          .openWindow(e.notification.data.click_action)
          .then((windowClient) => (windowClient ? windowClient.focus() : null));
    })
  );
});
