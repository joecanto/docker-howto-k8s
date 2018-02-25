using System;

public static class db {

   public static string ConnectionString(string databaseName = "bloggingDB"){
      
      string host = Environment.GetEnvironmentVariable("SQL_DB_HOST");
      string user = Environment.GetEnvironmentVariable("SQL_DB_USER");
      string password = Environment.GetEnvironmentVariable("SQL_DB_PASSWORD");

      return $@"Server={host};User Id={user};Password={password};Database={databaseName};";
   }
}