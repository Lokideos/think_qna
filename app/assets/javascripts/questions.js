$(document).on('turbolinks:load', function(){
    $('.question').on('click', '.edit-question-link', function(e) {
        e.preventDefault();
        $(this).hide();
        $('.question-info').hide();
        $('.edit-question-form').removeClass('hidden');
    });
});