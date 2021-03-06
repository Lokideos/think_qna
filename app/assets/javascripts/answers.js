var attachedToAnswerFiles = '';
var answerFilesAttachForm = '';

$(document).on('turbolinks:load', function(){
    var answers_list = $('.answers');

    answers_list.on('click', '.edit-answer-link', function(e) {
        e.preventDefault();
        $(this).hide();
        var answerId = $(this).data('answerId');
        $('#answer-info-' + answerId).hide();
        $('form#edit-answer-' + answerId).removeClass('hidden');
        if (answerFilesAttachForm !== '') {
            $(answerFilesAttachForm[1]).prop('disabled', false);
            $('form#edit-answer-' + answerId + ' .answer-file-upload-section').html(answerFilesAttachForm);
        }
        answerFilesAttachForm = $('form#edit-answer-' + answerId + ' .answer-file-upload-section').children();
        attachedToAnswerFiles = $(this).closest('li').find('.answer-instance .answer-attached-files');
        $(this).closest('li').find('.edit-answer-form .answer-form-attached-files').html(attachedToAnswerFiles);

        $(this).closest('li').find('.edit-answer-form .answer-links-attach-section input[type=text]').each(function() {
            if ( $(this).val() !== '' ) {
                $(this).parent().remove()
            }
        })
    });

    $('.edit-answer-form').on('click', '.answer-form-update-btn', function(e) {
        setTimeout(function() {
            $('.edit-answer-form input[type="file"]').val('');
        }, 1);
    });
});