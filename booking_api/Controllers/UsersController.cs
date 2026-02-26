using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BookingApi.Data;
using BookingApi.Models;

namespace BookingApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UsersController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public UsersController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: api/users
        [HttpGet]
        public async Task<ActionResult<IEnumerable<object>>> GetUsers()
        {
            var users = await _context.Users
                .Include(u => u.UserInformation)
                    .ThenInclude(ui => ui!.Status)
                .Include(u => u.UserType)
                .OrderByDescending(u => u.CreateDttm)
                .Select(u => new
                {
                    u.UserId,
                    u.UserIdType,
                    u.UserInformationId,
                    UserTypeDesc = u.UserType != null ? u.UserType.UserTypeDesc : null,
                    UserTypeCd = u.UserType != null ? u.UserType.UserTypeCd : null,
                    FirstName = u.UserInformation != null ? u.UserInformation.FirstName : null,
                    MiddleName = u.UserInformation != null ? u.UserInformation.MiddleName : null,
                    LastName = u.UserInformation != null ? u.UserInformation.LastName : null,
                    Email = u.UserInformation != null ? u.UserInformation.Email : null,
                    Number = u.UserInformation != null ? u.UserInformation.Number : null,
                    UserCode = u.UserInformation != null ? u.UserInformation.UserCode : null,
                    StatusId = u.UserInformation != null ? u.UserInformation.StatusId : null,
                    StatusDesc = u.UserInformation != null && u.UserInformation.Status != null 
                        ? u.UserInformation.Status.StatusDesc : null,
                    u.Remarks,
                    u.CreateUserId,
                    u.CreateDttm,
                    u.UpdateUserId,
                    u.UpdateDttm
                })
                .ToListAsync();

            return Ok(users);
        }

        // GET: api/users/5
        [HttpGet("{id}")]
        public async Task<ActionResult<object>> GetUser(int id)
        {
            var user = await _context.Users
                .Include(u => u.UserInformation)
                    .ThenInclude(ui => ui!.Status)
                .Include(u => u.UserType)
                .Where(u => u.UserId == id)
                .Select(u => new
                {
                    u.UserId,
                    u.UserIdType,
                    u.UserInformationId,
                    UserTypeDesc = u.UserType != null ? u.UserType.UserTypeDesc : null,
                    UserTypeCd = u.UserType != null ? u.UserType.UserTypeCd : null,
                    FirstName = u.UserInformation != null ? u.UserInformation.FirstName : null,
                    MiddleName = u.UserInformation != null ? u.UserInformation.MiddleName : null,
                    LastName = u.UserInformation != null ? u.UserInformation.LastName : null,
                    Email = u.UserInformation != null ? u.UserInformation.Email : null,
                    Number = u.UserInformation != null ? u.UserInformation.Number : null,
                    UserCode = u.UserInformation != null ? u.UserInformation.UserCode : null,
                    StatusId = u.UserInformation != null ? u.UserInformation.StatusId : null,
                    StatusDesc = u.UserInformation != null && u.UserInformation.Status != null 
                        ? u.UserInformation.Status.StatusDesc : null,
                    u.Remarks,
                    u.CreateUserId,
                    u.CreateDttm,
                    u.UpdateUserId,
                    u.UpdateDttm
                })
                .FirstOrDefaultAsync();

            if (user == null)
            {
                return NotFound();
            }

            return Ok(user);
        }

        // POST: api/users
        [HttpPost]
        public async Task<ActionResult<object>> CreateUser([FromBody] CreateUserRequest request)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();
            
            try
            {
                // 1. Create UserInformation
                var userInfo = new UserInformation
                {
                    FirstName = request.FirstName,
                    MiddleName = request.MiddleName,
                    LastName = request.LastName,
                    Email = request.Email,
                    Number = request.Number,
                    UserCode = request.UserCode,
                    StatusId = request.StatusId,
                    CreateUserId = request.CreateUserId ?? "SYSTEM",
                    CreateDttm = DateTime.Now,
                    UpdateUserId = request.CreateUserId ?? "SYSTEM",
                    UpdateDttm = DateTime.Now
                };

                _context.UserInformations.Add(userInfo);
                await _context.SaveChangesAsync();

                // 2. Create User
                var user = new User
                {
                    UserIdType = request.UserTypeId,
                    UserInformationId = userInfo.UserInformationId,
                    Remarks = request.Remarks,
                    CreateUserId = request.CreateUserId ?? "SYSTEM",
                    CreateDttm = DateTime.Now,
                    UpdateUserId = request.CreateUserId ?? "SYSTEM",
                    UpdateDttm = DateTime.Now
                };

                _context.Users.Add(user);
                await _context.SaveChangesAsync();

                // 3. Create UserCredential
                var credential = new UserCredential
                {
                    UserId = user.UserId,
                    Password = request.Password, // TODO: Hash password in production
                    CreateUserId = request.CreateUserId ?? "SYSTEM",
                    CreateDttm = DateTime.Now,
                    UpdateUserId = request.CreateUserId ?? "SYSTEM",
                    UpdateDttm = DateTime.Now
                };

                _context.UserCredentials.Add(credential);
                await _context.SaveChangesAsync();

                await transaction.CommitAsync();

                // Return created user with all details
                var createdUser = await GetUser(user.UserId);
                return CreatedAtAction(nameof(GetUser), new { id = user.UserId }, createdUser.Value);
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                return StatusCode(500, new { 
                    message = "Error creating user", 
                    error = ex.Message,
                    innerError = ex.InnerException?.Message 
                });
            }
        }

        // PUT: api/users/5
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateUser(int id, [FromBody] UpdateUserRequest request)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();
            
            try
            {
                var user = await _context.Users
                    .Include(u => u.UserInformation)
                    .FirstOrDefaultAsync(u => u.UserId == id);

                if (user == null)
                {
                    return NotFound();
                }

                // Update UserInformation
                if (user.UserInformation != null)
                {
                    user.UserInformation.FirstName = request.FirstName ?? user.UserInformation.FirstName;
                    user.UserInformation.MiddleName = request.MiddleName ?? user.UserInformation.MiddleName;
                    user.UserInformation.LastName = request.LastName ?? user.UserInformation.LastName;
                    user.UserInformation.Email = request.Email ?? user.UserInformation.Email;
                    user.UserInformation.Number = request.Number ?? user.UserInformation.Number;
                    user.UserInformation.UserCode = request.UserCode ?? user.UserInformation.UserCode;
                    user.UserInformation.StatusId = request.StatusId ?? user.UserInformation.StatusId;
                    user.UserInformation.UpdateUserId = request.UpdateUserId ?? "SYSTEM";
                    user.UserInformation.UpdateDttm = DateTime.Now;
                }

                // Update User
                user.UserIdType = request.UserTypeId ?? user.UserIdType;
                user.Remarks = request.Remarks ?? user.Remarks;
                user.UpdateUserId = request.UpdateUserId ?? "SYSTEM";
                user.UpdateDttm = DateTime.Now;

                // Update Password if provided
                if (!string.IsNullOrEmpty(request.Password))
                {
                    var credential = await _context.UserCredentials
                        .FirstOrDefaultAsync(c => c.UserId == id);
                    
                    if (credential != null)
                    {
                        credential.Password = request.Password; // TODO: Hash password in production
                        credential.UpdateUserId = request.UpdateUserId ?? "SYSTEM";
                        credential.UpdateDttm = DateTime.Now;
                    }
                }

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                var updatedUser = await GetUser(id);
                return Ok(updatedUser.Value);
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                return StatusCode(500, new { 
                    message = "Error updating user", 
                    error = ex.Message,
                    innerError = ex.InnerException?.Message 
                });
            }
        }

        // DELETE: api/users/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteUser(int id)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();
            
            try
            {
                var user = await _context.Users
                    .Include(u => u.UserInformation)
                    .FirstOrDefaultAsync(u => u.UserId == id);

                if (user == null)
                {
                    return NotFound();
                }

                // Delete UserCredential
                var credential = await _context.UserCredentials
                    .FirstOrDefaultAsync(c => c.UserId == id);
                if (credential != null)
                {
                    _context.UserCredentials.Remove(credential);
                }

                // Delete User
                _context.Users.Remove(user);

                // Delete UserInformation
                if (user.UserInformation != null)
                {
                    _context.UserInformations.Remove(user.UserInformation);
                }

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                return NoContent();
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                return StatusCode(500, new { 
                    message = "Error deleting user", 
                    error = ex.Message,
                    innerError = ex.InnerException?.Message 
                });
            }
        }
    }

    public class CreateUserRequest
    {
        public string? FirstName { get; set; }
        public string? MiddleName { get; set; }
        public string? LastName { get; set; }
        public string? Email { get; set; }
        public string? Number { get; set; }
        public short? StatusId { get; set; }
        public short? UserTypeId { get; set; }
        public string? UserCode { get; set; }
        public string? Password { get; set; }
        public string? Remarks { get; set; }
        public string? CreateUserId { get; set; }
    }

    public class UpdateUserRequest
    {
        public string? FirstName { get; set; }
        public string? MiddleName { get; set; }
        public string? LastName { get; set; }
        public string? Email { get; set; }
        public string? Number { get; set; }
        public short? StatusId { get; set; }
        public short? UserTypeId { get; set; }
        public string? UserCode { get; set; }
        public string? Password { get; set; }
        public string? Remarks { get; set; }
        public string? UpdateUserId { get; set; }
    }
}
