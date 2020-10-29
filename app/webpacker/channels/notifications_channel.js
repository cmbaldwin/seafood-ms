import consumer from "./consumer"

// Send messages like ActionCable.server.broadcast "notifications_channel", message: 'message'

document.addEventListener('turbolinks:load', () => {

	const sidebar = document.getElementById('front_sidebar');
	const user_id = sidebar.getAttribute('data-user-id');

	consumer.subscriptions.create({channel: "NotificationsChannel", user: user_id}, {
		connected() {
			// Called when the subscription is ready for use on the server
			// console.log("User with ID " + user_id + " connected to notifications...")
		},

		disconnected() {
			// Called when the subscription has been terminated by the server
			// console.log("User with ID " + user_id + " disconnected from notifications...")
		},

		received(data) {
			if ($('#front_sidebar').hasClass("active")) {
				$('#front_sidebar').toggleClass('active');
				$('.sidebarCollapse').toggleClass('active');
				$('#sidebar_spacer').toggleClass('active');
			};
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