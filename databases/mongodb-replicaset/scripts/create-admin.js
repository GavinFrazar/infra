db.getSiblingDB("$external").runCommand(
  {
    createUser: "CN=admin",
    roles: [
      { role: "root", db: "admin" },
      { role: "readWriteAnyDatabase", db: "admin" }
    ]
  }
);
