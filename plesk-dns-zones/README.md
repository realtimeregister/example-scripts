## DirectAdmin DNS zones

Example [Plesk](https://www.plesk.com/) [event listener](https://docs.plesk.com/en-US/onyx/extensions-guide/plesk-features-available-for-extensions/subscribe-to-plesk-events.71093/) to automatically create and delete [Premium DNS](https://realtimeregister.com/what-we-offer/add-products/premiumdns/) zones for all domains on the server.

Setup:
1. Place the script in `/usr/local/psa/admin/plib/registry/EventListener/` on your Plesk server
2. Configure an API key and the master IP address in the script.
3. See our [knowledge base](https://kb.realtimeregister.com/article/377-plesk-master-slave-replication) for detailed setup instructions.
