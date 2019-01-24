$(document).on('turbolinks:load', function(){
    $(document).on('ajax:success', '.create-comment-form', function(e) {
        var comment = e.detail[0];

        var inputField = $(this).closest('.comments-section').find('.new-comment #comment_body');
        var commentsList = $(this).closest('.comments-section').find('.comments-list');
        commentsList.append(JST["templates/comment"]({ data: comment }));
        inputField.val('');

        $('.comment-delete-link').on('click', function() {
            $(this).parent().remove();
        });
    })
        .on('ajax:error', '.create-comment-form', function(e) {
            var errors = e.detail[0];
            var errorsField = $(this).closest('.comments-section').find('.new-comment .comment-errors');

            errorsField.html('<p>There are errors in your input:</p><ul class="errors-list"></ul>');

            $.each(errors, function(index, error) {
                errorsField.find('.errors-list').append('<li>' + error + '</li>');
            });
        });

    $('.comment-delete-link').on('click', function() {
        $(this).parent().remove();
    });
});