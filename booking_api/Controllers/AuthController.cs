using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using BookingApi.Data;

namespace BookingApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly IConfiguration _configuration;

        public AuthController(ApplicationDbContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }

        // POST: api/auth/login
        [HttpPost("login")]
        public async Task<ActionResult<object>> Login([FromBody] LoginRequest request)
        {
            try
            {
                int selectedRole = request.SelectedRole;
                var connectionString = _configuration.GetConnectionString("DefaultConnection");

                using (var connection = new SqlConnection(connectionString))
                {
                    await connection.OpenAsync();

                    // Find user by UserCode or Email
                    var userInfoCmd = new SqlCommand(
                        @"SELECT TOP 1 
                            UserInformationId, FirstName, MiddleName, LastName, 
                            Email, Number, UserCode, StatusId
                        FROM UserInformation
                        WHERE UserCode = @Username OR Email = @Username",
                        connection);
                    userInfoCmd.Parameters.AddWithValue("@Username", request.Username);

                    UserInfoDto? userInfo = null;
                    using (var reader = await userInfoCmd.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            userInfo = new UserInfoDto
                            {
                                UserInformationId = reader.GetInt16(0),
                                FirstName = reader.IsDBNull(1) ? null : reader.GetString(1),
                                MiddleName = reader.IsDBNull(2) ? null : reader.GetString(2),
                                LastName = reader.IsDBNull(3) ? null : reader.GetString(3),
                                Email = reader.IsDBNull(4) ? null : reader.GetString(4),
                                Number = reader.IsDBNull(5) ? null : reader.GetString(5),
                                UserCode = reader.IsDBNull(6) ? null : reader.GetString(6),
                                StatusId = reader.IsDBNull(7) ? null : reader.GetInt16(7)
                            };
                        }
                    }

                    if (userInfo == null)
                    {
                        return Unauthorized(new { message = "Invalid username or password" });
                    }

                    // Check if user is active
                    if (userInfo.StatusId != 1)
                    {
                        return Unauthorized(new { message = "User account is inactive" });
                    }

                    // Get the User record
                    var userCmd = new SqlCommand(
                        @"SELECT TOP 1 UserId, UserTypeId, UserInformationId
                        FROM [User]
                        WHERE UserInformationId = @UserInformationId",
                        connection);
                    userCmd.Parameters.AddWithValue("@UserInformationId", userInfo.UserInformationId);

                    UserDto? user = null;
                    using (var reader = await userCmd.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            user = new UserDto
                            {
                                UserId = reader.GetInt16(0),
                                UserTypeId = reader.IsDBNull(1) ? null : reader.GetInt16(1),
                                UserInformationId = reader.IsDBNull(2) ? null : reader.GetInt16(2)
                            };
                        }
                    }

                    if (user == null)
                    {
                        return Unauthorized(new { message = "User account not found" });
                    }

                    // Check if user has a UserTypeId assigned
                    if (!user.UserTypeId.HasValue)
                    {
                        return Unauthorized(new { message = "User type not assigned" });
                    }

                    // Validate role matches user type
                    if (selectedRole != user.UserTypeId.Value)
                    {
                        string attemptedRole = selectedRole == 1 ? "Admin" : "Local";
                        return Unauthorized(new { message = $"You are not authorized to login as {attemptedRole}" });
                    }

                    // Get user credentials
                    var credentialCmd = new SqlCommand(
                        @"SELECT TOP 1 UserCredentialId, UserId, Password
                        FROM UserCredential
                        WHERE UserId = @UserId",
                        connection);
                    credentialCmd.Parameters.AddWithValue("@UserId", user.UserId);

                    UserCredentialDto? credential = null;
                    using (var reader = await credentialCmd.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            credential = new UserCredentialDto
                            {
                                UserCredentialId = reader.GetInt16(0),
                                UserId = reader.IsDBNull(1) ? null : reader.GetInt16(1),
                                Password = reader.IsDBNull(2) ? null : reader.GetString(2)
                            };
                        }
                    }

                    if (credential == null)
                    {
                        return Unauthorized(new { message = "User credentials not found" });
                    }

                    // Validate password
                    if (credential.Password != request.Password)
                    {
                        return Unauthorized(new { message = "Invalid username or password" });
                    }

                    // Get user type description
                    var userTypeCmd = new SqlCommand(
                        @"SELECT TOP 1 UserTypeId, UserTypeCd, UserTypeDesc
                        FROM UserType
                        WHERE UserTypeId = @UserTypeId",
                        connection);
                    userTypeCmd.Parameters.AddWithValue("@UserTypeId", user.UserTypeId.Value);

                    string? userTypeDesc = null;
                    using (var reader = await userTypeCmd.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            userTypeDesc = reader.IsDBNull(2) ? null : reader.GetString(2);
                        }
                    }

                    // Login successful
                    return Ok(new
                    {
                        message = "Login successful",
                        user = new
                        {
                            userId = user.UserId,
                            userTypeId = user.UserTypeId,
                            userType = userTypeDesc,
                            firstName = userInfo.FirstName,
                            middleName = userInfo.MiddleName,
                            lastName = userInfo.LastName,
                            email = userInfo.Email,
                            userCode = userInfo.UserCode,
                            fullName = $"{userInfo.FirstName} {userInfo.MiddleName} {userInfo.LastName}".Trim()
                        }
                    });
                }
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    message = "Error during login",
                    error = ex.Message,
                    innerError = ex.InnerException?.Message,
                    stackTrace = ex.StackTrace
                });
            }
        }
    }

    // DTOs using short (Int16) to match smallint in database
    public class UserInfoDto
    {
        public short UserInformationId { get; set; }
        public string? FirstName { get; set; }
        public string? MiddleName { get; set; }
        public string? LastName { get; set; }
        public string? Email { get; set; }
        public string? Number { get; set; }
        public string? UserCode { get; set; }
        public short? StatusId { get; set; }
    }

    public class UserDto
    {
        public short UserId { get; set; }
        public short? UserTypeId { get; set; }
        public short? UserInformationId { get; set; }
    }

    public class UserCredentialDto
    {
        public short UserCredentialId { get; set; }
        public short? UserId { get; set; }
        public string? Password { get; set; }
    }

    public class UserTypeDto
    {
        public short UserTypeId { get; set; }
        public string? UserTypeCd { get; set; }
        public string? UserTypeDesc { get; set; }
    }

    public class LoginRequest
    {
        public string Username { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public int SelectedRole { get; set; }
    }
}
