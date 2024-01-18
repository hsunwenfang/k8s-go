

# Protocol Buffers

https://protobuf.dev/overview/

- A smaller and faster json

- A language-neutral, platform-neutral, extensible way of serializing structured data for use in communications protocols, data storage, and more.

- inter-server communication

- archival storage

- .proto file
    - The protocol buffer compiler is invoked at build time to generate data access classes
    - messages are defined in .proto file
    - timestamp.proto, status.proto

- Advantages
    - Language and Platform neutral
    - Extensible
    - Automated generation of access classes
    - Binary format
    - Backward compatible
    - Fast to parse and generate
    - Less error prone

- Not Synario
    - Cannot handle large data

# grpc

https://grpc.io/docs/what-is-grpc/introduction/