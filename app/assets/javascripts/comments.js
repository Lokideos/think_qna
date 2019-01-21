$(document).on('turbolinks:load', function(){
    $(document).on('ajax:success', '.create-comment-form', function(e) {
        var comment = e.detail[0];
        $('.question-comments .question-comments-list').append('<li class="comment">' + comment.body + '</li>');
        $('.question-comments .new-comment .create-comment-form #comment_body').val('');
        $('.question-comments .new-comment .comment-errors').html('');
    })
        .on('ajax:error', '.create-comment-form', function(e) {
            var errors = e.detail[0];
            console.log(errors);
            $('.question-comments .new-comment .comment-errors').html('<p>There are errors in your input:</p><ul class="errors-list"></ul>');
            $.each(errors, function(index, error) {
                $('.question-comments .new-comment .comment-errors .errors-list').append('<li>' + error + '</li>');
            });
        });

    $('.comment-delete-link').on('click', function() {
        $(this).parent().remove();
    });
});