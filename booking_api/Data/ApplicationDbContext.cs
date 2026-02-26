using Microsoft.EntityFrameworkCore;
using BookingApi.Models;

namespace BookingApi.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        public DbSet<Booking> Bookings { get; set; }
        public DbSet<BookingParty> BookingParties { get; set; }
        public DbSet<Status> Statuses { get; set; }
        public DbSet<Location> Locations { get; set; }
        public DbSet<LocationType> LocationTypes { get; set; }
        public DbSet<Port> Ports { get; set; }
        public DbSet<VesselSchedule> VesselSchedules { get; set; }
        public DbSet<Vessel> Vessels { get; set; }
        public DbSet<TransportService> TransportServices { get; set; }
        public DbSet<PaymentMode> PaymentModes { get; set; }
        public DbSet<Equipment> Equipment { get; set; }
        public DbSet<Commodity> Commodities { get; set; }
        public DbSet<Customer> Customers { get; set; }
        public DbSet<CustomerInformation> CustomerInformations { get; set; }
        public DbSet<Container> Containers { get; set; }
        public DbSet<User> Users { get; set; }
        public DbSet<UserInformation> UserInformations { get; set; }
        public DbSet<UserType> UserTypes { get; set; }
        public DbSet<UserCredential> UserCredentials { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Configure table names to match database
            modelBuilder.Entity<Booking>().ToTable("Booking");
            modelBuilder.Entity<BookingParty>().ToTable("BookingParty");
            modelBuilder.Entity<Status>().ToTable("Status");
            modelBuilder.Entity<Location>().ToTable("Location");
            modelBuilder.Entity<LocationType>().ToTable("LocationType");
            modelBuilder.Entity<Port>().ToTable("Port");
            modelBuilder.Entity<VesselSchedule>().ToTable("VesselSchedule");
            modelBuilder.Entity<Vessel>().ToTable("Vessel");
            modelBuilder.Entity<TransportService>().ToTable("TransportService");
            modelBuilder.Entity<PaymentMode>().ToTable("PaymentMode");
            modelBuilder.Entity<Equipment>().ToTable("Equipment");
            modelBuilder.Entity<Commodity>().ToTable("Commodity");
            modelBuilder.Entity<Customer>().ToTable("Customer");
            modelBuilder.Entity<CustomerInformation>().ToTable("CustomerInformation");
            modelBuilder.Entity<Container>().ToTable("Container");
            modelBuilder.Entity<User>().ToTable("User");
            modelBuilder.Entity<UserInformation>().ToTable("UserInformation");
            modelBuilder.Entity<UserType>().ToTable("UserType");
            modelBuilder.Entity<UserCredential>().ToTable("UserCredential");

            // Configure relationships
            modelBuilder.Entity<Booking>()
                .HasOne(b => b.Status)
                .WithMany(s => s.Bookings)
                .HasForeignKey(b => b.StatusId);

            modelBuilder.Entity<Booking>()
                .HasOne(b => b.OriginLocation)
                .WithMany(l => l.OriginBookings)
                .HasForeignKey(b => b.OriginLocationId);

            modelBuilder.Entity<Booking>()
                .HasOne(b => b.DestinationLocation)
                .WithMany(l => l.DestinationBookings)
                .HasForeignKey(b => b.DestinationLocationId);

            modelBuilder.Entity<Booking>()
                .HasOne(b => b.VesselSchedule)
                .WithMany(vs => vs.Bookings)
                .HasForeignKey(b => b.VesselScheduleId);

            modelBuilder.Entity<Location>()
                .HasOne(l => l.LocationType)
                .WithMany(lt => lt.Locations)
                .HasForeignKey(l => l.LocationTypeId);

            // Configure Customer -> CustomerInformation relationship
            modelBuilder.Entity<Customer>()
                .HasOne(c => c.CustomerInformation)
                .WithOne(ci => ci.Customer)
                .HasForeignKey<CustomerInformation>(ci => ci.CustomerId);
        }
    }
}