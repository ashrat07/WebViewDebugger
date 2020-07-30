function getSessionStorage() {
    var final = {};
    for (i = 0; i < sessionStorage.length; i++) {
        key = sessionStorage.key(i);
        value = sessionStorage.getItem(key);
        final[key] = value;
    }
    return final;
}
getSessionStorage();
