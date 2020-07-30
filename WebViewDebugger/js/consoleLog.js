console.log = (function(logFunc) {
    return function(str) {
        window.webkit.messageHandlers.logHandler.postMessage(str);
        logFunc.call(console, str);
    }
})(console.log);
