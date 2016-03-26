(function() {

    _.mixin({
        showTelephoneNumberAsLink: function(content) {                    
            var regex = new RegExp("\\+*\\(?\\d*\\)??\\(?\\d+\\)?\\d*([\\s./-]?\\d{6,})+", "gi");
            return content.replace(regex, "<a href='tel:$&'>$&</a>");
        }
    });

}.call(this));
