var attachedToQuestionFiles = '';
var questionFilesAttachForm = '';

$(document).on('turbolinks:load', function() {
    questionFilesAttachForm = $('.edit-question-form .question-file-upload-section').children();

    $('.question').on('click', '.edit-question-link', function (e) {
        e.preventDefault();
        $(this).hide();
        $('.question-info').hide();
        $('.edit-question-form').removeClass('hidden');
    });

    $('.edit-question-link').on('click', function (e) {
        attachedToQuestionFiles = document.querySelector('.question-attached-files');
        $('.question-form-attached-files').html(attachedToQuestionFiles);
        $(questionFilesAttachForm[1]).prop('disabled', false);
        $('.edit-question-form .question-file-upload-section').html(questionFilesAttachForm);
    });

    $('.edit-question-form').on('click', '.question-form-update-btn', function (e) {
        setTimeout(function () {
            $('.edit-question-form input[type="file"]').val('');
        }, 3);
    });
});