$( document ).ready(function() {
  // check if the Google Analytics function is available
  if (typeof ga == 'function') {
    // GA Tracking of comment process
    $('.link-to-comment-form').click(function(e) {
      ga('send', 'event', 'comments', 'click link to go to comment form');
    });

    $('#comment-action-inputgroup input[type="submit"]').click(function(e) {
      ga('send', 'event', 'comments', 'click submit new comment');
    });

    if ($('.notice-comment-confirmed').length) {
      ga('send', 'event', 'comments', 'comment confirm message displayed');
    }

    if ($('#comments-area .error').length) {
      ga('send', 'event', 'comments', 'comment form error message displayed');
    }
  }
});
