function getLocalStorage() {
    var final = {};
    for (i = 0; i < localStorage.length; i++) {
        key = localStorage.key(i);
        value = localStorage.getItem(key);
        final[key] = value;
    }
    return final;
}
getLocalStorage();
