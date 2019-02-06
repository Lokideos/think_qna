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

        $('.question-links-attach-section input[type=text]').each(function() {
            if ( $(this).val() !== '' ) {
                $(this).parent().remove()
            }
        });
    });

    $('.edit-question-form').on('click', '.question-form-update-btn', function (e) {
        setTimeout(function () {
            $('.edit-question-form input[type="file"]').val('');
        }, 3);
    });

    $(document).on('ajax:success', '.subscribe-link', function(e) {
        var jsonResponse = e.detail[0];
      $(this).addClass('hidden');
      $('.notice').html(jsonResponse);
    })
        .on('ajax:error', '.subscribe-link', function(e) {
            var errors = e.detail[0];
            $('.notice').html(errors);
        });
});