## Architecture

```
   +-------------+
   |     1a      |
   |   Shipper   |
   |  (logstash) |----1d----+
   +-------------+          |
                            |
                            |
                            |
                            v
   +-------------+     +------------+    +--------------+    +-----------------+   +------------+
   |     1b      |     |     2      |    |      3       |    |       4         |   |      5     |
   |   Shipper   +-1e->|   Broker   |+-->|  Indexer     |+-->| Storage/Search  |+->|     UI     |
   |  (logyard)  |     |(Redis/AMPQ)|    |  (logstash)  |    | (elasticsearch) |   |  (kibana)  |
   +-------------+     +------------+    +--------------+    +-----------------+   +------------+
                            ^
                            |
                            |
   +-------------+          |
   |     1c      |          |
   |   Shipper   |          |
   |  (log4NET)  |----1f----+
   +-------------+
```

### Components

1. Shippers 
  1. Route logs events from where they are generated into a message broker.
  2. Each log event should be a separate message.
  3. Format optimised for speed
  4. (1a,1b,1c) One shipper per application?  Or per server?
  5. (1d,1e,1f) Transport to broker security?
2. Broker
  1. Stores log events ready for indexing
  2. 1 queue / source?
3. Indexer
  1. Converts native format to ElasticSearch JSON format
4. Storage/Search
  1. Stores log events
  2. Search log events
  3. Security / segragation?
5. UI 
  1. Constructs ElasticSearch queries
  2. Shows / graphs results
  3. Security / segragation?
