var attachedToQuestionFiles = '';
var questionFilesAttachForm = '';
$(document).on('turbolinks:load', function() {
    var like_link = $('.question-rating .ajax-rating-links .like-link-section .like-link');
    var unlike_link = $('.question-rating .ajax-rating-links .unlike-link-section .unlike-link');
    var dislike_link = $('.question-rating .ajax-rating-links .dislike-link-section .dislike-link');

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

    $('.question-rating').on('ajax:success', '.like-link', function(e) {
        var question_rating = e.detail[0];

        $('.question-rating .rating-links .like-links').html(unlike_link);
        $('.question-rating .rating-links .dislike-links').html(dislike_link);

        $('.question-rating-value').html('<p>Rating: ' + question_rating.score + '</p>');
        $('.notice').html('<p>You have successfully rated the question.</p>');

    });

    $('.question-rating').on('ajax:success', '.dislike-link', function(e) {
        var question_rating = e.detail[0];

        $('.question-rating .rating-links .like-links').html(like_link);
        $('.question-rating .rating-links .dislike-links').html(unlike_link);

        $('.question-rating-value').html('<p>Rating: ' + question_rating.score + '</p>');
        $('.notice').html('<p>You have successfully rated the question.</p>');
    });

    $('.question-rating').on('ajax:success', '.unlike-link', function(e) {
        var question_rating = e.detail[0];

        $('.question-rating .rating-links .like-links').html(like_link);
        $('.question-rating .rating-links .dislike-links').html(dislike_link);

        $('.question-rating-value').html('<p>Rating: ' + question_rating.score + '</p>');
        $('.notice').html('<p>You have canceled your vote.</p>');
    })
});