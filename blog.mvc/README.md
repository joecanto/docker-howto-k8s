Prerequisites
=============
* .net core sdk
* IDE - any text editor will suffice

Lesson 1 - Build a basic app using dot net core
================================================
Create a mvc project called blog.mvc, run it and check http://localhost:5000 to verify that it has been created successfully.
```
dotnet new mvc -o blog.mvc -au None -f netcoreapp2.0
dotnet run
```

Ctrl-c the running app and add the following dependencies
```
dotnet add package Microsoft.EntityFrameworkCore
dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.VisualStudio.Web.CodeGeneration.Design
```

#### Manually edit blog.mvc.csproj and add the following:
```
<ItemGroup>
    <DotNetCliToolReference Include="Microsoft.EntityFrameworkCore.Tools.DotNet" Version="2.0.1" />
  </ItemGroup>
```

Pull any missing dependencies
```dotnet restore```

Lesson 2 - Add a database model & SQL Server dependency
=======================================================
Use docker to run a SQL Server instance
```docker run -e 'ACCEPT_EULA=Y' -e 'MSSQL_SA_PASSWORD=Tot@11y5ecr3t' -e 'MSSQL_PID=Developer' -p 1433:1433 --name sqlexpress -d microsoft/mssql-server-linux```

or for docker on windows
```docker run -d -p 1433:1433 -h sqlexpress -e sa_password=Tot@11y5ecr3t -e ACCEPT_EULA=Y microsoft/mssql-server-windows-express```

Add the following content to a cs file in the Models directory (e.g. Model.cs)
```
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;

namespace blog.Mvc.Models
{
    public class BloggingContext : DbContext
    {
        private static bool _created = false;

        public BloggingContext()
        { 
            if (!_created)
            {
                _created = true;
                Database.EnsureCreated();
            }
        }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            var connection = @"Server=localhost;User Id=sa;Password=Tot@11y5ecr3t;Database=bloggingDB;";
            optionsBuilder.UseSqlServer(connection);
        }

        public DbSet<Blog> Blogs { get; set; }
        public DbSet<Post> Posts { get; set; }
    }

    public class Blog
    {
        public int BlogId { get; set; }
        public string Url { get; set; }
        public virtual List<Post> Posts { get; set; }
    }

    public class Post
    {
        public int PostId { get; set; }
        public string Title { get; set; }
        public string Content { get; set; }
        public int BlogId { get; set; }
        public Blog Blog { get; set; }
    }
}
```

Now Add the db connection string to the project (startup.cs)
```
 public void ConfigureServices(IServiceCollection services)
        {
            var connection = @"Server=localhost;User Id=sa;Password=Tot@11y5ecr3t;Database=bloggingDB;";
            
            services.AddMvc();

            services.AddDbContext<BloggingContext>(options => options.UseSqlServer(connection));
        }
```

### Create the database migration (code first)
```
dotnet ef migrations add initialCreate
```

### Build a basic Web UI
Run the following to scaffold out a Blog controller and views
```
dotnet aspnet-codegenerator controller -name BlogsController -m Blog -dc BloggingContext --relativeFolderPath Controllers --useDefaultLayout --referenceScriptLibraries
```

#### Run the app locally
```dotnet run```
check http://localhost:5000/blogs to verify that it works successfully.


Lesson 3 - Dockerize the app
========================================
Create a .dockerignore file (```touch .dockerignore```) and add the following
```
bin\
obj\
```

Create a Dockerfile (```touch Dockerfile```) and add the following
```
FROM microsoft/aspnetcore-build:2.0 AS build-env

WORKDIR /app

# Copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY . ./
RUN dotnet publish -c Release -o out

# Build runtime image
FROM microsoft/aspnetcore:2.0
WORKDIR /app
COPY --from=build-env /app/out .
ENTRYPOINT ["dotnet", "blog.mvc.dll"]
```

Replace references to ```localhost``` in the DB connection string (Startup.cs & Models/Model.cs) with the value of ```--name``` in the docker run command for sql server (```sqlexpress```)

Build and run the blog.mvc docker image 
```
docker build -t blog.mvc:latest .
docker run -p 8080:80 --name blogs -d blog.mvc:latest
```

It should be accessible on http://localhost:8080/blogs

Remove the existing docker processes
```docker rm -f sqlexpress blogs```

Lesson 4 - Docker Compose to do the heavy lifting
=================================================
Create a ```docker-compose.yaml``` file and add the following
__Note: For windows users, change the image to microsoft/mssql-server-windows-express__

```
version: '2.1'
services:
  sqlexpress:
    image: microsoft/mssql-server-linux
    environment:
      SA_PASSWORD : "Tot@11y5ecr3t"
      ACCEPT_EULA: "Y"
      MSSQL_PID: "Developer"
    ports:
      - "1433:1433"
  webapp:
    build:
      context: .
      dockerfile: Dockerfile
    depends_on:  
      - "sqlexpress"         
    ports:
      - "8080:80"
```

run the following commands to spin up the environment.

```
docker-compose build
docker-compose up
```
The web app should be accessible at http://localhost:8080/blogs


FAQ
===
>Q. How do I see errors through a browser when debugging a .Net core app?
>A. ```export ASPNETCORE_ENVIRONMENT=Development``` prior to ```dotnet run```
>
>Q. How do I see the SQL generated by an EF code migration?
>A. ```dotnet ef migrations script```
>
>Q. How do I remove previous migrations?
>A. ```dotnet ef migrations remove```
>
>Q. The 'addInitial' migration didn't update the database
>A. ```dotnet ef database update initialCreate```
>
>Q. How do I see running docker-compose processes?
>A. ```docker-compose ps```
