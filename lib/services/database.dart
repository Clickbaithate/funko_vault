import "package:funko_vault/models/folder.dart";
import "package:funko_vault/models/funko.dart";
import "package:path/path.dart";
import "package:sqflite/sqflite.dart";

class DatabaseService {

  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();
  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {

    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "FunkoPops.db");

    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          '''
            CREATE TABLE liked (
              Id INTEGER PRIMARY KEY,
              Name TEXT,
              Series TEXT,
              Rating TEXT,
              Scale TEXT,
              Brand TEXT,
              Type TEXT,
              Image TEXT UNIQUE
            );
          '''
        );
        await db.execute(
          '''
            CREATE TABLE folders (
              Id INTEGER PRIMARY KEY,
              Name TEXT UNIQUE
            );
          '''
        );
        await db.execute(
          '''
            CREATE TABLE folder_items (
              Id INTEGER PRIMARY KEY,
              FolderName TEXT,
              Name TEXT,
              Series TEXT,
              Rating TEXT,
              Scale TEXT,
              Brand TEXT,
              Type TEXT,
              Image TEXT UNIQUE,
              FOREIGN KEY (FolderName) REFERENCES folders(Name)
            );
          '''
        );
      }
    );
    return database;
  }

  // Check if a funko is liked
  Future<bool> isLiked(Funko funko) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      "liked",
      where: "Id = ?",
      whereArgs: [funko.id]
    );
    return results.isNotEmpty;
  }

  // checks if a funko is in a given folder
  Future<bool> isInFolder(String folderName, Funko funko) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      "folder_items",
      where: "FolderName = ? AND Image = ?",
      whereArgs: [folderName, funko.image]
    );
    return result.isNotEmpty;
  }

  // like a funko
  Future<void> likeFunko(Funko funko) async {
    final db = await database;
    await db.insert(
      "liked",
      {
        "Id": funko.id,
        "Name": funko.name,
        "Series": funko.series,
        "Rating": funko.rating,
        "Scale": funko.scale,
        "Brand": funko.brand,
        "Type": funko.type,
        "Image": funko.image,
      },
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  // add a new folder
  Future<void> addFolder(String name) async {
    final db = await database;
    await db.insert(
      "folders",
      {
        "Name" : name
      }, 
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  // unlike a funko
  Future<void> unlikeFunko(int id) async {
    final db = await database;
    await db.delete(
      "liked",
      where: "Id = ?",
      whereArgs: [id]
    );
  }

  // delete a folder and its child funko pops
  Future<void> deleteFolder(int id) async {

    final db = await database;

    // find the folder
    final folder = await db.query(
      "folders",
      where: "Id = ?",
      whereArgs: [id]
    );

    // delete the folder from folders table
    await db.delete(
      "folders",
      where: "Id = ?",
      whereArgs: [id]
    );

    // use folder variable to delete all funko pops previously associated with that folder
    await db.delete(
      "folder_items",
      where: "FolderName = ?",
      whereArgs: [folder.first["Name"] as String]
    );

  }

  // deleting a funko that belongs to a specific folder
  Future<void> deleteFromFolder(String name, String image) async {
    final db = await database;
    await db.delete(
      "folder_items",
      where: "FolderName = ? AND Image = ?",
      whereArgs: [name, image]
    );
  }

  // get all liked funkos
  Future<List<Funko>> getLikedFunkos() async {
    final db = await database;
    final data = await db.query("liked");
    List<Funko> likedFunkos = data.map(
      (e) => Funko(
        id: e["Id"] as int, 
        name: e["Name"] as String, 
        series: e["Series"] as String, 
        rating: e["Rating"] as String, 
        scale: e["Scale"] as String, 
        brand: e["Brand"] as String, 
        type: e["Type"] as String, 
        image: e["Image"] as String)
    ).toList();
    return likedFunkos;
  }

  // get all folders
  Future<List<Folder>> getFolders() async {
    final db = await database;
    final data = await db.query("folders");
    List<Folder> folders = data.map(
      (e) => Folder(
        id: e["Id"] as int,
        name: e["Name"] as String
      )
    ).toList();
    return folders;
  }

  // get all funkos from a specific folder
  Future<List<Funko>> getSavedFunkos(String folderName) async {
    final db = await database;
    final data = await db.query(
      "folder_items",
      where: "FolderName = ?",
      whereArgs: [folderName]
    );
    List<Funko> funkos = data.map(
      (e) => Funko(
        id: e["Id"] as int,
        name: e["Name"] as String,
        series: e["Series"] as String,
        rating: e["Rating"] as String,
        scale: e["Scale"] as String,
        brand: e["Brand"] as String,
        type: e["Type"] as String,
        image: e["Image"] as String
      )
    ).toList();
    return funkos;
  }

  // add a funko to a specific folder
  Future<void> addToFolder(String folderName, Funko funko) async {
    final db = await database;
    await db.insert(
      "folder_items",
      {
        "FolderName": folderName,
        "Name": funko.name,
        "Series": funko.series,
        "Rating": funko.rating,
        "Scale": funko.scale,
        "Brand": funko.brand,
        "Type": funko.type,
        "Image": funko.image
      },
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

}