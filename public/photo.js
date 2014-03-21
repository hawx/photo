$(function() {
    var tags = new Tags($('ul.tags'));

    var description = new Description({
        edit: $('textarea.description'),
        display: $('div.description')
    });

    var title = new Title({
        edit: $('h1 input.here'),
        display: $('h1 span.here'),
        key: 'title'
    })
});
