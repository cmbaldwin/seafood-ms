import consumer from "./consumer"

// Send messages like ActionCable.server.broadcast "notifications_channel", message: 'message'

consumer.subscriptions.create("NotificationsChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  	console.log("Connected to notifications...")
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    if ($('#front_sidebar').hasClass("active")) {
      $('#front_sidebar').toggleClass('active');
      $('#sidebarCollapse').toggleClass('active');
      $('#sidebar_spacer').toggleClass('active');
    };
    console.log(data)
  }
});
