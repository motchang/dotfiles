function FindProxyForURL(url, host) {
    if (shExpMatch(host, "*.local")) {
	return "PROXY localhost:3000";
    }
    if (shExpMatch(host, "*.localhost")) {
	return "PROXY localhost";
    }
    return "DIRECT";
}
