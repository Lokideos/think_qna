$(document).on('turbolinks:load', function(){
    $(document).on('ajax:success', '.create-comment-form', function(e) {
        var comment = e.detail[0];
        $('.question-comments .question-comments-list').append('<li class="comment">' + comment.body + '</li>');
        $('.question-comments .new-comment .create-comment-form #comment_body').val('');
    })
});