/*
 * This function binds the ports defined in Notification.elm to
 * the browser's Notification API.
 */
export function bind(app) {
  // Exit predictably if the ports aren't in use in Elm
  if (!app.ports || !(app.ports.newNotification)) {
    console.log(
      "Could not find 'newNotification' ports on app. It may not be in use yet."
    );
    return;
  }

  // Handle events from Elm
  app.ports.newNotification.subscribe(title => {
     if (!("Notification" in window)) {
       alert("This browser does not support system notifications");
     }

     // Let's check whether notification permissions have already been granted
     else if (Notification.permission === "granted") {
       // If it's okay let's create a notification
       var notification = new Notification(title);
     }

     // Otherwise, we need to ask the user for permission
     else if (Notification.permission !== 'denied') {
       Notification.requestPermission(function (permission) {
         // If the user accepts, let's create a notification
         if (permission === "granted") {
           var notification = new Notification(title);
         }
       });
     }
  });
}
