var Title = function(opts) {
        opts.display.on('click', function() {
        opts.display.hide();
        opts.edit.show();
        opts.edit.focus();
    });

    var setTitle = function() {
        var req = {
            url: window.location.pathname,
            data: {},
            success: function(obj) {
                opts.display.html(obj[opts.key]);
            },
            error: console.log
        }
        req.data[opts.key] = opts.edit.val();

        http.patch(req);

        opts.edit.hide();
        opts.display.show();
    }

    opts.edit.on('blur', setTitle);
    opts.edit.on('keypress', function(e) {
        if (e.keyCode == 13) {
            e.preventDefault();
            setTitle();
        }
    });

    opts.edit.hide();
}
