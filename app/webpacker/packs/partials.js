// Update/resize shuffled grid bricks
import Shuffle from 'shufflejs';

// Initializer tippy tooltips
tippy('.tippy', {
	allowHTML: true,
	animation: 'scale',
	duration: [300,0],
	touch: true,
	touch: 'hold'
});

if ($('#grid').length) {
	const shuffleInstance = new Shuffle(document.getElementById('grid'), {
		itemSelector: '.shuffle-brick',
		sizer: '.shuffle-sizer'
	});
	// Update shuffle instance when partial is rendered via render_async
	$(document).on('render_async_load', function(event) {
		shuffleInstance.update()
	});
}

// Loading overlay setup
$('.load').on('click', function() {
	var extra_classes = $(this).attr('data-overlay-class')
	var loading_overlay = `
	<div class="loading_overlay partial_overlay container d-flex align-items-center justify-content-center ${extra_classes}">
		<div class="spinner-grow text-primary" role="status">
			<span class="sr-only">読み込み中...</span>
		</div>
	</div>
	`;
	$($(this).attr('data-target')).prepend( loading_overlay );
})
