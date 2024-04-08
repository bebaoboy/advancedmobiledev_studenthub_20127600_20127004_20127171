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

// Optional:
messaging.onBackgroundMessage((m) => {
  console.log("onBackgroundMessageWEBB", m);
});