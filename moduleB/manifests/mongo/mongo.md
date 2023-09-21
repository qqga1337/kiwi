# Mongo client

Чтоб создать базу данных -- делаем так

```
use dbname #dbname это имя базы
db.dbname.insertone({"popa": "jopa"})  #dbname это имя базы
```

База сохранится на pvc и переживет перезапуск монги
