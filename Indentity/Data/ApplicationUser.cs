using Microsoft.AspNetCore.Identity;
using System.ComponentModel.DataAnnotations;

namespace Indentity.Data
{

    public class ApplicationUser : IdentityUser
    {
        [Required(ErrorMessage = "Họ tên không được để trống")]
        [StringLength(100)]
        [PersonalData]
        public string FullName { get; set; } = string.Empty;

        [DataType(DataType.Date)]
        [PersonalData]
        public DateTime? DateOfBirth { get; set; }

        [StringLength(200)]
        [PersonalData]
        public string? Address { get; set; }


    }
}
