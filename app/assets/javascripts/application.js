//= require jquery
//= require rails-ujs
//= require turbolinks




$.ajaxSetup({
    headers: {
      'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
    }
  });
