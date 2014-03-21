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
