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

    $('.notice-comment-confirmed .button-facebook').click(function(e) {
      ga('send', 'event', 'comments', 'click Facebook share', 'from comment confirmation');
    }

    // Creating Alerts
    $('#new_alert input[type="submit"]').click(function(e) {
      ga('send', 'event', 'alerts', 'click submit create alert');
    });

    if ($('#new_alert .error').length) {
      ga('send', 'event', 'alerts', 'alert form error messages displayed');
    }

    // Searching for applications
    $('.address-search input[type="submit"]').click(function(e) {
      ga('send', 'event', 'search', 'click submit address search');
    });

    $('.address-search #geolocate').click(function(e) {
      ga('send', 'event', 'search', 'click locate me link');
    });

    if ($('.address-search .error').length) {
      ga('send', 'event', 'search', 'address search form error message displayed');
    }
  }
});
