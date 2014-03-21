var Description = function(opts) {
    opts.edit.autosize();

    opts.display.on('click', function() {
        opts.display.hide();
        opts.edit.show();
        opts.edit.focus();
    });

    opts.edit.on('blur', function() {
        opts.edit.hide();
        opts.display.show();

        http.patch({
            url: window.location.pathname,
            data: {description: opts.edit.val()},
            success: function(obj) {
                opts.display.html(obj.description);
            },
            error: console.log
        });
    });

    opts.edit.hide();
}
