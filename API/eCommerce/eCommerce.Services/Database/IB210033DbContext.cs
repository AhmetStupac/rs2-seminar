using eCommerce.Model.Enums;
using Microsoft.EntityFrameworkCore;

namespace eCommerce.Services.Database
{
    public class IB210033DbContext : DbContext
    {
        public IB210033DbContext(DbContextOptions<IB210033DbContext> options) : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<Role> Roles { get; set; }
        public DbSet<UserRole> UserRoles { get; set; }
     //   public DbSet<Product> Products { get; set; }
        public DbSet<PersonalTrainer> PersonalTrainers { get; set; }
        public DbSet<TrainingPlan> TrainingPlans { get; set; }
        public DbSet<Exercise> Exercises { get; set; }
        public DbSet<ExercisePlan> ExercisePlans { get; set; }
        public DbSet<NutritionPlan> NutritionPlans { get; set; }
        public DbSet<Equipment> Equipments { get; set; }
        public DbSet<MuscleGroup> MuscleGroups { get; set; }
        public DbSet<Training> Trainings { get; set; }
        public DbSet<Image> Images { get; set; }
        public DbSet<Message> Messages { get; set; }
        public DbSet<Group> Groups { get; set; }
        public DbSet<Connection> Connections { get; set; }
        public DbSet<Country> Countries { get; set; }
        public DbSet<City> Cities { get; set; }
        public DbSet<Gym> Gyms { get; set; }
        public DbSet<TrainingSession> TrainingSessions { get; set; }
        public DbSet<PersonalTrainerRating> PersonalTrainerRatings { get; set; }
        public DbSet<MonthlyTrainingStatistics> MonthlyTrainingStatistics { get; set; }
        public DbSet<GroupTrainingSession> GroupTrainingSessions { get; set; }
        public DbSet<GroupTrainingSessionParticipant> GroupTrainingSessionParticipants { get; set; }
        public DbSet<Payment> Payments { get; set; }
        public DbSet<Membership> Memberships { get; set; }
        public DbSet<Notification> Notifications { get; set; }





        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configure User entity
            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();

            modelBuilder.Entity<User>()
                .HasIndex(u => u.Username)
                .IsUnique();

            // Configure Role entity
            modelBuilder.Entity<Role>()
                .HasIndex(r => r.Name)
                .IsUnique();

            // Global query filter za soft delete - User
            modelBuilder.Entity<User>()
                .HasQueryFilter(u => !u.IsDeleted);

            // Configure User -> ProfileImage as many-to-one (multiple users can share the same image)
            modelBuilder.Entity<User>()
                .HasOne(u => u.ProfileImage)
                .WithMany()
                .HasForeignKey(u => u.ProfileImageId)
                .OnDelete(DeleteBehavior.SetNull)
                .IsRequired(false);

            // Global query filter for PersonalTrainerRating - exclude ratings from deleted users
            modelBuilder.Entity<PersonalTrainerRating>()
                .HasQueryFilter(r => r.User == null || !r.User.IsDeleted);

            // Matching query filters for entities with required User FK
            modelBuilder.Entity<GroupTrainingSession>()
                .HasQueryFilter(g => !g.Creator.IsDeleted);

            modelBuilder.Entity<GroupTrainingSessionParticipant>()
                .HasQueryFilter(p => !p.User.IsDeleted);

            modelBuilder.Entity<Payment>()
                .HasQueryFilter(p => !p.User.IsDeleted);

            modelBuilder.Entity<Notification>()
                .HasQueryFilter(n => n.User == null || !n.User.IsDeleted);

            // Membership – ignore computed property, filter soft-deleted clients, configure relationships
            modelBuilder.Entity<Membership>()
                .Ignore(m => m.IsActive)
                .HasQueryFilter(m => !m.Client.IsDeleted);

            modelBuilder.Entity<Membership>()
                .HasOne(m => m.Client)
                .WithMany()
                .HasForeignKey(m => m.ClientUserId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Membership>()
                .HasOne(m => m.PersonalTrainer)
                .WithMany()
                .HasForeignKey(m => m.PersonalTrainerId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Membership>()
                .HasOne(m => m.Payment)
                .WithMany()
                .HasForeignKey(m => m.PaymentId)
                .OnDelete(DeleteBehavior.SetNull)
                .IsRequired(false);

            // Configure UserRole join entity
            modelBuilder.Entity<UserRole>()
                .HasOne(ur => ur.User)
                .WithMany(u => u.UserRoles)
                .HasForeignKey(ur => ur.UserId)
                .OnDelete(DeleteBehavior.Cascade)
                .IsRequired(false);

            modelBuilder.Entity<UserRole>()
                .HasOne(ur => ur.Role)
                .WithMany(r => r.UserRoles)
                .HasForeignKey(ur => ur.RoleId)
                .OnDelete(DeleteBehavior.Cascade);

            // Configure PersonalTrainer -> User relationship as optional
            modelBuilder.Entity<PersonalTrainer>()
                .HasOne(pt => pt.User)
                .WithMany()
                .HasForeignKey(pt => pt.UserId)
                .OnDelete(DeleteBehavior.NoAction)
                .IsRequired(false);

            modelBuilder.Entity<NutritionPlan>()
              .HasOne(n => n.User)
              .WithMany()
              .HasForeignKey(n => n.UserId)
              .OnDelete(DeleteBehavior.NoAction)
              .IsRequired(false);

            // Set TrainingPlans -> Users as NO ACTION to break potential cycles
            modelBuilder.Entity<TrainingPlan>()
                .HasOne(t => t.User)
                .WithMany()
                .HasForeignKey(t => t.UserId)
                .OnDelete(DeleteBehavior.NoAction);


            modelBuilder.Entity<Training>()
                .HasOne(t => t.Client)
                .WithMany()
                .HasForeignKey(t => t.ClientId)
                .OnDelete(DeleteBehavior.NoAction); // Change from Cascade to NoAction

            modelBuilder.Entity<Training>()
                .HasOne(t => t.PersonalTrainer)
                .WithMany()
                .HasForeignKey(t => t.PersonalTrainerId)
                .OnDelete(DeleteBehavior.Cascade);

            // Configure Message relationships to avoid multiple cascade paths
            modelBuilder.Entity<Message>()
                .HasOne(m => m.Sender)
                .WithMany()
                .HasForeignKey(m => m.SenderId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Message>()
                .HasOne(m => m.Recipient)
                .WithMany()
                .HasForeignKey(m => m.RecipientId)
                .OnDelete(DeleteBehavior.NoAction); // Use NoAction for Recipient to avoid cascade path conflict



            // Create a unique constraint on UserId and RoleId
            modelBuilder.Entity<UserRole>()
                .HasIndex(ur => new { ur.UserId, ur.RoleId })
                .IsUnique();

            // Configure MonthlyTrainingStatistics - ensure unique constraint per user/year/month
            modelBuilder.Entity<MonthlyTrainingStatistics>()
                .HasIndex(mts => new { mts.UserId, mts.Year, mts.Month })
                .IsUnique();

            modelBuilder.Entity<MonthlyTrainingStatistics>()
                .HasOne(mts => mts.User)
                .WithMany()
                .HasForeignKey(mts => mts.UserId)
                .OnDelete(DeleteBehavior.Cascade)
                .IsRequired(false);

            // Configure Country → City relationship
            modelBuilder.Entity<City>()
                .HasOne(c => c.Country)
                .WithMany(co => co.Cities)
                .HasForeignKey(c => c.CountryId)
                .OnDelete(DeleteBehavior.Restrict);

            // Configure Gym → City relationship
            modelBuilder.Entity<Gym>()
                .HasOne(g => g.City)
                .WithMany(c => c.Gyms)
                .HasForeignKey(g => g.CityId)
                .OnDelete(DeleteBehavior.SetNull)
                .IsRequired(false);

            // Configure GroupTrainingSession relationships
            modelBuilder.Entity<GroupTrainingSession>()
                .HasOne(g => g.Creator)
                .WithMany()
                .HasForeignKey(g => g.CreatorId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<GroupTrainingSessionParticipant>()
                .HasOne(p => p.GroupTrainingSession)
                .WithMany(g => g.Participants)
                .HasForeignKey(p => p.GroupTrainingSessionId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<GroupTrainingSessionParticipant>()
                .HasOne(p => p.User)
                .WithMany()
                .HasForeignKey(p => p.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<GroupTrainingSessionParticipant>()
                .HasIndex(p => new { p.GroupTrainingSessionId, p.UserId })
                .IsUnique();

            // Configure Payment -> User relationship
            modelBuilder.Entity<Payment>()
                .HasOne(p => p.User)
                .WithMany()
                .HasForeignKey(p => p.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Role>().HasData(
               new Role { Id = 1, Name = "Administrator", Description = "Administrator", IsActive = true, CreatedAt = DateTime.UtcNow },
               new Role { Id = 2, Name = "Kupac", Description = "Korisnik - kupac", IsActive = true, CreatedAt = DateTime.UtcNow },
               new Role { Id = 3, Name = "SuperAdmin", Description = "Super Administrator sa svim privilegijama", IsActive = true, CreatedAt = DateTime.UtcNow }
           );

            
            // Users
            modelBuilder.Entity<User>().HasData(
                new User { Id = 1, FirstName = "Ahmet", LastName = "Stupac", Email = "ahmet.stupac@edu.fit.ba", Username = "superadmin", PasswordHash = "cnmepYg0B3XVzwr9POBGEWwEAzNGv+KuqebPm0/AvFk=", PasswordSalt = "Qeunp0McejKht6Qx9PW6ug==", IsActive = true, CreatedAt = DateTime.UtcNow, ProfileImageId = 1 },
                new User { Id = 2, FirstName = "Denis", LastName = "Music", Email = "adil@edu.fit.ba", Username = "desktop", PasswordHash = "cnmepYg0B3XVzwr9POBGEWwEAzNGv+KuqebPm0/AvFk=", PasswordSalt = "Qeunp0McejKht6Qx9PW6ug==", IsActive = true, CreatedAt = DateTime.UtcNow, ProfileImageId = 1 },
                new User { Id = 3, FirstName = "Ismail", LastName = "Catic", Email = "ahmet2.stupac@edu.fit.ba", Username = "trener2", PasswordHash = "cnmepYg0B3XVzwr9POBGEWwEAzNGv+KuqebPm0/AvFk=", PasswordSalt = "Qeunp0McejKht6Qx9PW6ug==", IsActive = true, CreatedAt = DateTime.UtcNow, ProfileImageId = 1 },
                new User { Id = 4, FirstName = "Alem", LastName = "Stupac", Email = "ahmet3.stupac@edu.fit.ba", Username = "trener3", PasswordHash = "cnmepYg0B3XVzwr9POBGEWwEAzNGv+KuqebPm0/AvFk=", PasswordSalt = "Qeunp0McejKht6Qx9PW6ug==", IsActive = true, CreatedAt = DateTime.UtcNow, ProfileImageId = 1 },
                new User { Id = 5, FirstName = "Adil", LastName = "Joldic", Email = "ahmet4.stupac@edu.fit.ba", Username = "trener4", PasswordHash = "cnmepYg0B3XVzwr9POBGEWwEAzNGv+KuqebPm0/AvFk=", PasswordSalt = "Qeunp0McejKht6Qx9PW6ug==", IsActive = true, CreatedAt = DateTime.UtcNow, ProfileImageId = 1 },
                new User { Id = 6, FirstName = "Amel", LastName = "Music", Email = "ahmet5.stupac@edu.fit.ba", Username = "trener5", PasswordHash = "cnmepYg0B3XVzwr9POBGEWwEAzNGv+KuqebPm0/AvFk=", PasswordSalt = "Qeunp0McejKht6Qx9PW6ug==", IsActive = true, CreatedAt = DateTime.UtcNow, ProfileImageId = 1 },
                new User { Id = 7, FirstName = "Emina", LastName = "Junuz", Email = "ahmet6.stupac@edu.fit.ba", Username = "mobile", PasswordHash = "cnmepYg0B3XVzwr9POBGEWwEAzNGv+KuqebPm0/AvFk=", PasswordSalt = "Qeunp0McejKht6Qx9PW6ug==", IsActive = true, CreatedAt = DateTime.UtcNow, ProfileImageId = 1 }
            );

            modelBuilder.Entity<UserRole>().HasData(
                new UserRole { Id = 1, UserId = 1, RoleId = 3, DateAssigned = DateTime.UtcNow },
                new UserRole { Id = 2, UserId = 2, RoleId = 1, DateAssigned = DateTime.UtcNow },
                new UserRole { Id = 4, UserId = 3, RoleId = 1, DateAssigned = DateTime.UtcNow }, 
                new UserRole { Id = 5, UserId = 4, RoleId = 1, DateAssigned = DateTime.UtcNow }, 
                new UserRole { Id = 6, UserId = 5, RoleId = 1, DateAssigned = DateTime.UtcNow }, 
                new UserRole { Id = 7, UserId = 6, RoleId = 1, DateAssigned = DateTime.UtcNow }, 
                new UserRole { Id = 8, UserId = 7, RoleId = 2, DateAssigned = DateTime.UtcNow }  
            );

            // Equipment
            modelBuilder.Entity<Equipment>().HasData(
                new Equipment { Id = 1, Name = "Barbell" },
                new Equipment { Id = 2, Name = "Dumbbell" },
                new Equipment { Id = 3, Name = "Pull-up Bar" },
                new Equipment { Id = 4, Name = "Resistance Band" },
                new Equipment { Id = 5, Name = "Treadmill" }
            );

            // MuscleGroup
            modelBuilder.Entity<MuscleGroup>().HasData(
                new MuscleGroup { Id = 1, Name = "Chest" },
                new MuscleGroup { Id = 2, Name = "Back" },
                new MuscleGroup { Id = 3, Name = "Shoulders" },
                new MuscleGroup { Id = 4, Name = "Legs" },
                new MuscleGroup { Id = 5, Name = "Arms" }
            );

            // Country
            modelBuilder.Entity<Country>().HasData(
                new Country { Id = 1, Name = "Bosnia and Herzegovina" }
            );

            // City
            modelBuilder.Entity<City>().HasData(
                new City { Id = 1, Name = "Mostar",   CountryId = 1 },
                new City { Id = 2, Name = "Sarajevo", CountryId = 1 },
                new City { Id = 3, Name = "Zenica",   CountryId = 1 }
            );

            // Gym
            modelBuilder.Entity<Gym>().HasData(
                new Gym { Id = 1, Name = "FitLife Gym",       Address = "Titova 15",        CityId = 2, Email = "contact@fitlifegym.ba",  PhoneNumber = "+387 33 111 111", WorkTime = "Pon-Pet: 06-22h, Sub-Ned: 08-18h" },
                new Gym { Id = 2, Name = "PowerZone Fitness", Address = "Bulevar Mira 22",  CityId = 1, Email = "info@powerzone.ba",       PhoneNumber = "+387 36 222 222", WorkTime = "Pon-Ned: 07-23h" }
            );

            // PersonalTrainer
            modelBuilder.Entity<PersonalTrainer>().HasData(
                new PersonalTrainer { Id = 1, UserId = 2, YearsOfExperience = 8, IsActive = true, Certifications = "NASM-CPT, CSCS", Sport = "Karate", Gender = "Male" },
                new PersonalTrainer { Id = 2, UserId = 3, YearsOfExperience = 3, IsActive = true, Certifications = "ACE-CPT", Sport = "Running", Gender = "Male" },
                new PersonalTrainer { Id = 3, UserId = 4, YearsOfExperience = 4, IsActive = true, Certifications = "ACE-CC", Sport = "Gym" , Gender = "Female" },
                new PersonalTrainer { Id = 4, UserId = 5, YearsOfExperience = 10, IsActive = true, Certifications = "ACE-DPT", Sport = "Boxing", Gender = "Male" }
            );

            // Exerciseq
            modelBuilder.Entity<Exercise>().HasData(
                new Exercise { Id = 1, Name = "Bench Press", EquipmentId = 1 , ImageId=5},
                new Exercise { Id = 2, Name = "Deadlift", EquipmentId = 1, ImageId = 8 },
                new Exercise { Id = 3, Name = "Dumbbell Curl", EquipmentId = 2, ImageId = 9 },
                new Exercise { Id = 4, Name = "Pull-up", EquipmentId = 3, ImageId = 4},
                new Exercise { Id = 5, Name = "Barbell Squat", EquipmentId = 1, ImageId = 7},
                new Exercise { Id = 6, Name = "Barbell Row", EquipmentId = 1, ImageId = 6 },
                new Exercise { Id = 7, Name = "Treadmill Run", EquipmentId = 5, ImageId = 10},
                new Exercise { Id = 8, Name = "Lateral Raise", EquipmentId = 2, ImageId = 11 }
            );

            // ExerciseMuscleGroup
            modelBuilder.Entity<ExerciseMuscleGroup>().HasData(
                new ExerciseMuscleGroup { Id = 1, ExerciseId = 1, MuscleGroupId = 1 },  // Bench Press -> Chest
                new ExerciseMuscleGroup { Id = 2, ExerciseId = 1, MuscleGroupId = 3 },  // Bench Press -> Shoulders
                new ExerciseMuscleGroup { Id = 3, ExerciseId = 2, MuscleGroupId = 2 },  // Deadlift -> Back
                new ExerciseMuscleGroup { Id = 4, ExerciseId = 2, MuscleGroupId = 4 },  // Deadlift -> Legs
                new ExerciseMuscleGroup { Id = 5, ExerciseId = 3, MuscleGroupId = 5 },  // Dumbbell Curl -> Arms
                new ExerciseMuscleGroup { Id = 6, ExerciseId = 4, MuscleGroupId = 2 },  // Pull-up -> Back
                new ExerciseMuscleGroup { Id = 7, ExerciseId = 5, MuscleGroupId = 4 },  // Barbell Squat -> Legs
                new ExerciseMuscleGroup { Id = 8, ExerciseId = 6, MuscleGroupId = 2 },  // Resistance Band Row -> Back
                new ExerciseMuscleGroup { Id = 9, ExerciseId = 7, MuscleGroupId = 4 },  // Treadmill Run -> Legs
                new ExerciseMuscleGroup { Id = 10, ExerciseId = 8, MuscleGroupId = 3 }  // Lateral Raise -> Shoulders
            );

            // TrainingPlan
            modelBuilder.Entity<TrainingPlan>().HasData(
                new TrainingPlan { Id = 1, PersonalTrainerId = 1, UserId = 2, Title = "Beginner Strength Program", Description = "A 4-week program for building foundational strength using compound lifts.", BasePrice = 49.99f, CreatedAt = new DateTime(2026, 1, 15, 0, 0, 0, DateTimeKind.Utc) },
                new TrainingPlan { Id = 2, PersonalTrainerId = 1, UserId = 2, Title = "Advanced Hypertrophy", Description = "12-week muscle-building program designed for experienced lifters.", BasePrice = 79.99f, CreatedAt = new DateTime(2026, 1, 15, 0, 0, 0, DateTimeKind.Utc) },
                new TrainingPlan { Id = 3, PersonalTrainerId = 2, UserId = null, Title = "Cardio Blast", Description = "High-intensity cardio program focused on fat loss and endurance.", BasePrice = 39.99f, CreatedAt = new DateTime(2026, 1, 15, 0, 0, 0, DateTimeKind.Utc) },
                new TrainingPlan { Id = 4, PersonalTrainerId = 3, UserId = null, Title = "Upper Body Builder", Description = "Focused upper body strength and hypertrophy plan for intermediate clients.", BasePrice = 59.99f, CreatedAt = new DateTime(2026, 1, 16, 0, 0, 0, DateTimeKind.Utc) },
                new TrainingPlan { Id = 5, PersonalTrainerId = 4, UserId = null, Title = "Boxing Conditioning", Description = "Conditioning plan for boxing stamina, core stability, and footwork.", BasePrice = 69.99f, CreatedAt = new DateTime(2026, 1, 17, 0, 0, 0, DateTimeKind.Utc) }
            );

            // NutritionPlan
            modelBuilder.Entity<NutritionPlan>().HasData(
                new NutritionPlan { Id = 1, PersonalTrainerId = 1, UserId = 2, Title = "Muscle Gain Diet", Description = "High-protein diet plan tailored for muscle building and recovery.", TotalCalories = "3200", Protein = "220g", Carbs = "320g", Fats = 80, Price = 29.99f, CreatedAt = new DateTime(2026, 1, 15, 0, 0, 0, DateTimeKind.Utc) },
                new NutritionPlan { Id = 2, PersonalTrainerId = 1, UserId = null, Title = "Fat Loss Plan", Description = "Calorie-deficit diet designed for sustainable and healthy weight loss.", TotalCalories = "1800", Protein = "160g", Carbs = "150g", Fats = 60, Price = 24.99f, CreatedAt = new DateTime(2026, 1, 15, 0, 0, 0, DateTimeKind.Utc) },
                new NutritionPlan { Id = 3, PersonalTrainerId = 2, UserId = null, Title = "Endurance Fueling", Description = "Carbohydrate-focused plan for endurance athletes and long-distance runners.", TotalCalories = "2800", Protein = "140g", Carbs = "380g", Fats = 55, Price = 19.99f, CreatedAt = new DateTime(2026, 1, 15, 0, 0, 0, DateTimeKind.Utc) }
            );

            // ExercisePlan
            modelBuilder.Entity<ExercisePlan>().HasData(
                new ExercisePlan { Id = 1, TrainingPlanId = 1, ExerciseId = 1, Sets = 3, Reps = 10, Duration = null, CustomPrice = null, Note = "Focus on form and controlled movement" },
                new ExercisePlan { Id = 2, TrainingPlanId = 1, ExerciseId = 5, Sets = 3, Reps = 12, Duration = null, CustomPrice = null, Note = "Keep back straight, knees tracking over toes" },
                new ExercisePlan { Id = 3, TrainingPlanId = 1, ExerciseId = 4, Sets = 3, Reps = 8,  Duration = null, CustomPrice = null, Note = "Use assisted machine if full pull-ups are too difficult" },
                new ExercisePlan { Id = 4, TrainingPlanId = 2, ExerciseId = 2, Sets = 5, Reps = 5,  Duration = null, CustomPrice = null, Note = "Progressive overload - increase weight each week" },
                new ExercisePlan { Id = 5, TrainingPlanId = 2, ExerciseId = 1, Sets = 4, Reps = 8,  Duration = null, CustomPrice = null, Note = "Drop set on the last set" },
                new ExercisePlan { Id = 6, TrainingPlanId = 3, ExerciseId = 7, Sets = null, Reps = null, Duration = 30, CustomPrice = null, Note = "Maintain 70-80% of maximum heart rate" }
            );

            // Training
            modelBuilder.Entity<Training>().HasData(
                new Training { Id = 1, Name = "Strength Foundation", Description = "One-on-one session focusing on compound lifts and proper technique.", Duration = 60, ClientId = 2, PersonalTrainerId = 1 },
                new Training { Id = 2, Name = "Cardio Conditioning", Description = "Treadmill intervals and circuit training session for fat burn.", Duration = 45, ClientId = null, PersonalTrainerId = 2 },
                new Training { Id = 3, Name = "Mobility & Recovery", Description = "Guided stretching, foam rolling, and mobility work.", Duration = 30, ClientId = 2, PersonalTrainerId = 1 }
            );

            // TrainingSession
            modelBuilder.Entity<TrainingSession>().HasData(
                new TrainingSession { Id = 1, ClientId = 2, PersonalTrainerId = 1, GymId = 1, ScheduledDateTime = new DateTime(2026, 3, 10, 9, 0, 0, DateTimeKind.Utc), DurationMinutes = 60, Status = TrainingSessionStatus.Confirmed, Price = 50f, Notes = "Please bring lifting gloves", TrainerNotes = "Client needs focus on squat depth", CreatedAt = new DateTime(2026, 1, 15, 0, 0, 0, DateTimeKind.Utc) },
                new TrainingSession { Id = 2, ClientId = 2, PersonalTrainerId = 1, GymId = 1, ScheduledDateTime = new DateTime(2026, 3, 12, 10, 0, 0, DateTimeKind.Utc), DurationMinutes = 60, Status = TrainingSessionStatus.Pending, Price = 50f, Notes = null, TrainerNotes = null, CreatedAt = new DateTime(2026, 1, 15, 0, 0, 0, DateTimeKind.Utc) },
                new TrainingSession { Id = 3, ClientId = null, PersonalTrainerId = 2, GymId = 2, ScheduledDateTime = new DateTime(2026, 3, 15, 8, 0, 0, DateTimeKind.Utc), DurationMinutes = 45, Status = TrainingSessionStatus.Pending, Price = 40f, Notes = "Open availability slot", TrainerNotes = null, CreatedAt = new DateTime(2026, 1, 15, 0, 0, 0, DateTimeKind.Utc) }
            );

            // GroupTrainingSession
            modelBuilder.Entity<GroupTrainingSession>().HasData(
                new GroupTrainingSession { Id = 1, Name = "Morning Bootcamp", TrainingType = "Bodyweight Training", KcalBurned = 450, DurationMinutes = 45, Place = "FitLife Gym - Studio A", Notes = "Bring a mat and water bottle", CreatorId = 1, CreatedAt = new DateTime(2026, 1, 15, 0, 0, 0, DateTimeKind.Utc) },
                new GroupTrainingSession { Id = 2, Name = "Sunset Run", TrainingType = "Running", KcalBurned = 350, DurationMinutes = 40, Place = "Central Park Trail", Notes = null, CreatorId = 1, CreatedAt = new DateTime(2026, 1, 15, 0, 0, 0, DateTimeKind.Utc) }
            );

            // GroupTrainingSessionParticipant
            modelBuilder.Entity<GroupTrainingSessionParticipant>().HasData(
                new GroupTrainingSessionParticipant { Id = 1, GroupTrainingSessionId = 1, UserId = 2, JoinedAt = new DateTime(2026, 1, 15, 0, 0, 0, DateTimeKind.Utc) },
                new GroupTrainingSessionParticipant { Id = 2, GroupTrainingSessionId = 2, UserId = 2, JoinedAt = new DateTime(2026, 1, 15, 0, 0, 0, DateTimeKind.Utc) }
            );

            // PersonalTrainerRating
            modelBuilder.Entity<PersonalTrainerRating>().HasData(
                new PersonalTrainerRating { Id = 1, UserId = 2, PersonalTrainerId = 1, Rating = 5, Comment = "Excellent trainer! Very knowledgeable, motivating, and professional.", CreatedAt = new DateTime(2026, 1, 20, 0, 0, 0, DateTimeKind.Utc) },
                new PersonalTrainerRating { Id = 2, UserId = 2, PersonalTrainerId = 2, Rating = 4, Comment = "Great running coach. Helped me improve my pace and endurance significantly.", CreatedAt = new DateTime(2026, 1, 22, 0, 0, 0, DateTimeKind.Utc) }
            );

            // Payment
            modelBuilder.Entity<Payment>().HasData(
                new Payment { Id = 1, UserId = 2, ItemType = PaymentItemType.TrainingPlan, ItemId = 1, AmountInCents = 4999, StripePaymentIntentId = "pi_test_3NpL4K2eZvKYlo2C0QJx7aBC", Status = "succeeded", CreatedAt = new DateTime(2026, 1, 16, 0, 0, 0, DateTimeKind.Utc) },
                new Payment { Id = 2, UserId = 2, ItemType = PaymentItemType.NutritionPlan, ItemId = 1, AmountInCents = 2999, StripePaymentIntentId = "pi_test_7MqQ8R5eZvKYlo2C1XPz9eFG", Status = "succeeded", CreatedAt = new DateTime(2026, 1, 17, 0, 0, 0, DateTimeKind.Utc) }
            );



            // images

            modelBuilder.Entity<Image>().HasData(
                new Image { Id = 1, Name = "Ahmet Profile", Url = "https://cloudfordiversclub.blob.core.windows.net/takmicenja/users/1/9e3e8fe361ec4270962aea28b798f5e3-Sample_User_Icon.png", Size = 204800, IsHeader = true },
                new Image { Id = 2, Name = "Arena1", Url = "https://cloudfordiversclub.blob.core.windows.net/takmicenja/general/031c3d0740664e38b58800302259c3ef-arena.jpg", Size = 204800, IsHeader = true },
                new Image { Id = 3, Name = "Arena2", Url = "https://cloudfordiversclub.blob.core.windows.net/takmicenja/general/498dbeb0028f46f7928417bda2be856d-arena2.png", Size = 204800, IsHeader = true },
                new Image { Id = 4, Name = "pull-up", Url = "https://cloudfordiversclub.blob.core.windows.net/takmicenja/general/045cfc4432704dff8b23ee0bd602aa09-pull up bar.png", Size = 204800, IsHeader = true },
                new Image { Id = 5, Name = "bench-press", Url = "https://cloudfordiversclub.blob.core.windows.net/takmicenja/general/b9921a30b8864d3b87b8329883ef4b54-benchh.jpg", Size = 204800, IsHeader = true },
                new Image { Id = 6, Name = "row", Url = "https://cloudfordiversclub.blob.core.windows.net/takmicenja/general/row.jpeg", Size = 204800, IsHeader = true },
                new Image { Id = 7, Name = "squat", Url = "https://cloudfordiversclub.blob.core.windows.net/takmicenja/general/squat.jpg", Size = 204800, IsHeader = true },
                new Image { Id = 8, Name = "deadlift", Url = "https://cloudfordiversclub.blob.core.windows.net/takmicenja/general/deadlift.jpg", Size = 204800, IsHeader = true },
                new Image { Id = 9, Name = "curl1", Url = "https://cloudfordiversclub.blob.core.windows.net/takmicenja/general/curl1.jpeg", Size = 204800, IsHeader = true },
                new Image { Id = 10, Name = "treadmill", Url = "https://cloudfordiversclub.blob.core.windows.net/takmicenja/general/treadmill.jpeg", Size = 204800, IsHeader = true },
                new Image { Id = 11, Name = "lateral-raise", Url = "https://cloudfordiversclub.blob.core.windows.net/takmicenja/general/lateral-raise.jpeg", Size = 204800, IsHeader = true }
            );




        }
    }
}