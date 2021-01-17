import consumer from "./consumer"

// Send messages like ActionCable.server.broadcast "notifications_channel_#{user_id}", message: 'message'

document.addEventListener('turbolinks:load', () => {

	const sidebar = document.getElementById('sidebar_button');
	const user_id = sidebar.getAttribute('data-user-id');

	consumer.subscriptions.create({channel: "NotificationsChannel", user: user_id}, {
		connected() {
			// Called when the subscription is ready for use on the server
			// console.log("User with ID " + user_id + " connected to notifications...")
			$.ajax({
				type: "GET",
				url: "/messages/display_messages",
				data: {'user': user_id},
			});
			Turbolinks.clearCache()
		},

		disconnected() {
			// Called when the subscription has been terminated by the server
			// console.log("User with ID " + user_id + " disconnected from notifications...")
			$.ajax({
				type: "POST",
				url: "/messages/clear_expired_messages",
				data: {'user': user_id},
			});
			Turbolinks.clearCache()
		},

		received(data) {
			if (data.id) {
				$.ajax({
					type: "GET",
					url: "print_message",
					data: {'id':data.id},
				});
			} else {
				console.log('Error with message data...')
			}
		}
	});
})