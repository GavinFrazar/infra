db.getSiblingDB("$external").runCommand(
  {
    createUser: "CN=admin",
    roles: [
      { role: "userAdminAnyDatabase", db: "admin" },
      { role: "readWriteAnyDatabase", db: "admin" }
    ]
  }
);
db.getSiblingDB("$external").runCommand(
  {
    createUser: "CN=alice",
    roles: [
      { role: "readWriteAnyDatabase", db: "admin" }
    ]
  },
);
