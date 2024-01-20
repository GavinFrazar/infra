db.getSiblingDB("$external").runCommand(
  {
    createUser: "CN=alice",
    roles: [
      { role: "readWriteAnyDatabase", db: "admin" }
    ]
  }
);
db.getSiblingDB("admin").runCommand({
    createRole: "teleport-admin-role",
    privileges: [
        { resource: { cluster: true }, actions: [ "inprog" ] },
        { resource: { db: "", collection: "" }, actions: [ "grantRole", "revokeRole" ] },
        { resource: { db: "$external", "collection": "" }, actions: [ "createUser", "updateUser", "dropUser", "viewUser", "setAuthenticationRestriction", "changeCustomData"] },
    ],
    roles: [],
});
db.getSiblingDB("$external").runCommand({
  createUser: "CN=teleport-admin",
  roles: [ { role: 'teleport-admin-role', db: 'admin' } ],
});
