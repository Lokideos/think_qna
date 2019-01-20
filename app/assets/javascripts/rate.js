$(document).on('turbolinks:load', function() {

    $('.rate-link').on('ajax:success', function(e){
        var rating = e.detail[0];
        var ratable_id = rating.ratable_id;
        var ratable_type = rating.ratable_type.charAt(0).toLowerCase() + rating.ratable_type.substr(1);

        $('#' + ratable_type + '-info-' + ratable_id + ' .' + ratable_type + '-rating-value').html('<p>Rating: ' + rating.score + '</p>');
        $('#' + ratable_type + '-info-' + ratable_id + ' .rate-link').removeClass('hidden');
        $(this).addClass('hidden');
    });
});