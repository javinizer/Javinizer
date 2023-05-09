---
description: Use a custom proxy on your network requests within Javinizer
---

# Proxy Configuration

{% hint style="warning" %}
NOTE: This is an experimental feature. Though it has been added, it has largely been untested with various proxy configurations. If you find that it is not working, please create a new issue or message me on the Javinizer discord.
{% endhint %}

If you want to use a proxy with Javinizer, a few configurations are provided.

1. Open your settings file `Javinizer -OpenSettings` or via the JSON editor on the web gui.
2. Set proxy configurations
   1. `proxy.enabled` - true or false
   2. `proxy.host` - the hostname / IP of your proxy
   3. `proxy.username` - the username for your proxy (if required)
   4. `proxy.password` - the password for your proxy (if required)
