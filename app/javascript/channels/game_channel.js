import consumer from "./consumer"

consumer.subscriptions.create("GameChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
    console.log('connected to game channel');
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    console.log(data);
  }
});
