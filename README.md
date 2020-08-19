# FridgePal
#### What's good eatin?

This is my first Flutter application. I wanted to use it as a small stepping
stone to learning more cross-platform mobile development. The idea of
'everything' being a Widget is hard to grasp at first, but I found it
pretty easy to implement documentation for building most of the common mobile
dev assets.

The function is simple, keep track of groceries in a fridge. You add a
new fridge item with the button at the bottom, and it appears in the
main list.

My goals with this project are:
- learn Flutter basic widgets and architecture
- implement animations and thawed-out design
- test implementations on iOS, Android, and Chrome application
- implement CRUD operations (on mobile)

## Follow Up

I really enjoyed working with Flutter, and I can absolutely see myself developing more apps on this platform.

The nested structure of the framework was at first pretty challenging, especially when I needed to get access
to my `Fridge` class which contained all my items. Flutter has many approaches to doing this,
I went with the `Provider Consumer` pattern, which is similar to Rx Observables.

```
void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => Fridge(),
    child: MyApp(),
  ));
 
```

This allows for references to that Fridge in my main widget to respond (and rebuild) to any state changes.

My favorite piece was adding in the `Dismissible` widget, as it has a really clean animation and a super
simple interface:

```
Widget _buildFridgeItem(FridgeItem fridgeItem) {
    return Dismissible(
      child: Card(
        child: ListTile(
          leading: Text(
            fridgeItem.name,
            style: _biggestFont,
          ),
          title: Text(
            "${fridgeItem.expiration.difference(DateTime.now()).inDays} days",
            style: _biggerFont,
          ),
        ),
      ),
      background: Container(
        color: Colors.red,
      ),
      key: UniqueKey(),
      onDismissed: (direction) {
        Provider.of<Fridge>(context, listen: false).dumpFood(fridgeItem);
      },
    );
```

### SQLite

Having worked with SQLite in my Android experience, I wanted to implement
the standard CRUD operations for the Fridge object, and felt that having a UI
that was reactive to the database asynchronous functions would be the cleanest
way of doing so. I used the _Singleton Pattern_ to prevent from concurrency conflicts.

```
class Repository {
  static final _tableName = "fridge_items";
  static final _databaseName = "FridgeDatabase.db";
  static final _databaseVersion = 2;

  // singleton pattern
  Repository._internal();

  static final Repository repo = new Repository._internal();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory docs = await getApplicationDocumentsDirectory();
    String path = join(docs.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
      "id" INTEGER PRIMARY KEY, 
        "name" TEXT NOT NULL,
        "expiration" TEXT NOT NULL
      )
      ''');
  }

  Future<int> insert(FridgeItem item) async {
    Database db = await database;
    int id = await db.insert(_tableName, item.toMap());
    return id;
  }

  Future<List<FridgeItem>> getFridgeItems() async {
    Database db = await database;
    print(await db.query(_tableName));
    List<FridgeItem> items = [];
    List<Map> maps = await db.query(_tableName);
    maps.forEach((element) {
      items.add(FridgeItem.fromMap(element));
    });
    return items;
  }

  Future<int> removeAll() async {
    Database db = await database;
    int id = await db.delete(_tableName);
    return id;
  }

  Future<int> remove(FridgeItem item) async {
    Database db = await database;
    int id = await db.rawDelete('DELETE FROM $_tableName WHERE id = ?', [item.id]);
    return id;
  }
}
```

Unfortunately, this means that I cannot publish this application to the web
(without some slight changes). I think part of the fun of Flutter is sharing
applications across all the possible platforms, so I hope to be able to
share more of my Flutter projects on my personal site.

 - Dan
