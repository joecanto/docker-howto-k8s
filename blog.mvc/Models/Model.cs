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
            var connection = db.ConnectionString();
            // var connection = @"Server=sqlexpress;User Id=sa;Password=Tot@11y5ecr3t;Database=bloggingDB;";
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