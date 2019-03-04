using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace TheUnreliableAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class RandomController : ControllerBase
    {
        // GET api/values
        [HttpGet]
        public ActionResult<IEnumerable<string>> Get()
        {
            Random random = new Random();
            int randomNumber = random.Next(1,10);

            switch (randomNumber)
            {
                case 1: return new string[] { "London", DateTime.UtcNow.ToString() }; ;
                case 2: return StatusCode(201);
                case 3: return StatusCode(202);
                case 4: return StatusCode(203);
                case 5: return StatusCode(403);
                case 6: return StatusCode(404);
                case 7: return StatusCode(409);
                case 8: return StatusCode(418);
                case 9: return StatusCode(429);
                case 10: return StatusCode(451);
                default: return StatusCode(200);
            }
        }


        // POST api/values
        [HttpPost]
        public ActionResult<int> Post([FromBody] string value)
        {
            try
            {
                int passedInt = Convert.ToInt32(value);
                int dayOfTheWeek = DateTime.Now.Day;

                return (passedInt * dayOfTheWeek);

            }
            catch (Exception)
            {
                return StatusCode(406);
            }


        }
    }
}