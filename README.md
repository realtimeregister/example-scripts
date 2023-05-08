# Realtime Register example scripts

Example scripts for usage of the [Realtime Register](https://realtimeregister.com/) API, see see https://dm.realtimeregister.com/docs/api/ for the API documentation.


## DirectAdmin DNS zones

Example [DirectAdmin](https://www.directadmin.com/) [hooks](https://www.directadmin.com/features.php?id=506) to automatically create and delete [Premium DNS](https://realtimeregister.com/what-we-offer/add-products/premiumdns/) zones for all domains on the server.

Setup:
1. Place the scripts in `/usr/local/directadmin/scripts/custom/` on your DirectAdmin server
2. Configure A API key and the master IP address in the scripts.
3. See our [knowledge base](https://kb.realtimeregister.com/article/375-direct-admin-master-slave-replication) for detailed setup instructions.
