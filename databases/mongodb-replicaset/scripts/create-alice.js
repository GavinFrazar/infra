db.getSiblingDB("$external").runCommand(
  {
    createUser: "CN=alice",
    roles: [
      { role: "readWriteAnyDatabase", db: "admin" }
    ]
  },
);
