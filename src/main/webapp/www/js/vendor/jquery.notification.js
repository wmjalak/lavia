define(["jquery"],
    function($) {
        var config = {
            defaultTimeOut: 3000,
            notificationStyles: {
                padding: "12px 6px",
                margin: "0 0 6px 0",
                backgroundColor: "#a00",
                opacity: 0.9,
                color: "#fff",
                "text-shadow": "none",
                "font-weight": "bold",
                borderRadius: "5px",
                boxShadow: "#999 0 0 12px",
                width: "250px",
                border: "2px solid #ccc",
                "text-align": "center",
                "margin-left": "auto",
                "margin-right": "auto",
                "-ms-transform": "translateY(-50%)",
                "-webkit-transform": "translateY(-50%)",
                transform: "translateY(-50%)"
            },
            container: $("<div id='notifier'></div>")
        };

        $(document).ready(function() {
            config.container.css("position", "fixed");
            config.container.css("left", "0px");
            config.container.css("right", "0px");
            config.container.css("top", "50%");
            config.container.css("z-index", 9999);
            $("body").append(config.container);
        });

        return {
            _notify: function(message, title, iconUrl, timeOut) {

                var notificationElement = $("<div>").css(config.notificationStyles);

                timeOut = timeOut || config.defaultTimeOut;

                if (iconUrl) {
                    var iconElement = $("<img/>", {
                        src: iconUrl,
                        css: {
                            width: 36,
                            height: 36,
                            display: "inline-block",
                            verticalAlign: "middle"
                        }
                    });
                    notificationElement.append(iconElement);
                }

                var textElement = $("<div/>");

                if (title) {
                    var titleElement = $("<div/>");
                    titleElement.append(document.createTextNode(title));
                    titleElement.css("font-weight", "bold");
                    textElement.append(titleElement);
                }

                if (message) {
                    var messageElement = $("<div/>");
                    messageElement.append(document.createTextNode(message));
                    textElement.append(messageElement);
                }

                notificationElement.append(textElement);

                $("#notifier").queue( function() {
                    notificationElement.delay(timeOut).fadeOut(function() {
                        notificationElement.remove(); 
                    });
                    notificationElement.bind("click", function() {
                        notificationElement.remove();
                    });
                    notificationElement.bind("remove", function() {
                        $("#notifier").dequeue();
                    });
                    config.container.prepend(notificationElement);
                });
            },

            notify: function(message, title, iconUrl, timeOut) {
                config.notificationStyles.color = "#000000";
                config.notificationStyles.backgroundColor = "#FFFF00";
                this._notify(message, title, iconUrl, timeOut);
            },

            notifyError: function(message, title, iconUrl, timeOut) {
                config.notificationStyles.color = "#FFFFFF";
                config.notificationStyles.backgroundColor = "#ff0000";
                this._notify(message, title, iconUrl, timeOut);
            }
        }
    }
);
