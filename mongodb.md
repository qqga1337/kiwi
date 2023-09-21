https://idroot.us/install-mongodb-debian-12/

https://www.ibm.com/support/pages/how-connect-mongodb


MongoCLI:

    use OilRefineryDB1

    use admin
  
  db.createUser({ user: "app1", pwd: "app", roles: ["userAdminAnyDatabase", "dbAdminAnyDatabase", "readWriteAnyDatabase"] })
  
  db.OilRefineryDB1.insertOne({"popa":"skills"})
  
  
