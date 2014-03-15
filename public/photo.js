var http = {
    get: function(obj) {
          $.ajax({
            headers: {'Accept' : 'application/json',},
            url: obj.url,
            type: 'GET',
            success: function(response, textStatus, jqXhr) {
                obj.success(response);
            },
            error: function(jqXHR, textStatus, errorThrown) {
                obj.error(errorThrown);
            }
        });
    },
    patch: function(obj) {
        $.ajax({
            headers: {
                'Accept' : 'application/json',
                'Content-Type' : 'application/json'
            },
            url: obj.url,
            type: 'PATCH',
            data: JSON.stringify(obj.data),
            success: function(response, textStatus, jqXhr) {
                obj.success(response);
            },
            error: function(jqXHR, textStatus, errorThrown) {
                obj.error(errorThrown);
            }
        });
    },
    post: function(obj) {
        $.ajax({
            headers: {
                'Accept' : 'application/json',
                'Content-Type' : 'application/json'
            },
            url: obj.url,
            type: 'POST',
            data: JSON.stringify(obj.data),
            success: function(response, textStatus, jqXhr) {
                obj.success(response);
            },
            error: function(jqXHR, textStatus, errorThrown) {
                obj.error(errorThrown);
            }
        });
    },
    delete: function(obj) {
        $.ajax({
            headers: {'Accept' : 'application/json'},
            url: obj.url,
            type: 'DELETE',
            success: function(response, textStatus, jqXhr) {
                obj.success(response);
            },
            error: function(jqXHR, textStatus, errorThrown) {
                obj.error(errorThrown);
            }
        });
    }
}

function setUpDescription(description) {
    description.edit.autosize();

    description.display.on('click', function() {
        description.display.hide();
        description.edit.show();
        description.edit.focus();
    });

    description.edit.on('blur', function() {
        description.edit.hide();
        description.display.show();

        http.patch({
            url: window.location.pathname,
            data: {description: description.edit.val()},
            success: function(obj) {
                description.display.html(obj.description);
            },
            error: console.log
        });
    });

    description.edit.hide();
}

var Tags = function(el) {
    var add, edit;

    var findElements = function() {
        add = el.find('.add');
        edit = el.find('.edit');
    }

    var tmpl = '<li class="title">TAGS</li>' +
        '{{#tags}}' +
        '<li>' +
        '  <a class="name" href="{{{url}}}">{{name}}</a>' +
        '  <a class="delete">x</a>' +
        '</li>' +
        '{{/tags}}' +
        '<li>' +
        '  <span class="add">&amp;c</span>' +
        '  <input class="edit" type="text" value="" />' +
        '</li>' +
        '<div class="clear"></div>';

    var render = function(data, next) {
        var output = Mustache.render(tmpl, data)
        el.html(output);
        findElements();
        registerEvents();
        next && next();
    }

    var deleteEvent = function(el) {
        var href = el.parent().find('a.name').attr('href');

        http.delete({
            url: window.location.pathname + href,
            success: function(obj) { render(obj); },
            error: console.log
        });
    }

    var addEvent = function(next) {
        if (edit.val().trim() === "") {
            blurEvent();
            return;
        }

        http.post({
            url: window.location.pathname + '/tags',
            data: {name: edit.val()},
            success: function(obj) { render(obj, next); },
            error: console.log
        });
    }

    var blurEvent = function() {
        edit.hide();
        add.show();
    }

    var focusEvent = function() {
        add.hide();
        edit.show();
        edit.focus();
    }

    var registerEvents = function() {
        add.on('click', focusEvent);
        edit.on('blur', blurEvent);
        edit.on('keypress', function(e) {
            if (e.keyCode == 13) {
                e.preventDefault();
                addEvent(focusEvent);
            } else if (e.keyCode == 27) {
                e.preventDefault();
                blurEvent();
            }
        });

        el.find('.delete').on('click', function() {
            deleteEvent($(this));
        });
    }

    http.get({
        url: window.location.pathname,
        success: function(data) { render(data); },
        error: console.log
    });
}

$(function() {
    var tags = new Tags($('ul.tags'));

    setUpDescription({
        edit: $('textarea.description'),
        display: $('div.description')
    });
});
