https://idroot.us/install-mongodb-debian-12/


MongoCLI:
  use OilRefineryDB1
  db.createUser({ user: "app1", pwd: "app", roles: ["userAdminAnyDatabase", "dbAdminAnyDatabase", "readWriteAnyDatabase"] })
  db.OilRefineryDB1.insertOne({"popa":"skills"})
  
