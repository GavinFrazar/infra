db.getSiblingDB("$external").runCommand(
  {
    createUser: "CN=admin",
    roles: [
      { role: "userAdminAnyDatabase", db: "admin" },
      { role: "readWriteAnyDatabase", db: "admin" }
    ]
  }
);
