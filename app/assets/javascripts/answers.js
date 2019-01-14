var attachedToAnswerFiles = '';
var answerFilesAttachForm = '';

$(document).on('turbolinks:load', function(){
    $('.answers').on('click', '.edit-answer-link', function(e) {
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
        attachedToAnswerFiles = $(this).closest('li').children('.answer-instance').children('.answer-attached-files');
        $(this).closest('li').children('.edit-answer-form').children('.answer-form-attached-files').html(attachedToAnswerFiles);

        $(this).closest('li').children('.edit-answer-form').children('.answer-form-attached-links').children('.answer-links-attach-section').children('p').children('input[type=text]').each(function() {
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