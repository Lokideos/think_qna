var attachedToQuestionFiles = '';

$(document).on('turbolinks:load', function(){
    $('.question').on('click', '.edit-question-link', function(e) {
        e.preventDefault();
        $(this).hide();
        $('.question-info').hide();
        $('.edit-question-form').removeClass('hidden');
    });

    $('.edit-question-link').on('click', function(e) {
        attachedToQuestionFiles = document.querySelector('.question-attached-files');
        $('.question-form-attached-files').html(attachedToQuestionFiles);
    });

    $('.edit-question-form').on('click', '.question-form-update-btn', function(e) {
        setTimeout(function() {
            $('.edit-question-form input[type="file"]').val('');
        }, 1);
    });
});