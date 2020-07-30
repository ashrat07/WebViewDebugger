var open = XMLHttpRequest.prototype.open;
XMLHttpRequest.prototype.open = function() {
    this.addEventListener("load", function() {
        var message = { "status": this.status, "responseURL": this.responseURL, "response": this.response }
        window.webkit.messageHandlers.networkHandler.postMessage(message);
    });
    open.apply(this, arguments);
};
