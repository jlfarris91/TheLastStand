namespace W3xPipeline
{
    using System;
    using System.Diagnostics;

    public interface ILogger
    {
        void Log(string message);
    }

    public class ConsoleLogger : ILogger
    {
        public void Log(string message)
        {
            Console.WriteLine($"[{DateTime.UtcNow:O}] {message}");
            Debug.WriteLine($"[{DateTime.UtcNow:O}] {message}");
        }
    }
}